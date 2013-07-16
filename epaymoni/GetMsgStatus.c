/*****************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨ϵͳ״̬���ģ�� ��ȡ��Ϣ������Ϣ
** �� �� �ˣ����
** �������ڣ�2012/10/30
**
** $Revision: 1.7 $
** $Log: GetMsgStatus.c,v $
** Revision 1.7  2013/03/26 07:20:45  fengw
**
** 1���޸�GetMsgQue��������ֵ�жϡ�
**
** Revision 1.6  2012/12/21 02:08:15  fengw
**
** 1������Revision��Log��
**
*******************************************************************/

#define _EXTERN_

#include "epaymoni.h"

/****************************************************************
** ��    �ܣ������Ϣ����״̬
** ���������
**        ��
** ���������
**        szChkStatus       ״̬�����
** �� �� ֵ��
**        SUCC              ���ɹ�
**        FAIL              ���ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/10/31
** ����˵����
**        ״̬��ϸ��Ϣֱ��д���ļ�
** �޸���־��
****************************************************************/
int GetMsgStatus(char *szChkStatus)
{
    int     i;
    char    szTmpBuf[64+1];                 /* ��ʱ���� */
    int     iMsgCount;                      /* �������Ϣ���и��� */
    char    szMsgFileName[64+1];            /* ������Ϣ�����ļ��� */
    char    szID[16+1];                     /* ������Ϣ����ID */
    int     iID;                            /* ������Ϣ����ID */
    char    szMsgComments[32+1];            /* ��Ϣ���������� */
    int     iMsgID;                         /* ��Ϣ����ID */
    char    szStatus[64+1];                 /* ��Ϣ����״̬ */
    int     iIndex;                         /* �ַ������� */
    struct msqid_ds msInfo;                 /* ��Ϣ������Ϣ�ṹ */

    /* ��ȡ���� */
    /* ��ȡ�������Ϣ���и��� */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    if(ReadConfig(CONFIG_FILENAME, SECTION_EPAYMONI, "MSG_MON_COUNT", szTmpBuf) != SUCC)
    {
        WriteLog(ERROR, "��ȡ�����ļ�[%s] SECTION:[%s] ������:[%s] ʧ��!",
                 CONFIG_FILENAME, SECTION_EPAYMONI, "MSG_MON_COUNT");

        return FAIL;
    }

    iMsgCount = atoi(szTmpBuf);

    /* �жϴ������Ϣ���и�����С�ڵ���0�����ش��� */
    if(iMsgCount <=0)
    {
        WriteLog(ERROR, "MSG_MON_COUNT����ֵ[%d]����ȷ!", iMsgCount);

        return FAIL;
    }

    /* ��ȡ��Ϣ�����ļ��� */
    memset(szMsgFileName, 0, sizeof(szMsgFileName));
    if(ReadConfig(CONFIG_FILENAME, SECTION_EPAYMONI, "MSG_FILE", szMsgFileName) != SUCC)
    {
        WriteLog(ERROR, "��ȡ�����ļ�[%s] SECTION:[%s] ������:[%s] ʧ��!",
                 CONFIG_FILENAME, SECTION_EPAYMONI, "MSG_FILE");

        return FAIL;
    }

    /* д��ϸ��Ϣ�ļ������ݿ�sysinfo�ֶ� */
    fprintf(fpStatusFile, "��Ϣ���е�ǰ״̬\x0D\x0A");
    fprintf(fpStatusFile, "********************************************************************************\x0D\x0A");

    /* д״̬��Ϣ�����ݿ�msg_status�ֶ� */
    iIndex = 0;

    sprintf(szChkStatus, "%d|", iMsgCount);
    iIndex += strlen(szChkStatus);

    /* ѭ����ȡ������Ϣ */
    for(i=1;i<=iMsgCount;i++)
    {
        /* ��ȡ��Ϣ����ID */
        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        memset(szID, 0, sizeof(szID));
        sprintf(szTmpBuf, "MSG_ID_%d", i);
        if(ReadConfig(CONFIG_FILENAME, SECTION_EPAYMONI, szTmpBuf, szID) != SUCC)
        {
            WriteLog(ERROR, "��ȡ�����ļ�[%s] SECTION:[%s] ������:[%s] ʧ��!",
                     CONFIG_FILENAME, SECTION_EPAYMONI, szTmpBuf);

            return FAIL;
        }
        iID = atoi(szID);

        /* ��ȡ��Ϣ���������� */
        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        memset(szMsgComments, 0, sizeof(szMsgComments));
        sprintf(szTmpBuf, "MSG_COMMENTS_%d", i);
        if(ReadConfig(CONFIG_FILENAME, SECTION_EPAYMONI, szTmpBuf, szMsgComments) != SUCC)
        {
            WriteLog(ERROR, "��ȡ�����ļ�[%s] SECTION:[%s] ������:[%s] ʧ��!",
                     CONFIG_FILENAME, SECTION_EPAYMONI, szTmpBuf);

            return FAIL;
        }

        /* ��ȡ��Ϣ����ID */
        if((iMsgID = GetMsgQue(szMsgFileName, iID)) == FAIL)
        {
            WriteLog(ERROR, "��ȡ��Ϣ����MsgIDʧ�ܣ�MsgFile:[%s] ID:[%d]", szMsgFileName, iID);

            /* ״̬��Ϣ 2.��Ϣ����״̬ */
            memset(szStatus, 0, sizeof(szStatus));
            sprintf(szStatus, "N,%s,-1#", szMsgComments);

            memcpy(szChkStatus+iIndex, szStatus, strlen(szStatus));
            iIndex += strlen(szStatus);

            /* ��ϸ��Ϣ�ļ� */
            fprintf(fpStatusFile, "%s ��Ϣ�����쳣\x0D\x0A", szMsgComments);

            continue;
        }

        /* ��ȡ��Ϣ����״̬ */
        if(GetMsgQueStat(iMsgID, &msInfo) != SUCC)
        {
            WriteLog(ERROR, "��ȡ��Ϣ������Ϣʧ��!MsgID:[%d]", iMsgID);

            /* ״̬��Ϣ 2.��Ϣ����״̬ */
            memset(szStatus, 0, sizeof(szStatus));
            sprintf(szStatus, "N,%s,-1#", szMsgComments);

            memcpy(szChkStatus+iIndex, szStatus, strlen(szStatus));
            iIndex += strlen(szStatus);

            /* ��ϸ��Ϣ�ļ� */
            fprintf(fpStatusFile, "%s ��Ϣ�����쳣\x0D\x0A", szMsgComments);

            continue;
        }

        /* ״̬��Ϣ 2.��Ϣ����״̬ */
        memset(szStatus, 0, sizeof(szStatus));
        sprintf(szStatus, "%c,%s,%d#", msInfo.msg_qnum==0?STATUS_YES:STATUS_NO,
                szMsgComments, msInfo.msg_qnum);
            
        memcpy(szChkStatus+iIndex, szStatus, strlen(szStatus));
        iIndex += strlen(szStatus);

        /* ��ϸ��Ϣ�ļ� */
        fprintf(fpStatusFile, "%s ��Ϣ����:%d\x0D\x0A", szMsgComments, msInfo.msg_qnum);
    }

    /* ״̬��Ϣ ������־ */
    szChkStatus[iIndex] = '|';
    iIndex += 1;

    /* ��ϸ��Ϣ�ļ�  ������־ */
    fprintf(fpStatusFile, "********************************************************************************\x0D\x0A");

    return SUCC;
}
