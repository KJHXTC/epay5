/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:�ն˲���Ա��ؽ���
** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.1 $
$Log: OperOpt.ec,v $
Revision 1.1  2012/12/18 10:25:53  wukj
*** empty log message ***

Revision 1.10  2012/12/18 04:29:59  wukj
*** empty log message ***

Revision 1.9  2012/12/10 05:32:12  wukj
*** empty log message ***

Revision 1.8  2012/12/05 06:32:01  wukj
*** empty log message ***

Revision 1.7  2012/12/03 03:25:08  wukj
int����ǰ׺�޸�Ϊi

Revision 1.6  2012/11/29 10:09:03  wukj
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

# include "manatran.h"

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
        EXEC SQL INCLUDE SQLCA;
        EXEC SQL INCLUDE "../incl/DbStru.h";
EXEC SQL EnD DECLARE SECTION;
#endif

int GetEposLoginOperNo(T_App *ptAppStru,char *szOperNo);

/*****************************************************************
** ��    ��:�ն˲���Ա��½ǩ������
               ���׹���
               ���ݿ��terminal_oper���޴��ն˵Ĳ���Ա��Ϣ
               1������ն����Ͳ���Ա��Ϊ��0001��������Ա����Ϊ��000000����
                  ����terminal_oper������Ӹ��ն˵ĳ�ʼ����Ա��
                  ����Ա��Ϊ��0001������ʼ����Ϊ��000000��������Ϊ������Ա����
               2�����򷵻ء��޴˲���Ա��������󡱡�
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
int EposOperLogin( ptAppStru )
T_App *ptAppStru;
{
    int iRet = 0;
    
    EXEC SQL BEGIN DECLARE SECTION;
        char  szMsOperNo[4+1];
        char  szMsOperPwd[6+1];
        char  szMsShopNo[15+1];
    EXEC SQL END DECLARE SECTION;
    
    memset(    szMsOperNo, 0, sizeof( szMsOperNo) ) ;
    memset(    szMsOperPwd, 0,    sizeof(szMsOperPwd) );    
    memset( szMsShopNo , 0, sizeof(szMsShopNo) );
    
    /*���볤��У��*/
    if(strlen(ptAppStru->szBusinessCode) != 6 )
    {
        strcpy(ptAppStru->szRetCode, ERR_EPOS_OPERPWD_ERROR);
        WriteLog(ERROR,"���볤�Ȳ��Ϸ�");
        return FAIL;
    }
    
    /*��������Ա��� */
    memcpy(    szMsOperNo, ptAppStru->szFinancialCode, 4 ); 
    /*��������Ա����*/
    memcpy(    szMsOperPwd, ptAppStru->szBusinessCode, 6 );
    /*�����̻���*/
    memcpy( szMsShopNo, ptAppStru->szShopNo, 15 );
    
    /*�ڱ�terminal_oper��У�����Ա�Ƿ�Ϸ�:1������Ա�Ƿ���ڣ�2�������Ƿ���ȷ
    *chk_oper_vaild()�Ѷ��������������ֵ��Ӧ�������
    */
    WriteLog(TRACE,"����Ա��½���׿�ʼ shop[%s] operno[%s]����",szMsShopNo,szMsOperNo);
    
    BeginTran();
    
    iRet = ChkOperValid( ptAppStru );
    if( iRet  !=  SUCC )
    {
        /*��Ϊ�̻�����Ա��һ�ε�½�������Ӹò���Ա*/
        if( memcmp( ptAppStru->szFinancialCode, "0001", 4) == 0 && 
                memcmp( ptAppStru->szBusinessCode, "000000", 6) == 0 &&
            iRet == SQL_NO_RECORD )
        {
            iRet = Insert2TerminalOper( ptAppStru, "����Ա", "000000" );
            if(iRet != SUCC )
            {
                strcpy(ptAppStru->szRetCode, ERR_SYSTEM_ERROR);
                WriteLog(ERROR,"�̻�[%s]����Ա[%s]���ӹ���Աʧ��",szMsShopNo,szMsOperNo);
                return FAIL;
            }
            
        }
        else
        {    
            WriteLog(ERROR,"�̻�[%s]����Ա[%s]�Ƿ�",ptAppStru->szShopNo,ptAppStru->szFinancialCode);
            return FAIL;
        }
    }
    
    WriteLog(TRACE,"����Ա�Ϸ��Լ����ϣ�״̬�Ϸ����� shop[%s] operno[%s]����",szMsShopNo,szMsOperNo);
    
    /*�޸Ķ�ӦEPOS�������ѵ�½����Ա��״̬Ϊǩ��*/
    iRet = OtherOperLoginOut( ptAppStru );
    if( iRet != SUCC && iRet != SQL_NO_RECORD )
    {
        RollbackTran();
        WriteLog(ERROR,"ǩ��EPOS��%s�������в���Աʧ�ܣ�SQLCODE[%d]",ptAppStru->szPosNo,SQLCODE);
        return FAIL;
    }
    
    WriteLog(TRACE,"ǩ��POS����������Ա����");
    
    /*�޸�terminal_oper���ж�Ӧ����Ա��pos_noΪ��ǰ�ն˱��,*/
    iRet = UpdateOperStatusLogin( ptAppStru );
    if( iRet != SUCC )
    {
        RollbackTran();
        WriteLog(ERROR, "�޸��̻�[%s]����Ա[%s]��½ʧ��",ptAppStru->szShopNo,ptAppStru->szFinancialCode );
        return FAIL;
    }
    
    CommitTran();
    WriteLog(TRACE,"����Ա��½������ɡ��� shop[%s] operno[%s]����",szMsShopNo,szMsOperNo);
    
    strcpy(ptAppStru->szRetCode, TRANS_SUCC);
    return SUCC;
}

