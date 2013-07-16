/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨epay������ ��ȡ�����ļ���
** �� �� �ˣ����
** �������ڣ�2012-12-10
**
** $Revision: 1.3 $
** $Log: GetFullName.c,v $
** Revision 1.3  2012/12/20 09:25:54  wukj
** Revision�����Ԫ��
**
*******************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/****************************************************************
** ��    �ܣ���ȡ�����ļ���
** ���������
**        szEnvName                 ����������
**        szFileName                ���ļ���
** ���������
**        szFullFileName            �����ļ���
** �� �� ֵ��
**        char*                     �����ļ���
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/12/10
** ����˵����
**
** �޸���־��
****************************************************************/
char* GetFullName(char* szEnvName, char* szFileName, char* szFullFileName)
{
    char    szEnv[64+1];

    memset(szEnv, 0, sizeof(szEnv));
    if(getenv(szEnvName) != NULL)
    {
        strcpy(szEnv, getenv(szEnvName));
    }
    else
    {
        strcpy(szEnv, "/");
    }

    sprintf(szFullFileName, "%s%s", szEnv, szFileName);

    return szFullFileName;
}
