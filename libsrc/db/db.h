/* ---------------------------------------
 * Copyright(C)2006 - 2013 ���������豸���޹�˾
 *
 * FileName  :  db.h
 *
 * ��Ҫ����  :  ����db��Ĺ����궨�壬��Ҫ��Ϊ�˲�����user.h
 *
 * CreateInfo:  LinQili@ 2012.11.28 16:26:38
 *
 * ---------------------------------------
 *
 * $Revision: 1.2 $
 *
 * $Log: db.h,v $
 * Revision 1.2  2012/12/03 07:46:04  yezt
 *
 * ����.h�ļ����룬�޸�����״̬���麯��
 *
 * Revision 1.1  2012/11/28 08:33:30  linqil
 * init
 *
 * --------------------------------------------*/
 
#ifndef _DB_H_
#define _DB_H_

#define SQLCODE           sqlca.sqlcode
#define SQLERR            sqlca.sqlerrm.sqlerrmc
#define SQLROW            sqlca.sqlerrd[2]

#define SQL_NO_RECORD     1403
#define SQL_SELECT_MUCH   -2112
#define SQL_DUPLICATE     -1

#define DB_ORACLE         1


/*��������*/


/* ��־��ӡ��غ궨�� */
#define E_ERROR     0
#define T_TRACE     1

#define ERROR       __FILE__, __LINE__, E_ERROR
#define TRACE       __FILE__, __LINE__, T_TRACE

#endif /*  _DB_H_ */


