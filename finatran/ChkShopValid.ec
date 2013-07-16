/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� �̻��Ϸ��Լ��
** �� �� �ˣ����
** �������ڣ�2012-11-12
**
** $Revision: 1.5 $
** $Log: ChkShopValid.ec,v $
** Revision 1.5  2013/02/25 01:13:15  fengw
**
** 1�������ַ���ĩβ�ո�ɾ�����롣
**
** Revision 1.4  2013/01/16 02:24:45  fengw
**
** 1�����ӻ����㼶��Ϣ��ȡ��
**
** Revision 1.3  2012/12/25 08:32:40  wukj
** �̻�����mcc_code����NVL
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
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ��̻��Ϸ��Լ��
** ���������
**        ptApp->szShopNo       �̻���
** ���������
**        ptApp->szShopType     �̻�����
**        ptApp->szShopName     �̻�����
**        ptApp->szAcqBankId    �յ����к�
** �� �� ֵ��
**        SUCC                  ���ɹ�
**        FAIL                  ���ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/12
** ����˵����
**
** �޸���־��
****************************************************************/
int ChkShopValid(T_App *ptApp)
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szShopNo[15+1];                 /* �̻��� */
        int     iMarketNo;                      /* �г���� */
        char    szShopName[40+1];               /* �̻����� */
        char    szAcqBankID[11+1];              /* �յ��� */
        char    szMCCCode[4+1];                 /* �̻����� */
        char    szIsBlack[1+1];                 /* ��������־ */
        char    szDeptDetail[70+1];             /* �����㼶��Ϣ */
        int     iSignFlag;                      /* ǩԼ��־ */
    EXEC SQL END DECLARE SECTION;

    /* ��ȡ�̻����� */
    memset(szShopNo, 0, sizeof(szShopNo));
    memset(szShopName, 0, sizeof(szShopName));
    memset(szAcqBankID, 0, sizeof(szAcqBankID));
    memset(szMCCCode, 0, sizeof(szMCCCode));
    memset(szIsBlack, 0, sizeof(szIsBlack));
    memset(szDeptDetail, 0, sizeof(szDeptDetail));

    strcpy(szShopNo, ptApp->szShopNo);

	EXEC SQL
        SELECT NVL(market_no, 0), shop_name, acq_bank, sign_flag, is_black, dept_detail, NVL(mcc_code,' ')
        INTO :iMarketNo, :szShopName, :szAcqBankID, :iSignFlag, :szIsBlack, :szDeptDetail, :szMCCCode
        FROM shop
        WHERE shop_no = :szShopNo;
	if(SQLCODE == SQL_NO_RECORD)
	{
        strcpy(ptApp->szRetCode, ERR_INVALID_MERCHANT);

		WriteLog(ERROR, "�̻�����δ�Ǽ�!�̻���:[%s]", szShopNo);

		return FAIL;
	}
	else if(SQLCODE)
	{
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

		WriteLog(ERROR, "��ѯ�̻����� �̻���:[%s] ʧ��!SQLCODE=%d SQLERR=%s", szShopNo, SQLCODE, SQLERR);

		return FAIL;
	}

    /* ����̻�״̬ */
	if(szIsBlack[0] == '1' || iSignFlag == 1)
	{
        strcpy(ptApp->szRetCode, ERR_SHOP_STATUS);

        WriteLog(ERROR, "�̻�������״̬!ǩԼ״̬[%d] ��������־[%c]", iSignFlag, szIsBlack[0]);

        return FAIL;
	}

    /* �����̻���Ϣ */
    DelTailSpace(szShopName);
    DelTailSpace(szDeptDetail);

	strcpy(ptApp->szShopType, szMCCCode);
	strcpy(ptApp->szShopName, szShopName);
	strcpy(ptApp->szAcqBankId, szAcqBankID);
    strcpy(ptApp->szDeptDetail, szDeptDetail);

    return SUCC;
}
