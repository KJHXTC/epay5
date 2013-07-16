/******************************************************************
** Copyright(C)2012 - 2015���������豸���޹�˾
** ��Ҫ���ݣ�epay���ļ�,���ܽӿ�
** �� �� �ˣ�wukj
** �������ڣ�2012/11/29
**
**
** $Revision: 1.3 $
** $Log: HsmClient.c,v $
** Revision 1.3  2013/06/14 02:24:33  fengw
**
** 1���޸�HsmChangePin��������˵����
**
** Revision 1.2  2013/01/05 06:38:17  fengw
**
** 1��ɾ��HsmDecryptTrack������iMagAlog������
**
** Revision 1.1  2012/12/10 06:49:05  wukj
** *** empty log message ***
**
** Revision 1.4  2012/12/03 05:56:34  wukj
** *** empty log message ***
**
** Revision 1.3  2012/12/03 05:55:52  wukj
** �޸�WriteETLogΪWriteLog
**
** Revision 1.2  2012/11/29 04:36:01  wukj
** ������д������ע��
**
**
*******************************************************************/
# include <stdio.h>
# include <string.h>
# include <stdlib.h>
#include <time.h>
#include <sys/timeb.h>

# include "app.h"
# include "errcode.h"
# include "transtype.h"
# include "user.h"

long GetCurMillTime()
{
    unsigned long   lTime;
	struct	timeb	tp;
	struct	tm	*tm;

    ftime ( &tp );
    tm = localtime (  & ( tp.time )  );
    lTime = (tm->tm_min)*60000+(tm->tm_sec)*1000+
                tp.millitm;
	lTime = lTime%10000;

	return (lTime);
}

/*****************************************************************
** ��    ��:ͨ����Ϣ���з��ʼ��ܷ���ģ�飬����MAC
** �������:
            ptApp	        -- �������ݽṹ
            nMacType        -- XOR_CALC_MAC           XOR�㷨
                X99_CALC_MAC    X99�㷨
                X919_CALC_MAC   X919�㷨
            szEnMacKey      -- MacKey����
            szMacData       -- ����mac�����ݴ�
            nLen	        -- ���ݴ�����
** �������:
            szMac	-- �����MACֵ
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121129�淶�������Ű��޶�
**
****************************************************************/
int HsmCalcMac( ptApp, nMacType, szEnMacKey, szMacData, nLen, szMac )
T_App *ptApp;
int nMacType;
char szEnMacKey[17];
char *szMacData;
int nLen;
char *szMac;
{
	int iRet, iTimeOut;
	long	lMsgType;
	T_Interface tFace;

	iTimeOut = 10;

	memset( (char *)&tFace, 0, sizeof(T_Interface) );
	tFace.iTransType = CALC_MAC;
	lMsgType = GetCurMillTime()+10000*tFace.iTransType;
	tFace.lSourceType = lMsgType;
	tFace.iAlog = nMacType;
	strcpy( tFace.szPsamNo, ptApp->szPsamNo);
	memcpy( tFace.szMacKey, szEnMacKey, 16 );
	tFace.iDataLen = nLen;
	memcpy( tFace.szData, szMacData, nLen );

	iRet = SendToHsmQue( lMsgType, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "calc mac send to hsm fail" );
		strcpy( ptApp->szRetCode, ERR_SYSTEM_ERROR );
		return FAIL;
	}

	iRet = RecvFromHsmQue( lMsgType, iTimeOut, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "calc mac read from hsm fail" );
		strcpy( ptApp->szRetCode, ERR_SYSTEM_ERROR );
		return FAIL;
	}

	if( memcmp( tFace.szReturnCode, TRANS_SUCC, 2 ) != 0 )
	{
		strcpy( ptApp->szRetCode, tFace.szReturnCode );
		return FAIL;
	}

	memcpy( szMac, tFace.szData, 8 );
	return SUCC;
}

