/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:��ӡ��غ���

** �����б�:
** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.3 $
$Log: Print.ec,v $
Revision 1.3  2013/01/24 07:41:31  wukj
QLCODE��ӡ��ʽ�޸�Ϊ%d

Revision 1.2  2013/01/24 07:32:36  fengw
*** empty log message ***

Revision 1.1  2012/12/18 10:25:53  wukj
*** empty log message ***

Revision 1.10  2012/12/10 05:32:12  wukj
*** empty log message ***

Revision 1.9  2012/12/07 07:21:03  wukj
*** empty log message ***

Revision 1.8  2012/12/05 06:32:01  wukj
*** empty log message ***

Revision 1.7  2012/12/03 03:25:08  wukj
int����ǰ׺�޸�Ϊi

Revision 1.6  2012/11/29 10:09:04  wukj
��־,bcdascת�����޸�

Revision 1.5  2012/11/20 07:45:39  wukj
�滻\tΪ�ո����

Revision 1.4  2012/11/19 01:58:29  wukj
�޸�app�ṹ����,����ͨ��

Revision 1.3  2012/11/16 08:38:12  wukj
�޸�app�ṹ��������

Revision 1.2  2012/11/16 03:25:05  wukj
����CVS REVSION LOGע��

*******************************************************************/

#include "manatran.h"

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
        EXEC SQL INCLUDE SQLCA;
        EXEC SQL INCLUDE "../incl/DbStru.h";
EXEC SQL EnD DECLARE SECTION;
#endif


