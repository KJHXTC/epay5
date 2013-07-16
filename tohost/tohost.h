/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ���̨ͨѶ�����ͷ�ļ�
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision $
 * $Log: tohost.h,v $
 * Revision 1.3  2013/06/14 02:03:31  fengw
 *
 * 1������ǩ��������ѯ�����ѽ��ױ���������������
 *
 * Revision 1.2  2012/12/13 01:51:17  linxiang
 * *** empty log message ***
 *
 * ----------------------------------------------------------------
 */
#ifndef _TOHOST_H_
#define _TOHOST_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <setjmp.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

#include "user.h"
#include "libdb.h"
#include "libpub.h"
#include "app.h"
#include "EpayShm.h"
#include "errcode.h"
#include "8583.h"

#define CONFIG_FILE "Setup.ini"
#define CONFIG_SECTION "SECTION_COMMUNICATION"

#define GetCharParam(szItem, szValue) \
    do{ \
        if( ReadConfig( CONFIG_FILE, CONFIG_SECTION, szItem, szValue ) != SUCC ) \
        { \
            WriteLog( ERROR, "Setup�������ô���[%s]", szItem ); \
            return; \
        } \
    }while(0)

#define GetIntParam(szItem, iValue) \
    do{ \
        char szValue[80]; \
        if( ReadConfig( CONFIG_FILE, CONFIG_SECTION, szItem, szValue ) != SUCC ) \
        { \
            WriteLog( ERROR, "Setup�������ô���[%s]", szItem ); \
            return; \
        } \
        iValue = atoi(szValue); \
    }while(0)

#define GetLongParam(szItem, lValue) \
    do{ \
        char szValue[80]; \
        if( ReadConfig( CONFIG_FILE, CONFIG_SECTION, szItem, szValue ) != SUCC ) \
        { \
            WriteLog( ERROR, "Setup�������ô���[%s]", szItem ); \
            return; \
        } \
        lValue = atol(szValue); \
    }while(0)
    
#define PACK_TYPE           0           /* ������� */
#define UNPACK_TYPE         1           /* ���Ĳ�� */

typedef int (*PF)(MsgRule*, T_App*, ISO_data*);     // ���庯��ָ������

/* ���Ĵ�����ָ��ṹ���� */
typedef struct
{
    int     iTransType;                     /* �������� */
    char    szTransName[64+1];              /* �������� */
    PF      pFuncPack;                      /* ���������ָ�� */
    PF      pFuncUnpack;                    /* ���������ָ�� */
} T_PkgProc;
    
#ifndef _EXTERN_

    /* ���Ĵ��������� */
    /* ǩ������ */
    extern int LoginPack(MsgRule*, T_App*, ISO_data*);
    extern int LoginUnpack(MsgRule*, T_App*, ISO_data*);
    
    /* ����ѯ���� */
    extern int InqueryPack(MsgRule*, T_App*, ISO_data*);
    extern int InqueryUnpack(MsgRule*, T_App*, ISO_data*);

    /* ���ѽ��� */
    extern int PurchasePack(MsgRule*, T_App*, ISO_data*);
    extern int PurchaseUnpack(MsgRule*, T_App*, ISO_data*);

    /* �������� */
    extern int AutovoidPack(MsgRule*, T_App*, ISO_data*);
    extern int AutovoidUnpack(MsgRule*, T_App*, ISO_data*);

    /* ���ѳ������� */
    extern int PurcancelPack(MsgRule*, T_App*, ISO_data*);
    extern int PurcancelUnpack(MsgRule*, T_App*, ISO_data*);

    /* �˻����� */
    extern int RefundPack(MsgRule*, T_App*, ISO_data*);
    extern int RefundUnpack(MsgRule*, T_App*, ISO_data*);

    /* Ԥ��Ȩ���� */
    extern int PreauthPack(MsgRule*, T_App*, ISO_data*);
    extern int PreauthUnpack(MsgRule*, T_App*, ISO_data*);

    /* Ԥ��Ȩ�������� */
    extern int PrecancelPack(MsgRule*, T_App*, ISO_data*);
    extern int PrecancelUnpack(MsgRule*, T_App*, ISO_data*);

    /* Ԥ��Ȩ��ɽ��� */
    extern int ConfirmPack(MsgRule*, T_App*, ISO_data*);
    extern int ConfirmUnpack(MsgRule*, T_App*, ISO_data*);

    /* ���Ĵ��������� */
    T_PkgProc gtaPkgProc[]=
    {
        {LOGIN,         "ǩ������",         LoginPack,      LoginUnpack},
    	{INQUERY,       "����ѯ����",     InqueryPack,    InqueryUnpack},
    	{PURCHASE,      "���ѽ���",         PurchasePack,   PurchaseUnpack},
    	{AUTO_VOID,     "��������",         AutovoidPack,   AutovoidUnpack},
    	{PUR_CANCEL,    "���ѳ�������",     PurcancelPack,  PurcancelUnpack},
    	{REFUND,        "�˻�����",         RefundPack,     RefundUnpack},
    	{PRE_AUTH,      "Ԥ��Ȩ����",       PreauthPack,    PreauthUnpack},
    	{PRE_CANCEL,    "Ԥ��Ȩ��������",   PrecancelPack,  PrecancelUnpack},
    	{CONFIRM,       "Ԥ��Ȩ��ɽ���",   ConfirmPack,    ConfirmUnpack},
        {0,             "��Ч����",         NULL,           NULL}
    };
#else
    extern T_PkgProc  gtaPkgProc[];
#endif

#endif
