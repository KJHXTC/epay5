/*********************************************************
Copyright(C)2012 - 2015���������豸���޹�˾
��Ҫ���ݣ����ܷ������ؽ���
�� �� �ˣ�
�������ڣ�2012/11/8


$Revision: 1.15 $
$Log: hsm.c,v $
Revision 1.15  2012/12/24 08:30:20  fengw

1���޸�argc�жϡ�
2���޸�GetMasterKey���÷���ֵ�жϡ�

Revision 1.14  2012/12/21 07:02:58  wukj
*** empty log message ***

Revision 1.13  2012/12/10 07:56:53  wukj
*** empty log message ***

Revision 1.12  2012/12/10 07:52:07  wukj
ANS��غ�����������

Revision 1.11  2012/12/05 06:32:14  wukj
*** empty log message ***

Revision 1.10  2012/11/29 07:51:43  wukj
�޸���־����,�޸�ascbcdת������

Revision 1.9  2012/11/29 01:57:55  wukj
��־�����޸�

Revision 1.8  2012/11/28 02:58:41  wukj
*** empty log message ***

Revision 1.7  2012/11/21 04:13:38  wukj
�޸�hsmincl.h Ϊhsm.h

Revision 1.6  2012/11/21 03:23:15  wukj
���ܻ�����˵��

Revision 1.5  2012/11/21 03:20:31  wukj
1:���ܻ����������޸� 2: ȫ�ֱ�������hsmincl.h


��  ��: ������ܽ�������
��  ��: Robin 2009/04/05
        Landi
ע  ��: giHsmType == 0 ʹ���������
        giHsmType == 1 ʹ��Sjl06ERacal���ܻ���56��
        giHsmType == 2 ʹ��Sjl05Racal���ܻ���30��
        giHsmType == 3 ʹ������ר�ü��ܻ�
        giHsmType == 4 ʹ��SJL06��ָ����ܻ�
        giHsmType == 5 ʹ��SJL06S��ָ����ܻ�
*********************************************************/
#ifndef _MAIN_
#define _MAIN_
#endif

#include "hsm.h"


void  catch_exit(int iNouse) 
{
    close( giSockFd );
    WriteLog( TRACE, "hsm exit on SIGUSR1" );
    exit ( 0 );
}

