/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� �̻����ն˺Ϸ��Լ��
** �� �� �ˣ����
** �������ڣ�2012-11-13
**
** $Revision: 1.2 $
** $Log: ChkValid.ec,v $
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
** ��    �ܣ��̻����ն˺Ϸ��Լ��
** ���������
**        ptApp            app�ṹָ��
** ���������
**        ��
** �� �� ֵ��
**        SUCC             �������ɹ�
**        FAIL             �������ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/13
** ����˵����
**
** �޸���־��
****************************************************************/
int ChkValid(T_App *ptApp)
{
    /* ����̻��Ϸ��� */
    if(ChkShopValid(ptApp) != SUCC)
    {
        return FAIL;
    }

    /* ����ն˺Ϸ��� */
    if(ChkPosValid(ptApp) != SUCC)
    {
        return FAIL;
    }

    /* ���绰����Ϸ��� */
    if(ChkTeleValid(ptApp) != SUCC)
    {
        return FAIL;
    }

    /* �����Ϸ��Լ�� */
    /* ƽ̨�����޶�����Ϊ10�� */
	if(memcmp(ptApp->szAmount, "100000000000", 12) > 0)
	{
        strcpy(ptApp->szRetCode, ERR_EXCEED_SINGLE);

		WriteLog(ERROR, "���׽��[%s]����", ptApp->szAmount);

		return FAIL;
	}

	/* ת������ת�뿨��ͬ */
    if(strlen(ptApp->szPan) > 0 && strcmp(ptApp->szPan, ptApp->szAccount2) == 0)
    {
        strcpy(ptApp->szRetCode, ERR_ONE_CARD);

		WriteLog(ERROR, "ת����[%s]��ת�뿨[%s]��ͬ", ptApp->szPan, ptApp->szAccount2);

		return FAIL;
    }

    return SUCC;
}
