/*******************************************************************************
 * Copyright(C)2012��2015 �������������豸���޹�˾
 * ��Ҫ���ݣ��ն����ϱ���ز�������
 * �� �� �ˣ�Robin
 * �������ڣ�2012/12/11
 *
 * $Revision: 1.3 $
 * $Log: GetTermRec.ec,v $
 * Revision 1.3  2013/01/18 08:32:37  fengw
 *
 * 1����ֺ�����
 *
 * Revision 1.2  2012/12/21 07:05:35  wukj
 * ����ע��
 *
 * Revision 1.1  2012/12/18 09:14:02  wukj
 * *** empty log message ***
 *
 *
 ******************************************************************************/

#define _EXTERN_

#include "ScriptPos.h"

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL EnD DECLARE SECTION;
#endif
/*****************************************************************
** ��    ��:ȡ�ն���Ϣ
** �������:
           ptApp
** �������:
           ptTerm   �ն���Ϣ�ṹ��
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
int GetTermRec(T_App* ptApp, T_TERMINAL *ptTerm)
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szShopNo[15+1];             /* �̻��� */
        char    szPosNo[15+1];              /* �ն˺� */
        char    szPsamNo[16+1];             /* ��ȫģ��� */
        char    szTelephone[15+1];          /* �绰���� */
        int     iTermModule;                /* �ն˲���ģ�� */
        int     iPsamModule;                /* ��ȫ����ģ�� */
        int     iAppType;                   /* Ӧ������ */
        char    szDescribe[20+1];           /* �ն����� */
        char    szPosType[40+1];            /* �ն��ͺ� */
        char    szAddress[40+1];            /* ��װ��ַ */
        char    szPutDate[8+1];             /* ��װ���� */
        long    lCurTrace;                  /* ��ǰ��ˮ�� */
        char    szIp[15+1];                 /* ����IP */
        int     iPort;                      /* �˿ں� */
        char    szDownMenu[1+1];            /* �Ƿ���Ҫ���ز˵� */
        char    szDownTerm[1+1];            /* �Ƿ���Ҫ�����ն˲��� */
        char    szDownPsam[1+1];            /* �Ƿ���Ҫ���ذ�ȫ���� */
        char    szDownPrint[1+1];           /* �Ƿ���Ҫ���ش�ӡģ�� */
        char    szDownOperate[1+1];         /* �Ƿ���Ҫ���ز�����ʾ */
        char    szDownFunction[1+1];        /* �Ƿ���Ҫ���ع�����ʾ */
        char    szDownError[1+1];           /* �Ƿ���Ҫ���ش�����ʾ */
        char    szDownAll[1+1];             /* �Ƿ���Ҫ����ȫ������ */
        char    szDownPayList[1+1];         /* �Ƿ���Ҫ�����˵� */
        int     iMenuRecNo;                 /* �����ز˵���¼�� */
        int     iPrintRecNo;                /* �����ز˵���¼�� */
        int     iOperateRecNo;              /* �����ز�����ʾ��¼�� */
        int     iFunctionRecNo;             /* �����ع�����ʾ��¼�� */
        int     iErrorRecNo;                /* �����ش�����ʾ��¼�� */
        int     iAllTransType;              /* ��ǰ���ع��� */
        char    szTermBitMap[8+1];          /* �ն˲�������λͼ */
        char    szPsamBitMap[8+1];          /* ��ȫ��������λͼ */
        char    szPrintBitMap[64+1];        /* ��ӡλͼ */
        char    szOperateBitMap[64+1];      /* ������ʾλͼ */
        char    szFunctionBitMap[64+1];     /* ������ʾλͼ */
        char    szErrorBitMap[64+1];        /* ������ʾλͼ */
        int     iMsgRecNum;                 /* ��Ҫ���ض��ż�¼�� */
        char    szMsgRecNo[256+1];          /* ��Ҫ���ض��ż�¼����� */
        int     iFirstPage;                 /* ��Ҫ������ҳ��Ϣ��¼�� */
        int     iTStatus;                   /* 0-������1-ͣ�� */
        long    lCurBatch;                  /* ��ǰ���κ� */
    EXEC SQL END DECLARE SECTION;

    memset(szPsamNo, 0, sizeof(szPsamNo));
    strcpy(szPsamNo, ptApp->szPsamNo);

    EXEC SQL
        SELECT shop_no, pos_no, NVL(telephone, ' '), NVL(term_module, 0), NVL(psam_module, 0),
               NVL(app_type, 1), NVL(describe, ' '), NVL(pos_type, 'spp100'), NVL(address, ' '),
               NVL(put_date, ' '), NVL(cur_trace, 1), NVL(ip, '127.0.0.1'), NVL(port, 0),
               NVL(down_menu, 'N'), NVL(down_term, 'N'), NVL(down_psam, 'N'), NVL(down_print, 'N'),
               NVL(down_operate, 'N'), NVL(down_function, 'N'), NVL(Down_Error, 'N'), NVL(down_all, 'N'),
               NVL(down_paylist, 'N'), NVL(menu_recno, 0), NVL(print_recno, 0), NVL(operate_recno, 0),
               NVL(function_recno, 0), NVL(error_recno, 0), NVL(all_transtype, 3), NVL(term_bitmap, ' '),
               NVL(psam_bitmap, ' '), NVL(print_bitmap, ' '), NVL(operate_bitmap, ' '), NVL(function_bitmap, ' '),
               NVL(error_bitmap, '  '), NVL(msg_recnum, 0), NVL(msg_recno, ' '), NVL(first_page, 0),
               NVL(status, 0), NVL(cur_batch, 1)
        INTO :szShopNo, :szPosNo, :szTelephone, :iTermModule, :iPsamModule,
             :iAppType, :szDescribe, :szPosType, :szAddress,
             :szPutDate, :lCurTrace, :szIp, :iPort,
             :szDownMenu, :szDownTerm, :szDownPsam, :szDownPrint,
             :szDownOperate, :szDownFunction, :szDownError, :szDownAll,
             :szDownPayList, :iMenuRecNo, :iPrintRecNo, :iOperateRecNo,
             :iFunctionRecNo, :iErrorRecNo, :iAllTransType, :szTermBitMap,
             :szPsamBitMap, :szPrintBitMap, :szOperateBitMap, :szFunctionBitMap,
             :szErrorBitMap, :iMsgRecNum, :szMsgRecNo, :iFirstPage,
             :iTStatus, :lCurBatch
        FROM  terminal
        WHERE psam_no = :szPsamNo;
    if(SQLCODE == SQL_NO_RECORD)
    {
        memset(ptApp->szShopNo, 0, sizeof(ptApp->szShopNo));
        memcpy(ptApp->szShopNo, szPsamNo, 8);

        memset(ptApp->szPosNo, 0, sizeof(ptApp->szShopNo));
        memcpy(ptApp->szPosNo, szPsamNo+8, 8);

        WriteLog(ERROR, "��ȫģ���[%s]δ�Ǽ�", szPsamNo);

        strcpy(ptApp->szRetCode, ERR_INVALID_TERM);

        return FAIL;
    }
    else if(SQLCODE == SQL_SELECT_MUCH)
    {
        memset(ptApp->szShopNo, 0, sizeof(ptApp->szShopNo));
        memcpy(ptApp->szShopNo, szPsamNo, 8);

        memset(ptApp->szPosNo, 0, sizeof(ptApp->szShopNo));
        memcpy(ptApp->szPosNo, szPsamNo+8, 8);

        WriteLog(ERROR, "��ȫģ���[%s]��¼�ظ�", szPsamNo );

        strcpy(ptApp->szRetCode, ERR_DUPLICATE_PSAM_NO);

        return FAIL;
    }
    else if(SQLCODE)
    {
        memset(ptApp->szShopNo, 0, sizeof(ptApp->szShopNo));
        memcpy(ptApp->szShopNo, szPsamNo, 8);

        memset(ptApp->szPosNo, 0, sizeof(ptApp->szShopNo));
        memcpy(ptApp->szPosNo, szPsamNo+8, 8);

        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "��ѯ ��ȫģ���:[%s] �ն˼�¼ʧ��!SQLCODE=%d SQLERR=%s",
                 szPsamNo, SQLCODE, SQLERR);

        return FAIL;
    }

    /* ɾ���ո� */
    DelTailSpace(szShopNo);
    DelTailSpace(szPosNo);
    DelTailSpace(szTelephone);
    DelTailSpace(szDescribe);
    DelTailSpace(szPosType);
    DelTailSpace(szPosType);
        
    strcpy(ptTerm->szShopNo, szShopNo);
    strcpy(ptTerm->szPosNo, szPosNo);
    strcpy(ptTerm->szTelephone, szTelephone);
    ptTerm->iTermModule = iTermModule;
    ptTerm->iPsamModule = iPsamModule;
    ptTerm->iAppType = iAppType;
    strcpy(ptTerm->szDescribe, szDescribe);
    strcpy(ptTerm->szPosType, szPosType);
    strcpy(ptTerm->szAddress, szAddress);
    strcpy(ptTerm->szPutDate, szPutDate);
    ptTerm->lCurTrace = lCurTrace;
    strcpy(ptTerm->szIp, szIp);
    ptTerm->iPort = iPort;
    strcpy(ptTerm->szDownMenu, szDownMenu);
    strcpy(ptTerm->szDownTerm, szDownTerm);
    strcpy(ptTerm->szDownPsam, szDownPsam);
    strcpy(ptTerm->szDownPrint, szDownPrint);
    strcpy(ptTerm->szDownOperate, szDownOperate);
    strcpy(ptTerm->szDownFunction, szDownFunction);
    strcpy(ptTerm->szDownError, szDownError);
    strcpy(ptTerm->szDownAll, szDownAll);
    strcpy(ptTerm->szDownPayList, szDownPayList);
    ptTerm->iMenuRecNo = iMenuRecNo;
    ptTerm->iPrintRecNo = iPrintRecNo;
    ptTerm->iOperateRecNo = iOperateRecNo;
    ptTerm->iFunctionRecNo = iFunctionRecNo;
    ptTerm->iErrorRecNo = iErrorRecNo;
    ptTerm->iAllTransType = iAllTransType;
    strcpy(ptTerm->szTermBitMap, szTermBitMap);
    strcpy(ptTerm->szPsamBitMap, szPsamBitMap);
    strcpy(ptTerm->szPrintBitMap, szPrintBitMap);
    strcpy(ptTerm->szOperateBitMap, szOperateBitMap);
    strcpy(ptTerm->szFunctionBitMap, szFunctionBitMap);
    strcpy(ptTerm->szErrorBitMap, szErrorBitMap);
    ptTerm->iMsgRecNum = iMsgRecNum;
    strcpy(ptTerm->szMsgRecNo, szMsgRecNo);
    ptTerm->iFirstPage = iFirstPage;
    ptTerm->iTStatus = iTStatus;
    ptTerm->lCurBatch = lCurBatch;

    return SUCC;
}
