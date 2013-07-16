/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ�ģ��POS����
** �� �� �ˣ�
** �������ڣ�
**
** $Revision
** $Log
*******************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <sys/timeb.h>
#include <time.h>
#include <errno.h>
#include <setjmp.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>

#include "user.h"
#include "dbtool.h"

EXEC SQL BEGIN DECLARE SECTION;
EXEC SQL INCLUDE SQLCA;
EXEC SQL include "../incl/DbStru.h";
EXEC SQL END DECLARE SECTION;

#define DBGMODE
#define SCOUNIX
#define SINGLE_DES   1     /* DES */
#define TRIPLE_DES   2     /* 3DES */

/* ��󲢷��� */
#define MAX_POS_NUM    100

/* ���ذ�����λ�ú궨�� */
#define RETURN_POS    66
#define TRACE_POS    50
#define PIN_KEY_POS    83
#define MAC_KEY_POS    105

const int REQ_PSAM_POS=57;
const int REQ_TRACE_POS=73;
const int REQ_TRACK2_POS=94;
const int REQ_TRACK3_POS=114;
const int REQ_PIN_POS=172;
const int REQ_MAC_POS=180;

const int RSP_TRACE_POS=56;
const int RSP_PIN_KEY_POS=89;
const int RSP_MAC_KEY_POS=121;

const int REQ_MAC_SKIP=14;

#define MAXBUFF        4096

#define SA struct sockaddr

typedef struct sockaddr * P_ST_SA;

/* ȫ�� Socket ��� */
int giSockId;

/* ȫ�ֱ�����ʱ����ʼʱ�� */
unsigned long glBeginTime;

int giSleepTime;

/* ȫ�ֱ���, ʱ���� */
char    gszMasterKey[17];

/* ͨ��������Ϣ */
struct T_CommInfo{
    char szHostIP[16];    /*���� IP ��ַ*/
    int iHostPort;        /*��������˿�*/
};

struct T_CommInfo tCommStru = {0};

/* ȫ�ֱ���������ˮ�� */
int    giMaxNum;

/* ���ò�����Ϣ */
struct T_ParamInfo {
    unsigned char szSecureUnit[16+1];    /*��ȫģ���*/
    unsigned char pin_key[16+1];        /*PIN��Կ*/
    unsigned char mac_key[16+1];        /*MAC��Կ*/
    unsigned char szTrack2[19+1];        /*���ŵ�����*/
    unsigned char szTrack3[52+1];        /*���ŵ�����*/
    unsigned char szPIN[6+1];        /* PIN ��������*/
    int    iTrace;
    int    iNextTrace;        /*��һ����ʼ��ˮ��*/
};

struct T_ParamInfo tParamStru[MAX_POS_NUM];

typedef struct T_ParamInfo T_ParamInfo;

unsigned char guszLoginPacket[1024]=
"\x60\x00\x05\x00\x10"
"\x01"
"\x00\x00"
"\x01"
"\x01"
"\x01"
"\x01"
"\x00\x55"
"\x02"
"\x00"
"\x20\x12"
"\x07\x10\x23\x04"
"\x20\x12\x12\x15"
"\x4c\x41\x4e\x44\x49\x20\x20\x20\x20\x20"
"\x8d\x91\x46\x53"
"\x31\x36\x37\x33\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20"
"\x30"
"\x30\x31\x31\x30\x34\x37\x30\x36\x30\x30\x30\x30\x30\x30\x30\x31"
"\x00\x00\x01"
"\x00\x00\x00\x05"
"\x01\x82\x00\x10\x30"
"\x31\x31\x30\x34\x37\x30\x36\x30\x30\x30\x30\x30"
"\x30\x30\x31";

