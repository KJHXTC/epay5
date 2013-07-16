/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� �����Ѽ���
** �� �� �ˣ����
** �������ڣ�2012-11-08
**
** $Revision: 1.3 $
** $Log: CalcFee.ec,v $
** Revision 1.3  2013/02/21 06:35:00  fengw
**
** 1���޸������ѽ���ַ�����ʽ��
**
** Revision 1.2  2012/12/04 01:24:28  fengw
**
** 1���滻ErrorLogΪWriteLog��
**
** Revision 1.1  2012/11/23 09:09:16  fengw
**
** ���ڽ��״���ģ���ʼ�汾
**
** Revision 1.2  2012/11/22 08:58:23  fengw
**
** 1�������������ʲ�ѯSQL���
**
** Revision 1.1  2012/11/21 07:20:46  fengw
**
** ���ڽ��״���ģ���ʼ�汾
**
*******************************************************************/

#define _EXTERN_

#include "finatran.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
    char    szDeptNo[15+1];                 /* ������ */
    char    szDeptDetail[70+1];             /* �����㼶��Ϣ */
    char    szShopNo[15+1];                 /* �̻��� */
    int     iTransType;                     /* �������� */
    int     iHostFeeType;                   /* �������� */
    int     iCardType;                      /* ������ */
    double  dAmountBegin;                   /* �����������޽�� */
    double  dAmount;                        /* ���׽�� */
    int     iFeeRate;                       /* �������� */
    double  dFeeBase;                       /* �������� */
    double  dFeeMin;                        /* ��������� */
    double  dFeeMax;                        /* ��������� */
EXEC SQL END DECLARE SECTION;

/* �����ѽ�� */
static double gdFeeAmount;

static int _CalcByRate();
static int _CalcByInterval();

/****************************************************************
** ��    �ܣ�����������
** ���������
**        ptApp                     app�ṹָ��
** ���������
**        ptApp->szAddiAmount       �����ѽ��
** �� �� ֵ��
**        SUCC                      ���������ѳɹ�
**        FAIL                      ����������ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/09
** ����˵����
**
** �޸���־��
****************************************************************/
int CalcFee(T_App *ptApp, int iFeeType)
{
    /* ������ֵ */
    memset(szDeptNo, 0, sizeof(szDeptNo));
    memset(szDeptDetail, 0, sizeof(szDeptDetail));
    memset(szShopNo, 0, sizeof(szShopNo));

    strcpy(szDeptNo, ptApp->szDeptNo);
    strcpy(szDeptDetail, ptApp->szDeptDetail);
    strcpy(szShopNo, ptApp->szShopNo);
    iTransType = ptApp->iTransType;
    iHostFeeType = iFeeType;
    iCardType = ptApp->iOutCardLevel;
    dAmount = atof(ptApp->szAmount) / 100;

    switch(giFeeCalcType)
    {
        case FEE_CALC_NOT:
            gdFeeAmount = 0.0f;
            break;
        case FEE_CALC_RATE:
            if(_CalcByRate(ptApp) != SUCC)
            {
                return FAIL;
            }
            break;
        case FEE_CALC_INTERVAL:
            if(_CalcByInterval(ptApp) != SUCC)
            {
                return FAIL;
            }
            break;
        default:
            strcpy(ptApp->szRetCode, ERR_UNDEF_FEECALCTYPE);
            WriteLog(ERROR, "�����Ѽ��㷽ʽ[%d]δ����!", giFeeCalcType);
            return FAIL;
    }

    /* ���������ѽ�app�ṹ */
    sprintf(ptApp->szAddiAmount, "%d", (int)(gdFeeAmount * 100));

    return SUCC;
}

