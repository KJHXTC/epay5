/*****************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨ϵͳ״̬���ģ�� ��ȡ������Ϣ
** �� �� �ˣ����
** �������ڣ�2012/10/30
**
** $Revision: 1.5 $
** $Log: GetProcStatus.c,v $
** Revision 1.5  2012/12/21 02:08:15  fengw
**
** 1������Revision��Log��
**
*******************************************************************/

#define _EXTERN_

#include "epaymoni.h"

/****************************************************************
** ��    �ܣ�������״̬
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
int GetProcStatus(char *szChkStatus)
{
    int     i;
    int     iProcCount;                 /* ����ؽ��̸��� */
    char    szTmpBuf[64+1];             /* ��ʱ���� */
    char    szProcName[32+1];           /* ������ */
    char    szCommnts[64+1];            /* ���������� */
    char    szStatus[64+1];             /* ����״̬ */
    char    szInfo[4096+1];             /* ������ϸ��Ϣ */
    int     iIndex;                     /* �ַ������� */

    /* ��ȡ���� */
    /* ��ȡ����ؽ��̸��� */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    if(ReadConfig(CONFIG_FILENAME, SECTION_EPAYMONI, "PROC_MON_COUNT", szTmpBuf) != SUCC)
    {
        WriteLog(ERROR, "��ȡ�����ļ�[%s] SECTION:[%s] ������:[%s] ʧ��!",
                 CONFIG_FILENAME, SECTION_EPAYMONI, "PROC_MON_COUNT");

        return FAIL;
    }
    iProcCount = atoi(szTmpBuf);

    /* �жϴ���ؽ��̸�����С�ڵ���0�����ش��� */
    if(iProcCount <=0)
    {
        WriteLog(ERROR, "PROC_MON_COUNT����ֵ[%d]����ȷ!", iProcCount);

        return FAIL;
    }

    /* д��ϸ��Ϣ�ļ������ݿ�sysinfo�ֶ� */
    fprintf(fpStatusFile, "ƽ̨���̵�ǰ״̬\x0D\x0A");
    fprintf(fpStatusFile, "********************************************************************************\x0D\x0A");
    fprintf(fpStatusFile, "USER    PID    PPID    PGID    TIME        PCPU    PMEM    STATUS    START        COMMAND\x0D\x0A");

    /* д״̬��Ϣ�����ݿ�proc_status�ֶ� */
    iIndex = 0;

    sprintf(szChkStatus, "%d|", iProcCount);
    iIndex += strlen(szChkStatus);

    /* ѭ����ȡ������Ϣ */
    for(i=1;i<=iProcCount;i++)
    {
        /* ��ȡ������ */
        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        memset(szProcName, 0, sizeof(szProcName));
        sprintf(szTmpBuf, "PROC_NAME_%d", i);
        if(ReadConfig(CONFIG_FILENAME, SECTION_EPAYMONI, szTmpBuf, szProcName) != SUCC)
        {
            WriteLog(ERROR, "��ȡ�����ļ�[%s] SECTION:[%s] ������:[%s] ʧ��!",
                     CONFIG_FILENAME, SECTION_EPAYMONI, szTmpBuf);

            return FAIL;
        }

        /* ��ȡ���������� */
        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        memset(szCommnts, 0, sizeof(szCommnts));
        sprintf(szTmpBuf, "PROC_COMMENTS_%d", i);
        if(ReadConfig(CONFIG_FILENAME, SECTION_EPAYMONI, szTmpBuf, szCommnts) != SUCC)
        {
            WriteLog(ERROR, "��ȡ�����ļ�[%s] SECTION:[%s] ������:[%s] ʧ��!",
                     CONFIG_FILENAME, SECTION_EPAYMONI, szTmpBuf);

            return FAIL;
        }

        memset(szStatus, 0, sizeof(szStatus));
        memset(szInfo, 0, sizeof(szInfo));
        if(ChkProcStatus(szProcName, szCommnts, szStatus, szInfo) != SUCC)
        {
            return FAIL;
        }

        /* ״̬��Ϣ 2.����״̬ */
        memcpy(szChkStatus+iIndex, szStatus, strlen(szStatus));
        iIndex += strlen(szStatus);

        /* ��ϸ��Ϣ�ļ� */
        fprintf(fpStatusFile, "%s", szInfo);
    }

    /* ״̬��Ϣ ������־ */
    szChkStatus[iIndex] = '|';
    iIndex += 1;

    /* ��ϸ��Ϣ�ļ�  ������־ */
    fprintf(fpStatusFile,  "********************************************************************************\x0D\x0A");

    return SUCC;
}