/*****************************************************************
** ��    ��:����EPOS����Ա,�ù���ֻ���б��Ϊ"0001"�Ĳ���Աʹ��
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
int EposOperAdd(ptAppStru)
T_App *ptAppStru;
{
    int iRet = 0;
    EXEC SQL BEGIN DECLARE SECTION;
        T_TERMINAL_OPER tTerminalOper;
        char  szMsShopNo[15+1];
        char  szMsOperNo[4+1];
        char  szMsOperName[20+1];
    EXEC SQL END DECLARE SECTION;
    
    memset( &tTerminalOper, 0, sizeof( T_TERMINAL_OPER) );
    memset(    szMsOperNo, 0, sizeof( szMsOperNo) );
    memset( szMsOperName, 0, sizeof(szMsOperName) );

    memcpy( szMsOperName, ptAppStru->szBusinessCode, 20 );
    memcpy( szMsShopNo, ptAppStru->szShopNo, 15);
    
    WriteLog(TRACE,"���Ӳ���Ա���׿�ʼ ");
    
    BeginTran();
    
    /*ȡ���ն˵�¼�Ĳ���Ա���*/
    iRet = GetEposLoginOperNo(ptAppStru,szMsOperNo);
    if( iRet != SUCC )
    {
        strcpy(ptAppStru->szRetCode, ERR_SYSTEM_ERROR);
        WriteLog(ERROR," ��ǰ�ն��޲���Ա��¼�����¼");
        return FAIL;
    }
    
    if( strcmp( szMsOperNo, "0001") != 0 )
    {
        strcpy(ptAppStru->szRetCode, ERR_EPOS_OPT_INVALID);
        WriteLog(ERROR,"�̻�[%s]����Ա[%s]��Ȩ���Ӳ���Ա",ptAppStru->szShopNo ,szMsOperNo);
        return FAIL;
    }
            
    WriteLog(TRACE,"���Ӳ���Ա���ס��� shop[%s] ����Ա[%s]����",szMsShopNo,szMsOperNo);    
    
    memset( szMsOperNo, 0, sizeof(szMsOperNo) );
    memcpy( szMsOperNo, ptAppStru->szFinancialCode , 4);

    /*���Ӳ���Ա*/
    iRet = Insert2TerminalOper( ptAppStru, szMsOperName , "000000" );
    if( SUCC != iRet )
    {
        RollbackTran();
        WriteLog(ERROR,"�̻�[%s]���Ӳ���Ա[%s]ʧ��",szMsShopNo,szMsOperNo);
        return FAIL;
    }
    
    CommitTran();
    
    WriteLog(TRACE,"���Ӳ���Ա���׽��� ����shop[%s] operno[%s]����",szMsShopNo,szMsOperNo);
    
    strcpy(ptAppStru->szRetCode, TRANS_SUCC);
    
    return SUCC;
    
}