/*****************************************************************
** ��    ��:ͨ����Ϣ���з��ʼ��ܷ���ģ�飬��������ת����
** �������:
            ptApp	    -- �������ݽṹ
            nPinType    -- 1-szPasswd   2-szNewPasswd
            iPinAlog    -- TRIPLE_DES SINGLE_DES ֻ�������ʱʹ�õ�
            szEnPinKey1 -- ԴPinKey����
            szEnPinKey2 -- Ŀ��PinKey����
            szPan1      -- Դ�ʺ�
            szPan2      -- Ŀ���ʺ�
** �������:
            szPin	    -- ת���ܺ������
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121129�淶�������Ű��޶�
**
****************************************************************/
int HsmChangePin( ptApp, nPinType,iPinAlog, szEnPinKey1, szEnPinKey2, szPan1, szPan2 )
T_App *ptApp;
int nPinType;
int iPinAlog;
char szEnPinKey1[17];
char szEnPinKey2[17];
char *szPan1;
char *szPan2;
{
	int iRet, iTimeOut;
	long	lMsgType;
	T_Interface tFace;

	iTimeOut = 10;

	memset( (char *)&tFace, 0, sizeof(T_Interface) );
	tFace.iTransType = CHANGE_PIN;
	lMsgType = GetCurMillTime()+10000*tFace.iTransType;
	tFace.lSourceType = lMsgType;
	tFace.iAlog = iPinAlog;
	strcpy( tFace.szPsamNo, ptApp->szPsamNo);
	memcpy( tFace.szPinKey, szEnPinKey1, 16 );
	memcpy( tFace.szMacKey, szEnPinKey2, 16 );
	
	memcpy( tFace.szData, szPan1, 16 );	
	if( nPinType == 1 )
	{
		memcpy( tFace.szData+16, ptApp->szPasswd, 8 );
	}
	else
	{
		memcpy( tFace.szData+16, ptApp->szNewPasswd, 8 );
	}

	memcpy( tFace.szData+24, szPan2, 16 );
	tFace.iDataLen = 40;

	iRet = SendToHsmQue( lMsgType, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "change pin send to hsm fail" );
		strcpy( ptApp->szRetCode, ERR_SYSTEM_ERROR );
		return FAIL;
	}

	iRet = RecvFromHsmQue( lMsgType, iTimeOut, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "change pin read from hsm fail" );
		strcpy( ptApp->szRetCode, ERR_SYSTEM_ERROR );
		return FAIL;
	}

	if( memcmp( tFace.szReturnCode, TRANS_SUCC, 2 ) != 0 )
	{
		WriteLog( ERROR, "change pin fail %s", tFace.szReturnCode );
		strcpy( ptApp->szRetCode, tFace.szReturnCode );
		return FAIL;
	}

	if( nPinType == 1 )
	{
		memcpy( ptApp->szPasswd, tFace.szData, 8 );
	}
	else
	{
		memcpy( ptApp->szNewPasswd, tFace.szData, 8 );
	}
		
	return SUCC;
}

