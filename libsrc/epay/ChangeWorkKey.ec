/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨epay������ ������Կת����
** �� �� �ˣ����
** �������ڣ�2013-06-13
**
** $Revision: 1.1 $
** $Log: ChangeWorkKey.ec,v $
** Revision 1.1  2013/06/14 02:22:43  fengw
**
** 1�����ӹ�����Կת���ܺ�����
**
*******************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "app.h"
#include "user.h"
#include "dbtool.h"
#include "errcode.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ�������Կת����
** ���������
**        ptApp           app�ṹָ��
**        iHost           ������
**        ptWorkKey       ������Կ�ṹָ��
** ���������
**        ��
** �� �� ֵ��
**        SUCC            ����ɹ�
**        FAIL            ����ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2013/06/13
** ����˵����
**
** �޸���־��
****************************************************************/
int ChangeWorkKey(T_App* ptApp, int iHost, T_WorkKey *ptWorkKey)
{
    EXEC SQL BEGIN DECLARE SECTION;
        int     iHostNo;
        char    szShopNo[15+1];
        char    szPosNO[15+1];
        char    szTermKey[32+1];
        char    szPinKey[32+1];
        char    szMacKey[32+1];
        char    szMagKey[32+1];
    EXEC SQL END DECLARE SECTION;

    char    szKeyData[256+1];
    int     iIndex;

    memset(szTermKey, 0, sizeof(szTermKey));
    memset(szPinKey, 0, sizeof(szPinKey));
    memset(szMacKey, 0, sizeof(szMacKey));
    memset(szMagKey, 0, sizeof(szMagKey));

    /* ��ȡ�ն�����Կ */
    if(GetHostTermKey(ptApp, iHost, TERM_KEY, szTermKey) != SUCC)
    {
        return FAIL;
    }
    
    /* �ն�δ��ȡ���ն�����Կ����ʾ����ǩ�� */
    if(strcmp(szTermKey, " ") == 0)
    {
        strcpy(ptApp->szRetCode, ERR_NOT_HOST_KEY);

        WriteLog(ERROR, "������:[%d] �̻���:[%s] �ն˺�:[%s]�ն�����Կδ����",
                 iHostNo, ptApp->szShopNo, ptApp->szPosNo);

        return FAIL;
    }

    /* ��Կת���� */
    memset(szKeyData, 0, sizeof(szKeyData));
    iIndex = 0;

    /* �ն�����Կ */
    memcpy(szKeyData+iIndex, szTermKey, 32);
    iIndex += 32;

    /* PinKey���� */
    memcpy(szKeyData+iIndex, ptWorkKey->szPinKey, 32);
    iIndex += 32;

    /* MacKey���� */
    memcpy(szKeyData+iIndex, ptWorkKey->szMacKey, 32);
    iIndex += 32;

	if(HsmChangeWorkKey(szKeyData, szKeyData) != SUCC)
	{
		WriteLog(ERROR, "HsmChangeWorkKey error");

		strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

	   	return FAIL;
	}

	memset(szPinKey, 0, sizeof(szPinKey));
	memset(szMacKey, 0, sizeof(szMacKey));

	/* ��ȡת�����PinKey, MacKey */
	memcpy(szPinKey, szKeyData, 32);
	memcpy(szMacKey, szKeyData+32, 32);

	/***********************У�鲿��************************/
	/* PinKeyУ�� */
	memset(szKeyData, 0, sizeof(szKeyData));
	if(HsmCalcChkval(szPinKey, szKeyData, 0) != SUCC)
	{
		WriteLog(ERROR, "����PinKey��ԿУ��ֵʧ��!");

		strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

	   	return FAIL;
	}

	if(memcmp(ptWorkKey->szPIKChkVal, szKeyData, 8) != 0)
	{
		WriteLog(ERROR, "PinKey��ԿУ��ʧ��!��̨Ӧ��:[%s] ���ؼ���:[%s]", ptWorkKey->szPIKChkVal, szKeyData);

		strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

	   	return FAIL;
	}
	
	/* MacKeyУ�� */
	memset(szKeyData, 0, sizeof(szKeyData));
	if(HsmCalcChkval(szMacKey, szKeyData, 0) != SUCC)
	{
		WriteLog(ERROR, "����MacKey��ԿУ��ֵʧ��!");

		strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

	   	return FAIL;
	}

	if(memcmp(ptWorkKey->szMAKChkVal, szKeyData, 8) != 0)
	{
		WriteLog(ERROR, "MacKey��ԿУ��ʧ��!��̨Ӧ��:[%s] ���ؼ���:[%s]", ptWorkKey->szMAKChkVal, szKeyData);

		strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

	   	return FAIL;
	}

    /* ���¹�����Կ */
    if(UpdHostTermKey(ptApp, iHost, szPinKey, szMacKey, "") != SUCC)
	{
	    WriteLog(ERROR, "���¹�����Կʧ��!");

		return FAIL;
	}
	
	return SUCC;
}