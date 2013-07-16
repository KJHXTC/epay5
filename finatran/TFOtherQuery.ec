/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� ����ת��ǰ��ѯ����
** �� �� �ˣ����
** �������ڣ�2013-02-20
**
** $Revision: 1.1 $
** $Log: TFOtherQuery.ec,v $
** Revision 1.1  2013/02/21 06:33:45  fengw
**
** 1�����ӿ��л���ѯ�����л��ס�
**
*******************************************************************/

#define _EXTERN_

#include "finatran.h"

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
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ�����Ԥ����
** ���������
**        ptApp           app�ṹ
** ���������
**        ptApp           app�ṹ
** �� �� ֵ��
**        SUCC            ����ɹ�
**        FAIL            ����ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/14
** ����˵����
**
** �޸���־��
****************************************************************/
int TranOtherQueryPreTreat(T_App *ptApp)
{
    /* ��ȡ�տ����˻���Ϣ */
    memset(szShopNo, 0, sizeof(szShopNo));
    memset(szPosNo, 0, sizeof(szPosNo));
    memset(szPan, 0, sizeof(szPan));

    strcpy(szShopNo, ptApp->szShopNo);
    strcpy(szPosNo, ptApp->szPosNo);
    strcpy(szPan, ptApp->szStaticMenuOut);

    memset(szAcctName, 0, sizeof(szAcctName));
    memset(szExpireDate, 0, sizeof(szExpireDate));
    memset(szBankID, 0, sizeof(szBankID));
    memset(szBankName, 0, sizeof(szBankName));
    memset(szRegisterDate, 0, sizeof(szRegisterDate));

    EXEC SQL
        SELECT acct_name, expire_date, bank_id,
        bank_name, register_date, rec_no
        INTO :szAcctName, :szExpireDate, :szBankID,
        :szBankName, :szRegisterDate, :iRecNo
        FROM my_customer WHERE shop_no = :szShopNo AND
        pos_no = :szPosNo AND pan = :szPan;
    if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "��ѯ �̻���[%s] �ն˺�[%s] ����[%s] �տ�����Ϣʧ��!SQLCODE=%d SQLERR=%s",
                 szShopNo, szPosNo, szPan, SQLCODE, SQLERR);

        return FAIL;
	}

    DelTailSpace(szExpireDate);
    DelTailSpace(szAcctName);
    DelTailSpace(szBankID);
    DelTailSpace(szBankName);

    /* �����ֵ */
    /* �տ����˺� */
    memset(ptApp->szAccount2, 0, sizeof(ptApp->szAccount2));
    strcpy(ptApp->szAccount2, szPan);

    /* �������� */
    memset(ptApp->szInBankName, 0, sizeof(ptApp->szInBankName));
    strcpy(ptApp->szInBankName, szBankName);

    /* �ֿ������� */
    memset(ptApp->szHolderName, 0, sizeof(ptApp->szHolderName));
    strcpy(ptApp->szHolderName, szAcctName);

    return SUCC;
}

/****************************************************************
** ��    �ܣ����׺���
** ���������
**        ptApp           app�ṹ
** ���������
**        ptApp           app�ṹ
** �� �� ֵ��
**        SUCC            ����ɹ�
**        FAIL            ����ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2013/02/20
** ����˵����
**
** �޸���־��
****************************************************************/
int TranOtherQueryPostTreat(T_App *ptApp)
{
    int     iFeeType;           /* �������� */

    /* ���׳ɹ����������� */
    if(memcmp(ptApp->szRetCode, TRANS_SUCC, 2) == 0)
    {
        /* ����ת����������ת�뿨�����жϷ������� */
        /*
        �����
        */
        iFeeType = 0;

        if(CalcFee(ptApp, iFeeType) != SUCC)
        {
            WriteLog(ERROR, "����������ʧ��!");

            return FAIL;
        }

        /* ���������� */
        /*
        �����
        */
    }

    return SUCC;
}