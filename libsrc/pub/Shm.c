
/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision: 1.8 $
 * $Log: Shm.c,v $
 * Revision 1.8  2012/12/04 07:11:14  chenjr
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
 * Revision 1.4  2012/11/28 01:33:20  chenjr
 * ��Ӵ����ӿ�
 *
 * Revision 1.3  2012/11/27 07:38:25  yezt
 * *** empty log message ***
 *
 * Revision 1.2  2012/11/27 06:08:39  linqil
 * ��������pub.h �޸�return �޸������жϷ�ʽ
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
#include <sys/shm.h>

#include "pub.h"

/* ----------------------------------------------------------------
 * ��    �ܣ� ���������ڴ�
 * ���������
 *            szFile       �Ѿ����ڵ��ļ���(һ����etc�ļ�����)
 *            iId          �����
 *            iShmSize     �½��Ĺ����ڴ��С
 * ��������� ��
 * �� �� ֵ�� -1   ʧ�� /shmid   �����ڴ��ʶ��
 * ��    �ߣ�
 * ��    �ڣ� 2012/11/27
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int CreateShm(char *szFile,  int iId, int iShmSize)
{
    int    shmid;
    key_t  key;

    if (szFile == NULL || iId == 0 || iShmSize < 0)
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

    shmid = shmget(key, iShmSize, IPC_CREAT | 0666);
    if (shmid == -1)
    {
        WriteLog(ERROR, "call shmget(%ld, %d) fail[%d-%s]",
                         key, iShmSize, errno, strerror(errno));
        return FAIL;
    }

    return shmid;
}

/* ----------------------------------------------------------------
 * ��    �ܣ� ��ȡ�����ڴ��ʶ
 * ���������
 *            szFile       �Ѿ����ڵ��ļ���(һ����etc�ļ�����)
 *            iId          �����
 *            iShmSize     �½��Ĺ����ڴ��С
 * ��������� ��
 * �� �� ֵ�� -1   ʧ�� /shmid   �����ڴ��ʶ��
 * ��    �ߣ�
 * ��    �ڣ� 2012/11/27
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int GetShm(char *szFile,  int iId, int iShmSize)
{
    int    shmid;
    key_t  key;

    if (szFile == NULL || iId == 0 || iShmSize < 0)
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

    shmid = shmget(key, iShmSize, 0);
    if (shmid == -1)
    {
        WriteLog(ERROR, "call shmget(%ld, %d) fail[%d-%s]",
                         key, iShmSize, errno, strerror(errno));
        return FAIL;
    }

    return shmid;
}

/* ----------------------------------------------------------------
 * ��    �ܣ��ѹ����ڴ�������ӳ�䵽���ý��̵ĵ�ַ�ռ�(��дģʽ)
 * ���������iShmid       �����ڴ��ʶ��
 * �����������
 * �� �� ֵ��NULL  ��ָ�� / addr      ��ַָ��
 * ��    �ߣ�
 * ��    �ڣ�2012/11/27
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
char *AtShm(int iShmid)
{
    char   *addr;

    if (iShmid < 0)
    {
        return (NULL);
    }

    addr = (char*)shmat(iShmid, 0, SHM_RND);
    if (addr == (void*)-1)
    {
        WriteLog(ERROR, "call shmat(shmid=%d) fail[%d-%s]",
                         iShmid, errno, strerror(errno));
        return (NULL);
    }

    return (addr);
}


/* ----------------------------------------------------------------
 * ��    �ܣ���ָ���Ĺ����ڴ�ɾ��
 * ���������iShmid       �����ڴ��ʶ��
 * �����������
 * �� �� ֵ��FAIL  ʧ��/SUCC   �ɹ�
 * ��    �ߣ�
 * ��    �ڣ�2012/11/27
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int RmShm(int iShmid)
{
    int     iRet;

    if (iShmid <= 0)
    {
        WriteLog(ERROR, "RmShm input-para[iShmid=%d] error", iShmid);
        return FAIL;
    }

    iRet = shmctl(iShmid, IPC_RMID, NULL);
    if (iRet < 0)
    {
        WriteLog(ERROR, "call shmctl IPC_RMID(shmid=%d) fail[%d-%s]", 
                         iShmid, errno, strerror(errno));
        return FAIL;
    }

    return SUCC;
}

