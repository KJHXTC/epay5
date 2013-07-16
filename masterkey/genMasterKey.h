/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�ϵͳ����ܵ�����Կ�ϳ�ͷ�ļ�
 *  �� �� �ˣ�chenjr
 *  �������ڣ�2012/12/7
 * ----------------------------------------------------------------
 * $Revision: 1.1 $
 * $Log: genMasterKey.h,v $
 * Revision 1.1  2012/12/07 06:11:41  chenjr
 * init
 *
 * ----------------------------------------------------------------
 */

#ifndef _GEN_MASTER_KEY_H
#define _GEN_MASTER_KEY_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <termios.h>
#include "libpub.h"
#include "user.h"

#define MODELTITLE "\n\t\tϵͳ���������Կ�ϳ�\n"

#define KEYLT_TITLE "\n\tһ����ѡ����Կ����\n"
#define KEYLT_DES1 "\t������(16)------�밴1\n"
#define KEYLT_DES2 "\t˫����(32)------�밴2\n"
#define KEYLT_DES3 "\t������(48)------�밴3\n"
#define KEYLT_INT  "\t�жϲ������˳�------�밴q\n"
#define KEYLT_LEN  "\n\tһ����Կ����[%d]�ֽ�\n"
#define KEYLT_MENU KEYLT_TITLE KEYLT_DES1 KEYLT_DES2 KEYLT_DES3 KEYLT_INT


#define KEYCOM_TITLE "\n\t������ѡ����Կ������(1-3)\n"
#define KEYCOM_INT  "\t�жϲ������˳�------�밴q\n"
#define KEYCOM_NUM  "\n\t������Կ������[%d]\n"
#define KEYCOM_MENU KEYCOM_TITLE KEYCOM_INT 


#define COMCON_HEAD MODELTITLE KEYLT_LEN KEYCOM_NUM
#define COMCON_INPUT "\n\t���������%d����\n"
#define COMCON_REIN  "\n\t���ٴ��������%d����\n"
#define COMCON_ICON  "\n\t�������벻һ��,������\n"
#define COMCON_INLEN "\t�����볤��%d"

#define SAVECOM_SUCC "\n\t��������Կ����ɹ�\n\n"
#define SAVECOM_FAIL "\n\t��������Կ����ʧ��\n\n"

#endif /*_GEN_MASTER_KEY_H */
