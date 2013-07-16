/*****************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨ϵͳ״̬���ģ��
** �� �� �ˣ����
** �������ڣ�2012/10/30
**
** $Revision: 1.8 $
** $Log: epaymoni.ec,v $
** Revision 1.8  2013/06/08 05:30:57  fengw
**
** 1���޸����ݿ����ӻ��ƣ�ÿ�β�ѯϵͳ״̬ǰ��������ݿ����ӣ����ѶϿ����Զ�������
**
** Revision 1.7  2013/06/05 02:16:29  fengw
**
** 1������ϵͳ״̬�����ϸ��Ϣ�ļ�ɾ����
**
** Revision 1.6  2012/12/21 02:08:15  fengw
**
** 1������Revision��Log��
**
*******************************************************************/

#include "epaymoni.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
    OCIClobLocator* clobLoc;                    /* ϵͳ״̬��ϸ��Ϣ�ļ� CLOB */
    int     iOffset;                            /* �ļ�ƫ��λ�� */
    int     iFileLen;                           /* �ļ����� */
    char    szFileBuf[1024];                    /* �ļ�����BUF */
    char    szMoniTime[14+1];                   /* �������ʱ�� */
    int     iHostNo;                            /* ��������� */
    char    szHostName[32+1];                   /* ���������� */
    char    szProcStatus[1024+1];               /* ����״̬��Ϣ */
    char    szMsgStatus[1024+1];                /* ��Ϣ����״̬��Ϣ */
    char    szCommStatus[1024+1];               /* ͨѶ�˿�״̬��Ϣ */
EXEC SQL END DECLARE SECTION;

void _proc_exit(int iSigNo)
{
    CloseDB();

    exit(0);
}

