/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�tohost���������ķ�װ����
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision $
 * $Log: package.c,v $
 * Revision 1.3  2013/06/14 02:20:00  fengw
 *
 * 1������Ӧ����MACУ����롣
 *
 * Revision 1.2  2013/06/14 02:03:31  fengw
 *
 * 1������ǩ��������ѯ�����ѽ��ױ���������������
 *
 * Revision 1.1  2012/12/11 07:16:20  linxiang
 * *** empty log message ***
 *
 * ----------------------------------------------------------------
 */

#define _EXTERN_

#include "tohost.h"
#include "def8583.h"

 PF GetFuncPoint(T_App *ptApp, int iFuncType);

/* ----------------------------------------------------------------
 * ��    �ܣ�   ����Ƿ�������
 * ���������
 *            szBuffer:�յ��ĺ�̨���ݰ�
 * ���������
 * �� �� ֵ��-1  ��  0  ��
 * ��      �ߣ�
 * ��      �ڣ�
 * ����˵����
 * �޸���־���޸�����      �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int CheckWhetherHB(char *szBuffer)
{
    /*�ڴ˰��������ļ�鲹�����*/
    return FAIL;
}

/* ----------------------------------------------------------------
 * ��    �ܣ�   ��������
 * ���������
 * ���������
 *            szBuffer:��õ�������
 * �� �� ֵ������������
 * ��      �ߣ�
 * ��      �ڣ�
 * ����˵����
 * �޸���־���޸�����      �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int PackHB(unsigned char *szBuffer)
{
     /*�ڴ˰��������Ĵ���������*/
    return strlen(szBuffer);
}

/* ----------------------------------------------------------------
 * ��    �ܣ�   ���������
 * ���������
 *            ptApp:���״�����ύ�����ݽṹ
 * ���������
 *            szBuffer:��õĽ��������
 * �� �� ֵ���������������
 * ��      �ߣ�
 * ��      �ڣ�
 * ����˵����
 * �޸���־���޸�����      �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int PackageRequest(T_App *ptApp, char* szBuffer)
{
    MsgRule     tMsgRule;
    ISO_data    tData;
    PF          pFuncPack;
    char        szBuf[1024+1];
    char        szTmpBuf[512+1];
    char        szMAC[8+1];
    int         iLen;
    int         iIndex;

    memset(&tMsgRule, 0, sizeof(tMsgRule));

    tMsgRule.iMidType = MSGIDTYPE_BCD;
    tMsgRule.iFieldLenType = FIELDLENTYPE_BCD;
    tMsgRule.ptISO = iso8583_YLPOSP;

    /* ��ʼ�� */
    ClearBit(&tData);

    /* ���ݽ������ͣ������������ */    
    if((pFuncPack = GetFuncPoint(ptApp, PACK_TYPE)) == NULL)
    {
        return FAIL;
    }

    if(pFuncPack(&tMsgRule, ptApp, &tData) != SUCC)
    {
        WriteLog(ERROR, "��������[%d]���������ʧ��!", ptApp->iTransType);

        return FAIL;
    }

    /* �������� */
    memset(szBuf, 0, sizeof(szBuf));
    iLen = IsoToStr(&tMsgRule, &tData, szBuf);

    /* MAC���� */
    if(ptApp->iTransType != LOGIN)
    {
        memset(szMAC, 0, sizeof(szMAC));
        if(CalcMac(szBuf, iLen-8, ptApp, szMAC) != SUCC)
        {
            return FAIL;
        }

        memcpy(szBuf+iLen-8, szMAC, 8);
    }

    /* ����ͷ��� */
    iIndex = 2;

    /* TPDU */
    memcpy(szBuffer+iIndex, "\x60\x00\x00\x00\x00", 5);
    iIndex += 5;    

    /* Ӧ������� */
    szBuffer[iIndex] = 0x60;
    iIndex += 1;

    /* ����汾�� */
    szBuffer[iIndex] = 0x31;
    iIndex += 1;

    /* �ն�״̬������Ҫ�� */
    szBuffer[iIndex] = 0x00;
    iIndex += 1;

    /* �ն�����汾�� */
    memcpy(szBuffer+iIndex, "\x31\x00\x00", 3);
    iIndex += 3;

    /* �����忽�� */
    memcpy(szBuffer+iIndex, szBuf, iLen);
    iIndex += iLen;

    /* ���ĳ��� */
    szBuffer[0] = (iIndex-2) / 256;
    szBuffer[1] = (iIndex-2) % 256;

    return iIndex;
}