/****************************************************************
** ��    �ܣ���鵥������״̬
** ���������
**        szProcName        ������
**        szComments        ����������
** ���������
**        szStatus          ״̬��Ϣ
** �� �� ֵ��
**        SUCC              ���ɹ�
**        FAIL              ���ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/10/31
** ����˵����
**
** �޸���־��
****************************************************************/
int ChkProcStatus(char *szProcName, char *szComments, char *szStatus, char *szInfo)
{
    int     i;
    FILE    *fp;                            /* FILEָ�� */
    char    szCmd[256+1];                   /* ��ѯ����״̬���� */
    char    szField1[32+1];                 /* �����һ�� �����û� */
    char    szField2[32+1];                 /* ����ڶ��� ���̺� */
    char    szField3[32+1];                 /* ��������� �����̺� */
    char    szField4[32+1];                 /* ��������� ������� */
    char    szField5[32+1];                 /* ��������� CPUռ��ʱ�� */
    char    szField6[32+1];                 /* ��������� CPUռ�ðٷֱ� */
    char    szField7[32+1];                 /* ��������� �ڴ�ռ�ðٷֱ� */
    char    szField8[32+1];                 /* ����ڰ��� ����״̬ */
    char    szField9[1024+1];               /* ����ھ��� ���̲��� */
    char    szField10[32+1];                /* �����ʮ�� ��������ʱ�� */
    char    szTmpBuf[512+1];                /* ��ʱ���� */
    int     iProcCount;                     /* ���̸��� */
    int     iIndex;                         /* �ַ������� */
    int     iTmp;                           /* ��ʱ���� */
    char    cStatus;                        /* ����ģ��״̬ */

    memset(szCmd, 0, sizeof(szCmd));

    sprintf(szCmd,    
            "ps -u `whoami` -o user,pid,ppid,pgid,time,pcpu,pmem,%s -o \"%%a|\" -o start | tr -s ' ' | awk '{if($9==\"%s\")print $0}'",
            cnPSStat, szProcName);

    fp = popen(szCmd, "r");
    if(fp == NULL)
    {
        WriteLog(ERROR, "ִ��popenʧ��!CMD:[%s]", szCmd);

        return FAIL;
    }

    /* Ĭ��״̬���� */
    cStatus = STATUS_YES;
    iProcCount = 0;
    iIndex = 0;

    while(1)
    {
        memset(szField1, 0, sizeof(szField1));
        memset(szField2, 0, sizeof(szField2));
        memset(szField3, 0, sizeof(szField3));
        memset(szField4, 0, sizeof(szField4));
        memset(szField5, 0, sizeof(szField5));
        memset(szField6, 0, sizeof(szField6));
        memset(szField7, 0, sizeof(szField7));
        memset(szField8, 0, sizeof(szField8));
        memset(szField9, 0, sizeof(szField9));
        memset(szField10, 0, sizeof(szField10));

        if(fscanf(fp, "%s %s %s %s %s %s %s %s %[^|] |%[^\n]",
                  szField1, szField2, szField3, szField4, szField5, szField6,
                  szField7, szField8, szField9, szField10) != EOF)
        {
            memset(szTmpBuf, 0, sizeof(szTmpBuf));
            /* szField���ڴ��args�ֶ����ݣ�����tomcat���̲�������������ʹ��1024���ȱ��� */
            /* ��ϸ�����ֻ����256�������ݣ�ʣ�������Զ��ض� */
            if(strlen(szField9) > 256)
            {
                szField9[256] = 0x00;
            }

            sprintf(szTmpBuf, "%s    %s    %s    %s    %s    %s    %s    %s    %s    %s\x0D\x0A",
                    szField1, szField2, szField3, szField4, szField5, szField6,
                    szField7, szField8, szField10, szField9);

            memcpy(szInfo+iIndex, szTmpBuf, strlen(szTmpBuf));
            iIndex += strlen(szTmpBuf);

            /* �жϽ���״̬ */
            if(szField8[0] != cnProcStatus)
            {
                cStatus = STATUS_NO;
            }

            /* �жϽ���ռ��CPUʱ�� */
            if(strcmp(szField5, "00:00:00") != 0)
            {
                cStatus = STATUS_NO;
            }

            /* �жϽ���ռ��CPU�ٷֱ� */
            if(atof(szField6)- 5.0 > 0.001)
            {
                cStatus = STATUS_NO;
            }

            /* �жϽ���ռ���ڴ�ٷֱ� */
            if(atof(szField7)- 5.0 > 0.001)
            {
                cStatus = STATUS_NO;
            }

            iProcCount++;
        }
        else
        {
            break;
        }
    }

    if(iProcCount == 0)
    {
        cStatus = STATUS_NO;
    }

    /* ����״̬��Ϣ */
    sprintf(szStatus, "%c,%s,%s,%d#", cStatus, szProcName, szComments, iProcCount);

    pclose(fp);

    return SUCC;
}