/*****************************************************************
** ��    ��:ɾ���ն˲���Ա��������ֻ���ɹ���Ա'0001'�����'0001'�Ĳ���Ա���ܱ�ɾ��
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
int EposOperDel( ptAppStru )
T_App *ptAppStru;
{
    int iRet = 0;
    EXEC SQL BEGIN DECLARE SECTION;
        T_TERMINAL_OPER tTerminalOper;
    
        char  szMsShopNo[15+1];
        char  szMsOperNo[4+1];
        char  szMsDelOperNo[4+1];
        char  szMsPosNo[15+1];
    EXEC SQL END DECLARE SECTION;
    
    memset( &tTerminalOper, 0, sizeof( T_TERMINAL_OPER) );
    memset(    szMsShopNo, 0, sizeof(szMsShopNo) );
    memset(    szMsOperNo, 0, sizeof( szMsOperNo) );
    memset(    szMsDelOperNo, 0, sizeof( szMsDelOperNo) );
    memset( szMsPosNo, 0, sizeof(szMsPosNo) );

    strcpy(    szMsShopNo,  ptAppStru->szShopNo);
    strcpy( szMsPosNo, ptAppStru->szPosNo );
    memcpy( szMsDelOperNo, ptAppStru->szFinancialCode , 4);
    

    WriteLog(TRACE,"ɾ������Ա���׿�ʼ shop[%s] del_operno[%s]����",szMsShopNo, szMsDelOperNo);
    
    BeginTran();
    
    if( strcmp(szMsDelOperNo, "0001") == 0 )
    {
        strcpy(ptAppStru->szRetCode, ERR_DEL_ADMIN_ERROR);
        WriteLog(ERROR,"�̻�[%s]�ն�[%s]����Ա������ɾ��",szMsShopNo,szMsPosNo);
        return FAIL;
    }
    
    /*ȡ���ն˵�¼�Ĳ���Ա*/
    iRet = GetEposLoginOperNo( ptAppStru, szMsOperNo );
    if( iRet != SUCC )
    {
        strcpy(ptAppStru->szRetCode, ERR_SYSTEM_ERROR);
        WriteLog(ERROR," ��ǰ�ն��޲���Ա��¼�����¼");
        return FAIL;
    }
    
    if( strcmp( szMsOperNo, "0001" ) != 0 )
    {
        strcpy( ptAppStru->szRetCode, ERR_EPOS_OPT_INVALID );
        WriteLog(ERROR,"�̻�[%s]�ն�[%s]��ǰ����Ա[%s]�޴�Ȩ��",szMsPosNo,szMsOperNo);
        return FAIL;
    }
            
    WriteLog(TRACE,"ɾ������Ա���ס��� shop[%s] pos[%s]adminno[%s]����",szMsShopNo,szMsPosNo,szMsOperNo);
    
    /*ɾ������Ա*/
    EXEC SQL UPDATE terminal_oper t
                set 
                    t.del_flag =1,
                    t.login_status =0
                WHERE
                    t.shop_no =:szMsShopNo
                and t.pos_no =:szMsPosNo
                and t.oper_no =:szMsDelOperNo;
    if( SQLCODE && ( SQLCODE != SQL_NO_RECORD ) )
    {
        RollbackTran();
        strcpy(ptAppStru->szRetCode, ERR_SYSTEM_ERROR);
        return FAIL;
    }
    
    CommitTran();
    
    WriteLog(TRACE,"ɾ������Ա���׽��� shop[%s] del_operno[%s]����",szMsShopNo,szMsDelOperNo);
    
    strcpy(ptAppStru->szRetCode, TRANS_SUCC);
    
    return SUCC;
    
}

