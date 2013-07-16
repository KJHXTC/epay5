/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�ģ���̨����
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision $
 * $Log: simhost.ec,v $
 * Revision 1.1  2012/12/13 01:52:19  linxiang
 * *** empty log message ***
 *
 * ----------------------------------------------------------------
 */
# include "simhost.h" 


void HostProc(T_App *ptApp);

/* ----------------------------------------------------------------
 * ��    �ܣ����̸����յ��ź��˳�����
 * ���������
 *           iSigNo    �յ����ź�
 * ���������
 * �� �� ֵ��
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
void GracefulExit ( int iSigNo ) 
{
    alarm ( 0 ) ;
    exit (iSigNo);
}

main (int argc, char *argv[])
{
    int iRet, i, iTimeOut, iProcNum, iHostId, iCommNum;

    if( argc != 5 )
    {
        printf("Usage : simhost HostId CommNum SleepTime ProcNum\n");
        WriteLog(ERROR, "Usage : simhost HostId CommNum SleepTime ProcNum");
        return (FAIL);
    }
    iHostId = atoi(argv[1]);
    iCommNum = atoi(argv[2]);
    iTimeOut = atoi(argv[3]);
    iProcNum = atoi(argv[4]);

    /*���ɾ������, ʹ�������ն��ѽ�*/
    /*���ն��ѽں�,scanf�Ⱥ������޷�ʹ��*/
    switch ( fork ( ) ) {
    case 0 : 
        break;
    case -1 :
        exit ( -1 );
    default :
        exit ( 0 );        

    }
    for( i = 0; i < 32; i++ )
    {
        if( i == SIGALRM || i == SIGKILL || 
            i == SIGUSR1 || i == SIGUSR2 )
             continue;
        signal( i, SIG_IGN );
    }
    signal ( SIGUSR1, GracefulExit ) ;

    setpgrp (); /* Make a back process */

    /*��ȡ��Ϣ���б�ʶ*/
    if( GetEpayMsgId() != SUCC )
    {
        printf( "��ȡ��Ϣ���б�ʶ��������û�н���ϵͳ��ʼ��\n" );
        WriteLog( ERROR, "can't get msg");
        exit(0);
    }

    if( GetEpayShm() != SUCC )
    {
        printf( "ӳ�乲���ڴ�ʧ�ܣ�������û�н���ϵͳ��ʼ��\n" );
        WriteLog( ERROR, "GetSystemShmCtrl fail");
        exit(0);
    }

    iRet = SetHost( iHostId, iCommNum, 'Y', 'Y' );
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "SetHost fail");
        exit( 0 );
    }

    WriteLog (TRACE, "simhost ready..." );

    for( i=0; i<iProcNum; i++ )
    {
        switch ( fork ( ) ) {
        case 0 : 
            SingleProcess( iTimeOut, iHostId );
            break;
        case -1 :
            exit ( -1 );
        default :
            break;
        }
    }
}


