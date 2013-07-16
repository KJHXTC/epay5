/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�����������
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision $
 * $Log: dup_lt.c,v $
 * Revision 1.2  2012/12/11 07:16:20  linxiang
 * *** empty log message ***
 *
 * Revision 1.1  2012/12/10 01:19:21  linxiang
 * *** empty log message ***
 *
 * ----------------------------------------------------------------
 */

#include "tohost.h"

#define CP_APP_CHAR(dp, sp, f) \
    do{\
        strncpy((dp)->f, (sp)->f, sizeof((dp)->f) - 1);\
    }while(0)
    
enum eActAfterSig { ExitSig = 1, ResumeSig};
static const MAX_DATA_LENGTH = 1024;

#define FIFO_WAKEUP_C "/tmp/sig_lt.wakeup_c.fifo"
#define FIFO_WAKEUP_P "/tmp/sig_lt.wakeup_p.fifo"

static jmp_buf gSrvEnv, gCltEnv;

int giHostId, giCommNum;
int giSockId;

void ChildProc();
void ParentProc();

/* ----------------------------------------------------------------
 * ��    �ܣ������̸����յ����ӽ��̷������źŽ�����ת
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
void ParentAction( int iSigNo )
{    
    WriteLog( TRACE, "recv child signal %d", iSigNo );
    if(iSigNo == SIGUSR1)
        siglongjmp(gSrvEnv, ExitSig);
    else if( iSigNo == SIGUSR2)
        siglongjmp(gSrvEnv, ResumeSig);
    return;
}

/* ----------------------------------------------------------------
 * ��    �ܣ��ӽ��̸����յ��ĸ����̷������źŽ�����ת
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
void ChildAction( int iSigNo )
{    
    WriteLog( TRACE, "recv parent signal %d", iSigNo );
    if(iSigNo == SIGUSR1)
        siglongjmp(gCltEnv, ExitSig);
    else if( iSigNo == SIGUSR2)
        siglongjmp(gCltEnv, ResumeSig);
    return;
}

int main(int argc, char *argv[])
{
    int i, iRet, iChildPid;
    char szRemoteIp[20], szRemotePort[10];
    char szArgItem[100];

    if(argc != 3)
    {
        printf("usage: to_host host_id comm_num\n");
        exit(0);
    }
    giHostId = atoi(argv[1]);
    giCommNum = atoi(argv[2]);
    if(giHostId <= 0 || giCommNum <= 0)
    {
        printf("host_id��comm_num�������0\n");
        exit(0);
    }
    
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

    iRet = SetHost( giHostId, giCommNum, 'N', 'N' );
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "SetHost fail");
        exit( 0 );
    }
    
    while( 1 )
    {
        if(access(FIFO_WAKEUP_C, F_OK) == 0)
            unlink(FIFO_WAKEUP_C);
        if(mkfifo(FIFO_WAKEUP_C, O_CREAT|O_EXCL) < 0)
        {
            WriteLog(ERROR, "mkfifo err %d %d", errno, strerror(errno));
            exit(0);
        }
        /*���̨��������*/
        sprintf(szArgItem, "REMOTE_IP_%d", giHostId);
        GetCharParam(szArgItem, szRemoteIp);
        sprintf(szArgItem, "REMOTE_PORT_%d", giHostId);
        GetCharParam(szArgItem, szRemotePort);
        while(1)
        {
            giSockId = CreateCliSocket( szRemoteIp, szRemotePort );
            if(giSockId > 0)
                break;            
            sleep(5);
        }
        iRet = SetHost( giHostId, giCommNum, 'Y', 'Y' );
        if( iRet != SUCC )
        {
            WriteLog( ERROR, "SetHost fail");
            exit( 0 );
        }
        
        iChildPid = fork( );
        switch( iChildPid ){
        case  -1:
            close(giSockId);
            WriteLog( ERROR, "fork error!!!" );
            exit( -1 );
        case   0:
            /*�ӽ��̴���*/
            ChildProc();
            exit(0);
        default:
            /*�����̴���*/
            ParentProc( iChildPid );
            sleep(60);
            break;
        }
    }
}
 
