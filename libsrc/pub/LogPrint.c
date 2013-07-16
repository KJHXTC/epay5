/******************************************************************
 ** Copyright(C)2009��2012 �������������豸���޹�˾
 ** ��Ҫ���ݣ���־�ļ��Ĵ򿪣��رգ��ض���
 ** �� �� �ˣ�zhangwm
 ** �������ڣ�2012/12/03
 **
 ** ---------------------------------------------------------------
 **   $Revision: 1.12 $
 **   $Log: LogPrint.c,v $
 **   Revision 1.12  2012/12/11 02:14:48  fengw
 **
 **   1�����ӶԶ�ȡLOG_SWITCH���������жϣ����δ����LOG_SWITCH����Ĭ�ϴ�ӡ������־��
 **
 **   Revision 1.11  2012/11/29 07:02:31  zhangwm
 **
 **   �����Ƿ��ӡ��־����
 **
 **   Revision 1.10  2012/11/29 01:56:41  zhangwm
 **
 **   �������ý�����Ϣ������������������������־��ӡʹ��
 **
 **   Revision 1.9  2012/11/29 01:11:27  zhangwm
 **
 **   �޸�WriteETLogΪWriteLog
 **
 **   Revision 1.8  2012/11/28 08:25:17  linqil
 **   *** empty log message ***
 **
 **   Revision 1.7  2012/11/28 08:24:53  linqil
 **   ȡ��������ͷ�ļ�user.h
 **
 **   Revision 1.6  2012/11/27 09:26:21  zhangwm
 **
 **   �޸���������ϵͳ�����ж�LinuxΪLINUX
 **
 **   Revision 1.5  2012/11/27 08:39:40  zhangwm
 **
 **   ���µ�ʱ�䴦�����滻ԭ����
 **
 **   Revision 1.4  2012/11/27 06:13:41  zhangwm
 **
 **   ��дAPP��־�����Ƴ�
 **
 **   Revision 1.3  2012/11/27 03:36:31  zhangwm
 **
 **   �޸�ͷ�ļ�Ϊ�ڲ�ʹ��
 **
 **   Revision 1.2  2012/11/26 06:45:35  zhangwm
 **
 **  ��������־��ӡ��ֲ����������
 **
 **   Revision 1.1  2012/11/20 03:27:37  chenjr
 **   init
 **
 ** ---------------------------------------------------------------
 **
 *******************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#ifdef LINUX
#include <stdarg.h>
#else
#include <varargs.h>
#endif
#include "user.h"
#include "LogPrint.h"

/*****************************************************************
 ** ��    �ܣ�����־�ļ�
 ** ���������
 **        pszLogFile ��־�ļ�����
 **        iType ��־�ļ����ͣ�    
 **            1��������־ 2��������־
 **            3��16������־
 **            4�������־
 ** ���������
 **        ��
 ** �� �� ֵ��
 **          �ɹ����� 0 
 **          ʧ�ܷ��� -1 
 ** ��    �ߣ�zhangwm
 ** ��    �ڣ�2012/12/03
 ** �޸���־��
 **          1��2012/12/03 ��ʼ���� 
 ****************************************************************/
int OpenLogFile( char* pszLogFile, int iType)
{
    FILE         *fpLogFile;
    FILE         *logfp;

    if ((fpLogFile=fopen(pszLogFile, "a+")) == NULL)
    {
        fprintf(stdout, "Open Log file[%s] Error\n", pszLogFile);
        return -1;
    }

    switch(iType)
    {
        case T_TYPE:
            if (fpTLog != NULL)
            {
                fclose(fpTLog);
            }
            fpTLog = fpLogFile;

            return 0; 
        case H_TYPE:
            if (fpHLog != NULL)
            {
                fclose(fpHLog);
            }

            fpHLog = fpLogFile;
            return 0;
        case M_TYPE:
            if (fpMLog != NULL)
            {
                fclose(fpMLog);
            }

            fpMLog = fpLogFile;
            return 0;
        default:
            break;
    }


#ifdef AIX
    if (dup2(fpLogFile->_file,2)<0)
    {
        fprintf( stdout, "\ndup2 log Error[%d-%s]\n", errno, strerror(errno));
        fclose( fpLogFile );
        return -1;
    }
#endif

#ifdef SCO_SV
    if ( dup2(fpLogFile->__file,2)<0 )
    {
        fprintf( stdout, "\ndup2 log Error[%d-%s]\n", errno, strerror(errno));
        fclose( fpLogFile );
        return -1;
    }
#endif

#ifdef LINUX
    if ( dup2(fileno(fpLogFile),2)<0 )
    {
        fprintf( stdout, "\ndup2 log Error[%d-%s]\n", errno, strerror(errno));
        fclose( fpLogFile );
        return -1;
    }
#endif

    return 0;
}

/*****************************************************************
 ** ��    �ܣ�д��־�ļ�
 ** ���������
 **        pszData �������� 
 **        iType ��־�ļ����ͣ�    
 **            1��������־ 2��������־
 **            3��16������־
 **            4�������־
 ** ���������
 **        ��
 ** �� �� ֵ��
 **          �ɹ����� 0 
 **          ʧ�ܷ��� -1 
 ** ��    �ߣ�zhangwm
 ** ��    �ڣ�2012/12/03
 ** �޸���־��
 **          1��2012/12/03 ��ʼ���� 
 ****************************************************************/
