/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� ���ײ������
** �� �� �ˣ����
** �������ڣ�2012-11-08
**
** $Revision: 1.4 $
** $Log: ChkEpayConf.ec,v $
** Revision 1.4  2013/03/06 01:19:51  fengw
**
** 1��ͳ�Ƶ��ս����ۼƽ�����ʱ����pos_date������
**
** Revision 1.3  2013/02/21 06:36:11  fengw
**
** 1�����ӽṹ�崦����䡣
**
** Revision 1.2  2012/12/04 01:24:28  fengw
**
** 1���滻ErrorLogΪWriteLog��
**
** Revision 1.1  2012/11/23 09:09:16  fengw
**
** ���ڽ��״���ģ���ʼ�汾
**
** Revision 1.2  2012/11/22 08:59:27  fengw
**
** 1���޸Ľ����޶��鲿�ִ���
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
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ���ȡ�ն˲�������
** ���������
**        ptApp            app�ṹָ��
** ���������
**        giFeeCalcType    �����Ѽ��㷽ʽ
** �� �� ֵ��
**        SUCC             �������ɹ�
**        FAIL             �������ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/08
** ����˵����
**
** �޸���־��
****************************************************************/
int ChkEpayConf(T_App *ptApp)
{
    EXEC SQL BEGIN DECLARE SECTION;
        int     iBusinessType;                 /* ҵ������ */
        char    szPosDate[8+1];                /* �������� */
        double  dAmountTraceSum;               /* �����ۼƽ��׽�� */
        int     iTraceCount;                   /* �����ۼƽ��ױ��� */
    EXEC SQL END DECLARE SECTION;

    int        iRet;            /* ��������ֵ */
    double     dAmount;         /* ���׽�� */
    T_EpayConf tEpayConf;       /* ���ײ����ṹ�� */

    /* ҵ������ */
    iBusinessType = ptApp->iBusinessType;

    /* �������� */
    memset(szPosDate, 0, sizeof(szPosDate));
    strcpy(szPosDate, ptApp->szPosDate);

    /* ���׽�� */
    dAmount = atol(ptApp->szAmount)/100.0;

    memset(&tEpayConf, 0, sizeof(tEpayConf));

    iRet = GetEpayConf(ptApp, &tEpayConf);
    if(iRet == CONF_NOT_FOUND)
    {
        /* û�����ò��������ؼ��ɹ� */
        return SUCC;
    }
    else if(iRet == CONF_GET_FAIL)
    {
        /* ��ȡ����ʱʧ�ܣ����ؼ��ʧ�� */
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        return FAIL;
    }

    /* ������ */

    /* �����޶��� */
    if(tEpayConf.dAmountSingle > 0.001 && dAmount - tEpayConf.dAmountSingle > 0.001)
    {
        strcpy(ptApp->szRetCode, ERR_EXCEED_SINGLE);

        WriteLog(ERROR, "���ʽ����޶���ʧ��!���׽��:[%.2f] �����޶�:[%.2f]",
                 dAmount, tEpayConf.dAmountSingle);

        return FAIL;
    }

    /* �����ۼ��޶��飬���ս��ױ������ */
    if(tEpayConf.dAmountSum > 0.001 || tEpayConf.iMaxCount > 0)
    {
        EXEC SQL
            SELECT NVL(SUM(amount), 0), NVL(COUNT(amount), 0) INTO
                :dAmountTraceSum, :iTraceCount
            FROM posls
            WHERE business_type = :iBusinessType AND pos_date = :szPosDate AND return_code = '00'
                  AND cancel_flag = 'N' AND recover_flag = 'N';
        if(SQLCODE)
        {
            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

            WriteLog(ERROR, "ͳ�Ƶ��ս�������[%d]�ۼƽ��׽��ʧ��!SQLCODE=%d SQLERR=%s",
                     iBusinessType, SQLCODE, SQLERR);

            return FAIL;
        }

        if(tEpayConf.dAmountSum > 0.001 && (dAmountTraceSum + dAmount - tEpayConf.dAmountSum) > 0.001)
        {
            strcpy(ptApp->szRetCode, ERR_EXCEED_TOTAL);

            WriteLog(ERROR, "�ۼƽ����޶���ʧ��!���׽��:[%.2f] �ۼ��޶�:[%.2f] �����ۼƽ��׶�:[%.2f]",
                     dAmount, tEpayConf.dAmountSum, dAmountTraceSum);

            return FAIL;
        }

        if(tEpayConf.iMaxCount > 0 && (iTraceCount + 1) > tEpayConf.iMaxCount)
        {
            strcpy(ptApp->szRetCode, ERR_EXCEED_TIMES);

            WriteLog(ERROR, "���ս��ױ������Ƽ��ʧ��!�����ۼƽ��ױ���:[%d] ���ձ�������:[%d]",
                     iTraceCount, tEpayConf.iMaxCount);

            return FAIL;
        }
    }

    /* ���ÿ����� */
    if(ptApp->cOutCardType == CREDIT_CARD)
    {
        strcpy(ptApp->szRetCode, ERR_EXCEED_SINGLE);

        /* �����޶��� */
        if(tEpayConf.dCreditAmountSingle > 0.001 && dAmount - tEpayConf.dCreditAmountSingle > 0.001)
        {
            strcpy(ptApp->szRetCode, ERR_EXCEED_SINGLE);

            WriteLog(ERROR, "���ÿ����ʽ����޶���ʧ��!���׽��:[%.2f] �����޶�:[%.2f]",
                     dAmount, tEpayConf.dCreditAmountSingle);

            return FAIL;
        }

        /* �����ۼ��޶��飬���ս��ױ������ */
        if(tEpayConf.dCreditAmountSum > 0.001 || tEpayConf.iCreditMaxCount > 0)
        {
            EXEC SQL
                SELECT NVL(SUM(amount), 0), NVL(COUNT(amount), 0) INTO
                    :dAmountTraceSum, :iTraceCount
                FROM posls
                WHERE business_type = :iBusinessType AND pos_date = :szPosDate AND
                      card_type = '1' AND return_code = '00' AND cancel_flag = 'N'AND recover_flag = 'N';
            if(SQLCODE)
            {
                strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

                WriteLog(ERROR, "ͳ�Ƶ��ս�������[%d]�ۼ����ÿ����׽��ʧ��!SQLCODE=%d SQLERR=%s",
                         iBusinessType, SQLCODE, SQLERR);

                return FAIL;
            }

            if(tEpayConf.dCreditAmountSum > 0.001 &&
               (dAmountTraceSum + dAmount - tEpayConf.dCreditAmountSum) > 0.001)
            {
                strcpy(ptApp->szRetCode, ERR_EXCEED_TOTAL);

                WriteLog(ERROR, "�ۼ����ÿ������޶���ʧ��!���׽��:[%.2f] �ۼ��޶�:[%.2f] �����ۼƽ��׶�:[%.2f]",
                         dAmount, tEpayConf.dCreditAmountSum, dAmountTraceSum);

                return FAIL;
            }

            if(tEpayConf.iCreditMaxCount > 0 && (iTraceCount + 1) > tEpayConf.iCreditMaxCount)
            {
                strcpy(ptApp->szRetCode, ERR_EXCEED_TIMES);

                WriteLog(ERROR, "�������ÿ����ױ������Ƽ��ʧ��!�����ۼƽ��ױ���:[%d] ���ձ�������:[%d]",
                         iTraceCount, tEpayConf.iCreditMaxCount);

                return FAIL;
            }
        }
    }

    /* ת������� */
    if(strlen(ptApp->szPan) > 0 &&
       ChkCardType(ptApp->cOutCardType, ptApp->iOutCardBelong, tEpayConf.szCardTypeOut) != SUCC)
    {
        strcpy(ptApp->szRetCode, ERR_INVALID_CARD);

        WriteLog(ERROR, "ת������ɿ��ּ��ʧ��!����:[%c] ������:[%d] ��ɿ�������:[%s]",
                 ptApp->cOutCardType, ptApp->iOutCardBelong, tEpayConf.szCardTypeOut);

        return FAIL;
    }

    /* ת�뿨��� */
    if(strlen(ptApp->szAccount2) > 0 &&
       ChkCardType(ptApp->cInCardType, ptApp->iInCardBelong, tEpayConf.szCardTypeIn) != SUCC)
    {
        strcpy(ptApp->szRetCode, ERR_INVALID_CARD);

        WriteLog(ERROR, "ת�뿨��ɿ��ּ��ʧ��!����:[%c] ������:[%d] ��ɿ�������:[%s]",
                 ptApp->cInCardType, ptApp->iInCardBelong, tEpayConf.szCardTypeIn);

        return FAIL;
    }

    /* �����Ѽ��㷽ʽ������ȫ�ֱ�����������������ʱʹ�� */
    giFeeCalcType = tEpayConf.iFeeCalcType;

    return SUCC;
}
