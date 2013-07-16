/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨epay������ �Ǽǽ��׳�����ˮ
** �� �� �ˣ����
** �������ڣ�2012-12-04
**
** $Revision: 1.5 $
** $Log: InsertVoidls.ec,v $
** Revision 1.5  2013/03/28 07:58:26  fengw
**
** 1������SQL���BUG��
**
** Revision 1.4  2012/12/28 03:36:30  fengw
**
** 1�����ݿ������dept_detail�ֶΡ�
**
** Revision 1.3  2012/12/20 09:24:05  wukj
** *** empty log message ***
**
*******************************************************************/

#include <stdio.h>
#include <string.h>

#include "app.h"
#include "user.h"
#include "dbtool.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ��Ǽǽ��׳�����ˮ
** ���������
**        ptApp           app�ṹ
** ���������
**        ��
** �� �� ֵ��
**        SUCC            ����ɹ�
**        FAIL            ����ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/12/04
** ����˵����
**
** �޸���־��
****************************************************************/
int InsertVoidls(T_App *ptApp) 
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szShopNo[15+1];                 /* �̻��� */
        char    szPosNo[15+1];                  /* �ն˺� */
        char    szPsamNo[16+1];                 /* ��ȫģ��� */
        int     iPosTrace;                      /* �ն���ˮ�� */
        int     iBatchNo;                       /* ���κ� */
        int     iSysTrace;                      /* ƽ̨��ˮ�� */
        int     iTransType;                     /* �������� */
        int     iBusinessType;                  /* ҵ������ */
        char    szPan[19+1];                    /* ת������ */
        char    szCardType[1+1];                /* ������ */
        double  dAmount;                        /* ���׽�� */
        double  dAddiAmount;                    /* �����ѽ�� */
        char    szAccount2[19+1];               /* ת�뿨�� */
        char    szFinancialCode[40+1];          /* ����Ӧ�ú� */
        char    szBusinessCode[40+1];           /* ����Ӧ�ú� */
        char    szPosDate[8+1];                 /* POS�������� */
        char    szPosTime[6+1];                 /* POS����ʱ�� */
        char    szHostDate[8+1];                /* ������������ */
        char    szHostTime[6+1];                /* ��������ʱ�� */
        char    szReturnCode[2+1];              /* ƽ̨������ */
        char    szHostRetCode[6+1];             /* ���������� */
        char    szRetriRefNum[12+1];            /* ��̨�����ο��� */
        char    szOldRetriRefNum[12+1];         /* ԭ��̨�����ο��� */
        char    szAuthCode[6+1];                /* ��Ȩ�� */
        char    szBankID[11+1];                 /* ���б�ʶ�� */
        char    szCancelFlag[1+1];              /* ������־ */
        char    szRecoverFlag[1+1];             /* ������־ */
        char    szPosSettle[1+1];               /* �����־ */
        char    szOperNo[4+1];                  /* ����Ա��� */
        char    szMac[16+1];                    /* MAC */
        char    szDeptDetail[70+1];             /* �����㼶��Ϣ */
    EXEC SQL END DECLARE SECTION;

    memset(szShopNo, 0, sizeof(szShopNo));
    memset(szPosNo, 0, sizeof(szPosNo));
    memset(szPsamNo, 0, sizeof(szPsamNo));
    memset(szPan, 0, sizeof(szPan));
    memset(szCardType, 0, sizeof(szCardType));
    memset(szAccount2, 0, sizeof(szAccount2));
    memset(szFinancialCode, 0, sizeof(szFinancialCode));
    memset(szBusinessCode, 0, sizeof(szBusinessCode));
    memset(szPosDate, 0, sizeof(szPosDate));
    memset(szPosTime, 0, sizeof(szPosTime));
    memset(szReturnCode, 0, sizeof(szReturnCode));
    memset(szRetriRefNum, 0, sizeof(szRetriRefNum));
    memset(szAuthCode, 0, sizeof(szAuthCode));
    memset(szHostDate, 0, sizeof(szHostDate));
    memset(szHostTime, 0, sizeof(szHostTime));
    memset(szBankID, 0, sizeof(szBankID));
    memset(szCancelFlag, 0, sizeof(szCancelFlag));
    memset(szRecoverFlag, 0, sizeof(szRecoverFlag));
    memset(szPosSettle, 0, sizeof(szPosSettle));
    memset(szOperNo, 0, sizeof(szOperNo));
    memset(szMac, 0, sizeof(szMac));
    memset(szDeptDetail, 0, sizeof(szDeptDetail));

    strcpy(szShopNo, ptApp->szShopNo);
    strcpy(szPosNo, ptApp->szPosNo);
    strcpy(szPsamNo, ptApp->szPsamNo);
    iPosTrace = ptApp->lPosTrace;
    iBatchNo = ptApp->lBatchNo;
    iSysTrace = ptApp->lSysTrace;
    iTransType = ptApp->iTransType;
    iBusinessType = ptApp->iBusinessType;
    strcpy(szPan, ptApp->szPan);
    szCardType[0] = ptApp->cOutCardType;
    dAmount = atof(ptApp->szAmount) / 100;
    dAddiAmount = atof(ptApp->szAddiAmount) / 100;
    strcpy(szAccount2, ptApp->szAccount2);
    strcpy(szFinancialCode, ptApp->szFinancialCode);
    strcpy(szBusinessCode, ptApp->szBusinessCode);
    strcpy(szPosDate, ptApp->szPosDate);
    strcpy(szPosTime, ptApp->szPosTime);
    strcpy(szReturnCode, ptApp->szRetCode);
    strcpy(szHostRetCode, ptApp->szHostRetCode);
    strcpy(szRetriRefNum, ptApp->szRetriRefNum);
    strcpy(szOldRetriRefNum, ptApp->szOldRetriRefNum);
    strcpy(szAuthCode, ptApp->szAuthCode);
    strcpy(szHostDate, ptApp->szHostDate);
    strcpy(szHostTime, ptApp->szHostTime);
    strcpy(szBankID, ptApp->szAcqBankId);
    szCancelFlag[0] = 'N';
    szRecoverFlag[0] = 'N';
    szPosSettle[0] = 'N';
    strcpy(szOperNo, ptApp->szOperNo);
    BcdToAsc(ptApp->szMac, 16, 0, szMac);
    strcpy(szDeptDetail, ptApp->szDeptDetail);

    BeginTran();

	EXEC SQL
	    INSERT INTO void_ls 
        (
            shop_no, pos_no, psam_no, pos_trace, batch_no, sys_trace, trans_type,
            business_type, pan, card_type, amount, addi_amount, account2, financial_code,
            business_code, pos_date, pos_time, return_code, host_ret_code, retri_ref_num,
            old_retri_ref_num, auth_code, host_date, host_time, bank_id, cancel_flag,
            recover_flag, pos_settle, oper_no, mac, dept_detail
        )
        VALUES
        (
            :szShopNo, :szPosNo, :szPsamNo, :iPosTrace, :iBatchNo, :iSysTrace, :iTransType,
            :iBusinessType, :szPan, :szCardType, :dAmount, :dAddiAmount, :szAccount2, :szFinancialCode,
            :szBusinessCode, :szPosDate, :szPosTime, :szReturnCode, :szHostRetCode, :szRetriRefNum,
            :szOldRetriRefNum, :szAuthCode, :szHostDate, :szHostTime, :szBankID, :szCancelFlag,
            :szRecoverFlag, :szPosSettle, :szOperNo, :szMac, :szDeptDetail
        );
	if(SQLCODE)
	{
        WriteLog(ERROR, "���������ˮ��¼ʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

        RollbackTran();

        return FAIL;
    }

    CommitTran();

    return SUCC;
}