/*****************************************************************
** ��    ��:�޸Ĳ���Ա����
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
int EposOperUpdatePwd( ptAppStru )
T_App *ptAppStru;
{
    EXEC SQL BEGIN DECLARE SECTION;
        char szMsOldPwd[6+1];
        char szMsNewPwd[7+1];
        char szMsShopNo[15+1];
        char szMsPosNo[15+1];
        char szMsOperNo[4+1];
    EXEC SQL END DECLARE SECTION;
    
    memset( szMsOldPwd, 0, sizeof(szMsOldPwd) );
    memset( szMsNewPwd, 0, sizeof(szMsNewPwd) );
    memset( szMsShopNo, 0, sizeof(szMsShopNo) );
    memset( szMsPosNo, 0, sizeof(szMsPosNo) );
    memset( szMsOperNo, 0, sizeof(szMsOperNo) );


    
    /*���볤��У��*/
    if(  strlen(ptAppStru->szFinancialCode)!= 6 
      || strlen(ptAppStru->szBusinessCode)!= 6  )
     {
         strcpy(ptAppStru->szRetCode, ERR_EPOS_OPERPWD_ERROR);
         WriteLog(ERROR,"���볤�Ȳ��Ϸ�");
        return FAIL;
    }
    
    BeginTran();
    
    /*ȡ����ǰ��¼EPOS�Ĳ���Ա��*/
    GetEposLoginOperNo( ptAppStru,szMsOperNo );

    WriteLog(TRACE,"�޸Ĳ���Ա���뽻�׿�ʼ shop[%s] operno[%s]����",szMsShopNo,szMsOperNo);            
    
    memcpy(szMsOldPwd, ptAppStru->szFinancialCode, 6);
    memcpy(szMsNewPwd, ptAppStru->szBusinessCode, 6);
    memcpy(szMsShopNo, ptAppStru->szShopNo, 15);
    memcpy(szMsPosNo, ptAppStru->szPosNo,15);
    
    EXEC SQL UPDATE terminal_oper t 
                set 
                    t.oper_pwd =:szMsNewPwd
                WHERE
                     t.shop_no =:szMsShopNo 
                 and t.pos_no =:szMsPosNo 
                 and t.oper_pwd =:szMsOldPwd
                 and t.oper_no = :szMsOperNo
                 and t.del_flag =0 
                 and t.login_status =1;
    if( SQLCODE )
    {
        RollbackTran();
        strcpy( ptAppStru->szRetCode, ERR_EPOS_OPERPWD_ERROR );
        WriteLog( ERROR,"�̻�[%s]����Ա[%s]�����������",szMsShopNo,szMsPosNo );
        return FAIL;
    }
    
    WriteLog(TRACE,"�޸Ĳ���Ա���뽻����� shop[%s] pos[%s] operno[%s]����", \
                szMsShopNo,szMsPosNo,szMsOperNo );    
    CommitTran();
    
    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    
    return SUCC;
}


