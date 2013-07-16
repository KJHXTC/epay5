/*******************************************************************************
 * Copyright(C)2012��2015 �������������豸���޹�˾
 * ��Ҫ���ݣ��ű�POS ����ģ�顣��Ϊ����ˣ�������������FSK�������ء�·
 *           �������Գ�����˫����ʽ���룬ʵ�ֽű�POS�뽻�״���ϵͳ����
 *           ���������ĺϷ�����֤���Լ��ű�POS�����������ڲ��������ݽ�
 *           �����ݵĸ�ʽ��ת��
 * �� �� �ˣ�Robin
 * �������ڣ�2012/11/19
 *
 * $Revision: 1.6 $
 * $Log: ScriptPos.ec,v $
 * Revision 1.6  2013/06/14 06:33:26  fengw
 *
 * 1������SetEnvTransId���ô��롣
 *
 * Revision 1.5  2013/01/18 08:32:37  fengw
 *
 * 1����ֺ�����
 *
 * Revision 1.4  2012/12/26 01:15:43  wukj
 * ִ��SrvAcceptʧ�ܺ�return FAIl�޸�Ϊcontinue
 *
 * Revision 1.3  2012/12/21 03:35:33  chenrb
 * *** empty log message ***
 *
 * Revision 1.2  2012/12/17 09:20:19  chenrb
 * *** empty log message ***
 *
 * Revision 1.1  2012/12/12 02:23:18  chenrb
 * ��ʼ�汾
 *
 ******************************************************************************/

#include "ScriptPos.h"

/*******************************************************************************
 * �������ܣ����������˳��������˳�ǰ��Щ�ƺ��������ر����ݿ⡢�ر�socket�ȡ�
 * ���������
 *           iExitStatus - �����˳�ʱ״̬����exit��Ϊ��������
 * ���������
 *           ��
 * �� �� ֵ�� 
 *           ��
 *
 * ��    �ߣ�Robin
 * ��    �ڣ�2012/11/20
 *
 ******************************************************************************/
void  GracefulExit( iExitStatus )
int iExitStatus;
{
    WriteLog( TRACE, "ScriptPos receive signal USR1 and exit" );
    CloseDB( );
    if( giSock > 0 )
    {
        close( giSock );
        WriteLog( TRACE, "close Sock %ld", giSock );
    }

    exit( iExitStatus );
}

/*******************************************************************************
 * �������ܣ��յ��û��ź�USR2������ת
 *           ��TDI_SEM�ź����ȡ�
 * ���������
 *           iNoUse - ���ò���
 * ���������
 *           ��
 * �� �� ֵ�� 
 *           ��
 *
 * ��    �ߣ�Robin
 * ��    �ڣ�2012/11/20
 *
 ******************************************************************************/
void RecUSR2Proc( int nNoUse )
{
    siglongjmp( env, 1 );
}

/*******************************************************************************
 * �������ܣ���������˿ڣ��ȴ��ͻ��˷������������յ����������forkһ�Է���
 *           ���̣������̼��������ȴ������ͻ��˵�����������һ�Է�����̣�
 *           1������һ����������ػ���socket�˿ڣ��ȴ������ն˷���Ľ�������
 *              �����в������Ȼ��ͨ��ACCESS_TO_PROC��Ϣ���з��͸����״����
 *              ����
 *           2������һ�������ػ���PROC_TO_ACCESS��Ϣ�����У��ȴ����ս���Ӧ��
 *              �������������Ȼ��ͨ��socket���͸��նˡ�
 * ���������
 *           argv[1]  -  ����˿�
 * ���������
 *           ��
 * �� �� ֵ�� 
 *           FAIL  -  ʧ��
 *
 * ��    �ߣ�Robin
 * ��    �ڣ�2012/11/20
 *
 ******************************************************************************/