/*****************************************************************
** ��    ��:��ȡ���״�ӡģ��� 
** �������:
           iTrans        ��������
        
** �������:
          iPrintModule   ��ӡģ���
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
int GetPrintModule( int iTrans, int *iPrintModule )
{
        EXEC SQL BEGIN DECLARE SECTION;
                int     iTransType, iDataIndex;
                char    szTransFlag[2], szOrgCmd[3];
        EXEC SQL END DECLARE SECTION;

        iTransType = iTrans;
        szTransFlag[0] = '1';
        szTransFlag[1] = 0;
        strcpy( szOrgCmd, "21" );
        szOrgCmd[2] = 0;
        *iPrintModule = 0;

        EXEC SQL SELECT data_index 
        INTO :iDataIndex
        FROM trans_commands
        WHERE trans_type = :iTransType AND 
              trans_flag = :szTransFlag AND
              org_command = :szOrgCmd;
        if( SQLCODE == SQL_NO_RECORD )
        {
                WriteLog( ERROR, "print module not exist" );
                return ( FAIL );
        }
        else if( SQLCODE )
        {
                WriteLog( ERROR, "select data_index fail %d", SQLCODE );
                return ( FAIL );
        }

        *iPrintModule = iDataIndex;

        return SUCC;
}

/*****************************************************************
** ��    ��:�ش�ӡ����ȡԭ������ˮ
** �������:
           iTrans        ��������
        
** �������:
          iTransNum      �ݴ��ӡģ���
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
int Reprint( ptAppStru ) 
T_App    *ptAppStru;
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szTransName[21], szShopNo[16], szPosNo[16];
        long    lOldTrace, lCurTrace;
        int     iTransType;
        T_POSLS  tPosLs;
        T_SHOP tShop;
    EXEC SQL END DECLARE SECTION;

    double     dData;
    long    l;
    int    iPrintModule, iRet, iCardLevel;

    strcpy( szShopNo, ptAppStru->szShopNo );
    strcpy( szPosNo, ptAppStru->szPosNo );

    lCurTrace = ptAppStru->lPosTrace;
    if( lCurTrace == 1 )
    {
        lCurTrace = 999999;
    }

    /* �����û��������ˮ��ȡԭ������ˮ */
    if( ptAppStru->szControlCode[0] == '1' )
    {
        lOldTrace = ptAppStru->lOldPosTrace;
    }
    /* ȡ���ն����һ�ʳɹ�������ˮ */
    else
    {
        iTransType = INQUERY;

        EXEC SQL SELECT NVL(MAX(pos_trace), 0) 
        INTO :lOldTrace
        FROM posls
        WHERE shop_no = :szShopNo AND 
              pos_no = :szPosNo AND
              return_code = '00' AND
              cancel_flag = 'N' AND
              recover_flag = 'N' AND
              trans_type != :iTransType AND
              pos_trace <= :lCurTrace;
        if( SQLCODE )
        {
            WriteLog( ERROR, "select max trace fail %d", SQLCODE );
            strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
            return FAIL;
        }
    }
    EXEC SQL SELECT 
        NVL(HOST_DATE,' '),
        NVL(HOST_TIME,' '),
        NVL(PAN,' '),
        NVL(AMOUNT,0.00),
        NVL(CARD_TYPE,'1'),
        NVL(TRANS_TYPE, 0),
        NVL(BUSINESS_TYPE, 0),
        NVL(RETRI_REF_NUM,' '),
        NVL(AUTH_CODE, ' '),
        NVL(POS_NO,' '),
        NVL(SHOP_NO, ' '),
        NVL(ACCOUNT2, ' '),
        NVL(ADDI_AMOUNT, 0.00),
        NVL(BATCH_NO, 1),
        NVL(PSAM_NO,' '),
        NVL(INVOICE, 1),
        NVL(RETURN_CODE, ' '),
        NVL(HOST_RET_CODE,' '),
        NVL(CANCEL_FLAG, 'N'),
        NVL(RECOVER_FLAG, 'N'),
        NVL(POS_SETTLE,'N'),
        NVL(POS_BATCH, 'N'),
        NVL(HOST_SETTLE,'N'),
        NVL(SYS_TRACE,1),
        NVL(OLD_RETRI_REF_NUM,' '),
        NVL(POS_DATE,' '),
        NVL(POS_TIME,' '),
        NVL(FINANCIAL_CODE,' '),
        NVL(BUSINESS_CODE, ' '),
        NVL(BANK_ID, ' '),
        NVL(SETTLE_DATE,' '),
        NVL(OPER_NO, '0001'),
        NVL(MAC,' '),
        NVL(POS_TRACE, 1)
     INTO 
        :tPosLs.szHostDate,
        :tPosLs.szHostTime,
        :tPosLs.szPan,
        :tPosLs.dAmount,
        :tPosLs.szCardType,
        :tPosLs.iTransType,
        :tPosLs.szBusinessType,
        :tPosLs.szRetriRefNum,
        :tPosLs.szAuthCode,
        :tPosLs.szPosNo,
        :tPosLs.szShopNo,
        :tPosLs.szAccount2,
        :tPosLs.dAddiAmount,
        :tPosLs.iBatchNo,
        :tPosLs.szPsamNo,
        :tPosLs.iInvoice,
        :tPosLs.szRetCode,
        :tPosLs.szHostRetCode,
        :tPosLs.szCancelFlag,
        :tPosLs.szRecoverFlag,
        :tPosLs.szPosSettle,
        :tPosLs.szPosBatch,
        :tPosLs.szHostSettle,
        :tPosLs.iSysTrace,
        :tPosLs.szOldRetriRefNum,
        :tPosLs.szPosDate,
        :tPosLs.szPosTime,
        :tPosLs.szFinancialCode,
        :tPosLs.szBusinessCode,
        :tPosLs.szBankId,
        :tPosLs.szSettleDate,
        :tPosLs.szOperNo,
        :tPosLs.szMac,
        :tPosLs.iPosTrace
     FROM posls
     WHERE shop_no = :szShopNo AND 
           pos_no = :szPosNo AND
           return_code = '00' AND
           recover_flag = 'N' AND 
           pos_trace = :lOldTrace;

    if( SQLCODE == SQL_NO_RECORD )
    {
        WriteLog( ERROR, "psam[%s] pos_trace[%d] not exist", 
            ptAppStru->szPsamNo, lOldTrace );
        strcpy( ptAppStru->szRetCode, ERR_TRANS_NOT_EXIST );
        return FAIL;
    }
    else if( SQLCODE )
    {
        WriteLog( ERROR, "select posls fail %d", SQLCODE );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    strcpy( ptAppStru->szHostDate, tPosLs.szHostDate);
    strcpy( ptAppStru->szHostTime, tPosLs.szHostTime);
    
    DelTailSpace( tPosLs.szPan );
    strcpy( ptAppStru->szPan, tPosLs.szPan );

    dData = tPosLs.dAmount*100.0;
    l = ((long)dData);
    sprintf ( ptAppStru->szAmount, "%012ld", l );

    ptAppStru->iOldTransType = tPosLs.iTransType;
    ptAppStru->lOldPosTrace  = tPosLs.iPosTrace;

    strcpy( ptAppStru->szRetriRefNum, tPosLs.szRetriRefNum );

    strcpy( ptAppStru->szAccount2, tPosLs.szAccount2 );

    dData = tPosLs.dAddiAmount*100.0;
    l = ((long)(dData));
    sprintf ( ptAppStru->szAddiAmount, "%012ld", l );

    ptAppStru->lBatchNo = tPosLs.iBatchNo;
    ptAppStru->lSysTrace = tPosLs.iSysTrace;

    strcpy( ptAppStru->szPosDate, tPosLs.szPosDate);
    strcpy( ptAppStru->szPosTime, tPosLs.szPosTime);

    strcpy( ptAppStru->szHostRetCode, tPosLs.szHostRetCode);

    strcpy( ptAppStru->szOperNo, tPosLs.szOperNo);
    strcpy( ptAppStru->szOutBankId, tPosLs.szBankId);
    strcpy( ptAppStru->szFinancialCode, tPosLs.szFinancialCode);
    strcpy( ptAppStru->szBusinessCode, tPosLs.szBusinessCode);

    /* ȡ�����ཻ��ԭ������ˮ��(����֧���������볷���ཻ��ϵͳ���ٺ�һ����
    �����������Ҫȥ�����ʳ������� */
    if( tPosLs.iTransType == PUR_CANCEL ||
    tPosLs.iTransType == PRE_CANCEL || tPosLs.iTransType == CON_CANCEL ||
        tPosLs.iTransType == TRAN_CANCEL || tPosLs.iTransType == TRAN_IN_CANCEL ||
        tPosLs.iTransType == TRAN_OUT_CANCEL )
    {
        EXEC SQL SELECT pos_trace INTO :lOldTrace
        FROM posls
        WHERE Retri_Ref_Num = :tPosLs.szOldRetriRefNum AND
        pos_trace <> :tPosLs.iPosTrace;
        if( SQLCODE == SQL_NO_RECORD )
        {
            lOldTrace = 0;
        }
        else if( SQLCODE )
        {
            WriteLog( ERROR, "select old_trace fail %d", SQLCODE );
            strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
            return FAIL;
        }


        ptAppStru->lRate = lOldTrace;
    }

    GetCardType(ptAppStru);
    GetAcctType(ptAppStru);

    /* ȡ�������� */
    EXEC SQL SELECT trans_name INTO :szTransName 
        FROM trans_def
        WHERE trans_type = :tPosLs.iTransType;
    if( SQLCODE == SQL_NO_RECORD )
    {
        strcpy( szTransName, "δ֪����" );
    }
    else if( SQLCODE )
    {
        WriteLog( ERROR, "select trans_name fail %d", SQLCODE );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }
    DelTailSpace( szTransName );
    strcpy( ptAppStru->szReserved, szTransName );

    /* ȡ�̻���Ϣ */
    EXEC SQL SELECT 
        SHOP_NO,
        NVL(MARKET_NO,0),
        NVL(SHOP_NAME, ' '),
        NVL(ACQ_BANK,' '),
        NVL(CONTACTOR, ' '),
        NVL(TELEPHONE,' '),
        NVL(ADDR, ' '),
        NVL(FEE,0),
        NVL(FAX_NUM,' '),
        NVL(SIGN_FLAG,0),
        NVL(SIGN_DATE,' '),
        NVL(UNSIGN_DATE,' '),
        NVL(DEPT_NO,' ')
     INTO 
        :tShop.szShopNo,
        :tShop.iMarketNo,
        :tShop.szShopName,
        :tShop.szAcqBank,
        :tShop.szContactor,
        :tShop.szTelephone,
        :tShop.szAddr,
        :tShop.iFee,
        :tShop.szFaxNum,
        :tShop.iSignFlag,
        :tShop.szSignDate,
        :tShop.szUnSignDate,
        :tShop.szDeptNo
     FROM shop
     WHERE shop_no = :szShopNo;

    if( SQLCODE == SQL_NO_RECORD )
    {
        strcpy( ptAppStru->szRetCode, ERR_INVALID_MERCHANT );    
        WriteLog ( ERROR, "shop [%s] not found", szShopNo );
        return ( FAIL );

    }
    else if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );    
        WriteLog( ERROR, "select shop[%s] fail [%d]", szShopNo, SQLCODE );
        return ( FAIL );

    }

    /* ����ն�״̬ */
    DelTailSpace( tShop.szShopName);
    DelTailSpace( tShop.szAcqBank );
    ptAppStru->lMarketNo = tShop.iMarketNo;
    strcpy( ptAppStru->szShopName, tShop.szShopName);
    strcpy( ptAppStru->szAcqBankId, tShop.szAcqBank );

    /* ��ȡ��ӡģ�� */
    iRet = GetPrintModule( tPosLs.iTransType, &iPrintModule );
    if( iRet != SUCC )
    {
        iPrintModule = 8;
    }
    /* �ݴ��ӡģ�� */
    ptAppStru->iTransNum = iPrintModule;

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}