int main(int argc, char* argv[])
{
    int     i;
    int     iFlag;                              /* �ɹ���־ */
    int     iIntervalTime;                      /* ��ؼ��ʱ�� */
    char    szTmpBuf[64+1];                     /* ��ʱ���� */
    char    szFileName[128+1];                  /* �ļ��� */

    /* ��ȡ������������ȡ������ */
    memset(szHostName, 0, sizeof(szHostName));
    if(getenv("HOSTNAME") != NULL)
    {
        strcpy(szHostName, getenv("HOSTNAME"));
    }

    /* ��ȡ���� */
    /* ��ȡ���ڷ�������� */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));

    if(ReadConfig(CONFIG_FILENAME, SECTION_PUBLIC, "HOST_NO", szTmpBuf) != SUCC)
    {
        WriteLog(ERROR, "��ȡ�����ļ�[%s] SECTION:[%s] ������:[%s] ʧ��!",
                 CONFIG_FILENAME, SECTION_PUBLIC, "HOST_NO");

        return FAIL;
    }
    iHostNo = atoi(szTmpBuf);

    /* ����������� */
    if(iHostNo <= 0)
    {
        WriteLog(ERROR, "��ȡ����[%s]���������ʧ��!", szHostName);

        return FAIL;
    }

    /* ��ȡ���ʱ���� */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    if(ReadConfig(CONFIG_FILENAME, SECTION_EPAYMONI, "TIME_INTERVAL", szTmpBuf) != SUCC)
    {
        WriteLog(ERROR, "��ȡ�����ļ�[%s] SECTION:[%s] ������:[%s] ʧ��!",
                 CONFIG_FILENAME, SECTION_EPAYMONI, "TIME_INTERVAL");

        return FAIL;
    }

    iIntervalTime = atoi(szTmpBuf);

    if(iIntervalTime < MIN_MONI_INTERVAL)
    {
        WriteLog(ERROR, "TIME_INTERVAL����ֵ[%d]С�����ֵ[%d]��Ĭ��ȡ���ֵ!",
            iIntervalTime, MIN_MONI_INTERVAL);

        iIntervalTime = MIN_MONI_INTERVAL;
    }

    /* ���ɾ������, ʹ�������ն��ѽ� */
    /* ���ն��ѽں�,scanf�Ⱥ������޷�ʹ�� */
    switch(fork())
    {
        case 0 :
            break;
        case -1 :
            exit(-1);
        default :
            exit(0);
    }

    for(i=0;i<32;i++)
    {
        if(i == SIGALRM || i == SIGKILL ||
           i == SIGUSR1 || i == SIGUSR2)
        {
            continue;
        }

        signal(i, SIG_IGN);
    }

    signal(SIGUSR1, _proc_exit);

    /* Make a back process */
    setpgrp();

    while(1)
    {
        if(ChkDBLink() != SUCC && OpenDB() != SUCC)
        {
            WriteLog(ERROR, "�����ݿ�ʧ��!");

            sleep(10);

            continue;
        }

        /* ��ȡ��������ʱ�� */
        memset(szMoniTime, 0, sizeof(szMoniTime));

        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        GetSysDate(szTmpBuf);
        memcpy(szMoniTime, szTmpBuf, 8);

        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        GetSysTime(szTmpBuf);
        memcpy(szMoniTime+8, szTmpBuf, 6);

        /* ���ɱ�����ϸ��Ϣ�ļ��� */
        memset(szFileName, 0, sizeof(szFileName));

        sprintf(szFileName, "/tmp/%s_%s.txt", "EPAYStatus", szMoniTime);

        if(GetEpayStatus(szFileName, szProcStatus, szMsgStatus, szCommStatus) == SUCC)
        {
            BeginTran();

            /* Ĭ��״̬Ϊ�ɹ� */
            iFlag = SUCC;

            /* ��ȡ���ݿ�ϵͳ���� */
            memset(szMoniTime, 0, sizeof(szMoniTime));
            EXEC SQL SELECT TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') INTO :szMoniTime FROM dual;
            if(SQLCODE)
            {
                WriteLog(ERROR, "��ȡ���ݿ�ϵͳ����ʱ��ʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

                iFlag = FAIL;
            }
            else
            {
                /* ����ϵͳ״̬��¼ */
                EXEC SQL
                    INSERT INTO epay_moni (moni_time, host_no, host_name, proc_status,
                                           msg_status, comm_status, sys_info)
                    VALUES (:szMoniTime, :iHostNo, :szHostName, :szProcStatus,
                            :szMsgStatus, :szCommStatus, empty_clob());
                if(SQLCODE)
                {
                    WriteLog(ERROR, "����ϵͳ״̬��ر�ʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

                    iFlag = FAIL;
                }
                else
                {
                    /* ����CLOB���� */
                    if(UpdateClob(szFileName) != SUCC)
                    {
                        iFlag = FAIL;
                    }
                }
            }

            if(iFlag == SUCC)
            {
                CommitTran();
            }
            else
            {
                RollbackTran();
            }
        }
        else
        {
            /* ��¼������־ */
            WriteLog(ERROR, "����ϵͳ״̬�������ʧ��!");
        }

        /* ɾ���ļ� */
        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        sprintf(szTmpBuf, "rm -f %s", szFileName);

        system(szTmpBuf);

        /* �ȴ��´μ�� */
        sleep(iIntervalTime);
    }
}

/****************************************************************
** ��    �ܣ�����CLOB�����
** ���������
**        szFileName        ��ϸ��Ϣ�ļ���
** ���������
**        ��
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
int UpdateClob(char *szFileName)
{
    int     iRet;                   /* ����ִ�н�� */

    /* ����CLOB�ֶ� */
    /* ΪCLOB��λ�������ڴ� */
    EXEC SQL ALLOCATE :clobLoc;
    if(SQLCODE)
    {
        WriteLog(ERROR, "ΪCLOB��λ�������ڴ�ʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

        return FAIL;
    }

    /* ��ȡCLOB��λ�� */
    EXEC SQL
        SELECT sys_info INTO :clobLoc FROM epay_moni
        WHERE moni_time = :szMoniTime AND host_no = :iHostNo FOR UPDATE;
    if(SQLCODE)
    {
        WriteLog(ERROR, "��ȡCLOB��λ��ʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

        /* �ͷ�clob��λ��ռ�õ��ڴ� */
        EXEC SQL FREE :clobLoc;

        return FAIL;
    }

    /* ���CLOB�����ݳ��� */
    EXEC SQL LOB DESCRIBE :clobLoc GET LENGTH INTO :iOffset;
    if(SQLCODE)
    {
        WriteLog(ERROR, "��ȡCLOB�����ݳ���ʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

        /* �ͷ�clob��λ��ռ�õ��ڴ� */
        EXEC SQL FREE :clobLoc;

        return FAIL;
    }

    /* λ�Ƽ�һ */
    iOffset = iOffset + 1;

    /* ���ļ� */
    fpStatusFile = fopen(szFileName, "r");
    if(fpStatusFile == NULL)
    {
        WriteLog(ERROR, "���ļ�[%s]ʧ��!", szFileName);

        /* �ͷ�clob��λ��ռ�õ��ڴ� */
        EXEC SQL FREE :clobLoc;

        return FAIL;
    }

    while(1)
    {
        memset(szFileBuf, 0, sizeof(szFileBuf));

        if(fgets(szFileBuf, 1024, fpStatusFile) == NULL)
        {
            break;
        }

        iFileLen = strlen(szFileBuf);

        /* д��CLOB */
        EXEC SQL LOB WRITE :iFileLen FROM :szFileBuf INTO :clobLoc AT :iOffset;
        if(SQLCODE)
        {
            WriteLog(ERROR, "д��CLOB����ʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

            /* �ͷ�clob��λ��ռ�õ��ڴ� */
            EXEC SQL FREE :clobLoc;

            fclose(fpStatusFile);

            return FAIL;
        }

        iOffset += iFileLen;
    }

    /* �ͷ�clob��λ��ռ�õ��ڴ� */
    EXEC SQL FREE :clobLoc;

    fclose(fpStatusFile);

    return SUCC;
}
