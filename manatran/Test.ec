/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:����ʹ��

** �����б�:
** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.3 $
$Log: Test.ec,v $
Revision 1.3  2013/03/11 07:05:21  fengw

1���������ڶ�дָ����Խ��ס�

Revision 1.2  2013/01/24 07:41:31  wukj
QLCODE��ӡ��ʽ�޸�Ϊ%d

Revision 1.1  2012/12/18 10:25:53  wukj
*** empty log message ***

Revision 1.9  2012/12/10 05:32:12  wukj
*** empty log message ***

Revision 1.8  2012/12/05 06:32:01  wukj
*** empty log message ***

Revision 1.7  2012/12/03 03:25:09  wukj
int����ǰ׺�޸�Ϊi

Revision 1.6  2012/11/29 10:09:04  wukj
��־,bcdascת�����޸�

Revision 1.5  2012/11/20 07:45:39  wukj
�滻\tΪ�ո����

Revision 1.4  2012/11/19 01:58:29  wukj
�޸�app�ṹ����,����ͨ��

Revision 1.3  2012/11/16 08:38:12  wukj
�޸�app�ṹ��������

Revision 1.2  2012/11/16 03:25:05  wukj
����CVS REVSION LOGע��

*******************************************************************/

# include "manatran.h"

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL EnD DECLARE SECTION;
#endif

