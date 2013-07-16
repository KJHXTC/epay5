/*****************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨ϵͳ״̬���ģ�� ��ȡ��Ϣ������Ϣ
** �� �� �ˣ����
** �������ڣ�2012/10/30
**
** $Revision: 1.5 $
** $Log: GetCommStatus.c,v $
** Revision 1.5  2012/12/21 02:08:15  fengw
**
** 1������Revision��Log��
**
*******************************************************************/

#define _EXTERN_

#include "epaymoni.h"

/****************************************************************
** ��    �ܣ����ͨѶ�˿�״̬
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
int GetCommStatus(char *szChkStatus)
{
    int     i;
    int     iIndex;
    int     iCommCount;             /* �����ͨѶ�˿ڸ��� */
    char    szTmpBuf[64+1];         /* ��ʱ���� */
    char    szValueBuf[64+1];       /* �������������ʱ���� */
    char    szComments[32+1];       /* ͨѶ�˿��������� */
    int     iType;                  /* ͨѶ���� */
    char    szServIP[15+1];         /* �����IP��ַ */
    int     iServPort;              /* ����˼����˿� */
    int     iLocalPort;             /* ���ؼ����˿� */
    char    szStatus[64+1];         /* ͨѶ�˿�״̬��Ϣ */
    char    cCommStatus;            /* ͨѶ�˿�״̬ */

    /* ��ȡ������ͨѶ�˿ڸ��� */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    if(ReadConfig(CONFIG_FILENAME, SECTION_EPAYMONI, "COMM_MON_COUNT", szTmpBuf) != SUCC)
    {
        WriteLog(ERROR, "��ȡ�����ļ�[%s]SECTION:[%s] ������:[%s] ʧ��!",
                 CONFIG_FILENAME, SECTION_EPAYMONI, "COMM_MON_COUNT");

        return FAIL;
    }
    iCommCount = atoi(szTmpBuf);
    
    /* �жϴ����ͨѶ�˿ڸ�����С�ڵ���0�����ش��� */
    if(iCommCount <=0)
    {
        WriteLog(ERROR, "COMM_MON_COUNT����ֵ[%d]����ȷ!", iCommCount);

        return FAIL;
    }

    /* д��ϸ��Ϣ�ļ������ݿ�sysinfo�ֶ� */
    fprintf(fpStatusFile, "ͨѶ�˿�״̬\x0D\x0A");
    fprintf(fpStatusFile, "********************************************************************************\x0D\x0A");

    /* д״̬��Ϣ�����ݿ�comm_status�ֶ� */
    iIndex = 0;

    /* ״̬��Ϣ 1.ͨѶ�˿ڸ���*/
    sprintf(szChkStatus, "%d|", iCommCount);
    iIndex += strlen(szChkStatus);

    /* ѭ����ȡͨѶ�˿�״̬��Ϣ */
    for(i=1;i<=iCommCount;i++)
    {    
        /* ��ȡͨѶ�˿������� */
        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        memset(szComments, 0, sizeof(szComments));
        sprintf(szTmpBuf, "COMM_COMMENTS_%d", i);
        if(ReadConfig(CONFIG_FILENAME, SECTION_EPAYMONI, szTmpBuf, szComments) != SUCC)
        {
            WriteLog(ERROR, "��ȡ�����ļ�[%s] SECTION:[%s] ������:[%s] ʧ��!",
                     CONFIG_FILENAME, SECTION_EPAYMONI, szTmpBuf);

            return FAIL;
        }

        /* ��ȡͨѶ�˿����� */
        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        memset(szValueBuf, 0, sizeof(szValueBuf));
        sprintf(szTmpBuf, "COMM_TYPE_%d", i);
        if(ReadConfig(CONFIG_FILENAME, SECTION_EPAYMONI, szTmpBuf, szValueBuf) != SUCC)
        {
            WriteLog(ERROR, "��ȡ�����ļ�[%s] SECTION:[%s] ������:[%s] ʧ��!",
                     CONFIG_FILENAME, SECTION_EPAYMONI, szTmpBuf);

            return FAIL;
        }
        iType = atoi(szValueBuf);

        /* ��ȡ������IP��ַ */
        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        memset(szServIP, 0, sizeof(szServIP));
        sprintf(szTmpBuf, "COMM_SERV_IP_%d", i);
        if(ReadConfig(CONFIG_FILENAME, SECTION_EPAYMONI, szTmpBuf, szServIP) != SUCC)
        {
            WriteLog(ERROR, "��ȡ�����ļ�[%s] SECTION:[%s] ������:[%s] ʧ��!",
                     CONFIG_FILENAME, SECTION_EPAYMONI, szTmpBuf);

            return FAIL;
        }

        /* ��ȡ�����������˿� */
        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        memset(szValueBuf, 0, sizeof(szValueBuf));
        sprintf(szTmpBuf, "COMM_SERV_PORT_%d", i);
        if(ReadConfig(CONFIG_FILENAME, SECTION_EPAYMONI, szTmpBuf, szValueBuf) != SUCC)
        {
            WriteLog(ERROR, "��ȡ�����ļ�[%s] SECTION:[%s] ������:[%s] ʧ��!",
                     CONFIG_FILENAME, SECTION_EPAYMONI, szTmpBuf);

            return FAIL;
        }
        iServPort = atoi(szValueBuf);

        /* ��ȡ���ؼ����˿� */
        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        memset(szValueBuf, 0, sizeof(szValueBuf));
        sprintf(szTmpBuf, "COMM_LOCAL_PORT_%d", i);
        if(ReadConfig(CONFIG_FILENAME, SECTION_EPAYMONI, szTmpBuf, szValueBuf) != SUCC)
        {
            WriteLog(ERROR, "��ȡ�����ļ�[%s] SECTION:[%s] ������:[%s] ʧ��!",
                     CONFIG_FILENAME, SECTION_EPAYMONI, szTmpBuf);

            return FAIL;
        }
        iLocalPort = atoi(szValueBuf);

        /* ͨѶ״̬Ĭ��ΪY */
        cCommStatus = STATUS_YES;

        switch(iType)
        {
            /* ˫����������� */
            case DUPLEX_KEEPALIVE_SERV:
                if(ChkDKSStatus(szComments, iLocalPort, &cCommStatus) != SUCC)
                {
                    return FAIL;
                }
                break;
            /* ˫�������ͻ��� */
            case DUPLEX_KEEPALIVE_CLIT:
                if(ChkDKCStatus(szComments, szServIP, iServPort, &cCommStatus) != SUCC)
                {
                    return FAIL;
                }
                break;
            /* �������� */
            case SIMPLEX_KEEPALIVE:
                if(ChkSKStatus(szComments, iLocalPort, szServIP, iServPort, &cCommStatus) != SUCC)
                {
                    return FAIL;
                }
                break;
            /* ˫����������� */
            case DUPLEX_SERVER:
                if(ChkDSStatus(szComments, iLocalPort, &cCommStatus) != SUCC)
                {
                    return FAIL;
                }            
                break;
            default:
                return FAIL;
        }

        /* ״̬��Ϣ 2.ͨѶ�˿�״̬ */
        memset(szStatus, 0, sizeof(szStatus));
        sprintf(szStatus, "%c,%s#", cCommStatus, szComments);

        memcpy(szChkStatus+iIndex, szStatus, strlen(szStatus));
        iIndex += strlen(szStatus);

        /* ��ϸ��Ϣ�ļ� ���� */
        fprintf(fpStatusFile, "\x0D\x0A");
    }

    /* ״̬��Ϣ ������־ */
    szChkStatus[iIndex] = '|';
    iIndex += 1;

    /* ��ϸ��Ϣ�ļ� ������־ */
    fprintf(fpStatusFile, "********************************************************************************\x0D\x0A");

    return SUCC;
}

