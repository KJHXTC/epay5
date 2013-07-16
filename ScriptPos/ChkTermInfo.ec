/*******************************************************************************
 * Copyright(C)2012��2015 �������������豸���޹�˾
 * ��Ҫ���ݣ��ն����ϱ���ز�������
 * �� �� �ˣ�Robin
 * �������ڣ�2012/12/11
 *
 * $Revision: 1.3 $
 * $Log: ChkTermInfo.ec,v $
 * Revision 1.3  2013/03/01 05:15:28  fengw
 *
 * 1������ǩ�����°汾BUG��
 *
 * Revision 1.2  2013/02/21 06:50:58  fengw
 *
 * 1�����Ӵ���Ӧ���븳ֵ���롣
 *
 * Revision 1.1  2013/01/18 08:32:37  fengw
 *
 * 1����ֺ�����
 *
 ******************************************************************************/

#define _EXTERN_

#include "ScriptPos.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL EnD DECLARE SECTION;

/*******************************************************************************
 * �������ܣ����ݰ�ȫģ��Ż�ȡ�ն������Լ���Կ
 * ���������
 *           ptApp  - �������ݽṹ
 * ���������
 *           
 * �� �� ֵ�� 
 *           ��
 *
 * ��    �ߣ�Robin
 * ��    �ڣ�2012/11/20
 *
 ******************************************************************************/
