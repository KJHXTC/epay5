/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ����ձ���
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision $
 * $Log: DayendBackup.ec,v $
 * Revision 1.2  2013/06/05 07:35:01  fengw
 *
 * 1���滻PrintLog����ΪWriteLog��
 * 2���޸Ĳ����ļ����������ȡ�
 *
 * Revision 1.1  2012/12/03 05:30:43  linxiang
 * *** empty log message ***
 *
 * ----------------------------------------------------------------
 */

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL EnD DECLARE SECTION;
#else
    $include sqlca;
#endif

#include "dayend.h"
 
/* ----------------------------------------------------------------
 * ��    �ܣ����ձ���
 * ���������
 *           pszDate    ��������
 * ���������
 * �� �� ֵ��-1  ʧ�ܣ�  0  �ɹ�
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int DayendBackup( char *pszDate )
{
    EXEC SQL BEGIN DECLARE SECTION;
        char     szDate[8+1];
    EXEC SQL END DECLARE SECTION;

    char szCmd[255];

    strncpy(szDate, pszDate, 8);

    /* ɾ��֮ǰ����ƥ���¼����Щ��¼��Ϊ��̨δ���صĽ��׵Ľ��̼�¼ */
    EXEC SQL DELETE FROM pid_match WHERE local_date <= :szDate;
    CommitTran();

    WriteLog(TRACE, "���ݿⱸ�ݿ�ʼ..." );
    memset( szCmd, 0, sizeof( szCmd ) );
    sprintf( szCmd, "backup_db %s 1>/dev/null 2>/dev/null", szDate );
    system( szCmd );
    WriteLog(TRACE, "���ݿⱸ�����..." );

    WriteLog(TRACE, "������־���ݿ�ʼ..." );
    memset( szCmd, 0, sizeof( szCmd ) );
    sprintf( szCmd, "backlog %s 1>/dev/null 2>/dev/null", szDate );
    system( szCmd );
    WriteLog(TRACE, "������־�������..." );

    return SUCC;
}
