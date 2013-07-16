/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� ����֪ͨ����
** �� �� �ˣ����
** �������ڣ�2012-11-16
**
** $Revision: 1.2 $
** $Log: PurNotice.ec,v $
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
    char    szRetriRefNum[12+1];            /* ��̨�����ο��� */
    char    szReturnCode[2+1];              /* ƽ̨������ */
    char    szHostRetCode[6+1];             /* ��̨������ */
    char    szHostRetMsg[40+1];             /* ��̨���ش�����Ϣ */
    char    szAuthCode[6+1];                /* ��Ȩ�� */
    char    szHostDate[8+1];                /* ƽ̨�������� */
    char    szHostTime[6+1];                /* ƽ̨����ʱ�� */
    char    szSettleDate[8+1];              /* �������� */
    int     iBatchNo;                       /* ���κ� */
    char    szBankID[11+1];                 /* ���б�ʶ�� */
    char    szShopNo[15+1];                 /* �̻��� */
    char    szPosNo[15+1];                  /* �ն˺� */
    int     iPosTrace;                      /* �ն���ˮ�� */
    char    szPan[19+1];                    /* ת������ */
    char    szPosDate[8+1];                 /* POS�������� */
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ�����Ԥ����
** ���������
**        ptApp           app�ṹ
** ���������
**        ptApp           app�ṹ
** �� �� ֵ��
**        SUCC            ����ɹ�
**        FAIL            ����ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/16
** ����˵����
**
** �޸���־��
****************************************************************/
int PurNoticePreTreat(T_App *ptApp)
{
    int     iTransType;             /* �������� */

    /* Ԥ�Ǽ���ˮ */
    if(PreInsertPosls(ptApp) != SUCC)
    {
        return FAIL;
    }

    /* �������ѽ��� */
    /* ����ԭ�������ͣ������������͸�Ϊ���� */
    iTransType = ptApp->iTransType;
    ptApp->iTransType = PURCHASE;

    if(SendReqToHost(ptApp) != SUCC)
    {
        return FAIL;
    }

    /* �ָ��������� */
    ptApp->iTransType = iTransType;

    /* ������ˮ��Ϣ */
    memset(szRetriRefNum, 0, sizeof(szRetriRefNum));
    memset(szReturnCode, 0, sizeof(szReturnCode));
    memset(szHostRetCode, 0, sizeof(szHostRetCode));
    memset(szHostRetMsg, 0, sizeof(szHostRetMsg));
    memset(szAuthCode, 0, sizeof(szAuthCode));
    memset(szHostDate, 0, sizeof(szHostDate));
    memset(szHostTime, 0, sizeof(szHostTime));
    memset(szSettleDate, 0, sizeof(szSettleDate));
    memset(szBankID, 0, sizeof(szBankID));
    memset(szShopNo, 0, sizeof(szShopNo));
    memset(szPosNo, 0, sizeof(szPosNo));
    memset(szPan, 0, sizeof(szPan));
    memset(szPosDate, 0, sizeof(szPosDate));

    /* ������ֵ */
    strcpy(szRetriRefNum, ptApp->szRetriRefNum);
    strcpy(szReturnCode, ptApp->szRetCode);
    strcpy(szHostRetCode, ptApp->szHostRetCode);
    strcpy(szHostRetMsg, ptApp->szHostRetMsg);
    strcpy(szAuthCode, ptApp->szAuthCode);
    strcpy(szHostDate, ptApp->szHostDate);
    strcpy(szHostTime, ptApp->szHostTime);
    strcpy(szSettleDate, ptApp->szSettleDate);
    strcpy(szBankID, ptApp->szAcqBankId);
    strcpy(szShopNo, ptApp->szShopNo);
    strcpy(szPan, ptApp->szPan);
    strcpy(szPosDate, ptApp->szPosDate);

    iPosTrace = ptApp->lPosTrace;
    iBatchNo = ptApp->lBatchNo;

    EXEC SQL
        UPDATE posls
        SET retri_ref_num = :szRetriRefNum, return_code = :szReturnCode,
            host_ret_code = :szHostRetCode, host_ret_msg = :szHostRetMsg,
            auth_code = :szAuthCode, host_date = :szHostDate, host_time = :szHostTime,
            settle_date = :szSettleDate, batch_no = :iBatchNo, bank_id = :szBankID
        WHERE shop_no = :szShopNo AND pos_no = :szPosNo AND
              pos_trace = :iPosTrace AND pos_date = :szPosDate AND
              pan = :szPan AND recover_flag = 'N' AND pos_settle = 'N';
    if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "������ˮ �̻�[%s] �ն�[%s] POS��ˮ[%d] POS��������[%s] ����:[%s] ʧ��!SQLCODE=%d SQLERR=%s",
                 szShopNo, szPosNo, iPosTrace, szPosDate, szPan, SQLCODE, SQLERR);

        return FAIL;
    }

    /* ʧ�ܷ��ش���Ӧ�� */
    if(memcmp(ptApp->szRetCode, TRANS_SUCC, 2) != 0)
    {
        return FAIL;
    }

    /* ����֪ͨ���׺�̨·�� */
    /* ���޸�
    ptApp->lToHostMsgType = 111111;
    */

    return SUCC;
}

/****************************************************************
** ��    �ܣ����׺���
** ���������
**        ptApp           app�ṹ
** ���������
**        ptApp           app�ṹ
** �� �� ֵ��
**        SUCC            ����ɹ�
**        FAIL            ����ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/16
** ����˵����
**
** �޸���־��
****************************************************************/
int PurNoticePostTreat(T_App *ptApp)
{
    return SUCC;
}
