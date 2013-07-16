/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�˫��������
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision $
 * $Log: dup_st.c,v $
 * Revision 1.3  2013/06/14 02:02:14  fengw
 *
 * 1�����ӱ�����־��ӡ���롣
 * 2���޸Ķ�����ͨѶ������ơ�
 *
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
    
int giHostId, giCommNum;
static jmp_buf gProEnv;

/* ----------------------------------------------------------------
 * ��    �ܣ����̸����յ����źŽ�����ת
 * ���������
 *         iSigNo    �յ����ź�
 * ���������
 * �� �� ֵ��
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
void ProcessAction( int iSigNo )
{
    WriteLog( TRACE, "recv child signal %d", iSigNo );
    if(iSigNo == SIGUSR1)
        siglongjmp(gProEnv, ExitSig);
    else if( iSigNo == SIGUSR2)
        siglongjmp(gProEnv, ResumeSig);
    return;
}

int main(int argc, char *argv[])
{
    int i, iRet, iPid;
    int iTdi, iInterval;
    long lMsgType;
    char szArgItem[100];
    char szBuffer[MAX_DATA_LENGTH];
  
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

    iRet = SetHost( giHostId, giCommNum, 'Y', 'Y' );
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "SetHost fail");
        exit( 0 );
    }

    signal(SIGUSR1, ProcessAction);

    /* ����jmp��ֵ�����ź� */
    iRet = sigsetjmp(gProEnv, 1);
    if(iRet == ExitSig)
    {
        iRet = SetHost( giHostId, giCommNum, 'N', 'N' );
        exit(0);
    }
    
    lMsgType = giHostId;

    while(1) 
    {
        memset( szBuffer, 0, sizeof( szBuffer ) );

        iRet = RecvProcToPresentQue(lMsgType, 0, &iTdi);
        if(iRet != SUCC)
        {
            sleep(5);

            continue;
        }
        else
        {
            iPid = fork();
            if(iPid == -1)
            {
                 exit(0);
            }
            else if(iPid > 0)
            {
                continue;
            }

            ProcessTrans(szBuffer, iTdi);

            exit(0);
        }
    }
}
 