int PrintLog(char* pszData, int iType)
{
    FILE* fpFile;
    int iLen;
    char szEnvKey[20], szDate[9];
    char szPath[PATH_LEN], szFileName[PATH_LEN], szOldFileName[PATH_LEN];

    switch(iType)
    {
        case E_TYPE:
            sprintf(szEnvKey, "__LOG_FILE_%s_", "E");
            sprintf(szFileName, "%s%s", getenv("WORKDIR"), E_LOG);
            break;
        case T_TYPE:
            sprintf(szEnvKey, "__LOG_FILE_%s_", "T");
            sprintf(szFileName, "%s%s", getenv("WORKDIR"), T_LOG);
            break;
        case H_TYPE:
            sprintf(szEnvKey, "__LOG_FILE_%s_", "H");
            sprintf(szFileName, "%s%s", getenv("WORKDIR"), H_LOG);
            break;
        case M_TYPE:
            sprintf(szEnvKey, "__LOG_FILE_%s_", "M");
            sprintf(szFileName, "%s%s", getenv("WORKDIR"), M_LOG);
            break;
        default:
            break;
    }
    GetSysDate(szDate);
    strcat(szFileName, szDate);

    /* ���̳��δ�ӡ����־�������־�ļ� */
    if (getenv(szEnvKey) == NULL)
    {
        OpenLogFile(szFileName, iType);
        setenv(szEnvKey, szFileName, 1);
    }

    /* ��ǰ��־�ļ������ڻ��������е���־�ļ�����
       ��һ�£���˵������һ�죬�����ļ����� */
    strcpy(szOldFileName, getenv(szEnvKey));
    if (strcmp(szOldFileName, szFileName) != 0)
    {
        OpenLogFile(szFileName, iType);
        setenv(szEnvKey, szFileName, 1);
    }                

    iLen = strlen(pszData);

    switch(iType)
    {
        case T_TYPE:
            fpFile = fpTLog;
            break;
        case H_TYPE:
            fpFile = fpHLog;
            break;
        case M_TYPE:
            fpFile = fpMLog;
            break;
        default:
            break;
    }

    if (iType == E_TYPE)
    {
        fwrite(pszData, 1, iLen, stderr);
    }
    else
    {
        fwrite(pszData, 1, iLen, fpFile);
        fflush(fpFile);
    }

    return 0;
}

/*****************************************************************
 ** ��    �ܣ���ӡ������־�͸�����־
 ** ���������
 **        fpFile �ļ�ָ��
 **        pszData �������� 
 ** ���������
 **        ��
 ** �� �� ֵ��
 **        �� 
 ** ��    �ߣ�zhangwm
 ** ��    �ڣ�2012/12/03
 ** �޸���־��
 **          1��2012/12/03 ��ʼ���� 
 ****************************************************************/
#ifdef LINUX   
void WriteLog( char* szFileInfo, int iLine, int iType, char* szFmt, ...)
#else                   
WriteLog ( szFileInfo, iLine, iType, szFmt, va_alist )
    char* szFileInfo; 
    int   iLine, iType;
    char* szFmt;
    va_dcl
#endif
{
    va_list args;
    int     iLen;
    FILE*    fpFile;
    char    szMDate[11], szMTime[13], szDate[11], szPsamNo[17];
    char    szLogData[DATA_LEN];

    if ((iType == T_TYPE) && ((IsPrint(DEBUG_TLOG))== NO))
    {
        return;
    }

    memset(szLogData, 0, sizeof(szLogData));

    if (getenv("__EPAY_TRANS_ID_") == NULL)
    {
        strcpy(szPsamNo, "FFFFFFFFFFFFFFFF");    
    }
    else
    {
        strcpy(szPsamNo, getenv("__EPAY_TRANS_ID_"));
    }

    GetSysDate(szDate);

#ifdef LINUX
    va_start(args, szFmt);
#else
    va_start(args);
#endif

    /* �ú�������ʹ�ð�C���Թ淶������ĺ��� */
    GetSysDTFmt("%F", szMDate);
    GetSysDTFmt("%T", szMTime);

    sprintf(szLogData, "%s %s %s(%d) %s: ", szMDate, szMTime, szFileInfo, iLine, szPsamNo);
    iLen = strlen(szLogData);

    vsprintf(szLogData + iLen, szFmt, args);
    strcat(szLogData, "\n");

    if (iType == E_ERROR)
    {
        PrintLog(szLogData, E_TYPE);
    }
    else
    {
        PrintLog(szLogData, T_TYPE);
    }

    return;
}

/*****************************************************************
 ** ��    �ܣ�������־�����ֵĽ�����Ϣ
 ** ���������
 **        pszTransId ��Ҫ���ý������������ַ��� 
 ** ���������
 **        ��
 ** �� �� ֵ��
 **        �� 
 ** ��    �ߣ�zhangwm
 ** ��    �ڣ�2012/12/03
 ** �޸���־��
 **          1��2012/12/03 ��ʼ���� 
 ****************************************************************/
int SetEnvTransId(char* pszTransId)
{
    if (pszTransId == NULL)
    {
        return FAIL;
    }

    setenv("__EPAY_TRANS_ID_", pszTransId, 1);
    
    return SUCC;
}

/*****************************************************************
 ** ��    �ܣ��ж���־�����Ƿ���Ҫ��ӡ
 ** ���������
 **        iType ��־����
 ** ���������
 **        ��
 ** �� �� ֵ��
 **        �� 
 ** ��    �ߣ�zhangwm
 ** ��    �ڣ�2012/12/03
 ** �޸���־��
 **          1��2012/12/03 ��ʼ���� 
 ****************************************************************/
int IsPrint(int iType)
{
    char szDebug[4];
    int iDebug;

    if(getenv("LOG_SWITCH") == NULL)
    {
        iDebug = 15;    
    }
    else
    {
        strcpy(szDebug, getenv("LOG_SWITCH"));
        iDebug = atoi(szDebug);
    }
    if((iDebug & iType) == NO)
    {
        return NO;
    }

    return YES;
}
