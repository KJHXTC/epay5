/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:�ն������ཻ��

** �����б�:
** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.3 $
$Log: DownFirstPage.ec,v $
Revision 1.3  2013/01/24 07:41:31  wukj
QLCODE��ӡ��ʽ�޸�Ϊ%d

Revision 1.2  2012/12/20 06:43:05  wukj
*** empty log message ***

Revision 1.1  2012/12/18 10:04:56  wukj
*** empty log message ***

*******************************************************************/

# include "manatran.h"

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL EnD DECLARE SECTION;
#endif

/*****************************************************************
** ��    ��: ��ҳ��Ϣ����
** �������:
           ptAppStru
** �������:
           ptAppStru->szReserved        ��ҳ��Ϣ
           ptAppStru->iReservedLen    ��ҳ��Ϣ����
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
int DownFirstPage( ptAppStru ) 
T_App    *ptAppStru;
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szPsamNo[17], szMessage[256];
        char    szDate[9];
        int    iFirstPage;
    EXEC SQL END DECLARE SECTION;

    strcpy( szPsamNo, ptAppStru->szPsamNo );

    //���ķ����ף������ж��Ƿ���comweb
    strcpy( ptAppStru->szAuthCode, "YES" );

    ptAppStru->iReservedLen = 0;

    //�ն˷����ϴ����ؽ�������û����ն�&comweb
    if( memcmp( ptAppStru->szTransCode, "FF", 2 ) == 0 )
    {
        strcpy( ptAppStru->szAuthCode, "NO" );

        //���سɹ���������ҳ��Ϣ��¼Ϊ0
        if( memcmp( ptAppStru->szHostRetCode, "00", 2 ) == 0 )
        {
            EXEC SQL UPDATE terminal 
            set first_page = 0
            WHERE psam_no = :szPsamNo;
            if( SQLCODE )
            {
                strcpy(ptAppStru->szRetCode, ERR_SYSTEM_ERROR);
                WriteLog(ERROR, "update term fail %d", SQLCODE );
                RollbackTran();
                return FAIL;
            }
            CommitTran();
        }

        strcpy( ptAppStru->szRetCode, TRANS_SUCC );
        return SUCC;
    }

    EXEC SQL SELECT NVL(first_page,0)
    INTO :iFirstPage
    FROM terminal
    WHERE psam_no = :szPsamNo;
    if( SQLCODE )
    {
        WriteLog( ERROR, "SELECT term fail %d", SQLCODE );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    GetSysDate( szDate );

    EXEC SQL SELECT NVL(message,' ') 
    INTO :szMessage
    FROM first_page 
    WHERE recno = :iFirstPage and valid_date >= :szDate;
    //��Ӧ��ҳ��Ϣ�Ѿ���ɾ�����ѹ���Ч��
    if( SQLCODE == SQL_NO_RECORD )
    {
        strcpy( ptAppStru->szRetCode, ERR_INVALID_FIRST_PAGE );
        WriteLog( ERROR, "first page[%d] has been deleted or invalid", iFirstPage);
        return FAIL;
    }
    else if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "SELECT sms fail %d", SQLCODE );
        return FAIL;
    }
    
    DelTailSpace( szMessage );
    ptAppStru->iReservedLen = strlen( szMessage );
    memcpy( ptAppStru->szReserved, szMessage, ptAppStru->iReservedLen );

    strcpy( ptAppStru->szNextTransCode, "FF" );
    memcpy( ptAppStru->szNextTransCode+2, ptAppStru->szTransCode+2, 6 );
    ptAppStru->szNextTransCode[8] = 0;

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}
