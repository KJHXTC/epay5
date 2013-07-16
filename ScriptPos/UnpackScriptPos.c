/*******************************************************************************
 * Copyright(C)2012��2015 �������������豸���޹�˾
 * ��Ҫ���ݣ�ScriptPosģ�� POS�����Ĳ��
 * �� �� �ˣ�Robin
 * �������ڣ�2012/11/30
 * $Revision: 1.2 $
 * $Log: UnpackScriptPos.c,v $
 * Revision 1.2  2013/06/08 02:06:31  fengw
 *
 * 1�����ļ���ʽ��DOSת��ΪUNIX��
 *
 * Revision 1.1  2013/01/18 08:32:37  fengw
 *
 * 1����ֺ�����
 *
 ******************************************************************************/

#define _EXTERN_

#include "ScriptPos.h"

/*******************************************************************************
 * �������ܣ�������֧���淶����(�ű�POS����)�������������ݽṹ��
 *           ָ����ʹ�ã���ӵ�2����������ݽ�����szReserved�Զ����ֶ��У���Щ
 *           ���ݰ�TLV��ʽ��֯����Ҫ�õ���Щ���ݵ�ģ�鰴TLV��ʽ���н�����TAG����
 *           �������£�
 *           a) TagΪ���ֽ�
 *           b) ��һλ0xDF
 *           c) �ڶ�λ bit8Ϊ1����ʾTAG�к���λ��bit7-bit1��ʾָ���ţ�����9��
 *              ָ���ȡ����Ӧ�ú�Ϊ 0x89 
 *           d) ����λ bit8Ϊ0��bit7-bit1��ʾָ����ִ���������ڶ���ִ�У���Ϊ
 *              0x02
 *           e) ����ڶ���ִ������Ӧ�ú�ʱ�����ݱ���TagΪ \xDF\x89\x02
 * ���������
 *           ptApp      -  �������ݽṹָ��
 *           szInData   -  ���յ�������
 *           iInLen     -  ���յ������ݳ���
 * ���������
 *           ptApp      -  �������ݽṹָ��
 * �� �� ֵ�� 
 *           FAIL       -  ���ʧ��
 *           SUCC       -  ����ɹ�
 *           INVALID_PACK - �Ƿ�����
 * ��    �ߣ�Robin
 * ��    �ڣ�2012/12/11
 * �޶���־��
 *
 ******************************************************************************/
