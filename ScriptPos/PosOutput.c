/*******************************************************************************
 * Copyright(C)2012��2015 �������������豸���޹�˾
 * ��Ҫ���ݣ�ScriptPosģ�� POS�����Ĳ��
 * �� �� �ˣ�Robin
 * �������ڣ�2012/11/30
 * $Revision: 1.3 $
 * $Log: PosOutput.c,v $
 * Revision 1.3  2013/03/11 07:14:18  fengw
 *
 * 1�������Զ���ָ�����롣
 *
 * Revision 1.2  2013/02/21 06:49:38  fengw
 *
 * 1���޸�08�š�48��ָ�����롣
 *
 * Revision 1.1  2013/01/18 08:32:37  fengw
 *
 * 1����ֺ�����
 *
 ******************************************************************************/

#define _EXTERN_

#include "ScriptPos.h"

/****************************************************************
** ��    �ܣ�POSָ��������ݲ��
** ���������
**        iCmdNum                   ָ�����
**        szCmdData                 ָ������
**        iCmdLen                   ָ�����ݳ���
**        szData                    ��Ч����
**        iDataLen                  ��Ч���ݳ���
** ���������
**        ptApp                     app�ṹָ��
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
int PosOutput(T_App *ptApp, int iCmdNum, char *szCmdData, int iCmdLen, char *szData, int iDataLen)
{
    int         i, j;
    T_TLVStru   tTlv;                           /* TLV���ݽṹ */
    int         iCmdIndex;                      /* ָ������ */
    int         iDataIndex;                     /* ��Ч�������� */
    int         iCmdBytes;                      /* ָ��� */
    uchar       ucOrgCmd;                       /* ԭʼָ�� */
    char        szTmpBuf[1024+1];               /* ��ʱ���� */
    int         iTmp;                           /* ��ʱ���� */
    char        szTlvTag[3+1];                  /* TLV TAG */
    int         iTlvLen;                        /* TLV���ݳ��� */
    char        szTlvBuf[2048+1];               /* TLV���� */
    int         iCopyIndex;                     /* ���ݿ������� */
    int         iControlNum;                    /* ���̿�������� */
    int         iMenuNum;                       /* ��̬�˵����� */
    int         iaTimes[MAX_COMMAND_NUM];       /* ��¼ָ����ֵĴ��� */

    /* ��¼POSָ�������־ */
    WriteCmdData(ptApp->szTransName, ptApp->lPosTrace, "RCVBEGIN", ptApp->iTransType);

    /* ָ�����ݽ��� */
    /* TLV��ʼ�� */
    InitTLV(&tTlv, TAG_STANDARD, LEN_STANDARD, VALUE_NORMAL);

    iControlNum = 0;
    iMenuNum = 0;
    iCmdIndex = 0;
    iDataIndex = 0;

    for(i=0; i<MAX_COMMAND_NUM; i++)
    {
        iaTimes[i] = 0;
    }

    for(i=0;i<iCmdNum;i++)
    { 
        /* �ж��Ƿ�������ָ�� */
        /*
        �����������Ϊ3���ֽڡ�
        ��һ���ֽڹ̶�ΪC0��
        �ڶ����ֽڱ�ʾ����ָ�������Ӧ�Ĳ�����ʾ��Ϣ�����ţ�HEX������Ϊ0��ʾ�޲�����ʾ��Ϣ��Ϊ255��ʾʹ����ʱ������ʾ��Ϣ����ʱ������ʾ��Ϣ�����ķ��أ�������������XX��ʾ��
        �������ֽڱ�ʾ�����ָ�����͡�
        */
        if((szCmdData[iCmdIndex] & 0xFF) == SPECIAL_CMD_HEAD)
        {   
            if((iTmp = SpecialOutput(ptApp, szCmdData+iCmdIndex, szData+iDataIndex)) == FAIL)
            {
                WriteLog(ERROR, "�����Զ���ָ���������ʧ��!");

                return FAIL;
            }

            if(iTmp == 0)
            {
                WriteCmdData(szCmdData+iCmdIndex, i, "FF", 2);
            }
            else
            {
                WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, iTmp);
            }

            iDataIndex += iTmp;
            iCmdIndex += SPECIAL_CMD_LEN;
        }
        else
        {
            iCmdBytes = CalcCmdBytes((uchar)szCmdData[iCmdIndex]);

            ucOrgCmd = szCmdData[iCmdIndex] & 0x3F;

            /* ��¼ָ����ִ��� */
            iaTimes[ucOrgCmd]++;

            /* ���浱ǰ��������ֵ�����ڿ���TLV */
            iCopyIndex = iDataIndex;

            switch(ucOrgCmd)
            {
                /* ��ȡ��ȫģ��� */
                case 0x02:
                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 16);
                    iDataIndex += 16;

                    break;
                /* �ŵ��������� */
                case 0x03:
                    /* ����� */
                    memset(szTmpBuf, 0, sizeof(szTmpBuf));
                    BcdToAsc(szData+iDataIndex, 2, 0, szTmpBuf);
                    memcpy(ptApp->szEmvCardNo, szTmpBuf, 3);
                    iDataIndex += 2;
#ifdef DEBUG
                    WriteLog(TRACE, "�����:[%s]", ptApp->szEmvCardNo);
#endif

                    if((iTmp = GetTrack(ptApp, szData+iDataIndex)) == FAIL)
                    {
                        return FAIL;
                    }
                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, iTmp);
                    iDataIndex += iTmp;

                    if(iaTimes[ucOrgCmd] == 1)
                    {
                        /* ���ݴŵ���Ϣ��ȡ���� */
                        if(GetCardType(ptApp) != SUCC)
                        {
                            WriteLog(ERROR, "���ݴŵ���Ϣ��ȡ����ʧ��!");

                            return FAIL;
                        }
                    }

                    break;
                /* �ŵ��������� */
                case 0x04:
                    /* �ŵ��������ĳ��� */
                    iTmp = (uchar)(szData[iDataIndex]);    
                    if(iTmp > 88)
                    {
                        WriteLog(ERROR, "�ŵ��������ݳ���[%d]�Ƿ�!", iTmp);

                        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

                        return FAIL;
                    }
                    iDataIndex += 1;

                    /* /���ܴŵ����� */
                    if(iaTimes[ucOrgCmd] == 1)
                    {
                        if(HsmDecryptTrack(ptApp, ptApp->szTrackKey,
                           szData+iDataIndex, iTmp) != SUCC)
                        {
                            WriteLog(ERROR, "���ܴŵ���������ʧ��!");

                            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

                            return FAIL;
                        }

                        /* ���ݴŵ���Ϣ��ȡ���� */
                        if(GetCardType(ptApp) != SUCC)
                        {
                            WriteLog(ERROR, "���ݴŵ���Ϣ��ȡ����ʧ��!");

                            return FAIL;
                        }
                    }

                    /* ��¼ָ������ */
                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, iTmp);
                    iDataIndex += iTmp;

                    break;
                /* �������� */
                case 0x05:
                    if(iaTimes[ucOrgCmd] == 1)
                    {
                        memcpy(ptApp->szPasswd, szData+iDataIndex, 8);
                    }
                    else
                    {
                        memcpy(ptApp->szNewPasswd, szData+iDataIndex, 8);
                    }
                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 8);
                    iDataIndex += 8;

                    break;
                /* �������� */
                case 0x06:
                    if(iaTimes[ucOrgCmd] == 1)
                    {
                        memset(szTmpBuf, 0, sizeof(szTmpBuf));
                        BcdToAsc((uchar*)(szData+iDataIndex), 6, LEFT_ALIGN, (uchar*)szTmpBuf);

                        ptApp->iTransNum = atol(szTmpBuf);
                        ptApp->lOldPosTrace= atol(szTmpBuf);
                    }

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 3);
                    iDataIndex += 3;
    
                    break;
                /* ���׽�� */
                case 0x07:
                    if(iaTimes[ucOrgCmd] == 1)
                    {
                        BcdToAsc((uchar*)(szData+iDataIndex), 12, LEFT_ALIGN, ptApp->szAmount);
                    }  

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 6);
                    iDataIndex += 6;

                    break;
                /* ����Ӧ�ú� */
                case 0x08:
                    /* ����Ӧ�úų��� */
                    iTmp = (uchar)(szData[iDataIndex]);    
                    if(iTmp > 40)
                    {
                        WriteLog(ERROR, "����Ӧ�úų���[%d]�Ƿ�!", iTmp);

                        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

                        return FAIL;
                    }
                    iDataIndex += 1;

                    if(iaTimes[ucOrgCmd] == 1)
                    {
                        memcpy(ptApp->szFinancialCode, szData+iDataIndex, iTmp);
                        ptApp->szFinancialCode[iTmp] = 0;

                        strcpy(ptApp->szAccount2, ptApp->szFinancialCode);

                        /* ���ݵڶ����Ż�ȡ����Ϣ */
                        if(GetAcctType(ptApp) != SUCC)
                        {
                            WriteLog(ERROR, "���ݵڶ����Ż�ȡ����Ϣʧ��!");

                            return FAIL;
                        }
                    }

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, iTmp);
                    iDataIndex += iTmp;

                    break;
                /* ����Ӧ�ú� */
                case 0x09:
                    /* ����Ӧ�úų��� */
                    iTmp = (uchar)(szData[iDataIndex]);    
                    if(iTmp > 40)
                    {
                        WriteLog(ERROR, "����Ӧ�úų���[%d]�Ƿ�!", iTmp);

                        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

                        return FAIL;
                    }
                    iDataIndex += 1;

                    if(iaTimes[ucOrgCmd] == 1)
                    {
                        memcpy(ptApp->szBusinessCode, szData+iDataIndex, iTmp);
                        ptApp->szBusinessCode[iTmp] = 0;
                    }

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, iTmp);
                    iDataIndex += iTmp;

                    break;
                /* ����YYYYMMDD */
                case 0x0A:
                    if(iaTimes[ucOrgCmd] == 1)
                    {
                        BcdToAsc((uchar*)(szData+iDataIndex), 8, LEFT_ALIGN, 
                                 (uchar*)ptApp->szInDate);
                    }

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 4);
                    iDataIndex += 4;

                    break;
                /* ����YYYYMM */
                case 0x0B:
                    if(iaTimes[ucOrgCmd] == 1)
                    {
                        BcdToAsc((uchar*)(szData+iDataIndex), 6, LEFT_ALIGN, 
                                 (uchar*)ptApp->szInMonth);
                    }

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 3);
                    iDataIndex += 3;

                    break;
                /* �Զ������� */
                case 0x0C:
                    /* �Զ������ݳ��� */
                    iTmp = (uchar)(szData[iDataIndex]);    
                    if(iTmp > 40)
                    {
                        WriteLog(ERROR, "�Զ������ݳ���[%d]�Ƿ�!", iTmp);

                        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

                        return FAIL;
                    }
                    iDataIndex += 1;

                    if(iaTimes[ucOrgCmd] == 1)
                    {
                        memcpy(ptApp->szUserData, szData+iDataIndex, iTmp);
                        ptApp->szUserData[iTmp] = 0;
                    }

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, iTmp);
                    iDataIndex += iTmp;

                    break;
                /* MAC */
                case 0x0D:
                    if(ptApp->iTransType != AUTO_VOID)
                    {
                        memcpy(ptApp->szMac, szData+iDataIndex, 8);
                    }

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 8);
                    iDataIndex += 8;

                    break;
                /* ������Ϣ[ԭ������ˮ��(3 bytes)+ԭ����MAC(8 bytes)] */
                case 0x0F:
                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 11);

                    memset(szTmpBuf, 0, sizeof(szTmpBuf));
                    BcdToAsc((uchar*)(szData+iDataIndex), 6, LEFT_ALIGN, (uchar*)szTmpBuf);

                    ptApp->lOldPosTrace = atol(szTmpBuf);
                    iDataIndex += 3;

                    memcpy(ptApp->szMac, szData+iDataIndex, 8);
                    iDataIndex += 8;

                    break;
                /* ���İ汾�� */
                case 0x10:
                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 2);
                    iDataIndex += 2;

                    break;
                /* �ն�Ӧ�ýű��汾�� */
                case 0x11:
                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 4);
                    iDataIndex += 4;

                    break;
                /* �ն����к� */
                case 0x12:
                    memcpy(ptApp->szTermSerialNo, szData+iDataIndex, 10);

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 10);
                    iDataIndex += 10;

                    break;
                /* ���ܱ������� */
                case 0x13:
                    /* ���ܱ������ݳ��� */
                    iTmp = (uchar)(szData[iDataIndex]);    
                    if(iTmp > 256)
                    {
                        WriteLog(ERROR, "���ܱ������ݳ���[%d]�Ƿ�!", iTmp);

                        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

                        return FAIL;
                    }
                    iDataIndex += 1;

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, iTmp);
                    iDataIndex += iTmp;

                     break;
                /* ���ܱ������� */
                case 0x14:
                    /* ���ܱ������ݳ��� */
                    iTmp = (uchar)(szData[iDataIndex]);    
                    if(iTmp > 240)
                    {
                        WriteLog(ERROR, "���ܱ������ݳ���[%d]�Ƿ�!", iTmp);

                        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

                        return FAIL;
                    }
                    iDataIndex += 1;

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, iTmp);
                    iDataIndex += iTmp;

                    break;
                /* ��ȡ�ʵ�֧������ */
                case 0x15:
                    /* �˵�֧�����ݳ��� */
                    iTmp = (uchar)(szData[iDataIndex]);    
                    if(iTmp > 40)
                    {
                        WriteLog(ERROR, "�˵�֧�����ݳ���[%d]�Ƿ�!", iTmp);

                        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

                        return FAIL;
                    }
                    iDataIndex += 1;

                    memcpy(ptApp->szBusinessCode, szData+iDataIndex, iTmp); 

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, iTmp);
                    iDataIndex += iTmp;

                    break;
                /* �����ն˲��� */
                case 0x16:
                /* ���°�ȫģ����� */
                case 0x17:
                /* ���²˵����� */
                case 0x18:
                /* ���¹�����ʾ */
                case 0x19:
                /* ���²�����ʾ */
                case 0x1A:
                /* ������ҳ��Ϣ */
                case 0x1B:
                /* ���´�ӡģ���¼ */
                case 0x1C:
                /* ���´�����ʾ��Ϣ */
                case 0x1D:
                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 2);

                    memcpy(ptApp->szHostRetCode, szData+iDataIndex, 2);
                    iDataIndex += 2;

                    break;
                /* �洢�ʵ� */
                case 0x1E:
                    /* �˵�֧�����ݳ��� */
                    iTmp = (uchar)(szData[iDataIndex]);    
                    if(iTmp > 42)
                    {
                        WriteLog(ERROR, "�˵�֧�����ݳ���[%d]�Ƿ�!", iTmp);

                        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

                        return FAIL;
                    }
                    iDataIndex += 1;

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex-1, iTmp+1);

                    /* �洢��� */
                    memcpy(ptApp->szHostRetCode, szData+iDataIndex, 2);
                    iDataIndex += 2;

                    memcpy(ptApp->szBusinessCode, szData+iDataIndex, iTmp-2);
                    iDataIndex = iDataIndex+iTmp-2;

                    break;    
                /* ��¼��־ */
                case 0x1F:
                /* �洢���� */
                case 0x20:
                /* ��ӡ���� */
                case 0x21:
                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 2);

                    memcpy(ptApp->szHostRetCode, szData+iDataIndex, 2);
                    iDataIndex += 2;

                    break;
                /* ��ʾ�����Ϣ */
                case 0x22:
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
                /* ��֤MAC */
                case 0x28:
                /* ���Ღ�� */
                case 0x29:
                /* ����ȷ�� */
                case 0x2A:
                    /* ָ��0x22��0x2Aû��������� */
                    WriteCmdData(szCmdData+iCmdIndex, i, "FF", 2);

                    break;    
                /* �û�ѡ��̬�˵� */
                case 0x2B:
                     WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 1);

                    /* ��̬�˵��� */
                    iTmp = (uchar)(szData[iDataIndex]);    
                    if(iTmp >= 5)
                    {
                        WriteLog(ERROR, "��̬�˵���[%d]�Ƿ�!", iTmp);

                        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

                        return FAIL;
                    }
                    iDataIndex += 1;

                    ptApp->iaMenuItem[iMenuNum] = iTmp;
                    iMenuNum++;

                    break;    
                /* ��̬�˵����� */
                case 0x2C:
                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 2);

                    memcpy(ptApp->szHostRetCode, szData+iDataIndex, 2);
                    iDataIndex += 2;

                    break;    
                /* ��̬�˵���ʾ��ѡ�� */
                case 0x2D:
                    /* ��̬�˵�ID */
                    ptApp->iStaticMenuId = (uchar)(szData[iDataIndex]);
                    iDataIndex += 1;

                    /* ��̬�˵�������� */
                    iTmp = (uchar)(szData[iDataIndex]);    
                    if(iTmp > 30)
                    {
                        WriteLog(ERROR, "��̬�˵��������[%d]�Ƿ�!", iTmp);

                        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

                        return FAIL;
                    }
                    iDataIndex += 1;

                    memcpy(ptApp->szStaticMenuOut, szData+iDataIndex, iTmp);
                    ptApp->szStaticMenuOut[iTmp] = 0;

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex-2, iTmp+2);
                    iDataIndex += iTmp;

                    break;    
                /* �ϴ����� */
                case 0x2E:
                    /* ���ż�¼�� */
                    iTmp = (uchar)(szData[iDataIndex]);    
                    if(iTmp > MAX_REC_CARD_NUM)
                    {
                        WriteLog(ERROR, "һ���ϴ���������[%d]̫��!����ϴ���:[%d]",
                                 iTmp, MAX_REC_CARD_NUM);

                        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

                        return FAIL;
                    }
                    iDataIndex += 1;

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex-1, 17*iTmp+1);
                    iDataIndex += 17*iTmp;

                    break;    
                /* ϵͳ��ʱ������ʾ��Ϣ */
                case 0x2F:
                    WriteCmdData(szCmdData+iCmdIndex, i, "FF", 2);

                    break;
                /* ��ȡ���̿����� */
                case 0x30:
                    if(iControlNum <= 5)
                    {
                        ptApp->szControlCode[iControlNum] = szData[iDataIndex];
                    }
                    else
                    {
                        WriteLog(ERROR, "���̿����볬��5��");

                        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

                        return FAIL;
                    }

                    /* ��ִ����һ��ָ���룬���� */
                    if(szData[iDataIndex] == '0')
                    {
                        WriteCmdData(szCmdData+iCmdIndex+iCmdBytes, i, "FF", 2);
                        iCmdIndex += CalcCmdBytes((uchar)szCmdData[iCmdIndex+iCmdBytes]);
                        i++;
                    }

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 1);
                    iDataIndex += 1;

                    iControlNum++;

                    break;
                /* IC��ָ��(Ԥ��) */
                case 0x31:
                /* �ļ����ݴ��� */
                case 0x32:
                    WriteCmdData(szCmdData+iCmdIndex, i, "FF", 2);

                    break;
                /* ��ȡ���ŵ����� */
                case 0x33:
                    if(iaTimes[ucOrgCmd] == 1)
                    {
                        memset(szTmpBuf, 0, sizeof(szTmpBuf));
                        BcdToAsc((uchar*)(szData+iDataIndex), 20, LEFT_ALIGN, (uchar*)szTmpBuf);

                        iDataIndex += 10;

                        for(j=0;j<20;j++)
                        {
                            if(szTmpBuf[j] == 'F')
                            {
                                szTmpBuf[j] = 0;
                                break;
                            }
                        }
                        strcpy(ptApp->szPan, szTmpBuf);
                    }

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 10);
                    iDataIndex += 10;

                    break;
                /* �ϴ�������־ */
                case 0x34:
                    /* �ݲ�ʵ�� */
                    break;
                /* �ϴ�������־ */
                case 0x35:
                    /* �ݲ�ʵ�� */
                    break;    
                /* �������� */
                case 0x36:
                    if(iaTimes[ucOrgCmd] == 1)
                    {
                        memset(szTmpBuf, 0, sizeof(szTmpBuf));
                        BcdToAsc((uchar*)(szData+iDataIndex), 6, LEFT_ALIGN, (uchar*)szTmpBuf);
                        ptApp->lRate = atol(szTmpBuf);
                    }

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 3);
                    iDataIndex += 3;

                    break;
                /* �Ӵ��ڽ������� */
                case 0x37:
                    iTlvLen = (uchar)szData[iDataIndex];

                    szTlvTag[0] = 0xDF;
                    szTlvTag[1] = 0x80|ucOrgCmd;
                    szTlvTag[2] = iaTimes[ucOrgCmd];
                    SetTLV(&tTlv, szTlvTag, iTlvLen, szData+iDataIndex+1);

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, iTlvLen+1);
                    iDataIndex += (iTlvLen+1);

                    break;
                /* �������ݸ����� */
                case 0x38:
                    iTlvLen = (uchar)szData[iDataIndex];

                    szTlvTag[0] = 0xDF;
                    szTlvTag[1] = 0x80|ucOrgCmd;
                    szTlvTag[2] = iaTimes[ucOrgCmd];
                    SetTLV(&tTlv, szTlvTag, iTlvLen, szData+iDataIndex+1);

                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, iTlvLen+1);
                    iDataIndex += (iTlvLen+1);

                    break;
                /* ǩ��������Կ */
                case 0x39:
                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 2);

                    memcpy(ptApp->szHostRetCode, szData+iDataIndex, 2);
                    iDataIndex += 2;

                    break;
                /* Ԥ���� */
                case 0x3A:
                /* ��ղ˵� */
                case 0x3B:
                /* �����ط����� */
                case 0x3C:
                    WriteCmdData(szCmdData+iCmdIndex, i, "FF", 2);

                    break;
                /* ��ʾ��̨��������(ѡ�����) */
                case 0x3D:
                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 1);
                    iDataIndex += 1;

                    break;    
                /* TMS�������� */
                case 0x3E:
                    WriteCmdData(szCmdData+iCmdIndex, i, szData+iDataIndex, 2);

                    memcpy(ptApp->szHostRetCode, szData+iDataIndex, 2);
                    iDataIndex += 2;

                    break;
                /* Ԥ�� */
                case 0x3F:
                    break;
                default:
                    break;
            }

            /* ��2�γ��ֵ�ָ�����ݣ���TLV��ʽ��¼��szReserved�ֶ��� */
            if(iaTimes[ucOrgCmd] >= 2)
            {
                szTlvTag[0] = 0xDF;
                szTlvTag[1] = 0x80|ucOrgCmd;
                szTlvTag[2] = iaTimes[ucOrgCmd];

                SetTLV(&tTlv, szTlvTag, iDataIndex-iCopyIndex, szData+iCopyIndex);
            }

            iCmdIndex = iCmdIndex+iCmdBytes;
        }
    }

    /* ��¼POSָ�������־ */
    WriteCmdData(ptApp->szTransName, ptApp->lPosTrace, "RCVEND", ptApp->iTransType);

    /* ����TLV���� */
    memset(szTlvBuf, 0, sizeof(szTlvBuf));
    iTlvLen = PackTLV(&tTlv, szTlvBuf);
    if(iTlvLen == FAIL)
    {
        WriteLog(ERROR, "TLV���ݸ�ʽת��Ϊ�ַ���ʧ��!");

        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        return FAIL;
    }

    if((iTlvLen+ptApp->iReservedLen) > sizeof(ptApp->szReserved))
    {
        WriteLog(ERROR,
                 "��Ҫ����szReserved�����ݳ���̫��!��ǰ����:[%d] ���������ݳ���:[%d] ������ݳ���:[%d]",
                 ptApp->iReservedLen, iTlvLen, sizeof(ptApp->szReserved));

        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        return FAIL;
    }

    memcpy(ptApp->szReserved+ptApp->iReservedLen, 
           szTlvBuf, iTlvLen);
    ptApp->iReservedLen += iTlvLen;

    return SUCC;
}
