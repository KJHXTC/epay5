/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� ת��ת��ǰ��ѯ����
** �� �� �ˣ����
** �������ڣ�2012-11-14
**
** $Revision: 1.1 $
** $Log: TFOutQuery.ec,v $
** Revision 1.1  2013/02/21 06:34:21  fengw
**
** 1��ԭת��ת�˽��׸�����
**
** Revision 1.3  2013/01/14 09:17:45  fengw
**
** 1�����ӿ���ȥ�ո���
**
** Revision 1.2  2012/12/04 01:24:28  fengw
**
** 1���滻ErrorLogΪWriteLog��
**
** Revision 1.1  2012/11/23 09:09:16  fengw
**
** ���ڽ��״���ģ���ʼ�汾
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
    char    szShopNo[15+1];                 /* �̻��� */
    char    szPosNo[15+1];                  /* �ն˺� */
    char    szPan[19+1];                    /* ת������ */
    char    szAcctName[40+1];               /* �ֿ������� */
    char    szExpireDate[4+1];              /* ����Ч�� */
    char    szBankName[20+1];               /* �������� */
    int     iStatus;                        /* ״̬ */
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
int TranOutQueryPreTreat(T_App *ptApp)
{
    /* ��ȡ�󶨿���Ϣ */
    memset(szShopNo, 0, sizeof(szShopNo));
    memset(szPosNo, 0, sizeof(szPosNo));

    strcpy(szShopNo, ptApp->szShopNo);
    strcpy(szPosNo, ptApp->szPosNo);

    memset(szPan, 0, sizeof(szPan));
    memset(szAcctName, 0, sizeof(szAcctName));
    memset(szExpireDate, 0, sizeof(szExpireDate));
    memset(szBankName, 0, sizeof(szBankName));

	EXEC SQL
        SELECT pan, acct_name, expire_date, bank_name, status
        INTO :szPan, :szAcctName, :szExpireDate, :szBankName, :iStatus
        FROM register_card
        WHERE shop_no = :szShopNo AND pos_no = :szPosNo AND transtype = 0;
    if(SQLCODE == SQL_NO_RECORD)
	{
        strcpy(ptApp->szRetCode, ERR_OUT_CARD_NOT_REGISTER);

		WriteLog(ERROR, "�̻�[%s] �ն�[%s] ת���󶨿�δ�Ǽ�!", szShopNo, szPosNo);

		return FAIL;
	}
	else if(SQLCODE)
	{
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

		WriteLog(ERROR, "��ѯ�̻�[%s] �ն�[%s] ת���󶨿�ʧ��!SQLCODE=%d SQLERR=%s",
		         szShopNo, szPosNo, SQLCODE, SQLERR);

		return FAIL;
	}

    /* ����¼״̬ */
	if(iStatus != 1)
	{
		strcpy(ptApp->szRetCode, ERR_REG_CARD_NOT_APPROVE);

		WriteLog(ERROR, "�̻�[%s] �ն�[%s] ת���󶨿�δ����", szShopNo, szPosNo);

        return FAIL;
	}

    DelTailSpace(szPan);
    DelTailSpace(szExpireDate);
    DelTailSpace(szBankName);
    DelTailSpace(szAcctName);

    /* ���󶨿����ն�ˢ����Ϣ */
    if(strcmp(szPan, ptApp->szPan) != 0)
    {
        strcpy(ptApp->szRetCode, ERR_SELF_CARD);

		WriteLog(ERROR, "ת����[%s] �󶨿�[%s]��ƥ��", szPan, ptApp->szPan);

        return FAIL;
    }

    /* �����ֵ */
    /* ����Ч�� */
    memset(ptApp->szExpireDate, 0, sizeof(ptApp->szExpireDate));
    strcpy(ptApp->szExpireDate, szExpireDate);

    /* �������� */
    memset(ptApp->szOutBankName, 0, sizeof(ptApp->szOutBankName));
    strcpy(ptApp->szOutBankName, szBankName);

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
**        2012/11/14
** ����˵����
**
** �޸���־��
****************************************************************/
int TranOutQueryPostTreat(T_App *ptApp)
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
