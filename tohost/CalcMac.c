/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨����POSͨѶģ�� ����MAC����
** �� �� �ˣ����
** �������ڣ�2013-06-09
**
** $Revision: 1.1 $
** $Log: CalcMac.c,v $
** Revision 1.1  2013/06/14 02:05:29  fengw
**
** 1������MAC���㺯����
**
*******************************************************************/

#define _EXTERN_

#include "tohost.h"

/****************************************************************
** ��    �ܣ�MAC����
** ���������
**        szData          ����MAC���㱨��
**        iLen            ���ĳ���
**        ptApp           app�ṹָ��
** ���������
**        szMAC           ����MAC
** �� �� ֵ��
**        SUCC            ����ɹ�
**        FAIL            ����ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2013/06/09
** ����˵����
**
** �޸���־��
****************************************************************/
int CalcMac(char* szData, int iLen, T_App* ptApp, char* szMAC)
{
    char    szMacKey[32+1];
    char    szMAK[16+1];
    char    szTmpBuf1[8+1];
    char    szTmpBuf2[16+1];
    int     i;

    /* ��ȡ��̨MACKEY */
    memset(szMacKey, 0, sizeof(szMacKey));
    if(GetHostTermKey(ptApp, YLPOSP, MAC_KEY, szMacKey) != SUCC)
    {
        return FAIL;
    }
    AscToBcd(szMacKey, 32, 0, szMAK);

    /* ���Ĵ��� */
    memset(szTmpBuf1, 0, sizeof(szTmpBuf1));
    memset(szTmpBuf2, 0, sizeof(szTmpBuf2));

    /* ÿ8�ֽ�ѭ������չ�� */
    XOR(szData, iLen, szTmpBuf1);
    BcdToAsc(szTmpBuf1, 16, 0, szTmpBuf2);

    /* ȡǰ8���ֽڼ��� */
    if(HsmCalcMac(ptApp, X99_CALC_MAC, szMAK, szTmpBuf2, 8, szTmpBuf1) != SUCC)
    {
        WriteLog(ERROR, "���㱨��MAC����!");

        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        return FAIL;
    }

    /* ���ܽ�����8���ֽ���� */
    for(i=0;i<8;i++)
    {
        szTmpBuf1[i] = szTmpBuf1[i] ^ szTmpBuf2[8+i];
    }

    /* ��������� */
    if(HsmCalcMac(ptApp, X99_CALC_MAC, szMAK, szTmpBuf1, 8, szTmpBuf1) != SUCC)
    {
        WriteLog(ERROR, "���㱨��MAC����!");

        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        return FAIL;
    }

    /* ���ܽ��չ�� */
    BcdToAsc(szTmpBuf1, 16, 0, szTmpBuf2);

    /* ȡǰ8���ֽ���ΪMAC */
    memcpy(szMAC, szTmpBuf2, 8);

	return SUCC;
}