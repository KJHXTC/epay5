/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨epay������ ���ݽ������ȡ��������
** �� �� �ˣ����
** �������ڣ�2012-12-20
**
** $Revision: 1.6 $
** $Log: GetTranType.ec,v $
** Revision 1.6  2012/12/25 07:04:52  fengw
**
** 1������szTransCode�����Ϊ�ַ��������������дBUG��
**
** Revision 1.5  2012/12/20 09:25:54  wukj
** Revision�����Ԫ��
**
** Revision 1.4  2012/12/20 09:20:59  wukj
** *** empty log message ***
**
*******************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "app.h"
#include "user.h"
#include "dbtool.h"
#include "errcode.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ����ݽ������ȡ��������
** ���������
**        szTransCode               ������
** ���������
**        piTransType               ��������
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/12/20
** ����˵����
**
** �޸���־��
****************************************************************/
int GetTranType(char *szTransCode, int *piTransType)
{
	EXEC SQL BEGIN DECLARE SECTION;
        char    szHostTransCode[8+1];           /* ������ */
		int     iTransType;                     /* �������� */
	EXEC SQL END DECLARE SECTION;

    memset(szHostTransCode, 0, sizeof(szHostTransCode));
    memcpy(szHostTransCode, "__", 2);
    memcpy(szHostTransCode+2, szTransCode+2, 6);

	EXEC SQL
	    SELECT trans_type INTO :iTransType
        FROM trans_def 
        WHERE trans_code LIKE :szHostTransCode;
    if(SQLCODE == SQL_NO_RECORD)
	{
        WriteLog(ERROR, "������[%s]δ����!SQLCODE=%d SQLERR=%s", szHostTransCode, SQLCODE, SQLERR);

		return FAIL;
	}
	else if(SQLCODE)
	{
		WriteLog(ERROR, "��ѯ ������[%s] ���׶���ʧ��!SQLCODE=%d SQLERR=%s", szHostTransCode, SQLCODE, SQLERR);

		return FAIL;
	}

	*piTransType = iTransType;

	return SUCC;
}
