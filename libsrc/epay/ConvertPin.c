/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨epay������ PinBlockת����
** �� �� �ˣ����
** �������ڣ�2013-06-13
**
** $Revision: 1.1 $
** $Log: ConvertPin.c,v $
** Revision 1.1  2013/06/14 02:23:06  fengw
**
** 1������PinBlockת���ܺ�����
**
*******************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "app.h"
#include "user.h"
#include "errcode.h"

#define TRIPLE_DES      9
#define SINGLE_DES      8

/****************************************************************
** ��    �ܣ�PinBlockת����
** ���������
**        ptApp           app�ṹָ��
**        iHost           ������
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
int ConvertPin(T_App* ptApp, int iHost)
{
    char    szPinKey[32+1];
    char    szPIK[16+1];
	char    szSourcePan[20];
	char    szTargetPan[20];

    /* ��ȡPinKey */
    memset(szPinKey, 0, sizeof(szPinKey));
    if(GetHostTermKey(ptApp, iHost, PIN_KEY, szPinKey) != SUCC)
    {
        return FAIL;
    }

	memset(szPIK, 0, sizeof(szPIK));
	AscToBcd(szPinKey, 32, 0, szPIK);

    memset(szSourcePan, 0, sizeof(szSourcePan));
    memset(szTargetPan, 0, sizeof(szTargetPan));

	if(strlen(ptApp->szPan) < 16)
	{
		/*�Ҷ�������*/
		memset(szSourcePan, '0', 16);
		memcpy(szSourcePan+16-strlen(ptApp->szPan), ptApp->szPan, strlen(ptApp->szPan));
	}
	else
	{
		/*��16λ*/
		memset(szSourcePan, '0', 16);
		memcpy(szSourcePan, ptApp->szPan+strlen(ptApp->szPan)-16, 16);
	}
	strcpy(szTargetPan, szSourcePan);

	if(HsmChangePin(ptApp, 1, TRIPLE_DES, ptApp->szPinKey, szPIK, szSourcePan, szTargetPan) != SUCC)
	{
		WriteLog(ERROR, "PinBlockת����ʧ��!");

		strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

		return FAIL;
	}

	return SUCC;
}
