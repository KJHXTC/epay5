/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� ��������
** �� �� �ˣ����
** �������ڣ�2012-11-09
**
** $Revision: 1.4 $
** $Log: AutoVoid.ec,v $
** Revision 1.4  2013/03/22 05:33:18  fengw
**
** 1��������������ҵ���߼�����BUG��
**
** Revision 1.3  2013/03/11 07:09:03  fengw
**
** 1���޸�BcdToAsc����������
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
    char    szBusinessCode[40+1];           /* ����Ӧ�ú� */
    char    szCardType[1+1];                /* ������ */
    char    szPsamNo[16+1];                 /* ��ȫģ��� */
    char    szMAC[16+1];                    /* MAC */
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
int AutoVoidPreTreat(T_App *ptApp)
{
    long long llAmt;

    /* ������ֵ */
    memset(szPsamNo, 0, sizeof(szPsamNo));
    memset(szMAC, 0, sizeof(szMAC));

    strcpy(szPsamNo, ptApp->szPsamNo);
    BcdToAsc(ptApp->szMac, 16, LEFT_ALIGN, szMAC);
    iPosTrace = ptApp->lOldPosTrace;

    /* ��ѯԭ��ˮ��¼ */
    memset(szRetriRefNum, 0, sizeof(szRetriRefNum));
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
    memset(szBusinessCode, 0, sizeof(szBusinessCode));
    memset(szCardType, 0, sizeof(szCardType));
    memset(szBankID, 0, sizeof(szBankID));

    EXEC SQL
        SELECT retri_ref_num, old_retri_ref_num, sys_trace, auth_code, amount,
               host_time, host_date, trans_type, account2, pan, return_code,
               cancel_flag, recover_flag, pos_settle, business_code, card_type, bank_id
        INTO :szRetriRefNum, :szOldRetriRefNum, :iSysTrace, :szAuthCode, :dAmount,
             :szHostDate, :szHostTime, :iTransType, :szAccount2, :szPan, :szReturnCode,
             :szCancelFlag, :szRecoverFlag, :szPosSettle, :szBusinessCode, :szCardType, :szBankID
        FROM posls
        WHERE psam_no = :szPsamNo AND pos_trace = :iPosTrace AND mac = :szMAC AND
              recover_flag = 'N';
    if(SQLCODE == SQL_NO_RECORD)
    {
        /* �˳����״���Ӧ��������Ϊ�ɹ�������POS�����ɹ� */
        strcpy(ptApp->szRetCode, TRANS_SUCC);
        strcpy(ptApp->szHostRetCode, TRANS_SUCC);

        WriteLog(TRACE, "ԭ������ˮ psam_no:[%s] Trace:[%ld] Mac:[%s]�����ڻ��ѳ�����������������سɹ�",
                 szPsamNo, iPosTrace, szMAC);

        return FAIL;
    }
    else if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "��ѯԭ������ˮ psam_no:[%s] Trace:[%ld] Mac:[%s]ʧ��!SQLCODE=%d SQLERR=%s",
                 szPsamNo, iPosTrace, szMAC,  SQLCODE, SQLERR);

        return FAIL;
    }

    /* �ж�ԭ����״̬�Ƿ�ΪNN */
    if(memcmp(szReturnCode, "NN", 2) == 0)
    {
        /* ����������׷���Ϊ�նˣ��Ǽǳ�����ˮ�����سɹ� */
        if(memcmp(ptApp->szSourceTpdu, "\xFF\xFF", 2) != 0 &&
           memcmp(ptApp->szTargetTpdu, "\xFF\xFF", 2) != 0)
        {
            /* �Ǽǳ�����ˮ */
            InsertVoidls(ptApp);

            strcpy(ptApp->szRetCode, TRANS_SUCC);

            return FAIL;
        }
        /* ����������׷���Ϊƽ̨������ʧ�ܣ��ȴ��´γ��� */
        else
        {
            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);
            WriteLog(TRACE, "return_code[NN] posp_trans[%d]",iPosTrace);

            return FAIL;
        }
    }
    /* ���״̬��Ϊ�������������Ҫ���������سɹ� */
    else if(memcmp(szReturnCode, "00", 2) != 0 &&
            memcmp(szReturnCode, "68", 2) != 0 &&
            memcmp(szReturnCode, "TO", 2) != 0 &&
            memcmp(szReturnCode, "Q9", 2) != 0)
    {
        /* ������� */
        strcpy(ptApp->szRetCode, TRANS_SUCC);
        strcpy(ptApp->szHostRetCode, TRANS_SUCC);
WriteLog(ERROR, "not need void");
        return FAIL;
    }

    /* �����ֵ */
    DelTailSpace(szRetriRefNum);
    DelTailSpace(szOldRetriRefNum);
    DelTailSpace(szAuthCode);
    DelTailSpace(szPan);
    DelTailSpace(szBankID);
    DelTailSpace(szAccount2);
    DelTailSpace(szHostDate);
    DelTailSpace(szHostTime);
    DelTailSpace(szBusinessCode);

    /* ���ײο��� */
    strcpy(ptApp->szRetriRefNum, szRetriRefNum);

    /* ԭ���ײο��� */
    strcpy(ptApp->szOldRetriRefNum, szOldRetriRefNum);

    /* ��Ȩ�� */
    strcpy(ptApp->szAuthCode, szAuthCode);

    /* �������� */
    ptApp->iOldTransType = iTransType;

    /* ������ */
    ptApp->cOutCardType = szCardType[0];

    /* ת������ */
    strcpy(ptApp->szPan, szPan);

    /* ���б�ʶ */
    strcpy(ptApp->szAcqBankId, szBankID);

    /* ת���˺� */
    strcpy(ptApp->szAccount2, szAccount2);

    /* ���׽�� */
    memset(ptApp->szAmount, 0, sizeof(ptApp->szAmount));
    sprintf(ptApp->szAmount, "%012ld", (long long)(dAmount*100.0+0.5));

    /* �����������ڡ�ʱ�� */
    strcpy(ptApp->szHostDate, szHostDate);
    strcpy(ptApp->szHostTime, szHostTime);

    /* ԭϵͳ��ˮ�� */
    ptApp->lOldSysTrace = iSysTrace;

    /* ����ʹ��ԭ�еĵ���ˮ�� */
    ptApp->lSysTrace = iSysTrace;

    /* ����Ӧ�ú� */
    strcpy(ptApp->szBusinessCode, szBusinessCode);

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
int AutoVoidPostTreat(T_App *ptApp)
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

    iOldPosTrace = ptApp->lOldPosTrace;
    iPosTrace = ptApp->lPosTrace;
    iBatchNo = ptApp->lBatchNo;

    /* ������ */
    BeginTran();

    /* ����ԭ������ˮ������־��������־ */
    if(memcmp(ptApp->szRetCode, TRANS_SUCC, 2) == 0)
    {
        if(ptApp->iOldTransType == PUR_CANCEL ||
           ptApp->iOldTransType == PRE_CANCEL ||
           ptApp->iOldTransType == CON_CANCEL ||
           ptApp->iOldTransType == TRAN_CANCEL ||
           ptApp->iOldTransType == TRAN_OUT_CANCEL ||
           ptApp->iOldTransType == TRAN_IN_CANCEL)
        {
            EXEC SQL
                UPDATE posls SET cancel_flag = 'N'
                WHERE shop_no = :szShopNo AND pos_no = :szPosNo AND
                    retri_ref_num = :szOldRetriRefNum AND pan = :szPan AND
                    pos_date = :szPosDate AND recover_flag = 'N' AND pos_settle = 'N';
            if(SQLCODE)
            {
                RollbackTran();

                strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

                WriteLog(ERROR, "����ԭ������ˮ �̻�[%s] �ն�[%s] ԭϵͳ�ο���[%s] ����:[%s] POS��������[%s] ʧ��!SQLCODE=%d SQLERR=%s",
                         szShopNo, szPosNo, szOldRetriRefNum, szPan, szPosDate, SQLCODE, SQLERR);

                return FAIL;
            }
        }

		EXEC SQL
		    UPDATE posls SET recover_flag = 'Y'
    	 	WHERE psam_no = :szPsamNo AND pos_trace = :iOldPosTrace AND
                  mac = :szMAC AND recover_flag = 'N';
        if(SQLCODE)
        {
            RollbackTran();

            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

            WriteLog(ERROR, "������ˮ ��ȫģ���[%s] ԭPOS��ˮ[%d] MAC:[%s] ʧ��!SQLCODE=%d SQLERR=%s",
                     szPsamNo, iOldPosTrace, szMAC, SQLCODE, SQLERR);

            return FAIL;
        }

        /* �ύ���� */
        CommitTran();
    }

    return SUCC;
}
