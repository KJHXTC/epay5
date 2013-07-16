/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�ϵͳ���������Կ�������ȡ�ӿ�
 *  �� �� �ˣ�chenjr
 *  �������ڣ�2012/12/7
 * ----------------------------------------------------------------
 * $Revision: 1.2 $
 * $Log: SoftMasterKey.c,v $
 * Revision 1.2  2012/12/27 07:20:12  fengw
 *
 * 1�����ܺ���Կ��BCD�������
 *
 * Revision 1.1  2012/12/07 06:22:45  chenjr
 * init
 *
 * ----------------------------------------------------------------
 */

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include "libpub.h"
#include "user.h"


#define ENC_KEY "\xE0\x35\x21\xA4\x5B\x4C\x89\x67"
#define FILEPATH "etc/MKEY.dat"


/* ----------------------------------------------------------------
 * ��    �ܣ�������Կ���ļ��ܺ󱣴���ļ�
 * ���������szKeyText  ����Կ����
 *           iKeyLen    ����Կ���ĳ���
 * �����������
 * �� �� ֵ��FAIL ����ʧ��    SUCC����ɹ�
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/7
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int SaveMasterKey(char *szKeyText, int iKeyLen)
{
    int i;
    FILE *fp;
    unsigned char szMKey[48], szEnMKey[48], szAscMKey[48];
    char szFileName[100], *pEnv;

    AscToBcd(szKeyText, iKeyLen, 0, szMKey);

    for (i=0; i < iKeyLen / 2; i+=8)
    {
        DES(ENC_KEY, szMKey + i, szEnMKey + i);
    }

    BcdToAsc(szEnMKey, iKeyLen, 0, szAscMKey );

    pEnv = getenv("WORKDIR");
    if (pEnv == NULL)
    {
        WriteLog(ERROR, "env var[WORKDIR] isn't set [%d-%s]"
                , errno, strerror(errno));
        return  FAIL;
    }    

    memset(szFileName, '\0', sizeof(szFileName));
    sprintf(szFileName, "%s/%s", pEnv, FILEPATH);

    if( (fp=fopen(szFileName, "w+")) == NULL)
    {
        WriteLog(ERROR, "open file e");
        return( FAIL);
    }

    fprintf(fp, "%s\n", szAscMKey);

    fclose(fp);

    return(SUCC);
}

/* ----------------------------------------------------------------
 * ��    �ܣ�����Կ�ļ�ȡ������Կ���Ĳ����ܷ���
 * �����������
 * ���������szKeyText   ���ܺ������Կ����
 * �� �� ֵ��FAIL  ��ȡʧ��   >0  ����Կ���ĳ���
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/7
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int GetMasterKey(char *szKeyText)
{
    int iKeyLen, i;
    FILE    *fp;
    unsigned char   szTmpBuf[100], szTmpKey[25], szDeMKey[25];
    char    szFileName[100], *pEnv;

    pEnv = getenv("WORKDIR");
    if (pEnv == NULL)
    {
        WriteLog(ERROR, "env var[WORKDIR] isn't set [%d-%s]"
                , errno, strerror(errno));
        return  FAIL;
    }

    memset(szFileName, '\0', sizeof(szFileName));
    sprintf(szFileName, "%s/%s", pEnv, FILEPATH);

    if( (fp=fopen(szFileName, "r")) == NULL)
    {
        WriteLog(ERROR, "open file err");
        return( FAIL );
    }
   
    memset(szTmpBuf, 0, sizeof(szTmpBuf));
    fscanf(fp, "%s", szTmpBuf);
    fclose(fp);
    iKeyLen = strlen(szTmpBuf);

    AscToBcd(szTmpBuf, iKeyLen, 0, szTmpKey);

    for (i=0; i < iKeyLen / 2; i+=8)
    {
        _DES(ENC_KEY, szTmpKey + i, szDeMKey + i);
    }

    memcpy(szKeyText, szDeMKey, iKeyLen/2);

    return (iKeyLen);
}