unsigned char guszTermPacket[] = 
{0x60, 0x08, 0x08, 0x82, 0x78, 0x01, 0x00, 0x00, 0x38, 0x30, 0x30, 0x38, 0x36, 0x30, 0x30, 0x37,
0x37, 0x30, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x8c, 0x02, 0x00, 0x20, 0x01, 0x20, 0x10, 0x06,
0x26, 0x30, 0x30, 0x39, 0x33, 0x4c, 0x31, 0x37, 0x4c, 0x35, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30,
0x32, 0x37, 0x00, 0x11, 0x17, 0x00, 0x00, 0x01, 0x01, 0x04, 0x03, 0x06, 0x07, 0x12, 0xc5, 0x07,
0x81, 0xcd, 0x00, 0xc0, 0x00, 0x5f, 0x25, 0x90, 0x03, 0x09, 0x10, 0x00, 0x36, 0x26, 0x96, 0xd0,
0x00, 0x05, 0x01, 0x00, 0x00, 0x00, 0x00, 0x18, 0x67, 0x90, 0x68, 0x99, 0x90, 0x03, 0x09, 0x10,
0x00, 0x36, 0x26, 0x96, 0xd1, 0x56, 0x15, 0x60, 0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x30,
0x00, 0x00, 0x02, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xd0,
0x00, 0x00, 0x00, 0x00, 0x00, 0x0d, 0x00, 0x18, 0x67, 0x90, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
0x00, 0x00, 0x00, 0x00, 0x01, 0xd4, 0x62, 0xb8, 0x64, 0x57, 0xdf, 0xce, 0xbb, 0x2b, 0x1d, 0xf5,
0xb8, 0x8c, 0xb2, 0x91, 0x72};

unsigned char CheckValue[] = {0x30, 0x30};

const int LOGIN_PACK_SIZE=100;

#define PACKET_LEN    sizeof(guszTermPacket)

int ChildProc(int iPosNum, int iTotalNum);
int ParentProc(int iPosNo, int iTotalNum);
void PackingData(int iPosNo, unsigned char * szBuff);
int InitParamTable();

/*******************************************
 * ��ȫ�˳�����
 *******************************************/
void safe_exit(int exit_parm)
{
    WriteLog(TRACE, "simulate program terminates : %d", exit_parm);
    close(giSockId);
    CloseDB();
    exit(exit_parm);
}

/*****************************************************************
 ** ��    �ܣ���΢��Ϊ��λ����ʱ��
 ** ���������
 ** ���������
 ** �� �� ֵ��
 **         ��΢��Ϊ��λ��ʱ��
 ** ��    �ߣ�
 ** ��    �ڣ�
 ** �޸���־��
 ****************************************************************/
unsigned long GetMillTime( )
{
    struct timeb tp;
    struct tm *ptm;
    unsigned long lTime;

    ftime ( &tp );
    ptm = localtime (  & ( tp.time )  );

    lTime = (ptm->tm_hour)*3600000
            + (ptm->tm_min)*60000+(ptm->tm_sec)*1000+tp.millitm;
    
    return ( lTime );
}

