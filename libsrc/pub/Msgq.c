
/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision: 1.10 $
 * $Log: Msgq.c,v $
 * Revision 1.10  2012/12/04 06:50:14  chenjr
 * ����淶��
 *
 * Revision 1.9  2012/11/29 02:15:35  linqil
 * �޸�WriteETLogΪWriteLog
 *
 * Revision 1.8  2012/11/28 08:25:44  linqil
 * ȥ������ͷ�ļ�user.h
 *
 * Revision 1.7  2012/11/28 02:40:25  linqil
 * �޸���־����
 *
 * Revision 1.6  2012/11/27 07:08:04  linqil
 * �޸������ж����
 *
 * Revision 1.5  2012/11/27 03:26:05  linqil
 * ��������pub.h �޸�return
 *
 * Revision 1.4  2012/11/27 03:07:45  yezt
 * *** empty log message ***
 *
 * Revision 1.3  2012/11/26 02:43:03  chenjr
 * ����Ϣ���д������ȡ�ֽ�������ӿڣ���ӻ�ȡ��Ϣ������Ϣ�ӿ�
 *
 * Revision 1.2  2012/11/22 02:04:51  chenjr
 * *** empty log message ***
 *
 * Revision 1.1  2012/11/20 03:27:37  chenjr
 * init
 *
 * ----------------------------------------------------------------
 */

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <signal.h>
#include <setjmp.h>

#include "pub.h"

#define MSGSIZE    8092 * 5

struct MsgBuf
{
    long mtype;
    char mbuf[MSGSIZE];
};


/* ����Ϣ���ж���Ϣ��ʱ��ת */
static jmp_buf  RcvMsgTimeOut;
static void RcvMsgTimeOutProc(int n)
{
    siglongjmp(RcvMsgTimeOut, 1);
}