main ( argc , argv )
int argc;
char * argv[ ];
{
    T_Interface tInterface;
    char    szReadData[100], szTmpBuf[200], szHsmIp[20];
    int     i, iHsmType, iRet, iHsmPort, iTimeOut;
    long    lMsgType;

    if( argc < 2)
    {
        WriteLog(ERROR,"HSM����������������[%d]",argc);
        WriteLog(ERROR,"HSM����: hsm HSMTYPE [HSMIP] [HSMPORT]");
        exit(0);
    }
    giHsmType = atoi( argv[1] );

    if( giHsmType != SIM_HSM )
    {
        if( argc != 3)
        {
            WriteLog(ERROR,"HSM����������������[%d]",argc);
            WriteLog(ERROR,"HSM����: hsm HSMTYPE [HSMIP] [HSMPORT]");
            exit(0);
        }
        strcpy(szHsmIp,argv[2]);
        iHsmPort = atoi(argv[3]);

//WriteLog( TRACE, "connect hsm ip[%s] port[%d] begin",szHsmIp, iHsmPort );

        if(giHsmType == SJL06E_RACAL_HSM)
        {
            /* ��̨�ն�����Կ�洢������Կ��ͬʱ���ڼ��ܴ洢������Կ */
            memset( szTmpBuf, 0, 80 );
            strcpy( szReadData, "SEK_HOST_INDEX_SJL06ERAcAL" );
            if( ReadConfig( "Setup", "SECTION_HSM", szReadData, szTmpBuf ) != SUCC )
            {
                WriteLog( ERROR, "Setup�������ô���[%s]", 
                    szReadData );
                exit( 0 );
            }
            giSekHostTmkIndexSjl06ERacal = atoi( szTmpBuf );
            giSekHostWorkIndexSjl06ERacal = atoi( szTmpBuf );

            memset( szTmpBuf, 0, 80 );
            strcpy( szReadData, "POSC_ZMK_SJL06ERAcAL" );
            if( ReadConfig( "Setup", "SECTION_HSM", szReadData, szTmpBuf ) != SUCC )
            {
                WriteLog( ERROR, "Setup�������ô���[%s]", 
                    szReadData );
                exit( 0 );
            }
            strcpy( gszPoscZMKSjl06ERacal, szTmpBuf );
            memset( szTmpBuf, 0, 80 );
            strcpy( szReadData, "POSP_ZMK_SJL06ERAcAL" );
            if( ReadConfig( "Setup", "SECTION_HSM", szReadData, szTmpBuf ) != SUCC )
            {
                WriteLog( ERROR, "Setup�������ô���[%s]", 
                    szReadData );
                exit( 0 );
            }
            strcpy( gszPospZMKSjl06ERacal, szTmpBuf );

        }
        else if(giHsmType == SJL06_UNIONPAY_HSM)
        {
            /* ��̨�ն�����Կ�洢������Կ��ͬʱ���ڼ��ܴ洢������Կ */
            memset( szTmpBuf, 0, 80 );
            strcpy( szReadData, "SEK_HOST_INDEX_SJL06UP" );
            if( ReadConfig( "Setup", "SECTION_HSM", szReadData, szTmpBuf ) != SUCC )
            {
                WriteLog( ERROR, "Setup�������ô���[%s]", szReadData );
                exit( 0 );
            }
            giSekHostTmkIndexSjl06Up = atoi( szTmpBuf );
            giSekHostWorkIndexSjl06Up = atoi( szTmpBuf );

            /* �ն�����Կ������Կ��ͬʱ���ڼ��ܴ洢������Կ */
            memset( szTmpBuf, 0, 80 );
            strcpy( szReadData, "SEK_POS_INDEX_SJL06UP" );
            if( ReadConfig( "Setup", "SECTION_HSM", szReadData, szTmpBuf ) != SUCC )
            {
                WriteLog( ERROR, "Setup�������ô���[%s]",
                    szReadData );
                exit( 0 );
            }
            giSekTmkIndexSjl06Up = atoi( szTmpBuf );
            giSekWorkIndexSjl06Up = giSekTmkIndexSjl06Up;

            /* �ն�����Կ���������Կ */
            memset( szTmpBuf, 0, 80 );
            strcpy( szReadData, "TEK_POS_INDEX_SJL06UP" );
            if( ReadConfig( "Setup", "SECTION_HSM", szReadData, szTmpBuf ) != SUCC )
            {
                WriteLog( ERROR, "Setup�������ô���[%s]",
                    szReadData );
                exit( 0 );
            }
            giTekTmkIndexSjl06Up = atoi( szTmpBuf );
        }
        else if( giHsmType == SJL05_RACAL_HSM)
        {
            /* ��̨�ն�����Կ�洢������Կ��ͬʱ���ڼ��ܴ洢������Կ */
            memset( szTmpBuf, 0, 80 );
            strcpy( szReadData, "SEK_HOST_INDEX_SJL05RACAL" );
            if( ReadConfig( "Setup", "SECTION_HSM", szReadData, szTmpBuf ) != SUCC )
            {
                WriteLog( ERROR, "Setup�������ô���[%s]", szReadData );
                exit( 0 );
            }
            giSekHostTmkIndexSjl05Racal = atoi( szTmpBuf );
            giSekHostWorkIndexSjl05Racal = atoi( szTmpBuf );

            /* �ն�����Կ������Կ��ͬʱ���ڼ��ܴ洢������Կ */
            memset( szTmpBuf, 0, 80 );
            strcpy( szReadData, "SEK_POS_INDEX_SJL05RACAL" );
            if( ReadConfig( "Setup", "SECTION_HSM", szReadData, szTmpBuf ) != SUCC )
            {
                WriteLog( ERROR, "Setup�������ô���[%s]",
                    szReadData );
                exit( 0 );
            }
            giSekTmkIndexSjl05Racal = atoi( szTmpBuf );
            giSekWorkIndexSjl05Racal = giSekTmkIndexSjl05Racal;

            /* �ն�����Կ���������Կ */
            memset( szTmpBuf, 0, 80 );
            strcpy( szReadData, "TEK_POS_INDEX_SJL05RACAL" );
            if( ReadConfig( "Setup", "SECTION_HSM", szReadData, szTmpBuf ) != SUCC )
            {
                WriteLog( ERROR, "Setup�������ô���[%s]",
                    szReadData );
                exit( 0 );
            }
            giTekTmkIndexSjl05Racal = atoi( szTmpBuf );

            /* �ն�����Կ */
            memset( szTmpBuf, 0, 80 );
            strcpy( szReadData, "TMK_INDEX_SJL05RACAL" );
            if( ReadConfig( "Setup", "SECTION_HSM", szReadData, szTmpBuf ) != SUCC )
            {
                WriteLog( ERROR, "Setup�������ô���[%s]",
                    szReadData );
                exit( 0 );
            }
            giTmkIndexSjl05Racal = atoi( szTmpBuf );
        }
        else if( giHsmType == SJL06S_JK_HSM)
        {
            /* ��̨�ն�����Կ�洢������Կ��ͬʱ���ڼ��ܴ洢������Կ */
            memset( szTmpBuf, 0, 80 );
            strcpy( szReadData, "SEK_HOST_INDEX_SJL06JK" );
            if( ReadConfig( "Setup", "SECTION_HSM", szReadData, szTmpBuf ) != SUCC )
            {
                WriteLog( ERROR, "Setup�������ô���[%s]", szReadData );
                exit( 0 );
            }
            giSekHostTmkIndexSjl06SJk = atoi( szTmpBuf );
            giSekHostWorkIndexSjl06SJk = atoi( szTmpBuf );

            /*��ʱ�������Կ */
            memset( szTmpBuf, 0, 80 );
            strcpy( szReadData, "TEMP_BMK_INDEX_SJL06JK" );
            if( ReadConfig( "Setup", "SECTION_HSM", szReadData, szTmpBuf ) != SUCC )
            {
                WriteLog( ERROR, "Setup�������ô���[%s]", szReadData );
                exit( 0 );
            }
            giTempBMKIndexSjl06SJk = atoi( szTmpBuf );

            /* �ն�����Կ������Կ��ͬʱ���ڼ��ܴ洢������Կ */
            memset( szTmpBuf, 0, 80 );
            strcpy( szReadData, "SEK_POS_INDEX_SJL06JK" );
            if( ReadConfig( "Setup", "SECTION_HSM", szReadData, szTmpBuf ) != SUCC )
            {
                WriteLog( ERROR, "Setup�������ô���[%s]",
                    szReadData );
                exit( 0 );
            }
            giSekTmkIndexSjl06SJk = atoi( szTmpBuf );
            giSekWorkIndexSjl06SJk = giSekTmkIndexSjl06SJk;

            /* �ն�����Կ���������Կ */
            memset( szTmpBuf, 0, 80 );
            strcpy( szReadData, "TEK_POS_INDEX_Sjl06SJk" );
            if( ReadConfig( "Setup", "SECTION_HSM", szReadData, szTmpBuf ) != SUCC )
            {
                WriteLog( ERROR, "Setup�������ô���[%s]",
                    szReadData );
                exit( 0 );
            }
            giTekTmkIndexSjl06SJk = atoi( szTmpBuf );
        }
        else if( giHsmType == SJL06_JK_HSM)
        {
            /* ��̨�ն�����Կ�洢������Կ��ͬʱ���ڼ��ܴ洢������Կ */
            memset( szTmpBuf, 0, 80 );
            strcpy( szReadData, "SEK_HOST_INDEX_Sjl06Jk" );
            if( ReadConfig( "Setup", "SECTION_HSM", szReadData, szTmpBuf ) != SUCC )
            {
                WriteLog( ERROR, "Setup�������ô���[%s]", szReadData );
                exit( 0 );
            }
            giSekHostTmkIndexSjl06Jk = atoi( szTmpBuf );
            giSekHostWorkIndexSjl06Jk = atoi( szTmpBuf );

            /*��ʱ�������Կ */
            memset( szTmpBuf, 0, 80 );
            strcpy( szReadData, "TEMP_BMK_INDEX_Sjl06Jk" );
            if( ReadConfig( "Setup", "SECTION_HSM", szReadData, szTmpBuf ) != SUCC )
            {
                WriteLog( ERROR, "Setup�������ô���[%s]", szReadData );
                exit( 0 );
            }
            giTempBMKIndexSjl06Jk = atoi( szTmpBuf );

            /* �ն�����Կ������Կ��ͬʱ���ڼ��ܴ洢������Կ */
            memset( szTmpBuf, 0, 80 );
            strcpy( szReadData, "SEK_POS_INDEX_Sjl06Jk" );
            if( ReadConfig( "Setup", "SECTION_HSM", szReadData, szTmpBuf ) != SUCC )
            {
                WriteLog( ERROR, "Setup�������ô���[%s]",
                    szReadData );
                exit( 0 );
            }
            giSekTmkIndexSjl06Jk = atoi( szTmpBuf );
            giSekWorkIndexSjl06Jk = giSekTmkIndexSjl06Jk;

            /* �ն�����Կ���������Կ */
            memset( szTmpBuf, 0, 80 );
            strcpy( szReadData, "TEK_POS_INDEX_Sjl06Jk" );
            if( ReadConfig( "Setup", "SECTION_HSM", szReadData, szTmpBuf ) != SUCC )
            {
                WriteLog( ERROR, "Setup�������ô���[%s]",
                    szReadData );
                exit( 0 );
            }
            giTekTmkIndexSjl06Jk = atoi( szTmpBuf );
        }
        else
        {
             WriteLog(ERROR,"���ܻ����ʹ���[%d]",giHsmType);
             exit( 0 );
        }
    }
    else
    {
#ifdef MKEY_TRIDES
        iRet = GetMasterKey( gszMasterKeySim, 16 );
#else
        iRet = GetMasterKey( gszMasterKeySim, 8 );
#endif
        if( iRet == FAIL )
        {
            WriteLog( ERROR, "read key fail" );
            return FAIL;
        }
    }

    if( GetEpayMsgId( ) < 0 )
    {
        WriteLog (ERROR, "HSM Process GetEpayMsgId() Error!") ;
        exit (1) ;
    }

    if( GetEpayShm( ) != SUCC )
    {
        WriteLog(ERROR, "GetEpayShm fail!");
        return (FAIL);
    }

    setpgrp () ;

    /* next fork let ctrl know I started OK!!! */
    switch (fork () ) 
    {

    case 0 :
        break;
    case -1 :
        WriteLog (ERROR, " Fork error !!!") ;
        exit (-3) ;
    default :
        exit (0) ;

    }

    for( i=1; i<32; i++ )
    {
        if( i == SIGALRM || i == SIGKILL || i == SIGUSR1 ||
            i == SIGUSR2 )
        {
            continue;
        }
        signal( i, SIG_IGN );
    }
    signal (SIGUSR1, catch_exit) ;

    if( giHsmType != SIM_HSM )
    {
        giSockFd = ConnectHsm( szHsmIp,  iHsmPort );
    }

    WriteLog( TRACE, "hsm ready..." );
    iHsmType = HSMSIZE;
    lMsgType = 0L;
    iTimeOut = 0;    /*���޵ȴ�*/
    while (1) 
    {
        memset( (char *)&tInterface, 0, iHsmType );
        if( RecvToHsmQue( lMsgType, iTimeOut, &tInterface ) != SUCC )
        {
            continue;
        }
    
        iRet = Process( tInterface );
        if( iRet != SUCC )
        {
            WriteLog( ERROR,"hsm module Process fail ");
            if( giHsmType != SIM_HSM )
            {
                giSockFd = ConnectHsm( szHsmIp,  iHsmPort );
            }
        }
    }
}