int main(int argc, char ** argv)
{
    int i;
    int iRet, iLen, iSndLen, iRecLen, iSleepTime;
    int iPosNum, iTotalNum, iBeginTrace, iHostPort;
    char szTmpBuf[1024], szSndBuf[1024];
    char szTime[50], szTmpStr[100];
    char szBcdPinKey[17], szBcdMacKey[17], szTmk[17];
    char cEnter;
    pid_t pid;
    struct sockaddr_in tServAddr;
    
    EXEC SQL BEGIN DECLARE SECTION;
    T_TERMINAL tTerminal;
    T_POS_KEY tPosKey;
    int iKeyIndex;
    char szTermId[9];
    char kk[100];
    EXEC SQL END DECLARE SECTION;

    for( i = 0; i < 32; i++ ){
        if( i == SIGALRM || i == SIGKILL || 
            i == SIGUSR1 || i == SIGUSR2 )
            continue;
        signal( i, SIG_IGN );
    }

    signal( SIGKILL, safe_exit);
    signal( SIGUSR1, safe_exit);

    /* �����ʼ��������ʧ�ܾ��˳� */
    if (InitParamTable() != 0) 
    {
        WriteLog( ERROR, "init param fail" );
        exit(0);
    }

    iRet = GetMasterKey( gszMasterKey );
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "read key fail" );
        exit(0);
    }
    giSockId = CreateCliSocket(tCommStru.szHostIP, tCommStru.iHostPort);
    if( giSockId < 0 )
    {
        WriteLog(ERROR, "create connect failed errno[%d]", errno);
#ifdef DBGMODE
        printf("create connect failed errno[%d] \n", errno);
#endif
        close(giSockId);
        exit(0);
    }

    if( OpenDB() )
    {
        WriteLog( ERROR, "open database fail [%ld]!!", SQLCODE );
        close( giSockId );
        exit(0);
    }

    EXEC SQL DECLARE func_cur CURSOR 
        FOR SELECT * FROM terminal WHERE status = 0 ORDER BY psam_no;
    if( SQLCODE )
    {
        WriteLog( ERROR, "declare cur fail %ld", SQLCODE );
        close( giSockId );
        CloseDB();
        exit(0);
    }

    EXEC SQL OPEN func_cur;
    if( SQLCODE )
    {
        WriteLog( ERROR, "open func_cur fail %ld", SQLCODE );
        close( giSockId );
        CloseDB();
        exit(0);
    }

    iLen = strlen(guszLoginPacket);
    iSndLen = iLen/2;
    giMaxNum = 0;
    while(1)
    {
        EXEC SQL FETCH func_cur INTO :tTerminal;
        if( SQLCODE == SQL_NO_RECORD || giMaxNum == MAX_POS_NUM )
        {
            EXEC SQL close func_cur;
            break;
        }
        else if( SQLCODE )
        {
            WriteLog( ERROR, "fetch func_cur fail %ld", SQLCODE );
            EXEC SQL CLOSE func_cur;
            CloseDB();
            return FAIL;
        }

        /* ��ǩ���� */
        memcpy(szTmpBuf, guszLoginPacket, LOGIN_PACK_SIZE);
        memcpy(szTmpBuf + REQ_PSAM_POS, tTerminal.szPsamNo, 16 );

        szSndBuf[0] = iSndLen/256;
        szSndBuf[1] = iSndLen%256;
        memcpy( szSndBuf+2, szTmpBuf, iSndLen );

        /* ���ͱ�����Ϣ������ */
        iRet = WriteSock(giSockId, szSndBuf, iSndLen+2, 0);
        if(iRet <= 0) 
        {
            WriteLog(ERROR, "send data failed : %d", errno);
#ifdef DBGMODE
            printf("send data failed : %d\n", errno);
#endif
            close(giSockId);
            EXEC SQL CLOSE func_cur;
            CloseDB();
            exit(0);
        }

        if( (iRet = ReadSockFixLen(giSockId, 0, 2, szTmpBuf)) < 0 ){
            WriteLog( ERROR, "recv length fail" );
            printf( "recv length fail\n" );
            close( giSockId );
            EXEC SQL CLOSE func_cur;
            CloseDB();
            return FAIL;
        }
        iRecLen = (unsigned char)szTmpBuf[0]*256+
                (unsigned char)szTmpBuf[1];
           iRet = ReadSockVarLen(giSockId, 5, szTmpBuf);
        if( iRet != iRecLen )
        {
            printf( "recv data fail\n" );
            WriteLog( ERROR, "recv data fail %ld", errno );
            close( giSockId );
            EXEC SQL CLOSE func_cur;
            CloseDB();
            return FAIL;
        }

        /* ǩ���ɹ� */
        if( memcmp(szTmpBuf+RETURN_POS, "00", 2) == 0 )
        {
            printf( "%s ǩ���ɹ�!\n", tTerminal.szPsamNo );

            strcpy(tParamStru[giMaxNum].szSecureUnit, tTerminal.szPsamNo );
            memcpy( szTmpStr, tTerminal.szPsamNo+8, 8 );
            szTmpStr[8] = 0;
            iKeyIndex = atol(szTmpStr);

            /* ȡ��ˮ�� */
            BcdToAsc( szTmpBuf+TRACE_POS, 6, 0, szTmpStr );
            szTmpStr[6] = 0;
            tParamStru[giMaxNum].iTrace = atol(szTmpStr);

            tParamStru[giMaxNum].iNextTrace = tParamStru[giMaxNum].iTrace;

            /* ȡPinKey��MacKey���� */
            memcpy( szBcdPinKey, szTmpBuf+PIN_KEY_POS, 16 );
            memcpy( szBcdMacKey, szTmpBuf+MAC_KEY_POS, 16 );

            EXEC SQL SELECT * INTO :tPosKey FROM pos_key WHERE key_index = :iKeyIndex;
            if( SQLCODE == SQL_NO_RECORD )
            {
                WriteLog( ERROR, "pos_key[%d] not exist", iKeyIndex );
                continue;
            }
            else if( SQLCODE )
            {
                WriteLog( ERROR, "select pos_key fail[%ld]", SQLCODE );
                continue;
            }
            
            /* �����ն�����Կ */
            AscToBcd(tPosKey.szMasterKey, 32, 0, szTmpBuf);
            _TriDES( gszMasterKey, szTmpStr, szTmk );
            _TriDES( gszMasterKey, szTmpStr+8, szTmk+8 );

            /* ����PinKey */
            _TriDES( szTmk, szBcdPinKey, tParamStru[giMaxNum].pin_key );
            _TriDES( szTmk, szBcdPinKey+8, tParamStru[giMaxNum].pin_key+8 );

            /* ����MacKey */
            _TriDES( szTmk, szBcdMacKey, tParamStru[giMaxNum].mac_key );
            _TriDES( szTmk, szBcdMacKey+8, tParamStru[giMaxNum].mac_key+8 );

            giMaxNum ++;
        }
    }
    CloseDB();
    
    /* ����ѭ�� */
    while (1) {
        do {
            do {
                printf("1����ʼ����\n");
                printf("2����    ��\n");
                printf("��ѡ��: \n");

                memset(szTmpBuf, 0x00, sizeof(szTmpBuf));
                scanf("%s", szTmpBuf);
                cEnter = szTmpBuf[0];
            } while(cEnter < '1' || cEnter > '2');

            if (cEnter == '2') {
                // doing some thing ...
                close( giSockId );
                exit( 0 );
            }

            printf( "������POS��(���%d̨): \n", giMaxNum );
            do{
                memset(szTmpBuf, 0x00, sizeof(szTmpBuf));
                scanf("%s", szTmpBuf);
                if (IsNumber(szTmpBuf) == 0) 
                {
                    printf( "��������, �벻Ҫ�����������������ַ�!\n" );
                    printf( "����������POS��(���%d̨): \n", giMaxNum );
                    continue;
                }
                iPosNum = atoi(szTmpBuf);
                if( iPosNum > giMaxNum )
                {
                    printf( "�������ݳ���!\n" );
                    printf( "����������POS��(���%d̨): \n", giMaxNum );
                }
                if( iPosNum == 0 )
                {
                    printf( "�������ݲ���Ϊ0\n" );
                    printf( "����������POS��(���%d̨): \n", giMaxNum );
                }
            }while( iPosNum > giMaxNum );

            printf( "������ÿ̨POS������: \n" );
            do{
                memset(szTmpBuf, 0x00, sizeof(szTmpBuf));
                scanf("%s", szTmpBuf);
                if (IsNumber(szTmpBuf) == 0) 
                {
                    printf( "��������, �벻Ҫ�����������������ַ�!\n" );
                    printf( "����������ÿ̨POS������: \n" );
                    continue;
                }
                iTotalNum = atoi(szTmpBuf);
                if( iTotalNum >= 1 )
                {
                    break;
                }
                else
                {
                    printf( "��������\n" );
                    printf( "����������ÿ̨POS������: \n" );
                }
            }while( 1 );

            printf( "������ʱ������ \n" );
            do{
                memset(szTmpBuf, 0x00, sizeof(szTmpBuf));
                scanf("%s", szTmpBuf);
                if (IsNumber(szTmpBuf) == 0) 
                {
                    printf( "��������, �벻Ҫ�����������������ַ�!\n" );
                    printf( "����������ʱ������\n" );
                    continue;
                }
                giSleepTime = atoi(szTmpBuf);
                if( giSleepTime >= 1 )
                {
                    break;
                }
                else
                {
                    printf( "��������\n" );
                    printf( "����������ʱ������\n" );
                }
            }while( 1 );

            for( i=0; i<MAX_POS_NUM; i++ )
            {
                tParamStru[i].iTrace = tParamStru[i].iNextTrace;

                tParamStru[i].iNextTrace =
                tParamStru[i].iTrace + iTotalNum; 
            }

            /* ��¼���Կ�ʼʱ�� */
            glBeginTime = GetMillTime();
WriteLog( TRACE, "begin time %ld", glBeginTime );

            /* �����½��� */
            pid = fork();
            switch(pid) {
            case    -1:
                /* doing some thing close */
                WriteLog(ERROR, "can not fork" );
#ifdef DBGMODE
                printf("can not fork\n");
#endif
                close(giSockId);
                exit(0);
                break;
            case    0:
                /* �ӽ��̴��� */
                ChildProc(iPosNum, iTotalNum);
                close(giSockId);

                fflush(stdin);
                fflush(stdout);
                exit(0);
                break;
            default:
                /* �����̴��� */
                iRet = ParentProc(iPosNum, iTotalNum);
                break;
            }
        } while(iRet == SUCC);

        giSockId = CreateCliSocket(tCommStru.szHostIP, tCommStru.iHostPort);
        if( giSockId < 0 )
        {
            WriteLog(ERROR, "create connect failed errno[%d]", errno);
            printf("create connect failed errno[%d] \n", errno);
            close(giSockId);
            exit(0);
        }
    }
}