/****************************************************************
** ��    �ܣ������ʼ���������
** ���������
**        ptApp                 app�ṹָ��
** ���������
**        gdFeeAmount           �����ѽ��
** �� �� ֵ��
**        SUCC                  ���������ѳɹ�
**        FAIL                  ����������ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/09
** ����˵����
**
** �޸���־��
****************************************************************/
static int _CalcByRate(T_App *ptApp)
{
    /* ��ѯ�̻��������ʱ� */
    EXEC SQL
        SELECT fee_rate, fee_base, fee_min, fee_max
        INTO :iFeeRate, :dFeeBase, :dFeeMin, :dFeeMax
        FROM
            (SELECT fee_rate, fee_base, fee_min, fee_max
            FROM shop_fee_rate
            WHERE shop_no = :szShopNo AND (trans_type = :iTransType OR trans_type = 0) AND
                  fee_type = :iHostFeeType AND card_type = :iCardType AND
                  amount_begin < :dAmount
            ORDER BY trans_type DESC, amount_begin DESC) WHERE ROWNUM = 1;
    if(SQLCODE == SQL_NO_RECORD)
    {
        /* ��ѯ�����������ʱ� */
        EXEC SQL
            SELECT fee_rate, fee_base, fee_min, fee_max
            INTO :iFeeRate, :dFeeBase, :dFeeMin, :dFeeMax
            FROM
                (SELECT fee_rate, fee_base, fee_min, fee_max
                FROM dept_fee_rate
                WHERE (trans_type = :iTransType OR trans_type = 0) AND fee_type = :iHostFeeType AND
                       card_type = :iCardType AND amount_begin < :dAmount AND
                       INSTR(:szDeptDetail, dept_detail) = 1
                ORDER BY LENGTH(dept_detail) DESC, trans_type DESC, amount_begin DESC) WHERE ROWNUM = 1;
        if(SQLCODE == SQL_NO_RECORD)
        {
            strcpy(ptApp->szRetCode, ERR_NO_FEE_RECORD);

            WriteLog(ERROR, "����[%s] �̻�[%s] ��������[%d] ��������[%d] ����[%d] ��������δ����!",
                     szDeptDetail, szShopNo, iTransType, iHostFeeType, iCardType);

            return FAIL;
        }
        else if(SQLCODE)
        {
            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

            WriteLog(ERROR, "��ѯ ����[%s] ��������[%d] ��������[%d] ����[%d] ��������ʧ��!SQLCODE=%d SQLERR=%s",
                     szDeptDetail, iTransType, iHostFeeType, iCardType, SQLCODE, SQLERR);

            return FAIL;
        }
    }
    else if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "��ѯ �̻�[%s] ��������[%d] ��������[%d] ����[%d] ��������ʧ��!SQLCODE=%d SQLERR=%s",
                 szShopNo, iTransType, iHostFeeType, iCardType, SQLCODE, SQLERR);

        return FAIL;
    }

    /* ���������� */
    gdFeeAmount = dFeeBase +  dAmount * iFeeRate / 10000;

    if((dFeeMin - gdFeeAmount) > 0.001)
    {
        gdFeeAmount = dFeeMin;
    }

    if(dFeeMax > 0.001 && (gdFeeAmount - dFeeMax) > 0.001)
    {
        gdFeeAmount = dFeeMax;
    }

    return SUCC;
}