/*****************************************************************
** ��    ��:ͨ����Ϣ���з��ʼ��ܷ���ģ�飬��������ת����(PIK2TMK)
** �������:
*      		ptApp	    -- �������ݽṹ
*	    	nPinType    -- 1-szPasswd   2-szNewPasswd
*	    	szEnPinKey1 -- ԴPinKey����
*		    szEnPinKey2 -- Ŀ��PinKey����
*		    szPan1      -- Դ�ʺ�
*		    szPan2      -- Ŀ���ʺ�
** �������:
*   		szPin	    -- ת���ܺ������
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121129�淶�������Ű��޶�
**
****************************************************************/
int HsmChangePin_PIK2TMK( ptApp, nPinType, szEnPinKey1, szPan1, szPan2 )
T_App *ptApp;
int nPinType;
char szEnPinKey1[17];
char *szPan1;
char *szPan2;
{
	int iRet, iTimeOut;
	long	lMsgType;
	T_Interface tFace;

	iTimeOut = 10;

	memset( (char *)&tFace, 0, sizeof(T_Interface) );
	tFace.iTransType = CHANGE_PIN_PIK2TMK;
	lMsgType = GetCurMillTime()+10000*tFace.iTransType;
	tFace.lSourceType = lMsgType;
	strcpy( tFace.szPsamNo, ptApp->szPsamNo);
	memcpy( tFace.szPinKey, szEnPinKey1, 16 );
	
	memcpy( tFace.szData, szPan1, 16 );	
	if( nPinType == 1 )
	{
		memcpy( tFace.szData+16, ptApp->szPasswd, 8 );
	}
	else
	{
		memcpy( tFace.szData+16, ptApp->szNewPasswd, 8 );
	}

	memcpy( tFace.szData+24, szPan2, 16 );
	tFace.iDataLen = 40;

	iRet = SendToHsmQue( lMsgType, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "change pin send to hsm fail" );
		strcpy( ptApp->szRetCode, ERR_SYSTEM_ERROR );
		return FAIL;
	}

	iRet = RecvFromHsmQue( lMsgType, iTimeOut, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "change pin read from hsm fail" );
		strcpy( ptApp->szRetCode, ERR_SYSTEM_ERROR );
		return FAIL;
	}

	if( memcmp( tFace.szReturnCode, TRANS_SUCC, 2 ) != 0 )
	{
		WriteLog( ERROR, "change pin fail %s", tFace.szReturnCode );
		strcpy( ptApp->szRetCode, tFace.szReturnCode );
		return FAIL;
	}

	if( nPinType == 1 )
	{
		memcpy( ptApp->szPasswd, tFace.szData, 8 );
	}
	else
	{
		memcpy( ptApp->szNewPasswd, tFace.szData, 8 );
	}
		
	return SUCC;
}

/*****************************************************************
** ��    ��:����
** �������:
            ptApp    
            nPinType    1--szPasswd 2--szNewPasswd
            szEnPinKey  ������Կ
            szPan       �˺�
** �������:
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121129�淶�������Ű��޶�
**
****************************************************************/
int HsmDecryptPin( ptApp, nPinType, szEnPinKey, szPan )
T_App *ptApp;
int nPinType;
char szEnPinKey[17];
char *szPan;
{
	int iRet, iTimeOut;
	long	lMsgType;
	T_Interface tFace;

	iTimeOut = 10;

	memset( (char *)&tFace, 0, sizeof(T_Interface) );
	tFace.iTransType = DECRYPT_PIN;
	lMsgType = GetCurMillTime()+10000*tFace.iTransType;
	tFace.lSourceType = lMsgType;
	strcpy( tFace.szPsamNo, ptApp->szPsamNo);
	memcpy( tFace.szPinKey, szEnPinKey, 16 );
	
	memcpy( tFace.szData, szPan, 16 );	
	if( nPinType == 1 )
	{
		memcpy( tFace.szData+16, ptApp->szPasswd, 8 );
	}
	else
	{
		memcpy( tFace.szData+16, ptApp->szNewPasswd, 8 );
	}

	tFace.iDataLen = 24;

	iRet = SendToHsmQue( lMsgType, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "change pin send to hsm fail" );
		strcpy( ptApp->szRetCode, ERR_SYSTEM_ERROR );
		return FAIL;
	}

	iRet = RecvFromHsmQue( lMsgType, iTimeOut, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "change pin read from hsm fail" );
		strcpy( ptApp->szRetCode, ERR_SYSTEM_ERROR );
		return FAIL;
	}

	if( memcmp( tFace.szReturnCode, TRANS_SUCC, 2 ) != 0 )
	{
		WriteLog( ERROR, "change pin fail %s", tFace.szReturnCode );
		strcpy( ptApp->szRetCode, tFace.szReturnCode );
		return FAIL;
	}

	if( nPinType == 1 )
	{
		strcpy( ptApp->szPasswd, tFace.szData );
	}
	else
	{
		strcpy( ptApp->szNewPasswd, tFace.szData );
	}
		
	return SUCC;
}

