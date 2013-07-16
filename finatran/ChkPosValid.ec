/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� �ն˺Ϸ��Լ��
** �� �� �ˣ����
** �������ڣ�2012-11-12
**
** $Revision: 1.3 $
** $Log: ChkPosValid.ec,v $
** Revision 1.3  2013/06/14 02:32:57  fengw
**
** 1����ѯ�ն����κ�ʱ�����ӿ�ֵ�жϡ�
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
** ��    �ܣ��ն˺Ϸ��Լ��
** ���������
**        ptApp->szShopNo       �̻���
**        ptApp->szPosNo        �ն˺�
** ���������
**        ptApp->lBatchNo       �ն����κ�
**        gszTelephone          �󶨵绰����
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
int ChkPosValid(T_App *ptApp)
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szShopNo[15+1];                 /* �̻��� */
        char    szPosNo[15+1];                  /* �ն˺� */
        int     iStatus;                        /* �ն�״̬ */
        int     iBatchNo;                       /* �ն˵�ǰ���κ� */
        char    szTelephone[15+1];              /* �ն˰󶨵绰���� */
    EXEC SQL END DECLARE SECTION;

	/* ��ȡ�ն����� */
	memset(szShopNo, 0, sizeof(szShopNo));
	memset(szPosNo, 0, sizeof(szPosNo));
    memset(szTelephone, 0, sizeof(szTelephone));

    strcpy(szShopNo, ptApp->szShopNo);
    strcpy(szPosNo, ptApp->szPosNo);

	EXEC SQL
	    SELECT telephone, status, NVL(cur_batch, 0)
        INTO :szTelephone, :iStatus, :iBatchNo
	  	FROM terminal
	  	WHERE shop_no = :szShopNo AND pos_no = :szPosNo;
	if(SQLCODE == SQL_NO_RECORD)
	{
	    strcpy(ptApp->szRetCode, ERR_INVALID_TERM);

		WriteLog(ERROR, "�ն�����δ�Ǽ�!�̻���:[%s] �ն˺�:[%s]", szShopNo, szPosNo);

		return FAIL;
	}
	else if(SQLCODE == SQL_SELECT_MUCH)
	{
	    strcpy(ptApp->szRetCode, ERR_DUPLICATE_TERM);

        WriteLog(ERROR, "�ն������ظ��Ǽ�!�̻���:[%s] �ն˺�:[%s]", szShopNo, szPosNo);

		return FAIL;
	}
	else if(SQLCODE)
	{
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

		WriteLog(ERROR, "��ѯ�ն����� �̻���:[%s] �ն˺�:[%s] ʧ��!SQLCODE=%d SQLERR=%s",
		         szShopNo, szPosNo, SQLCODE, SQLERR);

		return FAIL;
	}
	
	/* ����ն�״̬ */
	if(iStatus != 1)
	{
	    strcpy(ptApp->szRetCode, ERR_TERM_STATUS);

	    WriteLog(ERROR, "�ն˷�����״̬!״̬[%d]", iStatus);

		return FAIL;
	}

    /* �����ն���Ϣ */
	ptApp->lBatchNo = iBatchNo;
	strcpy(gszTelephone, szTelephone);

    return SUCC;
}