/*****************************************************************
 ** ��    �ܣ��ӽ��̴�����
 ** ���������
 **          iPosNum:POS��
 **          iTotalNum:��̨������
 ** ���������
 ** �� �� ֵ��
 ** ��    �ߣ�
 ** ��    �ڣ�
 ** �޸���־��
 ****************************************************************/
int ChildProc( int iPosNum, int iTotalNum )
{
    int pid, i, iRet;

    for( i = 0; i<iPosNum; i++ ){
        pid = fork();
        switch( pid ){
        case -1:
            WriteLog( ERROR, "fork child[%ld] fail %ld", i+1, errno );
            printf( "fork child[%ld] fail %ld\n", i+1, errno );
            close(giSockId);
            exit(0);
        case 0:
            iRet = SingleChildProc( i, iTotalNum );
            close(giSockId);
            exit(0);
        default:
            break;
        }
    }
    if( pid > 0 )
    {
        close(giSockId);
        exit(0);
    }
}

/*****************************************************************
 ** ��    �ܣ�ͨѶ������
 ** ���������
 **          iPosNum:POS��
 **          iTotalNum:��̨������
 ** ���������
 ** �� �� ֵ��
 ** ��    �ߣ�
 ** ��    �ڣ�
 ** �޸���־��
 ****************************************************************/
