/* --------------------------------------------
 * Copyright(C)2006 - 2013 ���������豸���޹�˾
 *
 * FileName  :  pub.h
 *
 * ��Ҫ����  :  ����pub��Ĺ����궨��
 *
 * CreateInfo:  LinQili@ 2012.11.26 16:26:38
 *
 * ---------------------------------------
 *
 * $Revision: 1.1 $
 *
 * $Log: pub.h,v $
 * Revision 1.1  2012/12/17 07:18:58  fengw
 *
 * 1���������⡢EPAY����ͷ�ļ�����$WORKDIR/inclĿ¼��
 *
 * Revision 1.2  2012/11/28 08:25:44  linqil
 * ȥ������ͷ�ļ�user.h
 *
 * Revision 1.1  2012/11/26 08:35:51  linqil
 * ����ͷ�ļ�pub.h�����Ӹ����ļ���ͷ�ļ������ã��޸�return 0 return -1 Ϊreturn SUCC return FAIL��
 *
 *
 * --------------------------------------------*/
 
#ifndef _PUB_H_
#define _PUB_H_

/*��������*/
#define SUCC             0
#define FAIL            -1
#define DUPLICATE       -2
#define TIMEOUT         -3
#define INVALID_PACK    -4


/* ��־��ӡ��غ궨�� */
#define E_ERROR     0
#define T_TRACE     1

#define ERROR       __FILE__, __LINE__, E_ERROR
#define TRACE       __FILE__, __LINE__, T_TRACE

#endif /*  _PUB_H_ */


