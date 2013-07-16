/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:

** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.3 $
$Log: QueryTodayDetail.ec,v $
Revision 1.3  2013/01/24 07:41:31  wukj
QLCODE��ӡ��ʽ�޸�Ϊ%d

Revision 1.2  2013/01/24 07:30:30  wukj
*** empty log message ***

Revision 1.1  2013/01/21 05:53:31  wukj
������ϸ��ѯ����


*******************************************************************/
# include "manatran.h"

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
    EXEC SQL INCLUDE "../incl/DbStru.h";
EXEC SQL EnD DECLARE SECTION;
#endif

/*****************************************************************
** ��    ��:��ѯ���ն˵��ս�����ˮ 
** �������:
** �������:
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
int
QueryTodayDetail( ptAppStru, iQueVoid ) 
T_App	*ptAppStru;
int iQueVoid;
{
	EXEC SQL BEGIN DECLARE SECTION;
		char	szTermId[17], szMerchId[17], szTransName[21], szPsamNo[17];
		char	szBuf[2048];
		char	szToday[9], szCancel[5];
		int	iTotal, iTransType, lTrace;
		int	iTransType1, iTransType2, iTransType3, iTransType4;
		int	iTransType5;
                struct T_POSLS{
                        char    szHostDate[9];
                        char    szHostTime[7];
                        char    szPan[20];
                        double  dAmount;
                        char    szCardType[2];
                        int     iTransType;
                        int     szBusinessType;
                        char    szRetriRefNum[13];
                        char    szAuthCode[7];
                        char    szPosNo[16];
                        char    szShopNo[16];
                        char    szAccount2[19];
                        double  dAddiAmount;
                        int     iBatchNo;
                        char    szPsamNo[17];
                        int     iInvoice;
                        char    szRetCode[3];
                        char    szHostRetCode[7];
                        char    szCancelFlag[2];
                        char    szRecoverFlag[2];
                        char    szPosSettle[2];
                        char    szPosBatch[2];
                        char    szHostSettle[2];
                        int     iSysTrace;
                        char    szOldRetriRefNum[13];
                        char    szPosDate[9];
                        char    szPosTime[7];
                        char    szFinancialCode[41];
                        char    szBusinessCode[41];
                        char    szBankId[12];
                        char    szSettleDate[9];
                        char    szOperNo[5];
                        char    szMac[17];
                        int     iPosTrace;
                        char    szDeptDetail[71];
                } tPosLs;
                struct T_QUERY_CONDITION{
                        char    szPsamNo[17];
                        char    szPan[21];
                        char    szBeginDate[9];
                        char    szEndDate[9];
                        char    szShopNo[17];
                        char    szPosNo[17];
                        double  dAmount;
                }tQueryCon;
	EXEC SQL END DECLARE SECTION;

	char szTmpStr[100], szData[2048], szCmd[100];
	int  iCmdLen, iCurPos, iDataLen, iBegiiRecNo, iEndRecNo, iCurRecNum, iRecNo, iLine;
	int  iDateFlag;
	long	lAmt;

	strcpy( szPsamNo, ptAppStru->szPsamNo);
	lTrace = ptAppStru->lPosTrace;
	iTransType1 = TRAN_CANCEL;
	iTransType2 = TRAN_IN_CANCEL;
	iTransType3 = TRAN_OUT_CANCEL;
	iTransType4 = PUR_CANCEL;

	/* ��ѯ����֮������ѯ */
	if( memcmp( ptAppStru->szTransCode, "00", 2 ) != 0 )
	{
		AscToBcd( (uchar*)(ptAppStru->szTransCode), 2, 0 ,(uchar*)szBuf);
		szBuf[1] = 0;
		iBegiiRecNo = (uchar)szBuf[0];
	}
	else
	{
		iBegiiRecNo = 0;
	}
	strcpy( szMerchId, ptAppStru->szShopNo);
	strcpy( szTermId, ptAppStru->szPosNo);
	GetSysDate( szToday );

	WriteLog( TRACE, "begin[%ld] merch[%s] term[%s] today[%s]", iBegiiRecNo, szMerchId, szTermId, szToday);

	if( iQueVoid == YES )
	{
		strcpy( szCancel, "%" );
	}
	else
	{
		strcpy( szCancel, "N%" );
	}

	/*ȡ���ϲ�ѯ��������ˮ���� */
	EXEC SQL SELECT count(*) INTO :iTotal
	FROM posls
	WHERE SHOP_NO = :szMerchId AND POS_NO = :szTermId AND
              return_code = '00' AND recover_flag = 'N' AND cancel_flag like :szCancel AND
	      pos_date = :szToday AND
	      trans_type != :iTransType1 AND trans_type != :iTransType2 AND
	      trans_type != :iTransType3 AND trans_type != :iTransType4 ;
	if( SQLCODE )
	{
		strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
		WriteLog( ERROR, "count posls fail %d", SQLCODE );
		return FAIL;
	}
	if( iTotal == 0 )
	{
		strcpy( ptAppStru->szRetCode, ERR_NO_TRACE );
		return FAIL;
	}

	EXEC SQL DECLARE Today_cur cursor FOR
	SELECT 
                NVL(HOST_DATE,' '),
                NVL(HOST_TIME,' '),
                NVL(PAN,' '),
                NVL(AMOUNT,0.00),
                NVL(CARD_TYPE,'1'),
                NVL(TRANS_TYPE, 0),
                NVL(BUSINESS_TYPE, 0),
                NVL(RETRI_REF_NUM,' '),
                NVL(AUTH_CODE, ' '),
                NVL(POS_NO,' '),
                NVL(SHOP_NO, ' '),
                NVL(ACCOUNT2, ' '),
                NVL(ADDI_AMOUNT, 0.00),
                NVL(BATCH_NO, 1),
                NVL(PSAM_NO,' '),
                NVL(INVOICE, 1),
                NVL(RETURN_CODE, ' '),
                NVL(HOST_RET_CODE,' '),
                NVL(CANCEL_FLAG, 'N'),
                NVL(RECOVER_FLAG, 'N'),
                NVL(POS_SETTLE,'N'),
                NVL(POS_BATCH, 'N'),
                NVL(HOST_SETTLE,'N'),
                NVL(SYS_TRACE,1),
                NVL(OLD_RETRI_REF_NUM,' '),
                NVL(POS_DATE,' '),
                NVL(POS_TIME,' '),
                NVL(FINANCIAL_CODE,' '),
                NVL(BUSINESS_CODE, ' '),
                NVL(BANK_ID, ' '),
                NVL(SETTLE_DATE,' '),
                NVL(OPER_NO, '0001'),
                NVL(MAC,' '),
                NVL(POS_TRACE, 1)
	FROM posls
	WHERE SHOP_NO = :szMerchId AND POS_NO = :szTermId AND
              return_code = '00' AND recover_flag = 'N' AND cancel_flag like :szCancel AND
	      pos_date = :szToday AND
	      trans_type != :iTransType1 AND trans_type != :iTransType2 AND
	      trans_type != :iTransType3 AND trans_type != :iTransType4 
	ORDER BY sys_trace;

	if( SQLCODE )
	{
		strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
		WriteLog( ERROR, "delare Today_cur fail %d", SQLCODE );
		return FAIL;
	}


	EXEC SQL OPEN Today_cur;
	if( SQLCODE )
	{
		strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
		WriteLog( ERROR, "open Today_cur fail %d", SQLCODE );
		EXEC SQL CLOSE Today_cur;
		return FAIL;
	}

	iRecNo = 0;
	iCurRecNum = 0;
	iDataLen = 0;

	while(1)
	{
		EXEC SQL FETCH Today_cur 
		INTO 
                        :tPosLs.szHostDate,
                        :tPosLs.szHostTime,
                        :tPosLs.szPan,
                        :tPosLs.dAmount,
                        :tPosLs.szCardType,
                        :tPosLs.iTransType,
                        :tPosLs.szBusinessType,
                        :tPosLs.szRetriRefNum,
                        :tPosLs.szAuthCode,
                        :tPosLs.szPosNo,
                        :tPosLs.szShopNo,
                        :tPosLs.szAccount2,
                        :tPosLs.dAddiAmount,
                        :tPosLs.iBatchNo,
                        :tPosLs.szPsamNo,
                        :tPosLs.iInvoice,
                        :tPosLs.szRetCode,
                        :tPosLs.szHostRetCode,
                        :tPosLs.szCancelFlag,
                        :tPosLs.szRecoverFlag,
                        :tPosLs.szPosSettle,
                        :tPosLs.szPosBatch,
                        :tPosLs.szHostSettle,
                        :tPosLs.iSysTrace,
                        :tPosLs.szOldRetriRefNum,
                        :tPosLs.szPosDate,
                        :tPosLs.szPosTime,
                        :tPosLs.szFinancialCode,
                        :tPosLs.szBusinessCode,
                        :tPosLs.szBankId,
                        :tPosLs.szSettleDate,
                        :tPosLs.szOperNo,
                        :tPosLs.szMac,
                        :tPosLs.iPosTrace;

		if( SQLCODE == SQL_NO_RECORD )
		{
			EXEC SQL CLOSE Today_cur;
			break;
		}
		else if( SQLCODE )
		{
			strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
			WriteLog( ERROR, "fetch Today_cur fail %d", SQLCODE );
			EXEC SQL CLOSE Today_cur;
			return FAIL;
		}
		iRecNo ++;

		/* �����أ�ȡ��һ�� */
		if( iRecNo <= iBegiiRecNo )
		{
			continue;
		}

		DelTailSpace( tPosLs.szPan );
		DelTailSpace( tPosLs.szAccount2 );
		DelTailSpace( tPosLs.szBusinessCode);
		DelTailSpace( tPosLs.szFinancialCode);
		DelTailSpace( tPosLs.szShopNo);
		DelTailSpace( tPosLs.szPosNo);

		iTransType = tPosLs.iTransType;

		/* ȡ�������� */
		EXEC SQL SELECT trans_name INTO :szTransName
		FROM trans_def
		WHERE trans_type = :iTransType;
		if( SQLCODE )
		{
			WriteLog( ERROR, "get trans_name fail %d", SQLCODE );
			strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
			EXEC SQL CLOSE Today_cur;
			return FAIL;
		}
		DelTailSpace( szTransName );

		iCurPos = 0;
		iLine = 0;

		/* �������� */
		if( tPosLs.szCancelFlag[0] == 'Y' )
		{
			sprintf( szTmpStr, "%s �ѳ���|", szTransName );
		}
		else
		{
			sprintf( szTmpStr, "%s|", szTransName );
		}
		memcpy( szBuf+iCurPos, szTmpStr, strlen(szTmpStr) );
		iCurPos += strlen(szTmpStr);
		iLine ++;

		/* ��һ���� */
		if( iTransType == TRANS || iTransType == TRAN_IN || iTransType == TRAN_OUT ||
		    iTransType == PAY_CREDIT || iTransType == TRAN_OTHER )
		{
			sprintf( szTmpStr, "��%s|", tPosLs.szPan );
		}	
		else
		{
			sprintf( szTmpStr, "����%s|", tPosLs.szPan );
		}

		memcpy( szBuf+iCurPos, szTmpStr, strlen(szTmpStr) );
		iCurPos += strlen(szTmpStr);
		iLine ++;

		/* �ڶ����Ż��û��� */
		if( iTransType == TRANS || iTransType == TRAN_IN || iTransType == TRAN_OUT ||
		    iTransType == PAY_CREDIT || iTransType == TRAN_OTHER )
		{
			sprintf( szTmpStr, "��%s|", tPosLs.szAccount2 );
		}	
		else if( iTransType == PURCHASE )
		{
			sprintf( szTmpStr, "��Ȩ��:%s|", tPosLs.szAuthCode);
		}
		else if( iTransType == REFUND )
		{
			sprintf( szTmpStr, "ԭ�ο���:%s|", tPosLs.szFinancialCode);
		}
		else
		{
			sprintf( szTmpStr, "�û���:%s|", tPosLs.szFinancialCode);
		}
		memcpy( szBuf+iCurPos, szTmpStr, strlen(szTmpStr) );
		iCurPos += strlen(szTmpStr);;
		iLine ++;

		/* ���׽�� */
		/*add by gaomx 20100921 �����������*/
		sprintf( szTmpStr, "���:%.2fԪ|", tPosLs.dAmount);
		/*add end*/
		memcpy( szBuf+iCurPos, szTmpStr, strlen(szTmpStr) );
		iCurPos += strlen(szTmpStr);
		iLine ++;

		/* ����ʱ�� */
		sprintf( szTmpStr, "%4.4s-%2.2s-%2.2s %2.2s:%2.2s:%2.2s|", tPosLs.szPosDate, tPosLs.szPosDate+4, 
			tPosLs.szPosDate+6, tPosLs.szPosTime, tPosLs.szPosTime+2, tPosLs.szPosTime+4 );
		memcpy( szBuf+iCurPos, szTmpStr, strlen(szTmpStr) );
		iCurPos += strlen(szTmpStr);
		iLine ++;

		/* ������ˮ�� */
		sprintf( szTmpStr, "��ˮ��:%ld|", tPosLs.iPosTrace);
		memcpy( szBuf+iCurPos, szTmpStr, strlen(szTmpStr) );
		iCurPos += strlen(szTmpStr);
		iLine ++;

		/* ���У���ӡ������ˮʱÿ�ʽ���֮���һ�� */
		memcpy( szBuf+iCurPos, " |", 2 );
		iCurPos += 2;
		iLine ++;

		if( (iDataLen+iCurPos+4) <= MAX_QUERY_LEN )
		{
			memcpy( szData+iDataLen, szBuf, iCurPos );
			iDataLen += iCurPos;
			iCurRecNum ++;
		}
		else
		{
			EXEC SQL CLOSE Today_cur;
			break;
		}
	}
	iEndRecNo = iBegiiRecNo+iCurRecNum;

	sprintf( ptAppStru->szReserved, "%06ld%06ld%06ld%06ld%06ld", iDataLen+4, iTotal, iBegiiRecNo+1, iEndRecNo, iLine );
	ptAppStru->iReservedLen = 30;	
	szBuf[0] = iTotal;
	szBuf[1] = iBegiiRecNo+1;
	szBuf[2] = iEndRecNo;
	szBuf[3] = iLine;
	memcpy( szBuf+4, szData, iDataLen );
	szBuf[iDataLen+4] = 0;
	
	/* ɾ�����ն�������ѯ��� */
	EXEC SQL DELETE FROM query_result
	WHERE psam_no = :szPsamNo;
	if( SQLCODE != SQL_NO_RECORD && SQLCODE != 0 )
	{
		WriteLog( ERROR, "delete query_result fail %d", SQLCODE );
		strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
		RollbackTran();
		return FAIL;
	}
	CommitTran();

	/* ���뱾�β�ѯ������Ա�tcpcomposģ��ȡ���������ն� */
	EXEC sQL INSERT INTO query_result VALUES( :szPsamNo, :lTrace, :szBuf );
	if( SQLCODE )
	{
		WriteLog( ERROR, "insert query_result fail %d", SQLCODE );
		strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
		RollbackTran();
		return FAIL;
	}
	CommitTran();
	
	sprintf( ptAppStru->szPan, "����%03d-%03d / %03d", iBegiiRecNo+1, iEndRecNo, iTotal );

	/* ��Ҫ���к������� */
	if( iEndRecNo < iTotal )
	{
		//�������״���ǰ2λ��ʾ�����ؼ�¼����¼�ţ���6λΪ��ǰ����
		//�����6λ
		szBuf[0] = iEndRecNo;
		szBuf[1] = 0;
		BcdToAsc( (uchar*)szBuf, 2, 0 ,(uchar*)(ptAppStru->szNextTransCode));
		memcpy( ptAppStru->szNextTransCode+2, ptAppStru->szTransCode+2, 6 );
		ptAppStru->szNextTransCode[8] = 0;
		
		iCmdLen = ptAppStru->iCommandLen;
		memcpy( ptAppStru->szCommand+iCmdLen, "\x8D", 1 );	//����MAC
		iCmdLen += 1;
		ptAppStru->iCommandNum ++;
		memcpy( ptAppStru->szCommand+iCmdLen, "\x23\x02", 2 );//����ϵͳ
		iCmdLen += 2;
		ptAppStru->iCommandNum ++;
		memcpy( ptAppStru->szCommand+iCmdLen, "\x24\x03", 2 );//��������
		iCmdLen += 2;
		ptAppStru->iCommandNum ++;
		memcpy( ptAppStru->szCommand+iCmdLen, "\x25\x04", 2 );//��������
		iCmdLen += 2;
		ptAppStru->iCommandNum ++;

		ptAppStru->iCommandLen = iCmdLen;
	}
	else
	{
		memcpy( ptAppStru->szNextTransCode, "FF", 2 );
		memcpy( ptAppStru->szNextTransCode+2, ptAppStru->szTransCode+2, 6 );
		ptAppStru->szNextTransCode[8] = 0;
	}

	strcpy( ptAppStru->szRetCode, TRANS_SUCC );
	return ( SUCC );
}

