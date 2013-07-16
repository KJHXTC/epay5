/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�������ˮ����
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision $
 * $Log: ClearTrace.ec,v $
 * Revision 1.4  2013/06/08 02:04:39  fengw
 *
 * 1���������ڼ��㺯����ͳһ��ˮ����������Ρ�
 *
 * Revision 1.3  2013/06/05 07:35:01  fengw
 *
 * 1���滻PrintLog����ΪWriteLog��
 * 2���޸Ĳ����ļ����������ȡ�
 *
 * Revision 1.2  2013/06/05 02:15:38  fengw
 *
 * 1������ϵͳ״̬��ر�����������롣
 *
 * Revision 1.1  2012/12/03 05:30:43  linxiang
 * *** empty log message ***
 *
 * ----------------------------------------------------------------
 */
#ifdef DB_ORACLE
     EXEC SQL BEGIN DECLARE SECTION;
        EXEC SQL INCLUDE SQLCA;
        char    szSettleDate[8+1]; 
        char    szMoniTime[14+1];
     EXEC SQL EnD DECLARE SECTION;
#else
         $include sqlca;
#endif

#include "dayend.h"
      
/* ----------------------------------------------------------------
 * ��      �ܣ����յ�ǰ��ˮ����
 * ���������
 *          szDate      ��ˮ��������
 * ���������
 * �� �� ֵ��-1  ʧ�ܣ�  0  �ɹ�
 * ��      �ߣ�
 * ��      �ڣ�
 * ����˵����
 * �޸���־���޸�����      �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int Posls2History(char* szDate) 
{
    memset(szSettleDate, 0, sizeof(szSettleDate));
    memcpy(szSettleDate, szDate, 8);

    WriteLog(TRACE, "����ǰ��ˮ����(%s)��ǰ��ˮ�Ƶ���ʷ��", szSettleDate);

    EXEC SQL INSERT INTO history_ls VALUE
        (SELECT * FROM posls WHERE settle_date <= :szSettleDate);
    if(SQLCODE && SQLCODE != SQL_NO_RECORD)
    {
        WriteLog(ERROR, "insert into history_ls fail %ld %s", SQLCODE, SQLERR );

        return FAIL;
    }

    EXEC SQL DELETE FROM posls WHERE settle_date <= :szSettleDate;
    if(SQLCODE && SQLCODE != SQL_NO_RECORD)
    {
        WriteLog(ERROR, "delete posls fail %ld %s", SQLCODE, SQLERR );

        return FAIL;
    }

    WriteLog(TRACE, "��ǰ��ˮ���Ƶ���ʷ��ɹ�");

    return SUCC;
}

/* ----------------------------------------------------------------
 * ��      �ܣ�������ʷ��ˮ����
 * ���������
 *          szDate          ��ʷ��ˮ��������
 * ���������
 * �� �� ֵ��-1  ʧ�ܣ�  0  �ɹ�
 * ��      �ߣ�
 * ��      �ڣ�
 * ����˵����
 * �޸���־���޸�����      �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int ClearHistory(char* szDate) 
{
    memset(szSettleDate, 0, sizeof(szSettleDate));
    memcpy(szSettleDate, szDate, 8);

    WriteLog(TRACE, "�����ʷ��ˮ����(%s)��ǰ����ˮ", szSettleDate);

    EXEC SQL DELETE FROM history_ls WHERE settle_date <= :szSettleDate;
    if(SQLCODE && SQLCODE != SQL_NO_RECORD)
    {
        WriteLog(ERROR, "delete history_ls fail %ld %s", SQLCODE, SQLERR );

        return FAIL;
    }

    WriteLog(TRACE, "��ʷ��ˮ����������ɹ�" );

    return SUCC;
}

/* ----------------------------------------------------------------
 * ��      �ܣ�ϵͳ״̬��ؼ�¼���
 * ���������
 *          szDate      ��ؼ�¼��������
 * ���������
 * �� �� ֵ��-1  ʧ�ܣ�  0  �ɹ�
 * ��      �ߣ�
 * ��      �ڣ�
 * ����˵����
 * �޸���־���޸�����      �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int ClearEpayMoni(char* szDate) 
{
    memset(szMoniTime, 0, sizeof(szMoniTime));
    memcpy(szMoniTime, szDate, 8);
    memcpy(szMoniTime+8, "000000", 6);

    WriteLog(TRACE, "���ϵͳ״̬��ر�(%s)��ǰ�ļ�¼", szMoniTime);

    EXEC SQL
        DELETE FROM epay_moni
        WHERE moni_time < :szMoniTime;
    if(SQLCODE && SQLCODE != SQL_NO_RECORD)
    {
        WriteLog(ERROR, "���ϵͳ״̬��ر��¼ʧ��!SQLCODE=%d SQLERR=%s",
                 SQLCODE, SQLERR);

        return FAIL;
    }

    WriteLog(TRACE, "ϵͳ״̬��ر���������ɹ�");

    return SUCC;
}
