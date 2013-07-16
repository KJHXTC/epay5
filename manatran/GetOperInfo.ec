/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:
** �� �� ��:
** ��������:


$Revision: 1.1 $
$Log: GetOperInfo.ec,v $
Revision 1.1  2012/12/18 04:29:59  wukj
*** empty log message ***


*******************************************************************/

# include "manatran.h"

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
        EXEC SQL INCLUDE SQLCA;
EXEC SQL EnD DECLARE SECTION;
#endif
/*****************************************************************
** ��    ��:ȡ�ն˲���Ա��Ϣ
** �������:
           oper_no ����Ա���
** �������:
           tTermOperStru  �ն˲���Ա��ṹ��
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
*****************************************************************/
int GetOperInfo( ptAppStru , ptTerminalOper)
T_App *ptAppStru ;
T_TERMINAL_OPER *ptTerminalOper;
{
    EXEC SQL BEGIN DECLARE SECTION;
        
        char    szMsOperNo[4+1];
        char     szMsShopNo[15+1];
        char    szMsPosNo[15+1];

        char  szShopNo[15+1] ;
        char  szPosNo[15+1];
        char  szOperNo[4+1];
        char  szOperPwd[6+1];
        char  szOperName[20];
        int   iDelFlag;
        int   iLoginStatus;
    EXEC SQL END DECLARE SECTION;
    
    memset( &ptTerminalOper, 0, sizeof(T_TERMINAL_OPER) );
    memset( szMsOperNo, 0, sizeof(szMsOperNo) );
    memset( szMsShopNo, 0, sizeof(szMsShopNo) );
    memset( szMsPosNo, 0, sizeof(szMsPosNo) );
    
    memcpy( szMsOperNo, ptAppStru->szFinancialCode, 4);
    strcpy( szMsShopNo, ptAppStru->szShopNo );
    strcpy( szMsPosNo, ptAppStru->szPosNo );
        
    EXEC SQL SELECT 
        NVL(SHOP_NO,' '),
        NVL(POS_NO,' '),
        NVL(OPER_NO,' '),
        NVL(OPER_PWD,' '),
        NVL(OPER_NAME,' '),
        NVL(DEL_FLAG, 0),
        NVL(LOGIN_STATUS,0)
    
    INTO 
        :szShopNo,
        :szPosNo,
        :szOperNo,
        :szOperPwd,
        :szOperName,
        :iDelFlag,
        :iLoginStatus
    FROM
         terminal_oper t
    WHERE
        t.shop_no =:szMsShopNo
        and t.pos_no =:szMsPosNo  
        and t.oper_no =:szMsOperNo ;
    if(SQLCODE == SQL_NO_RECORD)
    {
        return SQL_NO_RECORD;
    }
    if( SQLCODE )
    {
        WriteLog(ERROR,"ȡ����Ա��Ϣʧ�ܣ�SQLCODE[%d]", SQLCODE );
        return FAIL;
    }
            
    strcpy(ptTerminalOper->szShopNo,szShopNo);
    strcpy(ptTerminalOper->szPosNo,szPosNo);
    strcpy(ptTerminalOper->szOperNo,szOperNo);
    strcpy(ptTerminalOper->szOperPwd,szOperPwd);
    strcpy(ptTerminalOper->szOperName,szOperName);
    ptTerminalOper->iDelFlag =  iDelFlag;
    ptTerminalOper->iLoginStatus = iLoginStatus;
    return SUCC;
}

