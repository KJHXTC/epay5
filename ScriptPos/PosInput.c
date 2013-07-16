/*******************************************************************************
 * Copyright(C)2012��2015 �������������豸���޹�˾
 * ��Ҫ���ݣ�ScriptPosģ�� POSӦ�������
 * �� �� �ˣ�Robin
 * �������ڣ�2012/11/30
 * $Revision: 1.2 $
 * $Log: PosInput.c,v $
 * Revision 1.2  2013/03/11 07:14:18  fengw
 *
 * 1�������Զ���ָ�����롣
 *
 * Revision 1.1  2013/01/18 08:32:37  fengw
 *
 * 1����ֺ�����
 *
 ******************************************************************************/

#define _EXTERN_

#include "ScriptPos.h"

/****************************************************************
** ��    �ܣ�POSָ�������������
** ���������
**        ptApp                     app�ṹָ��
**        szFirstPage               ��ҳ��Ϣ
**        iFirstPageLen             ��ҳ��Ϣ����
** ���������
**        szData                    ��Ч����
**        piDataLen                 ��Ч���ݳ���
**        piCalcMac                 �Ƿ�У��MAC
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        Robin
** ��    �ڣ�
**        2008/07/31
** ����˵����
**
** �޸���־��
****************************************************************/
int PosInput(T_App *ptApp, char* szFirstPage, int iFirstPageLen,
             char *szData, int *piDataLen, int *piCalcMac)
{

    int         i;
    uchar       ucOrgCmd;                       /* ԭʼָ�� */
    int         iCmdIndex;                      /* ָ������ */
    int         iCmdBytes;                      /* ָ��� */
    int         iValidDataLen;                  /* ��Ч���ݳ��� */
    char        szValidData[1024+1];            /* ��Ч���� */
    int         iCtrlIndex;                     /* ���Ʋ������� */
    int         iDataSourceIndex;               /* ������Դ���� */
    int         iPrintCount;                    /* ��ӡ���� */
    int         iMenuRecNo;                     /* ��̬�˵�ID */
    int         iValueLen;                      /* ���ݳ��� */
    char        szValue[1024+1];                /* ����(��ҳ��Ϣ����ӡ����) */
    char        szTmpBuf[512+1];                /* ��ʱ���� */
    int         iTmp;                           /* ��ʱ���� */

    /* ��¼POSָ�������־ */
    WriteCmdData(ptApp->szTransName, ptApp->lPosTrace, "SNDBEGIN", ptApp->iTransType);

    /* ��ʼ�� */
    iValidDataLen = 0;
    memset(szValidData, 0, sizeof(szValidData));

    iCmdIndex = 0;
    iCtrlIndex = 0;
    iDataSourceIndex = 0;
    iPrintCount = 0;

    for(i=0;i<ptApp->iCommandNum;i++)
    {
        /* �ж��Ƿ�������ָ�� */
        /*
        �����������Ϊ3���ֽڡ�
        ��һ���ֽڹ̶�ΪC0��
        �ڶ����ֽڱ�ʾ����ָ�������Ӧ�Ĳ�����ʾ��Ϣ�����ţ�HEX������Ϊ0��ʾ�޲�����ʾ��Ϣ��Ϊ255��ʾʹ����ʱ������ʾ��Ϣ����ʱ������ʾ��Ϣ�����ķ��أ�������������XX��ʾ��
        �������ֽڱ�ʾ�����ָ�����͡�
        */
        if((ptApp->szCommand[iCmdIndex] & 0xFF) == SPECIAL_CMD_HEAD)
        {
            if((iTmp = SpecialInput(ptApp, ptApp->szCommand+iCmdIndex, szValidData+iValidDataLen)) == FAIL)
            {
                WriteLog(ERROR, "��֯�Զ���ָ����������ʧ��!");

                return FAIL;
            }

            if(iTmp == 0)
            {
                WriteCmdData(ptApp->szCommand+iCmdIndex, i, "FF", 2);
            }
            else
            {
                WriteCmdData(ptApp->szCommand+iCmdIndex, i, szValidData+iValidDataLen, iTmp);
            }

            iValidDataLen += iTmp;
            iCmdIndex += SPECIAL_CMD_LEN;
        }
        else
        {
            iCmdBytes = CalcCmdBytes((uchar)ptApp->szCommand[iCmdIndex]);

            ucOrgCmd = ptApp->szCommand[iCmdIndex] & 0x3F;

            switch(ucOrgCmd)
            {
                /* ��ȡ��ȫģ��� */
                case 0x02:
                /* �ŵ��������� */
                case 0x03:
                /* �ŵ��������� */
                case 0x04:
                /* �������� */
                case 0x05:
                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, "FF", 2);

                    break;
                /* �������� */
                case 0x06:
                    /* �޸Ļ������� */
                    if(ptApp->iTransNum > 0)
                    {
                        /* ���Ʋ�������(1Byte) + ģʽ��ʶ(1Byte) */
                        iCtrlIndex += 2;

                        /* ������ֵ */
                        memset(szTmpBuf, 0, sizeof(szTmpBuf));
                        sprintf(szTmpBuf, "%06ld", ptApp->iTransNum);
                        AscToBcd(szTmpBuf, 6, LEFT_ALIGN, ptApp->szControlPara+iCtrlIndex);
                        iCtrlIndex += 3;

                        /* ��С��ֵ(3Bytes) + �����ֵ(3Bytes) */
                        iCtrlIndex += 6;
                    }

                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, "FF", 2);

                    break;
                /* ���׽�� */
                case 0x07:
                    /* ��̨�з��ؽ��(һ��ΪӦ�ɷѽ��)��Ҫ��������ʱ����Ϊ���Խ�� */
                    if(strlen(ptApp->szAmount) == 12)
                    {
                        /* ���Ʋ�������(1Byte) + ģʽ��ʶ(1Byte) + С����λ��(1Byte) */
                        iCtrlIndex += 3;

                        /* ���Խ��(6Bytes) */
                        AscToBcd(ptApp->szAmount, 12, LEFT_ALIGN, ptApp->szControlPara+iCtrlIndex);
                        iCtrlIndex += 6;

                        /* ��С���(6Bytes) + �����(6Bytes) + �������Ƿ����(1Byte) */
                        iCtrlIndex += 13;
                    }

                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, "FF", 2);

                    break;
                /* ����Ӧ�ú� */
                case 0x08:
                    if(strlen(ptApp->szFinancialCode) > 0)
                    {
                        /* ���Ʋ�������(1Byte) + ��С����(1Byte) + ��󳤶�(1Byte) + 
                           ģʽ��ʶ(1Byte) + ��ʾ��ʶ(1Byte) + ��������(1Byte) */
                        iCtrlIndex += 6;

                        /* �������ݳ��� */
                        ptApp->szControlPara[iCtrlIndex] = strlen(ptApp->szFinancialCode);
                        iCtrlIndex += 1;

                        /* �������� */
                        memcpy(ptApp->szControlPara+iCtrlIndex, ptApp->szFinancialCode, 
                               strlen(ptApp->szFinancialCode));
                        iCtrlIndex += strlen(ptApp->szFinancialCode);
                    }

                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, "FF", 2);

                    break;
                /* ����Ӧ�ú� */
                case 0x09:
                    if(strlen(ptApp->szBusinessCode) > 0)
                    {
                        /* ���Ʋ�������(1Byte) + ��С����(1Byte) + ��󳤶�(1Byte) + 
                           ģʽ��ʶ(1Byte) + ��ʾ��ʶ(1Byte) + ��������(1Byte) */
                        iCtrlIndex += 6;

                        /* �������ݳ��� */
                        ptApp->szControlPara[iCtrlIndex] = strlen(ptApp->szBusinessCode);
                        iCtrlIndex += 1;

                        /* �������� */
                        memcpy(ptApp->szControlPara+iCtrlIndex, ptApp->szBusinessCode, 
                               strlen(ptApp->szBusinessCode));
                        iCtrlIndex += strlen(ptApp->szBusinessCode);
                    }

                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, "FF", 2);

                    break;
                /* ���� */
                case 0x0A:
                /* ���� */
                case 0x0B:
                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, "FF", 2);

                    break;
                /* �Զ������� */
                case 0x0C:
                    if(strlen(ptApp->szBusinessCode) > 0)
                    {
                        /* ���Ʋ�������(1Byte) + ��С����(1Byte)+��󳤶�(1Byte)+ģʽ��ʶ(1Byte)*/
                        iCtrlIndex += 4;

                        /* �������ݳ��� */
                        ptApp->szControlPara[iCtrlIndex] = strlen(ptApp->szUserData);
                        iCtrlIndex += 1;

                        /* �������� */
                        memcpy(ptApp->szControlPara+iCtrlIndex, ptApp->szUserData, 
                               strlen(ptApp->szUserData));
                        iCtrlIndex += strlen(ptApp->szUserData);
                    }

                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, "FF", 2);

                    break;
                /* MAC */
                case 0x0D:
                /* ����ǩ�� */
                case 0x0E:
                /* ������Ϣ */
                case 0x0F:
                /* ���İ汾�� */
                case 0x10:
                /* �ն�Ӧ�ýű��汾�� */
                case 0x11:
                /* �ն����к� */
                case 0x12:
                /* ���ܱ������� */
                case 0x13:
                /* ���ܱ������� */
                case 0x14:
                /* ��ȡ�ʵ�֧������ */
                case 0x15:
                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, "FF", 2);

                    break;
                /* �����ն˲��� */
                case 0x16:
                /* ����PSAM������ */
                case 0x17:
                /* ���²˵����� */
                case 0x18:
                /* ���¹�����ʾ */
                case 0x19:
                /* ���²�����ʾ */
                case 0x1A:
                /* ���´�ӡģ���¼ */
                case 0x1C:
                /* ���´�����ʾ��Ϣ */
                case 0x1D:
                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, ptApp->szReserved, ptApp->iReservedLen);

                    /* ��Ч���ݳ��� */
                    szValidData[iValidDataLen] = ptApp->iReservedLen;
                    iValidDataLen += 1;

                    /* �������� */
                    memcpy(szValidData+iValidDataLen, ptApp->szReserved, ptApp->iReservedLen);
                    iValidDataLen += ptApp->iReservedLen;

                    break;    
                /* ������ҳ��Ϣ */
                case 0x1B:
                    if(iFirstPageLen > 0)
                    {
                        WriteCmdData(ptApp->szCommand+iCmdIndex, i, szFirstPage, iFirstPageLen);

                        /* ��Ч���ݳ��� */
                        szValidData[iValidDataLen] = iFirstPageLen;
                        iValidDataLen += 1;

                        /* �������� */
                        memcpy(szValidData+iValidDataLen, szFirstPage, iFirstPageLen);
                        iValidDataLen += iFirstPageLen;
                    }
                    else
                    {
                        WriteCmdData(ptApp->szCommand+iCmdIndex, i, "\x00", 1);

                        /* ��Ч���ݳ��� */
                        szValidData[iValidDataLen] = 0;
                        iValidDataLen += 1;
                    }

                    break;
                /* �洢�ʵ� */
                case 0x1E:
                    /* �������� */
                    AscToBcd((uchar*)(ptApp->szHostDate), 8, LEFT_ALIGN, szValidData+iValidDataLen);
                    iValidDataLen += 4;

                    /* ����ʱ�� */
                    AscToBcd((uchar*)(ptApp->szHostTime), 6, LEFT_ALIGN, szValidData+iValidDataLen);
                    iValidDataLen += 3;

                    /* ��Ч���ݳ��� */
                    szValidData[iValidDataLen] = ptApp->iReservedLen;
                    iValidDataLen ++;

                    /* �������� */
                    memcpy(szValidData+iValidDataLen, ptApp->szReserved, ptApp->iReservedLen);
                    iValidDataLen += ptApp->iReservedLen;

                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, szValidData+iValidDataLen-ptApp->iReservedLen-8,
                                 ptApp->iReservedLen+8);

                    break;
                /* ��¼��־ */
                case 0x1F:
                    /* �������� */
                    AscToBcd((uchar*)(ptApp->szHostDate), 8, LEFT_ALIGN, szValidData+iValidDataLen);
                    iValidDataLen += 4;

                    /* ����ʱ�� */
                    AscToBcd((uchar*)(ptApp->szHostTime), 6, LEFT_ALIGN, szValidData+iValidDataLen);
                    iValidDataLen += 3;

                    /* ��ˮ�� */
                    memset(szTmpBuf, 0, sizeof(szTmpBuf));
                    sprintf(szTmpBuf, "%06ld", ptApp->lPosTrace);
                    AscToBcd((uchar*)szTmpBuf, 6, LEFT_ALIGN, szValidData+iValidDataLen);
                    iValidDataLen += 3;

                    /* MAC */
                    memcpy(szValidData+iValidDataLen, ptApp->szMac, 8);
                    iValidDataLen += 8;

                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, szValidData+iValidDataLen-18, 18);

                    break;    
                /* �洢���� */
                case 0x20:
                    /* �������� */
                    AscToBcd((uchar*)(ptApp->szHostDate), 8, LEFT_ALIGN, szValidData+iValidDataLen);
                    iValidDataLen += 4;

                    /* ����ʱ�� */
                    AscToBcd((uchar*)(ptApp->szHostTime), 6, LEFT_ALIGN, szValidData+iValidDataLen);
                    iValidDataLen += 3;

                    /* �������ݳ��� */
                    szValidData[iValidDataLen] = ptApp->iReservedLen;
                    iValidDataLen ++;

                    /* �������� */
                    memcpy(szValidData+iValidDataLen, ptApp->szReserved, ptApp->iReservedLen);
                    iValidDataLen += ptApp->iReservedLen;

                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, szValidData+iValidDataLen-ptApp->iReservedLen-8, 
                                 ptApp->iReservedLen+8);

                    break;    
                /* ��ӡ���� */
                case 0x21:
                    iValueLen = 0;
                    iPrintCount = 0;
                    memset(szValue, 0, sizeof(szValue));

                    iValueLen = GetPrintData(ptApp, iDataSourceIndex, szValue, &iPrintCount);
                    iDataSourceIndex++;

                    /* ��ӡ���ݳ��� */
                    szValidData[iValidDataLen] = (iValueLen+1) / 256;
                    szValidData[iValidDataLen+1] = (iValueLen+1) % 256;
                    iValidDataLen += 2;

                    /* ��ӡ���� */
                    szValidData[iValidDataLen] = iPrintCount + '0';
                    iValidDataLen += 1;

                    /* ��ӡ���� */
                    memcpy(szValidData+iValidDataLen, szValue, iValueLen);
                    iValidDataLen += iValueLen;

                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, szValidData+iValidDataLen-3-iValueLen, iValueLen+3);

                    break;    
                /* ��ʾ�����Ϣ */
                case 0x22:
                    iValueLen = 0;
                    memset(szValue, 0, sizeof(szValue));

                    iValueLen = GetReturnData(ptApp, szValue);

                    /* �����Ϣ���� */
                    szValidData[iValidDataLen] = iValueLen;
                    iValidDataLen += 1;

                    memcpy(szValidData+iValidDataLen, szValue, iValueLen);
                    iValidDataLen += iValueLen;

                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, szValidData+iValidDataLen-iValueLen-1, iValueLen+1);

                    break;    
                /* ����ϵͳ */
                case 0x23: 
                /* �������� */
                case 0x24:   
                /* �������� */
                case 0x25:   
                /* �һ� */
                case 0x26:  
                /* ��֤����֧������ */
                case 0x27:
                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, "FF", 2);

                    break;    
                /* ��֤MAC */
                case 0x28:
                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, "FF", 2);

                    *piCalcMac = 1;

                    break;    
                /* ���Ღ�� */
                case 0x29:  
                /* ����ȷ�� */
                case 0x2A:
                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, "FF", 2);

                    break;    
                /* �û�ѡ��̬�˵� */
                case 0x2B:
                    iValueLen = 0;
                    memset(szValue, 0, sizeof(szValue));

                    iValueLen = GetMenuData(ptApp, iDataSourceIndex, &iMenuRecNo, szValue);
                    if(iValueLen == FAIL)
                    {
                        WriteLog(ERROR, "��ȡ��̬�˵�ʧ��!");

                        memset(ptApp->szRetDesc, 0, sizeof(ptApp->szRetDesc));

                        return FAIL;
                    }
                    iDataSourceIndex += 1;

                    ptApp->iMenuRecNo[ptApp->iMenuNum] = iMenuRecNo;
                    ptApp->iMenuNum += 1;

                    /* ��Ч���ݳ��� */
                    szValidData[iValidDataLen] = iValueLen;
                    iValidDataLen += 1;

                    /* �������� */
                    memcpy(szValidData+iValidDataLen, szValue, iValueLen);
                    iValidDataLen += iValueLen;

                    WriteCmdData(ptApp->szCommand+iCmdIndex, i,
                                 szValidData+iValidDataLen-iValueLen-1, iValueLen+1);

                    break;    
                /* ��̬�˵����� */
                case 0x2C:
                    /* ��Ч���ݳ��� */
                    szValidData[iValidDataLen] = ptApp->iReservedLen / 256;
                    szValidData[iValidDataLen+1] = ptApp->iReservedLen % 256;
                    iValidDataLen += 2;        

                    /* �������� */
                    memcpy(szValidData+iValidDataLen, ptApp->szReserved, ptApp->iReservedLen);
                    iValidDataLen += ptApp->iReservedLen;

                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, szValidData+iValidDataLen-ptApp->iReservedLen-2, 
                                 ptApp->iReservedLen+2);

                    break;    
                /* �洢���� */
                case 0x2D:
                /* �ϴ����� */
                case 0x2E:
                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, "FF", 2);

                    break;    
                /* ϵͳ��ʱ������ʾ��Ϣ */
                case 0x2F:
                    iValueLen = 0;
                    memset(szValue, 0, sizeof(szValue));

                    iValueLen = GetTmpOperationInfo(ptApp, iDataSourceIndex, szValue);
                    if(iValueLen == FAIL)
                    {
                        WriteLog(ERROR, "��ȡ��ʱ������ʾʧ��!");

                        memset(ptApp->szRetDesc, 0, sizeof(ptApp->szRetDesc));

                        return FAIL;
                    }
                    iDataSourceIndex += 1;

                    /* ��Ч���ݳ��� */
                    szValidData[iValidDataLen] = iValueLen;
                    iValidDataLen ++;

                    /* �������� */
                    memcpy(szValidData+iValidDataLen, szValue, iValueLen);
                    iValidDataLen += iValueLen;

                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, szValidData+iValidDataLen-iValueLen-1, iValueLen+1);

                    break;
                /* ��ȡ���̿����� */
                case 0x30:
                /* IC��ָ�� */
                case 0x31:
                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, "FF", 2);

                    break;
                /* �ļ����ݴ���(������) */
                case 0x32:
                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, "FF", 2);

                    break;    
                /* ���� */
                case 0x33:
                /* �ϴ�������־ */
                case 0x34:   
                /* �ϴ�������־ */
                case 0x35:  
                /* �������� */
                case 0x36:
                /* ��PC���ڽ������� */
                case 0x37:
                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, "FF", 2);

                    break;
                /* �������ݸ�PC���� */
                case 0x38:
                    /* �������� */
                    memcpy(szValidData+iValidDataLen, ptApp->szReserved, ptApp->iReservedLen);
                    iValidDataLen += ptApp->iReservedLen;

                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, szValidData+iValidDataLen-ptApp->iReservedLen, 
                                 ptApp->iReservedLen);

                    break;
                /* ���¹�����Կ */
                case 0x39:
                    /* ��Ч���ݳ��� */
                    szValidData[iValidDataLen] = ptApp->iReservedLen;
                    iValidDataLen += 1;

                    /* �������� */
                    memcpy(szValidData+iValidDataLen,ptApp->szReserved, ptApp->iReservedLen);
                    iValidDataLen += ptApp->iReservedLen;

                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, szValidData+iValidDataLen-ptApp->iReservedLen-1, 
                                 ptApp->iReservedLen+1);

                    break;
                /* Ԥ���� */
                case 0x3A:
                /* ��ղ˵� */
                case 0x3B:
                /* �����ط����� */
                case 0x3C:
                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, "FF", 2);

                    break;
                /* ��ʾ��Ϣ���� */
                case 0x3D:
                    iValueLen = 0;
                    memset(szValue, 0, sizeof(szValue));

                    iValueLen = GetQueryResult(ptApp, szValue);
                    if(iValueLen == FAIL)
                    {
                        WriteLog(ERROR, "��ȡ��ʾ��Ϣ����ʧ��!");

                        memset(ptApp->szRetDesc, 0, sizeof(ptApp->szRetDesc));

                        return FAIL;
                    }

                    /* ���ݳ��� */
                    szValidData[iValidDataLen] = iValueLen / 256L;
                    szValidData[iValidDataLen+1] = iValueLen % 256L;
                    iValidDataLen += 2;

                    /* �������� */
                    memcpy(szValidData+iValidDataLen, szValue, iValueLen);
                    iValidDataLen += iValueLen;

                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, szValidData+iValidDataLen-iValueLen-2, iValueLen+2);

                    break;            
                /* TMS�������� */
                case 0x3E:
                    /* ���ݳ��� */
                    szValidData[iValidDataLen] = (ptApp->iTmsLen) / 256L;
                    szValidData[iValidDataLen+1] = (ptApp->iTmsLen) % 256L;
                    iValidDataLen += 2;

                    /* �������� */
                    memcpy(szValidData+iValidDataLen, ptApp->szTmsData, ptApp->iTmsLen);
                    iValidDataLen += ptApp->iTmsLen;

                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, szValidData+iValidDataLen-ptApp->iTmsLen-2,
                                 ptApp->iTmsLen+2);

                    break;
                /* Ԥ�� */
                case 0x3F:
                    WriteCmdData(ptApp->szCommand+iCmdIndex, i, "FF", 2);

                    break;
                default:
                    WriteLog(ERROR, "δָ֪�� %02x", ucOrgCmd);

                    break;
            }

            iCmdIndex = iCmdIndex+iCmdBytes;
        }
    }

    /* ��¼POSָ�������־ */
    WriteCmdData(ptApp->szTransName, ptApp->lPosTrace, "SNDEND", ptApp->iTransType);

    memcpy(szData, szValidData, iValidDataLen);
    *piDataLen = iValidDataLen;

    return SUCC;
}