int main (argc, argv)
int    argc;
char   *argv[ ];
{
    int     i, j, k, iSock, iNewSock, iRet;
    long    lPid, lChildPid, lPrePid;
    char    szSvrPort[5+1];
    char    szIp[16], szTmpStr[200], szSectionName[256], szItemName[100], szTmpBuf[200];
    int     iMaxLinkNum;
    char    szDate[9], szTime[7];

    if( argc < 2 ) 
    {
        WriteLog( ERROR, "Usage : ScriptPos SvrPort" );
        return( FAIL );
	}

    memset(szSvrPort, 0, sizeof(szSvrPort));
    strcpy(szSvrPort, argv[1]);

    for( i = 0; i < 32; i++ )
    {
        if( i == SIGALRM || i == SIGKILL || 
            i == SIGUSR1 || i == SIGUSR2 )
             continue;
        signal( i, SIG_IGN );
    }

    /*���ɾ������, ʹ�������ն��ѽ�*/
    /*���ն��ѽں�,scanf�Ⱥ������޷�ʹ��*/
    switch ( fork ( ) ) 
    {
    case 0 : 
        break;
    case -1 :
        exit ( -1 );
    default :
        exit ( 0 );        
    }

    /* Make a back process */
    setpgrp (); 

    if( GetEpayMsgId( ) != SUCC ) 
    {
        WriteLog( ERROR, "��ȡ��Ϣ���б�ʶ��������û�н���ϵͳ��ʼ��" );
        return ( FAIL );
    }

    if( GetEpayShm() != SUCC )
    {
        WriteLog( ERROR, "ӳ�乫�����ݽṹ�����ڴ�ʧ�ܣ�������û�н���ϵͳ��ʼ��" );
        return ( FAIL );
    }

    iRet = GetMasterKey( gszAuthKey );
    if( iRet == FAIL )
    {
        WriteLog( ERROR, "read key fail" );
        return ( FAIL );
    }

    /*��ȡ����ϵͳ����*/
    strcpy( szSectionName, "SECTION_PUBLIC" );
    memset( szTmpBuf, 0, 80 );
    strcpy( szItemName, "EACH_PACK_MAX_BYTES" );
    iRet = ReadConfig( "Setup.ini", szSectionName, szItemName, szTmpBuf );
    if( iRet != SUCC )
    {    
        WriteLog( ERROR, "Setup�������ô���[%s]", szItemName );
        return ( FAIL );
    }
    giEachPackMaxBytes = atoi( szTmpBuf );

    memset( szTmpBuf, 0, 80 );
    strcpy( szItemName, "DISP_MODE" );
    iRet = ReadConfig( "Setup.ini", szSectionName, szItemName, szTmpBuf );
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "Setup�������ô���[%s]", szItemName );
        return ( FAIL );
    }
    giDispMode = atol(szTmpBuf);    

    memset( szTmpBuf, 0, 80 );
    strcpy( szItemName, "ACQUIRER_ID" );
    iRet = ReadConfig( "Setup.ini", szSectionName, szItemName, szTmpBuf );
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "Setup�������ô���[%s]", szItemName );
        return ( FAIL );
    }
    strcpy( gszAcqBankId, szTmpBuf );

    memset( szTmpBuf, 0, 80 );
    strcpy( szItemName, "HOLDER_NAME_MODE" );
    iRet = ReadConfig( "Setup.ini", szSectionName, szItemName, szTmpBuf );
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "Setup�������ô���[%s]", szItemName );
        return ( FAIL );
    }
    giHolderNameMode = atol(szTmpBuf);    

    memset( szTmpBuf, 0, 80 );
    strcpy( szItemName, "MAC_CHK" );
    iRet = ReadConfig( "Setup.ini", szSectionName, szItemName, szTmpBuf );
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "Setup�������ô���[%s]", szItemName );
        return ( FAIL );
    }
    giMacChk = atol(szTmpBuf);

    memset( szTmpBuf, 0, 80 );
    strcpy( szItemName, "TIMEOUT_TDI" );
    iRet = ReadConfig( "Setup.ini", szSectionName, szItemName, szTmpBuf );
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "Setup�������ô���[%s]", szItemName );
        return ( FAIL );
    }
    giTimeoutTdi = atol(szTmpBuf);

    /* ��ʼ��ȡͨѶ���� */
    strcpy( szSectionName, "SECTION_COMMUNICATION" );
    memset( szTmpBuf, 0, 80 );
    strcpy( szItemName, "WEB_IP" );
    iRet = ReadConfig( "Setup.ini", szSectionName, szItemName, szTmpBuf );
    if( iRet != SUCC )
    {    
        WriteLog( ERROR, "Setup�������ô���[%s]", szItemName );
        return ( FAIL );
    }
    strcpy( gszWebIp, szTmpBuf );

    memset(gszWebPort, 0, sizeof(gszWebPort));
    strcpy( szItemName, "WEB_PORT" );
    iRet = ReadConfig( "Setup.ini", szSectionName, szItemName, gszWebPort );
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "Setup�������ô���[%s]", szItemName );
        return ( FAIL );
    }

    memset( szTmpBuf, 0, 80 );
    strcpy( szItemName, "MAX_LINK_NUM" );
    iRet = ReadConfig( "Setup.ini", szSectionName, szItemName, szTmpBuf );
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "Setup�������ô���[%s]", szItemName );
        return ( FAIL );
    }
    iMaxLinkNum = atol(szTmpBuf);    

    signal(SIGUSR1, GracefulExit);

    for( i=0; i<5; i++ )
    {
        iSock = CreateSrvSocket( szSvrPort, SOCK_TCP, 5 );
        if( iSock == FAIL )
        {
            WriteLog( ERROR, "can not open socket[%s] times[%d]!!", szSvrPort, i);
            sleep(30);
        }
        else
        {
            break;
        }
    }
    if( i == 5 )
    {
        WriteLog( ERROR, "can not open socket[%ld]!!", szSvrPort);
        return ( FAIL );
    }
    giSock = iSock;

    while(1)
    {
        WriteLog( TRACE, "tcpcom father[%ld] waiting connect...", getpid() ); 
        iNewSock = SrvAccept( iSock, szIp );
        if( iNewSock < 0 )
        {
            WriteLog( ERROR, "can not open socket!");
            continue;
        }

        /* ���IP��ַ�������� */
        iRet = GetAccessLinkNum( szIp, szSvrPort );
        /* ����ָ��������������Ϊ�쳣���ر����ӣ�֪ͨԭ�д�������˳� */
        if( iRet > iMaxLinkNum )
        {
            while( 1 )
            {
                lPrePid = GetAccessPid( szIp, szSvrPort );
                if( lPrePid <= 0 )
                {
                    break;
                }
                kill(lPrePid, SIGUSR2);
            }
            WriteLog( ERROR, "����[IP:%s PORT:%s]�������쳣���뼰ʱ����", szIp, szSvrPort );
            close( iNewSock );
            continue;
        }

        /*����һ���ӽ��̣����ӽ��̽��н��״��������̼����غ�˿�*/
        lPid = fork();
        switch ( lPid )
        {
        case -1:
            WriteLog(ERROR, "fork error");
            GracefulExit (-2);

        case 0: /*�ӽ��̽��н��״���*/
            for( i = 0; i < 32; i++ )
            {
                if( i == SIGALRM || i == SIGKILL || 
                    i == SIGUSR1 || i == SIGUSR2 )
                     continue;
                signal( i, SIG_IGN );
            }

            /*�ص��̳е�sock����*/
            close( iSock );    

            lChildPid = getpid();

            switch (fork ()) 
            {
            case -1:
                WriteLog(ERROR, "fork error");
                GracefulExit (-2);

            case 0:
                ChildProcess( iNewSock, lChildPid, szIp, szSvrPort );
                break;

            default:

                ParentProcess( iNewSock, lChildPid, szIp, szSvrPort );
                break;
            }
        default: /*�����̼����غ�˿ڣ��ȴ�����*/
            close( iNewSock );    /*�ص�iNewSock����*/
            break;
        }
    }
}