/****************************************************************
** ��    �ܣ����˫�����������״̬
** ���������
**        szComments            ͨѶ��������
**        iLocalPort            ���ؼ����˿�
** ���������
**        pcCommStatus          ����״̬ Y������ N���쳣
** �� �� ֵ��
**        SUCC                  ���ɹ�
**        FAIL                  ���ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/10/31
** ����˵����
**        1.������˶˿ڼ���״̬
**        2.���ͻ�������״̬
** �޸���־��
****************************************************************/
int ChkDKSStatus(char *szComments, int iLocalPort, char *pcCommStatus)
{
    char szInfo[1024+1];
    char cStatus;

    /* ������״̬ */
    memset(szInfo, 0, sizeof(szInfo));
    if(ChkServListen(iLocalPort, szInfo, &cStatus) != SUCC)
    {
        return FAIL;
    }

    /* �ж�״̬ */
    if(cStatus == 'N')
    {
        *pcCommStatus = cStatus;
    }

    /* ��״̬��Ϣд����ϸ�ļ� */
    fprintf(fpStatusFile, "%s �����˿�:[%d]\x0D\x0A", szComments, iLocalPort);
    fprintf(fpStatusFile, "����״̬:\x0D\x0A");
    fprintf(fpStatusFile, "%s", szInfo);

    /* ���ͻ�������״̬ */
    memset(szInfo, 0, sizeof(szInfo));
    if(ChkClitConnection(iLocalPort, szInfo, &cStatus) != SUCC)
    {
        return FAIL;
    }

    /* �ж�״̬ */
    if(cStatus == 'N')
    {
        *pcCommStatus = cStatus;
    }

    /* ��״̬��Ϣд����ϸ�ļ� */
    fprintf(fpStatusFile, "����״̬:\x0D\x0A");
    fprintf(fpStatusFile, "%s", szInfo);

    return SUCC;
}