int ChkTermInfo(T_App *ptApp)
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szPsamNo[16+1];             /* ��ȫģ��� */
        long    lTrace;                     /* �ն���ˮ�� */
        long    lKeyIndex;                  /* ��Կ����ֵ */
        char    szPinKey[32+1];             /* PINKEY */
        char    szMacKey[32+1];             /* MACKEY */
        char    szMagKey[32+1];             /* MAGKEY */
    EXEC SQL END DECLARE SECTION;

    char    szTmpBuf[128+1];                /* ��ʱ���� */
    T_TERMINAL  tTerm;                      /* �ն˽ṹ */

    memset(&tTerm, 0, sizeof(T_TERMINAL));

    if(GetTermRec(ptApp, &tTerm) != SUCC)
    {
        WriteLog(ERROR, "��ȡ�ն� ��ȫģ���:[%s] ��¼ʧ��!", ptApp->szPsamNo);

        return FAIL;
    }

    /* �ն���Ϣ��ֵ */
    /* �̻��� */
    strcpy(ptApp->szShopNo, tTerm.szShopNo);

    /* �ն˺� */
    strcpy(ptApp->szPosNo, tTerm.szPosNo);

    /* �ն˲���ģ�� */
    ptApp->iTermModule = tTerm.iTermModule;

    /* ��ȫ����ģ�� */
    ptApp->iPsamModule = tTerm.iPsamModule;

    /* ��ǰ���κ� */
    ptApp->lBatchNo = tTerm.lCurBatch;

    /* ����λͼ */
    switch (ptApp->iTransType)
    {
        case DOWN_ALL_FUNCTION:    
        case DOWN_ALL_OPERATION:    
        case DOWN_ALL_PRINT:    
        case DOWN_ALL_ERROR:    
        case DOWN_FUNCTION_INFO:    
        case DOWN_OPERATION_INFO:    
        case AUTODOWN_ALL_OPERATION:    
        case DOWN_PRINT_INFO:    
        case DOWN_ERROR:    
            memset(ptApp->szReserved, '1', 256);
            break;
        case DOWN_ALL_PSAM:
        case DOWN_ALL_TERM:
        case DOWN_PSAM_PARA:
        case DOWN_TERM_PARA:
            memset(ptApp->szReserved, '1', 32);
            break;
        case CENDOWN_FUNCTION_INFO:
        case AUTODOWN_FUNCTION_INFO:
            UncompressBitmap(ptApp->szReserved, tTerm.szFunctionBitMap, 64);
            break;
        case CENDOWN_OPERATION_INFO:
        case AUTODOWN_OPERATION_INFO:
            UncompressBitmap(ptApp->szReserved, tTerm.szOperateBitMap, 64);
            break;
        case CENDOWN_PRINT_INFO:
        case AUTODOWN_PRINT_INFO:
            UncompressBitmap(ptApp->szReserved, tTerm.szPrintBitMap, 64);
            break;
        case CENDOWN_ERROR:
        case AUTODOWN_ERROR:
            UncompressBitmap(ptApp->szReserved, tTerm.szErrorBitMap, 64);
            break;
        case CENDOWN_TERM_PARA:
        case AUTODOWN_TERM_PARA:
            UncompressBitmap(ptApp->szReserved, tTerm.szTermBitMap, 8);
            break;
        case CENDOWN_PSAM_PARA:
        case AUTODOWN_PSAM_PARA:
            UncompressBitmap(ptApp->szReserved, tTerm.szPsamBitMap, 8);
            break;
    }

    /* ���POS�ϴ���ˮ�Ŵ���ϵͳ��¼�ĸ��ն���ˮ�ţ������ն˼�¼��ǰ��ˮ���ֶ� */
    if(ptApp->lPosTrace > tTerm.lCurTrace)
    {
        lTrace = ptApp->lPosTrace + 1;
    }
    else
    {
        lTrace = tTerm.lCurTrace + 1;
    }

    if(lTrace >= 1000000l)
    {
        lTrace = 1l;
    }

    memset(szPsamNo, 0, sizeof(szPsamNo));
    strcpy(szPsamNo, ptApp->szPsamNo);

    EXEC SQL
        UPDATE terminal
        SET cur_trace = :lTrace
        WHERE psam_no = :szPsamNo;
    if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "�����ն� ��ȫģ���:[%s] ��ǰ��ˮ��ʧ��!SQLCODE=%d SQLERR=%s",
                 szPsamNo, SQLCODE, SQLERR);

        RollbackTran();

        return(FAIL);
    }

    CommitTran();

    /* ��ѯ������Կ */
    if(ptApp->iTransType != LOGIN && ptApp->iTransType != ECHO_TEST &&
       ptApp->iTransType != OPER_LOGIN)
    {
        memset(szTmpBuf, 0, sizeof(szTmpBuf));
        memset(szPinKey, 0, sizeof(szPinKey));
        memset(szMacKey, 0, sizeof(szMacKey));
        memset(szMagKey, 0, sizeof(szMagKey));

        memcpy(szTmpBuf, ptApp->szPsamNo+8, 8);
        lKeyIndex = atol(szTmpBuf);

        EXEC SQL
            SELECT NVL(pin_key, ' '), NVL(mac_key, ' '), NVL(mag_key, ' ')
            INTO :szPinKey, :szMacKey, :szMagKey
            FROM pos_key
            WHERE key_index = :lKeyIndex;
        if(SQLCODE == SQL_NO_RECORD)
        {
            strcpy(ptApp->szRetCode, ERR_INVALID_TERM);

            WriteLog(ERROR, "��ѯ ��Կ����ֵ[%ld] ��Ӧ��Կ��¼ʧ��!SQLCODE=%d SQLERR=%s",
                     lKeyIndex, SQLCODE, SQLERR);

            return FAIL;
        }
        else if(SQLCODE)
        {
            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

            WriteLog(ERROR, "��ѯ ��Կ����ֵ[%ld] ��Ӧ��Կ��¼ʧ��!SQLCODE=%d SQLERR=%s",
                     lKeyIndex, SQLCODE, SQLERR);

            return FAIL;
        }

        AscToBcd((uchar*)(szPinKey), 32, 0 ,(uchar*)(ptApp->szPinKey));
        AscToBcd((uchar*)(szMacKey), 32, 0 ,(uchar*)(ptApp->szMacKey));
        AscToBcd((uchar*)(szMagKey), 32, 0 ,(uchar*)(ptApp->szTrackKey));
    }

    /* ǩ�������ڽ��׷���ʱ����Ƿ���Ҫ���� */
    if(ptApp->iTransType == LOGIN)
    {
        return SUCC;
    }

#ifdef DEBUG
    WriteLog(TRACE, "Check TMS Downlaod Begin!");
#endif
    /* ����ն��Ƿ���Ҫ����TMS */
    if(ChkTmsUpdate(ptApp) != SUCC)
    {
#ifdef DEBUG
        WriteLog(TRACE, "TMS Need Update!");
#endif
        memcpy(ptApp->szRetCode, ERR_NEED_DOWN_APP, 2);

        return FAIL;
    }

#ifdef DEBUG
    WriteLog(TRACE, "Check App Downlaod Begin!");
#endif
    /* ����ն��Ƿ���Ҫ����Ӧ�� */
    if(ChkAppUpdate(ptApp, &tTerm) != SUCC)
    {
#ifdef DEBUG
        WriteLog(TRACE, "App Need Update!");
#endif
        memcpy(ptApp->szRetCode, ERR_NEED_DOWN_APP, 2);

        return FAIL;
    }

    return SUCC;
}
