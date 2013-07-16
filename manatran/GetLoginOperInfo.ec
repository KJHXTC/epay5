/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:
** �� �� ��:
** ��������:2012/12/18


$Revision: 1.1 $
$Log: GetLoginOperInfo.ec,v $
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
** ��    ��:ȡ���ն˵�ǰ��½�Ĳ���Ա����Ϣ
** �������:
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
int GetLoginOperInfo( ptAppStru, ptTerminalOper )
T_App *ptAppStru ;
T_TERMINAL_OPER *ptTerminalOper;
{
    
    EXEC SQL BEGIN DECLARE SECTION;
        char    szMsShopNo[15+1];
        char    szMsPosNo[15+1];        

        char  szShopNo[15+1] ;
        char  szPosNo[15+1];
        char  szOperNo[4+1];
        char  szOperPwd[6+1];
        char  szOperName[20];
        int   iDelFlag;
        int   iLoginStatus;
    EXEC SQL END DECLARE SECTION;

    memset( szMsShopNo, 0, sizeof(szMsShopNo) );
    memset( szMsPosNo, 0, sizeof(szMsPosNo) );
    memset( &ptTerminalOper, 0, sizeof(T_TERMINAL_OPER) );

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
        and t.login_status = 1 ;
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