/****************************************************************
** ��    �ܣ����˫�������ͻ���״̬
** ���������
**        szComments            ͨѶ��������
**        szServIP              ������IP��ַ
**        iServPort             �������˿�
** ���������
**        pcCommStatus          ����״̬ Y������ N���쳣
** �� �� ֵ��
**        SUCC                  ���ɹ�
**        FAIL                  ���ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/10/31
** ����˵����
**        1.�������������״̬
** �޸���־��
****************************************************************/
int ChkDKCStatus(char *szComments, char *szServIP, int iServPort, char *pcCommStatus)
{
    char    szInfo[1024+1];             /* �˿�״̬��Ϣ */
    char    cStatus;                    /* �˿�״̬ */

    /* �������������״̬ */
    memset(szInfo, 0, sizeof(szInfo));
    if(ChkServConnection(szServIP, iServPort, szInfo, &cStatus) != SUCC)
    {
        return FAIL;
    }

    /* �ж�״̬ */
    if(cStatus == 'N')
    {
        *pcCommStatus = cStatus;
    }

    /* ��״̬��Ϣд����ϸ�ļ� */
    fprintf(fpStatusFile, "%s ��������ַ:[%s:%d]\x0D\x0A", szComments, szServIP, iServPort);
    fprintf(fpStatusFile, "����״̬:\x0D\x0A");
    fprintf(fpStatusFile, "%s", szInfo);

    return SUCC;
}

