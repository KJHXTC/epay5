
/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�ASCII����BCD��以��ת���ӿ�
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision: 1.4 $
 * $Log: AscBcd.c,v $
 * Revision 1.4  2013/01/04 06:11:39  fengw
 *
 * 1������BcdToAsc�����ַ�����������ֵԽ��BUG��
 *
 * Revision 1.3  2012/12/14 08:06:16  chenrb
 * BcdToAsc�����asc�����ӽ�����
 *
 * Revision 1.2  2012/11/27 02:43:00  linqil
 * ��������pub.h �޸�return
 *
 * Revision 1.1  2012/11/20 03:27:37  chenjr
 * init
 *
 * ----------------------------------------------------------------
 */


#include <string.h>
#include "pub.h"
#define  CONVSEAT_EVEN_FLAG     0x55     /* ת��λ�ô���ż����ʶ */
#define  ODD_CHKFLAG            0x01     /* ����У���ʶ��*/


/* ----------------------------------------------------------------
 * ��    �ܣ���ASC��ת����BCD��; �����ת����ASC������Ϊ�������ӿ�֧��
 *           ��ת�����BCD����ǰ������4bit��0
 * ���������uszAscBuf  ������ת����ASCII��
 *           iAscLen    ASCII������
 *           ucType     ת����ʽ;ֻ��ת������iAscLenΪ����ʱ��Ч.
 *                      0,  ת������BCD�����4bit��0
 *                      ��0,ת������BCD����ǰ4bit��0
 * ���������uszBcdBuf  ת������BCD��
 * �� �� ֵ��-1   ��������쳣
 *           >0   ת����uszBcdBuf�ĳ���
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */ 
int AscToBcd(unsigned char  *uszAscBuf, int iAscLen,  
             unsigned char   ucType,    unsigned char *uszBcdBuf)
{
    int i;
    unsigned char ucLVal, ucRVal;

    /* �����Ϸ��Լ�� */
    if (uszAscBuf == NULL ||
        iAscLen   <= 0    ||
        uszBcdBuf == NULL)
    {
        return FAIL;
    }
        
    /* ��䷽ʽ�ж� */
    if (iAscLen & ODD_CHKFLAG && ucType)
    {
        /* ת������Ϊ�����ֽڳ���ת�����ͷ��㣬
           ��ʾ�ڴ�ǰ���4bit��0,  */
        ucLVal = 0;
    }
    else
    {
        ucLVal = CONVSEAT_EVEN_FLAG;
    }

    /* ���ֽ� ASC->BCDת�� */
    for (i = 0; i < iAscLen; i++, uszAscBuf++)
    {
        if (*uszAscBuf >= 'a')
        {
            ucRVal = *uszAscBuf - 'a' + 10;
        }
        else if (*uszAscBuf >= 'A')
        {
            ucRVal = *uszAscBuf - 'A' + 10;
        }
        else if (*uszAscBuf >= '0')
        {
            ucRVal = *uszAscBuf - '0';
        }
        else
        {
            ucRVal = 0;
        }

        if (ucLVal == CONVSEAT_EVEN_FLAG)
        {
            ucLVal = ucRVal;
        }
        else
        {
            *uszBcdBuf++ = (ucLVal << 4) | ucRVal;
            ucLVal = CONVSEAT_EVEN_FLAG;
        }
    }

    /* ȫ��ת�����, �ж�ת�������Ƿ�Ϊ���� */
    if (ucLVal != CONVSEAT_EVEN_FLAG)
    {
        /* Ϊ����, �ڴ���4bit��0 */
        *uszBcdBuf = ucLVal << 4;
    }

    return (iAscLen + 1) / 2;
}



/* ----------------------------------------------------------------
 * ��    �ܣ���BCD��ת����ASC��; �����Ҫת���������ֽڵ�ASC����
 *           �ӿ�֧������BCD����ǰ������4bit
 * ���������uszBcdBuf  ������ת����BCD��
 *           iAscLen    ��Ҫת������ASC������
 *           ucType     ת����ʽ;ֻ��ת������iAscLenΪ����ʱ��Ч.
 *                      0,  ��ͷ��ʼת��
 *                      ��0,����BCD����ǰ4bit����ת��
 * ���������uszAscBuf  ת������Asc��
 * �� �� ֵ��-1   ��������쳣
 *           >0   ת����uszAscBuf�ĳ���
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */ 
int BcdToAsc(unsigned char  *uszBcdBuf, int iAscLen,
             unsigned char   ucType,    unsigned char *uszAscBuf)
{
    int i, iConvLen;

    /* �����Ϸ��Լ�� */
    if (uszAscBuf == NULL ||
        iAscLen   <= 0    ||
        uszBcdBuf == NULL)
    {
        return FAIL;
    }

    /* ת����ʼλ���ж� */
    iConvLen = iAscLen;
    if (iAscLen & ODD_CHKFLAG && ucType)
    {
        /* ת������Ϊ�����ֽڳ���ת�����ͷ��㣬
           ��ʾ������ǰ4bit  */
        i = 1;
        iConvLen++;
    }
    else
    {
        i = 0;
    }

    for (; i < iConvLen; i++, uszAscBuf++)
    {
        *uszAscBuf = ( (i & 0x01) ? (*uszBcdBuf++ & 0x0f) : 
                                    (*uszBcdBuf >> 4) );
        *uszAscBuf += ( (*uszAscBuf > 9) ? ('A' - 10) : '0' );
    }
    uszAscBuf[0] = 0;

    return iAscLen;

}



