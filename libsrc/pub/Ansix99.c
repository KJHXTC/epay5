/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�ansix99
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision: 1.10 $
 * $Log: Ansix99.c,v $
 * Revision 1.10  2012/12/10 02:57:33  fengw
 *
 * 1���滻WriteERLog����ΪWriteLog��
 *
 * Revision 1.9  2012/12/04 03:33:18  chenjr
 * ����淶��
 *
 * Revision 1.8  2012/11/29 02:15:35  linqil
 * �޸�WriteETLogΪWriteLog
 *
 * Revision 1.7  2012/11/28 08:25:44  linqil
 * ȥ������ͷ�ļ�user.h
 *
 * Revision 1.6  2012/11/27 08:22:52  linqil
 * �޸���־����
 *
 * Revision 1.5  2012/11/27 05:54:09  linqil
 * ȥ��void �ķ���ֵ
 *
 * Revision 1.4  2012/11/27 05:46:48  linqil
 * ��������pub.h �޸�return
 *
 * Revision 1.3  2012/11/27 02:41:45  linqil
 * ��������pub.h �޸�return
 *
 * Revision 1.2  2012/11/26 09:06:24  linqil
 * �޸�AscToBCDΪAscToBcd
 *
 * Revision 1.1  2012/11/20 03:27:37  chenjr
 * init
 *
 * ----------------------------------------------------------------
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "libpub.h"
#include "pub.h"

#define SINGLE_DES   1     /* DES */
#define TRIPLE_DES   2     /* 3DES */

/* ----------------------------------------------------------------
 * ��    �ܣ�ANSI X9.9    ����MAc
 *           DES ( DES ( A ) ^ ( A + 8 ) ... ) )
 *           TriDES ( TriDES ( A ) ^ ( A + 8 ) ... ) )
 * ���������uuszMacKey     ����MAC����Կ
 *           uszBuf        ���ڼ���MAc�ı���
 *           iLen         ���ĳ���
 *           iAlg         �㷨��ʶ: ����SINGLE_DES or TRIPLE_DES
 * ���������uszMac        ������MAcֵ(64bit)
 * �� �� ֵ��
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
void ANSIX99(unsigned char *uuszMacKey, unsigned char *uszBuf, int iLen, 
             int iAlg, unsigned char *uszMac)
{
    int   i, j;
    char  tmp[20];
    
    if (iLen <= 0)
    {
        WriteLog(ERROR, "Invalid argument[iLen=%d]\n", iLen);
        return ;
    }
    
    memset(uszMac, '\0', 8);
    
    for (i = 0; i < iLen; i += 8)
    {
        /* right-justified with append 0x00 */
        if ((iLen - i) < 8)
        {
            memset( tmp, '\0', 8 );
            memcpy( tmp, uszBuf + i, iLen - i );
            for (j = 0; j < 8; j ++) 
            {
                uszMac[j] ^= tmp[j];
            }
        } 
        else
        {
            for ( j = 0; j < 8; j ++ ) 
            {
                uszMac [ j ] ^= uszBuf [ i + j ];
            }
        }
        
        if (iAlg == TRIPLE_DES)
        {
            TriDES(uuszMacKey, uszMac, uszMac);
        }
        else
        {
            DES(uuszMacKey, uszMac, uszMac);
        }
    }
    
    return ;
}