/*****************************************************************
** ��    ��:ͨ����Ϣ���з��ʼ��ܷ���ģ�飬��������У��
** �������:
*   		ptApp	-- �������ݽṹ
*   		szPin	-- ��������
*   		szEnPinKey -- PinKey����
** �������:
*   		szEnPin -- ��������
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121129�淶�������Ű��޶�
**
****************************************************************/
int HsmVerifyPin( ptApp, szPin, szEnPinKey, szHsmRet )
T_App *ptApp;
char *szPin;
char szEnPinKey[17];
char *szHsmRet;
{
	int iRet, iTimeOut;
	long	lMsgType;
	T_Interface tFace;

	iTimeOut = 10;

	memset( (char *)&tFace, 0, sizeof(T_Interface) );
	tFace.iTransType = VERIFY_PIN;
	time( &lMsgType );
	lMsgType = GetCurMillTime()+10000*tFace.iTransType;
	tFace.lSourceType = lMsgType;
	strcpy( tFace.szPsamNo, ptApp->szPsamNo );
	memcpy( tFace.szPinKey, szEnPinKey, 16 );
	
	memcpy( tFace.szData, szPin, 8 );	
	memcpy( tFace.szData+8, ptApp->szPasswd, 8 );
	tFace.iDataLen = 16;

	iRet = SendToHsmQue( lMsgType, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "change pin send to hsm fail" );
		strcpy( ptApp->szRetCode, ERR_SYSTEM_ERROR );
		return FAIL;
	}

	iRet = RecvFromHsmQue( lMsgType, iTimeOut, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "change pin read from hsm fail" );
		strcpy( ptApp->szRetCode, ERR_SYSTEM_ERROR );
		return FAIL;
	}

	if( memcmp( tFace.szReturnCode, TRANS_SUCC, 2 ) != 0 )
	{
		WriteLog( ERROR, "change pin fail %s", tFace.szReturnCode );
		strcpy( ptApp->szRetCode, tFace.szReturnCode );
		return FAIL;
	}

	strcpy( szHsmRet, tFace.szData );
		
	return SUCC;

}

/*****************************************************************
** ��    ��:���ܴŵ���Ϣ
** �������:
*	    	ptApp	-- �������ݽṹ
*   		iMagAlog --SINGLE_DES  TRIPLE_DES  ֻ�������ʱʹ�õ�
*   		szEnMagKey -- MagKey����
*   		szMagData -- �ŵ�����
*   		nLen	-- �ŵ����ĳ���
** �������:
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121129�淶�������Ű��޶�
**
 ****************************************************************/
