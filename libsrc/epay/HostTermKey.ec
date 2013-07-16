/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨epay������ ��̨�ն���Կ������
** �� �� �ˣ����
** �������ڣ�2013-06-13
**
** $Revision: 1.1 $
** $Log: HostTermKey.ec,v $
** Revision 1.1  2013/06/14 02:23:30  fengw
**
** 1�����Ӻ�̨��Կ��ѯ�����º�����
**
*******************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "app.h"
#include "user.h"
#include "dbtool.h"
#include "errcode.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
    int     iHostNo;
    char    szShopNo[15+1];
    char    szPosNo[15+1];
    char    szTermKey[32+1];
    char    szPinKey[32+1];
    char    szMacKey[32+1];
    char    szMagKey[32+1];
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ���ȡ������Կ��Ϣ
** ���������
**        ptApp           app�ṹָ��
**        iHost           ������
** ���������
**        szTMK           �ն�����Կ
**        szPinKey        PinKey
**        szMacKey        MacKey
**        szMagKey        MagKey
** �� �� ֵ��
**        SUCC            ����ɹ�
**        FAIL            ����ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2013/06/13
** ����˵����
**
** �޸���־��
****************************************************************/
int GetHostTermKey(T_App* ptApp, int iHost, int iKeyType, char* szKey)
{
    memset(szShopNo, 0, sizeof(szShopNo));
    memset(szPosNo, 0, sizeof(szPosNo));

    iHostNo = iHost;
    strcpy(szShopNo, ptApp->szShopNo);
    strcpy(szPosNo, ptApp->szPosNo);

    memset(szTermKey, 0, sizeof(szTermKey));
    memset(szPinKey, 0, sizeof(szPinKey));
    memset(szMacKey, 0, sizeof(szMacKey));
    memset(szMagKey, 0, sizeof(szMagKey));

    EXEC SQL
        SELECT
            NVL(MASTER_KEY, ' '), NVL(PIN_KEY, ' '), NVL(MAC_KEY, ' '), NVL(MAG_KEY, ' ')
        INTO
            :szTermKey, :szPinKey, :szMacKey, :szMagKey
        FROM host_term_key
        WHERE host_no = :iHostNo AND shop_no = :szShopNo AND pos_no = :szPosNo;
    if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "��ѯ ������:[%d] �̻���:[%s] �ն˺�:[%s]��Կ��Ϣʧ��!SQLCODE=%d SQLERR=%s",
                 iHostNo, szShopNo, szPosNo, SQLCODE, SQLERR); 

        return FAIL;
    }

    switch(iKeyType)
    {
        case TERM_KEY:
            strcpy(szKey, szTermKey);
            break;
        case PIN_KEY:
            strcpy(szKey, szPinKey);
            break;
        case MAC_KEY:
            strcpy(szKey, szMacKey);
            break;
        case MAG_KEY:
            strcpy(szKey, szMagKey);
            break;
        default:
            WriteLog(ERROR, "��Կ����:[%d]δ����!", iKeyType);
            return FAIL;
    }

    return SUCC;
}

/****************************************************************
** ��    �ܣ���������������Կ
** ���������
**        ptApp           app�ṹָ��
**        iHost           ������
**        szPinKey        PinKey
**        szMacKey        MacKey
**        szMagKey        MagKey
** ���������
**        ��
** �� �� ֵ��
**        SUCC            ����ɹ�
**        FAIL            ����ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2013/06/13
** ����˵����
**
** �޸���־��
****************************************************************/
int UpdHostTermKey(T_App* ptApp, int iHost, char* szPIK,
                   char* szMAK, char* szMGK)
{
    memset(szShopNo, 0, sizeof(szShopNo));
    memset(szPosNo, 0, sizeof(szPosNo));
    memset(szPinKey, 0, sizeof(szPinKey));
    memset(szMacKey, 0, sizeof(szMacKey));
    memset(szMagKey, 0, sizeof(szMagKey));

    iHostNo = iHost;
    strcpy(szShopNo, ptApp->szShopNo);
    strcpy(szPosNo, ptApp->szPosNo);
    strcpy(szPinKey, szPIK);
    strcpy(szMacKey, szMAK);
    strcpy(szMagKey, szMGK);

	EXEC SQL 
	    UPDATE host_term_key 
        SET pin_key = :szPinKey, mac_key = :szMacKey, mag_key = :szMagKey
        WHERE host_no = :iHostNo AND shop_no = :szShopNo AND pos_no = :szPosNo;
	if(SQLCODE)
	{
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "���� ������:[%d] �̻���:[%s] �ն˺�:[%s]��Կ��Ϣʧ��!SQLCODE=%d SQLERR=%s",
                 iHostNo, szShopNo, szPosNo, SQLCODE, SQLERR); 

		RollbackTran();

		return FAIL;
	}

	CommitTran();

	return SUCC;
}