/******************************************************************
** Copyright(C)2012 - 2015���������豸���޹�˾
** ��Ҫ���ݣ����屾ϵͳ�ź����ĺ��Լ����������
** �� �� �ˣ����
** �������ڣ�2012/11/29
** ----------------------------------------------------------------
** $Revision:
** $Log:
*******************************************************************/

#ifndef	_EPAY_SEM_
#define _EPAY_SEM_

#include <stdlib.h>

#include "user.h"
#include "dbtool.h"
#include "transtype.h"
#include "libpub.h"

#define SEM_FILE            "/etc/SEMFILE"

/* �ź�����ʶ */
#define SEM_ACCESS_ID       1               /* ����ͻ�����Ϣ�����ڴ��д�ź��� */
#define SEM_TDI_ID          2               /* �����������������ڴ��д�ź��� */
#define SEM_HOST_ID         3               /* ��̨ͨѶ״̬�����ڴ��д�ź��� */

int     giSemAccessID;
int     giSemTdiID;
int     giSemHostID;

#else
    extern int      giSemAccessID;
    extern int      giSemTdiID;
    extern int      giSemHostID;
#endif