int HsmDecryptTrack( ptApp, szEnMagKey, szMagData, nLen )
T_App *ptApp;
char szEnMagKey[17];
char *szMagData;
int nLen;
{
	int iRet, iTimeOut, nTrack2Len, nTrack3Len;
	long	lMsgType;
	T_Interface tFace;
	char szPan[20+1];
	iTimeOut = 10;

	memset( (char *)&tFace, 0, sizeof(T_Interface) );
	memset(szPan, 0, sizeof(szPan));
	tFace.iTransType = DECRYPT_TRACK;
	lMsgType = GetCurMillTime()+10000*tFace.iTransType;
	tFace.lSourceType = lMsgType;
	strcpy( tFace.szPsamNo, ptApp->szPsamNo );
	memcpy( tFace.szPinKey, szEnMagKey, 16 );
	tFace.iDataLen = nLen;
	memcpy( tFace.szData, szMagData, nLen );

	iRet = SendToHsmQue( lMsgType, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "decrypt track send to hsm fail" );
		strcpy( ptApp->szRetCode, ERR_SYSTEM_ERROR );
		return FAIL;
	}

	iRet = RecvFromHsmQue( lMsgType, iTimeOut, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "decrypt track read from hsm fail" );
		strcpy( ptApp->szRetCode, ERR_SYSTEM_ERROR );
		return FAIL;
	}

	if( memcmp( tFace.szReturnCode, TRANS_SUCC, 2 ) != 0 )
	{
		WriteLog( ERROR, "decrypt track fail %s", tFace.szReturnCode );
		strcpy( ptApp->szRetCode, tFace.szReturnCode );
		return FAIL;
	}

	nTrack2Len = (unsigned char)tFace.szData[0];
	memcpy( ptApp->szTrack2, tFace.szData+1, nTrack2Len );
	ptApp->szTrack2[nTrack2Len] = 0;

	nTrack3Len = (unsigned char)tFace.szData[1+nTrack2Len];
	memcpy( ptApp->szTrack3, tFace.szData+nTrack2Len+2, nTrack3Len );
	ptApp->szTrack3[nTrack3Len] = 0;
	return SUCC;
}

/*****************************************************************
** ��    ��:��ȡ������Կ����
** �������:
*	    	ptApp	-- �������ݽṹ
** �������:
    		szKeyData -- �´����ն˵���Կ��������		
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121129�淶�������Ű��޶�
**
 ****************************************************************/
int HsmGetWorkKey( ptApp, szKeyData )
T_App *ptApp;
char *szKeyData;
{
	int iRet, iTimeOut;
	long	lMsgType;
	T_Interface tFace;

	iTimeOut = 10;

	memset( (char *)&tFace, 0, sizeof(T_Interface) );
	tFace.iTransType = GET_WORK_KEY;
	lMsgType = GetCurMillTime()+10000*tFace.iTransType;
	tFace.lSourceType = lMsgType;
	memcpy( tFace.szPsamNo, ptApp->szPsamNo, 16 );
	memcpy( tFace.szData, szKeyData, 32 );

	iRet = SendToHsmQue( lMsgType, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "get work key send to hsm fail" );
		strcpy( ptApp->szRetCode, ERR_SYSTEM_ERROR );
		return FAIL;
	}

	iRet = RecvFromHsmQue( lMsgType, iTimeOut, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "get work key read from hsm fail" );
		strcpy( ptApp->szRetCode, ERR_SYSTEM_ERROR );
		return FAIL;
	}

	if( memcmp(tFace.szReturnCode, TRANS_SUCC, 2) != 0 )
	{
		WriteLog( ERROR, "get work key fail %s", tFace.szReturnCode );
		strcpy( ptApp->szRetCode, tFace.szReturnCode );
		return FAIL;
	}

	memcpy( szKeyData, tFace.szData, 240 );
		
	return SUCC;
}

/*****************************************************************
** ��    ��:ͨ����Ϣ���з��ʼ��ܷ���ģ�飬��ȡ�ն�����Կ
** �������:
** �������:
            szKeyData -- ����Կ��������+У��ֵ
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121129�淶�������Ű��޶�
**
 ****************************************************************/
int HsmGetMasterKey( szKeyData )
char *szKeyData;
{
	int iRet, iTimeOut;
	long	lMsgType;
	T_Interface tFace;

	iTimeOut = 10;

	memset( (char *)&tFace, 0, sizeof(T_Interface) );
	tFace.iTransType = GET_MASTER_KEY;
	lMsgType = GetCurMillTime()+10000*tFace.iTransType;
	tFace.lSourceType = lMsgType;

	iRet = SendToHsmQue( lMsgType, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "get master key send to hsm fail" );
		return FAIL;
	}

	iRet = RecvFromHsmQue( lMsgType, iTimeOut, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "get master key read from hsm fail" );
		return FAIL;
	}

	if( memcmp(tFace.szReturnCode, TRANS_SUCC, 2) != 0 )
	{
		WriteLog( ERROR, "get master key ret[%s]", tFace.szReturnCode );
		return FAIL;
	}

	memcpy( szKeyData, tFace.szData, 68 );
		
	return SUCC;
}