/*******************************************************************************
 * �������ܣ��ػ���socket�˿ڣ��ȴ������ն˷���Ľ������󣬲����в������Ȼ��
 *           ͨ��ACCESS_TO_PROC��Ϣ���з��͸����״���㴦��
 * ���������
 *           iNewSock   -  sock�˿�
 *           lParentPid -  �������̺ţ���Ϊ���״���������㷢��Ӧ��ʱ����Ϣ����
 *           szIp       -  ����IP��ַ
 *           szSrvPort  -  ����˿ں�
 * ���������
 *           ��
 * �� �� ֵ�� 
 *           FAIL  -  ʧ��
 *
 * ��    �ߣ�Robin
 * ��    �ڣ�2012/11/20
 *
 ******************************************************************************/
int ChildProcess( int iNewSock, long lParentPid, char *szIp, char *szSrvPort )
{
    T_App   *ptApp;
    uchar   szRcvBuf[BUFFSIZE], szSndBuf[BUFFSIZE];
    int     iLen, iRet, i, iLenLen;

    for( i = 0; i < 32; i++ )
    {
        if( i == SIGALRM || i == SIGKILL || 
            i == SIGUSR1 || i == SIGUSR2 )
             continue;
        signal( i, SIG_IGN );
    }
    signal(SIGUSR1, GracefulExit);

    if( OpenDB() )
    {
        WriteLog( ERROR, "database fail" );
        exit( 0 );
    }

    WriteLog( TRACE, "tcpcom child child[%ld] ready read sock", getpid() ); 

    iLenLen = 2;
    while (1) 
    {
        memset( szRcvBuf, 0, BUFFSIZE );
        iLen = ReadSockDelLenField( iNewSock, 0, iLenLen, HEX_DATA, szRcvBuf );
        /*��sock����֪ͨ�������˳����Լ��ر�sock��Ҳ�˳�*/
        if( iLen < 0 )
        {
            WriteLog(ERROR, "ReadSock ERROR");
            /* ˯��5���ӣ�ȷ�������̵���sigsetjmp�ɹ� */
            sleep(5);
            kill( lParentPid, SIGUSR2 );
            close( iNewSock );
            CloseDB();
            exit( 0 );
        }
        /*�����������Ļ������Ƿ�����(����绰��ֱ�Ӳ��ţ����������͵������к�����Ϣ*/
        else if( iLen < 50 )
        {
            continue;
        }

        WriteHdLog( szRcvBuf, iLen, "ScriptPos receive from pos" );
        
        /* ���ݱ���ͷ��ȡApp�ṹָ�� */
        ptApp = GetTdiAddress(szRcvBuf, iLen);
        if(ptApp == NULL)
        {
            WriteLog(ERROR, "��ȡApp�ṹָ��ʧ��!");
            WriteHdLog(szRcvBuf, iLen, "ScriptPos receive invalid message from pos");
            continue;
        }

        /*���ն˱��Ľ������ڲ��������ݽṹ*/
        iRet = UnpackScriptPos(ptApp, szRcvBuf, iLen);
        if(iRet == INVALID_PACK)
        {
            WriteLog(ERROR, "invalid pack or get tdi fail");
            WriteHdLog( szRcvBuf, iLen, "ScriptPos receive invalid message from pos" );
            FreeTdi(ptApp->lTransDataIdx);
            continue;
        }
        else if( iRet != SUCC ) 
        {
            /* �����ն�δ�Ǽ�����Ĳ�����󣬼�¼����� */
            if( memcmp(ptApp->szRetCode, ERR_INVALID_TERM, 2) != 0 &&
                memcmp(ptApp->szRetCode, ERR_NEED_DOWN_APP, 2) != 0 &&
                memcmp(ptApp->szRetCode, ERR_DUPLICATE_PSAM_NO, 2) != 0 &&
                memcmp(ptApp->szRetCode, ERR_AUTHCODE, 2) != 0 )
            {
                WriteLog(ERROR, "UnpackScriptPos fail");
                WriteHdLog( szRcvBuf, iLen, "ScriptPos receive invalid message from pos" );
            }

            WriteMoniLog( ptApp, NULL );
            WebDispMoni( ptApp, NULL, gszWebIp, gszWebPort );

            /* ���÷���ָ�� */
            /* �һ� */
            memcpy(ptApp->szCommand, "\xA6", 1);

            /* ��ʾ�����Ϣ */
            memcpy(ptApp->szCommand+1, "\xA2", 1);

            ptApp->iCommandNum = 2;
            ptApp->iCommandLen = 2;

            if(strlen(ptApp->szNextTransCode) == 8)
            {
                GetNextTransCmd(ptApp);
            }

            SendOutToPos(ptApp, iNewSock);

            FreeTdi(ptApp->lTransDataIdx);

            continue;
        }

        /* IP��ַ */
        strcpy(ptApp->szIp, szIp);

        /* ����Ӧ����Ϣ���� ���̺� */
        ptApp->lProcToAccessMsgType = lParentPid;

        /* ������־��¼�İ�ȫģ��� */
        SetEnvTransId(ptApp->szPsamNo);

        /*���ͽ������������Ÿ�����㣬֪ͨ�������н��׺�������*/
        if( SendAccessToProcQue( ptApp->lAccessToProcMsgType, ptApp->lTransDataIdx ) != SUCC )
        {
            WriteLog(ERROR, "send to proc fail");

            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR );

            SendOutToPos(ptApp, iNewSock);

            FreeTdi(ptApp->lTransDataIdx);

            continue;
        }
    }
}

