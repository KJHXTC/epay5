/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� ���ͽ�������
** �� �� �ˣ����
** �������ڣ�2012-11-13
**
** $Revision: 1.3 $
** $Log: SendReqToHost.ec,v $
** Revision 1.3  2012/12/11 07:00:58  fengw
**
** 1������̨��������ʱ���ȵ���ChkHostStatus�ж�ͨѶ״̬��������ֱ�ӷ���ϵͳ���ϡ�
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
** ��    �ܣ�����POSӦ������·�������
** ���������
**        ptApp                 app�ṹָ��
**        lTimeOut              ���׳�ʱʱ��
** ���������
**        ��
** �� �� ֵ��
**        ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/13
** ����˵����
**
** �޸���־��
****************************************************************/
int SendReqToHost(T_App *ptApp)
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szShopNo[15+1];         /* �̻��� */
        char    szPosNo[15+1];          /* �ն˺� */
        int     iPosTrace;              /* �ն���ˮ�� */
        char    szPosDate[8+1];         /* POS�������� */
    EXEC SQL END DECLARE SECTION;

    int     iRet;                       /* ����ִ�н�� */
    long    lTransDataIdx;              /* �������������� */

    /* ��app�ṹ���ݱ����������ڴ� */
    if(SetApp(ptApp->lTransDataIdx, ptApp) != SUCC)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "����app�ṹ�������ڴ�ʧ��!TransDataIdx:[%ld]",
                 ptApp->lTransDataIdx);

        return FAIL;
    }
    
    /* �жϺ�̨ͨѶ״̬�Ƿ����� */
    if(ChkHostStatus(ptApp->lProcToPresentMsgType) != SUCC)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "��̨ MsgType:[%d] ͨѶ״̬�쳣!", ptApp->lProcToPresentMsgType);

        return FAIL;
    }

    /* ���ͽ�����������̨ */
    if(SendProcToPresentQue(ptApp->lProcToPresentMsgType, ptApp->lTransDataIdx) != SUCC)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "���ͽ�������ʧ��!MsgType:[%ls] TransDataIdx:[%ld]",
            ptApp->lProcToPresentMsgType, ptApp->lTransDataIdx);

        return FAIL;
    }

    /* **********����SendToHost��������RecvFromHost���ý���֮ǰ�Ͻ�д�κζ�app�ṹ��������********** */

    /*����etc/setup.ini�����ý��״���ʱʱ��*/
    glTimeOut=30;
    /* �ȴ���̨����Ӧ�� */
    /* ѭ�����պ�̨Ӧ��ֱ�����յ���ȷӦ���ʱ */
    while(1)
    {
        iRet = RecvPresentToProcQue(ptApp->lPresentToProcMsgType, glTimeOut, &lTransDataIdx);
        if(iRet == TIMEOUT)
        {
            strcpy(ptApp->szRetCode, ERR_TIMEOUT);

            WriteLog(ERROR, "���ս���Ӧ��ʱ!MsgType:[%ld]", ptApp->lPresentToProcMsgType);

            /* ������ˮ״̬ΪTO */
            memset(szShopNo, 0, sizeof(szShopNo));
            memset(szPosNo, 0, sizeof(szPosNo));
            memset(szPosDate, 0, sizeof(szPosDate));

            strcpy(szShopNo, ptApp->szShopNo);
            strcpy(szPosNo, ptApp->szPosNo);
            iPosTrace = ptApp->lPosTrace;
            strcpy(szPosDate, ptApp->szPosDate);

            EXEC SQL
                UPDATE posls SET return_code = 'TO'
                WHERE shop_no = :szShopNo AND pos_no = :szPosNo AND
                      pos_trace = :iPosTrace AND pos_date = :szPosDate AND
                      cancel_flag = 'N' AND recover_flag = 'N' AND pos_settle = 'N' AND
                      return_code = 'NN';
            if(SQLCODE && SQLCODE != SQL_NO_RECORD)
            {
                WriteLog(ERROR, "������ˮ״̬ �̻�[%s] �ն�[%s] POS��ˮ[%d] ʧ��!SQLCODE=%d SQLERR=%s",
                         szShopNo, szPosNo, iPosTrace, SQLCODE, SQLERR);
            }
            CommitTran();

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
