/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨ϵͳ״̬���ģ��
** �� �� �ˣ����
** �������ڣ�2012-10-30
**
** $Revision: 1.5 $
** $Log: epaymoni.h,v $
** Revision 1.5  2012/12/21 02:08:15  fengw
**
** 1������Revision��Log��
**
*******************************************************************/

#ifndef _EPAYMONI_H_
#define _EPAYMONI_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <oci.h>
#include <errno.h>
#include <signal.h>
#include <sys/ipc.h>
#include <sys/msg.h>

#include "app.h"
#include "dbtool.h"
#include "transtype.h"
#include "user.h"
#include "errcode.h"

/* �����ļ��궨�� */
#define CONFIG_FILENAME                 "Setup.ini"         /* ϵͳ�����ļ����� */
#define SECTION_PUBLIC                  "SECTION_PUBLIC"    /* ����SECTION���� */
#define SECTION_EPAYMONI                "SECTION_EPAYMONI"  /* ���SECTION���� */

/* �����С����궨�� */
#define MIN_MONI_INTERVAL	            30                  /* ��Сϵͳ��ؼ��ʱ�䣬��λ�� */

/* ͨѶ���ͺ궨�� */
#define DUPLEX_KEEPALIVE_SERV           1                   /* ˫����������� */
#define DUPLEX_KEEPALIVE_CLIT           2                   /* ˫�������ͻ��� */
#define SIMPLEX_KEEPALIVE               3                   /* �������� */
#define DUPLEX_SERVER                   4                   /* ��������� */

/* ״̬�궨�� */
#define STATUS_YES                      'Y'                 /* ���� */
#define STATUS_NO                       'N'                 /* �쳣 */

#ifndef _EXTERN_

/* ����netstat����IP��ַ��˿ڷָ��� */
#ifdef AIX
    const char cnServListenIP[] = "*";
    const char cnSplit = '.';
    const char cnPSStat[] = "status";
    const char cnProcStatus = 'A';
#else
    const char cnServListenIP[] = "0.0.0.0";
    const char cnSplit = ':';
    const char cnPSStat[] = "stat";
    const char cnProcStatus = 'S';
#endif

FILE *fpStatusFile;

#else
    extern char cnServListenIP[];
    extern char cnSplit;
    extern char cnPSStat[];
    extern char cnProcStatus;
    extern FILE *fpStatusFile;
#endif

#endif
