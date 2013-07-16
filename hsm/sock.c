/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:���ܻ�socketͨѶ�ӿ�
           
** �� �� ��:Robin 
** ��������:2009/08/29


$Revision: 1.12 $
$Log: sock.c,v $
Revision 1.12  2012/12/26 01:44:17  wukj
%s/commu_with_hsm/CommuWithHsm/g

Revision 1.11  2012/12/05 06:32:14  wukj
*** empty log message ***

Revision 1.10  2012/12/03 03:24:46  wukj
int����ǰ׺�޸�Ϊi

Revision 1.9  2012/11/29 07:51:43  wukj
�޸���־����,�޸�ascbcdת������

Revision 1.8  2012/11/29 01:57:55  wukj
��־�����޸�

Revision 1.7  2012/11/21 04:13:38  wukj
�޸�hsmincl.h Ϊhsm.h

Revision 1.6  2012/11/21 03:20:31  wukj
1:���ܻ����������޸� 2: ȫ�ֱ�������hsmincl.h


*******************************************************************/

#include "hsm.h"

int CreateSockClient(char *szIpAddr,int iPort);
int CloseSocket(int iSckId);
int SendToSocket(int iSckId,unsigned char *uszBuf,int iLen);
int ReceiveFromSocket(int iFd,char *uszBuf,int iLen);

extern int  giSockFd;