/****************************************************************
** ��    �ܣ���鵥������״̬
** ���������
**        szComments            ͨѶ��������
**        iLocalPort            ���ؼ����˿�
**        szServIP              ������IP��ַ
**        iServPort             �������˿�
** ���������
**        pcCommStatus          ����״̬ Y������ N���쳣
** �� �� ֵ��
**        SUCC                  ���ɹ�
**        FAIL                  ���ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/10/31
** ����˵����
**        1.������˶˿ڼ���״̬
**        2.�������������״̬
**        3.���ͻ�������״̬
** �޸���־��
****************************************************************/
int ChkSKStatus(char *szComments, int iLocalPort, char *szServIP, int iServPort, char *pcCommStatus)
{
    char    szInfo[1024+1];             /* �˿�״̬��Ϣ */
    char    cStatus;                    /* �˿�״̬ */
    
    /* ������״̬ */
    memset(szInfo, 0, sizeof(szInfo));
    if(ChkServListen(iLocalPort, szInfo, &cStatus) != SUCC)
    {
        return FAIL;
    }

    /* �ж�״̬ */
    if(cStatus == 'N')
    {
        *pcCommStatus = cStatus;
    }

    /* ��״̬��Ϣд����ϸ�ļ� */
    fprintf(fpStatusFile, "%s ���ض˿�:[%d] ��������ַ:[%s:%d]\x0D\x0A", szComments, iLocalPort, szServIP, iServPort);
    fprintf(fpStatusFile, "����״̬:\x0D\x0A");
    fprintf(fpStatusFile, "%s", szInfo);

    /* �������������״̬ */
    memset(szInfo, 0, sizeof(szInfo));
    if(ChkServConnection(szServIP, iServPort, szInfo, &cStatus) != SUCC)
    {
        return FAIL;
    }

    /* �ж�״̬ */
    if(cStatus == 'N')
    {
        *pcCommStatus = cStatus;
    }

    /* ��״̬��Ϣд����ϸ�ļ� */
    fprintf(fpStatusFile, "����״̬:\x0D\x0A");
    fprintf(fpStatusFile, "%s", szInfo);

    /* ���ͻ�������״̬ */
    memset(szInfo, 0, sizeof(szInfo));
    if(ChkClitConnection(iLocalPort, szInfo, &cStatus) != SUCC)
    {
        return FAIL;
    }

    /* �ж�״̬ */
    if(cStatus == 'N')
    {
        *pcCommStatus = cStatus;
    }

    /* ��״̬��Ϣд����ϸ�ļ� */
    fprintf(fpStatusFile, "%s", szInfo);

    return SUCC;
}

/****************************************************************
** ��    �ܣ����˫�����������״̬
** ���������
**        szComments            ͨѶ��������
**        iLocalPort            ���ؼ����˿�
** ���������
**        pcCommStatus          ����״̬ Y������ N���쳣
** �� �� ֵ��
**        SUCC                  ���ɹ�
**        FAIL                  ���ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/10/31
** ����˵����
**        1.������˶˿ڼ���״̬
** �޸���־��
****************************************************************/
int ChkDSStatus(char *szComments, int iLocalPort, char *pcCommStatus)
{
    char szInfo[1024+1];             /* �˿�״̬��Ϣ */
    char cStatus;                    /* �˿�״̬ */
    
    /* ������״̬ */
    memset(szInfo, 0, sizeof(szInfo));
    if(ChkServListen(iLocalPort, szInfo, &cStatus) != SUCC)
    {
        return FAIL;
    }

    /* �ж�״̬ */
    if(cStatus == 'N')
    {
        *pcCommStatus = cStatus;
    }

    /* ��״̬��Ϣд����ϸ�ļ� */
    fprintf(fpStatusFile, "%s �����˿�:[%d]\x0D\x0A", szComments, iLocalPort);
    fprintf(fpStatusFile, "����״̬:\x0D\x0A");
    fprintf(fpStatusFile, "%s", szInfo);

    return SUCC;
}

