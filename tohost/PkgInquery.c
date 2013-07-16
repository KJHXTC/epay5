/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨����POSͨѶģ�� ����ѯ������������
** �� �� �ˣ����
** �������ڣ�2013-06-08
**
** $Revision: 1.2 $
** $Log: PkgInquery.c,v $
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
** ��    �ܣ�����ѯ���
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
int InqueryPack(MsgRule *ptMsgRule, T_App *ptApp, ISO_data *ptData)
{
    char    szTmpBuf[512+1];
    int     iIndex;

	/* 0�� ��Ϣ���� */
    if(SetBit(ptMsgRule, "0200", MSG_ID, 4, ptData) != SUCC)
    {
        WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                 ptApp->iTransType, MSG_ID, "0200");

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
    }

	/* 2�� ���� */
	if(strlen(ptApp->szPan) > 0 &&
	   SetBit(ptMsgRule, ptApp->szPan, PAN, strlen(ptApp->szPan), ptData) != SUCC)
    {
        WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                 ptApp->iTransType, PAN, ptApp->szPan);

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
	}

	/* 3�� ���״����� */
    if(SetBit(ptMsgRule, "310000", PROC_CODE, 6, ptData) != SUCC)
    {
        WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                 ptApp->iTransType, PROC_CODE, "310000");

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

    /* 14�� ����Ч�� */
    if(strlen(ptApp->szExpireDate) == 4 &&
       SetBit(ptMsgRule, ptApp->szExpireDate, EXPIRY, strlen(ptApp->szExpireDate), ptData) != SUCC)
    {
        WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                 ptApp->iTransType, EXPIRY, ptApp->szExpireDate);

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
    }

	/* 25�� ����������� */
    if(SetBit(ptMsgRule, "00", SERVER_CODE, 2, ptData) != SUCC)
    {
        WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                 ptApp->iTransType, SERVER_CODE, "00");

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

	/* 35�� ���ŵ� */
	if(strlen(ptApp->szTrack2) > 0 &&
	   SetBit(ptMsgRule, ptApp->szTrack2, TRACK_2, strlen(ptApp->szTrack2), ptData) != SUCC)
	{
        WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                 ptApp->iTransType, TRACK_2, ptApp->szTrack2);

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
	}

    /* 36�� ���ŵ� */
	if(strlen(ptApp->szTrack3) > 0 &&
	   SetBit(ptMsgRule, ptApp->szTrack3, TRACK_3, strlen(ptApp->szTrack3), ptData) != SUCC)
	{
        WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                 ptApp->iTransType, TRACK_3, ptApp->szTrack3);

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
	}

	/* 49�� ����һ��Ҵ��� */
    if(SetBit(ptMsgRule, "156", FUND_TYPE, 3, ptData) != SUCC)
    {
        WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                 ptApp->iTransType, FUND_TYPE, "156");

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
    }

	/* �������� */
	if(memcmp(ptApp->szPasswd, "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF", 8) != 0 &&
       memcmp(ptApp->szPasswd, "\x00\x00\x00\x00\x00\x00\x00\x00", 8) != 0)
	{
		/* ����ת���� */
		if(ConvertPin(ptApp, YLPOSP) != SUCC)
		{
			return FAIL;
		}

		/* 22�� ��������뷽ʽ */
		if(strlen(ptApp->szTrack2))
		{
		    /* ��ˢ�� */		
            strcpy(ptApp->szEntryMode, "021");
		}
		else
		{
		    /* δˢ�� */
            strcpy(ptApp->szEntryMode, "011");
		}

        if(SetBit(ptMsgRule, ptApp->szEntryMode, MODE, strlen(ptApp->szEntryMode), ptData) != SUCC)
        {
            WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                     ptApp->iTransType, MODE, ptApp->szEntryMode);

            strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

            return FAIL;
        }

		/* 52���˱�ʶ������ ���� */
        if(SetBit(ptMsgRule, ptApp->szPasswd, PIN_DATA, 8, ptData) != SUCC)
        {
            WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                     ptApp->iTransType, PIN_DATA, "********");

            strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

            return FAIL;
        }

		/* 53�� ��ȫ������Ϣ 
		 PIN-FORMAT-USED: 
		 2 ANSI X9.8 Format�������˺���Ϣ��

		 ENCRYPTION-METHOD-USED �����㷨��־:
		 0����������Կ�㷨
		 6��˫������Կ�㷨
        */
        if(SetBit(ptMsgRule, "2600000000000000", SEC_CTRL_CODE, 16, ptData) != SUCC)
        {
            WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                     ptApp->iTransType, SEC_CTRL_CODE, "2600000000000000");

            strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

            return FAIL;
        }

		/* 26�� �����PIN��ȡ��(������豸����������ĸ����������ĵ���󳤶�) */
        if(SetBit(ptMsgRule, "06", PIN_MODE, 2, ptData) != SUCC)
        {
            WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                     ptApp->iTransType, PIN_MODE, "06");

            strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

            return FAIL;
        }
	}
	else
	{
        /* 22�� ��������뷽ʽ */
		if(strlen(ptApp->szTrack2))
		{
		    /* ��ˢ�� */		
            strcpy(ptApp->szEntryMode, "022");
		}
		else
		{
		    /* δˢ�� */
            strcpy(ptApp->szEntryMode, "012");
		}

        if(SetBit(ptMsgRule, ptApp->szEntryMode, MODE, strlen(ptApp->szEntryMode), ptData) != SUCC)
        {
            WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                     ptApp->iTransType, MODE, ptApp->szEntryMode);

            strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

            return FAIL;
        }
	}

    /* 60�� �Զ����� */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    iIndex = 0;

	/* 60.1���������� */
	sprintf(szTmpBuf, "01");
	iIndex += 2;

	/* 60.2 ���κ� */
	sprintf(szTmpBuf+iIndex, "%06ld", ptApp->lBatchNo);
	iIndex += 6;

	/*60.3 ���������3*/
    sprintf(szTmpBuf+iIndex, "000");
    iIndex += 3;

    if(SetBit(ptMsgRule, szTmpBuf, FIELD60, strlen(szTmpBuf), ptData) != SUCC)
    {
        WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                 ptApp->iTransType, FIELD60, szTmpBuf);

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
    }

	/* 64�� Ԥ��mac��Ϣ */
    if(SetBit(ptMsgRule, "        ", 64, strlen(szTmpBuf), ptData) != SUCC)
    {
        WriteLog(ERROR, "��������[%d]�����ĵ�[%d]���������[%s]����ʧ��!",
                 ptApp->iTransType, 64, "        ");

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
    }

	return SUCC;
}