int UnpackScriptPos(T_App *ptApp, char *szInData, int iInLen)
{
    int     i;
    int     iIndex;                     /* ���Ĳ������ֵ */
    char    szTmpBuf[1024+1];           /* ��ʱ���� */
    int     iMsgLen;                    /* ��Ϣ���ݳ��� */
    int     iMsgIndex;                  /* ��Ϣ���ݿ�ʼ����ֵ */
    int     iCmdNum;                    /* ���̴������ */
    int     iCmdLen;                    /* ���̴��볤�� */
    char    szCmdData[512+1];           /* ���̴������� */
    int     iDataLen;                   /* ��Ч���ݳ��� */
    int     iDataIndex;                 /* ��Ч���ݿ�ʼ����ֵ */
    char    szAuthCode[4];              /* ������֤�� */

    /* ���Ĳ�� */
    iIndex = 0;

    /* TPDU */
    /* ����60 */
    iIndex += 1;

    /* Ŀ�ĵ�ַ */
    memcpy(ptApp->szTargetTpdu, szInData+iIndex, 2);
    iIndex += 2;
#ifdef DEBUG
    WriteLog(TRACE, "TPDU Ŀ�ĵ�ַ:[%02x %02x]",
             ptApp->szTargetTpdu[0], ptApp->szTargetTpdu[1]);
#endif

    /* Դ��ַ */
    memcpy(ptApp->szSourceTpdu, szInData+iIndex, 2);
    iIndex += 2;
#ifdef DEBUG
    WriteLog(TRACE, "TPDU Դ��ַ:[%02x %02x]",
             ptApp->szSourceTpdu[0], ptApp->szSourceTpdu[1]);
#endif

    /* ���͵绰���� */
    if(memcmp(szInData+iIndex, "\x4C\x52\x49\x00\x1C", 5) == 0)
    {
        /* �绰�����ʶͷ */
        iIndex += 5;

        /* ���к��� */
        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        BcdToAsc(szInData+iIndex, 16, LEFT_ALIGN, (uchar*)szTmpBuf);

        for(i=0;i<16;i++)
        {
            if(szTmpBuf[i] != '0')
            {
                break;
            }
        }
        memcpy(ptApp->szCallingTel, szTmpBuf+i, 16-i);
        iIndex += 8;
#ifdef DEBUG
        WriteLog(TRACE, "���к���:[%s]", ptApp->szCallingTel);
#endif

        /* ���к��� */        
        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        BcdToAsc(szInData+iIndex, 16, LEFT_ALIGN, (uchar*)szTmpBuf);

        for(i=0;i<16;i++)
        {
            if(szTmpBuf[i] != '0')
            {
                break;
            }
        }
        memcpy(ptApp->szCalledTelByNac, szTmpBuf+i, 16-i);
        iIndex += 8;
#ifdef DEBUG
        WriteLog(TRACE, "���к���:[%s]", ptApp->szCalledTelByNac);
#endif

        /* �绰�����ʶβ */
        iIndex += 12;
    }

    /* ����ͬ����� */
    iIndex += 1;

    /* �������������� */
    iIndex += 2;

    /* �������� */
    iIndex += 1;

    /* �������ر�� */
    ptApp->iFskId = (uchar)szInData[iIndex];
    iIndex ++;
#ifdef DEBUG
    WriteLog(TRACE, "�������ر��:[%d]", ptApp->iFskId);
#endif

    /* ��������ģ��� */
    ptApp->iModuleId = (uchar)szInData[iIndex];
    iIndex ++;
#ifdef DEBUG
    WriteLog(TRACE, "��������ģ���:[%d]", ptApp->iModuleId);
#endif

    /* ��������ͨ���� */
    ptApp->iChannelId = (uchar)szInData[iIndex];
    iIndex ++;
#ifdef DEBUG
    WriteLog(TRACE, "��������ͨ����:[%d]", ptApp->iChannelId);
#endif

    /******************************��Ϣ�������ݲ��******************************/
    /* ��Ϣ���ݳ��� */
    iMsgLen = ((uchar)szInData[iIndex])*256 + (uchar)szInData[iIndex+1];
    iIndex += 2;

    /* �۳�MAC���� */
    iMsgLen = iMsgLen - 8;
#ifdef DEBUG
    WriteLog(TRACE, "��Ϣ���ݳ���:[%d]", iMsgLen);
#endif

    /* �ж���Ϣ���ݳ����Ƿ񳬳� */
    if(iMsgLen <= 0 || iMsgLen > 1024 || iMsgLen > (iInLen-iIndex-8))
	{
		WriteLog(ERROR, "��Ϣ���ݳ���[%d]�Ƿ�!ʵ����Ϣ���ݳ���[%d]",
		         iMsgLen, iInLen-iIndex-8);

		return INVALID_PACK;
	}

    /* ��Ϣ���� */
    /* ��¼��Ϣ���ݿ�ʼ����ֵ������MAC���� */
    iMsgIndex = iIndex;

    /* �������� */
#ifdef DEBUG
    WriteLog(TRACE, "��������:[%02x]", szInData[iIndex]);
#endif
    iIndex += 1;

    /* ������־ */
#ifdef DEBUG
    WriteLog(TRACE, "������־:[%02x]", szInData[iIndex]);
#endif
    iIndex += 1; 

    /* ���İ汾 */
    memcpy(ptApp->szMsgVer, szInData+iIndex, 2);    
    iIndex += 2;
#ifdef DEBUG
    WriteLog(TRACE, "���İ汾:[%02x%02x]", ptApp->szMsgVer[0], ptApp->szMsgVer[1]);
#endif

    /* Ӧ�ýű��汾 */
    memcpy(ptApp->szAppVer, szInData+iIndex, 4);    
    iIndex += 4;
#ifdef DEBUG
    WriteLog(TRACE, "Ӧ�ýű��汾:[%02x%02x%02x%02x]",
             ptApp->szAppVer[0], ptApp->szAppVer[1],
             ptApp->szAppVer[2], ptApp->szAppVer[3]);
#endif

    /* �ն˳���汾 */
    BcdToAsc(szInData+iIndex, 8, LEFT_ALIGN, ptApp->szPosCodeVer);
    iIndex += 4;
#ifdef DEBUG
    WriteLog(TRACE, "�ն˳���汾:[%s]", ptApp->szPosCodeVer);
#endif

    /* �ն����� */
    memcpy(ptApp->szPosType, szInData+iIndex, 10);
    iIndex += 10;
#ifdef DEBUG
    WriteLog(TRACE, "�ն�����:[%s]", ptApp->szPosType);
#endif

    /* ������֤�� */
    memcpy(szAuthCode, szInData+iIndex, 4);
    iIndex += 4;
#ifdef DEBUG
    WriteLog(TRACE, "������֤��:[%02x%02x%02x%02x]",
             szAuthCode[0] & 0xFF, szAuthCode[1] & 0xFF,
             szAuthCode[2] & 0xFF, szAuthCode[3] & 0xFF);
#endif

    /* POS���ͱ��к��� */
    memcpy(ptApp->szCalledTelByTerm, szInData+iIndex, 15);
    iIndex += 15;
    DelTailSpace(ptApp->szCalledTelByTerm);
#ifdef DEBUG
    WriteLog(TRACE, "POS���ͱ��к���:[%s]", ptApp->szCalledTelByTerm);
#endif

    /* ������ʾ��־ */
#ifdef DEBUG
    WriteLog(TRACE, "������ʾ��־:[%c]", szInData[iIndex]);
#endif
    iIndex += 1;    

    /* ��ȫģ��� */
    memcpy(ptApp->szPsamNo, szInData+iIndex, 16);
    iIndex += 16;
#ifdef DEBUG
    WriteLog(TRACE, "��ȫģ���:[%s]", ptApp->szPsamNo);
#endif

    /* POS��ˮ�� */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    BcdToAsc(szInData+iIndex, 6, LEFT_ALIGN, (uchar*)szTmpBuf);
    ptApp->lPosTrace = atol(szTmpBuf);
    iIndex += 3;
#ifdef DEBUG
    WriteLog(TRACE, "POS��ˮ��:[%ld]", ptApp->lPosTrace);
#endif

    /* ���״��� */
    BcdToAsc(szInData+iIndex, 8, LEFT_ALIGN, ptApp->szTransCode);
    iIndex += 4;
#ifdef DEBUG
    WriteLog(TRACE, "���״���:[%s]", ptApp->szTransCode);
#endif

    /* ����szTransCode��ȡ������Ϣ */
    if(GetTranInfo(ptApp) != SUCC)
    {
        WriteLog(ERROR, "��ȡ������[%s]��Ӧ���׶���ʧ��!", ptApp->szTransCode);

        return FAIL;
    }

    /* trans_def���׶������trans_code��ʶ�ն˽��ף�trans_type��ʶƽ̨���ס���Լ��trans_type��4λ��ͬ��
       ��ƽ̨���ԣ���Щ���׶�Ӧƽ̨ͬһ�����ף����Բ�����ȫ��ͬ�Ľ������̡����ڴ�trans_type��ģ10000��
       ����������ƽ̨������ģ�鶼ֻ��Ҫ��һ�����״���*/
    ptApp->iTransType = ptApp->iTransType % 10000;

    /* �����ط����� */
    if(szInData[iMsgIndex] == 0x03)
    {
        ptApp->iOldTransType = ptApp->iTransType;

        ptApp->iTransType = RESEND;
    }

    /* ��ȡ�ն���Ϣ������ն��Ƿ���Ҫ���� */
    if(ChkTermInfo(ptApp) != SUCC)
    {
        return FAIL;
    }

    /******************************���̴������ݲ��******************************/
    /* ���̴������ */
    iCmdNum = (uchar)szInData[iIndex];    
    iIndex ++;
#ifdef DEBUG
    WriteLog(TRACE, "���̴������:[%d]", iCmdNum);
#endif

    /* �������̴��볤�� */
    iCmdLen = 0;

    for(i=0;i<iCmdNum;i++)
    {
        iCmdLen += CalcCmdBytes((uchar)szInData[iIndex+iCmdLen]);
    }
#ifdef DEBUG
    WriteLog(TRACE, "���̴��볤��:[%d]", iCmdLen);
#endif

    /* ���̴��� */
    memset(szCmdData, 0, sizeof(szCmdData));
    memcpy(szCmdData, szInData+iIndex, iCmdLen);    
    iIndex += iCmdLen;

    /* ��Ч���ݳ��� */
    iDataLen = ((uchar)szInData[iIndex])*256 + (uchar)szInData[iIndex+1];
    iIndex += 2;

    /* �ж���Ч���ݳ����Ƿ񳬳� */
	if(iDataLen > 1024 || iDataLen > (iInLen-iIndex))
	{
        WriteLog(ERROR, "��Ч���ݳ���[%d]�Ƿ�!ʵ����Ϣ���ݳ���[%d]",
                 iDataLen, iInLen-iIndex);

		return INVALID_PACK;
	}

    /******************************ָ�����ݽ���******************************/
    /* ��¼��Ч���ݿ�ʼ����ֵ */
    iDataIndex = iIndex;
    
    if(PosOutput(ptApp, iCmdNum, szCmdData, iCmdLen, szInData+iDataIndex, iDataLen) != SUCC)
    {
		return INVALID_PACK;
    }

    /* ����ǩ����������ԡ���Աǩ���������⣬����Ҫ����MACУ�� */
    if((ptApp->iTransType != LOGIN &&
        ptApp->iTransType != ECHO_TEST &&
        ptApp->iTransType != DOWN_ALL_FUNCTION &&
        ptApp->iTransType != DOWN_ALL_MENU &&
        ptApp->iTransType != DOWN_ALL_PRINT &&
        ptApp->iTransType != DOWN_ALL_TERM &&
        ptApp->iTransType != DOWN_ALL_PSAM &&
        ptApp->iTransType != DOWN_ALL_ERROR &&
        ptApp->iTransType != TEST_DISP_OPER_INFO &&
        ptApp->iTransType != TEST_PRINT &&
        ptApp->iTransType != DOWN_ALL_OPERATION &&
        ptApp->iTransType != CENDOWN_ALL_OPERATION &&
        ptApp->iTransType != REGISTER &&
        ptApp->iTransType != TERM_REGISTER &&
        ptApp->iTransType != AUTO_VOID &&
        ptApp->iTransType != OPER_LOGIN) && giMacChk == 1)
    {
        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        if(HsmCalcMac(ptApp, XOR_CALC_MAC, ptApp->szMacKey, 
                      szInData+iMsgIndex, iMsgLen, szTmpBuf) != SUCC)
        {
            WriteLog(ERROR, "���㱨��MAC����!");

            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

            return FAIL;
        }

        if(memcmp(ptApp->szMac, szTmpBuf, 8) != 0) 
        {
            WriteLog(ERROR, "����MAC����!");

            strcpy(ptApp->szRetCode, ERR_MAC);
#ifdef DEBUG
            WriteLog(TRACE, "��������MAC:[%02x%02x%02x%02x] ����MAC:[%02x%02x%02x%02x]",
            ptApp->szMac[0] & 0xFF, ptApp->szMac[1] & 0xFF,
            ptApp->szMac[2] & 0xFF, ptApp->szMac[3] & 0xFF,
            szTmpBuf[0] & 0xFF, szTmpBuf[1] & 0xFF,
            szTmpBuf[2] & 0xFF, szTmpBuf[3] & 0xFF);
#endif
            return FAIL;
        }
    }

    WriteAppStru(ptApp, "Read from ePos");

    /* У��������֤�� */
    if(CheckAuthCode(szAuthCode, ptApp->szPsamNo) != SUCC)
    {     
        WriteLog(ERROR, "��֤������֤��ʧ��!");

        strcpy(ptApp->szRetCode, ERR_AUTHCODE);

        return FAIL; 
    }

    return SUCC;
}
