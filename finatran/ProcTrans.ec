/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� ���״���
** �� �� �ˣ����
** �������ڣ�2012-11-08
**
** $Revision: 1.7 $
** $Log: ProcTrans.ec,v $
** Revision 1.7  2013/06/14 06:26:08  fengw
**
** 1������SetEnvTransId���ô��롣
**
** Revision 1.6  2013/03/11 07:11:31  fengw
**
** 1�����ݱ�־λ���жϽ����Ƿ���Ҫ��������̨��
**
** Revision 1.5  2013/01/18 08:25:22  fengw
**
** 1��ɾ��δʹ�ñ������塣
**
** Revision 1.4  2012/12/24 08:22:15  fengw
**
** 1���޸Ľ��״���ʧ�ܺ�Ǽ��Զ�������ˮ����
**
** Revision 1.3  2012/12/07 02:03:23  fengw
**
** 1������app�ṹ��־��¼��
** 2�������쳣�Զ��Ǽǳ�����ˮ��
**
** Revision 1.2  2012/12/04 01:24:28  fengw
**
** 1���滻ErrorLogΪWriteLog��
**
** Revision 1.1  2012/11/23 09:09:16  fengw
**
** ���ڽ��״���ģ���ʼ�汾
**
** Revision 1.1  2012/11/21 07:20:46  fengw
**
** ���ڽ��״���ģ���ʼ�汾
**
*******************************************************************/

#define _EXTERN_

#include "finatran.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ����״���
** ���������
**        lMsgType              ������Ϣ����
**        lTimeOut              ���׳�ʱʱ��
** ���������
**        ��
** �� �� ֵ��
**        ��                    ѭ�������ף�ֱ��ģ������˳�
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/13
** ����˵����
**
** �޸���־��
****************************************************************/
void ProcTrans(long lMsgType)
{
    int     i;
    long    lPid;                       /* ��ǰ���̺� */
    long    lTransDataIdx;              /* �������������� */
    T_App   tApp;                       /* app�ṹ */
    int     (*pFuncPre)(T_App*);        /* ����Ԥ������ָ�� */
    int     (*pFuncPost)(T_App*);       /* ���׺�����ָ�� */
    int     iSendToHost;                /* ���ͺ�̨��־ */

    /* ��ȡ��ǰ���̺� */
    lPid = getpid();

    while(1)
	{
	    /* �ȴ����ս������� */
		if(RecvAccessToProcQue(lMsgType, 0, &lTransDataIdx) != SUCC)
		{
			WriteLog(ERROR, "���ս�������ʧ��!MsgType:[%ld]", lMsgType);

			continue;
		}

        /* �ж����ݿ��Ƿ��*/
        if(ChkDBLink() != SUCC && OpenDB() != SUCC)
        {
            WriteLog(ERROR, "�����ݿ�ʧ��!");

            continue;
        }

		/* ��app�ṹָ��ָ�����ڴ� */
        if(GetApp(lTransDataIdx, &tApp) != SUCC)
        {
            SendRspToPos(&tApp);

            continue;
        }

        /* ������־��¼�İ�ȫģ��� */
        SetEnvTransId(tApp.szPsamNo);

        /* ���ý�����Ϣ���� */
        tApp.lPresentToProcMsgType = lPid;;

        /* ��ȡϵͳ��ˮ�� */
        if(GetSysTrace(&tApp) != SUCC)
        {
            SendRspToPos(&tApp);

            continue;
        }

        /* �Ϸ��Լ�� */
        if(ChkValid(&tApp) != SUCC)
        {
            SendRspToPos(&tApp);

            continue;
        }

        /* ���ײ������ */
        if(ChkEpayConf(&tApp) != SUCC)
        {
            SendRspToPos(&tApp);

            continue;
        }

        /* ��ȡ���״�����ָ�� */
        /* Ĭ���޴��� */
        pFuncPre = NULL;
        pFuncPost = NULL;
        i = 0;

        while(1)
        {
            if(gtaTransProc[i].iTransType == 0)
            {
                /* δ���彻�� */
                strcpy(tApp.szRetCode, ERR_INVALID_TRANS);

                WriteLog(ERROR, "��������[%d]δ����!", tApp.iTransType);

                SendRspToPos(&tApp);

                continue;
            }

            if(gtaTransProc[i].iTransType == tApp.iTransType)
            {
                pFuncPre = gtaTransProc[i].pFuncPre;

                pFuncPost = gtaTransProc[i].pFuncPost;

                iSendToHost = gtaTransProc[i].iSendToHost;

                break;
            }

            i++;
        }

        /* ����Ԥ���� */
        if(pFuncPre != NULL && pFuncPre(&tApp) != SUCC)
        {

             SendRspToPos(&tApp);

             continue;
        }

        /* ��¼app�ṹ��Ϣ */
        WriteAppStru(&tApp, "finatran send to tohost");

        /* ���ͽ������󵽺�̨ */
        if(iSendToHost == SEND && SendReqToHost(&tApp) != SUCC)
        {
            if(memcmp(tApp.szRetCode, ERR_TIMEOUT, 2) == 0 &&
            tApp.cExcepHandle == POS_MUST_VOID &&
            InsertVoidls(&tApp) != SUCC )
            {   
                    WriteLog(ERROR, "�Ǽǳ�����ˮ��¼ʧ��!");
                    continue;
            }   
            WriteLog( ERROR, "time out recv return");
            SendRspToPos(&tApp);

            continue;
        }

        /* ��¼app�ṹ��Ϣ */
        WriteAppStru(&tApp, "finatran recv from tohost");

        /* ���׺��� */
        if(pFuncPost != NULL && pFuncPost(&tApp) != SUCC &&
           tApp.cExcepHandle == POS_MUST_VOID && InsertVoidls(&tApp) != SUCC)
        {
            /* ����ʧ�ܣ�������׶�������Ҫ��������Ǽ��Զ�������ˮ */
            WriteLog(ERROR, "�Ǽǳ�����ˮ��¼ʧ��!");

            continue;
        }

        SendRspToPos(&tApp);
    }
}
