/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:�ն������ཻ��

** �����б�:
** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.18 $
$Log: download.ec,v $
Revision 1.18  2013/01/24 07:41:31  wukj
QLCODE��ӡ��ʽ�޸�Ϊ%d

Revision 1.17  2012/12/21 01:38:58  wukj
*** empty log message ***

Revision 1.16  2012/12/18 10:04:56  wukj
*** empty log message ***

*******************************************************************/

# include "manatran.h"

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL EnD DECLARE SECTION;
#endif

/*****************************************************************
** ��    ��: �ϵ�������ȡ�ϴ����ز���(���ϴν����е����ؽ���)
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
int GetDownAllTransType( ptAppStru ) 
T_App    *ptAppStru;
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szPsamNo[17];
        int    iTransType;
    EXEC SQL END DECLARE SECTION;

    int    iRet;

    strcpy( szPsamNo, ptAppStru->szPsamNo );
    //�׸����ذ�����Ҫ��ϵ�������ȡ�ϴ����ز���(���ϴν��е����ؽ���)
    if( memcmp( ptAppStru->szTransCode, "00", 2 ) == 0 &&
        ptAppStru->szControlCode[1] == '1' )
    {
WriteLog( TRACE, "%s �ϵ�����", ptAppStru->szTransName );
        EXEC SQL SELECT NVL(all_transtype,0) INTO :iTransType
        FROM terminal
        WHERE psam_no = :szPsamNo;
        if( SQLCODE )
        {
            WriteLog( ERROR, "get all_transtype fail %d", SQLCODE );
            strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
            return FAIL;
        }

        //����nTransType��ȡ������Ϣ
        iRet = GetTranInfo( ptAppStru );
        if( iRet != SUCC )
        {
            strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
            WriteLog( ERROR, "get trans_def fail" );
            return FAIL;
        }    

        memset( ptAppStru->szReserved, '1', 255 );
    }
        
    return SUCC;
}