int Process( T_Interface tInterface )
{
    int    iRet, iSekIndex;

    switch( tInterface.iTransType)
    {

    case GET_WORK_KEY:
        if( giHsmType == SJL06_UNIONPAY_HSM )
        {
            iRet = Sjl06UphsmGetWorkKey( &tInterface, giSekTmkIndexSjl06Up, giSekWorkIndexSjl06Up );
        }
        else if( giHsmType == SJL06E_RACAL_HSM)
        {
            iRet = Sjl06eRacalGetWorkKey( &tInterface );
        }
        else if( giHsmType == SJL05_RACAL_HSM)
        {
#ifdef FJ_ICBC
            iRet = Sjl05GetWorkKey_FJICBC( &tInterface, giSekTmkIndexSjl05Racal, giSekWorkIndexSjl05Racal );
#else
            iRet = Sjl05GetWorkKey( &tInterface, giSekTmkIndexSjl05Racal, giSekWorkIndexSjl05Racal );
#endif
        }
        else if( giHsmType == SJL06_JK_HSM)
        {
            iRet = Sjl06JkGetWorkKey( &tInterface, giSekTmkIndexSjl06Jk, giSekWorkIndexSjl06Jk, giTempBMKIndexSjl06Jk );
        }
        /** add new hsm type : Sjl06SJk **
        ** by zhengguoq **/
        else if( giHsmType == SJL06S_JK_HSM)
        {     
            iRet = Sjl06sGetWorkKey( &tInterface, giSekTmkIndexSjl06SJk, giSekWorkIndexSjl06SJk, giTempBMKIndexSjl06SJk );
        }
        else
        {
            iRet = SimhsmGetWorkKey( &tInterface );
        }
        break;
    case GET_MASTER_KEY:
        if( giHsmType == SJL06_UNIONPAY_HSM )
        {
            iRet = Sjl06UphsmGetTmk( &tInterface, giSekTmkIndexSjl06Up, giTekTmkIndexSjl06Up );
        }
        else if( giHsmType == SJL06E_RACAL_HSM)
        {
            iRet = Sjl06eRacalGetTmk( &tInterface );
        }
        else if( giHsmType == SJL05_RACAL_HSM)
        {
            iRet = Sjl05GetTmk( &tInterface, giSekTmkIndexSjl05Racal, giTekTmkIndexSjl05Racal );
        }
        else if( giHsmType == SJL06_JK_HSM)
        {
            iRet = Sjl06JkGetTmk( &tInterface, giSekTmkIndexSjl06Jk, giTekTmkIndexSjl06Jk );
        }
        /** add by zhengguoq **/
        else if( giHsmType == SJL06S_JK_HSM)
        {
            iRet = Sjl06sGetTmk( &tInterface, giSekTmkIndexSjl06SJk, giTekTmkIndexSjl06SJk );
        }
        else
        {
            iRet = SimhsmGetTmk( &tInterface );
        }
        break;
    case CALC_MAC:

        if( giHsmType == SJL06_UNIONPAY_HSM )
        {
            if( tInterface.iAlog== XOR_CALC_MAC )
            {
                iSekIndex = giSekWorkIndexSjl06Up;
            }
            else
            {
                iSekIndex = giSekHostWorkIndexSjl06Up;
            }
            iRet = Sjl06UphsmCalcMac( &tInterface, iSekIndex );
        }
        else if( giHsmType == SJL06E_RACAL_HSM)
        {
            iRet = Sjl06eRacalCalcMac( &tInterface );
        }
        else if( giHsmType == SJL05_RACAL_HSM)
        {
            if( tInterface.iAlog == XOR_CALC_MAC )
            {
                iSekIndex = giSekWorkIndexSjl05Racal;
            }
            else
            {
                iSekIndex = giSekHostWorkIndexSjl05Racal;
            }
            iRet = Sjl05CalcMac( &tInterface, iSekIndex );
        }
        else if( giHsmType == SJL06_JK_HSM)
        {
            if( tInterface.iAlog == XOR_CALC_MAC )
            {
                iSekIndex = giSekWorkIndexSjl06Jk;
            }
            else
            {
                iSekIndex = giSekHostWorkIndexSjl06Jk;
            }
            iRet = Sjl06JkCalcMac( &tInterface, iSekIndex );
        }
        /** add by zhenggguoq **/
        else if( giHsmType == SJL06S_JK_HSM)
        {
            if( tInterface.iAlog == XOR_CALC_MAC )
            {
                iSekIndex = giSekWorkIndexSjl06SJk;
            }
            else
            {
                iSekIndex = giSekHostWorkIndexSjl06SJk;
            }
#ifdef DEBUGON
            WriteLog(TRACE,"====calc mac used sekindex [%d]", iSekIndex);
#endif
            iRet = Sjl06sCalcMac( &tInterface, iSekIndex );
        }
        else
        {
            iRet = SimhsmCalcMac( &tInterface );
        }
        break;
    case CHANGE_PIN:
        if( giHsmType == SJL06_UNIONPAY_HSM )
        {
            iRet = Sjl06UphsmChangePin( &tInterface, giSekWorkIndexSjl06Up, giSekHostWorkIndexSjl06Up );
        }
        else if( giHsmType == SJL06E_RACAL_HSM)
        {
            iRet = Sjl06eRacalChangePin( &tInterface );
        }
        else if( giHsmType == SJL05_RACAL_HSM)
        {
            iRet = Sjl05ChangePin( &tInterface, giSekWorkIndexSjl05Racal, giSekHostWorkIndexSjl05Racal );
        }
        else if( giHsmType == SJL06_JK_HSM)
        {
            iRet = Sjl06JkChangePin( &tInterface, giSekWorkIndexSjl06Jk, giSekHostWorkIndexSjl06Jk );
        }
        /** add by zhengguoq **/
        else if( giHsmType == SJL06S_JK_HSM)
        {
            iRet = Sjl06sChangePin( &tInterface, giSekWorkIndexSjl06SJk, giSekHostWorkIndexSjl06SJk );
        }
        else
        {
            iRet = SimhsmChangePin( &tInterface );
        }
        break;
    case VERIFY_PIN:
        if( giHsmType == SJL06_UNIONPAY_HSM )
        {
            iRet = Sjl06UphsmVerifyPin( &tInterface, giSekWorkIndexSjl06Up );
        }
        else if( giHsmType == SJL06E_RACAL_HSM)
        {
            iRet = Sjl06eRacalVerifyPin( &tInterface );
        }
        else if( giHsmType == SJL05_RACAL_HSM)
        {
            iRet = Sjl05VerifyPin( &tInterface, giSekWorkIndexSjl05Racal );
        }
        else if( giHsmType == SJL06_JK_HSM)
        {
            iRet = Sjl06JkVerifyPin( &tInterface, giSekWorkIndexSjl06Jk );
        }
        /** add by zhengguoq **/
        else if( giHsmType == SJL06S_JK_HSM)
        {
            iRet = Sjl06sVerifyPin( &tInterface, giSekWorkIndexSjl06SJk );
        }
        else
        {
            iRet = SimhsmVerifyPin( &tInterface );
        }
        break;
    case DECRYPT_PIN:
        if( giHsmType == SJL05_RACAL_HSM)
        {
            iRet = Sjl05DecryptPin( &tInterface, giSekWorkIndexSjl05Racal );
        }
        else if( giHsmType == SJL06E_RACAL_HSM)
        {
            iRet = Sjl06eRacalDecryptPin( &tInterface );
        }
        /** add by zhengguoq **/
        else if( giHsmType == SJL06S_JK_HSM)
        {
#ifdef MKEY_TRIDES
            iRet = GetMasterKey( gszMasterKeySim, 16 );
#else
            iRet = GetMasterKey( gszMasterKeySim, 8 );
#endif
            if( iRet == FAIL )
            {
                WriteLog( ERROR, "read key fail" );
                return FAIL;
            }
            iRet = SimhsmDecryptPin( &tInterface );
        }
        else
        {
            iRet = SimhsmDecryptPin( &tInterface );
        }
        break;
    case CHANGE_PIN_PIK2TMK:
        if( giHsmType == SJL05_RACAL_HSM)
        {
            iRet = Sjl05ChangePin_PIK2TMK( &tInterface, giSekWorkIndexSjl05Racal, giTmkIndexSjl05Racal );
        }
        else if( giHsmType == SJL06E_RACAL_HSM)
        {
            iRet = Sjl06eRacalChangePin_TPK2LMK( &tInterface );
        }
        break;
    case CALC_CHKVAL:
        if( giHsmType == SJL06_UNIONPAY_HSM )
        {
            iRet = Sjl06UphsmCalcChkval( &tInterface, giSekHostWorkIndexSjl06ERacal );
        }
        else if( giHsmType == SJL06E_RACAL_HSM)
        {
            iRet = Sjl06eRacalCalcChkval( &tInterface );
        }
        else if( giHsmType == SJL05_RACAL_HSM)
        {
            iRet = Sjl05CalcChkval( &tInterface, giSekHostWorkIndexSjl05Racal );
        }
        else if( giHsmType == SJL06_JK_HSM)
        {
            iRet = Sjl06JkCalcChkval( &tInterface, giSekHostWorkIndexSjl06Jk );
        }
        /** add by zhengguoq **/
        else if( giHsmType == SJL06S_JK_HSM)
        {
            iRet = Sjl06sCalcChkval( &tInterface, giSekHostWorkIndexSjl06SJk );
        }
        else
        {
            iRet = SimhsmCalcChkval( &tInterface );
        }
        break;
    case DECRYPT_TRACK:
        if( giHsmType == SJL06_UNIONPAY_HSM )
        {
            iRet = SimhsmDecryptTrack( &tInterface );
        }
        else if( giHsmType == SJL05_RACAL_HSM)
        {
            iRet = Sjl05DecryptTrack( &tInterface, giSekWorkIndexSjl05Racal );
        }
        else
        {
            iRet = SimhsmDecryptTrack( &tInterface );
        }
        break;
    case CHANGE_KEY:
        if( giHsmType == SJL06_UNIONPAY_HSM )
        {
            iRet = Sjl06UphsmChangeWorkKey( &tInterface, giSekHostTmkIndexSjl06Up, giSekHostWorkIndexSjl06Up );
        }
        else if( giHsmType == SJL05_RACAL_HSM)
        {
            iRet = Sjl05ChangeWorkKey( &tInterface, giSekHostTmkIndexSjl06ERacal, giSekHostWorkIndexSjl06ERacal );
        }
        else if( giHsmType == SJL06E_RACAL_HSM)
        {
            iRet = Sjl06eRacalChangeWorkkey( &tInterface );
        }
        else if( giHsmType == SJL06_JK_HSM)
        {
            iRet = Sjl06JkChangeWorkKey( &tInterface, giSekHostTmkIndexSjl06Jk, giSekHostWorkIndexSjl06Jk, giTempBMKIndexSjl06Jk );
        }
        /** add by zhengguoq **/
        else if( giHsmType == SJL06S_JK_HSM)
        {
            iRet = Sjl06sChangeWorkKey( &tInterface, giSekHostTmkIndexSjl06SJk, giSekHostWorkIndexSjl06SJk, giTempBMKIndexSjl06SJk );
        }
        else
        {
            iRet = SimhsmChangeWorkKey( &tInterface );
        }
        break;
    default:
        WriteLog( ERROR, "trans_type error %ld", tInterface.iTransType);    
        break;
    }

    if( SendFromHsmQue( tInterface.lSourceType, &tInterface ) != SUCC )
    {
        WriteLog (ERROR," write msg to hsm fail!");
    }
    
    return ( iRet );
}
