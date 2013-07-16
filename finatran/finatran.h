/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ��ͷ�ļ�
** �� �� �ˣ����
** �������ڣ�2012-11-08
**
** $Revision: 1.15 $
** $Log: finatran.h,v $
** Revision 1.15  2013/06/14 02:33:14  fengw
**
** 1������ǩ�����ס�
**
** Revision 1.14  2013/06/07 02:14:40  fengw
**
** 1�������Ƿ��������ж���ش��롣
**
** Revision 1.13  2013/03/29 02:52:34  fengw
**
** 1������EMV����ѯ���״��������塢EMV���ѳ��������״���������ȡ�
**
** Revision 1.12  2013/03/11 07:09:43  fengw
**
** 1������EMV���ѽ��ס�
** 2�����������Ƿ��ͺ�̨��־λ��
**
** Revision 1.11  2013/02/21 06:37:32  fengw
**
** 1�����ӿ��л���ѯ�����л��ס�
**
** Revision 1.10  2013/01/18 08:24:23  fengw
**
** 1������Ԥ��Ȩ���״��������塢���Žɷѽ��״���������ȡ�
**
** Revision 1.9  2012/12/25 06:54:43  fengw
**
** 1���޸�web���׼��ͨѶ�˿ںű�������Ϊ�ַ�����
**
** Revision 1.8  2012/12/17 02:38:33  fengw
**
** 1�����������궨������../incl/errcode.h��
**
** Revision 1.7  2012/12/14 06:31:50  fengw
**
** 1������SECTION_PUBLIC�궨�塣
**
** Revision 1.6  2012/12/07 05:57:44  fengw
**
** 1��ɾ��public.h�����ã�����stdio.h��string.h�����á�
**
** Revision 1.5  2012/12/07 02:01:44  fengw
**
** 1������web���ip��ַ���˿ں�ȫ�ֱ������������ú궨�塣
**
** Revision 1.4  2012/12/04 01:24:28  fengw
**
** 1���滻ErrorLogΪWriteLog��
**
** Revision 1.3  2012/11/26 01:33:05  fengw
**
** 1���޸��ļ�����׺Ϊec�������ϴ���ģ�����
**
** Revision 1.1  2012/11/21 07:20:46  fengw
**
** ���ڽ��״���ģ���ʼ�汾
**
*******************************************************************/

#ifndef _FINATRAN_H_
#define _FINATRAN_H_

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>

#include "app.h"
#include "user.h"
#include "dbtool.h"
#include "transtype.h"
#include "errcode.h"


/* �궨�� */
#define CONF_GET_SUCC           0           /* ��ѯ��������ɹ� */
#define CONF_GET_FAIL           -1          /* ��ѯ��������ʧ�� */
#define CONF_NOT_FOUND          1           /* δ�ҵ��������� */

#define SHOP_FEE_CONF           0           /* �̻������Ѷ��� */
#define DEPT_FEE_CONF           1           /* ���������Ѷ��� */

#define FEE_CALC_NOT            0           /* ������������ */
#define FEE_CALC_RATE           1           /* �����ʼ��������� */
#define FEE_CALC_INTERVAL       2           /* ��������������� */

#define CONFIG_FILENAME         "Setup.ini"
#define SECTION_COMMUNICATION   "SECTION_COMMUNICATION"
#define SECTION_PUBLIC          "SECTION_PUBLIC"

#define NOT_SEND                0           /* ������ */
#define SEND                    1           /* ���� */

/* ���ײ����ṹ���� */
typedef struct
{
    double  dAmountSingle;                  /* �����޶� */
    double  dAmountSum;                     /* �����ۼ��޶� */
    int     iMaxCount;                      /* ��������ױ��� */
    double  dCreditAmountSingle;            /* ���ÿ������޶� */
    double  dCreditAmountSum;               /* ���ÿ������ۼ��޶� */
    int     iCreditMaxCount;                /* ���ÿ���������ױ��� */
    char    szCardTypeOut[9+1];             /* ת������ɿ����� */
    char    szCardTypeIn[9+1];              /* ת�뿨��ɿ����� */
    int     iFeeCalcType;                   /* �����Ѽ��㷽ʽ */
} T_EpayConf;

/* ���״�����ָ��ṹ���� */
typedef struct
{
    int     iTransType;                     /* �������� */
    char    szTransName[64+1];              /* �������� */
    int     (*pFuncPre)(T_App*);            /* ��������ָ�� */
    int     (*pFuncPost)(T_App*);           /* Ӧ������ָ�� */
    int     iSendToHost;                    /* ���ͺ�̨��־ */
} T_TransProc;

