/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�TLV���ݸ�ʽ�����ͷ�ļ�
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision: 1.1 $
 * $Log: Tlv.h,v $
 * Revision 1.1  2012/12/17 07:18:58  fengw
 *
 * 1���������⡢EPAY����ͷ�ļ�����$WORKDIR/inclĿ¼��
 *
 * Revision 1.2  2012/12/13 05:06:24  fengw
 *
 * 1������ע�͡�
 * 2�������淶����
 *
 * Revision 1.1  2012/11/20 03:27:37  chenjr
 * init
 *
 * ----------------------------------------------------------------
 */

#ifndef _TLV_H_
#define _TLV_H_

#define MAX_TLV_NUM         20              /* TLV���������� */

#define MAX_TAG_LEN         4               /* TAG���ռ���ֽ��� */
#define MAX_LEN_LEN         4               /* LENGTH���ռ���ֽ��� */
#define MAX_VALUE_LEN       2048            /* VALUE���ռ���ֽ��� */

#define TAG_NORMAL          0               /* ��ͨ���ͣ�һ��TAGռ��һ���ֽ� */
#define TAG_STANDARD        1               /* ��׼���ͣ���Tag��ǩ�ĵ�һ���ֽ�(�ֽڰ�������������
                                               ����ߵ�Ϊ��һ���ֽڣ�bit˳�������෴)��bit1-bit5
                                               Ϊ"11111"����˵��Tag���Ȳ�ֹһ���ֽڣ������м��ֽ�
                                               �ο���һ�ֽڵ�bit8,���bit8Ϊ1���ٿ���һ�ֽڵ�bit8
                                               ֱ����һ�ֽڵ�bit8Ϊ0ֹ����Tag�����һ���ֽڡ�
                                            */

#define LEN_NORMAL          0               /* ��ͨ���ͣ�����ռ��һ���ֽ�(HEX��ʽ) */
#define LEN_STANDARD        1               /* ��׼���ͣ���Len����ߵ�bitλֵΪ0ʱ��
                                               Lenֵռ��һ���ֽڣ�bit7-bit1�����ȣ�ȡֵ
                                               ��ΧΪ0-127����Len����ߵ�bitλֵΪ1ʱ��
                                               Lenֵռ��2-3���ֽڣ�bit7-bit1����Lenֵռ���ֽ�
                                               �������磬�������ֽ�Ϊ10000010����ʾL�ֶγ���
                                               �ֽ��⣬���滹�������ֽڡ�������ֽڵ�ʮ��
                                               ��ȡֵ��ʾ����ȡֵ�ĳ��ȡ�
                                             */

#define VALUE_NORMAL        0               /* ��ͨ���ͣ�����ԭ���������������� */
#define VALUE_BCD_RIGHT     1               /* BCD��ѹ��(�Ҷ���)��������BCD��ѹ��������Ϊ����ʱ����0���� */
#define VALUE_BCD_LEFT      2               /* BCD��ѹ��(�����)��������BCD��ѹ��������Ϊ����ʱ���Ҳ�0���� */

#define DATA_NULL           0               /* ��ֵ */
#define DATA_NOTNULL        1               /* �ǿ�ֵ */

typedef struct
{
    int     iFlag;                          /* �Ƿ��ֵ��־ */
    char    szTag[MAX_TAG_LEN+1];           /* TAG */
    int     iLen;                           /* LENGTH */
    char    szValue[MAX_VALUE_LEN+1];       /* VALUE */
} T_TLVData;

typedef struct
{
    T_TLVData   tTLVData[MAX_TLV_NUM];      /* TLV���� */
    int         iTagType;                   /* TAG���� */
    int         iLenType;                   /* LEN���� */
    int         iValueType;                 /* VALUE���� */
} T_TLVStru;

#endif