/*****************************************************************
** ��    ��:�޸ı�terminal_oper��pos_noΪptAppStru->szPosNo�ļ�¼�����ü�¼�еĲ���Ա״̬��Ϊǩ�ˡ�
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
int OtherOperLoginOut( ptAppStru )
T_App *ptAppStru;
{
    EXEC SQL BEGIN DECLARE SECTION;
        char szMsPosNo[15+1];
        char szMsShopNo[15+1];
    EXEC SQL END DECLARE SECTION;


    memset( szMsPosNo, 0, sizeof(szMsPosNo)    );
    memset( szMsShopNo, 0, sizeof(szMsShopNo) );

    strcpy( szMsShopNo,  ptAppStru->szShopNo);
    strcpy( szMsPosNo,   ptAppStru->szPosNo);

    EXEC SQL UPDATE terminal_oper t
        set
            t.login_status=0 
        WHERE
            t.shop_no =:szMsShopNo
          and t.pos_no=:szMsPosNo ;
    if( SQLCODE == SQL_NO_RECORD )
    {
             return SQL_NO_RECORD;
    }
    if( SQLCODE )
    {
        strcpy(ptAppStru->szRetCode, ERR_SYSTEM_ERROR);
        return FAIL;
    }

    return SUCC;

}

/*****************************************************************
** ��    ��:��termianl_oper���У��޸�shop_no��szOperNoΪ��ǰ��EOPS��ŵļ�¼������¼��pos_no��ΪptAppStru->szPosNo,�����login_statusΪ��½
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
int UpdateOperStatusLogin(ptAppStru)
T_App *ptAppStru;
{
    EXEC SQL BEGIN DECLARE SECTION;
        char szMsShopNo[15+1];
        char szMsPosNo[15+1];
        char szMsOperNo[4+1];
    EXEC SQL END DECLARE SECTION;

    memset( szMsShopNo, 0, sizeof(szMsShopNo) );
    memset( szMsOperNo, 0, sizeof(szMsOperNo) );
    memset( szMsPosNo, 0, sizeof(szMsPosNo)    );

    strcpy( szMsShopNo, ptAppStru->szShopNo );
    memcpy( szMsOperNo, ptAppStru->szFinancialCode , 4 );
    strcpy( szMsPosNo, ptAppStru->szPosNo );

    EXEC SQL UPDATE    terminal_oper  t
                set
                    t.login_status=1
                WHERE
                    t.shop_no=:szMsShopNo
                    and t.pos_no =:szMsPosNo
                    and t.oper_no=:szMsOperNo 
                    and t.del_flag =0 ;
    if( SQLCODE )
    {
        strcpy(ptAppStru->szRetCode, ERR_SYSTEM_ERROR);
        WriteLog(ERROR,"�޸�terminal_oper����,SQLCODE[%d]",SQLCODE);
        return FAIL;
    }
    return SUCC;
}


/*****************************************************************
** ��    ��:ȡ���ն˵�ǰ��¼�Ĳ���Ա��
** �������:
           ptAppStru
** �������:
           szOperNo ����Ա��
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
*****************************************************************/
int GetEposLoginOperNo(ptAppStru,szOperNo)
T_App *ptAppStru;
char *szOperNo ;
{
    int iRet = 0;
    EXEC SQL BEGIN DECLARE SECTION;
        char szMsOperNo[4+1];
        char szMsShopNo[15+1];
        char szMsPosNo[15+1];
    EXEC SQL END DECLARE SECTION;
    
    memset(    szMsShopNo, 0, sizeof(szMsShopNo) );
    memset(    szMsOperNo, 0, sizeof(szMsOperNo) );
    memset(    szMsPosNo, 0, sizeof(szMsPosNo)    );

    strcpy(    szMsShopNo, ptAppStru->szShopNo );
    strcpy(    szMsPosNo, ptAppStru->szPosNo );
    
    EXEC SQL SELECT oper_no 
    INTO :szMsOperNo
    FROM terminal_oper t
    WHERE t.shop_no=:szMsShopNo
        and t.pos_no=:szMsPosNo
        and t.del_flag=0
        and t.login_status=1;
    if( SQLCODE )
    {
        strcpy(ptAppStru->szRetCode, ERR_SYSTEM_ERROR);
        return FAIL;
    }
    
    strcpy( szOperNo, szMsOperNo );
    
    return SUCC;
}

/*****************************************************************
** ��    ��:��terminal_oper��������һ����¼
** �������:
       oper_name  ����Ա����
       oper_pwd   ����Ա����
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
int Insert2TerminalOper( ptAppStru, szOperName, szOperPwd)
T_App *ptAppStru;
char *szOperName;
char *szOperPwd;
{
    int iRet = 0;
    EXEC SQL BEGIN DECLARE SECTION;
        char szMsShopNo[15+1];
        char szMsOperNo[4+1];
        char szMsOperPwd[6+1];
        char szMsOperName[20+1];
        char szMsPosNo[15+1];
        
    EXEC SQL END DECLARE SECTION;
    T_TERMINAL_OPER tTerminalOper;

    memset( szMsShopNo, 0, sizeof(szMsShopNo) );
    memset( szMsOperNo, 0, sizeof(szMsOperNo) );
    memset( szMsOperPwd, 0, sizeof(szMsOperPwd) );
    memset( szMsOperName, 0, sizeof(szMsOperName));
    memset( szMsPosNo, 0, sizeof(szMsPosNo) );
    
    strcpy( szMsShopNo, ptAppStru->szShopNo );
    memcpy( szMsOperNo, ptAppStru->szFinancialCode, 4 );
    strcpy( szMsPosNo, ptAppStru->szPosNo );
    strcpy( szMsOperPwd, szOperPwd);
    strcpy( szMsOperName, szOperName);
    
    /*ȡ���ն˲���Ա���еĶ�Ӧ��Ϣ�������ݲ�ͬ��������ж�*/
    iRet = GetOperInfo(ptAppStru, &tTerminalOper);    
    if( iRet == SQL_NO_RECORD )    
    {    
        EXEC SQL insert INTO 
                terminal_oper 
                    t(shop_no,pos_no,oper_no,oper_pwd,oper_name,del_flag,login_status)
                values
                    (:szMsShopNo,:szMsPosNo,:szMsOperNo,:szMsOperPwd,:szMsOperName,0,0) ;    
        if( SQLCODE )
        {    
            strcpy(ptAppStru->szRetCode, ERR_SYSTEM_ERROR);
            WriteLog(ERROR,"�̻�[%s]�ն�[%s]���Ӳ���Ա[%s]ʧ��", \
                    szMsShopNo,szMsPosNo,szMsOperNo);
            return FAIL;
        }
    }
    else if( iRet == SUCC && tTerminalOper.iDelFlag)
    {
        /*��¼���ڣ���del_flag״̬Ϊɾ����1*/
        EXEC SQL UPDATE 
                        terminal_oper t
                    set 
                        t.del_flag = 0 ,
                        t.login_status = 0,
                        t.oper_name = :szMsOperName,
                        t.oper_pwd = :szMsOperPwd
                    WHERE
                         t.pos_no =:szMsPosNo
                     and t.shop_no =:szMsShopNo
                     and t.oper_no =:szMsOperNo ;
        if( SQLCODE )
        {
            strcpy(ptAppStru->szRetCode, ERR_SYSTEM_ERROR);
            WriteLog(ERROR,"�̻�[%s]�ն�[%s]���Ӳ���Ա[%s]ʧ��", \
                    szMsShopNo,szMsPosNo,szMsOperNo);
            return FAIL;
        }
    }
    else if( iRet == SUCC && !tTerminalOper.iDelFlag)    
    {
        /*��¼���ڣ���del_flag״̬Ϊδ!ɾ����0*/
        strcpy(ptAppStru->szRetCode, ERR_SYSTEM_ERROR);
        WriteLog(ERROR,"�̻�[%s]�ն�[%s]����Ա[%s]�Ѵ���", \
                    szMsShopNo,szMsPosNo,szMsOperNo);
        return FAIL;
    }    
    else if( iRet == FAIL )
    {
        strcpy(ptAppStru->szRetCode, ERR_SYSTEM_ERROR);
        WriteLog(ERROR,"�̻�[%s]�ն�[%s]���Ӳ���Ա[%s]ʧ��", \
                    szMsShopNo,szMsPosNo,szMsOperNo);
        return FAIL;
    }    
    
    return SUCC ;

}

