/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨web�����������ģ�� Ӧ�������
** �� �� �ˣ����
** �������ڣ�2012-12-18
**
** $Revision: 1.3 $
** $Log: PackWebRsp.c,v $
** Revision 1.3  2012/12/21 07:33:09  fengw
**
** 1����Ӧ��Ϣ���ȸ�Ϊ16���Ƹ�ʽ��
**
** Revision 1.2  2012/12/21 02:04:03  fengw
**
** 1���޸�Revision��Log��ʽ��
**
*******************************************************************/

#define _EXTERN_

#include "comweb.h"

/****************************************************************
** ��    �ܣ�Ӧ�������
** ���������
**        ptApp                 app�ṹָ��
** ���������
**        szRspBuf              ����Ӧ����
** �� �� ֵ��
**        >0                    ���ĳ���
**        FAIL                  ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/12/18
** ����˵����
**
** �޸���־��
****************************************************************/
int PackWebRsp(T_App *ptApp, char *szRspBuf)
{
    int     iIndex;                 /* buf���� */
    int     iMsgCount;              /* ���ż�¼�� */
    int     iRetDescLen;            /* ��Ӧ��Ϣ���� */

    iIndex = 0;

    /* ���״��� */
    memcpy(szRspBuf+iIndex, ptApp->szTransCode, 8);
    iIndex += 8;

    /* ��Ӧ�� */
    memcpy(szRspBuf+iIndex, ptApp->szRetCode, 2);
    iIndex += 2;

    /* ���ݷ�����ȡ������Ϣ */
	if(strlen(ptApp->szRetDesc) == 0)
	{
		GetResult(ptApp->szRetCode, ptApp->szRetDesc);
	}

    /* ��Ӧ��Ϣ���� */
    iRetDescLen = strlen(ptApp->szRetDesc);
    szRspBuf[iIndex] = iRetDescLen;
    iIndex += 1;

    /* ��Ӧ��Ϣ */
	memcpy(szRspBuf+iIndex, ptApp->szRetDesc, iRetDescLen);
    iIndex += iRetDescLen;

    return iIndex;
}