/****************************************************************
** ��    �ܣ����������������
** ���������
**        ptApp                 app�ṹָ��
** ���������
**        gdFeeAmount           �����ѽ��
** �� �� ֵ��
**        SUCC                  ���������ѳɹ�
**        FAIL                  ����������ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/09
** ����˵����
**
** �޸���־��
****************************************************************/
static int _CalcByInterval(T_App *ptApp)
{
    int    iFlag;
    double dTmpAmount, dTmpFeeAmount;

    /* Ĭ��ȥ�̻������Ѷ��� */
    iFlag = SHOP_FEE_CONF;

    /* ���������Ѷ��� */
    /* ��ѯ�̻��������ʱ� */
    EXEC SQL
        SELECT trans_type INTO :iTransType
        FROM
            (SELECT trans_type
            FROM shop_fee_rate
            WHERE shop_no = :szShopNo AND (trans_type = :iTransType OR trans_type = 0) AND
                  fee_type = :iHostFeeType AND card_type = :iCardType AND
                  amount_begin < :dAmount
            ORDER BY trans_type DESC, amount_begin DESC) WHERE ROWNUM = 1;
    if(SQLCODE == SQL_NO_RECORD)
    {
        /* ��ѯ�����������ʱ� */
        EXEC SQL
            SELECT dept_no, trans_type
            INTO :szDeptNo, :iTransType
            FROM
                (SELECT dept_no, trans_type
                FROM dept_fee_rate
                WHERE (trans_type = :iTransType OR trans_type = 0) AND fee_type = :iHostFeeType AND
                      card_type = :iCardType AND amount_begin < :dAmount AND
                INSTR(:szDeptDetail, dept_detail) = 1
            ORDER BY LENGTH(dept_detail) DESC, trans_type DESC, amount_begin DESC) WHERE ROWNUM = 1;
        if(SQLCODE == SQL_NO_RECORD)
        {
            strcpy(ptApp->szRetCode, ERR_NO_FEE_RECORD);

            WriteLog(ERROR, "����[%s] �̻�[%s] ��������[%d] ��������[%d] ����[%d] ��������δ����!",
                     szDeptDetail, szShopNo, iTransType, iHostFeeType, iCardType);

            return FAIL;
        }
        else if(SQLCODE)
        {
            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

            WriteLog(ERROR, "��ѯ ����[%s] ��������[%d] ��������[%d] ����[%d] ��������ʧ��!SQLCODE=%d SQLERR=%s",
                     szDeptDetail, iTransType, iHostFeeType, iCardType, SQLCODE, SQLERR);

            return FAIL;
        }

        iFlag = DEPT_FEE_CONF;
    }
    else if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "��ѯ �̻�[%s] ��������[%d] ��������[%d] ����[%d] ��������ʧ��!SQLCODE=%d SQLERR=%s",
                 szShopNo, iTransType, iHostFeeType, iCardType, SQLCODE, SQLERR);

        return FAIL;
    }

    /* ���潻�׽����Ϊ��һ�����������Ѽ����� */
    dTmpAmount = dAmount;

    /* ͨ���α��ѯ���������� */
    if(iFlag == SHOP_FEE_CONF)
    {
        /* �����α� */
        EXEC SQL
            DECLARE cur_shop_fee_rate CURSOR FOR
            SELECT amount_begin, fee_rate, fee_base, fee_min, fee_max
            FROM shop_fee_rate
            WHERE shop_no = :szShopNo AND trans_type = :iTransType AND
                  fee_type = :iHostFeeType AND card_type = :iCardType AND
                  amount_begin < :dAmount
            ORDER BY amount_begin DESC;
        if(SQLCODE)
        {
            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

            WriteLog(ERROR, "�����α�cur_shop_fee_rateʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

            return FAIL;
        }

        /* ���α� */
        EXEC SQL OPEN cur_shop_fee_rate;
        if(SQLCODE)
        {
            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

            WriteLog(ERROR, "���α�cur_shop_fee_rateʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

            return FAIL;
        }

        /* ѭ����ȡ���ʣ����������� */
        while(1)
        {
            EXEC SQL
                FETCH cur_shop_fee_rate
                INTO :dAmountBegin, :iFeeRate, :dFeeBase, :dFeeMin, :dFeeMax;
            if(SQLCODE == SQL_NO_RECORD)
            {
                EXEC SQL CLOSE cur_shop_fee_rate;

                break;
            }
            else if(SQLCODE)
            {
                strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

                WriteLog(ERROR, "��ȡ�α�cur_shop_fee_rateʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

                EXEC SQL CLOSE cur_shop_fee_rate;

                return FAIL;
            }

            /* ��������������� */
            dTmpFeeAmount = dFeeBase + (dTmpAmount-dAmountBegin) * iFeeRate / 10000;

            if((dFeeMin - dTmpFeeAmount) > 0.001)
            {
                dTmpFeeAmount = dFeeMin;
            }

            if(dFeeMax > 0.001 && (dTmpFeeAmount - dFeeMax) > 0.001)
            {
                dTmpFeeAmount = dFeeMax;
            }

            /* �ۼ��������ѽ�� */
            gdFeeAmount += dTmpFeeAmount;

            /* ��һ���������Ѽ����� */
            dTmpAmount = dAmountBegin;
        }
    }
    else
    {
        /* �����α� */
        EXEC SQL
            DECLARE cur_dept_fee_rate CURSOR FOR
            SELECT amount_begin, fee_rate, fee_base, fee_min, fee_max
            FROM dept_fee_rate
            WHERE dept_no = :szDeptNo AND trans_type = :iTransType AND
                  fee_type = :iHostFeeType AND card_type = :iCardType AND
                  amount_begin < :dAmount
            ORDER BY amount_begin DESC;
        if(SQLCODE)
        {
            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

            WriteLog(ERROR, "�����α�cur_dept_fee_rateʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

            return FAIL;
        }

        /* ���α� */
        EXEC SQL OPEN cur_dept_fee_rate;
        if(SQLCODE)
        {
            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

            WriteLog(ERROR, "���α�cur_dept_fee_rateʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

            return FAIL;
        }

        /* ѭ����ȡ���ʣ����������� */
        while(1)
        {
            EXEC SQL
                FETCH cur_dept_fee_rate
                INTO :dAmountBegin, :iFeeRate, :dFeeBase, :dFeeMin, :dFeeMax;
            if(SQLCODE == SQL_NO_RECORD)
            {
                EXEC SQL CLOSE cur_dept_fee_rate;

                break;
            }
            else if(SQLCODE)
            {
                strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

                WriteLog(ERROR, "��ȡ�α�cur_dept_fee_rateʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

                EXEC SQL CLOSE cur_dept_fee_rate;

                return FAIL;
            }

            /* ��������������� */
            dTmpFeeAmount = dFeeBase + (dTmpAmount-dAmountBegin) * iFeeRate / 10000;

            if((dFeeMin - dTmpFeeAmount) > 0.001)
            {
                dTmpFeeAmount = dFeeMin;
            }

            if(dFeeMax > 0.001 && (dTmpFeeAmount - dFeeMax) > 0.001)
            {
                dTmpFeeAmount = dFeeMax;
            }

            /* �ۼ��������ѽ�� */
            gdFeeAmount += dTmpFeeAmount;

            /* ��һ���������Ѽ����� */
            dTmpAmount = dAmountBegin;
        }
    }

    return SUCC;
}
