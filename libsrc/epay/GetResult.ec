/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨epay������ ������Ӧ�������ȡ������Ϣ
** �� �� �ˣ����
** �������ڣ�2012-12-19
**
** $Revision: 1.4 $
** $Log: GetResult.ec,v $
** Revision 1.4  2012/12/20 09:22:33  wukj
** *** empty log message ***
**
*******************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "app.h"
#include "user.h"
#include "dbtool.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ�������Ӧ�������ȡ������Ϣ
** ���������
**        ptApp                     app�ṹָ��
** ���������
**        szRetDesc                 ������Ϣ
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/12/19
** ����˵����
**
** �޸���־��
****************************************************************/
int GetResult(char *szRetCode, char *szRetDesc)
{
	EXEC SQL BEGIN DECLARE SECTION;
        char    szReturnCode[2+1];
        char    szReturnName[12+1];
	EXEC SQL END DECLARE SECTION;

    memset(szReturnCode, 0, sizeof(szReturnCode));
	strcpy(szReturnCode, szRetCode);

    memset(szReturnName, 0, sizeof(szReturnName));

	EXEC SQL 
        SELECT return_name 
        INTO :szReturnName 
        FROM error_code 
        WHERE return_code = :szReturnCode;
	if(SQLCODE) 
	{
	    WriteLog(ERROR, "��ѯ������[%s]��Ӧ������Ϣʧ��!SQLCODE=%d SQLERR=%s",
	             szReturnCode, SQLCODE, SQLERR);

        strcpy(szRetDesc, "δ֪����");

		return FAIL;
	}

    DelTailSpace(szReturnName);
	strcpy(szRetDesc, szReturnName);

	return SUCC;
}
