/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� �˻�����
** �� �� �ˣ����
** �������ڣ�2012-11-14
**
** $Revision: 1.4 $
** $Log: Refund.ec,v $
** Revision 1.4  2013/02/21 06:36:51  fengw
**
** 1�������ն˺Ÿ�ֵ��䡣
**
** Revision 1.3  2013/01/18 08:26:53  fengw
**
** 1���޸Ļ�ȡԭ������ˮ����ش��롣
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
    char    szRetriRefNum[12+1];            /* ��̨�����ο��� */
    char    szOldRetriRefNum[12+1];         /* ԭ��̨�����ο��� */
    char    szReturnCode[2+1];              /* ƽ̨������ */
    char    szHostRetCode[6+1];             /* ��̨������ */
    char    szHostRetMsg[40+1];             /* ��̨���ش�����Ϣ */
    char    szAuthCode[6+1];                /* ��Ȩ�� */
    char    szHostDate[8+1];                /* ƽ̨�������� */
    char    szHostTime[6+1];                /* ƽ̨����ʱ�� */
    char    szSettleDate[8+1];              /* �������� */
    int     iBatchNo;                       /* ���κ� */
    double  dAmount;                        /* ���׽�� */
    char    szBankID[11+1];                 /* ���б�ʶ�� */
    char    szShopNo[15+1];                 /* �̻��� */
    char    szPosNo[15+1];                  /* �ն˺� */
    int     iPosTrace;                      /* �ն���ˮ�� */
    int     iOldPosTrace;                   /* ԭ�ն���ˮ�� */
    int     iSysTrace;                      /* ƽ̨��ˮ�� */
    int     iTransType;                     /* �������� */
    char    szPan[19+1];                    /* ת������ */
    char    szAccount2[19+1];               /* ת�뿨�� */
    char    szPosDate[8+1];                 /* POS�������� */
    char    szCancelFlag[1+1];              /* ������־ */
    char    szRecoverFlag[1+1];             /* ������־ */
    char    szPosSettle[1+1];               /* �����־ */
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
**        2012/11/09
** ����˵����
**
** �޸���־��
****************************************************************/
int RefundPreTreat(T_App *ptApp)
{
    double dRefundAmt;

    /* ����Ƿ��Ǹ����˻� */
    if(memcmp(ptApp->szInDate, ptApp->szPosDate, 8) >= 0)
    {
        strcpy(ptApp->szRetCode, ERR_REFUND_ERRDATE);

        WriteLog(ERROR, "�˻���������[%s]��Ӧ���ڵ��ڵ�ǰ����[%s]", ptApp->szInDate, ptApp->szPosDate);

        return FAIL;
    }

    /* ������ֵ */
    memset(szShopNo, 0, sizeof(szShopNo));
    memset(szPosNo, 0, sizeof(szPosNo));
    memset(szPosDate, 0, sizeof(szPosDate));

    strcpy(szShopNo, ptApp->szShopNo);
    strcpy(szPosNo, ptApp->szPosNo);
    strcpy(szPosDate, ptApp->szInDate);
    iOldPosTrace = ptApp->lOldPosTrace;

    /* ��ѯԭ��ˮ��¼ */
    memset(szOldRetriRefNum, 0, sizeof(szOldRetriRefNum));
    memset(szAuthCode, 0, sizeof(szAuthCode));
    memset(szHostDate, 0, sizeof(szHostDate));
    memset(szHostTime, 0, sizeof(szHostTime));
    memset(szAccount2, 0, sizeof(szAccount2));
    memset(szPan, 0, sizeof(szPan));
    memset(szReturnCode, 0, sizeof(szReturnCode));
    memset(szCancelFlag, 0, sizeof(szCancelFlag));
    memset(szRecoverFlag, 0, sizeof(szRecoverFlag));
    memset(szPosSettle, 0, sizeof(szPosSettle));

    EXEC SQL
        SELECT retri_ref_num, sys_trace, auth_code, amount, host_time, host_date,
               trans_type, account2, pan, return_code, cancel_flag, recover_flag, pos_settle
        INTO :szOldRetriRefNum, :iSysTrace, :szAuthCode, :dAmount,
             :szHostDate, :szHostTime, :iTransType, :szAccount2, :szPan,
             :szReturnCode, :szCancelFlag, :szRecoverFlag, :szPosSettle
        FROM history_ls
        WHERE shop_no = :szShopNo AND pos_no = :szPosNo AND
              pos_trace = :iOldPosTrace AND pos_date = :szPosDate;
    if(SQLCODE == SQL_NO_RECORD)
    {
        EXEC SQL
            SELECT retri_ref_num, sys_trace, auth_code, amount, host_time, host_date,
                   trans_type, account2, pan, return_code, cancel_flag, recover_flag, pos_settle
            INTO :szOldRetriRefNum, :iSysTrace, :szAuthCode, :dAmount,
                 :szHostDate, :szHostTime, :iTransType, :szAccount2, :szPan,
                 :szReturnCode, :szCancelFlag, :szRecoverFlag, :szPosSettle
            FROM posls
            WHERE shop_no = :szShopNo AND pos_no = :szPosNo AND
                  pos_trace = :iOldPosTrace AND pos_date = :szPosDate;
        if(SQLCODE == SQL_NO_RECORD)
        {
            strcpy(ptApp->szRetCode, ERR_TRANS_NOT_EXIST);

            WriteLog(ERROR, "ԭ������ˮ��ˮ �̻�[%s] �ն�[%s] POS��ˮ[%d] POS��������[%s] ������!SQLCODE=%d SQLERR=%s",
                     szShopNo, szPosNo, iOldPosTrace, szPosDate, SQLCODE, SQLERR);

            return FAIL;
        }
        else if(SQLCODE)
        {
            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

            WriteLog(ERROR, "��ѯԭ������ˮ��ˮ �̻�[%s] �ն�[%s] POS��ˮ[%d] POS��������[%s] ʧ��!SQLCODE=%d SQLERR=%s",
                     szShopNo, szPosNo, iOldPosTrace, szPosDate, SQLCODE, SQLERR);

            return FAIL;
        }
    }
    else if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "��ѯԭ������ˮ��ˮ �̻�[%s] �ն�[%s] POS��ˮ[%d] POS��������[%s] ʧ��!SQLCODE=%d SQLERR=%s",
                 szShopNo, szPosNo, iOldPosTrace, szPosDate, SQLCODE, SQLERR);

        return FAIL;
    }