int SingleChildProc(int iPosNo, int iTotalNum)
{
    int i, iRet;
    unsigned char szBuffer[1024];
    
    for( i = 0; i < 32; i++ ){
        if( i == SIGALRM || i == SIGKILL || 
            i == SIGUSR1 || i == SIGUSR2 )
            continue;
        signal( i, SIG_IGN );
    }

    for (i=0; i<iTotalNum; i++) 
    {
        /* ��� */
        memset(szBuffer, 0x00, sizeof(szBuffer));
        PackingData(iPosNo, szBuffer);

        /* ���ͱ�����Ϣ������ */
        iRet = WriteSock(giSockId, szBuffer, PACKET_LEN+2);
        if(iRet <= 0) 
        {
            WriteLog(ERROR, "send data failed : %d", errno);
#ifdef DBGMODE
            printf("send data failed : %d\n", errno);
#endif
            close(giSockId);
            exit(0);
        }

        sleep( giSleepTime );
    }

    return(0);
}

/*****************************************************************
 ** ��    �ܣ������̴�����
 ** ���������
 **          iPosNum:POS��
 **          iTotalNum:��̨������
 ** ���������
 ** �� �� ֵ��
 ** ��    �ߣ�
 ** ��    �ڣ�
 ** �޸���־��
 ****************************************************************/
