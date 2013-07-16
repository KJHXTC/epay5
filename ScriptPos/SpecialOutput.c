/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨epay������ �����Զ���ָ���������
** �� �� �ˣ�fengwei
** �������ڣ�2013/03/06
**
** $Revision: 1.2 $
** $Log: SpecialOutput.c,v $
** Revision 1.2  2013/03/28 07:59:40  fengw
**
** 1���޸��Զ���ָ��06�����ݽ�����
**
** Revision 1.1  2013/03/11 07:12:49  fengw
**
** 1�������Զ���ָ�����롢������ݴ���
**
*******************************************************************/

#define _EXTERN_

#include "ScriptPos.h"

/****************************************************************
** ��    �ܣ������Զ���ָ���������
** ���������
**        ptApp                     app�ṹָ��
**        szCmdData                 ָ������
**        szData                    ��Ч����
** ���������
**        ��
** �� �� ֵ��
**        >0                        ���ݳ���
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2013/03/06
** ����˵����
**
** �޸���־��
****************************************************************/
int SpecialOutput(T_App *ptApp, char *szCmdData, char *szData)
{
    uchar   uCmd;                       /* ָ��� */
    int     iDataIndex;                 /* ��Ч�������� */
    char    szTmpBuf[1024+1];           /* ��ʱ���� */
    int     iTmp;                       /* ��ʱ���� */

    iDataIndex = 0;
    uCmd = szCmdData[SPECIAL_CMD_LEN-1];

    switch(uCmd)
    {
        /* EMV�����汾�� */
        case 0x01:
            memcpy(ptApp->szEmvParaVer, szData+iDataIndex, 12);
            iDataIndex += 12;
#ifdef DEBUG
            WriteLog(TRACE, "EMV�����汾��:[%s]", ptApp->szEmvParaVer);
#endif

            break;
        /* ����EMV���� */
        case 0x02:
            /* EMV�����汾�� */
            memcpy(ptApp->szEmvParaVer, szData+iDataIndex, 12);
            iDataIndex += 12;
#ifdef DEBUG
            WriteLog(TRACE, "EMV�����汾��:[%s]", ptApp->szEmvParaVer);
#endif

            /* ������ */
            memcpy(ptApp->szHostRetCode, szData+iDataIndex, 2);
            iDataIndex += 2;
#ifdef DEBUG
            WriteLog(TRACE, "������:[%s]", ptApp->szHostRetCode);
#endif

            break;
        /* ��ȡ�ն˵�ǰ��Կ�汾�� */
        case 0x03:
            /* EMV��Կ�汾�� */
            memcpy(ptApp->szEmvKeyVer, szData+iDataIndex, 8);
            iDataIndex += 8;
#ifdef DEBUG
            WriteLog(TRACE, "EMV��Կ�汾��:[%s]", ptApp->szEmvKeyVer);
#endif

            break;
        /* ����EMV��Կ */
        case 0x04:
            /* EMV�����汾�� */
            memcpy(ptApp->szEmvKeyVer, szData+iDataIndex, 8);
            iDataIndex += 8;
#ifdef DEBUG
            WriteLog(TRACE, "EMV��Կ�汾��:[%s]", ptApp->szEmvKeyVer);
#endif

            /* ������ */
            memcpy(ptApp->szHostRetCode, szData+iDataIndex, 2);
            iDataIndex += 2;
#ifdef DEBUG
            WriteLog(TRACE, "������:[%s]", ptApp->szHostRetCode);
#endif

            break;
        /* EMV�������̴��� */
        case 0x05:
            /* ���׽�� */
            memset(szTmpBuf, 0, sizeof(szTmpBuf));
            BcdToAsc((uchar*)(szData+iDataIndex), 12, LEFT_ALIGN, szTmpBuf);

            memcpy(ptApp->szAmount, szTmpBuf, 12);
            iDataIndex += 6;
#ifdef DEBUG
            WriteLog(TRACE, "���׽��:[%s]", ptApp->szAmount);
#endif

            /* �������� */
            memcpy(ptApp->szPasswd, szData+iDataIndex, 8);
            iDataIndex += 8;

            /* ����� */
            memset(szTmpBuf, 0, sizeof(szTmpBuf));
            BcdToAsc((uchar*)(szData+iDataIndex), 4, LEFT_ALIGN, szTmpBuf);
            iDataIndex += 2;
#ifdef DEBUG
            WriteLog(TRACE, "�����:[%s]", ptApp->szEmvCardNo);
#endif

            /* �ֿ����������� */
            iTmp = (uchar)(szData[iDataIndex]);	
            iDataIndex += 1;

            /* �ֿ������� */
            if(iTmp > 0)
            {
                memcpy(ptApp->szHolderName, szData+iDataIndex, iTmp>40?40:iTmp);
                iDataIndex += iTmp;
            }
#ifdef DEBUG
            WriteLog(TRACE, "�ֿ�������:[%s]", ptApp->szHolderName);
#endif

            /* �ŵ���Ϣ */
            if((iTmp = GetTrack(ptApp, szData+iDataIndex)) == FAIL)
            {
                return FAIL;
            }
            iDataIndex += iTmp;

            /* ���ݴŵ���Ϣ��ȡ���� */
            if(GetCardType(ptApp) != SUCC)
            {
                WriteLog(ERROR, "���ݴŵ���Ϣ��ȡ����ʧ��!");

                return FAIL;
            }

            /* EMV���ݳ��� */
            ptApp->iEmvDataLen = (uchar)(szData[iDataIndex]);	
    	    iDataIndex += 1;

            /* EMV���� */
            if(ptApp->iEmvDataLen > 0)
            {
                memcpy(ptApp->szEmvData, szData+iDataIndex, ptApp->iEmvDataLen);
                iDataIndex += ptApp->iEmvDataLen;
            }

            break;
        /* EMV�������ݴ��� */
        case 0x06:
            /* ���׽�� */
            memcpy(ptApp->szHostRetCode, szData+iDataIndex, 2);
            iDataIndex += 2;

            /* �������ݸ���ʵ��������� */
            /* ԭ�������� */
            iDataIndex += 4;

            /* ԭ������ˮ�� */
            memset(szTmpBuf, 0, sizeof(szTmpBuf));
            BcdToAsc(szData+iDataIndex, 6, 0, szTmpBuf);
            iDataIndex += 3;
            ptApp->lOldPosTrace = atol(szTmpBuf);

            /* EMV֤�鳤�� */
            ptApp->iEmvTcLen  = (uchar)(szData[iDataIndex]);
    		iDataIndex += 1;
    
            /* EMV֤�� */
            if(ptApp->iEmvTcLen > 0)
            {
                memcpy(ptApp->szEmvTc, szData+iDataIndex, ptApp->iEmvTcLen);
            }
            iDataIndex += ptApp->iEmvTcLen;
    
            /* EMV�ű����� */
            ptApp->iEmvScriptLen  = (uchar)(szData[iDataIndex]);
    		iDataIndex += 1;
    
            /* EMV�ű� */
            if(ptApp->iEmvScriptLen > 0)
            {
                memcpy(ptApp->szEmvScript, szData+iDataIndex, ptApp->iEmvScriptLen);
            }
            iDataIndex += ptApp->iEmvScriptLen;
            
            break;
        default:
            WriteLog(ERROR, "�Ƿ��Զ���ָ��[%d]", uCmd);

            return FAIL;
    }

    return iDataIndex;
}