/*****************************************************************
** ��    ��:ͨ����Ϣ���з��ʼ��ܷ���ģ�飬������ԿУ��ֵ
** �������:
    		szKeyData -- ��Կ����
 			iFlag -- ��Կ����
** �������:
            szChkVal -- У��ֵ
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121129�淶�������Ű��޶�
**
 ****************************************************************/
int HsmCalcChkval( szKeyData, szChkVal ,iFlag)
char *szKeyData;
char *szChkVal;
int iFlag;   //��ֵΪLMK�Դ���,����ʾszKeyData�ڸ�LMK���¼���
{
	int iRet, iTimeOut;
	long	lMsgType;
	T_Interface tFace;

	iTimeOut = 10;

	memset( (char *)&tFace, 0, sizeof(T_Interface) );
	tFace.iTransType = CALC_CHKVAL;
	lMsgType = GetCurMillTime()+10000*tFace.iTransType;
	tFace.lSourceType = lMsgType;
	tFace.iAlog = iFlag;
	memcpy( tFace.szData, szKeyData, 32 );
	tFace.iDataLen = 32;

	iRet = SendToHsmQue( lMsgType, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "calc chkval send to hsm fail" );
		return FAIL;
	}

	iRet = RecvFromHsmQue( lMsgType, iTimeOut, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "calc chkval read from hsm fail" );
		return FAIL;
	}

	if( memcmp(tFace.szReturnCode, TRANS_SUCC, 2) != 0 )
	{
		WriteLog( ERROR, "calc chkval ret[%s]", tFace.szReturnCode );
		return FAIL;
	}

	memcpy( szChkVal, tFace.szData, 8 );
		
	return SUCC;
}


/*****************************************************************
 * �������ܣ�	* ���������
 * ���������
 * ��    �أ�
 *     		SUCC	-- �ɹ� 
 *     		FAIL	-- �ɹ� 
 ****************************************************************/
/*****************************************************************
** ��    ��:ͨ����Ϣ���з��ʼ��ܷ���ģ�飬��ȡ�����ն�����Կת����
** �������:
            szInKey -- TMK����(32Bytes)+PIK����(32Bytes)+MAC����(32Bytes)
** �������:
            szOutKey -- PIK����(32Bytes)+MAC����(32Bytes)+TMK����(32Bytes)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121129�淶�������Ű��޶�
**
 ****************************************************************/
int HsmChangeWorkKey( szInKey, szOutKey )
char *szInKey;
char *szOutKey;
{
	int iRet, iTimeOut;
	long	lMsgType;
	T_Interface tFace;

	iTimeOut = 10;

	memset( (char *)&tFace, 0, sizeof(T_Interface) );
	tFace.iTransType = CHANGE_KEY;
	memcpy( tFace.szData, szInKey, 96 );
	tFace.iDataLen = 96;

	lMsgType = GetCurMillTime()+10000*tFace.iTransType;
	tFace.lSourceType = lMsgType;

	iRet = SendToHsmQue( lMsgType, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "change work key send to hsm fail" );
		return FAIL;
	}

	iRet = RecvFromHsmQue( lMsgType, iTimeOut, &tFace );
	if( iRet != SUCC )
	{
		WriteLog( ERROR, "change work key read from hsm fail" );
		return FAIL;
	}

	if( memcmp(tFace.szReturnCode, TRANS_SUCC, 2) != 0 )
	{
		WriteLog( ERROR, "change work key ret[%s]", tFace.szReturnCode );
		return FAIL;
	}

	memcpy( szOutKey, tFace.szData, 96 );
	tFace.iDataLen = 96;
		
	return SUCC;
}