/* ----------------------------------------------------------------
 * ��    �ܣ�   �⽻����Ӧ��
 * ���������
 *            szBuffer:��̨���ص����ݰ�
 *            iLength:��̨���ص����ݰ�����
 * ���������
 *            ptApp:���ظ����״��������ݽṹ
 * �� �� ֵ��-1  ʧ�ܣ�  0  �ɹ�
 * ��      �ߣ�
 * ��      �ڣ�
 * ����˵����
 * �޸���־���޸�����      �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int UnpackageRespond(T_App *ptApp, char* szBuffer, int iLength)
{
    MsgRule     tMsgRule;
    ISO_data    tData;
    PF          pFuncUnpack;
    int         iHeadLen=13;
    char        szMAC[8+1];

    memset(&tMsgRule, 0, sizeof(tMsgRule));

    tMsgRule.iMidType = MSGIDTYPE_BCD;
    tMsgRule.iFieldLenType = FIELDLENTYPE_BCD;
    tMsgRule.ptISO = iso8583_YLPOSP;

    /* ��ʼ�� */
    ClearBit(&tData);

    /* ���Ľ�� */
    if(StrToIso(&tMsgRule, szBuffer+iHeadLen, &tData) != SUCC)
    {
        return FAIL;
    }

    /* ������Ϣ���ͺʹ������ȡ�������� */
    if(GetTransType(&tMsgRule, &tData, ptApp) != SUCC)
    {
        return FAIL;
    }

    /* ���ݽ������ͣ����ò������ */    
    if((pFuncUnpack = GetFuncPoint(ptApp, UNPACK_TYPE)) == NULL)
    {
        return FAIL;
    }

    if(pFuncUnpack(&tMsgRule, ptApp, &tData) != SUCC)
    {
        WriteLog(ERROR, "��������[%d]Ӧ���Ĳ��ʧ��!", ptApp->iTransType);

        return FAIL;
    }

    strcpy(ptApp->szRetCode, ptApp->szHostRetCode);

    /* ��֤MAC */
    if(ptApp->iTransType != LOGIN)
    {
        memset(szMAC, 0, sizeof(szMAC));
        if(CalcMac(szBuffer+iHeadLen, iLength-iHeadLen-8, ptApp, szMAC) != SUCC)
        {
            return FAIL;
        }

        if(memcmp(szBuffer+iLength-8, szMAC, 8) != 0)
        {
            WriteLog(ERROR, "MACУ���!Ӧ��MAC:[%s] ����MAC:[%s]", szBuffer+iLength-8, szMAC);
            strcpy(ptApp->szRetCode, ERR_RESP_MAC);

            return SUCC;
        }
    }

    return SUCC;
}

/****************************************************************
** ��    �ܣ����ݽ������ͣ����Ĵ������ͻ�ȡ���Ĵ�����ָ��
** ���������
**        ptApp                 app�ṹָ��
**        iFuncType             ���Ĵ�������
** ���������
**        �� 
** �� �� ֵ��
**        pFunc                 ���Ĵ�����ָ�� 
**        FAIL                  ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2013/06/09
** ����˵����
**
** �޸���־��
****************************************************************/
PF GetFuncPoint(T_App *ptApp, int iFuncType)
{
    int i=0;

    while(1)
    {
        if(gtaPkgProc[i].iTransType == 0)
        {
            /* δ���彻�� */
            strcpy(ptApp->szRetCode, ERR_INVALID_TRANS);

            WriteLog(ERROR, "��������[%d]�������������δ����!", ptApp->iTransType);

            return NULL;
        }

        if(gtaPkgProc[i].iTransType == ptApp->iTransType)
        {
            if(iFuncType == PACK_TYPE)
            {
                return gtaPkgProc[i].pFuncPack;
            }
            else if(iFuncType == UNPACK_TYPE)
            {
                return gtaPkgProc[i].pFuncUnpack;
            }
            else
            {
                /* δ���彻�� */
                strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

                WriteLog(ERROR, "���Ĵ������Ͳ���[%d]δ����!", iFuncType);

                return NULL;
            }
        }

        i++;
    }
}

