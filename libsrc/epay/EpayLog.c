/******************************************************************
 ** Copyright(C)2009��2012 �������������豸���޹�˾
 ** ��Ҫ���ݣ���־��ӡ�� 
 ** �� �� �ˣ�zhangwm
 ** �������ڣ�2012/12/03
 **
 ** ---------------------------------------------------------------
 **   $Revision: 1.5 $
 **   $Log: EpayLog.c,v $
 **   Revision 1.5  2012/11/29 07:09:22  zhangwm
 **
 **   �����ж��Ƿ��ӡ��־
 **
 **   Revision 1.4  2012/11/28 07:21:54  zhangwm
 **
 **   �޸ļ����־��ʾ�ն˺Ŷ����̻���
 **
 **   Revision 1.3  2012/11/28 03:01:57  zhangwm
 **
 **   �޸�ʱ�䴦�����Լ�������Ϊ�°汾
 **
 **   Revision 1.2  2012/11/27 06:13:41  zhangwm
 **
 **   ��дAPP��־�����Ƴ�
 **
 **   Revision 1.1  2012/11/27 03:49:52  zhangwm
 **
 **   ����epay��־��ӡ����
 **
 ** ---------------------------------------------------------------
 **
 *******************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef LINUX
#include <stdarg.h>
#else
#include <varargs.h>
#endif
#include "EpayLog.h"
#include "user.h"
#include "app.h"

/*****************************************************************
 ** ��    �ܣ���ӡ16��������
 ** ���������
 **        pszLogData Ҫ��ӡ������
 **        iLen ��ӡ���ݵĳ��� 
 **        pszTitle ��ӡ������ͷ 
 ** ���������
 **        ��
 ** �� �� ֵ��
 **        �� 
 ** ��    �ߣ�zhangwm
 ** ��    �ڣ�2012/12/03
 ** �޸���־��
 **          1��2012/12/03 ��ʼ���� 
 ****************************************************************/
void WriteHdLog(char* pszLogData, int iLen, char* pszTitle)
{
    char szTemp[100];
    char szTime[7], szLogData[DATA_LEN];
    int i, j, iPos, iStep;

    if (IsPrint(DEBUG_HLOG) == NO)
    {
        return;
    }

    iPos = 0;
    /* �ú�������ʹ�ð�C���Թ淶������ĺ��� */
    GetSysTime(szTime);

    sprintf(szTemp, "%s  %s\n", pszTitle, szTime);
    sprintf(szLogData + iPos, "%s", szTemp);
    iPos += strlen(szTemp);

    sprintf(szTemp, "%s", "===== =1==2==3==4==5==6==7==8=Hex=0==1==2==3==4==5==6 ====Asc Value====\n");
    sprintf(szLogData + iPos, "%s", szTemp);
    iPos += strlen(szTemp);

    for (i=0; i<iLen/16; i++)
    {
        iStep = 0;
        sprintf(szTemp + iStep, "%04xh:", i*16);
        iStep += 6;

        for (j=0; j<16; j++)
        {
            sprintf(szTemp + iStep, "%02x ", (unsigned char )pszLogData[i*16+j]);
            iStep += 3;
        }
        sprintf(szTemp + iStep, "%s", "|");
        iStep += 1;

        for (j=0; j<16; j++)
        {
            if (pszLogData[i*16+j] >= 0x30 && pszLogData[i*16+j] <= 0x7e)
            {
                sprintf(szTemp + iStep, "%c", (unsigned char )pszLogData[i*16+j]);
            }
            else
            {
                sprintf(szTemp + iStep, "%s", ".");
            }
            iStep += 1;
        }

        sprintf(szTemp + iStep, "%s", "\n");
        iStep += 1;

        sprintf(szLogData + iPos, "%s", szTemp);
        iPos += iStep;
    }

    /* ���ݳ��Ȳ���16�ı��������һ�в��㲹�ո� */    
    if (iLen % 16 != 0)
    {
        iStep = 0;
        sprintf(szTemp + iStep, "%04xh:", i*16);
        iStep += 6;

        for (j=0; j< iLen%16; j++)
        {
            sprintf(szTemp + iStep, "%02x ", (unsigned char )pszLogData[i*16+j]);
            iStep += 3;
        }
        for (j=0; j<(48-(iLen%16)*3); j++)
        {
            sprintf(szTemp + iStep, "%s", " ");
            iStep += 1;
        }

        sprintf(szTemp + iStep, "%s", "|");
        iStep += 1;

        for (j=0; j<iLen%16; j++)
        {
            if (pszLogData[i*16+j] >= 0x30 && pszLogData[i*16+j] <= 0x7e)
            {
                sprintf(szTemp + iStep, "%c", (unsigned char )pszLogData[i*16+j]);
            }
            else
            {
                sprintf(szTemp + iStep, "%s", ".");
            }
            iStep += 1;
        }

        sprintf(szTemp + iStep, "%s", "\n");
        iStep += 1;

        sprintf(szLogData + iPos, "%s", szTemp);
        iPos += iStep;
    }

    sprintf(szTemp, "%s", "===== =============================================== =================\n\n");
    sprintf(szLogData + iPos, "%s", szTemp);
    iPos += strlen(szTemp);

    PrintLog(szLogData, H_TYPE);

    return;
}

