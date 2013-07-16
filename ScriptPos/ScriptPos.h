#ifndef _SCRIPTPOS_H_
#define _SCRIPTPOS_H_

#include <string.h>
#include <stdio.h>
#include <signal.h>
#include <sys/types.h>
#include <stdlib.h>
#include <time.h>
#include <setjmp.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <malloc.h>
#include <netinet/tcp.h>
#include <errno.h>

#include "app.h"
#include "user.h"
#include "dbtool.h"
#include "transtype.h"
#include "errcode.h"
#include "DbStru.h"
#include "Tlv.h"
#include "EpayShm.h"

#define BUFFSIZE 	        2048

#define MAX_CMD_INDEX       62              /* ���ָ���� */
#define MAX_SP_CMD_INDEX    6               /* ����Զ���ָ���� */
#define MAX_CMD_NAME        64              /* ָ��������󳤶� */

#define MAX_REC_CARD_NUM    14              /* ÿ���ϴ����ŵ�������� */

#define MAX_COMMAND_NUM     100             /* ���ָ������ */

static jmp_buf	env;

T_App* GetTdiAddress(char *szInData, int iLen);

#ifndef _EXTERN_

char    gszaCmdName[MAX_CMD_INDEX][MAX_CMD_NAME+1] =
{
    "����",                     /* 01��ָ�� */
    "��ȫģ���",               /* 02��ָ�� */
    "�ŵ�����",                 /* 03��ָ�� */
    "�ŵ�����",                 /* 04��ָ�� */
    "��������",                 /* 05��ָ�� */
    "��������(ԭ��ˮ��)",       /* 06��ָ�� */
    "���׽��",                 /* 07��ָ�� */
    "����Ӧ�ú�",               /* 08��ָ�� */
    "����Ӧ�ú�",               /* 09��ָ�� */
    "��������(YYYYMMDD)",       /* 0A��ָ�� */
    "����(YYYYMM)",             /* 0B��ָ�� */
    "�Զ�������",               /* 0C��ָ�� */
    "����MAC",                  /* 0D��ָ�� */
    "����ǩ��(�ݲ�ʹ��)",       /* 0E��ָ�� */
    "������Ϣ",                 /* 0F��ָ�� */
    "�ն˳���汾",             /* 10��ָ�� */
    "�ն�Ӧ�ù��ܰ汾",         /* 11��ָ�� */
    "�ն����к�",               /* 12��ָ�� */
    "���ܱ�������",             /* 13��ָ�� */
    "���ܱ�������",             /* 14��ָ�� */
    "�˵�֧������",             /* 15��ָ�� */
    "�����ն˲���",             /* 16��ָ�� */
    "���°�ȫ����",             /* 17��ָ�� */
    "����Ӧ�ò˵�",             /* 18��ָ�� */
    "���¹�����ʾ",             /* 19��ָ�� */
    "���²�����ʾ",             /* 1A��ָ�� */
    "������ҳ��Ϣ",             /* 1B��ָ�� */
    "���´�ӡ��¼",             /* 1C��ָ�� */
    "����(�ݲ�ʹ��)",           /* 1D��ָ�� */
    "�洢�ʵ�",                 /* 1E��ָ�� */
    "��¼��־",                 /* 1F��ָ�� */
    "�洢����",                 /* 20��ָ�� */
    "��ӡ����",                 /* 21��ָ�� */
    "��ʾ�����Ϣ",             /* 22��ָ�� */
    "����ϵͳ",                 /* 23��ָ�� */
    "��������",                 /* 24��ָ�� */
    "��������",                 /* 25��ָ�� */
    "�һ�",                     /* 26��ָ�� */
    "��֤����֧������",         /* 27��ָ�� */
    "��֤MAC",                  /* 28��ָ�� */
    "���Ღ��",                 /* 29��ָ�� */
    "����ȷ��",                 /* 2A��ָ�� */
    "ѡ��̬�˵�",             /* 2B��ָ�� */
    "���¾�̬�˵�",             /* 2C��ָ�� */
    "��̬�˵���ʾ��ѡ��",       /* 2D��ָ�� */
    "�ϴ�����",                 /* 2E��ָ�� */
    "��ʱ��ʾ��Ϣ",             /* 2F��ָ�� */
    "���̿���",                 /* 30��ָ�� */
    "����(�ݲ�ʹ��)",           /* 31��ָ�� */
    "�ļ����ݴ���",             /* 32��ָ�� */
    "��ȡ����",                 /* 33��ָ�� */
    "�ϴ�������־",             /* 34��ָ�� */
    "�ϴ�������־",             /* 35��ָ�� */
    "��ȡ����",                 /* 36��ָ�� */
    "����������",               /* 37��ָ�� */
    "д��������",               /* 38��ָ�� */
    "���¹�����Կ",             /* 39��ָ�� */
    "Ԥ����",                   /* 3A��ָ�� */
    "��ղ˵�",                 /* 3B��ָ�� */
    "�����ط�����",             /* 3C��ָ�� */
    "��Ϣ��ʾ",                 /* 3D��ָ�� */
    "TMS��������"               /* 3E��ָ�� */
};

char    gszaSpecialCmdName[MAX_SP_CMD_INDEX][MAX_CMD_NAME+1] =
{
    "EMV�����汾��",            /* 01��ָ�� */
    "����EMV����",              /* 02��ָ�� */
    "EMV��Կ�汾��",            /* 03��ָ�� */
    "����EMV��Կ",              /* 04��ָ�� */
    "EMV��������",              /* 05��ָ�� */
    "EMV��������"               /* 06��ָ�� */
};

int giEachPackMaxBytes, giMacChk;
int giSock, giDispMode, giHolderNameMode, giTimeoutTdi;
char gszWebIp[25], gszAuthKey[17], gszAcqBankId[12], gszWebPort[5+1];

#else

extern int giEachPackMaxBytes, giMacChk;
extern int giSock, giDispMode, giHolderNameMode, giTimeoutTdi;
extern char gszWebIp[25], gszAuthKey[17], gszAcqBankId[12], gszWebPort[5+1];
extern char gszaCmdName[MAX_CMD_INDEX][MAX_CMD_NAME+1];
extern char gszaSpecialCmdName[MAX_SP_CMD_INDEX][MAX_CMD_NAME+1];

#endif
#endif