/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� ǩ������
** �� �� �ˣ����
** �������ڣ�2013-06-13
**
** $Revision: 1.1 $
** $Log: Login.ec,v $
** Revision 1.1  2013/06/14 02:33:14  fengw
**
** 1������ǩ�����ס�
**
*******************************************************************/

#define _EXTERN_

#include "finatran.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ�����Ԥ����
** ���������
**        ptApp           app�ṹ
** ���������
**        ptApp           app�ṹ
** �� �� ֵ��
**        SUCC            ����ɹ�
**        FAIL            ����ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/09
** ����˵����
**
** �޸���־��
****************************************************************/
int LoginPreTreat(T_App *ptApp)
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szPsamNo[16+1];
        long    lPosTrace;
        int     iKeyIndex;
        char    szTMK[32+1];
        char    szPinKey[32+1];
        char    szMacKey[32+1];
        char    szMagKey[32+1];
    EXEC SQL END DECLARE SECTION;

    char    szTmpBuf[512+1];
    char    szKeyData[256+1];
    int     iIndex;
    int     iCount;
    int     i;

    /* ȡPOS��ǰ��ˮ�ţ��Ա��ն˸��µ�ǰ��ˮ�� */
    memset(szPsamNo, 0, sizeof(szPsamNo));
    strcpy(szPsamNo, ptApp->szPsamNo);

    EXEC SQL
        SELECT cur_trace INTO :lPosTrace
        FROM terminal
        WHERE psam_no = :szPsamNo;
    if(SQLCODE)
    {
        WriteLog(ERROR, "��ѯ�ն� ��ȫģ���[%s] ��ǰ��ˮʧ��!SQLCODE=%d SQLERR=%s",
                 szPsamNo, SQLCODE, SQLERR);

        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        return FAIL;
    }

    ptApp->lPosTrace = lPosTrace;

    /* ȡ�ն�����Կ���� */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    memcpy(szTmpBuf, ptApp->szPsamNo+8, 8);
    iKeyIndex = atol(szTmpBuf);

    memset(szTMK, 0, sizeof(szTMK));

    EXEC SQL
        SELECT master_key_lmk INTO :szTMK
        FROM pos_key 
        WHERE key_index = :iKeyIndex;
    if(SQLCODE)
    {
        WriteLog(ERROR, "��ѯ��Կ����[%d]TMK����ʧ��!SQLCODE=%d SQLERR=%s",
                 iKeyIndex, SQLCODE, SQLERR);

        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        return FAIL;
    }

    /* ���ܻ�������ɹ�����Կ */
    memset(szKeyData, 0, sizeof(szKeyData));
    memcpy(szKeyData, szTMK, 32);

    if(HsmGetWorkKey(ptApp, szKeyData) != SUCC)
    {
        WriteLog(ERROR, "���ɹ�����Կʧ��!");

        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        return FAIL;
    }

    /* ������Կ���ܵĹ�����Կ���ı��浽���ݿ� */
    memset(szPinKey, 0, sizeof(szPinKey));
    memset(szMacKey, 0, sizeof(szMacKey));
    memset(szMagKey, 0, sizeof(szMagKey));

    memcpy(szPinKey, szKeyData, 32);
    memcpy(szMacKey, szKeyData+80, 32);
    memcpy(szMagKey, szKeyData+160, 32);

    EXEC SQL
        UPDATE pos_key 
        SET pin_key = :szPinKey, mac_key = :szMacKey,
            mag_key = :szMagKey
        WHERE key_index = :iKeyIndex;
    if(SQLCODE)
    {
        WriteLog(ERROR, "������Կ����[%d]������Կ����ʧ��!SQLCODE=%d SQLERR=%s",
                 iKeyIndex, SQLCODE, SQLERR);

        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        RollbackTran();

        return FAIL;
    }

    CommitTran();

    /* �ն�����Կ���ܵĹ�����Կ���ķ��ظ��ն� */
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    iCount = 0;
    iIndex = 0;

    for(i=8;i<=14;i++)
    {
        switch(i)
        {
            case 8:
                /* ��ȫģ���״̬ */
                szTmpBuf[iIndex] = i;
                iIndex += 1;
            
                /* ���ݳ��� */
                szTmpBuf[iIndex] = 1;
                iIndex += 1;
            
                /* ���� */
                szTmpBuf[iIndex] = '0';
                iIndex += 1;

                iCount += 1;

                break;
            case 9:
            case 10:
            case 14:
                /* ���� */
                break;
            case 11:
            case 12:
            case 13:
                /* ������Կ */
                /* ��Կ���� */
                szTmpBuf[iIndex] = i;
                iIndex += 1;

                /* ��Կ���� 16�ֽ�����+4�ֽ���ԿУ��ֵ */
                szTmpBuf[iIndex] = 20;
                iIndex += 1;

                /* ��Կ���� + У��ֵ */
                AscToBcd((uchar *)(szKeyData+32+(i-11)*80), 40, 0 ,(uchar *)(szTmpBuf+iIndex));
                iIndex += 20;

                iCount += 1;

                break;
            default:
                break;
        }
    }

    ptApp->szReserved[0] = iCount;
    memcpy(ptApp->szReserved+1, szTmpBuf, iIndex);
    ptApp->iReservedLen = iIndex+1;

    strcpy(ptApp->szRetCode, TRANS_SUCC);

    return SUCC;
}

/****************************************************************
** ��    �ܣ����׺���
** ���������
**        ptApp           app�ṹ
** ���������
**        ptApp           app�ṹ
** �� �� ֵ��
**        SUCC            ����ɹ�
**        FAIL            ����ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/09
** ����˵����
**
** �޸���־��
****************************************************************/
int LoginPostTreat(T_App *ptApp)
{
    return SUCC;
}
