/******************************************************************
** Copyright(C)2012 - 2015���������豸���޹�˾
** ��Ҫ���ݣ�epay���ļ�,��Ҫ�������ͼ����Ϣ��WEB��UPD�����˿�
** �� �� �ˣ�������
** �������ڣ�2012/11/8
** $Revision: 1.7 $
** $Log: MoniOpt.ec,v $
** Revision 1.7  2013/06/17 09:07:09  fengw
**
** 1���޸�WebDispMoni������web���������ݸ�ʽ��
**
** Revision 1.6  2012/12/25 07:02:57  fengw
**
** 1���޸Ķ˿ںŲ�������Ϊ�ַ�����
**
** Revision 1.5  2012/12/19 07:40:54  fengw
**
** 1���޸�GetResult�������ò�����
**
** Revision 1.4  2012/12/19 07:14:49  fengw
**
** 1����GetResult�������ļ��з���ɶ��������ļ���
**
** Revision 1.3  2012/12/07 01:51:56  fengw
**
** 1���滻sgetdateΪGetSysDate��sgettimeΪGetSysTime��
**
** Revision 1.2  2012/12/03 08:23:50  gaomx
** *** empty log message ***
**
** Revision 1.1  2012/12/03 07:44:03  gaomx
** *** empty log message ***
**
*******************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include "../../incl/user.h"
#include "../../incl/app.h"
#include "../../incl/dbtool.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL END DECLARE SECTION;

/*************************************************************
*  ��    ��: 	
*		���ͼ����Ϣ��WEB��UDP�����˿ڡ�
*  �������: 
*		ptApp		    APP�������ݽṹ
        pszTransName    ��������
        pszIp           WEBϵͳ��IP��ַ
        iPort           WEBϵͳ��UPD��ض˿�
*  �������: 	
*       ��
*  ��    �أ�	
        ��
*************************************************************/
void WebDispMoni( ptApp, pszTransName, pszIp, szPort ) 
T_App  *ptApp;
char   *pszTransName;
char   *pszIp;
char   *szPort;
{
	char	szTimeBuf[20], szDateBuf[10];
	char	szCardNo[20], szTransName[9], szResult[23]; 
	unsigned long	lMoney;
	int	iLen;
	char	szAmtBuf[20], szBuf[512];

	strcpy( szTimeBuf, ptApp->szHostTime );
	strcpy( szDateBuf, ptApp->szHostDate );

	if( strlen(szTimeBuf) == 0 )
	{
		GetSysTime(szTimeBuf);
	}
	if( strlen(szDateBuf) == 0 )
	{
		GetSysDate(szDateBuf);
	}

	memset( szCardNo, '\0', 20 );
	memset( szBuf, 0, sizeof(szBuf) );

	memset( szResult, 0, sizeof( szResult ) );
	
    memcpy(szResult, ptApp->szRetCode, 2);
    GetResult(ptApp->szRetCode, szResult+2);

	//���µ�ȡ���ź����滻get_cardno( szCardNo, ptApp );

	DelTailSpace( szResult );
	strcat( szResult, ptApp->szHostRetCode );

    /* ��Э������20���ֽ�����ʶ�������� */
	if( pszTransName == NULL ) 
	{
		sprintf( szTransName, "%-20.20s", ptApp->szTransName );
	}
	else
	{
		sprintf( szTransName, "%-20.20s", pszTransName );
	}

	lMoney = atol( ptApp->szAmount );
	if( lMoney != 0 )
	{
		ChgAmtZeroToDot( ptApp->szAmount, 12, szAmtBuf);
		sprintf( szBuf, "%-15.15s%15.15s%-19.19s%-20.20s%12.12s%-16.16s%8.8s%6.6s%8.8s%8.8s%-20.20s", \
                 ptApp->szShopNo, ptApp->szPosNo, szCardNo, szTransName, szAmtBuf, szResult, szDateBuf, \
                 szTimeBuf, ptApp->szOutBankId, ptApp->szAcqBankId, ptApp->szShopName );
	}
	else if( strlen(ptApp->szAddiAmount) > 0 )
	{
		ChgAmtZeroToDot( ptApp->szAddiAmount, 12, szAmtBuf);
		sprintf( szBuf, "%-15.15s%15.15s%-19.19s%-20.20s%12.12s%-16.16s%8.8s%6.6s%8.8s%8.8s%-20.20s", \
                 ptApp->szShopNo, ptApp->szPosNo, szCardNo, szTransName, szAmtBuf, szResult, szDateBuf, 
                 szTimeBuf, ptApp->szOutBankId, ptApp->szAcqBankId, ptApp->szShopName );
	}
	else
	{
		sprintf( szBuf, "%-15.15s%15.15s%-19.19s%-20.20s%12s%-16.16s%8.8s%6.6s%8.8s%8.8s%-20.20s", \
                 ptApp->szShopNo, ptApp->szPosNo, szCardNo, szTransName, "", szResult, szDateBuf, 
                 szTimeBuf, ptApp->szOutBankId, ptApp->szAcqBankId, ptApp->szShopName );
	}

	iLen = strlen(szBuf);

	SendToUdpSrv( pszIp, szPort, szBuf, iLen );
}
