/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨web�����������ģ��ͷ�ļ�
** �� �� �ˣ����
** �������ڣ�2012-12-18
**
** $Revision: 1.3 $
** $Log: comweb.h,v $
** Revision 1.3  2012/12/25 07:00:35  fengw
**
** 1���޸�web���׼��ͨѶ�˿ںű�������Ϊ�ַ�����
**
** Revision 1.2  2012/12/21 02:04:03  fengw
**
** 1���޸�Revision��Log��ʽ��
**
*******************************************************************/

#ifndef _COMWEB_H_
#define _COMWEB_H_

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>

#include "app.h"
#include "user.h"
#include "dbtool.h"
#include "transtype.h"
#include "errcode.h"
#include "EpayLog.h"

/* �궨�� */

#define CONFIG_FILENAME                 "Setup.ini"
#define SECTION_COMMUNICATION           "SECTION_COMMUNICATION"
#define SECTION_PUBLIC                  "SECTION_PUBLIC"

/* ����ģʽ */
#define DOWN_MODE_IMMEDIATE             1                   /* �������� */
#define DOWN_MODE_ONLINE                2                   /* �������� */

/* ���ط�ʽ */
#define DOWN_SPECIFY_POS                1                   /* ����ָ���ն� */
#define DOWN_SPECIFY_SHOP               2                   /* ����ָ���̻��ն� */
#define DOWN_ALL                        3                   /* ���������ն� */
#define DOWN_SPECIFY_TYPE               4                   /* ����ָ��Ӧ�������ն� */
#define DOWN_SPECIFY_DEPT               5                   /* ����ָ���������ն� */

/* �������� */
#define CALLTYPE_POS                    1                   /* �ն˷��� */
#define CALLTYPE_CENTER                 2                   /* ƽ̨���� */

/* ͨѶ������󳤶� */
#define MAX_SOCKET_BUFLEN               1024

#ifndef _EXTERN_
    /* finatranģ��ȫ�ֱ��� */
    int     giTdiTimeOut;                       /* TDI���������ʱ�� */
    long    glTimeOut;                          /* ���׳�ʱʱ�� */
    char    gszMoniIP[15+1];                    /* web���IP��ַ */
    int     gszMoniPort[5+1];                   /* web��ض˿ں� */
    int     giDownMode;                         /* ����ģʽ */
    int     giDownType;                         /* ���ط�ʽ */
    char    gszBitmap[256+1];                   /* ����λͼ */
#else
    extern int          giTdiTimeOut;
    extern long         glTimeOut;
    extern char         gszMoniIP[15+1];
    extern int          gszMoniPort[5+1];
    extern int          giDownMode;
    extern int          giDownType;
    extern char         gszBitmap[256+1];
#endif

#endif
