/******************************************************************
** Copyright(C)2012 - 2015���������豸���޹�˾
** ��Ҫ���ݣ����屾ϵͳ���ݿ�ĺ�
** �� �� �ˣ�������
** �������ڣ�2012/11/8
** $Revision: 1.1 $
** $Log: dbtool.h,v $
** Revision 1.1  2012/11/22 01:42:35  epay5
** add by gaomx
**
*******************************************************************/

#ifndef _DBTOOL_H_
#define _DBTOOL_H_

#define SQLCODE         sqlca.sqlcode
#define SQLERR          sqlca.sqlerrm.sqlerrmc
#define SQLROW          sqlca.sqlerrd[2]

#ifdef DB_ORACLE
	#define SQL_NO_RECORD   1403
	#define SQL_SELECT_MUCH   -2112
	#define SQL_DUPLICATE	-1
#endif
#ifdef DB_INFORMIX
	#define SQL_NO_RECORD   100
	#define SQL_SELECT_MUCH   -2112
	#define SQL_DUPLICATE	-239
#endif



#endif /* _DBTOOL_H_ */