/*****************************************************************
** ��    ��:��������ܻ�ͨѶsock
** �������:
           szIp
           iPort
** �������:
** �� �� ֵ:
           ���ش�����sock���
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int CreateSockClient(char *szIp, int iPort)
{
    struct     sockaddr_in tSockAddrIn;
    int        iSockCli, iOn=1, iLen;
    struct     linger    tLinger;

    memset((char *)(&tSockAddrIn),'0',sizeof(struct sockaddr_in));
    tSockAddrIn.sin_family = AF_INET;
    tSockAddrIn.sin_addr.s_addr = inet_addr(szIp);
    tSockAddrIn.sin_port = htons((u_short)iPort);

    if( (iSockCli = socket(AF_INET, SOCK_STREAM, 0)) == INVALID_SOCKET )
    {
         WriteLog( ERROR, "can not open stream socket" );
         return( INVALID_SOCKET );
    }

    iLen = sizeof( struct sockaddr_in );
    if( connect(iSockCli, (struct sockaddr *)(&tSockAddrIn), iLen) < 0 )
    {
        WriteLog( ERROR, "cannot connect to hsm! hsm_ip = [%s] iPort = [%d] errno[%d]", szIp, iPort, errno );
        CloseSocket(iSockCli);
        return(INVALID_SOCKET);
    }

    tLinger.l_onoff = 1;
    tLinger.l_linger = 0;
    if( setsockopt(iSockCli,SOL_SOCKET,SO_LINGER,(char *)&tLinger,sizeof(tLinger)) != 0) 
    {
        WriteLog( ERROR, "setsockopt linger!" );
        CloseSocket(iSockCli);
        return(INVALID_SOCKET);
    }
    if (setsockopt(iSockCli, SOL_SOCKET, SO_OOBINLINE, (char *)&iOn, sizeof(iOn)))
    {
        WriteLog( ERROR, "setsockopt SO_OOBINLINE!");
        return(INVALID_SOCKET);
    }
    iOn = 1;
    if (setsockopt(iSockCli, IPPROTO_TCP, TCP_NODELAY, (char *)&iOn, sizeof(iOn)))
    {
        WriteLog( ERROR, "setsockopt: TCP_NODELAY");
        return(INVALID_SOCKET);
    }

    return(iSockCli);
}

/*****************************************************************
** ��    ��:����Ӳ�����ܻ�
** �������:
           szIp
           iPort
** �������:
           ���ش�����sock���
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int ConnectHsm( char *szIp, int iPort )
{
    unsigned char uszBuffer[512];
    int iRet, iTimes, iSock;
    
    WriteLog( TRACE, "connect hsm ip[%s] iPort[%d] begin", szIp, iPort );
    iTimes = 1;
    do
    {
        iSock = CreateSockClient( szIp, iPort );
        if( iSock < 0 )
        {
            if( iTimes%10 == 1 )
            {
                WriteLog( ERROR, "connect hsm ip[%s] iPort[%d] fail times[%d]", szIp, iPort, iTimes );
            }
            sleep( 5 );
        }
        iTimes++;
    }while( iSock < 0 );
    
    WriteLog( TRACE, "connect hsm ip[%s] iPort[%d] succ", szIp, iPort );

    return ( iSock );
}

int CloseSocket(int iSockFd)
{
    if (close(iSockFd) != 0)
    {
        WriteLog( ERROR, "close client connection error!\n");
    }

    return( SUCC );
}

/*****************************************************************
** ��    ��: ���׽ӿ�������Ϣ��
** �������:
           Sockfd      �׽ӿھ��  
           szSendBuf   ���д���׽ӿ���Ϣ�Ļ�����  
           iLen        ��Ϣ�ĳ���
** �������:
           ��
** �� �� ֵ:
           ʵ���ͳ��ĳ���, ��ֵ<0˵�����ݷ���ʧ��   | 
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int WriteToHsmSock( iSockFd, szSendBuf, iLen )
int iSockFd;
unsigned char *szSendBuf;
int iLen;
{
        int i;
        unsigned char szTcpBuf[1024];

        memset( szTcpBuf, 0, 1024);
        szTcpBuf[0] = iLen/256;
        szTcpBuf[1] = iLen%256;

        memcpy( szTcpBuf+2, szSendBuf, iLen );

        i = write( iSockFd, szTcpBuf, iLen+2 );

        return (i-2);
}

/*****************************************************************
** ��    ��:  ���׽ӿ��ж�ȡ��Ϣ�����г�ʱ���� 
** �������:
           iSockFd      �׽ӿھ��    
           szRecvBuf    ������Ϣ��ŵĻ�����   
           iTimeOut      ��ʱʱ��
** �������:
           ��
** �� �� ֵ:
           ʵ�ʶ����ĳ��� ������ֵ<0˵�����׽ӿ�ʧ��  
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int  ReadFromHsmSock( iSockFd, szRecvBuf, iTimeOut )
int  iSockFd;
unsigned char *szRecvBuf;
int iTimeOut;
{
    int iLen;
    int i, n;
    unsigned char szTmpBuf[1024];

    memset( szTmpBuf, 0, 1024 );

    n = ReadSockFixLen(iSockFd,iTimeOut,2,szTmpBuf);
    if( n != 2 )
    {
        WriteLog( ERROR, "read length iTimeOut[%d] errno[%ld]", n, errno );
        return FAIL;
    }

    iLen = szTmpBuf[0]*256+szTmpBuf[1];

    n = ReadSockFixLen(iSockFd,3,iLen,szTmpBuf);
    if( n != iLen )
    {
        WriteLog( ERROR, "read sock data fail %d", n );
        return FAIL;
    }

    memcpy( szRecvBuf, szTmpBuf, iLen );
    return ( iLen );
}

/*****************************************************************
** ��    ��: ����ܻ�����������,�����ܼ��ܻ���Ӧ����
** �������:
            uszIn          ������
            iLen           �����ĳ���
            uszOut          ��Ӧ����
** �������:
           ��
** �� �� ֵ:
           ʵ�ʶ����ĳ��� ������ֵ<0˵�����׽ӿ�ʧ��  
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int CommuWithHsm( unsigned char *uszIn, int iLen, unsigned char *uszOut )
{
    int iRetVal, iTimeOut;

    iTimeOut = 3;

    iRetVal = WriteToHsmSock( giSockFd, uszIn, iLen);
    if( iRetVal != iLen )
    {
        CloseSocket( giSockFd );
        WriteLog( ERROR, "send to hsm fail" );
        return FAIL;
    }

    iRetVal = ReadFromHsmSock( giSockFd, uszOut, iTimeOut );
    if( iRetVal == FAIL )
    {
        CloseSocket( giSockFd );
        WriteLog( ERROR, "read from hsm fail" );
        return FAIL;
    }

    return iRetVal;
}


/*****************************************************************
** ��    ��:дsjl05���ܻ�ͨѶsocket�ӿ�
** �������:
           iFd
           uszBuf
           iLen
** �������:
           ��
** �� �� ֵ:
           
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int SendToSocket(int iFd, unsigned char *uszBuf, int iLen)
{
    if( send(iFd,uszBuf,iLen,0) != iLen )
    {
        WriteLog( ERROR, "send to sjl05 hsm fail %d", errno);
        return( FAIL );
    }

    return(iLen);
}
/*****************************************************************
** ��    ��:��sjl05���ܻ�ͨѶsocket�ӿ�
** �������:
           iFd
           uszBuf
           iLen
** �������:
           ��
** �� �� ֵ:
           
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int ReceiveFromSocket(int iFd, char *uszBuf, int iLen)
{
    int iRet;

    iRet = recv(iFd, uszBuf, iLen, 0);
    if( iRet < 0 ) 
    {
        WriteLog( ERROR, "receive from sjl05 hsm fail! errno = [%d]",errno);
        return( FAIL );
    }

    return(iRet);
}

/*****************************************************************
** ��    ��:sjl05���ܻ�ͨѶ
** �������:
           uszIn         	������
           iLen                 �����ĳ���
           uszOut               ��Ӧ����
** �������:
           ��
** �� �� ֵ:
          SUCC   --�ɹ�
          FAIL   --ʧ��
           
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int CommuWithSjl05hsm( unsigned char *uszIn, int iLen, unsigned char *uszOut )
{
    int iRetVal;

    iRetVal = SendToSocket( giSockFd, uszIn, iLen);
    if( iRetVal != iLen )
    {
        CloseSocket( giSockFd );
        WriteLog( ERROR, "send to hsm fail" );
        return FAIL;
    }

    iRetVal = ReceiveFromSocket( giSockFd, uszOut, 200 );
    if( iRetVal < 0 )
    {
        CloseSocket( giSockFd );
        WriteLog( ERROR, "send to hsm fail" );
        return FAIL;
    }

    return SUCC;
}