#ifndef _EXTERN_

    /* ���״��������� */
    /* ǩ������ */
    extern int LoginPreTreat(T_App*);
    extern int LoginPostTreat(T_App*);

    /* ���ѽ��� */
    extern int PurchasePreTreat(T_App*);
    extern int PurchasePostTreat(T_App*);
    
    /* EMV���ѽ����������� */
    extern int EmvPurTransPreTreat(T_App*);
    extern int EmvPurTransPostTreat(T_App*);

    /* EMV�����������ݴ��� */
    extern int EmvPurOnlinePreTreat(T_App*);
    extern int EmvPurOnlinePostTreat(T_App*);

    /* EMV����ѯ */
    extern int EmvInqueryPreTreat(T_App*);
    extern int EmvInqueryPostTreat(T_App*);
    
    /* EMV���ѳ��� */
    extern int EmvPurCancelPreTreat(T_App*);
    extern int EmvPurCancelPostTreat(T_App*);
    
    /* Ԥ��Ȩ���� */
    extern int PreAuthPreTreat(T_App*);
    extern int PreAuthPostTreat(T_App*);

    /* ��ѯ���� */
    extern int InqueryPreTreat(T_App*);
    extern int InqueryPostTreat(T_App*);

    /* �������� */
    extern int PurCancelPreTreat(T_App*);
    extern int PurCancelPostTreat(T_App*);

    /* �������� */
    extern int AutoVoidPreTreat(T_App*);
    extern int AutoVoidPostTreat(T_App*);

    /* �˻����� */
    extern int RefundPreTreat(T_App*);
    extern int RefundPostTreat(T_App*);

    /* Ԥ��Ȩ��ɽ��� */
    extern int ConfirmPreTreat(T_App*);
    extern int ConfirmPostTreat(T_App*);

    /* ת��ת��Ԥ��ѯ���� */
    extern int TranOutQueryPreTreat(T_App*);
    extern int TranOutQueryPostTreat(T_App*);

    /* ת��ת�˽��� */
    extern int TranOutPreTreat(T_App*);
    extern int TranOutPostTreat(T_App*);


    /* ����ת��Ԥ��ѯ���� */
    extern int TranOtherQueryPreTreat(T_App*);
    extern int TranOtherQueryPostTreat(T_App*);

    /* ����ת�˽��� */
    extern int TranOtherPreTreat(T_App*);
    extern int TranOtherPostTreat(T_App*);

    /* ����֪ͨ���� */
    extern int PurNoticePreTreat(T_App*);
    extern int PurNoticePostTreat(T_App*);

    /* ���Žɷ�Ԥ��ѯ���� */
    extern int CTCCQueryPreTreat(T_App*);
    extern int CTCCQueryPostTreat(T_App*);

    /* ���Žɷѽ��� */
    extern int CTCCPrepayPreTreat(T_App*);
    extern int CTCCPrepayPostTreat(T_App*);

    /* ���״��������� */
    T_TransProc gtaTransProc[]=
    {
        {LOGIN,                 "ǩ������",             LoginPreTreat,          LoginPostTreat,             SEND},
    	{PURCHASE,              "���ѽ���",             PurchasePreTreat,       PurchasePostTreat,          SEND},
    	{EMV_PUR_TRANS,         "EMV������������",      EmvPurTransPreTreat,    EmvPurTransPostTreat,       SEND},
    	{EMV_PUR_ONLINE,        "EMV������������",      EmvPurOnlinePreTreat,   EmvPurOnlinePostTreat,      NOT_SEND},
    	{EMV_INQUERY,           "EMV����ѯ",          EmvInqueryPreTreat,     EmvInqueryPostTreat,        SEND},
    	{EMV_PUR_CANCEL,        "EMV���ѳ���",          EmvPurCancelPreTreat,   EmvPurCancelPostTreat,      SEND},
    	{PRE_AUTH,              "Ԥ��Ȩ����",           PreAuthPreTreat,        PreAuthPostTreat,           SEND},
    	{INQUERY,               "��ѯ����",             NULL,                   InqueryPostTreat,           SEND},
    	{PUR_CANCEL,            "��������",             PurCancelPreTreat,      PurCancelPostTreat,         SEND},
    	{AUTO_VOID,             "��������",             AutoVoidPreTreat,       AutoVoidPostTreat,          SEND},
    	{REFUND,                "�˻�����",             RefundPreTreat,         RefundPostTreat,            SEND},
    	{CONFIRM,               "Ԥ��Ȩ���",           ConfirmPreTreat,        ConfirmPostTreat,           SEND},
    	{TRAN_OUT_QUERY,        "ת��ת��Ԥ��ѯ����",   TranOutQueryPreTreat,   TranOutQueryPostTreat,      SEND},
    	{TRAN_OUT,              "ת��ת�˽���",         TranOutPreTreat,        TranOutPostTreat,           SEND},
        {TRAN_OTHER_QUERY,      "����ת��Ԥ��ѯ����",   TranOtherQueryPreTreat, TranOtherQueryPostTreat,    SEND},
    	{TRAN_OTHER,            "����ת�˽���",         TranOtherPreTreat,      TranOtherPostTreat,         SEND},
    	{PUR_NOTICE,            "����֪ͨ����",         PurNoticePreTreat,      PurNoticePostTreat,         SEND},
    	{CHINATELECOM_QUERY,    "���Žɷ�Ԥ��ѯ����",   CTCCQueryPreTreat,      CTCCQueryPostTreat,         SEND},
    	{CHINATELECOM_PREPAY,   "���Žɷѽ���",         CTCCPrepayPreTreat,     CTCCPrepayPostTreat,        SEND},
        {0,                     "��Ч����",             NULL,                   NULL,                       NOT_SEND}
    };

    /* finatranģ��ȫ�ֱ��� */
    int     giFeeCalcType;                      /* �����Ѽ��㷽ʽ */
    int     giTeleChkType;                      /* �Ƿ������� */
    char    gszTelephone[15+1];                 /* �󶨵绰���� */
    int     giTeleChkLen;                       /* �绰������λ�� */
    long    glTimeOut;                          /* ���׳�ʱʱ�� */
    char    gszMoniIP[15+1];                    /* web���IP��ַ */
    char    gszMoniPort[5+1];                   /* web��ض˿ں� */

#else
    extern int          giFeeCalcType;
    extern int          giTeleChkType;
    extern char         gszTelephone[15+1];
    extern int          giTeleChkLen;
    extern long         glTimeOut;
    extern char         gszMoniIP[15+1];
    extern char         gszMoniPort[5+1];

    extern T_TransProc  gtaTransProc[];
#endif

#endif
