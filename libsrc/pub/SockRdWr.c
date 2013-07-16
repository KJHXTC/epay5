
/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ��׽ӿڶ�д
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision: 1.8 $
 * $Log: SockRdWr.c,v $
 * Revision 1.8  2013/06/14 06:25:28  fengw
 *
 * 1��SendToUdpSrv��������setsockopt���ô��롣
 *
 * Revision 1.7  2012/12/21 05:44:01  chenrb
 * *** empty log message ***
 *
 * Revision 1.6  2012/12/04 07:24:05  chenjr
 * ����淶��
 *
 * Revision 1.5  2012/11/29 02:15:35  linqil
 * �޸�WriteETLogΪWriteLog
 *
 * Revision 1.4  2012/11/28 08:25:44  linqil
 * ȥ������ͷ�ļ�user.h
 *
 * Revision 1.3  2012/11/28 02:58:33  linqil
 * �޸���־����
 *
 * Revision 1.2  2012/11/27 06:42:35  linqil
 * ���Ӷ�pub.h�����ã��޸�return�����������ж����
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
#include <signal.h>
#include <setjmp.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

#include "pub.h"
#include "user.h"

/* �䳤��ȡ����󳤶� */
#define VARLENFORREAD   1024
#define RDSOCKTIMEOUT   -3
#define WRSOCKTIMEOUT   -3

/* ���׽ӿڶ��������ݳ�ʱ��ת */
jmp_buf  RdFixLen;
static void RdFixLenTimeOut(int n)
{
    siglongjmp(RdFixLen, 1);
}

/* ���׽ӿڶ��䳤���ݳ�ʱ��ת */
jmp_buf  RdVarLen;
static void RdVarLenTimeOut(int n)
{
    siglongjmp(RdVarLen, 1);
}

/* ���׽ӿ�д���ݳ�ʱ��ת */
jmp_buf  WrSock;
static void WrSockTimeOut(int n)
{
    siglongjmp(WrSock, 1);
}



/* ----------------------------------------------------------------
 * ��    �ܣ���ָ���׽ӿڶ�ȡָ������������(����ʱ)
 * ���������iSockFd   �׽ӿھ��
 *           iTimeOut  ��ʱʱ��(��)
 *           iLen      ָ����ȡ����������
 * ���������szBuf     ��ȡ��������������
 * �� �� ֵ��-1  ���ò�����������; 
 *           RDSOCKTIMEOUT ����ʱ
 *           =0  �Զ˹رգ�
 *           >0  �ɹ����������ĳ���;
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int ReadSockFixLen(int iSockFd, int iTimeOut, int iLen, char *szBuf)
{
    int iNvrRead, iHveRead;

    if (iSockFd <= 0 || iTimeOut < 0 || iLen <= 0 || szBuf == NULL)
    {
        WriteLog(ERROR, "�������ݷǷ�iSockFd[%d], iTimeOut[%d] iLen[%d]",
                 iSockFd, iTimeOut, iLen);
        return FAIL;
    }

    iNvrRead = iLen;

    if( iTimeOut > 0 )
    {
        signal(SIGALRM, RdFixLenTimeOut); 
        if (sigsetjmp(RdFixLen, 1) != 0)
        {
            WriteLog(ERROR, "ReadSockFixLen timeout");
            alarm(0);
            return(RDSOCKTIMEOUT);
        }
        alarm(iTimeOut);
    }

    while (iNvrRead > 0)
    {
        iHveRead = read(iSockFd, szBuf, iNvrRead);
        if (iHveRead < 0)
        {
            if( iTimeOut > 0 )
            {
                alarm(0);
            }
            return iHveRead;
        }
        else if (iHveRead == 0)
        {
            break;
        }

        iNvrRead -= iHveRead;
        szBuf += iHveRead;
    }

    if( iTimeOut > 0 )
    {
        alarm(0);
    }

    return(iLen - iNvrRead);
}

/* ----------------------------------------------------------------
 * ��    �ܣ����׽ӿڶ�����������(һ�ζ�ȡ������)
 * ���������iSockFd   �׽ӿ�
 *           iTimeOut  ��ʱʱ��(��)
 * ���������szBuf     ��ȡ��������
 * �� �� ֵ��>0  �������ݳ��ȣ� 
 *           =0  �Զ˹ر�;
 *           -1 ��ȡʧ��; 
 *           RDSOCKTIMEOUT ����ʱ
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int ReadSockVarLen(int iSockFd, int iTimeOut, char *szBuf)
{
    int iHveRead = 0;

    signal(SIGALRM, RdVarLenTimeOut);
    if (sigsetjmp(RdVarLen, 1) != 0)
    {
        WriteLog(ERROR, "ReadSockVarLen timeout");
        alarm(0);
        return (RDSOCKTIMEOUT);
    }
    alarm(iTimeOut);

    iHveRead = read(iSockFd, szBuf, VARLENFORREAD);
    if (iHveRead < 0)
    {
        alarm(0);
        return FAIL;
    }

    alarm(0);
    return iHveRead;
}

/******************************************************************************
 * ��    �ܣ���ָ���׽ӿڶ�ȡ������������ݣ�ȥ������������
 * ���������
 *           iSockFd    �׽ӿھ��
 *           iTimeOut   ��ʱʱ��(��)��Ϊ0��ʾ������
 *           iLenLen    �����򳤶�
 *           iLenType   ����������  HEX_DATA-ʮ������ ASC_DATA-ASCʮ���� BCD_DATA-BCD
 * ���������
 *           szOutData  ��ȡ��������������(����������)
 * �� �� ֵ��
 *           FAIL           ��ȡʧ��
 *           RDSOCKTIMEOUT  ����ʱ
 *           >0  �ɹ����������ĳ���
 * ��    �ߣ�Robin
 * ��    �ڣ�2012/12/19
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 *
 * **************************************************************************/
