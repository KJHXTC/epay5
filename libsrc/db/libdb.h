/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision: 1.5 $
 * $Log: libdb.h,v $
 * Revision 1.5  2012/12/03 07:46:04  yezt
 *
 * ����.h�ļ����룬�޸�����״̬���麯��
 *
 * Revision 1.4  2012/12/03 05:47:54  yezt
 *
 * ��������libpub.h
 *
 * Revision 1.3  2012/11/29 06:12:49  yezt
 *
 * �������ݿ�����״̬�жϺ���
 *
 * Revision 1.2  2012/11/28 01:43:42  chenjr
 * ȥ��dbop�ӿ����
 *
 * Revision 1.1  2012/11/20 07:25:03  chenjr
 * init
 *
 * ----------------------------------------------------------------
 */

#ifndef _LIBDB_H_
#define _LIBDB_H_

    /* �������ݿ����� */
    extern int OpenDB();

    /* �Ͽ����ݿ����� */
    extern void CloseDB();

    /* ��ʼһ������ */
    extern int BeginTran();

    /* �ύһ������ */
    extern int CommitTran();

    /* ����ع� */
    extern int RollbackTran();
    
    /* ���ݿ�����״̬�ж� */
    extern int ChkDBLink();


#endif  /*_LIBDB_H_ */ 