/* ----------------------------------------------------------------
 * ��    �ܣ�    1������Ϣ�����ж�ȡ����������Ϣ�����ڲ��������ݽṹ
 *  ���ݰ�������ϵͳ�ı��ĸ�ʽת���������͵���Ӧ����ϵͳ��
 *                          2����socket�ж�ȡ����ϵͳ����Ӧ��Ϣ�������󽫸���
 * Ա�����ı���ת�����ڲ��������ݽṹ����������Ӧ��Ϣ��  �ͽ������󷽡�
 * ���������
 *            szBuffer:��Ϣ�����е�����
 *            iTdi:��������
 * ���������
 * �� �� ֵ��
 * ��      �ߣ�
 * ��      �ڣ�
 * ����˵����
 * �޸���־���޸�����      �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int ProcessTrans(char *szBuffer, int iTdi)
{
    int i, iRet, iLength;
    T_App tApp, *ptApp;
    char szRemoteIp[20], szRemotePort[10];
    long lMsgType;
    int iSockId, fd;
    int iTimeout, iShmExpired;
    int iRetTdi;
    char szArgItem[100];

    for( i = 0; i < 32; i++ )
    {
        if( i == SIGALRM || i == SIGKILL || 
            i == SIGUSR1 || i == SIGUSR2 )
             continue;
        signal( i, SIG_IGN );
    }
    
    /*�������ڴ�*/
    ptApp = GetAppAddress(iTdi);
    if( ptApp == NULL )
    {
        WriteLog( ERROR, "GetApp [%d]error", giHostId );
        return FAIL;
    }

    iRet = OpenDB();
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "parent open database fail" );
        return FAIL;
    }

    /*���̨��������*/
    sprintf(szArgItem, "REMOTE_IP_%d", giHostId);
    GetCharParam(szArgItem, szRemoteIp);
    sprintf(szArgItem, "REMOTE_PORT_%d", giHostId);
    GetCharParam(szArgItem, szRemotePort);

    iSockId = CreateCliSocket( szRemoteIp, szRemotePort );
    if(iSockId < 0)
    {
        WriteLog(ERROR, "connect host [%d]err %s", giHostId, strerror(errno));
        /*����������Ӧ��Ϣ������*/
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);
        SendPresentToProcQue( ptApp->lPresentToProcMsgType, iTdi );
        return FAIL;
    }

    /*���ڲ��������ݽṹ����ת���ɺ�̨����*/
    iLength = PackageRequest(ptApp, szBuffer);
    if( iLength < 0 )
    {
        WriteLog( ERROR, "pack Host[%03d] fail", giHostId );
        close(iSockId);
        /*����������Ӧ��Ϣ������*/
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);
        SendPresentToProcQue( ptApp->lPresentToProcMsgType, iTdi );
        return FAIL;
    }

    WriteHdLog(szBuffer, iLength, "send to host");

    iRet = WriteSock( iSockId, szBuffer, iLength, 0 );
    if ( iRet <= 0 )
    {
        WriteLog( ERROR, "Host[%03d][%d] write idle pack errno[%ld]", giHostId, giCommNum, errno );
        close(iSockId);
        /*����������Ӧ��Ϣ������*/
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);
        SendPresentToProcQue( ptApp->lPresentToProcMsgType, iTdi );
        return FAIL;
    }

    /* ���ͽ�������ɹ�����¼pid_match�� */
    iRet = SetTdiMatch( iTdi, ptApp->szShopNo, ptApp->szPosNo, ptApp->lSysTrace ,ptApp->iTransType);
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "insert pid_match fail" );
        close(iSockId);
        return FAIL;
    }
   
    sprintf(szArgItem, "REMOTE_TIMEOUT_%d", giHostId);
    GetIntParam(szArgItem, iTimeout);
    GetIntParam("ShmExpired", iShmExpired);
    iLength = ReadSockVarLen(iSockId, iTimeout, szBuffer);
    if( iLength <= 0 )
    {
        WriteLog( ERROR, "read length fail %ld, nLength=[%d]", errno, iLength );
        close(iSockId);
        /*��ѯƥ���¼*/
        iRetTdi = GetTdiMatch(ptApp->szShopNo, ptApp->szPosNo, ptApp->lSysTrace, iShmExpired,ptApp->iTransType);
        if( iRetTdi == FAIL || iRetTdi != iTdi)
        {
            WriteLog( ERROR, "GetTdiMatch [%d]error", giHostId );
            return FAIL;
        }
        /*����������Ӧ��Ϣ������*/
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);
        SendPresentToProcQue( ptApp->lPresentToProcMsgType, iTdi );
        WriteLog( ERROR, "time out begin return" );
        return FAIL;
    }

    WriteHdLog(szBuffer, iLength, "recv from host");
            
    /*�����ݰ� */
    iRet = UnpackageRespond(ptApp, szBuffer, iLength);
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "Unpack Host[%03ld] error", giHostId );
        close(iSockId);
        /*��ѯƥ���¼*/
        iRetTdi = GetTdiMatch(ptApp->szShopNo, ptApp->szPosNo, ptApp->lSysTrace, iShmExpired,ptApp->iTransType);
        if( iRetTdi == FAIL || iRetTdi != iTdi)
        {
            WriteLog( ERROR, "GetTdiMatch [%d]error", giHostId );
            return FAIL;
        }
        /*����������Ӧ��Ϣ������*/
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);
        SendPresentToProcQue( ptApp->lPresentToProcMsgType, iTdi );
        return FAIL;    
    }

    /*��ѯƥ���¼*/
    iRetTdi = GetTdiMatch(ptApp->szShopNo, ptApp->szPosNo, ptApp->lSysTrace, iShmExpired,ptApp->iTransType);
    if( iRetTdi == FAIL || iRetTdi != iTdi)
    {
        WriteLog( ERROR, "GetTdiMatch [%d]error", giHostId );
        close(iSockId);
        return FAIL;
    }

    /*������Ӧ��Ϣ�����׷������*/
    iRet = SendPresentToProcQue(ptApp->lPresentToProcMsgType, iTdi);
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "SendPresentToProcQue[%03ld] error", giHostId );
        close(iSockId);
        return FAIL;
    }

    close(iSockId);
    return SUCC;
}

/* ----------------------------------------------------------------
 * ��    �ܣ�   ��������ϵͳ�ı��ĸ�ʽ����������
 * ���������
 * ���������
 * �� �� ֵ��
 * ��      �ߣ�
 * ��      �ڣ�
 * ����˵����
 * �޸���־���޸�����      �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int ProcessHB()
{
    int i, iRet, iLength;
    T_App tApp, *ptApp;
    char szRemoteIp[20], szRemotePort[10];
    long lMsgType, iTdi;
    int iSockId, fd;
    int iTimeout;
    int iRetTdi;
    char szArgItem[100];
    char szBuffer[MAX_DATA_LENGTH];

    for( i = 0; i < 32; i++ )
    {
        if( i == SIGALRM || i == SIGKILL || 
            i == SIGUSR1 || i == SIGUSR2 )
             continue;
        signal( i, SIG_IGN );
    }
    
    /*���̨��������*/
    sprintf(szArgItem, "REMOTE_IP_%d", giHostId);
    GetCharParam(szArgItem, szRemoteIp);
    sprintf(szArgItem, "REMOTE_PORT_%d", giHostId);
    GetCharParam(szArgItem, szRemotePort);
    iSockId = CreateCliSocket( szRemoteIp, szRemotePort );
    if(iSockId < 0)
    {
        return FAIL;
    }
    
    iLength = PackHB(szBuffer);            
    if( iLength < 0 )
    {
        close(iSockId);
        return FAIL;
    }
    iRet = WriteSock( iSockId, szBuffer, iLength, 0 );
    if ( iRet <= 0 )
    {
        close(iSockId);
        return FAIL;
    }

       close(iSockId);
    return SUCC;
}
