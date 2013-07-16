/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� ���ͽ�������
** �� �� �ˣ����
** �������ڣ�2012-11-13
**
** $Revision: 1.3 $
** $Log: SendVoidReq.c,v $
** Revision 1.3  2012/12/21 01:57:30  fengw
**
** 1���޸�Revision��Log��ʽ��
**
*******************************************************************/

#define _EXTERN_

#include "autovoid.h"

int SendVoidReq(T_App *ptApp, int iTimeOut)
{
    long    lTransDataIndex;

    if(SetApp(ptApp->lTransDataIdx, ptApp) != SUCC)
    {
        return FAIL;
    }

    /* ���ͽ������� */
    if(SendAccessToProcQue(ptApp->lAccessToProcMsgType, ptApp->lTransDataIdx) != SUCC) 
    {
        WriteLog(ERROR, "�����Զ�������������ʧ��!");

        return FAIL;
    }

    /* �ȴ���̨����Ӧ�� */
    /* ѭ�����պ�̨Ӧ��ֱ�����յ���ȷӦ���ʱ */
    while(1)
    {
        if(RecvProcToAccessQue(ptApp->lProcToAccessMsgType, iTimeOut, &lTransDataIndex) != SUCC)
        {
            WriteLog(ERROR, "�������� PsamNo:[%s] PosTrace:[%ld] ��ʱ���ȴ��´γ���!",
                     ptApp->szPsamNo, ptApp->lPosTrace);

            return SUCC;
        }

        /* �ж���������ֵ�Ƿ�һ�� */
        /* ��һ�±�ʾ���յ�����Ӧ����������ȴ����� */
        if(ptApp->lTransDataIdx != lTransDataIndex)
        {
            WriteLog(ERROR, "��������Ӧ��ƥ��ʧ��!TransDataIdx ToTrans:[%ls] TransDataIdx FromHost:[%ld]",
                     ptApp->lTransDataIdx, lTransDataIndex);

            continue;
        }

        break;
    }

    /* �������ڴ����ݿ�����app�ṹ */
    if(GetApp(ptApp->lTransDataIdx, ptApp) != SUCC)
    {
        WriteLog(ERROR, "�ӹ����ڴ濽��app�ṹʧ��!TransDataIdx:[%ld]",
                 ptApp->lTransDataIdx);

        return FAIL;
    }

    return SUCC;
}