/*******************************************************************************
 * �������ܣ� �ػ���PROC_TO_ACCESS��Ϣ�����У��ȴ����ս���Ӧ�𣬲������������
 *            Ȼ��ͨ��socket���͸��նˡ�
 * ���������
 *            iNewSock  -  sock�˿�
 *            lParentPid-  �������̺ţ���Ϊ���յ���Ϣ����
 *            szIp      -  ����IP��ַ
 *            szSrvPort -  ����˿ں�
 * ���������
 *           ��
 * �� �� ֵ�� 
 *           FAIL  -  ʧ��
 *
 * ��    �ߣ�Robin
 * ��    �ڣ�2012/11/20
 *
 ******************************************************************************/
int ParentProcess( int iNewSock, long lParentPid, char *szIp, char *szSrvPort )
{
    T_App   *ptApp;
    uchar   szSndBuf[BUFFSIZE], szTmpBuf[BUFFSIZE];
    int     iLen, i, iRet;
    long    lMsgType, lTDI;
    T_TERMINAL      tTerm;

    lMsgType = lParentPid;

    for( i = 0; i < 32; i++ )
    {
        if( i == SIGALRM || i == SIGKILL || 
            i == SIGUSR1 || i == SIGUSR2 )
             continue;
        signal( i, SIG_IGN );
    }
    
    if( sigsetjmp(env,1) != 0 )
    {
        WriteLog( ERROR, "receive usr2 and exit" );
        /*ɾ�������ڴ��м�¼�Ľ����pid��*/
        DelAccessPid( lParentPid );
        shutdown( iNewSock, 2 );
        exit( 0 );
    }
    
    signal( SIGUSR2, RecUSR2Proc );

    WriteLog(TRACE, "Parent OpenDB begin..." );
    if( OpenDB() )
    {
        WriteLog( ERROR, "open database fail" );
        exit( 0 );
    }
    WriteLog(TRACE, "Parent OpenDB succ" );

    /* �ǼǱ����̵Ľ��̺� */
    SetAccessPid( szIp, atoi(szSrvPort), lParentPid );
        
    WriteLog(TRACE, "ScriptPos child father[%ld] ready read msg", lMsgType); 
    i = 1;
    while (1) {
        if( RecvProcToAccessQue( lMsgType, 0, &lTDI ) != SUCC ) 
        {
            /*��ֹ��Ϣ���б���ɾ����־����̫�죬����i����������
            ÿ10000�μ�һ�δ�����־*/
            if( i == 1 )
                WriteLog(ERROR, "ScirptPos recv from processing layer fail!");
            i ++;
            if( i == 10000 )
                i = 1;
            continue;
        }
    
        ptApp = GetAppAddress( lTDI );
        if( ptApp == NULL )
        {
            WriteLog( ERROR, "GetApp fail, TDI=%d", lTDI );
            continue;
        }

        WriteAppStru( ptApp, "ScriptPos recv from processing layer" );

        /* �ն˸��½������һ��(���½��֪ͨ)����Ҫ���ظ��նˣ��������ͷ�TDI */
        if( memcmp( ptApp->szTransCode, "FF", 2) == 0 )
        {
            FreeTdi( lTDI );
            continue;
        }

        /* ����ʧ�� */
        if(memcmp(ptApp->szRetCode, TRANS_SUCC, 2) != 0)
        {
            /* ���÷���ָ�� */
            /* �һ� */
            memcpy(ptApp->szCommand, "\xA6", 1);

            /* ��ʾ�����Ϣ */
            memcpy(ptApp->szCommand+1, "\xA2", 1);

            ptApp->iCommandNum = 2;
            ptApp->iCommandLen = 2;
        }

        /* ����ն��Ƿ���Ҫ����TMS */
        if(ChkTmsUpdate(ptApp) != SUCC)
        {
            GetNextTransCmd(ptApp);

            SendOutToPos(ptApp, iNewSock);

            continue;
        }

        /* ����ն��Ƿ���Ҫ����Ӧ�� */
        memset(&tTerm, 0, sizeof(T_TERMINAL));

        if(GetTermRec(ptApp, &tTerm) == SUCC && ChkAppUpdate(ptApp, &tTerm) != SUCC)
        {
            GetNextTransCmd(ptApp);

            SendOutToPos(ptApp, iNewSock);

            continue;
        }

        SendOutToPos(ptApp, iNewSock);

        continue;
    }
}
