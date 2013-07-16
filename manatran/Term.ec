/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:�ն˵Ǽ����

** �����б�:
** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.2 $
$Log: Term.ec,v $
Revision 1.2  2013/01/24 07:41:31  wukj
QLCODE��ӡ��ʽ�޸�Ϊ%d

Revision 1.1  2012/12/18 10:25:53  wukj
*** empty log message ***

Revision 1.9  2012/12/18 04:57:16  wukj
*** empty log message ***

Revision 1.8  2012/12/14 02:09:24  wukj
*** empty log message ***

Revision 1.7  2012/12/05 06:32:01  wukj
*** empty log message ***

Revision 1.6  2012/12/03 03:25:08  wukj
int����ǰ׺�޸�Ϊi

Revision 1.5  2012/11/29 10:09:04  wukj
��־,bcdascת�����޸�

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
** ��    ��:�ն˵Ǽ�����
** �������:
          ptAppStru
        
** �������:
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
int
TermRegister( ptAppStru ) 
T_App    *ptAppStru;
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szPsamNo[17];
        char    szTeleNo[40];
        char    szShopNo[16];
        char    szPosNo[16];
        char    szPutDate[9];
        int iCount;
    EXEC SQL END DECLARE SECTION;
    char szDate[8+1];
    int    iRet;
    memset( szPsamNo, 0, sizeof(szPsamNo));
    memset( szTeleNo, 0, sizeof(szTeleNo));
    memset( szShopNo, 0, sizeof(szShopNo));
    memset( szPosNo, 0, sizeof(szPosNo));
    memset( szDate , 0, sizeof(szDate));

    strcpy( szPsamNo, ptAppStru->szPsamNo);
    strcpy( szTeleNo, ptAppStru->szBusinessCode);
    strcpy( szShopNo, ptAppStru->szReserved);
    strcpy( szPosNo, ptAppStru->szFinancialCode);
    if( strlen(ptAppStru->szReserved) == 0 || strlen(ptAppStru->szFinancialCode) == 0)
    {
        WriteLog( ERROR, "��������Ч���̻��Ż��ն˺�[%s],[%s]", szShopNo,szPosNo );
        strcpy( ptAppStru->szRetCode, ERR_INVALID_TERM );
        return FAIL;
    }
    if (strlen(ptAppStru->szBusinessCode) == 0)
    {
        strcpy(szTeleNo, "00000000");
    }
            
    /* ���PSAM���Ƿ񱻵Ǽ� */
    EXEC SQL SELECT count(*) INTO :iCount
        FROM terminal
        WHERE psam_no = :szPsamNo;
    if( SQLCODE && SQLCODE != SQL_NO_RECORD)
    {
        WriteLog( ERROR, "select terminal fail %d", SQLCODE );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }
    if (iCount > 0)
    {
        WriteLog( ERROR, "PSAM���Ѿ����Ǽǣ����ʵ[%s]",szPsamNo );
        strcpy( ptAppStru->szRetCode, PSAMNO_INVALID );
        return FAIL;
    }
    /* ����̻��š��ն˺��Ƿ񱻵Ǽ� */
    EXEC SQL SELECT count(*) INTO :iCount
        FROM terminal
        WHERE shop_no = :szShopNo and pos_no = :szPosNo;
    if( SQLCODE && SQLCODE != SQL_NO_RECORD)
    {
        WriteLog( ERROR, "select terminal fail %d", SQLCODE );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }
    if (iCount > 0)
    {
        WriteLog( ERROR, "�̻��š��ն˺��Ѿ����Ǽǣ����ʵ[%s][%s]",szShopNo,szPosNo );
        strcpy( ptAppStru->szRetCode, SHOP_TERM_INVALID );
        return FAIL;
    }
    
    /* �����ն���Ϣ */
    GetSysDate( szDate );
    strcpy(szPutDate, szDate);
    EXEC SQL INSERT INTO TERMINAL 
             (SHOP_NO, POS_NO, PSAM_NO,
              TELEPHONE,TERM_MODULE,PSAM_MODULE,
              POS_TYPE,PUT_DATE,FIRST_PAGE,
              STATUS,APP_TYPE,ADDRESS)
         VALUES
              (:szShopNo, :szPosNo, :szPsamNo,
              :szTeleNo, 1, 1,
              'SPP-100',:szPutDate, 0,
              1,3,'�ͻ���ַ');
    if( SQLCODE )
    {
        WriteLog( ERROR, "insert terminal fail %d", SQLCODE );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }
    CommitTran();

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}

/*****************************************************************
** ��    ��:�ն˰�(�����Ǽ�)
** �������:
          ptAppStru
        
** �������:
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
int TermTelRegister( ptAppStru, iTeleLen ) 
T_App    *ptAppStru;
int iTeleLen;
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szPsamNo[17], szTeleNo[40], szIp[16];
        char    szPin[9], szPinKey[33];
        int    iTermModu, iKeyIndex;
    EXEC SQL END DECLARE SECTION;
    char     szTmpStr[9], szBcdPinKey[17], szHsmRet[10];
    int    iRet;

    iTermModu = ptAppStru->iTermModule;
    strcpy( szIp, ptAppStru->szIp );
    if( strlen(ptAppStru->szBusinessCode) == 0 )
    {
        /*ȥ���绰����ǰ������*/
        memcpy( szTeleNo, ptAppStru->szCalledTelByTerm+strlen(ptAppStru->szCalledTelByTerm)-iTeleLen, iTeleLen );
        szTeleNo[iTeleLen] = 0;
    }
    else
    {
        strcpy( szTeleNo, ptAppStru->szBusinessCode);
    }
    strcpy( szPsamNo, ptAppStru->szPsamNo);

    memcpy( szTmpStr, szPsamNo+8, 8 );
    szTmpStr[8] = 0;
    iKeyIndex = atol(szTmpStr);
    
    /* ���������ն˹��������Ƿ���ȷ */
    EXEC SQL SELECT manager_pwd INTO :szPin
        FROM terminal_para
        WHERE module = :iTermModu;
    if( SQLCODE == SQL_NO_RECORD )
    {
        WriteLog( ERROR, "module %d not exist", iTermModu );
        strcpy( ptAppStru->szRetCode, ERR_TERM_MODULE );
        return FAIL;
    }
    else if( SQLCODE )
    {
        WriteLog( ERROR, "select manager_pwd fail %d", SQLCODE );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    EXEC SQL SELECT pin_key INTO :szPinKey
        FROM pos_key
        WHERE key_index = :iKeyIndex;    
    if( SQLCODE )
    {
        WriteLog( ERROR, "select pin_key fail %d", SQLCODE );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }
    
    AscToBcd( (uchar *)szPinKey, 32, 0, (uchar *)szBcdPinKey );

    iRet = HsmVerifyPin( ptAppStru, szPin, szBcdPinKey, szHsmRet );
        if( iRet != SUCC )
        {
            WriteLog( ERROR, "encrypt pin fail" );
                   strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR);
                   return ( FAIL );
        }

    /* ���������Ƿ�һ�� */
    if( memcmp( szHsmRet, "SUCC", 4 ) != 0 )
    {
        WriteLog( ERROR, "passwd error" );
                   strcpy( ptAppStru->szRetCode, ERR_OPERPWD_ERROR );
                   return ( FAIL );
    }

    EXEC SQL UPDATE terminal set telephone = :szTeleNo, ip = :szIp
    where psam_no = :szPsamNo;
    if( SQLCODE )
    {
        WriteLog( ERROR, "update terminal fail %d", SQLCODE );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        RollbackTran();
        return FAIL;
    }
    CommitTran();

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}