int ParentProc(int iPosNum, int iTotalNum)
{
    int flag, iTimeOut, i, iLen, iTotal, iSuccNum, iFailNum, iRet;
    char szTmpBuf[1024], szTmpStr[100];
    unsigned long lTotalTime, lEachTime, lEndTime;
    float fTotalTime, fNum;

    iTotal = iPosNum*iTotalNum;

    signal(SIGUSR1, safe_exit);
    signal(SIGUSR2, safe_exit);
    signal(SIGKILL, safe_exit);

    iSuccNum = 0;
    iFailNum = 0;
    iTimeOut = 20;
    flag = SUCC;

    for( i = 0; i < iTotal; i++ )
    {
        if( (iRet = ReadSockFixLen(giSockId, iTimeOut, 2, szTmpBuf)) < 0 ){
            WriteLog( ERROR, "recv length fail" );
            printf( "recv length fail\n" );
            flag = FAIL;
            break;
        }
        iLen = (unsigned char)szTmpBuf[0]*256+(unsigned char)szTmpBuf[1];
           iRet = ReadSockVarLen(giSockId, iTimeOut, szTmpBuf);
        if( iRet != iLen )
        {
            printf( "recv data fail\n" );
            WriteLog( ERROR, "recv data fail %ld", errno );
            close( giSockId );
            return FAIL;
        }

        if( memcmp(szTmpBuf+68, "00", 2) == 0 )
        {
            iSuccNum ++;
            printf( "SuccNum[%ld] FailNum[%ld] RetCode[00]\n", iSuccNum, iFailNum );
        }
        else
        {
            iFailNum ++;
            printf( "SuccNum[%ld] FailNum[%ld] RetCode[%2.2s]\n", iSuccNum, iFailNum, szTmpBuf+64 );
        }
    }

    lEndTime = GetMillTime();
    if( i < iTotal )
    {
        lEndTime = lEndTime-iTimeOut*1000;
    }
WriteLog( TRACE, "End time %ld", lEndTime );
    
    lTotalTime = lEndTime-glBeginTime;
    fTotalTime = (float)lTotalTime;
    fNum = ((float)iTotal)/(fTotalTime/1000.0);

    WriteLog( ERROR, "��[%ld]̨POS�������ף�ÿ̨����Ϸ���[%ld]�ʽ��ף���[%ld]��",
iPosNum, iTotalNum, iTotal ); 
    WriteLog( ERROR, "�ɹ�[%ld]�� ʧ��[%ld]�� ��ʱ[%ld]�� ��ʱ%ld���� %ld����/�� %.2f��/��", iSuccNum, iFailNum, iTotal-(iSuccNum+iFailNum), lTotalTime, lTotalTime/iTotal, fNum );
    printf( "��[%ld]̨POS�������ף�ÿ̨����Ϸ���[%ld]�ʽ��ף���[%ld]��\n",
iPosNum, iTotalNum, iTotal ); 
    printf( "�ɹ�[%ld]�� ʧ��[%ld]�� ��ʱ[%ld]�� ��ʱ%ld���� %ld����/�� %.2f��/��\n", iSuccNum, iFailNum, iTotal-(iSuccNum+iFailNum), lTotalTime, lTotalTime/iTotal, fNum );

    return(flag);
}

