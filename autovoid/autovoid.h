/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨�Զ�����ģ��ͷ�ļ�
** �� �� �ˣ����
** �������ڣ�2012-11-08
**
** $Revision: 1.4 $
** $Log: autovoid.h,v $
** Revision 1.4  2012/12/21 01:55:45  fengw
**
** 1�����ļ���ʽ��DOSתΪUNIX��
** 2���޸�Revision��Log��ʽ��
**
*******************************************************************/

#ifndef _AUTOVOID_H_
#define _AUTOVOID_H_

#include <stdlib.h>
#include <stdio.h>
#include <signal.h>

#include "app.h"
#include "user.h"
#include "dbtool.h"
#include "transtype.h"
#include "libpub.h"

#define CONFIG_FILENAME             "Setup.ini"
#define SECTION_AUTOVOID            "SECTION_AUTOVOID"
#define SECTION_PUBLIC              "SECTION_PUBLIC"

#ifndef _EXTERN_
    int     glPid;
    int     giVoidTimeOut;
    int     giTdiTimeOut;
    int     giSleepTime;
#else
    extern int  glPid;
    extern int  giVoidTimeOut;
    extern int  giTdiTimeOut;
    extern int  giSleepTime;
#endif

#endif