/* ----------------------------------------------------------------
 * ��    �ܣ�    �ӽ��̸����socket�ж�ȡ����ϵͳ����Ӧ��Ϣ�������󽫸���
 * Ա�����ı���ת�����ڲ��������ݽṹ����������Ӧ��Ϣ��  �ͽ������󷽡�
 * ���������
 * ���������
 * �� �� ֵ��
 * ��      �ߣ�
 * ��      �ڣ�
 * ����˵����
 * �޸���־���޸�����      �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
void ChildProc()
{
    int i, iParentPid, iLength, iRet;
    unsigned char szReadData[MAX_DATA_LENGTH];
    T_App tApp, *ptApp;
    int iSockId, iNewSockId, fd;
    char szCltIp[20], szLocalPort[10], szArgItem[100];
    int iInterval, iShmExpired;
    int iTdi;
    
    for( i = 0; i < 32; i++ )
    {
        if( i == SIGALRM || i == SIGKILL || 
            i == SIGUSR1 || i == SIGUSR2 )
             continue;
        signal( i, SIG_IGN );
    }
    signal( SIGUSR1, ChildAction );
    signal( SIGUSR2, ChildAction );

    iParentPid = getppid();

    /* �ӽ��̵ȴ������̵�ͬ���źź��������ݿ⣬��ֹ�븸����ͬʱȥ����*/
    /* ͬʱȥ���ᵼ�¸������������ݿ������ϣ���֪ʲôԭ�� */
    fd = open(FIFO_WAKEUP_C, O_RDONLY, 0);
    read(fd, szReadData, 16);
    close(fd);
    
    if(OpenDB() != SUCC)
    {
        WriteLog(ERROR, "child open database fail");
        kill(iParentPid, SIGUSR2);
        return;
    }

    /* ����jmp��ֵ�����ź� */
    iRet = sigsetjmp(gCltEnv, 1);
    if(iRet == ExitSig)
    {
        close(giSockId);
        CloseDB();
        return;
    }
    sprintf(szArgItem, "HBInterval_%d", giHostId);
    GetIntParam(szArgItem, iInterval);
    GetIntParam("ShmExpired", iShmExpired);
    do{
        iLength = ReadSockVarLen(iNewSockId, iInterval, szReadData);
        /*�����ݳ����ʱ���ر�sock����֪ͨ�������˳�*/
        if( iLength <= 0 )
        {
            WriteLog( ERROR, "read length fail %ld, nLength=[%d]", errno, iLength );
            close( giSockId );
        
            /*�򸸽��̷�����Ϣ��֪ͨ�������˳�*/
            kill( iParentPid, SIGUSR1 );

            /*����������״̬��־��Ϊ"N" */
            SetHost( giHostId, giCommNum, 'N', 'N' );

            CloseDB();
            return;
        }
        /* �������������ʱ�䣬Ҫ�ж��Ƿ������� */
        if(iInterval != 0)
        {
            if(CheckWhetherHB(szReadData) == SUCC)
                continue;
        }

        /*�����ݰ� */
        iRet = UnpackRsp(szReadData, iLength, &tApp );
        if( iRet != SUCC )
        {
            WriteLog( ERROR, "Unpack Host[%03ld] error", giHostId );
            continue;
        }
        /*��ѯƥ���¼*/
        iTdi = GetTdiMatch(tApp.szShopNo, tApp.szPosNo, tApp.lSysTrace, iShmExpired,tApp.iTransType);
        if( iTdi == FAIL )
        {
            WriteLog( ERROR, "GetTdiMatch [%d]error", giHostId );
            continue;
        }
        /*�������ڴ�*/
        ptApp = GetAppAddress(iTdi);
        if( ptApp == NULL )
        {
            WriteLog( ERROR, "GetApp [%d]error", giHostId );
            continue;
        }
        /*�޸Ĺ����ڴ�*/
        CP_APP_CHAR(ptApp, &tApp, szRetriRefNum);
        CP_APP_CHAR(ptApp, &tApp, szAuthCode);
        CP_APP_CHAR(ptApp, &tApp, szHostRetCode);
        CP_APP_CHAR(ptApp, &tApp, szHostRetMsg);
        
        /*������Ӧ��Ϣ�����׷������*/
        iRet = SendPresentToProcQue(ptApp->lPresentToProcMsgType, iTdi);
        if( iRet != SUCC )
        {
            WriteLog( ERROR, "SendPresentToProcQue[%03ld] error", giHostId );
            continue;
        }
    }while( 1 );
}

 /* ----------------------------------------------------------------
 * ��    �ܣ�    �����̸������Ϣ�����ж�ȡ����������Ϣ�����ڲ��������ݽṹ
 *  ���ݰ�������ϵͳ�ı��ĸ�ʽת���������͵���Ӧ����ϵͳ��
 * ���������
 *            iChildPid    �ӽ���PID
 * ���������
 * �� �� ֵ��
 * ��      �ߣ�
 * ��      �ڣ�
 * ����˵����
 * �޸���־���޸�����      �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
void ParentProc( int iChildPid )
{
    int i, iRet, iLength;
    T_App tApp, *ptApp;
    char szRemoteIp[20], szRemotePort[10];
    long lMsgType;
    int fd, iInterval, iTdi;
    unsigned char szBuffer[MAX_DATA_LENGTH];
    char szArgItem[100];

    for( i = 0; i < 32; i++ )
    {
        if( i == SIGALRM || i == SIGKILL || 
            i == SIGUSR1 || i == SIGUSR2 )
             continue;
        signal( i, SIG_IGN );
    }
    signal( SIGUSR1, ParentAction );
    signal( SIGUSR2, ParentAction );

    /*�������ݿ�����ӽ���ͬ��*/
    iRet = OpenDB();
    fd = open(FIFO_WAKEUP_C, O_WRONLY|O_NONBLOCK, 0);
    write(fd, "0000", 4);
    close(fd);
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "parent open database fail" );
        exit( 0 );
    }
    
    iRet = sigsetjmp(gSrvEnv, 1);
    if(iRet == ExitSig)
    {
        SetHost( giHostId, giCommNum, 'N', 'N' );
        close(giSockId);
        CloseDB();
        return;
    }
    
    lMsgType = giHostId;
    sprintf(szArgItem, "HBInterval_%d", giHostId);
    GetIntParam(szArgItem, iInterval);
    do{
        memset( szBuffer, 0, sizeof( szBuffer ) );

        iRet = RecvProcToPresentQue(lMsgType, iInterval, &iTdi);
        /* ����iInterval�룬���Ϳ��б��ĸ���̨ϵͳ */
        if( iRet == TIMEOUT )
        {
            iLength = PackHB(szBuffer);
            iRet = WriteSock( giSockId, szBuffer, iLength, 0 );
            if ( iRet <= 0 )
            {
                close( giSockId );
                WriteLog( ERROR, "Host[%03d][%d] write idle pack errno[%ld]", giHostId, giCommNum, errno );

                /* ֪ͨ�ӽ����˳������������½������� */    
                kill( iChildPid, SIGUSR1 );

                CloseDB();
                SetHost( giHostId, giCommNum, 'N', 'N' );
                return;
            }
            continue;
        }
        else if( iRet != SUCC )
        {
            WriteLog (ERROR, "Read from ToHost error");
             continue;
        }


        /*�������ڴ�*/
        ptApp = GetAppAddress(iTdi);
        if( ptApp == NULL )
        {
            WriteLog( ERROR, "GetApp [%d]error", giHostId );
            continue;
        }        
        /*���ڲ��������ݽṹ����ת���ɺ�̨����*/
        iLength = PackageRequest(ptApp, szBuffer);
        if( iLength < 0 ){
            WriteLog( ERROR, "pack Host[%03d] fail", giHostId );
            /*����������Ӧ��Ϣ������*/
            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);
            SendPresentToProcQue( ptApp->lPresentToProcMsgType, iTdi );
            continue;
        }

        iRet = WriteSock( giSockId, szBuffer, iLength, 0 );
        if ( iRet <= 0 )
        {
            close( giSockId );
            WriteLog( ERROR, "Host[%03d][%d] write idle pack errno[%ld]", giHostId, giCommNum, errno );
            /* ֪ͨ�ӽ����˳������������½������� */    
            kill( iChildPid, SIGUSR2 );

            /*����������Ӧ��Ϣ������*/
            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);
            SendPresentToProcQue( ptApp->lPresentToProcMsgType, iTdi );
            
            CloseDB();
            SetHost( giHostId, giCommNum, 'N', 'N' );
            return;
        }

        /* ���ͽ�������ɹ�����¼pid_match�� */
        iRet = SetTdiMatch( iTdi, ptApp->szShopNo, ptApp->szPosNo, ptApp->lSysTrace, ptApp->iTransType );
        if( iRet != SUCC )
        {
            WriteLog( ERROR, "insert pid_match fail" );
        }
    }while( 1 );
}