int ReadSockDelLenField( iSockFd, iTimeOut, iLenLen, iLenType, szOutData )
int iSockFd;
int iTimeOut;
int iLenLen;
uchar *szOutData;
{
    int i, iLen, iRet;
    uchar szBuf[2048], szTmpStr[256];

    if( iLenLen <= 0 || iLenLen > 4 )
    {
        WriteLog( ERROR, "iLenLen�Ƿ�[%d]", iLenLen );
        return FAIL;
    }

    //��ȡ������
    memset( szBuf, 0, sizeof(szBuf) );
    iLen = ReadSockFixLen( iSockFd, iTimeOut, iLenLen, szBuf );
    if( iLen != iLenLen )
    {
        WriteLog( ERROR, "��������ʧ�ܡ���������[%d] ��������[%d]", iLen, iLenLen );
        return FAIL;
    }

    //���㳤��
    iLen = 0;
    switch (iLenType){
    case HEX_DATA:
        for( i=0; i<iLenLen; i++ )
        {
            iLen = iLen*256 + szBuf[i];
        }
        break;
    case ASC_DATA:
        iLen = atol(szBuf);
        break;
    case BCD_DATA:
        BcdToAsc( szBuf, iLenLen*2, LEFT_ALIGN, szTmpStr );
        iLen = atol(szTmpStr);
        break;
    default:
        WriteLog( ERROR, "iLenType�Ƿ�[%d]", iLenType );
        return FAIL;
    }

    if( iLen > sizeof(szBuf) )
    {
        WriteLog( ERROR, "����̫��������Ϊ�Ƿ����ġ�len=[%d]", iLen );
        return FAIL;
    }

    //���ݳ��ȶ�ȡ����
    memset( szBuf, 0, sizeof(szBuf) );
    iRet = ReadSockFixLen( iSockFd, 1, iLen, szBuf );
    if( iRet != iLen )
    {
        WriteLog( ERROR, "����������ʧ�ܡ���������[%d] ��������[%d]", iLen, iLenLen );
        return FAIL;
    }

    memcpy( szOutData, szBuf, iLen );

    return iLen;
}