/*****************************************************************
** ��    ��:��¼�ն���������
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
WriteTermData( ptAppStru )
T_App    *ptAppStru;
{
    FILE    *pFd;
    char    szFileName[80], szTmpBuf[1024], szDate[20];

    sprintf(szFileName ,"%s/log/Test", getenv("WORKDIR") );
    GetSysDate( szDate );
    strcat( szFileName, szDate );
    if( (pFd = fopen( szFileName, "a+") ) == NULL )
    {
        WriteLog( ERROR, "fopen [%s] err", szFileName );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return( FAIL );
    }
    fprintf( pFd, "%d %s==================\n", ptAppStru->iTransType, 
        ptAppStru->szTransName );

    fprintf( pFd, "��ȫģ���[%s]\n", ptAppStru->szPsamNo );
    fprintf( pFd, "���ŵ�[%s]\n", ptAppStru->szTrack2 );
    fprintf( pFd, "���ŵ�[%s]\n", ptAppStru->szTrack3 );
    fprintf( pFd, "��������[%d]\n", ptAppStru->iTransNum );
    fprintf( pFd, "���[%s]\n", ptAppStru->szAmount );
    fprintf( pFd, "����Ӧ�ú�[%s]\n", ptAppStru->szFinancialCode );
    fprintf( pFd, "����Ӧ�ú�[%s]\n", ptAppStru->szBusinessCode );
    fprintf( pFd, "����YYYYMMDD[%s]\n", ptAppStru->szSettleDate );
    fprintf( pFd, "����YYYYMM  [%s]\n", ptAppStru->szPosDate );
    fprintf( pFd, "�Զ�����Ϣ[%ld][%s]\n", ptAppStru->iReservedLen, ptAppStru->szReserved );
    BcdToAsc( (unsigned char*)(ptAppStru->szPosCodeVer), 4, 0 ,(unsigned char*)szTmpBuf);
    szTmpBuf[4] = 0;
    fprintf( pFd, "�ն˳���汾[%s]\n", szTmpBuf );
    BcdToAsc( (unsigned char*)(ptAppStru->szAppVer), 8, 0 ,(unsigned char*)szTmpBuf);
    szTmpBuf[8] = 0;
    fprintf( pFd, "Ӧ�ù��ܰ汾[%s]\n", szTmpBuf );
    BcdToAsc( (unsigned char*)(ptAppStru->szRetDesc), 20, 0 ,(unsigned char*)szTmpBuf);
    szTmpBuf[20] = 0;
    fprintf( pFd, "�ն����к�[%s]\n", szTmpBuf );
    fprintf( pFd, "����[%s]\n", ptAppStru->szPan );
    fprintf( pFd, "����[%ld]\n", ptAppStru->lRate );

    fprintf( pFd, "END ==================\n\n");
    fclose( pFd );

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );

    return(SUCC);
}

/*****************************************************************
** ��    ��:��¼�ն���������
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
WriteHandInputData( ptAppStru )
T_App    *ptAppStru;
{
    FILE    *pFd;
    char    szFileName[80], szTmpBuf[1024], szDate[20];

    sprintf(szFileName ,"%s/log/Test", getenv("WORKDIR") );
    GetSysDate( szDate );
    strcat( szFileName, szDate );
    if( (pFd = fopen( szFileName, "a+") ) == NULL )
    {
        WriteLog( ERROR, "fopen [%s] err", szFileName );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return( FAIL );
    }
    fprintf( pFd, "%d %s==================\n", ptAppStru->iTransType, 
        ptAppStru->szTransName );

    fprintf( pFd, "��������[%d]\n", ptAppStru->iTransNum );
    fprintf( pFd, "���[%s]\n", ptAppStru->szAmount );
    fprintf( pFd, "����Ӧ�ú�[%s]\n", ptAppStru->szFinancialCode );
    fprintf( pFd, "����Ӧ�ú�[%s]\n", ptAppStru->szBusinessCode );
    fprintf( pFd, "����YYYYMMDD[%s]\n", ptAppStru->szSettleDate );
    fprintf( pFd, "����YYYYMM  [%s]\n", ptAppStru->szPosDate );
    fprintf( pFd, "�Զ�����Ϣ[%ld][%s]\n", ptAppStru->iReservedLen, ptAppStru->szReserved );
    fprintf( pFd, "����[%ld]\n", ptAppStru->lRate );

    fprintf( pFd, "END ==================\n\n");
    fclose( pFd );

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );

    return(SUCC);
}

/*****************************************************************
** ��    ��:��¼�ն���������-��Ҫ����У��/�ȶ�
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
WriteDigCheckData( ptAppStru )
T_App    *ptAppStru;
{
    FILE    *pFd;
    char    szFileName[80], szTmpBuf[1024], szDate[20];

    sprintf(szFileName,"%s/log/Test",getenv("WORKDIR"));
    GetSysDate( szDate );
    strcat( szFileName, szDate );
    if( (pFd = fopen( szFileName, "a+") ) == NULL )
    {
        WriteLog( ERROR, "fopen [%s] err", szFileName );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return( FAIL );
    }
    fprintf( pFd, "%d %s==================\n", ptAppStru->iTransType, 
        ptAppStru->szTransName );

    fprintf( pFd, "����Ӧ�ú�[%s]\n", ptAppStru->szFinancialCode );
    fprintf( pFd, "����Ӧ�ú�[%s]\n", ptAppStru->szBusinessCode );

    fprintf( pFd, "END ==================\n\n");
    fclose( pFd );

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );

    return(SUCC);
}

/*****************************************************************
** ��    ��:��ӡ����
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
TestPrint( ptAppStru )
T_App    *ptAppStru;
{
    
    GetSysDate( ptAppStru->szHostDate );
    GetSysTime( ptAppStru->szHostTime );
    strcpy( ptAppStru->szPan, "1234567890123456789" );
    strcpy( ptAppStru->szAmount, "000088888888" );
    strcpy( ptAppStru->szAuthCode, "666666" );
    strcpy( ptAppStru->szRetriRefNum, "123456789012" );
    strcpy( ptAppStru->szAccount2, "9876543210987654321" );
    strcpy( ptAppStru->szAddiAmount, "C000055555555" );
    strcpy( ptAppStru->szFinancialCode, "88077150" );
    strcpy( ptAppStru->szBusinessCode, "13305919562" );
    strcpy( ptAppStru->szReserved, "���Ƚ����µ�95566��ѯ" );
    strcpy( ptAppStru->szHolderName, "����" );
    strcpy( ptAppStru->szInBankId, "01020000" );
    strcpy( ptAppStru->szOutBankId, "03080000" );

    return(SUCC);
}


/*****************************************************************
** ��    ��:�ն˷��Ϳ���
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
TestSendCardno( ptAppStru ) 
T_App    *ptAppStru;
{
    int    iRecNum, i, iCurPos;
    FILE    *pFd;
    char    szFileName[80], szCardNo[21], szDate[20], szTime[7];

    sprintf(szFileName,"%s/log/Test",getenv("WORKDIR") );
    GetSysDate( szDate );
    strcat( szFileName, szDate );
    if( (pFd = fopen( szFileName, "a+") ) == NULL )
    {
        WriteLog( ERROR, "fopen [%s] err", szFileName );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return( FAIL );
    }
    fprintf( pFd, "%d %s==================\n", ptAppStru->iTransType, 
        ptAppStru->szTransName );

    iRecNum = (unsigned char)(ptAppStru->szReserved[0]);

    fprintf( pFd, "�ն�[%s]��%d������\n", ptAppStru->szPsamNo, iRecNum );
    fprintf( pFd, "  ����   ʱ��          ����\n" );
    iCurPos = 1;
    for( i=0; i<iRecNum; i++ )
    {
        memset( szDate, 0, 9 );
        memset( szTime, 0, 7 );
        memset( szCardNo, 0, 20 );

        BcdToAsc( (unsigned char*)(ptAppStru->szReserved+iCurPos), 8, 0 ,(unsigned char*)szDate);
        iCurPos += 4;
        BcdToAsc( (unsigned char*)(ptAppStru->szReserved+iCurPos), 6, 0 ,(unsigned char*)szTime);
        iCurPos += 3;

        BcdToAsc( (unsigned char*)(ptAppStru->szReserved+iCurPos), 20, 0,(unsigned char*)szCardNo);
        iCurPos += 10;

        fprintf( pFd, "%8.8s %6.6s %20.20s\n", szDate, szTime, szCardNo );
    }    
    fprintf( pFd, "END ==================\n\n");
    fclose( pFd );

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}

/*****************************************************************
** ��    ��:�ն˷��Ͷ���
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
TermSendInfo( ptAppStru ) 
T_App    *ptAppStru;
{
    FILE    *pFd;
    char    szFileName[80], szDate[20];

    sprintf(szFileName,"%s/log/Test",getenv("WORKDIR") );
    GetSysDate( szDate );
    strcat( szFileName, szDate );
    if( (pFd = fopen( szFileName, "a+") ) == NULL )
    {
        WriteLog( ERROR, "fopen [%s] err", szFileName );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return( FAIL );
    }
    fprintf( pFd, "%d %s==================\n", ptAppStru->iTransType, 
        ptAppStru->szTransName );

    fprintf( pFd, "�յ��ն�[%s]����[%s]�Ķ���[%s]\n", ptAppStru->szPsamNo, 
        ptAppStru->szFinancialCode, ptAppStru->szReserved );
    fprintf( pFd, "END ==================\n\n");
    fclose( pFd );

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}

/*****************************************************************
** ��    ��:�ն˷��ͽ�����־
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
SendTrace( ptAppStru ) 
T_App    *ptAppStru;
{
    int    iRecNum, i, iCurPos;
    char    szBuf[512], szDate[9], szTime[7], szTransCode[9], szMac[17];
    char    szRetCode[3];
    FILE    *pFd;
    char    szFileName[80];

    sprintf(szFileName,"%s/log/Test",getenv("WORKDIR") );
    GetSysDate( szDate );
    strcat( szFileName, szDate );
    if( (pFd = fopen( szFileName, "a+") ) == NULL )
    {
        WriteLog( ERROR, "fopen [%s] err", szFileName );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return( FAIL );
    }
    fprintf( pFd, "%d %s==================\n", ptAppStru->iTransType, 
        ptAppStru->szTransName );

    iRecNum = (unsigned char)(ptAppStru->szReserved[0]);

    fprintf( pFd, "�ն�[%s]��%d��������־\n", ptAppStru->szPsamNo, iRecNum );
    fprintf( pFd, "  ����   ʱ��  ���״���  Ӧ����   MAC\n" );
    iCurPos = 1;
    for( i=0; i<iRecNum; i++ )
    {
        memset( szDate, 0, 9 );
        memset( szTime, 0, 7 );
        memset( szTransCode, 0, 9 );
        memset( szRetCode, 0, 3 );
        memset( szMac, 0, 17 );

        BcdToAsc( (unsigned char*)(ptAppStru->szReserved+iCurPos), 8, 0 ,(unsigned char*)szDate);
        iCurPos += 4;
        BcdToAsc( (unsigned char*)(ptAppStru->szReserved+iCurPos), 6, 0 ,(unsigned char*)szTime);
        iCurPos += 3;
        BcdToAsc( (unsigned char*)(ptAppStru->szReserved+iCurPos), 8, 0,(unsigned char*)szTransCode);
        iCurPos += 4;
        memcpy( szRetCode, ptAppStru->szReserved+iCurPos, 2 );
        iCurPos += 2;
        BcdToAsc( (unsigned char*)(ptAppStru->szReserved+iCurPos), 16, 0,(unsigned char*)szMac);
        iCurPos += 8;

        fprintf( pFd, "%8.8s %6.6s %8.8s %2.2s %16.16s\n", szDate, 
            szTime, szTransCode, szRetCode, szMac );
    }    
    fprintf( pFd, "END ==================\n\n");
    fclose( pFd );

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}

/*****************************************************************
** ��    ��:�ն˷��ʹ�����־
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
SendErrLog( ptAppStru ) 
T_App    *ptAppStru;
{
    int    iRecNum, i, iCurPos, iLen;
    char    szBuf[512], szDate[9], szTime[7], szTransCode[9], szErr[100];
    FILE    *pFd;
    char    szFileName[80];

    sprintf(szFileName,"%s/log/Test",getenv("WORKDIR") );
    GetSysDate( szDate );
    strcat( szFileName, szDate );
    if( (pFd = fopen( szFileName, "a+") ) == NULL )
    {
        WriteLog( ERROR, "fopen [%s] err", szFileName );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return( FAIL );
    }
    fprintf( pFd, "%d %s==================\n", ptAppStru->iTransType, 
        ptAppStru->szTransName );

    iRecNum = (unsigned char)(ptAppStru->szReserved[0]);

    fprintf( pFd, "�ն�[%s]��%d��������־\n", ptAppStru->szPsamNo, iRecNum );
    fprintf( pFd, "  ����   ʱ��  ���״���    ��������\n" );
    iCurPos = 1;
    for( i=0; i<iRecNum; i++ )
    {
        memset( szDate, 0, 9 );
        memset( szTime, 0, 7 );
        memset( szTransCode, 0, 9 );
        memset( szErr, 0, 100 );

        BcdToAsc( (unsigned char*)(ptAppStru->szReserved+iCurPos), 8, 0 ,(unsigned char*)szDate);
        iCurPos += 4;
        BcdToAsc( (unsigned char*)(ptAppStru->szReserved+iCurPos), 6, 0,(unsigned char*)szTime );
        iCurPos += 3;
        BcdToAsc( (unsigned char*)(ptAppStru->szReserved+iCurPos), 8, 0 , (unsigned char*)szTransCode);
        iCurPos += 4;
        iLen = ptAppStru->szReserved[iCurPos];
        iCurPos ++;
        memcpy( szErr, ptAppStru->szReserved+iCurPos, iLen );
        iCurPos += iLen;

        fprintf( pFd, "%8.8s %6.6s %8.8s %s\n", szDate, szTime, 
            szTransCode, szErr );
    }    

    fprintf( pFd, "END ==================\n\n");
    fclose( pFd );

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}

/*****************************************************************
** ��    ��:�ɷѲ�ѯ����
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
TestInq( ptAppStru )
T_App *ptAppStru;
{
    FILE    *pFd;
    char    szFileName[80], szDate[20];

    sprintf(szFileName,"%s/log/Test",getenv("WORKDIR") );
    GetSysDate( szDate );
    strcat( szFileName, szDate );
    if( (pFd = fopen( szFileName, "a+") ) == NULL )
    {
        WriteLog( ERROR, "fopen [%s] err", szFileName );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return( FAIL );
    }
    fprintf( pFd, "%d %s==================\n", ptAppStru->iTransType, 
        ptAppStru->szTransName );

    sprintf( ptAppStru->szRetriRefNum, "%6.6s%06ld", ptAppStru->szPosDate+2, ptAppStru->lPosTrace );
    sprintf( ptAppStru->szAuthCode, "%06ld", ptAppStru->szPosDate+2, ptAppStru->lSysTrace );

    if( memcmp( ptAppStru->szBusinessCode, "88077150", 8 ) == 0 )
    {
        sprintf( ptAppStru->szAmount, "%012ld", 88888 );
    }
    else if( memcmp( ptAppStru->szBusinessCode, "88077151", 8 ) == 0 )
    {
        sprintf( ptAppStru->szAmount, "%012ld", 0 );
    }
    else
    {
        sprintf( ptAppStru->szAmount, "%012ld", 66666 );
    }

    GetSysDate( ptAppStru->szHostDate );
    GetSysTime( ptAppStru->szHostTime );

    if( memcmp( ptAppStru->szAmount, "000000000000", 12 ) == 0 )
    {
        strcpy( ptAppStru->szRetCode, ERR_NOT_PAY );
    }
    else
    {
        strcpy( ptAppStru->szRetCode, TRANS_SUCC  );
    }

    fprintf( pFd, "�ɷѺ���:%s\n", ptAppStru->szBusinessCode );
    fprintf( pFd, "Ӧ�ɽ��:%ld.%02ld\n", atol(ptAppStru->szAmount)/100,
        atol(ptAppStru->szAmount)%100 );
    fprintf( pFd, "END ==================\n\n");
    fclose( pFd );

    strcpy( ptAppStru->szHostRetCode, TRANS_SUCC );

    return SUCC;
}

/*****************************************************************
** ��    ��:�ɷѲ���
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
TestPay( ptAppStru )
T_App *ptAppStru;
{
    FILE    *pFd;
    char    szFileName[80], szDate[20];

    sprintf(szFileName,"%s/log/Test",getenv("WORKDIR") );
    GetSysDate( szDate );
    strcat( szFileName, szDate );
    if( (pFd = fopen( szFileName, "a+") ) == NULL )
    {
        WriteLog( ERROR, "fopen [%s] err", szFileName );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return( FAIL );
    }
    fprintf( pFd, "%d %s==================\n", ptAppStru->iTransType, 
        ptAppStru->szTransName );

    fprintf( pFd, "��    ��:%s\n", ptAppStru->szPan );
    fprintf( pFd, "�ɷѽ��:%ld.%02ld\n", atol(ptAppStru->szAmount)/100,
        atol(ptAppStru->szAmount)%100 );

    if( ptAppStru->szControlCode[0] == '1' )
    {
        fprintf( pFd, "����֪ͨ�ֻ�[%s]\n", ptAppStru->szFinancialCode );
    }
    else
    {
        fprintf( pFd, "����Ҫ����֪ͨ\n" );
    }

    sprintf( ptAppStru->szRetriRefNum, "%6.6s%06ld", ptAppStru->szPosDate+2, ptAppStru->lPosTrace );
    sprintf( ptAppStru->szAuthCode, "%06ld", ptAppStru->szPosDate+2, ptAppStru->lSysTrace );

    GetSysDate( ptAppStru->szHostDate );
    GetSysTime( ptAppStru->szHostTime );

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );

    fprintf( pFd, "END ==================\n\n");
    fclose( pFd );

    return SUCC;
}

/*****************************************************************
** ��    ��:�ʵ�֧������
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
TestPayList( ptAppStru )
T_App *ptAppStru;
{
    FILE    *pFd;
    char    szFileName[80], szDate[20], szTmpStr[50];

    EXEC SQL BEGIN DECLARE SECTION;
        char    szClassName[50], szTypeName[50], szGenDate[9], szNote[250];
        char    szPayDate[9];
        int    iListClass, iListType, iListNo;
    EXEC SQL END DECLARE SECTION;

    GetSysDate( szPayDate );
    memcpy( szTmpStr, ptAppStru->szBusinessCode, 3 );
     szTmpStr[3] = 0;
     iListClass = atol(szTmpStr);

     memcpy( szTmpStr, ptAppStru->szBusinessCode+3, 3 );
        szTmpStr[3] = 0;
        iListType = atol(szTmpStr);

        memcpy( szGenDate, ptAppStru->szBusinessCode+6, 8 );
        szGenDate[8] = 0;

        memcpy( szTmpStr, ptAppStru->szBusinessCode+14, 6 );
        szTmpStr[6] = 0;
        iListNo = atol(szTmpStr);

    EXEC SQL SELECT class_name into :szClassName 
    FROM pay_class
    WHERE list_class = :iListClass;
    if( SQLCODE == SQL_NO_RECORD )
    {
        WriteLog( ERROR, "pay_class %ld not exist", iListClass );
        strcpy( ptAppStru->szRetCode, ERR_INVALID_PAYLIST );
        return FAIL;
    }
    else if( SQLCODE )
    {
        WriteLog( ERROR, "select pay_class fail %ld", SQLCODE );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    EXEC SQL SELECT type_name into :szTypeName 
    FROM pay_type
    WHERE list_class = :iListClass and list_type = :iListType;
    if( SQLCODE == SQL_NO_RECORD )
    {
        WriteLog( ERROR, "pay_type[%ld, %ld] not exist", iListClass, iListType );
        strcpy( ptAppStru->szRetCode, ERR_INVALID_PAYLIST );
        return FAIL;
    }
    else if( SQLCODE )
    {
        WriteLog( ERROR, "select pay_class fail %ld", SQLCODE );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    EXEC SQL SELECT data into :szNote
    FROM pay_list
    WHERE list_class = :iListClass and list_type = :iListType and
              gen_date = :szGenDate and list_no = :iListNo;
    if( SQLCODE == SQL_NO_RECORD )
    {
        WriteLog( ERROR, "class[%ld] type[%ld] gen_date[%s] list_no[%ld] not exist", iListClass, iListType, szGenDate, iListNo );
        strcpy( ptAppStru->szRetCode, ERR_INVALID_PAYLIST );
        return FAIL;
    }
    else if( SQLCODE )
    {
        WriteLog( ERROR, "select pay_class fail %d", SQLCODE );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    DelTailSpace( szNote );

    EXEC SQL UPDATE pay_list set status = 'Y', pay_date = :szPayDate
        where list_class = :iListClass and list_type = :iListType and
              gen_date = :szGenDate and list_no = :iListNo;
    if( SQLCODE )
    {
        WriteLog( ERROR, "update pay_class fail %d", SQLCODE );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        RollbackTran();
        return FAIL;
    }
    CommitTran();

    sprintf(szFileName,"%s/log/Test",getenv("WORKDIR") );
    GetSysDate( szDate );
    strcat( szFileName, szDate );
    if( (pFd = fopen( szFileName, "a+") ) == NULL )
    {
        WriteLog( ERROR, "fopen [%s] err", szFileName );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return( FAIL );
    }
    fprintf( pFd, "%d %s==================\n", ptAppStru->iTransType, 
        ptAppStru->szTransName );

    fprintf( pFd, "�ʵ�����:%s\n", szClassName );
    fprintf( pFd, "�ʵ�С��:%s\n", szTypeName );
    fprintf( pFd, "�ʵ�����:%s\n", szGenDate );
    fprintf( pFd, "�ʵ����:%d\n", iListNo );
    fprintf( pFd, "�ʵ�����:%s\n", szNote );
    fprintf( pFd, "֧������:%s\n", ptAppStru->szPan );
    fprintf( pFd, "�ʵ����:%ld.%02ld\n", atol(ptAppStru->szAmount)/100,
        atol(ptAppStru->szAmount)%100 );

    sprintf( ptAppStru->szRetriRefNum, "%6.6s%06ld", ptAppStru->szPosDate+2, ptAppStru->lPosTrace );
    sprintf( ptAppStru->szAuthCode, "%06ld", ptAppStru->szPosDate+2, ptAppStru->lSysTrace );

    GetSysDate( ptAppStru->szHostDate );
    GetSysTime( ptAppStru->szHostTime );

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );

    fprintf( pFd, "END ==================\n\n");
    fclose( pFd );

    return SUCC;
}

/*****************************************************************
** ��    ��:��¼�ն������͵�IC��оƬ����
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
WriteIcTrack( ptAppStru )
T_App    *ptAppStru;
{
    FILE    *pFd;
    char    szFileName[80], szTmpBuf[1024], szDate[20];

    sprintf(szFileName,"%s/log/Test",getenv("WORKDIR") );
    GetSysDate( szDate );
    strcat( szFileName, szDate );
    if( (pFd = fopen( szFileName, "a+") ) == NULL )
    {
        WriteLog( ERROR, "fopen [%s] err", szFileName );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return( FAIL );
    }
    fprintf( pFd, "%d %s==================\n", ptAppStru->iTransType, 
        ptAppStru->szTransName );

    fprintf( pFd, "��ȫģ���[%s]\n", ptAppStru->szPsamNo );
    fprintf( pFd, "���ŵ�[%s]\n", ptAppStru->szTrack2 );
    fprintf( pFd, "���ŵ�[%s]\n", ptAppStru->szTrack3 );

    fprintf( pFd, "END ==================\n\n");
    fclose( pFd );

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );

    return(SUCC);
}

/*****************************************************************
** ��    ��:��ʾ������ʾ��Ϣ
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
DispOperationInfo( ptAppStru )
T_App *ptAppStru;
{
    unsigned char    szTmpBuf[20], szTmpStr[20];
    int    i, iCmdLen;

    GetSysDate( ptAppStru->szHostDate );
    GetSysTime( ptAppStru->szHostTime );

    memcpy( szTmpBuf, ptAppStru->szTransCode, 2 );
    AscToBcd( szTmpBuf, 2, 0 ,szTmpStr);
    i = szTmpStr[0];
    if( i >= 255 )
    {
        strcpy( ptAppStru->szRetCode, ERR_LAST_RECORD );
        memset( ptAppStru->szNextTransCode, 0, 8 );
        return FAIL;    
    }
    else
    {
        i ++;
        szTmpStr[0] = i;
        BcdToAsc( szTmpStr, 2, 0 ,szTmpBuf);
        memcpy( ptAppStru->szNextTransCode, szTmpBuf, 2 );
        memcpy( ptAppStru->szNextTransCode+2, ptAppStru->szTransCode+2, 6 );

        iCmdLen = 0;
        ptAppStru->iCommandNum = 0;
        memcpy( ptAppStru->szCommand+iCmdLen, "\x30", 1 );    //�Ƿ�ִ����һ��ָ��
        iCmdLen += 1;
        memcpy( ptAppStru->szCommand+iCmdLen, szTmpStr, 1 );    //�Ƿ�ִ����һ��ָ��-��ʾ��Ϣ����
        iCmdLen += 1;
        ptAppStru->iCommandNum ++;

        memcpy( ptAppStru->szCommand+iCmdLen, "\x8D", 1 );    //����MAC
        iCmdLen += 1;
        ptAppStru->iCommandNum ++;

        memcpy( ptAppStru->szCommand+iCmdLen, "\x24\x03", 2 );//��������
        iCmdLen += 2;
        ptAppStru->iCommandNum ++;

        memcpy( ptAppStru->szCommand+iCmdLen, "\x25\x04", 2 );//��������
        iCmdLen += 2;
        ptAppStru->iCommandNum ++;

        ptAppStru->iCommandLen = iCmdLen;
    }

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );

    return SUCC;
}

/*****************************************************************
** ��    ��:���Դ������ݶ�д
** �������:
        
** �������:
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:fengwei
** ��    ��:2013/03/11
** ����˵��:
** �޸���־:
**
****************************************************************/
int TestSerial(T_App *ptApp)
{
    T_TLVStru   tTlv;               /* TLV���ݽṹ */
    int         iLen;               /* �������ݳ��� */
    char        szData[128+1];      /* �������� */
    char        szTmpBuf[128+1];    /* ��ʱ���� */
    int         i;                  /* ��ʱ���� */
    int         j;                  /* ��ʱ���� */   

    /* TLV��ʼ�� */
    InitTLV(&tTlv, TAG_STANDARD, LEN_STANDARD, VALUE_NORMAL);

    if(UnpackTLV(&tTlv, ptApp->szReserved, ptApp->iReservedLen) != SUCC)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "�ַ���ת��ΪTLV���ݸ�ʽʧ��!");

        return FAIL;
    }

    if(memcmp(ptApp->szTransCode, "00", 2) == 0)
    {
        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        if((iLen = GetValueByTag(&tTlv, "\xDF\xB7\x01", szTmpBuf, sizeof(szTmpBuf))) == FAIL)
        {
            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);
    
            WriteLog(ERROR, "��ȡ��������ʧ��!");
    
            return FAIL;
        }

        memset(szData, 0, sizeof(szData));
        memcpy(szData, szTmpBuf, iLen);
        WriteLog(TRACE, "Read From Serial Port:[%s]", szData);

        memset(ptApp->szReserved, 0, sizeof(ptApp->szReserved));
        ptApp->iReservedLen = 0;

        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        for(i=iLen-1,j=0;i>=0;i--,j++)
        {
            szTmpBuf[j] = szData[i];
        }

        /* ���ú�������ָ�� */
        /* ��պ���ָ�� */
        memset(ptApp->szCommand, 0, sizeof(ptApp->szCommand));
        ptApp->iCommandLen = 0;
        ptApp->iCommandNum = 0;

        /* �������״���ǰ2λ��ʾ�����ؼ�¼����¼�ţ���6λΪ��ǰ���� */
        memset(ptApp->szNextTransCode, 0, sizeof(ptApp->szNextTransCode));
        memcpy(ptApp->szNextTransCode, "01", 2);
        memcpy(ptApp->szNextTransCode+2, ptApp->szTransCode+2, 6);

        /* д�������� */
        memcpy(ptApp->szCommand+ptApp->iCommandLen, "\xB8", 1);
        ptApp->iCommandLen += 1;
        ptApp->iCommandNum += 1;

        /* ����MAC */
        memcpy(ptApp->szCommand+ptApp->iCommandLen, "\x8D", 1);
        ptApp->iCommandLen += 1;
        ptApp->iCommandNum += 1;

        /* �������� */
        memcpy(ptApp->szCommand+ptApp->iCommandLen, "\x24\x03", 2);
        ptApp->iCommandLen += 2;
        ptApp->iCommandNum += 1;

        /* �������� */
        memcpy(ptApp->szCommand+ptApp->iCommandLen, "\x25\x04", 2);
        ptApp->iCommandLen += 2;
        ptApp->iCommandNum += 1;

        ptApp->szReserved[0] = 0x60;
        ptApp->szReserved[1] = iLen;
        memcpy(ptApp->szReserved+2, szTmpBuf, iLen);
        ptApp->iReservedLen = iLen + 2;

        WriteLog(TRACE, "Write To Serial Port:[%s]", ptApp->szReserved+2);
    }
    else
    {
        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        if((iLen = GetValueByTag(&tTlv, "\xDF\xB8\x01", szTmpBuf, sizeof(szTmpBuf))) == FAIL)
        {
            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);
    
            WriteLog(ERROR, "��ȡ��������ʧ��!");
    
            return FAIL;
        }
        
        WriteLog(TRACE, "Serial Port Write Return:[%s]", szTmpBuf);
    }

    strcpy(ptApp->szRetCode, TRANS_SUCC);

    return SUCC;
}