/*****************************************************************
 ** ��    �ܣ��������
 ** ���������
 **          iPosNo:POS���
 ** ���������
 **          szOutData:����������
 ** �� �� ֵ��
 ** ��    �ߣ�
 ** ��    �ڣ�
 ** �޸���־��
 ****************************************************************/
void PackingData(int iPosNo, unsigned char *szOutData)
{
    int iRet, iMacDataLen, iLen;
    unsigned char szPan[50], szMacData[1024], szMac[9];
    unsigned char szEncryptPin[24], szBuff[1024];
    unsigned char szTraceNo[7];

    /* �Ӷ��ŵ���ȡ��PAN */
    memset(szPan, 0x00, sizeof(szPan));
    getAccNoFromTrackData(tParamStru[iPosNo].szTrack2, szPan);

    /* ����PIN���� */
    memset(szEncryptPin, 0x00, sizeof(szEncryptPin));
    iRet = ANSIX98(szEncryptPin, tParamStru[iPosNo].pin_key, tParamStru[iPosNo].szPIN, szPan, 6, TRIPLE_DES);
    if (iRet != 0) 
    {
        WriteLog(ERROR, "encrypt pin failed!" );
#ifdef DBGMODE    
        printf("encrypt pin failed!\n" );
#endif
        return;
    }

    /* ȡ������ˮ��(ASC��) */
    memset(szTraceNo, 0x00, sizeof(szTraceNo));
    sprintf(szTraceNo, "%06ld", tParamStru[iPosNo].iTrace);
    tParamStru[iPosNo].iTrace++;

    /* �齻�ױ��İ� */
    memcpy(szBuff, guszTermPacket, PACKET_LEN);

    iMacDataLen = ((unsigned char)szBuff[23])*256 + 
           (unsigned char)szBuff[24];    //��Ϣ����
    iMacDataLen = iMacDataLen-8;                //�۳�MAC8���ֽ�

    /* ��ȫģ��� offset=34 */
    memcpy(szBuff+REQ_PSAM_POS, tParamStru[iPosNo].szSecureUnit, 16);

    /* ��ˮ�� 50 */
    AscToBcd(szTraceNo, 6, 0, szBuff+REQ_TRACE_POS);

    /* ���ŵ� */
    memcpy(szBuff+REQ_TRACK2_POS, tParamStru[iPosNo].szTrack2, 19);

    /* ���ŵ� */
    memcpy(szBuff+REQ_TRACK3_POS, tParamStru[iPosNo].szTrack3, 52);

    /* ���� */
    memcpy(szBuff+REQ_PIN_POS, szEncryptPin, 8);

    /* ����MAC */
    memcpy( szMacData, szBuff+REQ_MAC_SKIP, iMacDataLen );
    Mac_Normal(tParamStru[iPosNo].mac_key, szMacData, iMacDataLen, szMac, 
        TRIPLE_DES);

    /* MAC */
    memcpy(szBuff+REQ_MAC_POS, szMac, 8);

    iLen = PACKET_LEN;    

    szOutData[0] = iLen/256;    
    szOutData[1] = iLen%256;    
    memcpy( szOutData+2, szBuff, iLen );
}

/*****************************************************************
 ** ��    �ܣ���ʼ���������ñ�
 ** ���������
 ** ���������
 ** �� �� ֵ��
 ** ��    �ߣ�
 ** ��    �ڣ�
 ** �޸���־��
 ****************************************************************/
 #define CONFIG_FILE "Simconfig"
 #define CONFIG_SECTION "simpos"
 
