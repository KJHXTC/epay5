
/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision: 1.10 $
 * $Log: Sem.c,v $
 * Revision 1.10  2012/12/04 07:09:53  chenjr
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
 * Revision 1.6  2012/11/28 01:36:45  chenjr
 * *** empty log message ***
 *
 * Revision 1.5  2012/11/28 01:34:54  chenjr
 * �޸�GetSem�ӿ�����ж�
 *
 * Revision 1.4  2012/11/28 01:33:20  chenjr
 * ��Ӵ����ӿ�
 *
 * Revision 1.3  2012/11/27 06:23:57  yezt
 * *** empty log message ***
 *
 * Revision 1.2  2012/11/27 06:04:53  linqil
 * ��������pub.h �޸�return �޸������ж�
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
#include <sys/sem.h>

#include "pub.h"

/* ----------------------------------------------------------------
 * ��    �ܣ� �����ź���
 * ��������� 
 *            szFile       �Ѿ����ڵ��ļ���(һ����etc�ļ�����)
 *            iId          iId        �����
 *            iResource    �ź�������
 * ��������� ��
 * �� �� ֵ�� -1  ʧ��/ semid �ź�����ʶ��
 * ��    �ߣ�
 * ��    �ڣ� 2012/12/27
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int CreateSem(char *szFile,  int iId, int iResource)
{
    int     semid;
    key_t   key;
    int     iRet;

    if (szFile == NULL || iId == 0 || iResource<= 0)
    {
        WriteLog(ERROR, "GetSem Invalid argument[%s, %d, %d]", 
                        szFile, iId, iResource);
        return FAIL;
    }

    key = ftok(szFile, iId);
    if (key == -1)
    {
        WriteLog(ERROR, "call ftok(\"%s\",%d) fail[%d-%s]",
                         szFile, iId, errno, strerror(errno));
        return FAIL;
    }

    semid = semget(key, 1, IPC_CREAT | 0666);
    if (semid == -1)
    {
        WriteLog(ERROR, "call semget(key=%ld) fail[%d-%s]",
                         key, errno, strerror(errno));
        return FAIL;
    }

    iRet = semctl(semid, 0, SETVAL, iResource);
    if (iRet == -1)
    {
        WriteLog(ERROR, "call semctl(semid=%d, rs=%d) fail[%d-%s]",
                         semid, iResource, errno, strerror(errno));
        return FAIL;
    }

    return semid;
}

/* ----------------------------------------------------------------
 * ��    �ܣ� ��ȡһ���Ѵ��ڵ��ź���
 * ��������� szFile       �Ѿ����ڵ��ļ���(һ����etc�ļ�����)
 *            iId          iId        �����
 * ��������� ��
 * �� �� ֵ�� -1  ʧ��/ semid �ź�����ʶ��
 * ��    �ߣ�
 * ��    �ڣ� 2012/12/27
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int GetSem(char *szFile,  int iId)
{
    int     semid;
    key_t   key;
    int     iRet;

    if (szFile == NULL || iId == 0)
    {
        WriteLog(ERROR, "GetSem Invalid argument[%s, %d]", szFile, iId);
        return FAIL;
    }

    key = ftok(szFile, iId);
    if (key == -1)
    {
        WriteLog(ERROR, "call ftok(\"%s\",%d) fail[%d-%s]",
                         szFile, iId, errno, strerror(errno));
        return FAIL;
    }

    semid = semget(key, 1, 0);
    if (semid == -1)
    {
        WriteLog(ERROR, "call semget(key=%ld) fail[%d-%s]",
                         key, errno, strerror(errno));
        return FAIL;
    }

    return semid;
}

/* ----------------------------------------------------------------
 * ��    �ܣ����ź�����ʾ��ָ�����ź������в���
 * ���������
 *           semid          �ź�����ʶ��
 *           iResource      �ź���Դ  >0 �ͷſ�����Դ
 *                                    <0 ռ�ÿ�����Դ
 * �����������
 * �� �� ֵ��-1  ʧ�� /0   �ɹ�
 * ��    �ߣ�
 * ��    �ڣ�2012/12/27
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int SemOpera(int iSemid, int iResource)
{
    struct sembuf sop;
    int     iRet;

    if (iSemid <= 0 || iResource == 0)
    {
        WriteLog(ERROR, "SemOpera Invalid argument[%d, %d]"
                      , iSemid, iResource);
        return FAIL;
    }
 
    sop.sem_num = 0;
    sop.sem_op  = iResource;
    sop.sem_flg = SEM_UNDO;

    iRet = semop(iSemid, &sop, 1);
    if (iRet == -1)
    {
        WriteLog(ERROR, "call semop(semid=%d) fail[%d-%s]",
                         iSemid, errno, strerror(errno));
        return FAIL;
    }

    return SUCC;
}

/* ----------------------------------------------------------------
 * ��    �ܣ�P����
 * ���������
 *           semid          �ź�����ʶ��
 *           iResource      ������Դ�ĸ���  
 * �����������
 * �� �� ֵ��-1    ʧ��/0       �ɹ�
 * ��    �ߣ�
 * ��    �ڣ�2012/12/27
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int P(int iSemid, int iResource)
{
    int     iRet;
    iRet = SemOpera(iSemid, 0 - iResource);
    return iRet;
}


/* ----------------------------------------------------------------
 * ��    �ܣ�V����
 * ��������� 
 *           semid          �ź�����ʶ��
 *           iResource      ������Դ�ĸ���  
 * �����������
 * �� �� ֵ��-1    ʧ��/0       �ɹ�
 * ��    �ߣ�
 * ��    �ڣ�2012/12/27
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int V(int iSemid, int iResource)
{
    int     iRet;
    iRet = SemOpera(iSemid, iResource);
    return iRet;
}


/* ----------------------------------------------------------------
 * ��    �ܣ� ��ָ�����ź��������ڴ���ɾ��
 * ��������� semid          �ź�����ʶ��
 * ��������� ��
 * �� �� ֵ�� -1    �ɹ�/0      ʧ��
 * ��    �ߣ�
 * ��    �ڣ� 2012/12/27
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int RmSem(int iSemid)
{
    int     iRet;

    if (iSemid <= 0)
    {
        WriteLog(ERROR, "RmSem Invalid argument[%d]", iSemid);
        return FAIL;
    }

    iRet = semctl(iSemid, 0, IPC_RMID, (struct semid_ds*)0);
    if (iRet < 0)
    {
        WriteLog(ERROR, "call semctl IPC_RMID(semid=%d) fail[%d-%s]", 
                         iSemid, errno, strerror(errno));
        return FAIL;
    }

    return SUCC;
}

