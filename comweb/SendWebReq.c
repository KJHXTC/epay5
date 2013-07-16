/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨web�����������ģ�� ��manatran����������
** �� �� �ˣ����
** �������ڣ�2012-12-18
**
** $Revision: 1.3 $
** $Log: SendWebReq.c,v $
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
** ��    �ܣ���manatran���������󣬲����ս���Ӧ��
** ���������
**        ptApp                 app�ṹָ��
**        lTimeOut              ���׳�ʱʱ��
** ���������
**        ��
** �� �� ֵ��
**        SUCC                  �ɹ�
**        FAIL                  ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/12/18
** ����˵����
**
** �޸���־��
****************************************************************/
int SendWebReq(T_App *ptApp, long lTimeOut)
{
    int     iRet;                           /* ������� */
    int     lTransDataIdx;                  /* ������������ */

    /* �ж�IP��ַ */
    if(strlen(ptApp->szIp) < 7)
    {
        WriteLog(ERROR, "�̻�[%s] �ն�[%s] �Ǽ�IP��ַ����!",
                 ptApp->szShopNo, ptApp->szPosNo, ptApp->szIp);

        strcpy(ptApp->szRetCode, ERR_TERM_NOT_REGISTER);

        return FAIL;
    }

    /* ���ý���Ӧ����Ϣ���� */
    ptApp->lProcToAccessMsgType = getpid();

    /* ��app�ṹ���ݱ����������ڴ� */
    if(SetApp(ptApp->lTransDataIdx, ptApp) != SUCC)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "����app�ṹ�������ڴ�ʧ��!TransDataIdx:[%ld]",
                 ptApp->lTransDataIdx);

        return FAIL;
    }

    /* ���ͽ������� */
    iRet = SendAccessToProcQue(ptApp->lAccessToProcMsgType, ptApp->lTransDataIdx);
    if(iRet != SUCC)
    {
        WriteLog(ERROR, "���ͽ�������ʧ��!MsgType:[%ls] TransDataIdx:[%ld]",
                 ptApp->lAccessToProcMsgType, ptApp->lTransDataIdx);

        return FAIL;
    }

    /* ���ս���Ӧ�� */
    /* ѭ������Ӧ��ֱ�����յ���ȷӦ���ʱ */
    while(1)
    {
        iRet = RecvProcToAccessQue(ptApp->lProcToAccessMsgType, lTimeOut, &lTransDataIdx);
        if(iRet == TIMEOUT)
        {
            strcpy(ptApp->szRetCode, ERR_TIMEOUT);

            WriteLog(ERROR, "���ս���Ӧ��ʱ!MsgType:[%ls]", ptApp->lProcToAccessMsgType);

            return FAIL;
        }

        /* �ж���������ֵ�Ƿ�һ�� */
        /* ��һ�±�ʾ���յ�����Ӧ����������ȴ����� */
        if(ptApp->lTransDataIdx != lTransDataIdx)
        {
            WriteLog(ERROR, "����Ӧ��ƥ��ʧ��!TransDataIdx ToTrans:[%ls] TransDataIdx FromHost:[%ld]",
                     ptApp->lTransDataIdx, lTransDataIdx);

            continue;
        }

        break;
    }

    /* �������ڴ����ݿ�����app�ṹ */
    if(GetApp(ptApp->lTransDataIdx, ptApp) != SUCC)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "�ӹ����ڴ濽��app�ṹʧ��!TransDataIdx:[%ld]",
                 ptApp->lTransDataIdx);

        return FAIL;
    }

    return SUCC;
}