/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�8583���Ĵ���ͷ�ļ�
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision: 1.1 $
 * $Log: 8583.h,v $
 * Revision 1.1  2012/12/17 07:18:58  fengw
 *
 * 1���������⡢EPAY����ͷ�ļ�����$WORKDIR/inclĿ¼��
 *
 * Revision 1.4  2012/12/04 02:05:42  chenjr
 * ����淶��
 *
 * Revision 1.3  2012/11/26 08:54:41  yezt
 * *** empty log message ***
 *
 * Revision 1.2  2012/11/26 03:13:40  chenjr
 * ��ӹ���
 *
 * Revision 1.1  2012/11/20 03:23:45  chenjr
 * init
 *
 * ----------------------------------------------------------------
 */

#ifndef _8583
#define _8583

#define DBUFSIZE 512

#define FIELDLENTYPE_ASC  1
#define FIELDLENTYPE_BCD  2
#define FIELDLENTYPE_HEX  3

#define MSGIDTYPE_BCD  2
#define MSGIDTYPE_ASC  4

/* ISO 8583 Message Structure Definitions */

/* ���ľ���ÿ������� */
struct  ISO_8583 
{              
    int            len;   /* data element max length */
    unsigned char  type;  /* bit0--C/D����, bit1--n�����, 
                             bit2--z�Ҷ��� bit3--BIN DATA*/
    unsigned char  flag;  /* length field length: 0--�̶� 
                             1--LLVAR�� 2--LLLVAR��*/
};

/* ���Ĺ��� */
typedef struct
{
    short   iMidType;        /* MessageID����  ASC or BCD  */
    short   iFieldLenType;   /* �򳤶����� ASC��BCD or HEX */
    struct  ISO_8583 *ptISO; /* ISO�ṹ */
}MsgRule;


struct data_element_flag {
    short bitf;
    short len;
    int   dbuf_addr;
};

typedef struct  {
    struct  data_element_flag f[128];
    short   off;
    char    dbuf[512];
    char    message_id[10];
} ISO_data;


#endif