/****************************************************************
** ��    �ܣ������������״̬
** ���������
**        iPort                 ���ؼ����˿�
** ���������
**        szInfo                ������Ϣ
**        pcStatus              ����״̬ Y������ N���쳣
** �� �� ֵ��
**        SUCC                  ���ɹ�
**        FAIL                  ���ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/10/31
** ����˵����
**        ���˿ڴ��ڼ���״̬���ҷ��͡����վ���������������״̬ΪY������ΪN
** �޸���־��
****************************************************************/
int ChkServListen(int iPort, char *szInfo, char *pcStatus)
{
    FILE *fp;
    char szCmd[256+1];
    char szField1[32+1], szField4[32+1], szField5[32+1], szField6[32+1];
    int iRecvQ, iSendQ;
    
    memset(szCmd, 0, sizeof(szCmd));
    
    sprintf(szCmd, "netstat -an | grep %d | awk '{if($4==\"%s%c%d\" && $6==\"LISTEN\") print $0}'",
        iPort, cnServListenIP, cnSplit, iPort);

    fp = popen(szCmd, "r");
    if(fp == NULL)
    {
        WriteLog(ERROR, "ִ��popenʧ��!CMD:[%s]", szCmd);
        return FAIL;
    }

    /* ��ȡshellִ�н�� */
    memset(szField1, 0, sizeof(szField1));
    memset(szField4, 0, sizeof(szField4));
    memset(szField5, 0, sizeof(szField5));
    memset(szField6, 0, sizeof(szField6));
    
    /* Ĭ��״̬���� */
    *pcStatus = STATUS_YES;

    if(fscanf(fp, "%s %d %d %s %s %s",
        szField1, &iRecvQ, &iSendQ, szField4, szField5, szField6) != EOF)
    {
        /* �ж��Ƿ����������� */
        if(iRecvQ > 0 || iSendQ > 0)
        {
            *pcStatus = STATUS_NO;
        }
        
        sprintf(szInfo, "%s    %d    %d    %s                %s                %s\x0D\x0A",
            szField1, iRecvQ, iSendQ, szField4, szField5, szField6);
    }
    else
    {
        *pcStatus = STATUS_NO;
    }

    pclose(fp);

    return SUCC;
}

/****************************************************************
** ��    �ܣ������������״̬
** ���������
**        szIP              �����IP��ַ
**        iPort             ����˼����˿�
** ���������
**        szInfo            ������Ϣ
**        pcStatus          ����״̬ Y������ N���쳣
** �� �� ֵ��
**        SUCC              ���ɹ�
**        FAIL              ���ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/10/31
** ����˵����
**        �������˽������ӣ��ҷ��͡����վ�������������������״̬ΪY������ΪN
** �޸���־��
****************************************************************/
int ChkServConnection(char *szIP, int iPort, char *szInfo, char *pcStatus)
{
    FILE    *fp;                    /* �ļ�ָ�� */
    char    szCmd[256+1];           /* �˿�״̬��ѯ���� */
    char    szField1[32+1];         /* �����һ�� Э������ */
    int     iRecvQ;                 /* ͨѶ���ն��� */
    int     iSendQ;                 /* ͨѶ���Ͷ��� */
    char    szField4[32+1];         /* ��������� �����IP���˿� */
    char    szField5[32+1];         /* ��������� �ͻ���IP���˿� */
    char    szField6[32+1];         /* ��������� ״̬ */ 
    char    szTmpBuf[128+1];        /* ��ʱ���� */
    int     iConnCount;             /* ���Ӹ��� */
    int     iIndex;                 /* �ַ������� */

    memset(szCmd, 0, sizeof(szCmd));

    sprintf(szCmd,
            "netstat -an | grep %d | awk '{if($5==\"%s%c%d\" && $6==\"ESTABLISHED\") print $0}'",
            iPort, szIP, cnSplit, iPort);

    fp = popen(szCmd, "r");
    if(fp == NULL)
    {
        WriteLog(ERROR, "ִ��popenʧ��!CMD:[%s]", szCmd);

        return FAIL;
    }

    /* ��ȡshellִ�н�� */
    memset(szField1, 0, sizeof(szField1));
    memset(szField4, 0, sizeof(szField4));
    memset(szField5, 0, sizeof(szField5));
    memset(szField6, 0, sizeof(szField6));

    /* Ĭ��״̬���� */
    iConnCount = 0;
    iIndex = 0;
    *pcStatus = STATUS_YES;

    while(1)
    {
        if(fscanf(fp, "%s %d %d %s %s %s",
            szField1, &iRecvQ, &iSendQ, szField4, szField5, szField6) != EOF)
        {
            /* �ж��Ƿ����������� */
            if(iRecvQ > 0 || iSendQ > 0)
            {
                *pcStatus = STATUS_NO;
            }

            sprintf(szTmpBuf, "%s    %d    %d    %s        %s        %s\x0D\x0A",
                    szField1, iRecvQ, iSendQ, szField4, szField5, szField6);

            strcpy(szInfo+iIndex, szTmpBuf);
            iIndex += strlen(szTmpBuf);

            iConnCount++;
        }
        else
        {
            break;
        }
    }

    if(iConnCount == 0)
    {
        *pcStatus = STATUS_NO;
    }

    pclose(fp);

    return SUCC;
}