/* ----------------------------------------------------------------
 * ��    �ܣ�������Ϣ����
 * ���������szFile     �Ѿ����ڵ��ļ���(һ����etc�ļ�����)
 *           iId        �����
 * �����������
 * �� �� ֵ��-1 ʧ��/��Ϣ���еı�ʶ��
 * ��    �ߣ�
 * ��    �ڣ�2012/12/26
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int CreateMsgQue(char *szFile,  int iId)
{
    int    msgid;
    key_t  key;

    if (szFile == NULL || iId == 0)
    {
        return FAIL;
    }
   
    key = ftok(szFile, iId);
    if (key == -1)
    {
        WriteLog(ERROR, "call ftok(\"%s\",%d) fail[%d-%s]", 
                         szFile, iId, errno, strerror(errno));
        return FAIL;
    }

    msgid = msgget(key, IPC_CREAT | 0666);
    if (msgid == -1)
    {
        WriteLog(ERROR, "call msgget IPC_CREAT(%ld) fail[%d-%s]", 
                         key, errno, strerror(errno));
        return FAIL;
    }

    return (msgid);
}


/* ----------------------------------------------------------------
 * ��    �ܣ���ȡһ���Ѵ�����Ϣ���еı�ʶ
 * ���������
 *           szFile     �Ѿ����ڵ��ļ���(һ����etc�ļ�����)
 *           iId        �����
 * �����������
 * �� �� ֵ��-1 ʧ��/��Ϣ���еı�ʶ��
 * ��    �ߣ�
 * ��    �ڣ�2012/12/27
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int GetMsgQue(char *szFile,  int iId)
{
    int    msgid;
    key_t  key;

    if (szFile == NULL || iId == 0)
    {
        return FAIL;
    }

    key = ftok(szFile, iId);
    if (key == -1)
    {
        WriteLog(ERROR, "call ftok(\"%s\",%d) fail[%d-%s]", 
                         szFile, iId, errno, strerror(errno));
        return FAIL;
    }

    msgid = msgget(key, 0);
    if (msgid == -1)
    {
        WriteLog(ERROR, "call msgget 0(%ld) fail[%d-%s]", 
                         key, errno, strerror(errno));
        return FAIL;
    }

    return (msgid);
}


/* ----------------------------------------------------------------
 * ��    �ܣ���ϵͳ�ں����Ƴ���Ϣ����
 * ���������iMsgid     ��Ϣ���еı�ʶ��
 * �����������
 * �� �� ֵ��0  �ɹ�/-1 ʧ��
 * ��    �ߣ�
 * ��    �ڣ�2012/12/27
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int RmMsgQue(int iMsgid)
{

    if (iMsgid <= 0)
    {
        WriteLog(ERROR, "RmMsgQue input-para[iMsgid=%d] error", iMsgid); 
        return FAIL;
    }

    if (msgctl(iMsgid, IPC_RMID, NULL) < 0)
    {
        WriteLog(ERROR, "call msgctl IPC_RMID(msgid=%d) fail[%d-%s]", 
                         iMsgid, errno, strerror(errno));
        return FAIL;
    }

    return SUCC;
}

/* ----------------------------------------------------------------
 * ��    �ܣ� ȡ����Ϣ���е�msqid_ds���ݲ�����
 *            �Ļ�����
 * ��������� iMsgid     ��Ϣ���еı�ʶ��
 * ��������� ptDs       ��Ϣ���е�msqid_ds�ṹ
 * �� �� ֵ�� 0  �ɹ�/-1 ʧ��
 * ��    �ߣ�
 * ��    �ڣ�2012/12/27
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int GetMsgQueStat(int iMsgid, struct msqid_ds *ptDs)
{
    if (iMsgid <= 0)
    {
        WriteLog(ERROR, "GetMsgQueStat input-para[iMsgid=%d] error", iMsgid);
        return FAIL;
    }

    if (msgctl(iMsgid, IPC_STAT, ptDs) < 0)
    {
        WriteLog(ERROR, "call msgctl IPC_STAT(msgid=%d) fail[%d-%s]",
                         iMsgid, errno, strerror(errno));
        return FAIL;
    }

    return SUCC;
}


/* ----------------------------------------------------------------
 * ��    �ܣ�����Ϣ�����з�����Ϣ����Ϣ��СΪiSndLen
 * ���������
 *          iMsgid     ��Ϣ���еı�ʶ��
 *          lMsgType   ��Ϣ������
 *          szSndBuf   ��������
 *          iSndLen    ���͵����ݴ�С
 * �����������
 * �� �� ֵ��0  �ɹ� /-1 ʧ��
 * ��    �ߣ�
 * ��    �ڣ�2012/12/27
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int SndMsgToMQ(int iMsgid, long lMsgType, char *szSndBuf, int iSndLen)
{
    struct MsgBuf mb;

    if (iMsgid <= 0 || lMsgType <= 0 || szSndBuf == NULL || 
        iSndLen < 0 || iSndLen > MSGSIZE - 1)
    {
        return FAIL;
    }
    
    memset(&mb, 0, sizeof(mb));
    mb.mtype = lMsgType;
    memcpy(mb.mbuf, szSndBuf, iSndLen);

    if (msgsnd(iMsgid, &mb, iSndLen, ~IPC_NOWAIT) == -1)
    {
        WriteLog(ERROR, "call msgsnd(msgid=%d) fail[%d-%s]", 
                        iMsgid, errno, strerror(errno));
        return FAIL;
    }

    return SUCC;
}


/* ----------------------------------------------------------------
 * ��    �ܣ�����Ϣ�����ж�ȡ��Ϣ����Ϣ���ΪMSGSIZE
 * ���������
 *           iMsgid    ��Ϣ���еı�ʶ��
 *           lMsgType  ��Ϣ������
 *           iTimeOut  ��ʱʱ��(0�����޵ȴ�������Ϣ,>0����ʱʱ��)
 * ���������szRcvBuf  �յ�������
 * �� �� ֵ�� 0   �ɹ�/-1  ʧ��
 * ��    �ߣ�
 * ��    �ڣ�2012/12/27
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int RcvMsgFromMQ(int iMsgid, long lMsgType, int iTimeOut, char *szRcvBuf)
{
    int rcvlen;
    struct MsgBuf mb;

    if (iMsgid <= 0 || lMsgType <= 0 || iTimeOut < 0 || szRcvBuf == NULL)
    {
        return FAIL;
    }

    if (iTimeOut > 0)
    {
        signal(SIGALRM, RcvMsgTimeOutProc);
        if (sigsetjmp(RcvMsgTimeOut, 1) != 0)
        {
            WriteLog(ERROR, "RcvMsgFromMQ(msgid=%d) Timeout", iMsgid);
            return SUCC;
        }
        alarm(iTimeOut);
    }

    memset(&mb, 0, sizeof(mb));
    rcvlen = msgrcv(iMsgid, &mb, MSGSIZE, lMsgType, 0);
    if (rcvlen == -1)
    {
        WriteLog(ERROR, "call msgrcv(msgid=%d) fail[%d-%s]", 
                        iMsgid, errno, strerror(errno));
        return FAIL;
    }
    alarm(0);

    memcpy(szRcvBuf, mb.mbuf, rcvlen);

    return (rcvlen);
}


