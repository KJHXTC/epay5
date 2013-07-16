/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨epay������ �����Զ���ָ����������
** �� �� �ˣ�fengwei
** �������ڣ�2013/03/06
**
** $Revision: 1.1 $
** $Log: SpecialInput.c,v $
** Revision 1.1  2013/03/11 07:12:49  fengw
**
** 1�������Զ���ָ�����롢������ݴ���
**
*******************************************************************/

#define _EXTERN_

#include "ScriptPos.h"

/****************************************************************
** ��    �ܣ������Զ���ָ����������
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
int SpecialInput(T_App *ptApp, char *szCmdData, char *szData)
{
    uchar   uCmd;                       /* ָ��� */
    int     iDataLen;                   /* ��Ч�������� */

    iDataLen = 0;
    uCmd = szCmdData[SPECIAL_CMD_LEN-1];

    switch(uCmd)
    {
        /* EMV�����汾�� */
        case 0x01:
            break;
        /* ����EMV���� */
        case 0x02:
            /* ��λ���� */
            szData[iDataLen] = (12 + ptApp->iEmvParaLen)/256;
            iDataLen += 1;

            szData[iDataLen] = (12 + ptApp->iEmvParaLen)%256;
            iDataLen += 1;

            /* EMV�����汾�� */
            memcpy(szData+iDataLen, ptApp->szEmvParaVer, 12);
            iDataLen += 12;

            /* EMV���� */
            if(ptApp->iEmvParaLen > 0)
            {
                memcpy(szData+iDataLen, ptApp->szEmvPara, ptApp->iEmvParaLen);
                iDataLen +=  ptApp->iEmvParaLen;
            }

            break;
        /* ��ȡ�ն˵�ǰ��Կ�汾�� */
        case 0x03:
            break;
        /* ����EMV��Կ */
        case 0x04:
            /* ��λ���� */
            szData[iDataLen] = (8 + ptApp->iEmvKeyLen)/256;
            iDataLen += 1;
        
            szData[iDataLen] = (8 + ptApp->iEmvKeyLen)%256;
            iDataLen += 1;

            /* EMV��Կ�汾�� */
            memcpy(szData+iDataLen, ptApp->szEmvKeyVer, 8);
            iDataLen += 8;

            /* EMV��Կ */
            if(ptApp->iEmvKeyLen > 0)
            {
                memcpy(szData+iDataLen, ptApp->szEmvKey, ptApp->iEmvKeyLen);
                iDataLen += ptApp->iEmvKeyLen;
            }

            break;
        /* EMV�������̴��� */
        case 0x05:
            break;
        /* EMV�������ݴ��� */
        case 0x06:
            /* EMV���ݳ��� */
            szData[iDataLen] = ptApp->iEmvDataLen;
            iDataLen += 1;

            /* EMV���� */
            if(ptApp->iEmvDataLen > 0)
            {
                memcpy(szData+iDataLen, ptApp->szEmvData, ptApp->iEmvDataLen);
                iDataLen += ptApp->iEmvDataLen;
            }

            break;
        default:
            WriteLog(ERROR, "�Ƿ��Զ���ָ��[%d]", uCmd);

            return FAIL;
    }

    return iDataLen;
}