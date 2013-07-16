/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:
** �� �� ��:
** ��������:


$Revision: 1.2 $
$Log: ChkOperValid.ec,v $
Revision 1.2  2012/12/20 06:43:05  wukj
*** empty log message ***

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
** ��    ��:������Ա�Ƿ���ڣ���У�����롣�����szOperNoΪ����Ա"0001"�Ĳ���Ա��һ�ε�½����ֱ�Ӳ����terminal_oper��
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
*****************************************************************/
int ChkOperValid(ptAppStru)
T_App *ptAppStru;
{
    int iRet = 0;
    EXEC SQL BEGIN DECLARE SECTION;
        
        char  szMsShopNo[15+1];
        char  szMsPosNo[15+1];
        char  szMsOperNo[4+1];
        char  szMsOperPwd[6+1];

        char  szOperPwd[6+1];
        char  szOperName[20];
        int   iDelFlag;
        int   iLoginStatus;
    EXEC SQL END DECLARE SECTION;
     

    memset( szMsShopNo, 0, sizeof(szMsShopNo)    );
    memset( szMsPosNo, 0, sizeof( szMsPosNo) );
    memset( szMsOperNo, 0, sizeof( szMsOperNo) );
    memset( szMsOperPwd, 0, sizeof(szMsOperPwd) );

    strcpy( szMsShopNo,  ptAppStru->szShopNo);
    strcpy( szMsPosNo,  ptAppStru->szPosNo);
    memcpy( szMsOperNo,  ptAppStru->szFinancialCode, 4);
    memcpy( szMsOperPwd,  ptAppStru->szBusinessCode, 6);

    EXEC SQL SELECT     
        NVL(OPER_PWD,' '),
        NVL(OPER_NAME,' '),
        NVL(DEL_FLAG, 0),
        NVL(LOGIN_STATUS,0)
    INTO 
        :szOperPwd,
        :szOperName,
        :iDelFlag,
        :iLoginStatus
    
    FROM
        terminal_oper t
    WHERE
        t.shop_no=:szMsShopNo
        and t.oper_no=:szMsOperNo 
        and t.pos_no =:szMsPosNo
        and t.del_flag=0 ;
    if( SQLCODE )
    {
        WriteLog(ERROR,"�̻�[%s]����Ա[%s]������,SQLCODE[%d]",szMsShopNo,szMsOperNo,SQLCODE );
        strcpy(ptAppStru->szRetCode, ERR_EPOS_OPERPWD_ERROR);
        return SQL_NO_RECORD ;
    }
    iRet = strcmp( ptAppStru->szBusinessCode, szOperPwd);
    if( iRet != 0 )
    {
        WriteLog(ERROR,"�̻�[%s]����Ա[%s]���벻��",szMsShopNo,szMsOperNo);
        strcpy(ptAppStru->szRetCode, ERR_EPOS_OPERPWD_ERROR);
        return FAIL;
    }
    
    return SUCC;
}