int InitParamTable()
{
    int i;
    int iRet;
    char szTmpBuf[1024], szFieldName[100];
    unsigned char szTmp[200];

    /* ��ʼ��ʼ������,��ȡ�����ļ��еĲ��� */
    printf("\nBegin param init ... \n");

    memset(&tCommStru, 0x00, sizeof(tCommStru));
    
    memset(szTmpBuf, 0x00, 100);
    memset(szFieldName, 0x00, sizeof(szFieldName));
    strcpy(szFieldName, "HostIP");
    iRet = ReadConfig( CONFIG_FILE, CONFIG_SECTION, szFieldName, szTmpBuf );
    if (iRet != 0)    {    /*���ɹ��Ļ�*/
        WriteLog( ERROR, "Simconfig�������ô���[%s]", szFieldName);
        return(-1);
    }
    strcpy(tCommStru.szHostIP, szTmpBuf);

    memset(szTmpBuf, 0x00, 100);
    memset(szFieldName, 0x00, sizeof(szFieldName));
    strcpy(szFieldName, "HostPORT");
    iRet = ReadConfig( CONFIG_FILE, CONFIG_SECTION, szFieldName, szTmpBuf );
    if (iRet != 0)    {    /*���ɹ��Ļ�*/
        WriteLog( ERROR, "Simconfig�������ô���[%s]", szFieldName);
        return(-1);
    }
    tCommStru.iHostPort = atoi(szTmpBuf);

    /*���ṹ��������*/
    memset(tParamStru, 0x00, sizeof(tParamStru)*MAX_POS_NUM);

    /*ѭ����ȡ�������ñ��е�ֵ*/
    for (i=0; i<MAX_POS_NUM; i++) {
        memset(szTmpBuf, 0x00, 100);
        memset(szFieldName, 0x00, sizeof(szFieldName));
        sprintf(szFieldName, "Track2_%d", i+1);
        
        iRet = ReadConfig( CONFIG_FILE, CONFIG_SECTION, szFieldName, szTmpBuf );
        if (iRet != 0)    {    /*���ɹ��Ļ�*/
            WriteLog( ERROR, "Simconfig�������ô���[%s]", szFieldName);
            return(-1);
        }
        AscToBcd(szTmpBuf, 19, 0, tParamStru[i].szTrack2);

        memset(szTmpBuf, 0x00, 100);
        memset(szFieldName, 0x00, sizeof(szFieldName));
        sprintf(szFieldName, "Track3_%d", i+1);
        
        iRet = ReadConfig( CONFIG_FILE, CONFIG_SECTION, szFieldName, szTmpBuf );
        if (iRet != 0)    {
            WriteLog( ERROR, "Simconfig�������ô���[%s]", szFieldName);
            return(-1);
        }
        AscToBcd(szTmpBuf, 52, 0, tParamStru[i].szTrack3);

        strcpy(tParamStru[i].szPIN, "000000");
    }
    printf("\nread param succ... \n");

    return(0);
}

/*****************************************************************
 ** ��    �ܣ��Ӵŵ����ݻ�ȡ�ʻ���
 ** ���������
 **           szTrackData:�ŵ�������Ϣ
 ** ���������
 **           szAccNo:��ȡ�����ʻ���
 ** �� �� ֵ��
 ** ��    �ߣ�
 ** ��    �ڣ�
 ** �޸���־��
 ****************************************************************/
#define MAX_ACCOUNT_NO_LEN 19
void getAccNoFromTrackData(char * szTrackData, char * szAccNo)
{
	char szTrackDataAsc[200] = {0};
	int i;
	BcdToAsc(szTrackDataAsc,80,0,szTrackData);
	for (i=0;i<MAX_ACCOUNT_NO_LEN+1;i++)
	{
		if (szTrackDataAsc[i]=='D')
			break;
	}
	memcpy(szAccNo,szTrackDataAsc,i);
}