/* ----------------------------------------------------------------
 * ��    �ܣ�ģ���̨ͨѶ�ӿ�
 * ���������
 *           iTimeout ��ʱʱ��
 *           iHostId ��̨����ID
 * ���������
 * �� �� ֵ��
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int SingleProcess( int iTimeOut, int iHostId )
{
    int i, iRet;
    T_App *ptApp;
    int iTdi, iRetTdi;
    int iShmExpired = 30;

    for( i = 0; i < 32; i++ )
    {
        if( i == SIGALRM || i == SIGKILL || 
            i == SIGUSR1 || i == SIGUSR2 )
             continue;
        signal( i, SIG_IGN );
    }
    signal( SIGUSR1, GracefulExit ) ;

    while(1)
    {
        iRet = RecvProcToPresentQue(iHostId, 0, &iTdi);
        ptApp = GetAppAddress(iTdi);
        if( ptApp == NULL )
        {
            WriteLog( ERROR, "GetApp [%d]error", iHostId );
            continue;
        }

        WriteAppStru( ptApp, "simhost read request" );

        if( iTimeOut > 0 && ptApp->iTransType != LOGIN )
        {
//            sleep(nTimeOut);
            usleep(iTimeOut*1000);
        }

        HostProc( ptApp );

        iRetTdi = GetTdiMatch(ptApp->szShopNo, ptApp->szPosNo, ptApp->lSysTrace, iShmExpired,ptApp->iTransType);
        if( iRetTdi == FAIL || iRetTdi != iTdi)
        {
            WriteLog( ERROR, "GetTdiMatch [%d]error", iHostId );
            continue;
        }
                            
        iRet = SendPresentToProcQue(ptApp->lPresentToProcMsgType, iTdi);
        if( iRet != SUCC )
        {
            WriteLog( ERROR, "SendPresentToProcQue[%03ld] error", iHostId );
            continue;
        }
        WriteAppStru( ptApp, "tohost send response" );
    }
}


/* ----------------------------------------------------------------
 * ��    �ܣ����ɺ�̨��ģ�ⱨ��
 * ���������
 *           ptApp �ӹ����ڴ��������������
 * ���������
 *           ptApp �����ڴ�д�����Ӧ����
 * �� �� ֵ��
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
void HostProc( T_App *ptApp )
{
    FILE *fp;
    int fd;
    long lAuthCode, lRrn;

    fp = fopen("~/etc/simhost.inf", "r+");
    if(fp == NULL)
    {
        WriteLog(ERROR, "simhost.int not exist");
        return;
    }
    fd = fileno(fp);
    flock(fd, LOCK_EX);
    fscanf(fp, "%d %d", &lAuthCode, &lRrn);
    lAuthCode++;
    lRrn++;
    fprintf(fp, "%d %d", lAuthCode, &lRrn);
    flock(fd, LOCK_UN);
    fclose(fp);
    
    sprintf( ptApp->szRetriRefNum, "%012ld", lRrn );
    sprintf( ptApp->szAuthCode, "%06ld", lAuthCode );

    if( ptApp->iTransType == INQUERY ) //|| ptApp->iTransType == ICBC_INQUERY )
    {
        sprintf( ptApp->szAddiAmount, "D%012ld", 1000000 );
    }
#if 0
    else if( ptApp->iTransType == CHINAUNICOM_INQ ||
        ptApp->iTransType == CHINATELECOM_INQ ||
        ptApp->iTransType == ELECTRICITY_INQ ||
        ptApp->iTransType == CHINAMOBILE_INQ )
    {
        if( memcmp( ptApp->szBusinessCode, "13305919562", 11 ) == 0 )
        {
            sprintf( ptApp->szAmount, "%012ld", 88888 );
        }
        else if( memcmp( ptApp->szBusinessCode, "13305919563", 11 ) == 0 )
        {
            sprintf( ptApp->szAmount, "%012ld", 0 );
        }
        else
        {
            sprintf( ptApp->szAmount, "%012ld", 66666 );
        }
    }
    else if( ptApp->iTransType == CHINAUNICOM_QUERY ||
             ptApp->iTransType == CHINATELECOM_QUERY ||
             ptApp->iTransType == CHINAMOBILE_QUERY )
    {
        if( memcmp( ptApp->szBusinessCode, "13305919562", 11 ) == 0 )
        {
            sprintf( ptApp->szAddiAmount, "D%012ld", 88888 );
        }
        else
        {
            sprintf( ptApp->szAddiAmount, "%012ld", 77777 );
        }
    }
#endif

    GetSysDate( ptApp->szHostDate );
    GetSysTime( ptApp->szHostTime );

#if 0
    if( ( ptApp->iTransType == CHINAUNICOM_INQ || 
          ptApp->iTransType == CHINAMOBILE_INQ ) &&
        memcmp( ptApp->szAmount, "000000000000", 12 ) == 0 )
    {
        strcpy( ptApp->szRetCode, ERR_NOT_PAY );
    }
    else
#endif
    {
        strcpy( ptApp->szRetCode, TRANS_SUCC );
    }

#if 0
    if( ptApp->iTransType == TRAN_OUT_OTHER_CALC_FEE )
    {
        /* δ����ת���������к� */
        if( strlen(ptApp->szFinancialCode) == 0 )
        {
            if( strcmp(ptApp->szAccount2, "4512891711209101" ) == 0 )
            {
                strcpy( ptApp->szFinancialCode, "123456789012" );
                strcpy( ptApp->szHolderName, "����" );
                strcpy( ptApp->szInBankName, "��ҵ���и��ݷ���" );
                strcpy( ptApp->szHostRetCode, "00000" );
            }
            else
            {
                strcpy( ptApp->szRetCode, ERR_NO_OTHER_BANK );
                strcpy( ptApp->szHostRetCode, ERR_ZJYW_NO_OTHER_BANK );
            }
        }
        /* ���� */
        else
        {
            if( strcmp(ptApp->szBusinessCode, "111111111111" ) == 0 )
            {
                strcpy( ptApp->szHolderName, "����" );
                strcpy( ptApp->szInBankName, "��ҵ���и��ݷ���" );
                strcpy( ptApp->szHostRetCode, "00000" );
            }
            else if( strcmp(ptApp->szBusinessCode, "222222222222" ) == 0 )
            {
                strcpy( ptApp->szInBankName, "��ҵ���и��ݷ���" );
                strcpy( ptApp->szHostRetCode, "00000" );
            }
            else
            {
                strcpy( ptApp->szRetCode, ERR_BANK_CODE );
                strcpy( ptApp->szHostRetCode, ERR_ZJYW_BANK_CODE );
            }
        }
    }
    else if( ptApp->iTransType == TRAN_OUT_OTHER )
    {
        WriteLog( TRACE, "�տ���:%s", ptApp->szHolderName );
        WriteLog( TRACE, "���:%s", ptApp->szPan );
        WriteLog( TRACE, "�տ:%s", ptApp->szAccount2 );
        WriteLog( TRACE, "������:%s", ptApp->szOutBankName );
        WriteLog( TRACE, "�����к�:%s", ptApp->szInBankId );
        WriteLog( TRACE, "���:%s", ptApp->szAmount );
        WriteLog( TRACE, "������:%s", ptApp->szAddiAmount );
    }
    else if( ptApp->iTransType == TRAFFIC_AMERCE_INQ ||
             ptApp->iTransType == TRAFFIC_AMERCE_NO_INQ )
    {
        GetSysDate( ptApp->szHostDate );
        strcpy( ptApp->szBusinessCode, "88000001" );
        strcpy( ptApp->szAmount, "000000020000" );
        strcpy( ptApp->szAddiAmount, "000000001000" );
        sprintf( ptApp->szRetriRefNum, "%012ld", lRrn );
        strcpy( ptApp->szHolderName, "����" );
        strcpy( ptApp->szHostRetCode, "00" );
    }
    else
#endif
    {
        strcpy( ptApp->szHolderName, "����" );
        strcpy( ptApp->szHostRetCode, "00" );
    }

    ptApp->iReservedLen = 0;

    return;
}
