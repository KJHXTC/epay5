/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� ��ȡϵͳ��ˮ��
** �� �� �ˣ����
** �������ڣ�2012-11-08
**
** $Revision: 1.2 $
** $Log: GetSysTrace.ec,v $
** Revision 1.2  2012/12/04 01:24:28  fengw
**
** 1���滻ErrorLogΪWriteLog��
**
** Revision 1.1  2012/11/23 09:09:16  fengw
**
** ���ڽ��״���ģ���ʼ�汾
**
** Revision 1.1  2012/11/21 07:20:46  fengw
**
** ���ڽ��״���ģ���ʼ�汾
**
*******************************************************************/

#define _EXTERN_

#include "finatran.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ���ȡϵͳ��ˮ��
** ���������
**        ptApp                 app�ṹָ��
** ���������
**        ptApp->lSysTrace      ϵͳ��ˮ��
** �� �� ֵ��
**        SUCC                  ��ȡ��ˮ�ųɹ�
**        FAIL                  ��ȡ��ˮ��ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/13
** ����˵����
**
** �޸���־��
****************************************************************/
int GetSysTrace(T_App *ptApp)
{
    EXEC SQL BEGIN DECLARE SECTION;
        int     iSysTrace;             /* ϵͳ��ˮ�� */
    EXEC SQL END DECLARE SECTION;
	
	/* ��ʼ���� */
	BeginTran();
	
	/* ��ѯϵͳ����������Ʋ��� */
	EXEC SQL
	    SELECT sys_trace INTO :iSysTrace
	    FROM system_parameter FOR UPDATE;
	if(SQLCODE)
	{
	    strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "��ѯϵͳ������ʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

		RollbackTran();

		return FAIL;
	}

    if(iSysTrace >= 999999)
    {
        iSysTrace = 1;
    }
    else
    {
        iSysTrace++;
    }

    EXEC SQL
        UPDATE system_parameter SET sys_trace = :iSysTrace;
    if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "����ϵͳ������ʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

        RollbackTran();

        return FAIL;
    }

    /* ������ˮ�ŵ�app�ṹ */
    ptApp->lSysTrace = iSysTrace;

    CommitTran();

    return SUCC;
}
