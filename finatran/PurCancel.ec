/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� ��������
** �� �� �ˣ����
** �������ڣ�2012-11-09
**
** $Revision: 1.3 $
** $Log: PurCancel.ec,v $
** Revision 1.3  2013/03/22 05:32:37  fengw
**
** 1���޸Ľ��׳ɹ������ԭ������ˮ�ο��š�
**
** Revision 1.2  2013/01/14 09:19:10  fengw
**
** 1�����ӿ���ȥ�ո���
**
** Revision 1.1  2012/12/07 02:00:25  fengw
**
** 1������������PurVoid����ΪPurCancel��
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
int PurCancelPreTreat(T_App *ptApp)
{
    long long llAmt;

    /* ������ֵ */
    memset(szShopNo, 0, sizeof(szShopNo));
    memset(szPosNo, 0, sizeof(szPosNo));
    memset(szPosDate, 0, sizeof(szPosDate));

    strcpy(szShopNo, ptApp->szShopNo);
    strcpy(szPosNo, ptApp->szPosNo);
    strcpy(szPosDate, ptApp->szPosDate);
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

    /* ����ԭ���������ж� */
    switch(iTransType)
    {
        case PUR_CANCEL:
        case PRE_CANCEL:
        case CON_CANCEL:
        case TRAN_CANCEL:
        case TRAN_OUT_CANCEL:
        case TRAN_IN_CANCEL:
            /* �����ཻ�ײ������ٴγ��� */
            strcpy(ptApp->szRetCode, ERR_VOID_VOID);

            WriteLog(ERROR, "�����ཻ�ײ������� %d", iTransType);

            return FAIL;
        default:
            break;
    }

    /* ���ԭ���׿������ն�ˢ����Ϣ */
    DelTailSpace(szPan);

    if(strcmp(ptApp->szPan, szPan) != 0)
    {
        strcpy(ptApp->szRetCode, ERR_OLDTRANS_CARDERR);

        WriteLog(ERROR, "ԭ���׿������ն�ˢ����Ϣ���� ԭ����:[%s] �ն�ˢ��:[%s]",
                 ptApp->szPan, szPan);

        return FAIL;
    }

    /* ���ԭ����״̬ */
    /* �Ƿ�ɹ����� */
    if(memcmp(szReturnCode, "00", 2) != 0)
    {
        strcpy(ptApp->szRetCode, ERR_OLDTRANS_FAIL);

        WriteLog(ERROR, "ԭ����״̬[%s]�ǳɹ����޷�����", szReturnCode);

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

    /* �����ֵ */
    /* ���׽�� */
    memset(ptApp->szAmount, 0, sizeof(ptApp->szAmount));
    sprintf(ptApp->szAmount, "%012ld", (long long)(dAmount*100.0+0.5));

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
int PurCancelPostTreat(T_App *ptApp)
{
    /* ������ˮ��Ϣ */

    memset(szOldRetriRefNum, 0, sizeof(szOldRetriRefNum));
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
    strcpy(szOldRetriRefNum, ptApp->szOldRetriRefNum);
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

    /* ������ */
    BeginTran();

    /* ���±�����������ˮ������־ */
    if(memcmp(ptApp->szRetCode, TRANS_SUCC, 2) == 0)
    {
        EXEC SQL
            UPDATE posls SET cancel_flag = 'Y'
            WHERE shop_no = :szShopNo AND pos_no = :szPosNo AND
                pos_trace = :iOldPosTrace AND pos_date = :szPosDate AND
                pan = :szPan AND recover_flag = 'N' AND pos_settle = 'N' AND
                return_code = '00';
        if(SQLCODE)
        {
            RollbackTran();

            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

            WriteLog(ERROR, "����ԭ��ˮ �̻�[%s] �ն�[%s] POS��ˮ[%d] POS��������[%s] ����:[%s] ʧ��!SQLCODE=%d SQLERR=%s",
                     szShopNo, szPosNo, iOldPosTrace, szPosDate, szPan, SQLCODE, SQLERR);

            return FAIL;
        }
    }

    EXEC SQL
        UPDATE posls
        SET old_retri_ref_num = :szOldRetriRefNum, retri_ref_num = :szRetriRefNum, 
            return_code = :szReturnCode, host_ret_code = :szHostRetCode,
            host_ret_msg = :szHostRetMsg, auth_code = :szAuthCode, host_date = :szHostDate,
            host_time = :szHostTime, settle_date = :szSettleDate, batch_no = :iBatchNo,
            bank_id = :szBankID
        WHERE shop_no = :szShopNo AND pos_no = :szPosNo AND
              pos_trace = :iPosTrace AND pos_date = :szPosDate AND
              pan = :szPan AND recover_flag = 'N' AND pos_settle = 'N';
    if(SQLCODE)
    {
        RollbackTran();

        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "������ˮ �̻�[%s] �ն�[%s] POS��ˮ[%d] POS��������[%s] ����:[%s] ʧ��!SQLCODE=%d SQLERR=%s",
                 szShopNo, szPosNo, iPosTrace, szPosDate, szPan, SQLCODE, SQLERR);

        return FAIL;
    }

    /* �ύ���� */
    CommitTran();

    return SUCC;
}
