
/*******************************************************************************
 * Copyright(C)2012��2015 �������������豸���޹�˾
 * ��Ҫ���ݣ�ScriptPosģ�� POSӦ�������
 * �� �� �ˣ�Robin
 * �������ڣ�2012/11/30
 * $Revision: 1.1 $
 * $Log: PackScriptPos.c,v $
 * Revision 1.1  2013/01/18 08:32:37  fengw
 *
 * 1����ֺ�����
 *
 ******************************************************************************/

#define _EXTERN_

#include "ScriptPos.h"

/*******************************************************************************
 * �������ܣ����������ݽṹ���ݰ�����֧���淶����(�ű�POS����)���
 * ���������
 *           ptApp          -  �������ݽṹָ��
 *           szFirstPage    -  ��ҳ��Ϣ
 *           iFirstPageLen  -  ��ҳ��Ϣ����
 * ���������
 *           szOutData      -  ��õı���
 * �� �� ֵ�� 
 *           FAIL           -  ���ʧ��
 *           >0             -  ��õı��ĳ���
 * ��    �ߣ�Robin
 * ��    �ڣ�2012/12/14
 * �޶���־��
 *
 ******************************************************************************/
int PackScriptPos(T_App *ptApp, char* szFirstPage, int iFirstPageLen, char *szOutData)
{
    int     iIndex;                             /* ������������ */
    int     iMsgIndex;                          /* ��Ϣ�������ݿ�ʼ���� */
    char    szValidData[2048+1];                /* ��Ч���� */
    int     iValidDataLen;                      /* ��Ч���ݳ��� */
    int     iCalcMac;                           /* ����MAC��־ */
    char    szMac[8+1];                         /* MAC */
    char    szTmpBuf[512+1];                    /* ��ʱ���� */

    /* ��ʼ�� */
    iIndex = 0;

    /* ������� */
    /* TPDU */
    szOutData[iIndex] = 0x60;
    iIndex += 1;

    /* Դ��ַ */
    memcpy(szOutData+iIndex, ptApp->szSourceTpdu, 2);
    iIndex += 2;
   
    /* Ŀ�ĵ�ַ */
    memcpy(szOutData+iIndex, ptApp->szTargetTpdu, 2);
    iIndex += 2;   

    /* ����ͬ����� */
    szOutData[iIndex] = ptApp->iSteps;
    iIndex += 1;

    /* �������������� */    
    szOutData[iIndex] = (ptApp->lTransDataIdx) / 256;  
    szOutData[iIndex+1] = (ptApp->lTransDataIdx) % 256;
    iIndex += 2;

    /* �������� */
    szOutData[iIndex] = ptApp->iCallType;
    iIndex += 1;
    
    /* �������ر�� */
    szOutData[iIndex] = ptApp->iFskId;
    iIndex += 1;

    /* ģ��� */
    szOutData[iIndex] = ptApp->iModuleId;
    iIndex += 1;

    /* ͨ���� */
    szOutData[iIndex] = ptApp->iChannelId;
    iIndex += 1;

    /******************************��Ϣ�����������******************************/
    /* ��Ϣ���ݳ��� */
    iIndex += 2;

    /* ��¼��Ϣ���ݿ�ʼ���������ڼ���MAC */
    iMsgIndex = iIndex;

    /* �������� */
    if(ptApp->iTransType == RESEND)
    {
        szOutData[iIndex] = 0x03;    
    }
    else
    {
        szOutData[iIndex] = 0x02;
    }
    iIndex += 1;

    /* ������־ */
    szOutData[iIndex] = 0x00;
    iIndex += 1;

    /* �绰���� */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    sprintf(szTmpBuf, "%15.15s", ptApp->szCallingTel);
    memcpy(szOutData+iIndex, szTmpBuf, 15);    
    iIndex += 15;

    /* ��ȫģ��� */
    memcpy(szOutData+iIndex, ptApp->szPsamNo, 16);    
    iIndex += 16;

    /* ϵͳ���� */
    AscToBcd((uchar*)(ptApp->szPosDate), 8, LEFT_ALIGN, szOutData+iIndex);
    iIndex += 4;

    /* ϵͳʱ�� */
    AscToBcd( (uchar*)(ptApp->szPosTime), 6, LEFT_ALIGN, szOutData+iIndex);
    iIndex += 3;

    /* ��ˮ�� */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    sprintf(szTmpBuf, "%06ld", ptApp->lPosTrace);
    AscToBcd((uchar*)szTmpBuf, 6, LEFT_ALIGN, szOutData+iIndex);
    iIndex += 3;

    /* POSָ��������� */
    if(PosInput(ptApp, szFirstPage, iFirstPageLen,
                szValidData, &iValidDataLen, &iCalcMac) != SUCC)
    {
        WriteLog(ERROR, "POSָ�������������ʧ��!");

        return FAIL;
    }

    /* ���״��� */
    if(strlen(ptApp->szNextTransCode) == 8)
    {
        AscToBcd((uchar*)(ptApp->szNextTransCode), 8, LEFT_ALIGN, szOutData+iIndex);
    }
    else
    {
        AscToBcd((uchar*)(ptApp->szTransCode), 8, LEFT_ALIGN, szOutData+iIndex);
        FreeTdi(ptApp->lTransDataIdx);
    }
    iIndex += 4;

    /* ��������� */
    szOutData[iIndex] = ptApp->iCommandNum;
    iIndex += 1;

    /* �����뼯 */
    memcpy(szOutData+iIndex, ptApp->szCommand, ptApp->iCommandLen);
    iIndex += ptApp->iCommandLen;

    /* ���Ʋ������� */
    szOutData[iIndex] = ptApp->iControlLen / 256;
    szOutData[iIndex+1] = ptApp->iControlLen % 256;
    iIndex += 2;

    /* ���Ʋ��� */
    memcpy(szOutData+iIndex, ptApp->szControlPara, ptApp->iControlLen);
    iIndex += ptApp->iControlLen;

    /* ��Ч���ݳ��ȣ�����8���ֽ�MACS */
    szOutData[iIndex] = (iValidDataLen + 8) / 256;
    szOutData[iIndex+1] = (iValidDataLen + 8) % 256;
    iIndex += 2;

    /* ��Ч���� */
    memcpy(szOutData+iIndex, szValidData, iValidDataLen);
    iIndex += iValidDataLen;

     /* �ְ����ͣ����޸� */
    /* ����ֳɶ��ٸ����´���POS */
    /*
    if( iMsgLen%giEachPackMaxBytes == 0 )
    {
        iPackNum = iMsgLen/giEachPackMaxBytes;
    }
    else
    {
        iPackNum = iMsgLen/giEachPackMaxBytes+1;
    }

    if( iPackNum == 1 )
    {
        szMsg[1] = 0;
    }
    else
    {
        szMsg[1] = iPackNum;
    }
    */

    /* ����MAC */
    memset(szMac, 0, sizeof(szMac));

    if(iCalcMac == 1 && giMacChk == 1)
    {
        if(HsmCalcMac(ptApp, XOR_CALC_MAC, ptApp->szMacKey, 
                      szOutData+iMsgIndex, iIndex-iMsgIndex, szMac) != SUCC)
        {
            WriteLog(ERROR, "����MACʧ��!");

            memset(szMac, 'A', 8);
        }
    }
    else
    {
        memset(szMac, 0x00, 8);
    }

    memcpy(szOutData+iIndex, szMac, 8);
    iIndex += 8;

    /* ��Ϣ���ݳ��� */
    szOutData[iMsgIndex-2] = (iIndex-iMsgIndex+8) / 256;
    szOutData[iMsgIndex-2+1] = (iIndex-iMsgIndex+8) % 256;

    return iIndex;    
}