/****************************************************************
** ��    �ܣ�����ѯ���
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
int InqueryUnpack(MsgRule *ptMsgRule, T_App *ptApp, ISO_data *ptData)
{
	char    szTmpBuf[512+1];
    char    szTmpBuf2[512+1];
	int     iRet;

	/* 2�� ���˺� */
	memset(szTmpBuf, 0, sizeof(szTmpBuf));
	iRet = GetBit(ptMsgRule, ptData, PAN, szTmpBuf);
	if(iRet < 0 || iRet > 19)
	{
        WriteLog(ERROR, "��������[%d]Ӧ�����ĵ�[%d]����ʧ��iRet:[%d]!",
                 ptApp->iTransType, PAN, iRet);

		strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

		return FAIL;
	}
	strcpy(ptApp->szPan, szTmpBuf);

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
	
	/* 14�� ��Ч�� */
	memset(szTmpBuf, 0, sizeof(szTmpBuf));
	iRet = GetBit(ptMsgRule, ptData, EXPIRY, szTmpBuf);
	if(iRet == 4)
	{
		strcpy(ptApp->szExpireDate, szTmpBuf);
	}

	/* 25�� ����������� */
	/* �ѽ��� */

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

	/* 54 �򸽽�� */
	if(strcmp(ptApp->szHostRetCode, TRANS_SUCC) == 0)
	{
		memset(szTmpBuf, 0, sizeof(szTmpBuf));
        iRet = GetBit(ptMsgRule, ptData, ADDI_AMOUNT, szTmpBuf);
    	if(iRet != 20 && iRet != 40)
    	{
            WriteLog(ERROR, "��������[%d]Ӧ�����ĵ�[%d]����ʧ��iRet:[%d]!",
                     ptApp->iTransType, ADDI_AMOUNT, iRet);

    		strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

    		return FAIL;
    	}
    	sprintf(ptApp->szAddiAmount, "%13.13s", szTmpBuf+7);
	}

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

	return SUCC;
}
