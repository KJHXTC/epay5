/*******************************************************************************
 * Copyright(C)2012��2015 �������������豸���޹�˾
 * ��Ҫ���ݣ�����ն��Ƿ���Ҫ����
 * �� �� �ˣ�Robin
 * �������ڣ�2012/12/11
 *
 * $Revision: 1.2 $
 * $Log: ChkAppUpdate.ec,v $
 * Revision 1.2  2013/02/21 06:46:28  fengw
 *
 * 1���޸ļ��Ӧ�ø���ʱ�Խ��������ж�������
 * 2������DEBUG���룬���ڵ��ԡ�
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

/*****************************************************************
** ��    ��:����ն��Ƿ���Ҫ����
** �������:
**          ptApp                   app�ṹָ��
**          ptTerm                  terminal�ṹָ��
** �������:
** �� �� ֵ:
**          �ɹ� - SUCC
**          ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
int ChkAppUpdate(T_App *ptApp, T_TERMINAL *ptTerm)
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szPsamNo[16+1];             /* ��ȫģ��� */
        char    szCenAppVer[8+1];           /* ƽ̨Ӧ�ð汾�� */
        int     iCnt;                       /* ��¼�� */
        int     iAppType;                   /* Ӧ������ */
    EXEC SQL END DECLARE SECTION;

    char        szTmpBuf[128+1];            /* ��ʱ���� */

    /* ����������� */
    /* 1.��غϽ����з��׻غϽ��ף���֤��ǰ������������ */
    /* 2.��������С��100(�ǽ��ڽ���)����ֹ�ն˸��¹����б���� */
    /* 3.�������ʹ���100(���ڽ���)��Ӧ����Ϊ�ɹ�����֤����ƾ����ӡ�ɹ� */
    /* 4.Ӧ����Ϊ��Ч�նˡ���Ч�̻��� */
    if(ptApp->iSteps > 1 || (ptApp->iTransType < 100 && ptApp->iTransType != LOGIN) ||
       (ptApp->iTransType >= 100 && memcmp(ptApp->szRetCode, TRANS_SUCC, 2) == 0) ||
       memcmp(ptApp->szRetCode, ERR_INVALID_TERM, 2) == 0 ||
       memcmp(ptApp->szRetCode, ERR_DUPLICATE_PSAM_NO, 2) == 0 ||
       memcmp(ptApp->szRetCode, ERR_INVALID_MERCHANT, 2) == 0)
    {
        return SUCC;
    }

    /* ����Ƿ���Ҫ����Ӧ�� */
    if(ptTerm->szDownAll[0] == 'Y')
    {
#ifdef DEBUG
        WriteLog(TRACE, "Next TransCode:[%s]", AUTODOWN_ALL_OPERATION_CODE);
#endif

        strcpy(ptApp->szNextTransCode, AUTODOWN_ALL_OPERATION_CODE);

        return FAIL;
    }

    /* ����ն�Ӧ�ð汾�� */
    iAppType = ptTerm->iAppType;
    memset(szCenAppVer, 0, sizeof(szCenAppVer));

    EXEC SQL SELECT app_ver 
        INTO :szCenAppVer
        FROM app_def
        WHERE app_type = :iAppType;
    if(SQLCODE == SQL_NO_RECORD)
    {
        strcpy(ptApp->szRetCode, ERR_INVALID_APP);

        WriteLog(ERROR, "Ӧ������[%d]δ����", ptTerm->iAppType);

        return FAIL;
    }
    else if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "��ѯӦ������[%d]�汾��ʧ��!SQLCODE=%d SQLERR=%s",
                 iAppType, SQLCODE, SQLERR);

        return FAIL;
    }

    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    BcdToAsc((uchar*)(ptApp->szAppVer), 8, 0 ,(uchar*)szTmpBuf);

    if(memcmp(szTmpBuf, szCenAppVer, 8) != 0)
    {
#ifdef DEBUG
        WriteLog(TRACE, "Next TransCode:[%s]", AUTODOWN_ALL_OPERATION_CODE);
#endif
        strcpy(ptApp->szNextTransCode, AUTODOWN_ALL_OPERATION_CODE);

        return FAIL;
    }

    /* ����ն˵������ */
    /* ���²˵� */
    if(ptTerm->szDownMenu[0] == 'Y')
    {
#ifdef DEBUG
        WriteLog(TRACE, "Next TransCode:[%s]", AUTODOWN_MENU_CODE);
#endif
        strcpy(ptApp->szNextTransCode, AUTODOWN_MENU_CODE);

        return FAIL;
    }
    /* �����ն˲��� */
    else if(ptTerm->szDownTerm[0] == 'Y')
    {
#ifdef DEBUG
        WriteLog(TRACE, "Next TransCode:[%s]", AUTODOWN_TERM_PARA_CODE);
#endif
        strcpy(ptApp->szNextTransCode, AUTODOWN_TERM_PARA_CODE);

        return FAIL;
    }
    /* ���°�ȫ���� */
    else if(ptTerm->szDownPsam[0] == 'Y')
    {
#ifdef DEBUG
        WriteLog(TRACE, "Next TransCode:[%s]", AUTODOWN_PSAM_PARA_CODE);
#endif
        strcpy(ptApp->szNextTransCode, AUTODOWN_PSAM_PARA_CODE);

        return FAIL;
    }
    /* ���´�ӡ��¼ */
    else if(ptTerm->szDownPrint[0] == 'Y')
    {
#ifdef DEBUG
        WriteLog(TRACE, "Next TransCode:[%s]", AUTODOWN_PRINT_INFO_CODE);
#endif
        strcpy(ptApp->szNextTransCode, AUTODOWN_PRINT_INFO_CODE);

        return FAIL;
    }
    /* ���¹�����ʾ��Ϣ */
    else if(ptTerm->szDownFunction[0] == 'Y')
    {
#ifdef DEBUG
        WriteLog(TRACE, "Next TransCode:[%s]", AUTODOWN_FUNCTION_INFO_CODE);
#endif
        strcpy(ptApp->szNextTransCode, AUTODOWN_FUNCTION_INFO_CODE);

        return FAIL;
    }
    /* ���²�����ʾ��Ϣ */
    else if(ptTerm->szDownOperate[0] == 'Y')
    {
#ifdef DEBUG
        WriteLog(TRACE, "Next TransCode:[%s]", AUTODOWN_OPERATION_INFO_CODE);
#endif
        strcpy(ptApp->szNextTransCode, AUTODOWN_OPERATION_INFO_CODE);

        return FAIL;
    }
    /* ���´�����Ϣ */
    else if(ptTerm->szDownError[0] == 'Y')
    {
#ifdef DEBUG
        WriteLog(TRACE, "Next TransCode:[%s]", AUTODOWN_ERROR_CODE);
#endif
        strcpy(ptApp->szNextTransCode, AUTODOWN_ERROR_CODE);

        return FAIL;
    }
    /* ���¶��� */
    else if(ptTerm->iMsgRecNum > 0)
    {
#ifdef DEBUG
        WriteLog(TRACE, "Next TransCode:[%s]", AUTODOWN_MSG_CODE);
#endif
        strcpy(ptApp->szNextTransCode, AUTODOWN_MSG_CODE);

        return FAIL;
    }

    /* ����Ƿ���Ҫ�����˵� */
    memset(szPsamNo, 0, sizeof(szPsamNo));
    strcpy(szPsamNo, ptApp->szPsamNo);

    EXEC SQL
        SELECT COUNT(*) INTO :iCnt
        FROM  pay_list
        WHERE psam_no = :szPsamNo AND
              down_flag = 'N' AND pay_status = 'N';
    if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "��ѯ�ն� ��ȫģ���[%s] �˵�����ʧ��!SQLCODE=%d SQLERR=%s",
                 szPsamNo, SQLCODE, SQLERR);

        return FAIL;
    }

    if(iCnt > 0)
    {
        strcpy(ptApp->szNextTransCode, AUTODOWN_PAYLIST_CODE);

        return FAIL;
    }

    return SUCC;
}
