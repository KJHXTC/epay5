/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ��ն������ཻ�� ����EMV��Կ
** �� �� �ˣ�fengwei
** �������ڣ�2013/03/06
**
** $Revision: 1.1 $
** $Log: DownEmvKey.ec,v $
** Revision 1.1  2013/03/11 07:04:33  fengw
**
** 1������EMV��Կ���ؽ��ס�
**
*******************************************************************/

#include "manatran.h"

/****************************************************************
** ��    �ܣ�����EMV��Կ
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

int DownEmvKey(T_App *ptApp) 
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szEmvKeyVer[8+1];               /* EMV��Կ�汾�� */
        char    szEmvKeyMaxVer[8+1];            /* EMV��Կ���汾�� */
        char    szEmvKey[1024+1];               /* EMV��Կ���� */
    EXEC SQL END DECLARE SECTION;

    char    szTmpBuf[128+1];                    /* ��ʱ���� */

    /* ���ķ����ף������ж��Ƿ���comweb */
    strcpy(ptApp->szAuthCode, "YES" );

    memset(szEmvKeyVer, 0, sizeof(szEmvKeyVer));
    memset(szEmvKeyMaxVer, 0, sizeof(szEmvKeyMaxVer));
    memset(szEmvKey, 0, sizeof(szEmvKey));

    if(strlen(ptApp->szEmvKeyVer) == 0)
    {
        strcpy(szEmvKeyVer, "00000000");
    }
    else
    {
        strcpy(szEmvKeyVer, ptApp->szEmvKeyVer);
    }

    EXEC SQL
        SELECT MAX(key_ver) INTO :szEmvKeyMaxVer
        FROM emv_key;
    if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "��ѯEMV��Կ���汾��ʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

        return FAIL;
    }
#ifdef DEBUG
    WriteLog(TRACE, "MAX EMV Para Ver:[%s]", szEmvKeyMaxVer);
#endif

    EXEC SQL
        SELECT key_ver, key_data
        INTO :szEmvKeyVer, :szEmvKey
        FROM
            (SELECT key_ver, key_data FROM emv_key
            WHERE key_ver > :szEmvKeyVer OR key_ver = :szEmvKeyMaxVer
            ORDER BY key_ver ASC)
        WHERE ROWNUM = 1;
    if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "��ѯ�汾�Ŵ���[%s]��EMV��Կ��¼ʧ��!SQLCODE=%d SQLERR=%s",
                 szEmvKeyVer, SQLCODE, SQLERR);

        return FAIL;
    }
    else
    {
        DelTailSpace(szEmvKey);

        memset(ptApp->szEmvKeyVer, 0, sizeof(ptApp->szEmvKeyVer));
        strcpy(ptApp->szEmvKeyVer, szEmvKeyVer);
        ptApp->iEmvKeyLen = strlen(szEmvKey) / 2;
        AscToBcd(szEmvKey, strlen(szEmvKey), LEFT_ALIGN, ptApp->szEmvKey);
#ifdef DEBUG
        WriteLog(TRACE, "szEmvKeyVer:[%s]", ptApp->szEmvKeyVer);
        WriteLog(TRACE, "iEmvKeyLen:[%d]", ptApp->iEmvKeyLen);
        WriteLog(TRACE, "szEmvKey:[%s]", szEmvKey);
#endif

        /* �ж��Ƿ���Ҫ�������� */
        if(memcmp(szEmvKeyVer, szEmvKeyMaxVer, 8) < 0)
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

            /* ����EMV��Կ */
            memcpy(ptApp->szCommand+ptApp->iCommandLen, "\xC0\x00\x04", 3);
            ptApp->iCommandLen += 3;
            ptApp->iCommandNum += 1;

            /* ��ȡEMV��Կ�汾�� */
            memcpy(ptApp->szCommand+ptApp->iCommandLen, "\xC0\x00\x03", 3);
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