
/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ��������ļ�
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision: 1.11 $
 * $Log: ReadConf.c,v $
 * Revision 1.11  2013/06/17 03:10:39  fengw
 *
 * 1���ж���Ŀ�Ƿ����ʱ�������ж���Ŀ��һ���ֽ��Ƿ��ǽ��������ո�tab����ֹ��ѯ������Ŀʱ�������С�
 * 2��������Ŀֵʱ��������Ŀ��ֵ֮��Ŀո�tab����ֹ����Խ�硣
 *
 * Revision 1.10  2012/12/04 07:06:22  chenjr
 * ����淶��
 *
 * Revision 1.9  2012/12/03 06:31:35  yezt
 *
 * �ġ�Writelog�� Ϊ"WriteLog��
 *
 * Revision 1.8  2012/11/29 02:15:35  linqil
 * �޸�WriteETLogΪWriteLog
 *
 * Revision 1.7  2012/11/28 08:25:44  linqil
 * ȥ������ͷ�ļ�user.h
 *
 * Revision 1.6  2012/11/28 02:40:25  linqil
 * �޸���־����
 *
 * Revision 1.5  2012/11/27 05:55:25  linqil
 * ȥ��void�����ķ���ֵ
 *
 * Revision 1.4  2012/11/21 06:08:30  chenjr
 * *** empty log message ***
 *
 * Revision 1.3  2012/11/21 06:05:53  chenjr
 * ��Ӵ�WORKDIR����������ȡ����·������
 *
 * Revision 1.2  2012/11/20 07:49:11  chenjr
 * �޸ĺ�������,ȥ��Ĭ��ֵ�������.
 *
 * Revision 1.1  2012/11/20 03:27:37  chenjr
 * init
 *
 * ----------------------------------------------------------------
 */


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include "pub.h"

extern char *DelAllSpace(char *szStr);

/* ----------------------------------------------------------------
 * ��    �ܣ��������ļ�
 * ���������szFilenm    �����ļ���
 *           szSection   �½���,һ�������ļ������ж���½ڣ�ÿ���½�����
 *                       ���԰��������Ŀ
 *           szItem      ��Ŀ, ������Ÿ���Ŀ�ľ���ֵ
 * ���������szVal       ��Ŀֵ����szItem��Ŀͬ��һ�У��м��ÿո��=�ָ�
 * �� �� ֵ��0  ��ȡ�ɹ���  -1  ��ȡʧ��
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */ 
int ReadConfig(char *szFilenm, char *szSection, char *szItem, char *szVal)
{
    int   findSection = 0;
    int   findItem = 0;
    FILE  *fp;
    char  acLine[200], acTmp[51], szPath[500], *pEnv;
    int   i;

    if (szFilenm == NULL || szSection == NULL || szItem == NULL ||
        szVal    == NULL)
    {
        WriteLog(ERROR, "Invalid argument\n");
        return  FAIL;
    }

    pEnv = getenv("WORKDIR");
    if (pEnv == NULL)
    {
        WriteLog(ERROR, "environment variable[WORKDIR] isn't set [%d-%s]", errno, strerror(errno));
        return  FAIL;
    }

    memset(szPath, 0, sizeof(szPath));
    sprintf(szPath, "%s/etc/%s", pEnv, szFilenm);

    fp = fopen(szPath, "r");
    if (fp == NULL)
    {
        WriteLog(ERROR, "Open file[%s] error[%d-%s]", szPath, errno, strerror(errno));
        return  FAIL;
    }

    while (!feof(fp))
    {
        memset(acLine, 0x00, sizeof(acLine));

        if (fgets(acLine, 80, fp) == NULL)
        {
            break;
        }

        acLine[strlen(acLine)-1] = 0;      /* ȥ�����з� '0x0A' */
        memset(acTmp, 0, sizeof(acTmp));

        if( acLine[0]=='#' )
        {
            continue;
        }

        if (acLine[0] == '[')
        {
            if (findSection == 1)     /* �ѵ�����һ�½�,˵��δ�ҵ����� */
            {
                break;
            }

        //    findSection = 0;
        
            memcpy(acTmp, acLine + 1, strlen(szSection) );

            if (memcmp(szSection, acTmp, strlen(acTmp) ) == 0)
            {
                findSection = 1;
            }
        }
        else
        {
            if (findSection == 0)
            {
                continue;
            }

            if (memcmp(acLine, szItem, strlen(szItem)) == 0)
            {
                if(acLine[strlen(szItem)] == 0x00)
                {
                    szVal[0] =0x00;
                    findItem=1;
                    break;
                }
                else if(acLine[strlen(szItem)] == 0x09 || acLine[strlen(szItem)] == 0x20)
                {
                    for(i=strlen(szItem)+1;i<strlen(acLine);i++)
                    {
                        if(acLine[i] != 0x20 && acLine[i] != 0x09)
                        {
                            break;
                        }
                    }
                    strcpy(szVal, acLine+i);
                    findItem=1;
                    break;
                }
            }
        }
    }

    fclose(fp);

    if (findSection == 0 || findItem==0 )
    {
/*
        if (szDefVal != NULL)
        {
            strcpy(szVal, szDefVal);
            return 0;
        }
*/
        WriteLog(ERROR, "Not found param[%s][%s] in file[%s]",
                         szSection, szItem, szFilenm);
        return  FAIL;
    }

    DelAllSpace(szVal);
    return  SUCC;
}
