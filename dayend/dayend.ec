/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ����մ���
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision $
 * $Log: dayend.ec,v $
 * Revision 1.6  2013/06/17 00:56:20  fengw
 *
 * 1���������ݿ������ύ���롣
 *
 * Revision 1.5  2013/06/08 02:04:39  fengw
 *
 * 1���������ڼ��㺯����ͳһ��ˮ����������Ρ�
 *
 * Revision 1.4  2013/06/05 07:35:01  fengw
 *
 * 1���滻PrintLog����ΪWriteLog��
 * 2���޸Ĳ����ļ����������ȡ�
 *
 * Revision 1.3  2013/06/05 02:15:38  fengw
 *
 * 1������ϵͳ״̬��ر�����������롣
 *
 * Revision 1.2  2013/04/07 05:52:15  linqil
 * �޸�DECODE����ΪCASE...WHEN...END��䣻�޸�trim; ʹ���ܹ�����DB2���ݿ⡣
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
 * ��    �ܣ����մ���
 * uGsage: 0.dayend YYYYMMDD
 *        1.dayend `date +%Y%m%d`
 *        2.dayend `date -d"1 days ago" +%Y%m%d`
 * ----------------------------------------------------------------
 */
int main(int argc, char *argv[])
{
    int     iDays;
    char    szToday[8+1];
    char    szDate[8+1];

    if(OpenDB())
    {
        WriteLog(ERROR, "open db fail");

        return FAIL;
    }

    memset(szDate, 0, sizeof(szDate));
    memset(szToday, 0, sizeof(szToday));

    GetSysDate(szToday);

    if(argc < 2)
    {
        if(CalcDateByDays(szToday, 1, szDate) != SUCC)
        {
            return FAIL;
        }
    }
    else
    {
        strncpy(szDate, argv[1], 8);
    }

    DayendBackup(szDate);

    if(GetStatLine(szDate, szDate) == FAIL)
    {
        RollbackTran();
        CloseDB();
        return FAIL;
    }

    /* ����ǰ��ˮ�� */
    GetIntParam("POSLS_DAYS", iDays);

    if(CalcDateByDays(szToday, iDays, szDate) != SUCC)
    {
        RollbackTran();
        CloseDB();
        return FAIL;
    }

    if(Posls2History(szDate) != SUCC)
    {
        RollbackTran();
        CloseDB();
        return FAIL;
    }

    /* ������ʷ��ˮ�� */
    GetIntParam("HISLS_DAYS", iDays);

    if(CalcDateByDays(szToday, iDays, szDate) != SUCC)
    {
        RollbackTran();
        CloseDB();
        return FAIL;
    }

    if(ClearHistory(szDate) != SUCC)
    {
        RollbackTran();
        CloseDB();
        return FAIL;
    }

    CommitTran();

    /* ���ϵͳ״̬������� */
    GetIntParam("MONI_DAYS", iDays);

    if(CalcDateByDays(szToday, iDays, szDate) != SUCC)
    {
        CloseDB();
        return FAIL;
    }

    ClearEpayMoni(szDate);

    CommitTran();

    CloseDB();

    return SUCC;
}

int CalcDateByDays(char* szDate, int iDays, char* szCalcDate)
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szDate1[8+1];
        char    szDate2[8+1];
        int     iHostDays;
    EXEC SQL END DECLARE SECTION;    

    memset(szDate1, 0, sizeof(szDate1));
    memset(szDate2, 0, sizeof(szDate2));

    memcpy(szDate1, szDate, 8);
    iHostDays = iDays;

    EXEC SQL
        SELECT TO_CHAR(TO_DATE(:szDate1, 'yyyymmdd') - :iHostDays, 'yyyymmdd')
        INTO :szDate2
        FROM dual;
    if(SQLCODE)
    {
        WriteLog(ERROR, "��������ʧ��!SQLCODE=%d SQLERR=%s",
            SQLCODE, SQLERR);

        return FAIL;
    }

    memcpy(szCalcDate, szDate2, 8);

    return SUCC;
}
