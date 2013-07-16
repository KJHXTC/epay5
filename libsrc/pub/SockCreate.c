
/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ������������׽ӿ�
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision: 1.10 $
 * $Log: SockCreate.c,v $
 * Revision 1.10  2013/02/19 03:12:43  linqil
 * ���Ӵ�����־��ӡ
 *
 * Revision 1.9  2013/02/19 03:11:04  linqil
 * ���Ӵ�����־��ӡ
 *
 * Revision 1.8  2012/12/04 07:22:02  chenjr
 * ����淶��
 *
 * Revision 1.7  2012/11/29 02:15:35  linqil
 * �޸�WriteETLogΪWriteLog
 *
 * Revision 1.6  2012/11/28 08:25:44  linqil
 * ȥ������ͷ�ļ�user.h
 *
 * Revision 1.5  2012/11/28 02:58:33  linqil
 * �޸���־����
 *
 * Revision 1.4  2012/11/27 08:26:17  yezt
 * *** empty log message ***
 *
 * Revision 1.3  2012/11/27 08:21:01  linqil
 * �޸���־����
 *
 * Revision 1.2  2012/11/27 06:33:02  linqil
 * ��������pub.h �޸�return �޸��ж�����`
 *
 * Revision 1.1  2012/11/20 03:27:37  chenjr
 * init
 *
 * ----------------------------------------------------------------
 */

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

#include "pub.h"

/* ----------------------------------------------------------------
 * ��    �ܣ� ����sock�ͻ�������
 * ���������
 *            szSrv       IP��ַ
 *            szSrvPort   �˿ں� 
 * ��������� ��
 * �� �� ֵ��FAIL   ʧ��/iFd         �׽���������
 * ��    �ߣ�
 * ��    �ڣ�2012/11/27
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int CreateCliSocket(char *szSrv, char *szSrvPort)
{
    int iFd;
    int iRet;
    struct sockaddr_in srv_addr, cli_addr;
    struct hostent     *ptHost;

    if (szSrv == NULL || szSrvPort == NULL)
    {
        WriteLog(ERROR, "PARAMETER ILLEGAL!");
        return FAIL;
    }

    memset((char*)&srv_addr, 0, sizeof(srv_addr));
    srv_addr.sin_family = AF_INET;   /* IPV4 */
    srv_addr.sin_addr.s_addr = htonl(INADDR_ANY);

    srv_addr.sin_port = htons(atoi(szSrvPort));
    if (srv_addr.sin_port == 0)
    {
        WriteLog(ERROR, "set sin_port fail[%d-%s], szSrvPort[%d]"
                , errno, strerror(errno), szSrvPort);        
        return FAIL;
    }

    ptHost = gethostbyname(szSrv);
    if (ptHost)
    {
        memcpy(&srv_addr.sin_addr, ptHost->h_addr, ptHost->h_length);
    }
    else if ((srv_addr.sin_addr.s_addr = inet_addr(szSrv)) == INADDR_NONE)
    {
        WriteLog(ERROR, "set sin_addr.s_addr fail[%d-%s], szSrv[%d]"
                 , errno, strerror(errno), szSrv);
        return FAIL;
    }

    iFd = socket(AF_INET, SOCK_STREAM, 0);
    if (iFd < 0)
    {
        WriteLog(ERROR, "call socket fail[%d-%s]", errno, 
                strerror(errno));
        return FAIL;
    }

    iRet = connect(iFd, (struct sockaddr*)&srv_addr, sizeof(srv_addr));
    if (iRet < 0)
    {
        WriteLog(ERROR, "call connect fail[%d-%s]", errno, 
                strerror(errno));
        close(iFd);
        return FAIL;
    }

    return iFd;
}


/* ----------------------------------------------------------------
 * ��    �ܣ�����sock������������
 * ���������
 *            szSrvPort   �˿ں� 
 *            szSrvType   ͨ��Э���Э����
 *            iQueLen     �����ͻ��˵�������
 * ��������� ��
 * �� �� ֵ�� FAIL    ʧ��/iSockFd       �׽��ֵ�������
 * ��    �ߣ�
 * ��    �ڣ� 2012/11/27
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int CreateSrvSocket(char *szSrvPort, char *szSrvType, int iQueLen)
{
    int iSockFd, iType;
    int iRet;
    struct sockaddr_in   srv_addr;

    if (szSrvPort == NULL || szSrvType == NULL || iQueLen  <= 0)
    {
        WriteLog(ERROR, "PARAMETER ILLEGAL!");
        return FAIL;
    }
 
    memset((char*)&srv_addr, 0, sizeof(srv_addr));
    srv_addr.sin_family  =AF_INET;
    srv_addr.sin_addr.s_addr = htonl(INADDR_ANY);

    srv_addr.sin_port = htons(atoi(szSrvPort));
    if (srv_addr.sin_port == 0)
    {
        WriteLog(ERROR, "set sin_port fail[%d-%s], szSrvPort[%d]"
                 , errno, strerror(errno), szSrvPort);
        return FAIL;
    }

    if (memcmp(szSrvType, "udp", 3) == 0)
    {
        iType = SOCK_DGRAM;
    }
    else
    {
        iType = SOCK_STREAM;
    }
   
    iSockFd = socket(AF_INET, iType, 0);
    if (iSockFd < 0)
    {
        WriteLog(ERROR, "call socket fail[%d-%s]", errno, strerror(errno));
        return FAIL;
    }

    iRet = bind(iSockFd, (struct sockaddr*)&srv_addr, sizeof(srv_addr));
    if (iRet < 0)
    {
        WriteLog(ERROR, "call bind fail[%d-%s]", errno, strerror(errno));
        close(iSockFd);
        return FAIL;
    }

    iRet = listen(iSockFd, iQueLen);
    if ((iType == SOCK_STREAM) && (iRet < 0))
    {
        WriteLog(ERROR, "call listen fail[%d-%s]", errno, 
                strerror(errno));
        close(iSockFd);
        return FAIL;
    }

    return iSockFd;
}


/* ----------------------------------------------------------------
 * ��    �ܣ�����ָ���׽�����������Ӧ������
 * ���������iLisSock    �׽���������
 * ���������szCliIp     ��ַ
 * �� �� ֵ��FAIL  ʧ��/iSock  �µ��׽���������
 * ��    �ߣ�
 * ��    �ڣ�2012/11/27
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int SrvAccept(int iLisSock, char *szCliIp)
{
    int  iSock, iCliLen;
    struct sockaddr_in cli_addr;

    if (iLisSock <= 0 || szCliIp == NULL)
    {
        return FAIL;
    }

    iCliLen = sizeof(cli_addr);
    while (1)
    {
        memset((char*)&cli_addr, 0, iCliLen);
        
        iSock = accept(iLisSock, (struct sockaddr*)&cli_addr, &iCliLen);
        if (iSock < 0)
        {
            if (errno == EINTR)
            {
                continue;
            }
            else
            {
                WriteLog(ERROR, "accept error[%d-%s]", errno, strerror(errno));
                return FAIL;
            }
        }

        break;
    }

    strcpy(szCliIp, inet_ntoa(cli_addr.sin_addr));
    return iSock;
}
