/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ��ն������ཻ�� ����EMV����
** �� �� �ˣ�fengwei
** �������ڣ�2013/03/06
**
** $Revision: 1.1 $
** $Log: DownEmvPara.ec,v $
** Revision 1.1  2013/03/11 07:04:57  fengw
**
** 1������EMV�������ؽ��ס�
**
*******************************************************************/

#include "manatran.h"

/****************************************************************
** ��    �ܣ�����EMV����
** ���������
**        ptApp                     app�ṹָ��
** ���������
**        ��
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2013/03/06
** ����˵����
**
** �޸���־��
****************************************************************/

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL EnD DECLARE SECTION;
#endif

int DownEmvPara(T_App *ptApp) 
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szEmvParaVer[12+1];                 /* EMV�����汾�� */
        char    szEmvParaMaxVer[12+1];              /* EMV�������汾�� */
        char    szEmvPara[1024+1];                  /* EMV�������� */
    EXEC SQL END DECLARE SECTION;

    char    szTmpBuf[128+1];                        /* ��ʱ���� */

    /* ���ķ����ף������ж��Ƿ���comweb */
    strcpy(ptApp->szAuthCode, "YES" );

    memset(szEmvParaVer, 0, sizeof(szEmvParaVer));
    memset(szEmvParaMaxVer, 0, sizeof(szEmvParaMaxVer));
    memset(szEmvPara, 0, sizeof(szEmvPara));

    if(strlen(ptApp->szEmvParaVer) == 0)
    {
        strcpy(szEmvParaVer, "000000000000");
    }
    else
    {
        strcpy(szEmvParaVer, ptApp->szEmvParaVer);
    }

    EXEC SQL
        SELECT MAX(Para_ver) INTO :szEmvParaMaxVer
        FROM emv_para;
    if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "��ѯEMV�������汾��ʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

        return FAIL;
    }
#ifdef DEBUG
    WriteLog(TRACE, "MAX EMV Para Ver:[%s]", szEmvParaMaxVer);
#endif

    EXEC SQL
        SELECT para_ver, para_data
        INTO :szEmvParaVer, :szEmvPara
        FROM
            (SELECT para_ver, para_data FROM emv_para
            WHERE para_ver > :szEmvParaVer OR para_ver = :szEmvParaMaxVer
            ORDER BY para_ver ASC)
        WHERE ROWNUM = 1;
    if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "��ѯ�汾�Ŵ���[%s]��EMV������¼ʧ��!SQLCODE=%d SQLERR=%s",
                 szEmvParaVer, SQLCODE, SQLERR);

        return FAIL;
    }
    else
    {
        DelTailSpace(szEmvPara);

        memset(ptApp->szEmvParaVer, 0, sizeof(ptApp->szEmvParaVer));
        strcpy(ptApp->szEmvParaVer, szEmvParaVer);
        ptApp->iEmvParaLen = strlen(szEmvPara) / 2;
        AscToBcd(szEmvPara, strlen(szEmvPara), LEFT_ALIGN, ptApp->szEmvPara);
#ifdef DEBUG
        WriteLog(TRACE, "szEmvParaVer:[%s]", ptApp->szEmvParaVer);
        WriteLog(TRACE, "iEmvParaLen:[%d]", ptApp->iEmvParaLen);
        WriteLog(TRACE, "szEmvPara:[%s]", szEmvPara);
#endif

        /* �ж��Ƿ���Ҫ�������� */
        if(memcmp(szEmvParaVer, szEmvParaMaxVer, 12) < 0)
        {
            /* ��պ���ָ�� */
            memset(ptApp->szCommand, 0, sizeof(ptApp->szCommand));
            ptApp->iCommandLen = 0;
            ptApp->iCommandNum = 0;
            
            /* �������״���ǰ2λ��ʾ�����ؼ�¼����¼�ţ���6λΪ��ǰ���� */
            memset(szTmpBuf, 0, sizeof(szTmpBuf));
            memcpy(szTmpBuf, ptApp->szTransCode, 2);

            memset(ptApp->szNextTransCode, 0, sizeof(ptApp->szNextTransCode));
            sprintf(ptApp->szNextTransCode, "%02d", atoi(szTmpBuf)+1);
            memcpy(ptApp->szNextTransCode+2, ptApp->szTransCode+2, 6);

            /* ����EMV���� */
            memcpy(ptApp->szCommand+ptApp->iCommandLen, "\xC0\x00\x02", 3);
            ptApp->iCommandLen += 3;
            ptApp->iCommandNum += 1;

            /* ��ȡEMV�����汾�� */
            memcpy(ptApp->szCommand+ptApp->iCommandLen, "\xC0\x00\x01", 3);
            ptApp->iCommandLen += 3;
            ptApp->iCommandNum += 1;

            /* ����MAC */
            memcpy(ptApp->szCommand+ptApp->iCommandLen, "\x8D", 1);
            ptApp->iCommandLen += 1;
            ptApp->iCommandNum += 1;

            /* �������� */
            memcpy(ptApp->szCommand+ptApp->iCommandLen, "\x24\x03", 2);
            ptApp->iCommandLen += 2;
            ptApp->iCommandNum += 1;

            /* �������� */
            memcpy(ptApp->szCommand+ptApp->iCommandLen, "\x25\x04", 2);
            ptApp->iCommandLen += 2;
            ptApp->iCommandNum += 1;

            /* ��Ҫ�������أ�����comweb */
            strcpy(ptApp->szAuthCode, "NO");
        }
    }

    /* �޺������ף��һ� */
    if(strlen(ptApp->szNextTransCode) == 0 || memcmp(ptApp->szNextTransCode, "00000000", 8) == 0)
    {
        /* �һ� */
        memcpy(ptApp->szCommand+ptApp->iCommandLen, "\xA6", 1);
        ptApp->iCommandLen += 1;
        ptApp->iCommandNum += 1;
    }
#ifdef DEBUG
    WriteLog(TRACE, "Next TransCode:[%s]", ptApp->szNextTransCode);
#endif

    strcpy(ptApp->szRetCode, TRANS_SUCC);

    return SUCC;
}