/*******************************************************************************
 * Copyright(C)2012��2015 �������������豸���޹�˾
 * ��Ҫ���ݣ�ScriptPosģ�� ���ݱ���ͷ��ȡ���׶�Ӧapp�ṹָ��
 * �� �� �ˣ�Robin
 * �������ڣ�2012/11/30
 * $Revision: 1.2 $
 * $Log: GetTdiAddress.c,v $
 * Revision 1.2  2013/06/14 06:32:54  fengw
 *
 * 1���ļ���ʽת����
 *
 * Revision 1.1  2013/01/18 08:32:37  fengw
 *
 * 1����ֺ�����
 *
 ******************************************************************************/

#define _EXTERN_

#include "ScriptPos.h"

/****************************************************************
** ��    �ܣ����ݱ���ͷ��ȡ���׶�Ӧapp�ṹָ��
** ���������
**        szInData                  ����
**        iLen                      ���ĳ���
** ���������
**        ��
** �� �� ֵ��
**        ptApp                     app�ṹָ��
**        NULL                      ʧ��
** ��    �ߣ�
**        Robin
** ��    �ڣ�
**        2008/07/31
** ����˵����
**
** �޸���־��
****************************************************************/
T_App* GetTdiAddress(char *szInData, int iLen)
{
    T_App   *ptApp;                     /* app�ṹָ�� */
    int     iStepIndex;                 /* ����ͬ��������� */
    int     iSteps;                     /* ����ͬ����� */
    int     iCallType;                  /* �������� */
    long    lTdi;                       /* �������������� */

    /* �ж��Ƿ����͵绰���� */
    if(memcmp(szInData+5, "\x4C\x52\x49\x00\x1C", 5) == 0)
    {
        iStepIndex = 38;
    }
    else
    {
        iStepIndex = 5;
    }

    /* ��ȡ����ͬ����� */
    iSteps = (uchar)szInData[iStepIndex];
#ifdef DEBUG
    WriteLog(TRACE, "����ͬ�����:[%d]", iSteps);
#endif

    /* ��ȡ�������� */
    iCallType = (uchar)szInData[iStepIndex+3];
#ifdef DEBUG
    WriteLog(TRACE, "���ĺ�������:[%d]", iCallType);
#endif
    if(iCallType != POS_CALLING && iCallType != EPAY_CALLING)
    {
        WriteLog(ERROR, "���ĺ�������[%d]�Ƿ�!�ն�����:[%d] ƽ̨����:[%d]",
                 iCallType, POS_CALLING, EPAY_CALLING);

        return NULL;
    }

    /* �ն˷����׸����װ�����Ҫ���ķ��佻������������ */
    if(iSteps == 1)
    {
        lTdi = GetTransDataIndex(giTimeoutTdi);
        if(lTdi < 0)
        {
            WriteLog(ERROR, "���佻������������ʧ��!");

            return NULL;
        }
    }
    else
    {
        lTdi = (uchar)szInData[iStepIndex+1]*256 + (uchar)szInData[iStepIndex+2];

        /* �������������ŷǷ����ж�Ϊ���Ƿ� */
        if(lTdi >= MAX_TRANS_DATA_INDEX)
        {
            WriteLog(ERROR, "��������������[%d]�Ƿ�!��ɷ�Χ[0-%ld]", lTdi, MAX_TRANS_DATA_INDEX-1);

            return NULL;
        }

        /* ����TDIռ��ʱ�� */
        SetTdiTime(lTdi);
    }
#ifdef DEBUG
    WriteLog(TRACE, "��������������:[%ld]", lTdi);
#endif

    /* ���ݽ�������������ȡ�ṹָ�� */
    ptApp = GetAppAddress(lTdi); 
    if(ptApp == NULL)
    {
        WriteLog(ERROR, "��ȡ������������[%ld]��Ӧ�ṹָ��ʧ��!", lTdi);

        return NULL;
    }

    /* �ն˷����׵�1�������ķ����׵ĵ�2������ʼ���������ݽṹ */
    if(iSteps == 1 || ((iCallType == EPAY_CALLING)&&(iSteps == 2)))
    {
        memset(ptApp, 0, APPSIZE);
    }
    /* ������������ϻغϽ���ָ������ */
    else
    {
        memset(ptApp->szCommand, 0, sizeof(ptApp->szCommand));    
        ptApp->iCommandNum = 0;
        ptApp->iCommandLen = 0;
        
        memset(ptApp->szControlPara, 0, sizeof(ptApp->szControlPara));    
        ptApp->iControlLen = 0;
    }

    /* ��ʼ��ֵ */
    /* ����ͬ����� */
    ptApp->iSteps = iSteps;

    /* �������� */
    ptApp->iCallType = iCallType;

    /* ������������ */
    ptApp->lTransDataIdx = lTdi;

    /* �������ڡ�ʱ�� */
    GetSysDate(ptApp->szPosDate);
    GetSysTime(ptApp->szPosTime);

    /* Ĭ����Ӧ��NN */
    strcpy(ptApp->szRetCode, "NN");
    strcpy(ptApp->szHostRetCode, "NN");
    memset(ptApp->szRetDesc, 0, sizeof(ptApp->szRetDesc));

    /* �յ��к� */
    strcpy(ptApp->szAcqBankId, gszAcqBankId);

    return ptApp;
}
