/******************************************************************
** Copyright(C)2012 - 2015���������豸���޹�˾
** ��Ҫ���ݣ����屾ϵͳ�����ڴ�ĺ��Լ����������
** �� �� �ˣ������
** �������ڣ�2012/11/8
** ----------------------------------------------------------------
** $Revision: 1.1 $
** $Log: EpayShm.h,v $
** Revision 1.1  2012/12/07 05:47:02  fengw
**
** 1�����libepay����ͷ�ļ���
**
** Revision 1.4  2012/12/03 05:51:01  fengw
**
** 1������GetAppAddress�����������塣
**
** Revision 1.3  2012/11/30 06:53:35  fengw
**
** 1���޸�T_HOST��T_SHM_EPAY�ṹ���壬����T_LOCALCARDS�ṹ���塣
**
** Revision 1.2  2012/11/28 02:27:05  chenrb
** dos2unix ��ʽת��
**
** Revision 1.1  2012/11/28 02:19:52  chenrb
** ��ʼ���汾
**
*******************************************************************/

#ifndef	_EPAY_SHM_
#define _EPAY_SHM_

#include <stdlib.h>

#include "app.h"
#include "user.h"
#include "dbtool.h"
#include "transtype.h"
#include "libpub.h"
#include "EpaySem.h"

#define SHM_FILE                "/etc/SHMFILE"
#define EPAY_SHM_ID             1

/* �������̨�� */
#define MAX_HOST_NUM            50

/* ������ͻ����� */
#define MAX_ACCESS_NUM          60

#define CARD_PAN                1           /* ���� */
#define CARD_TRACK2             2           /* ���ŵ� */
#define CARD_TRACK3             3           /* ���ŵ� */

typedef struct
{
    char    szBankName[21];
    char    szBankId[12];
    char    szCardName[41];
    char    szCardId[20];
    int     iCardNoLen;
    int     iCardSite2;
    int     iExpSite2;
    int     iPanSite3;
    int     iCardSite3;
    int     iExpSite3;
    char    szCardType[2];
    int     iCardLevel;
}T_CARDS;

typedef struct
{
    char    szCardId[16+1];
    char    szCardName[40+1];
    int     iCardNoLen;
    char    szCardType[1+1];
}T_LOCALCARDS;

typedef struct
{
    long    lMsgType;           /* ��Ӧҵ���ύģ��ĵ�һ������(������Ϣ����) */
    int     iLinkNo;            /* ��·��� */
	char	cClitNet;           /* client״̬, 'Y'-������  'N'-δ���� */
	char	cServNet;           /* server״̬, 'Y'-������  'N'-δ���� */
}T_HOST;

typedef struct
{
    long    lLastVisitTime;            /* �������ʱ�䣬Ϊ0����ϵͳ��ǰʱ����ȳ���15��������Է��������������ʹ�� */
}T_TDI;

/* ����IP�봦����̺Ŷ��ձ� */
typedef struct
{
	char    szIp[20];
    long    lPort;
	long	lPid;
}T_ACCESS;

/* �����ڴ����ݽṹ */
typedef struct
{
    int             iCardNum;                       /* �������� */
    T_CARDS         tCards[MAX_CARD_NUM];           /* �������� */
    int             iLocalCardNum;                  /* ���ؿ������� */
    T_LOCALCARDS    tLocalCards[MAX_CARD_NUM];      /* ���ؿ������� */
    T_ACCESS        tAccess[MAX_ACCESS_NUM];        /* ����ͻ������� */
	T_App           tApp[MAX_TRANS_DATA_INDEX];     /* ������������ */
    int             iCurTdi;                        /* ��ǰ���������� */
	T_TDI           tTdi[MAX_TRANS_DATA_INDEX];     /* ����������������ʱ�� */
    T_HOST          tHost[MAX_HOST_NUM];            /* �����̨���� */
}T_SHM_EPAY;

#define SHM_EPAY_SIZE       sizeof(T_SHM_EPAY)

T_SHM_EPAY  *gpShmEpay;
int         giShmEpayID;

extern T_App* GetAppAddress(int iTransDataIdx);

#else

extern T_EPAY   *gpShmEpay;
extern int      giShmEpayID;

#endif
