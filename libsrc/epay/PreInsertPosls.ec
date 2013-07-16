/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨epay������ �Ǽǽ�����ˮ
** �� �� �ˣ����
** �������ڣ�2012-12-04
**
** $Revision: 1.6 $
** $Log: PreInsertPosls.ec,v $
** Revision 1.6  2013/06/28 01:20:47  fengw
**
** 1��Ԥ�Ǽ�POS������ˮ����ʼ�������������ڡ���������ʱ�䡢��������Ϊϵͳ���ڡ�ʱ�䡣
**
** Revision 1.5  2013/01/16 02:22:25  fengw
**
** 1���޸Ľ��׽��ת�����롣
** 2��������ˮ��¼�ֶΡ�
**
** Revision 1.4  2012/12/28 03:36:30  fengw
**
** 1�����ݿ������dept_detail�ֶΡ�
**
** Revision 1.3  2012/12/20 09:25:54  wukj
** Revision�����Ԫ��
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
** ��    �ܣ��Ǽǽ�����ˮ
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
int PreInsertPosls(T_App *ptApp)
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szShopNo[15+1];                 /* �̻��� */
        char    szPosNo[15+1];                  /* �ն˺� */
        int     iPosTrace;                      /* �ն���ˮ�� */
        char    szPsamNo[16+1];                 /* ��ȫģ��� */
        int     iBatchNo;                       /* ���κ� */
        int     iSysTrace;                      /* ƽ̨��ˮ�� */
        int     iTransType;                     /* �������� */
        int     iBusinessType;                  /* ҵ������ */
        char    szPan[19+1];                    /* ת������ */
        char    szCardType[1+1];                /* ������ */
        double  dAmount;                        /* ���׽�� */
        double  dAddiAmount;                    /* �����ѽ�� */
        char    szAccount2[19+1];               /* ת�뿨�� */
        char    szPosDate[8+1];                 /* POS�������� */
        char    szPosTime[6+1];                 /* POS����ʱ�� */
        char    szHostDate[8+1];                /* ������������ */
        char    szHostTime[6+1];                /* ��������ʱ�� */
        char    szSettleDate[8+1];              /* �������� */
        char    szFinancialCode[40+1];          /* ����Ӧ�ú� */
        char    szBusinessCode[40+1];           /* �̻�Ӧ�ú� */
        char    szAcqBankId[11+1];              /* �յ����к� */
        char    szReturnCode[2+1];              /* ƽ̨������ */
        char    szCancelFlag[1+1];              /* ������־ */
        char    szRecoverFlag[1+1];             /* ������־ */
        char    szPosSettle[1+1];               /* �����־ */
        char    szMac[16+1];                    /* MAC */
        char    szDeptDetail[70+1];             /* �����㼶��Ϣ */
    EXEC SQL END DECLARE SECTION;

    /* ������ֵ */
    memset(szShopNo, 0, sizeof(szShopNo));
    memset(szPosNo, 0, sizeof(szPosNo));
    memset(szPsamNo, 0, sizeof(szPsamNo));
    memset(szPan, 0, sizeof(szPan));
    memset(szCardType, 0, sizeof(szCardType));
    memset(szAccount2, 0, sizeof(szAccount2));
    memset(szPosDate, 0, sizeof(szPosDate));
    memset(szPosTime, 0, sizeof(szPosTime));
    memset(szHostDate, 0, sizeof(szHostDate));
    memset(szHostTime, 0, sizeof(szHostTime));
    memset(szSettleDate, 0, sizeof(szSettleDate));
    memset(szFinancialCode, 0, sizeof(szFinancialCode));
    memset(szBusinessCode, 0, sizeof(szBusinessCode));
    memset(szAcqBankId, 0, sizeof(szAcqBankId));
    memset(szReturnCode, 0, sizeof(szReturnCode));
    memset(szCancelFlag, 0, sizeof(szCancelFlag));
    memset(szRecoverFlag, 0, sizeof(szRecoverFlag));
    memset(szPosSettle, 0, sizeof(szPosSettle));
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
    strcpy(szPosDate, ptApp->szPosDate);
    strcpy(szPosTime, ptApp->szPosTime);

    if(strlen(ptApp->szHostDate) == 8)
    {
        strcpy(szHostDate, ptApp->szHostDate);
    }
    else
    {
        GetSysDate(szHostDate);
    }

    if(strlen(ptApp->szHostTime) == 6)
    {
        strcpy(szHostTime, ptApp->szHostTime);
    }
    else
    {
        GetSysTime(szHostTime);
    }
    
    if(strlen(ptApp->szSettleDate) == 8)
    {
        strcpy(szSettleDate, ptApp->szSettleDate);
    }
    else
    {
        GetSysDate(szSettleDate);
    }

    strcpy(szFinancialCode, ptApp->szFinancialCode);
    strcpy(szBusinessCode, ptApp->szBusinessCode);
    strcpy(szAcqBankId, ptApp->szAcqBankId);
    strcpy(szPan, ptApp->szPan);
    szCardType[0] = ptApp->cOutCardType;
    dAmount = atoll(ptApp->szAmount) / 100.00f;
    dAddiAmount = atoll(ptApp->szAddiAmount) / 100.00f;
    strcpy(szAccount2, ptApp->szAccount2);
    strcpy(szReturnCode, "NN");
    szCancelFlag[0] = 'N';
    szRecoverFlag[0] = 'N';
    szPosSettle[0] = 'N';
    BcdToAsc(ptApp->szMac, 16, 0, szMac);
    strcpy(szDeptDetail, ptApp->szDeptDetail);

    BeginTran();

    EXEC SQL
        INSERT INTO posls (shop_no, pos_no, psam_no, pos_trace, batch_no, sys_trace,
                           trans_type, business_type, pan, card_type, amount, account2,
                           pos_date, pos_time, financial_code, business_code, bank_id,
                           return_code, cancel_flag, recover_flag, pos_settle, mac, dept_detail)
        VALUES(:szShopNo, :szPosNo, :szPsamNo, :iPosTrace, :iBatchNo, :iSysTrace,
               :iTransType, :iBusinessType, :szPan, :szCardType, :dAmount, :szAccount2,
               :szPosDate, :szPosTime, :szFinancialCode, :szBusinessCode, :szAcqBankId,
               :szReturnCode, :szCancelFlag, :szRecoverFlag, :szPosSettle, :szMac, :szDeptDetail);
    if(SQLCODE)
    {
        WriteLog(ERROR, "����POS��ˮ��¼ʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

        RollbackTran();

        return FAIL;
    }

    CommitTran();

    return SUCC;
}
