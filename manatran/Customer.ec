/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨ �տ��˹���
** �� �� �ˣ����
** �������ڣ�2013-02-19
**
** $Revision: 1.1 $
** $Log: Customer.ec,v $
** Revision 1.1  2013/02/21 06:24:14  fengw
**
** 1�������տ��˹����ס�
**
*******************************************************************/
#include "manatran.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
    char    szShopNo[15+1];                 /* �̻��� */
    char    szPosNo[15+1];                  /* �ն˺� */
    char    szPan[19+1];                    /* ���� */
    char    szAcctName[40+1];               /* �ֿ������� */
    char    szExpireDate[4+1];              /* ��Ч�� */
    char    szBankID[12+1];                 /* ���������к� */
    char    szBankName[40+1];               /* �������� */
    char    szRegisterDate[8+1];            /* �Ǽ�ʱ�� */
    int     iRecNo;                         /* ��¼��� */
    int     iRecCount;                      /* ��¼���� */
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ������տ�����Ϣ
** ���������
**        ptApp            app�ṹָ��
** ���������
**        ��
** �� �� ֵ��
**        SUCC             �������ɹ�
**        FAIL             �������ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2013/02/19
** ����˵����
**
** �޸���־��
****************************************************************/
int AddCustomer(T_App *ptApp) 
{
    T_TLVStru   tTlv;               /* TLV���ݽṹ */
    char        szTmpBuf[128+1];    /* ��ʱ���� */

    memset(szShopNo, 0, sizeof(szShopNo));
    memset(szPosNo, 0, sizeof(szPosNo));

    strcpy(szShopNo, ptApp->szShopNo);
    strcpy(szPosNo, ptApp->szPosNo);

    /* ��ѯ�ҵ��տ�����Ϣ */
    EXEC SQL
        SELECT COUNT(*), NVL(MAX(rec_no), 0)+1 INTO :iRecCount, :iRecNo
        FROM my_customer
        WHERE shop_no = :szShopNo AND pos_no = :szPosNo;
    if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "��ѯ �̻���[%s] �ն˺�[%s] �տ�����Ϣʧ��!SQLCODE=%d SQLERR=%s",
                 szShopNo, szPosNo, SQLCODE, SQLERR);

        return FAIL;
    }

    /* ���֧��9���տ�����Ϣ */
    if(iRecCount >= MAX_STATIC_MENU_COUNT)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "�̻���[%s] �ն˺�[%s] �տ�����Ϣ����[%d]����!",
                 szShopNo, szPosNo, iRecCount);

        return FAIL;
    }

    /* TLV��ʼ�� */
    InitTLV(&tTlv, TAG_STANDARD, LEN_STANDARD, VALUE_NORMAL);

    if(UnpackTLV(&tTlv, ptApp->szReserved, ptApp->iReservedLen) != SUCC)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "�ַ���ת��ΪTLV���ݸ�ʽʧ��!");

        return FAIL;
    }

    memset(szPan, 0, sizeof(szPan));
    memset(szAcctName, 0, sizeof(szAcctName));
    memset(szExpireDate, 0, sizeof(szExpireDate));
    memset(szBankID, 0, sizeof(szBankID));
    memset(szBankName, 0, sizeof(szBankName));
    memset(szRegisterDate, 0, sizeof(szRegisterDate));

    strcpy(szPan, ptApp->szAccount2);
    strcpy(szAcctName, ptApp->szUserData);
    strcpy(szExpireDate, ptApp->szBusinessCode);

    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    if(GetValueByTag(&tTlv, "\xDF\x89\x02", szTmpBuf, sizeof(szTmpBuf)) != 13)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "��ȡ�����к�����ʧ��!");

        return FAIL;
    }
    memcpy(szBankID, szTmpBuf+1, 12);

    strcpy(szBankName, ptApp->szInBankName);
    GetSysDate(szRegisterDate);

    BeginTran();

    EXEC SQL
        INSERT INTO my_customer
        (shop_no, pos_no, pan, acct_name, expire_date,
        bank_id, bank_name, register_date, rec_no)
        VALUES
        (:szShopNo, :szPosNo, :szPan, :szAcctName,
        :szExpireDate, :szBankID, :szBankName, :szRegisterDate, :iRecNo);
    if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "���� �̻���[%s] �ն˺�[%s] �տ�����Ϣʧ��!SQLCODE=%d SQLERR=%s",
                 szShopNo, szPosNo, SQLCODE, SQLERR);

        return FAIL;
    }

    CommitTran();

    strcpy(ptApp->szRetCode, TRANS_SUCC);

    return SUCC;
}

/****************************************************************
** ��    �ܣ�ɾ���տ�����Ϣ
** ���������
**        ptApp            app�ṹָ��
** ���������
**        ��
** �� �� ֵ��
**        SUCC             �������ɹ�
**        FAIL             �������ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2013/02/19
** ����˵����
**
** �޸���־��
****************************************************************/
int DelCustomer(T_App *ptApp) 
{
    memset(szShopNo, 0, sizeof(szShopNo));
    memset(szPosNo, 0, sizeof(szPosNo));
    memset(szPan, 0, sizeof(szPan));

    strcpy(szShopNo, ptApp->szShopNo);
    strcpy(szPosNo, ptApp->szPosNo);
    strcpy(szPan, ptApp->szAccount2);

    /* ɾ���ҵ��տ�����Ϣ */

    BeginTran();

    EXEC SQL
        DELETE FROM my_customer
        WHERE shop_no = :szShopNo AND pos_no = :szPosNo AND pan = :szPan;
    if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "ɾ�� �̻���[%s] �ն˺�[%s] �տ��[%s] �տ�����Ϣʧ��!SQLCODE=%d SQLERR=%s",
                 szShopNo, szPosNo, szPan, SQLCODE, SQLERR);

        return FAIL;
    }

    CommitTran();

    strcpy(ptApp->szRetCode, TRANS_SUCC);

    return SUCC;
}