/*
            INTO :szOldRetriRefNum, :iSysTrace, :szAuthCode, :dAmount,
                 :szHostDate, :szHostTime, :iTransType, :szAccount2, :szPan,
                 :szReturnCode, :szCancelFlag, :szRecoverFlag, :szPosSettle
                 */
    DelTailSpace(szOldRetriRefNum);
    DelTailSpace(szAuthCode);
    DelTailSpace(szHostDate);
    DelTailSpace(szHostTime);
    DelTailSpace(szAccount2);
    DelTailSpace(szPan);
    DelTailSpace(szReturnCode);
    DelTailSpace(szCancelFlag);
    DelTailSpace(szCancelFlag);
    DelTailSpace(szRecoverFlag);
    DelTailSpace(szPosSettle);

    /* ���ԭ����״̬ */
    /* �Ƿ�ɹ����� */
    if(memcmp(szReturnCode, "00", 2) != 0)
    {
        strcpy(ptApp->szRetCode, ERR_OLDTRANS_FAIL);

        WriteLog(ERROR, "ԭ����״̬[%s]�ǳɹ����޷��˻�", szReturnCode);

        return FAIL;
    }

    /* �Ƿ��ѳ��� */
    if(szCancelFlag[0] != 'N')
    {
        strcpy(ptApp->szRetCode, ERR_OLDTRANS_CANCEL);

        WriteLog(ERROR, "ԭ�����ѳ���");

        return FAIL;
    }

    /* �Ƿ��ѳ��� */
    if(szRecoverFlag[0] != 'N')
    {
        strcpy(ptApp->szRetCode, ERR_OLDTRANS_RECOVER);

        WriteLog(ERROR, "ԭ�����ѳ���");

        return FAIL;
    }

    /* �Ƿ��ѽ��� */
    if(szPosSettle[0] != 'N')
    {
        strcpy(ptApp->szRetCode, ERR_OLDTRANS_SETTLE);

        WriteLog(ERROR, "ԭ�����ѽ���");

        return FAIL;
    }

    /* �˻����ܴ���ԭ���׽�� */
    dRefundAmt = atol(ptApp->szAmount)/100.0;

    if(dRefundAmt - dAmount > 0.001)
    {
        strcpy(ptApp->szRetCode, ERR_REFUNE_ERRAMT);

        WriteLog(ERROR, "�˻����[%.2f]����ԭ���׽��[%.2f]", dRefundAmt - dAmount);

        return FAIL;
    }

    /* �����ֵ */
    /* ���׿��� */
    strcpy(ptApp->szPan, szPan);
    WriteLog(ERROR, "szPan[%s]", ptApp->szPan);

    /* ԭ���ײο��� */
    strcpy(ptApp->szOldRetriRefNum, szOldRetriRefNum);

    /* ��Ȩ�� */
    strcpy(ptApp->szAuthCode, szAuthCode);

    /* ԭƽ̨��ˮ�� */
    ptApp->lOldSysTrace = iSysTrace;

    /* Ԥ�Ǽ���ˮ */
    if(PreInsertPosls(ptApp) != SUCC)
    {
        return FAIL;
    }

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
**        2012/11/09
** ����˵����
**
** �޸���־��
****************************************************************/
int RefundPostTreat(T_App *ptApp)
{
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
    strcpy(szPosNo, ptApp->szPosNo);
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
              pos_trace = :iPosTrace AND  pos_date = :szPosDate AND
              pan = :szPan AND recover_flag = 'N' AND pos_settle = 'N';
    if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "������ˮ �̻�[%s] �ն�[%s] POS��ˮ[%d] POS��������[%s] ����:[%s] ʧ��!SQLCODE=%d SQLERR=%s",
                 szShopNo, szPosNo, iPosTrace, szPosDate, szPan, SQLCODE, SQLERR);

        return FAIL;
    }
    CommitTran();  

    return SUCC;
}
