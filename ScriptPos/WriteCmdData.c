/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨epay������ ��¼POSָ������
** �� �� �ˣ�Robin
** �������ڣ�2008/07/31
**
** $Revision: 1.2 $
** $Log: WriteCmdData.c,v $
** Revision 1.2  2013/03/11 07:15:40  fengw
**
** 1�������Զ���ָ���жϴ���
**
** Revision 1.1  2013/01/06 05:29:25  fengw
**
** 1����WriteCmdData��������Ϊ�����ļ���
**
*******************************************************************/

#define _EXTERN_

#include "ScriptPos.h"

/****************************************************************
** ��    �ܣ����ļ�$HOME/log/POSYYYYMMDD.log�м�¼���������
** ���������
**        szCmd                     ָ�����
**        iStep                     ָ���
**        szData                    ��������
**        iLen                      ���ݳ���
** ���������
**        ��
** �� �� ֵ��
**        ��
** ��    �ߣ�
**        Robin
** ��    �ڣ�
**        2008/07/31
** ����˵����
**
** �޸���־��
****************************************************************/
void WriteCmdData(char *szCmd, int iStep, char *szData, int iLen)
{
    FILE    *fp;                            /* �ļ�ָ�� */
    char    szFileName[128+1];              /* ��־�ļ��� */
    char    szDate[8+1];                    /* ���� */
    char    cOrgCmd;                        /* ԭʼָ�� */
    char    szCmdName[MAX_CMD_NAME+1];      /* ָ������ */
    char    szCryptType[3+1];               /* �������� */
    char    szCryptName[64+1];              /* ������������ */
    int     iCmdBytes;                      /* ָ���ֽ��� */
    char    szTmpBuf[1024+1];               /* ��ʱ���� */
    int     i, j;

    memset(szDate , 0 ,sizeof(szDate));
    memset(szFileName, 0, sizeof(szFileName));

    GetSysDate(szDate);
    sprintf(szFileName, "%s/log/POS%s", getenv("WORKDIR"), szDate);
    fp = fopen(szFileName, "a+");
    if(fp == NULL)
    {
        WriteLog(ERROR, "��POSָ����־�ļ�[%s]ʧ��!", szFileName);

        return;
    }

    /* ָ����ʼ����β�ָ� */
    if(memcmp(szData, "RCVBEGIN", 8) == 0)
    {
        fprintf(fp, "from pos begin trace[%ld] TransType[%ld][%s]=======>\n", iStep, iLen, szCmd);
        fclose(fp);
        return;
    }
    else if(memcmp(szData, "RCVEND", 6) == 0)
    {
        fprintf(fp, "from pos end trace[%ld] TransType[%ld][%s]=======>\n", iStep, iLen, szCmd);
        fclose(fp);
        return;
    }
    else if(memcmp(szData, "SNDBEGIN", 8) == 0)
    {
        fprintf(fp, "to pos begin trace[%ld] TransType[%ld][%s]+++++++>\n", iStep, iLen, szCmd);
        fclose(fp);
        return;
    }
    else if(memcmp(szData, "SNDEND", 6) == 0)
    {
        fprintf(fp, "to pos end trace[%ld] TransType[%ld][%s]+++++++>\n\n", iStep, iLen, szCmd);
        fclose(fp);
        return;
    }

    if((szCmd[0] & 0xFF) == SPECIAL_CMD_HEAD)
    {
        iCmdBytes = SPECIAL_CMD_LEN;

        strcpy(szCryptName, "δ����");

        cOrgCmd = (szCmd[SPECIAL_CMD_LEN-1] & 0xFF);

        /* ָ������ */
        memset(szCmdName, 0, sizeof(szCmdName));
        if(cOrgCmd > 0 && cOrgCmd <= MAX_SP_CMD_INDEX)
        {
            strcpy(szCmdName, gszaSpecialCmdName[cOrgCmd-1]);
        }
        else
        {
            strcpy(szCmdName, "δָ֪��");
        }
    }
    else
    {
        /* ����ָ���ֽ��� */
        iCmdBytes = CalcCmdBytes((unsigned char)szCmd[0]);

        /* ��ȡ�������� */
        memset(szCryptName, 0, sizeof(szCryptName));
        memset(szCryptType, 0, sizeof(szCryptType));

        if(iCmdBytes == 3)
        {
            /* δ����-����λ1 */
            if((szCmd[2]&0x80) == 0) 
            {
                strcpy(szCryptName, "δ����"); 
            }
            /* �м���-����λ1 */
            else
            {
                strcpy(szCryptName, "����");
            }
        }
        else
        {
            strcpy(szCryptName, "δ����");
        }

        /* ָ������ */
        cOrgCmd = szCmd[0]&0x3F;
        memset(szCmdName, 0, sizeof(szCmdName));
        if(cOrgCmd > 0 && cOrgCmd <= MAX_CMD_INDEX)
        {
            strcpy(szCmdName, gszaCmdName[cOrgCmd-1]);
        }
        else
        {
            strcpy(szCmdName, "δָ֪��");
        }
    }

    /* ��ӡָ�� */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    for(i=0;i<iCmdBytes;i++)
    {
        sprintf(szTmpBuf+i*3, "%02x ", szCmd[i]&0xFF);
    }

    /* ��ӡָ����־ */
    fprintf(fp, "%2d %s ָ���[%d] ָ��[%s] �����㷨[%s]\n", iStep, szCmdName, iCmdBytes, szTmpBuf, szCryptName);

    if(memcmp(szData, "FF", 2) == 0 && iLen == 2)
    {
        fprintf(fp, "������\n");
        fclose(fp);
        return;
    }

    /* ��ӡ������־ */
    for(i=0;i<iLen;i+=25)
    {
        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        for(j=0;j<25&&(i+j)<iLen;j++)
        {
            sprintf(szTmpBuf+3*j, "%02x ", szData[i+j]&0xff);
        }
        fprintf(fp, "%s\n", szTmpBuf);
    }

    fclose(fp);

    return;
}