/* ----------------------------------------------------------------
 * ��    �ܣ�ANSI X9.19    ����MAc
 *  TMP1 = DES ( DES (A, KeyL ) ^ ( A + 8 ) ... ), KeyL )
 *  TMP2 = _DES( TMP1, KeyR )
 *  MAC  = DES( TMP2, KeyL )
 * ���������uszMacKey      ����MAC����Կ
 *           uszBuf         ���ڼ���MAc�ı���
 *           iLen          ���ĳ���
 * ���������uszMac         ������MAcֵ(64bit)
 * �� �� ֵ��
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
void ANSIX919(unsigned char *uszMacKey, unsigned char *uszBuf, int iLen, 
              unsigned char *uszMac)
{
    int   i, j;
    char  tmp[20];

    if (iLen <= 0)
    {
        WriteLog(ERROR, "Invalid argument[iLen=%d]", iLen);
        return ;
    }

    memset(uszMac, '\0', 8);
    
    for (i = 0; i < iLen; i += 8) 
    {
        /* right-justified with append 0x00 */
        if ((iLen - i) < 8) 
        {
            memset(tmp, '\0', 8);
            memcpy(tmp, uszBuf + i, iLen - i);
            for (j = 0; j < 8; j ++) 
            {
                uszMac[j] ^= tmp[j];
            }
        }
        else 
        {
            for (j = 0; j < 8; j ++) 
            {
                uszMac[j] ^= uszBuf[i+j];
            }
        }
        
        DES(uszMacKey, uszMac, uszMac);
    }
    
    _DES(uszMacKey+8, uszMac, uszMac);
    DES(uszMacKey, uszMac, uszMac);
    
    return ;
}


/* ----------------------------------------------------------------
 * ��    �ܣ���MAc�㷨 DES ( A ^ ( A + 8 ) ... )
 * ���������uszMacKey    ����MAC����Կ
 *           uszBuf       ���ڼ���MAc�ı���
 *           iLen         ���ĳ���
 *           iAlg         �㷨��ʶ TRIPLE_DES or SINGLE_DES
 * ���������uszMac       ������MAcֵ(64bit)
 * �� �� ֵ��
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
void Mac_Normal(unsigned char *uszMacKey, unsigned char *uszBuf, 
               int iLen, int iAlg, unsigned char *uszMac)
{
    int   i, j;
    char  tmp[20];

    if (iLen <= 0)
    {
        WriteLog(ERROR, "Invalid argument[iLen=%d]", iLen);
        return ;
    }

    memset(uszMac, '\0', 8);
    
    for (i = 0; i < iLen; i += 8) 
    {
        /* right-justified with append 0x00 */
        if ((iLen - i) < 8) 
        {
            memset ( tmp, '\0', 8 );
            memcpy ( tmp, uszBuf + i, iLen - i );
            for ( j = 0; j < 8; j ++ ) 
            {
                uszMac [ j ] ^= tmp [ j ];
            }
        } 
        else 
        {
            for (j = 0; j < 8; j ++) 
            {
                uszMac[j] ^= uszBuf[i + j];
            }
        }
    }
    
    if (iAlg == TRIPLE_DES)
    {
        TriDES(uszMacKey, uszMac, uszMac);
    }
    else
    {
        DES(uszMacKey, uszMac, uszMac);
    }

    return ;
}


/* ----------------------------------------------------------------
 * ��    �ܣ��������ַ�����ÿ8���ֽڷ��飬�����8λ������0��
 *           Ȼ��ӵ�1�鿪ʼ�������;( A ^ ( A + 8 ) ^ ( A + 16 ) ... )
 * ���������uszInData     ��������
 *           nLen          �������ݳ���
 * ���������uszOutData    ���������(8 byte)
 * �� �� ֵ��
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
void XOR(unsigned char *uszInData, int iLen, unsigned char *uszOutData )
{
    int   i, j;
    char  tmp[20];
 
    memset( uszOutData, 0, 8 );
    
    for (i = 0; i < iLen; i += 8) 
    {
        /* ����8λ�Ҳ� 0x00 */
        if ( ( iLen - i ) < 8 ) 
        {
            memset(tmp, '\0', 8);
            memcpy(tmp, uszInData+i, iLen-i);
            for (j = 0; j < 8; j ++) 
            {
                uszOutData[j] ^= tmp[j];
            }
        }
        else
        {
            for (j = 0; j < 8; j ++) 
            {
                uszOutData[j] ^= uszInData[i+j];
            }
        }
    }
 
    return ;
}

