/******************************************************************
 ** Copyright(C)2009��2012 �������������豸���޹�˾
 ** ��Ҫ���ݣ���־��ӡͷ�ļ��������ļ������һЩ����������� 
 ** �� �� �ˣ�zhangwm
 ** �������ڣ�2012/12/03
 **
 ** ---------------------------------------------------------------
 **   $Revision: 1.1 $
 **   $Log: LogPrint.h,v $
 **   Revision 1.1  2012/12/17 07:18:58  fengw
 **
 **   1���������⡢EPAY����ͷ�ļ�����$WORKDIR/inclĿ¼��
 **
 **   Revision 1.4  2012/11/29 07:02:31  zhangwm
 **
 **   �����Ƿ��ӡ��־����
 **
 **   Revision 1.3  2012/11/27 06:13:41  zhangwm
 **
 **   ��дAPP��־�����Ƴ�
 **
 **   Revision 1.2  2012/11/26 06:45:35  zhangwm
 **
 **   	��������־��ӡ��ֲ����������
 **
 **   Revision 1.1  2012/11/20 03:27:37  chenjr
 **   init
 **
 ** ---------------------------------------------------------------
 **
 *******************************************************************/
#ifndef __LOGPRINT_H_
#define __LOGPRINT_H_


/* ��־�ļ������� */
#define E_LOG "/log/E_LOG"
#define T_LOG "/log/T_LOG"
#define H_LOG "/log/H_LOG"
#define M_LOG "/log/M_LOG"

#define E_TYPE 0
#define T_TYPE 1
#define H_TYPE 2
#define M_TYPE 3

/* ȫ���ļ���� */
FILE *fpTLog;
FILE* fpHLog;
FILE* fpMLog;

/* ��־��ӡ������ݱ������ȶ��� */
#define PATH_LEN 80
#define DATA_LEN 5120

#define E_ERROR     0
#define T_TRACE     1

#define ERROR       __FILE__, __LINE__, E_ERROR
#define TRACE       __FILE__, __LINE__, T_TRACE

#endif /* end __LOGPRINT_H */
