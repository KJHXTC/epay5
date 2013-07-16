/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨����POSͨѶģ�� ǩ��������������
** �� �� �ˣ����
** �������ڣ�2013-06-08
**
** $Revision: 1.2 $
** $Log: PkgLogin.c,v $
** Revision 1.2  2013/06/17 05:19:45  fengw
**
** 1���޸�Ӧ���ĵ�13�������ڴ�����롣
**
** Revision 1.1  2013/06/14 02:04:51  fengw
**
** 1������ǩ��������ѯ�����ѽ��ױ���������������
**
*******************************************************************/

#define _EXTERN_

#include "tohost.h"

/****************************************************************
** ��    �ܣ�ǩ��ѯ���
** ���������
**        ptMsgRule       ���Ĺ���
**        ptApp           app�ṹ
** ���������
**        ptData          ISO�ṹָ��
** �� �� ֵ��
**        SUCC            ����ɹ�
**        FAIL            ����ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2013/06/08
** ����˵����
**
** �޸���־��
****************************************************************/
int LoginPack(MsgRule *ptMsgRule, T_App *ptApp, ISO_data *ptData)
{
    char    szTmpBuf[512+1];
    int     iIndex;

	/* 0�� ��Ϣ���� */
    if(SetBit(ptMsgRule, "0800", MSG_ID, 4, ptData) != SUCC)
    {
        WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                 ptApp->iTransType, MSG_ID, "0800");

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
    }

	/* 11�� �ܿ���ϵͳ���ٺ� */
	memset(szTmpBuf, 0, sizeof(szTmpBuf));
	sprintf(szTmpBuf, "%06ld", ptApp->lSysTrace);
    if(SetBit(ptMsgRule, szTmpBuf, POS_TRACE, 6, ptData) != SUCC)
    {
        WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                 ptApp->iTransType, POS_TRACE, szTmpBuf);

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
    }

	/*41�� �ܿ����ն˱�ʶ��*/
    if(SetBit(ptMsgRule, ptApp->szPosNo, POS_ID, strlen(ptApp->szPosNo), ptData) != SUCC)
    {
        WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                 ptApp->iTransType, POS_ID, ptApp->szPosNo);

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
    }
    
	/* 42�� �ܿ�����ʶ�� */
    if(SetBit(ptMsgRule, ptApp->szShopNo, CUSTOM_ID, strlen(ptApp->szShopNo), ptData) != SUCC)
    {
        WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                 ptApp->iTransType, CUSTOM_ID, ptApp->szShopNo);

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
    }

    /* 60�� �Զ����� */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    iIndex = 0;

	/* 60.1���������� */
	sprintf(szTmpBuf, "00");
	iIndex += 2;

	/* 60.2 ���κ� */
	sprintf(szTmpBuf+iIndex, "%06ld", ptApp->lBatchNo);
	iIndex += 6;

	/*60.3 ���������3*/
    sprintf(szTmpBuf+iIndex, "003");
    iIndex += 3;

    if(SetBit(ptMsgRule, szTmpBuf, FIELD60, iIndex, ptData) != SUCC)
    {
        WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                 ptApp->iTransType, FIELD60, szTmpBuf);

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
    }

    /* 62�� �ն���Ϣ */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    strcpy(szTmpBuf, "Sequence No12311611111111");

    if(SetBit(ptMsgRule, szTmpBuf, FIELD62, strlen(szTmpBuf), ptData) != SUCC)
    {
        WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                 ptApp->iTransType, FIELD62, szTmpBuf);

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
    }

	/* 63�� ����Ա���� */
    if(SetBit(ptMsgRule, "000", FIELD63, 3, ptData) != SUCC)
    {
        WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                 ptApp->iTransType, FIELD63, "000");

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
    }

	return SUCC;
}