/****************************************************************
** ��    �ܣ�������Ϣ���ͺʹ������ȡ��������
** ���������
**        ptMsgRule             ���Ĺ���
**        iFuncType             ���Ĵ�������
** ���������
**        ptApp                 app�ṹָ��
** �� �� ֵ��
**        SUCC                  �ɹ�
**        FAIL                  ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2013/06/09
** ����˵����
**
** �޸���־��
****************************************************************/
int GetTransType(MsgRule* ptMsgRule, ISO_data* ptData, T_App* ptApp)
{
    char    szTmpBuf[512+1];
    char    szMsgType[2+1];
    char    szNetCode[3+1];
    int     iRet;

    /* 0�� ��Ϣ���� */
    strcpy(ptApp->szMsgId, ptData->message_id);

    /* 3�� ������ */	
	memset(szTmpBuf, 0, sizeof(szTmpBuf));
	iRet = GetBit(ptMsgRule, ptData, PROC_CODE, szTmpBuf);
	if(iRet == 6)
	{
	    strcpy(ptApp->szProcCode, szTmpBuf);
    }

    /* 60�� ��Ϣ���� ���������Ϣ�� */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    memset(szMsgType, 0, sizeof(szMsgType));
    memset(szNetCode, 0, sizeof(szNetCode));
    iRet = GetBit(ptMsgRule, ptData, FIELD60, szTmpBuf);
    if(iRet > 0)
    {
        memcpy(szMsgType, szTmpBuf, 2);

        if(iRet > 8)
        {
            memcpy(szNetCode, szTmpBuf+8, 3);
        }
    }

    /* �жϽ������� */
    ptApp->iTransType = 0;
    strcpy(ptApp->szTransName, "δ֪����");

    if(memcmp(ptApp->szMsgId, "0810", 4) == 0)
    {
        if(memcmp(szNetCode, "001", 3) == 0 || memcmp(szNetCode, "003", 3) == 0 ||
           memcmp(szNetCode, "004", 3) == 0) 
        {
            ptApp->iTransType = LOGIN;
            strcpy(ptApp->szTransName, "ǩ��");
        }
    }
    else if(memcmp(ptApp->szMsgId, "0210", 4) == 0)
	{
	    if(memcmp(ptApp->szProcCode, "000000", 6) == 0)
        {
            if(memcmp(szMsgType, "22", 3) == 0)
            {
                ptApp->iTransType = PURCHASE;
                strcpy(ptApp->szTransName, "����");
            }
            else if(memcmp(szMsgType, "20", 3) == 0)
            {
                ptApp->iTransType = CONFIRM;
                strcpy(ptApp->szTransName, "��Ȩ���");
            }
        }
	    else if(memcmp(ptApp->szProcCode, "310000", 6) == 0)
        {
			ptApp->iTransType = INQUERY;
		    strcpy(ptApp->szTransName, "����ѯ");
		}else if(memcmp(ptApp->szProcCode, "200000", 6) == 0)
        {
			ptApp->iTransType = PUR_CANCEL;
		    strcpy(ptApp->szTransName, "���ѳ���");
        }
	}else if(memcmp(ptApp->szMsgId,"0410" ,4) == 0)
    {
	    if(memcmp(ptApp->szProcCode, "000000", 6) == 0)
        {
            ptApp->iOldTransType = PURCHASE;
            strcpy(ptApp->szTransName, "���ѳ���");
        }
	    else if(memcmp(ptApp->szProcCode, "200000", 6) == 0)
        {
            /*Ԥ��Ȩ��������ͬ������*/
			ptApp->iOldTransType = PUR_CANCEL;
		    strcpy(ptApp->szTransName, "��������");
		}else if(memcmp(ptApp->szProcCode, "030000", 6) == 0)
        {
			ptApp->iOldTransType = PRE_AUTH;
		    strcpy(ptApp->szTransName, "Ԥ��Ȩ����");
        }
        ptApp->iTransType = AUTO_VOID;

    }else if(memcmp(ptApp->szMsgId,"0230" ,4) == 0)
    {
	    ptApp->iTransType = REFUND;
	    strcpy(ptApp->szTransName, "�˻�");
    }else if(memcmp(ptApp->szMsgId,"0110" ,4) == 0)
    {
        if(memcmp(ptApp->szProcCode, "030000", 6) == 0)
        {
			ptApp->iTransType = PRE_AUTH;
		    strcpy(ptApp->szTransName, "Ԥ��Ȩ");
        }else if(memcmp(ptApp->szProcCode, "200000", 6) == 0)
        {
			ptApp->iTransType = PRE_CANCEL;
		    strcpy(ptApp->szTransName, "Ԥ��Ȩ����");
        }

    }

    if(ptApp->iTransType == 0)
	{
	    WriteLog(ERROR, "��ϢID:[%s] ������:[%s] ��Ϣ����:[%s] ���������Ϣ��:[%s]δ���жϳ���������!",
	             ptApp->szMsgId, ptApp->szProcCode, szMsgType, szNetCode);

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
	}

	return SUCC;
}