/* ----------------------------------------------------------------
 * ��    �ܣ����׽ӿ�д����
 * ���������iSockFd   �׽ӿ�
 *           uszBuf    ��������
 *           iLen      �������ݳ���
 *           iTimeOut  ��ʱʱ��(��)
 * ���������
 * �� �� ֵ��>=0           �ɹ��� 
 *           =-1           ʧ��;  
 *          WRSOCKTIMEOUT д��ʱ
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int WriteSock(int iSockFd, uchar *uszBuf, int iLen, int iTimeOut)
{
    int iLeft, iWrit;

    if (iSockFd <= 0 || uszBuf == NULL || iLen <= 0 || iTimeOut < 0)
    {
        return FAIL;
    }

    iLeft = iLen;

    signal(SIGALRM, WrSockTimeOut);
    if (sigsetjmp(WrSock, 1) != 0)
    {
        WriteLog(ERROR, "WriteSock timeout");
        alarm(0);
        return (WRSOCKTIMEOUT);
    }
    alarm(iTimeOut);

    while (iLeft > 0)
    {
        iWrit = write(iSockFd, uszBuf, iLeft);
        if (iWrit <= 0)
        {
            alarm(0);
            return iWrit;
        }

        iLeft  -= iWrit;
        uszBuf += iWrit;
    }

    alarm(0);
    return iLen - iLeft;
}

/* ----------------------------------------------------------------
 * ��    �ܣ����׽ӿ�д���ݣ��Զ�������ǰ����ӳ�����
 * ���������iSockFd    �׽ӿ�
 *           szInData   ��������
 *           iLen       �������ݳ���
 *           iTimeOut   ��ʱʱ��(��)
 *           iLenLen    ��ӳ����򳤶�
 *           iLenType   ����������
 * ���������
 * �� �� ֵ��>=0           �ɹ��� 
 *           =-1           ʧ��;  
 *          WRSOCKTIMEOUT д��ʱ
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int WriteSockAddLenField(int iSockFd, uchar *szInData, int iLen, int iTimeOut, int iLenLen, int iLenType )
{
    int     iRet;
    uchar   szBuf[2048], szTmpStr[256];

    if( iLenLen <= 0 || iLenLen > 4 )
    {
        WriteLog( ERROR, "iLenLen�Ƿ�[%d]", iLenLen );
        return FAIL;
    }

    if( iLen > sizeof(szBuf)-4 )
    {
        WriteLog( ERROR, "��������̫��[%d]", iLen );
        return FAIL;
    }

    //��֯������
    switch (iLenType){
    case HEX_DATA:
        if( iLenLen == 2 )
        {
            if( iLen > 65535 )
            {
                WriteLog( ERROR, "��������̫����2�ֽڳ������ʾ���ˡ�����[%ld]", iLen );
                return FAIL;
            }
            else
            {
                szBuf[0] = iLen/256;    
                szBuf[1] = iLen%256;        
            }
        }
        else if( iLenLen == 1 )
        {
            if( iLen > 256 )
            {
                WriteLog( ERROR, "��������̫����1�ֽڳ������ʾ���ˡ�����[%ld]", iLen );
                return FAIL;
            }
            else
            {
                szBuf[0] = iLen;        
            }
        }
        else
        {
            WriteLog( ERROR, "ʮ�����Ƴ��ȣ�������û��Ҫ����2�������򳤶�[%ld]", iLenLen );
            return FAIL;
        }
        break;
    case ASC_DATA:
        if( iLenLen == 4 )
        {
            if( iLen > 9999 )
            {
                WriteLog( ERROR, "��������̫����4�ֽڳ������ʾ���ˡ�����[%ld]", iLen );
                return FAIL;
            }
            else
            {
                sprintf( szBuf, "%04ld", iLen );
            }
        }
        else if( iLenLen == 3 )
        {
            if( iLen > 999 )
            {
                WriteLog( ERROR, "��������̫����3�ֽڳ������ʾ���ˡ�����[%ld]", iLen );
                return FAIL;
            }
            else
            {
                sprintf( szBuf, "%03ld", iLen );
            }
        }
        else if( iLenLen == 2 )
        {
            if( iLen > 99 )
            {
                WriteLog( ERROR, "��������̫����2�ֽڳ������ʾ���ˡ�����[%ld]", iLen );
                return FAIL;
            }
            else
            {
                sprintf( szBuf, "%02ld", iLen );
            }
        }
        else if( iLenLen == 1 )
        {
            if( iLen > 9 )
            {
                WriteLog( ERROR, "��������̫����1�ֽڳ������ʾ���ˡ�����[%ld]", iLen );
                return FAIL;
            }
            else
            {
                sprintf( szBuf, "%01ld", iLen );
            }
        }
        break;
    case BCD_DATA:
        if( iLenLen == 2 )
        {
            if( iLen > 9999 )
            {
                WriteLog( ERROR, "��������̫����2�ֽڳ������ʾ���ˡ�����[%ld]", iLen );
                return FAIL;
            }
            else
            {
                sprintf( szTmpStr, "%04ld", iLen );
                AscToBcd( szTmpStr, 4, LEFT_ALIGN, szBuf );
            }
        }
        else if( iLenLen == 1 )
        {
            if( iLen > 99 )
            {
                WriteLog( ERROR, "��������̫����1�ֽڳ������ʾ���ˡ�����[%ld]", iLen );
                return FAIL;
            }
            else
            {
                sprintf( szTmpStr, "%04ld", iLen );
                AscToBcd( szTmpStr, 4, LEFT_ALIGN, szBuf );
            }
        }
        else
        {
            WriteLog( ERROR, "ʮ�����Ƴ��ȣ�������û��Ҫ����2�������򳤶�[%ld]", iLenLen );
            return FAIL;
        }
        break;
    default:
        WriteLog( ERROR, "iLenType�Ƿ�[%d]", iLenType );
        return FAIL;
    }

    memcpy( szBuf+iLenLen, szInData, iLen );

    iRet = WriteSock( iSockFd, szBuf, iLen+iLenLen, iTimeOut );
    if( iRet != (iLen+iLenLen) )
    {
        WriteLog( ERROR, "��������ʧ�ܡ����ͳ���[%d] ��������[%d]", iRet, iLen+iLenLen );
        return FAIL;
    }

    return SUCC;
}

/* ----------------------------------------------------------------
 * ��    �ܣ���UDP����˷�������
 * ���������szIp   UDP�����IP��ַ
 *           szPort UDP����˶˿�
 *           szBuf  ��������
 *           iLen   �������ݳ���
 * ���������
 * �� �� ֵ��0 ���ͳɹ���  -1  ����ʧ��
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int SendToUdpSrv(char *szIp, char *szPort, char *szBuf, int iLen)
{
    int                 sockfd;
    struct sockaddr_in  srv_addr,cli_addr;
    int                 iRet;
    int                 on=1;

    /* �����׽ӿ� */
    sockfd = socket(AF_INET,SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        WriteLog(ERROR, "call socket error[%d-%s]"
                 , errno, strerror(errno));
        return FAIL;
    }

    setsockopt(sockfd, SOL_SOCKET,SO_REUSEADDR | SO_BROADCAST, &on, sizeof(on));

    memset((char *)&srv_addr, 0, sizeof(srv_addr));
    srv_addr.sin_family = AF_INET;
    srv_addr.sin_addr.s_addr = inet_addr(szIp);
    srv_addr.sin_port = htons(atoi(szPort));

    memset((char *)&cli_addr, 0, sizeof(cli_addr));
    cli_addr.sin_family = AF_INET;
    cli_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    cli_addr.sin_port = htons(0);

    iRet = bind(sockfd,(struct sockaddr *)&cli_addr,sizeof(cli_addr));
    if (iRet < 0)
    {
        WriteLog(ERROR, "call bind error[%d-%s]", errno, strerror(errno));
        close(sockfd);
        return FAIL;
    }

    iRet = sendto(sockfd, szBuf, iLen, 0,
                 (struct sockaddr *)&srv_addr, sizeof(srv_addr));
    if (iRet < 0) 
    {
        WriteLog(ERROR, "call sendto error[%d-%s]\n"
                 , errno, strerror(errno));
        close(sockfd);
        return FAIL;
    }

    close(sockfd);

    return SUCC;
}