/****************************************************************
** ��    �ܣ�ǩ�����
** ���������
**        ptMsgRule       ���Ĺ���
**        ptData          ISO�ṹָ��
** ���������
**        ptApp           app�ṹ
** �� �� ֵ��
**        SUCC            ����ɹ�
**        FAIL            ����ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2013/06/08
** ����˵����
**
** �޸���־��
****************************************************************/
int LoginUnpack(MsgRule *ptMsgRule, T_App *ptApp, ISO_data *ptData)
{
	char    szTmpBuf[512+1];
    char    szTmpBuf2[512+1];
	int     iRet;
	T_WorkKey   tWorkKey;

	/* 11�� ��ˮ�� */
	memset(szTmpBuf, 0, sizeof(szTmpBuf));
	iRet = GetBit(ptMsgRule, ptData, POS_TRACE, szTmpBuf);
	if(iRet != 6)
	{
        WriteLog(ERROR, "��������[%d]Ӧ�����ĵ�[%d]����ʧ��iRet:[%d]!",
                 ptApp->iTransType, POS_TRACE, iRet);

		strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

		return FAIL;
	}
	ptApp->lSysTrace = atol(szTmpBuf);

	/* 12�� ����ʱ�� */
	memset(szTmpBuf, 0, sizeof(szTmpBuf));
	iRet = GetBit(ptMsgRule, ptData, LOCAL_TIME, szTmpBuf);
	if(iRet == 6)
	{
		strcpy(ptApp->szHostTime, szTmpBuf);
	}
	else
	{
       	GetSysTime(ptApp->szHostTime);
   	}

	/* 13�� �������� */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    GetSysDate(ptApp->szHostDate);
    iRet = GetBit(ptMsgRule, ptData, LOCAL_DATE, szTmpBuf);
    if(iRet == 4)
    {   
        strcpy(ptApp->szHostDate+4, szTmpBuf);
    }  
    strcpy(ptApp->szSettleDate, ptApp->szHostDate);

	/* 32�� ������ʶ�� */
	memset(szTmpBuf, 0, sizeof(szTmpBuf));
	iRet = GetBit(ptMsgRule, ptData, ACQUIRER_ID, szTmpBuf);
    if(iRet > 11 || iRet < 1)
	{
        WriteLog(ERROR, "��������[%d]Ӧ�����ĵ�[%d]����ʧ��iRet:[%d]!",
                 ptApp->iTransType, ACQUIRER_ID, iRet);

		strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

		return FAIL;
	}

	/* 37�� �����ο��� ����λ��ƾ֤�� */
	memset(szTmpBuf, 0, sizeof(szTmpBuf));
	iRet = GetBit(ptMsgRule, ptData, RETR_NUM, szTmpBuf);
	if(iRet != 12)
	{
        WriteLog(ERROR, "��������[%d]Ӧ�����ĵ�[%d]����ʧ��iRet:[%d]!",
                 ptApp->iTransType, RETR_NUM, iRet);

		strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

		return FAIL;
	}
    sprintf(ptApp->szRetriRefNum, "%12.12s", szTmpBuf);

    /* 39�� ��Ӧ�� */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    iRet = GetBit(ptMsgRule, ptData, RET_CODE, szTmpBuf);
	if(iRet != 2)
	{
        WriteLog(ERROR, "��������[%d]Ӧ�����ĵ�[%d]����ʧ��iRet:[%d]!",
                 ptApp->iTransType, RET_CODE, iRet);

		strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

		return FAIL;
	}
	strcpy(ptApp->szHostRetCode, szTmpBuf);

	/* 41�� �ն˺� */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
	iRet = GetBit(ptMsgRule, ptData, POS_ID, szTmpBuf);
	if(iRet != 8)
	{
        WriteLog(ERROR, "��������[%d]Ӧ�����ĵ�[%d]����ʧ��iRet:[%d]!",
                 ptApp->iTransType, POS_ID, iRet);

		strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

		return FAIL;
	}
    strcpy(ptApp->szPosNo, szTmpBuf);

	/* 42�� �̻��� */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
	iRet = GetBit(ptMsgRule, ptData, CUSTOM_ID, szTmpBuf);
	if(iRet != 15)
	{
        WriteLog(ERROR, "��������[%d]Ӧ�����ĵ�[%d]����ʧ��iRet:[%d]!",
                 ptApp->iTransType, CUSTOM_ID, iRet);

		strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

		return FAIL;
	}
    strcpy(ptApp->szShopNo, szTmpBuf);

	/* 60.2�� ���κ� */
	memset(szTmpBuf, 0, sizeof(szTmpBuf));
	iRet = GetBit(ptMsgRule, ptData, FIELD60, szTmpBuf);
    if(iRet < 1 || iRet > 11)
	{
        WriteLog(ERROR, "��������[%d]Ӧ�����ĵ�[%d]����ʧ��iRet:[%d]!",
                 ptApp->iTransType, FIELD60, iRet);

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
	}
	memset(szTmpBuf2, 0, sizeof(szTmpBuf2));
	memcpy(szTmpBuf2, szTmpBuf+2, 6);
	ptApp->lBatchNo = atol(szTmpBuf2);

	/* 62�� ������Կ */
	if(memcmp(ptApp->szHostRetCode, TRANS_SUCC, 2) == 0) 
	{
        memset(szTmpBuf, 0, sizeof(szTmpBuf));
	    iRet = GetBit(ptMsgRule, ptData, FIELD62, szTmpBuf);
	    if(iRet != 40)
    	{
            WriteLog(ERROR, "��������[%d]Ӧ�����ĵ�[%d]����ʧ��iRet:[%d]!",
                     ptApp->iTransType, FIELD62, iRet);

		    strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

	    	return FAIL;
	    }

        /* ���¹�����Կ */
        memset(&tWorkKey, 0, sizeof(tWorkKey));

        /* PinKey���� */
        BcdToAsc(szTmpBuf, 32, 0, tWorkKey.szPinKey);

        /* PinKeyУ��ֵ */
        BcdToAsc(szTmpBuf+16, 8, 0, tWorkKey.szPIKChkVal);

        /* MacKey���� */
        /* ���MacKey��8�ֽ�Ϊ0������ǰ8���ֽ� */
        if(memcmp(szTmpBuf+28, "\x00\x00\x00\x00\x00\x00\x00\x00", 8) == 0)
        {
            memcpy(szTmpBuf+28, szTmpBuf+20, 8);
        }
        BcdToAsc(szTmpBuf+20, 32, 0, tWorkKey.szMacKey);

        /* MacKeyУ��ֵ */
        BcdToAsc(szTmpBuf+36, 8, 0, tWorkKey.szMAKChkVal);

        if(ChangeWorkKey(ptApp, YLPOSP, &tWorkKey) != SUCC)
        {
            WriteLog(ERROR, "������Կת����ʧ��!");

            return FAIL;
        }
	}

	return SUCC;
}