/*****************************************************************
** ��    ��:��ptAppStru�ṹ�帳ֵ�ն˲���Ա��
            ���׹���
            �����EPOS_OPER_LOGIN���ף�ֱ������ptAppStru->OperNo = AppStru->user_code1
            ���򣬴�terminal_oper����ȡ��szOperNo����ֵ��ptAppStru->OperNo��
            ����������ptAppStru->szOperNo = "0001"
** �������:
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
int SetOper2ptAppStru( ptAppStru )
T_App *ptAppStru ;
{
        int iRet = 0;
        EXEC SQL BEGIN DECLARE SECTION;
                char szOperNo[4+1];
        EXEC SQL END DECLARE SECTION;

        memset( szOperNo, 0, sizeof( szOperNo) );

        if( 5 == ptAppStru->iTransType
            && ( memcmp(ptAppStru->szTransCode,"10000005", 8) == 0 )
           )
        {
                memcpy( ptAppStru->szOperNo, ptAppStru->szFinancialCode, 4 );
                return SUCC;
        }

        iRet = GetEposLoginOperNo( ptAppStru, szOperNo );
        if( iRet == SUCC )
        {
                strcpy( ptAppStru->szOperNo, szOperNo );
                return SUCC;
        }
        else
        {
                memcpy( ptAppStru->szOperNo, "0001", 4 );
                return SUCC;
        }

        return SUCC ;

}

/*****************************************************************
** ��    ��:�жϲ���Ա�������Ƿ����޸ĳ�ʼ���� ��
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
int IsBeginPwd( ptAppStru )
T_App *ptAppStru ;
{
    T_TERMINAL_OPER tTerminalOper;
    
    if( GetLoginOperInfo( ptAppStru, &tTerminalOper) == SUCC )
    {
        if( memcmp(tTerminalOper.szOperPwd,"000000",6) == 0 )
        {
            strcpy(ptAppStru->szRetCode, ERR_EPOS_OPERPWD_NOCHG);
            WriteLog(ERROR,"�����޸ĳ�ʼ���룬�ٽ���");
            return SUCC ;
        }
        else
        {
            return FAIL;
        }
    }
    else
    {
        WriteLog(ERROR,"ȡ����Ա��Ϣʧ��!" );
        return FAIL;
    }
}

