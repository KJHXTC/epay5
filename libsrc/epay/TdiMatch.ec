/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨epay������ ������������ƥ�亯��
** �� �� �ˣ����
** �������ڣ�2012-11-27
**
** $Revision: 1.5 $
** $Log: TdiMatch.ec,v $
** Revision 1.5  2012/12/20 09:25:54  wukj
** Revision�����Ԫ��
**
*******************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "user.h"
#include "dbtool.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
    int     iTransDataIndex;
    char    szHostShopNo[15+1];
    char    szHostPosNo[15+1];
    long    lSendTime;
    long    lHostSysTrace;
    int     iTransTypeNum;
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ����ý�����������ƥ��
** ���������
**        iTdi                      ������������
**        szShopNo                  �̻���
**        szPosNo                   �ն˺�
**        lSysTrace                 ƽ̨��ˮ��
** ���������
**        ��
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/12/03
** ����˵����
**
** �޸���־��
****************************************************************/
int SetTdiMatch(int iTdi, char *szShopNo, char* szPosNo, long lSysTrace,int iTransType)
{
    memset(szHostShopNo, 0, sizeof(szHostShopNo));
    memset(szHostPosNo, 0, sizeof(szHostPosNo));

    iTransDataIndex = iTdi;
    strcpy(szHostShopNo, szShopNo);
    strcpy(szHostPosNo, szPosNo);
    time(&lSendTime);
    lHostSysTrace = lSysTrace;
    iTransTypeNum = iTransType;

    BeginTran();

    EXEC SQL 
        SELECT  shop_no  into :szHostShopNo
        FROM  tdi_match
        WHERE shop_no = :szHostShopNo AND pos_no = :szHostPosNo AND sys_trace = :lHostSysTrace  and trans_type= :iTransTypeNum;
    if(SQLCODE == 0 )
    {
        EXEC SQL 
            DELETE FROM  tdi_match 
            WHERE shop_no = :szHostShopNo AND pos_no = :szHostPosNo AND sys_trace = :lHostSysTrace  and trans_type= :iTransTypeNum;
            
    }

    EXEC SQL
        INSERT INTO tdi_match (trans_data_index, local_date, shop_no, pos_no, send_time, sys_trace,trans_type)
        VALUES (:iTransDataIndex, TO_CHAR(SYSDATE, 'YYYYMMDD'), :szHostShopNo, :szHostPosNo,:lSendTime, :lHostSysTrace,:iTransTypeNum);
    if(SQLCODE)
    {
        RollbackTran();

        WriteLog(ERROR, "���뽻���������� tdi:[%d] shop_no:[%s] pos_no:[%s] sys_trace:[%ld] trans_type: [%d] ƥ���¼ʧ��!SQLCODE=%d SQLERR=%s",
                 iTransDataIndex, szHostShopNo, szHostPosNo, lHostSysTrace,iTransTypeNum, SQLCODE, SQLERR);

        return FAIL;
    }

    CommitTran();

    return SUCC;
}

/****************************************************************
** ��    �ܣ���ȡ������������ƥ��
** ���������
**        szShopNo                  �̻���
**        szPosNo                   �ն˺�
**        lSysTrace                 ƽ̨��ˮ��
**        iTimeOut                  ƥ�䳬ʱʱ��
** ���������
**        ��
** �� �� ֵ��
**        >=0                       ����ƥ��Ľ�����������
**        FAIL                      ƥ��ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/12/03
** ����˵����
**
** �޸���־��
****************************************************************/
int GetTdiMatch(char *szShopNo, char* szPosNo, long lSysTrace, int iTimeOut,int iTransType)
{
    long    lRecvTime;

    memset(szHostShopNo, 0, sizeof(szHostShopNo));
    memset(szHostPosNo, 0, sizeof(szHostPosNo));

    strcpy(szHostShopNo, szShopNo);
    strcpy(szHostPosNo, szPosNo);
    lHostSysTrace = lSysTrace;
    iTransTypeNum = iTransType;
    

    time(&lRecvTime);

    EXEC SQL
        SELECT trans_data_index, send_time
        INTO :iTransDataIndex, :lSendTime
        FROM tdi_match
        WHERE shop_no = :szHostShopNo AND pos_no = :szHostPosNo AND sys_trace = :lHostSysTrace AND trans_type = :iTransTypeNum;
    if(SQLCODE)
    {
        WriteLog(ERROR, "��ѯ������������ shop_no:[%s] pos_no:[%s] sys_trace:[%ld] trans_type:[%d] ƥ���¼ʧ��!SQLCODE=%d SQLERR=%s",
                 szHostShopNo, szHostPosNo, lHostSysTrace,iTransTypeNum, SQLCODE, SQLERR);

        return FAIL;
    }
    
    /* ��鷢��ʱ�������ʱ���Ƿ񳬹���ʱʱ�� */
    if(lRecvTime - lSendTime > iTimeOut)
    {
        WriteLog(ERROR, "������������ shop_no:[%s] pos_no:[%s] sys_trace:[%ld] ƥ���¼��ʱ!SendTime:[%ld] RecvTime:[%ld] TimeOut:[%d]",
                 szHostShopNo, szHostPosNo, lHostSysTrace, lSendTime, lRecvTime, iTimeOut);

        return FAIL;
    }

    return iTransDataIndex;
}
