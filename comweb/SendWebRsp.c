/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨web�����������ģ�� ��web���ͽ���Ӧ��
** �� �� �ˣ����
** �������ڣ�2012-12-19
**
** $Revision: 1.4 $
** $Log: SendWebRsp.c,v $
** Revision 1.4  2012/12/26 08:33:21  fengw
**
** 1������ͨѶԭʼ������־��¼��
**
** Revision 1.3  2012/12/21 02:05:32  fengw
**
** 1�����ļ���ʽ��DOSתΪUNIX��
**
** Revision 1.2  2012/12/21 02:04:03  fengw
**
** 1���޸�Revision��Log��ʽ��
**
*******************************************************************/

#define _EXTERN_

#include "comweb.h"

/****************************************************************
** ��    �ܣ���web���ͽ���Ӧ��
** ���������
**        ptApp                 app�ṹָ��
**        iSockFd               socket������
** ���������
**        ��
** �� �� ֵ��
**        SUCC                  �ɹ�
**        FAIL                  ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/12/19
** ����˵����
**
** �޸���־��
****************************************************************/
int SendWebRsp(T_App *ptApp, int iSockFd)
{
    char    szLenBuf[2+1];                      /* ���ĳ���Buf */
    int     iRet;                               /* �������ý�� */
    int     iLen;                               /* ���ĳ��� */
    char    szRspBuf[MAX_SOCKET_BUFLEN+1];      /* Ӧ���� */

    /* Ӧ������� */
    memset(szRspBuf, 0, sizeof(szRspBuf));
    iLen = PackWebRsp(ptApp, szRspBuf);

    /* ��app�ṹ���ݱ����������ڴ� */
    if(SetApp(ptApp->lTransDataIdx, ptApp) != SUCC)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "����app�ṹ�������ڴ�ʧ��!TransDataIdx:[%ld]",
                 ptApp->lTransDataIdx);

        return FAIL;
    }

    /* ����Ӧ���� */
	memset(szLenBuf, 0, sizeof(szLenBuf));
	szLenBuf[0] = iLen / 256;
	szLenBuf[1] = iLen % 256;

    iRet = WriteSock(iSockFd, szLenBuf, 2, 0);
    if(iRet != 2)
    {
        WriteLog(ERROR, "����Web����Ӧ���ĳ���ʧ��!iRet:[%d]", iRet);

        return FAIL;
    }

    iRet = WriteSock(iSockFd, szRspBuf, iLen , 0);
    if(iRet != iLen)
    {
        WriteLog(ERROR, "����Web����Ӧ����ʧ��!Ԥ�ڷ��ͳ���:[%d] ʵ�ʷ��ͳ���:[%d]", iLen, iRet);

        return FAIL;
    }

    /* ��¼ԭʼͨѶ��־ */
    WriteHdLog(szRspBuf, iLen, "comweb send web rsp");

    return SUCC;
}