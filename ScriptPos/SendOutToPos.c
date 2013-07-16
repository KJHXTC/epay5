/*******************************************************************************
 * Copyright(C)2012��2015 �������������豸���޹�˾
 * ��Ҫ���ݣ������ն�Ӧ����
 * �� �� �ˣ�Robin
 * �������ڣ�2012/12/11
 *
 * $Revision: 1.1 $
 * $Log: SendOutToPos.c,v $
 * Revision 1.1  2013/01/18 08:32:37  fengw
 *
 * 1����ֺ�����
 *
 ******************************************************************************/

#define _EXTERN_

#include "ScriptPos.h"

/*******************************************************************************
 * �������ܣ������ն�Ӧ����
 * ���������
 *           ptApp  - �������ݽṹ
 * ���������
 *           ��
 * �� �� ֵ�� 
 *           SUCC               �ɹ�
 *           FAIL               ʧ�� 
 * ��    �ߣ�Robin
 * ��    �ڣ�2012/11/20
 *
 ******************************************************************************/

int SendOutToPos(T_App *ptApp, int iSockFd)
{
    uchar   szSndBuf[BUFFSIZE];         /* Ӧ���� */
    int     iLen;                       /* Ӧ���ĳ��� */
    char    szFirstPage[256+1];         /* ��ҳ��Ϣ */
    int     iFirstPageLen;              /* ��ҳ��Ϣ���� */

    /* �����ҳ��Ϣ */
    memset(szFirstPage, 0, sizeof(szFirstPage));
    iFirstPageLen = 0;
    CheckFirstPage(ptApp, &iFirstPageLen, szFirstPage);

    iLen = PackScriptPos(ptApp, szFirstPage, iFirstPageLen, szSndBuf);
    if(iLen == FAIL)
    {
        WriteLog(ERROR, "POSӦ�������ʧ��!");

        FreeTdi(ptApp->lTransDataIdx);

        return FAIL;
    }

    WriteHdLog(szSndBuf, iLen, "ScriptPos send to pos");

    if(WriteSockAddLenField(iSockFd, szSndBuf, iLen, 0, 2, HEX_DATA) == FAIL)
    {
        WriteLog(ERROR, "����POSӦ�������ʧ��!");

        FreeTdi(ptApp->lTransDataIdx);

        return FAIL;
    }

    if(strlen(ptApp->szNextTransCode) == 0)
    {
        FreeTdi(ptApp->lTransDataIdx);
    }

    return SUCC;
}