/*****************************************************************
 ** ��    �ܣ���ӡ���׼������
 ** ���������
 **        tpApp ���׽ṹ��
 ** ���������
 **        ��
 ** �� �� ֵ��
 **        �� 
 ** ��    �ߣ�zhangwm
 ** ��    �ڣ�2012/12/03
 ** �޸���־��
 **          1��2012/12/03 ��ʼ���� 
 ****************************************************************/
void WriteMoniLog(T_App* tpApp, char* pszTransName)
{
    char szLogData[DATA_LEN], szAmount[14], szTransName[9];
    char szResult[23], szTime[9];
    unsigned long lAmount;

    if (IsPrint(DEBUG_MLOG) == NO)
    {
        return;
    }

    memset(szResult, 0, sizeof(szResult));
    memset(szLogData, 0, sizeof(szLogData));

    if (strcmp(tpApp->szRetCode, "00") != 0)
    {
        strcpy(szResult, tpApp->szRetCode);
        if (strlen(tpApp->szRetDesc) != 0)
        {    
            strcat(szResult, tpApp->szRetDesc);
        }
        else
        {
            strcat(szResult, "����ʧ��");
        }
    }
    else
    {
        strcpy(szResult, "00");
        strcat(szResult, "���׳ɹ�");
    }

    strcat(szResult, tpApp->szHostRetCode);

    GetSysDTFmt("%T", szTime);

    if (pszTransName == NULL)
    {
        strcpy(szTransName, tpApp->szTransName);
    }
    else
    {
        strcpy(szTransName, pszTransName);
    }

    lAmount = atol(tpApp->szAmount);
    if (lAmount != 0)
    {    
        ChgAmtZeroToDot(tpApp->szAmount, 0, szAmount);
        sprintf(szLogData, "  %8.8s %-22.22s %-8.8s %13s %-16.16s %8.8s\n", tpApp->szPosNo, tpApp->szPan, szTransName, szAmount, szResult, szTime );
    }
    else if (strlen(tpApp->szAddiAmount) > 0)
    {
        ChgAmtZeroToDot(tpApp->szAddiAmount, 0, szAmount);
        sprintf(szLogData, "  %8.8s %-22.22s %-8.8s %13s %-16.16s %8.8s\n", tpApp->szPosNo, tpApp->szPan, szTransName, szAmount, szResult, szTime );
    }
    else
    {
        sprintf(szLogData, "  %8.8s %-22.22s %-8.8s %13s %-16.16s %8.8s\n", tpApp->szPosNo, tpApp->szPan, szTransName, " ", szResult, szTime );
    }

    PrintLog(szLogData, M_TYPE);

    return;
}