/****************************************************************
** ��    �ܣ����ͻ�������״̬
** ���������
**        iPort                 ���ؼ����˿�
** ���������
**        szInfo                ������Ϣ
**        pcStatus              ����״̬ Y������ N���쳣
** �� �� ֵ��
**        SUCC                  ���ɹ�
**        FAIL                  ���ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/10/31
** ����˵����
**        ��������һ���ͻ��˽������ӣ������пͻ�������
**        ���͡����վ�������������������״̬ΪY������ΪN
** �޸���־��
****************************************************************/
int ChkClitConnection(int iPort, char *szInfo, char *pcStatus)
{
    int     i;
    FILE    *fp;                    /* �ļ�ָ�� */
    char    szCmd[256+1];           /* �˿�״̬��ѯ���� */
    char    szField1[32+1];         /* �����һ�� Э������ */
    int     iRecvQ;                 /* ͨѶ���ն��� */
    int     iSendQ;                 /* ͨѶ���Ͷ��� */
    char    szField4[32+1];         /* ��������� �����IP���˿� */
    char    szField5[32+1];         /* ��������� �ͻ���IP���˿� */
    char    szField6[32+1];         /* ��������� ״̬ */ 
    char    szTmpBuf[128+1];        /* ��ʱ���� */
    int     iTmp;                   /* ��ʱ���� */
    int     iConnCount;             /* ���Ӹ��� */
    int     iIndex;                 /* �ַ������� */

    memset(szCmd, 0, sizeof(szCmd));

    sprintf(szCmd,
            "netstat -an | grep '%c%d ' | awk '{if($6==\"ESTABLISHED\") print $0}'", cnSplit, iPort);

    fp = popen(szCmd, "r");
    if(fp == NULL)
    {
        WriteLog(ERROR, "ִ��popenʧ��!CMD:[%s]", szCmd);

        return FAIL;
    }

    /* Ĭ��״̬���� */
    *pcStatus = STATUS_YES;
    iConnCount = 0;
    iIndex = 0;

    while(1)
    {
        if(fscanf(fp, "%s %d %d %s %s %s\n",
                  szField1, &iRecvQ, &iSendQ, szField4, szField5, szField6) != EOF)
        {
            /* �жϼ����˿��Ƿ���ȷ */
            for(i=(strlen(szField4)-1);i>=0;i--)
            {
                if(szField4[i] == cnSplit)
                {
                    break;
                }
            }

            iTmp = atoi(szField4+i+1);

            if(iTmp != iPort)
            {
                continue;
            }

            /* �ж��Ƿ����������� */
            if(iRecvQ > 0 || iSendQ > 0)
            {
                *pcStatus = STATUS_NO;
            }

            memset(szTmpBuf, 0, sizeof(szTmpBuf));
            sprintf(szTmpBuf, "%s    %d    %d    %s        %s        %s\x0D\x0A",
                    szField1, iRecvQ, iSendQ, szField4, szField5, szField6);
            strcpy(szInfo+iIndex, szTmpBuf);
            iIndex += strlen(szTmpBuf);

            iConnCount++;
        }
        else
        {
            break;
        }
    }

    if(iConnCount == 0)
    {
        *pcStatus = STATUS_NO;
    }

    pclose(fp);

    return SUCC;
}
