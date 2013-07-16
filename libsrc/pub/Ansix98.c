
/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�ansix98
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision: 1.8 $
 * $Log: Ansix98.c,v $
 * Revision 1.8  2012/12/04 03:20:37  chenjr
 * ����淶��
 *
 * Revision 1.7  2012/11/27 07:00:43  linqil
 * ���������ж����
 *
 * Revision 1.6  2012/11/26 09:09:45  linqil
 * ����ע��
 *
 * Revision 1.5  2012/11/26 09:08:08  linqil
 * �޸�BCDToAscΪBcdToAsc
 *
 * Revision 1.4  2012/11/26 09:06:24  linqil
 * �޸�AscToBCDΪAscToBcd
 *
 * Revision 1.3  2012/11/26 08:40:13  linqil
 * ���Ӷ�pub.h�����ã�0 -1 �滻ΪSUCC��FAIL
 *
 * Revision 1.2  2012/11/20 03:27:37  chenjr
 * init
 *
 * Revision 1.1  2012/11/20 03:25:44  chenjr
 * init
 *
 * ----------------------------------------------------------------
 */

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include "pub.h"


#define SINGLE_DES   1     /* DES */
#define TRIPLE_DES   2     /* 3DES */

/* ----------------------------------------------------------------
 * ��    �ܣ�ANSI X9.8    ����ģ��
 * ���������uszKey       ������Կ����
 *           szPan        �˺�
 *           szPasswd     ��������
 *           iPwdLen      �������ĳ���
 *           iFlag        �㷨��ʶ: ����DES��3DES
 * ���������uszResult    ����ansi98���ܺ����������
 * �� �� ֵ��-1  ����ʧ�ܣ�  0  �ɹ�
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int ANSIX98(unsigned char *uszKey, char *szPan,  char *szPwd,
            int iPwdLen, int iFlag, unsigned char *uszResult)
{
    int	i;
    int iRet;
    unsigned char  password[9];
    
    if (iPwdLen > 8)
    {
        return FAIL;
    }
    
    iRet = A_(szPwd, szPan, iPwdLen, uszResult);
    if (iRet < 0 )	
    {
        return FAIL;
    }
    
    if (iFlag == TRIPLE_DES)
    {
        TriDES( uszKey, uszResult, password );
    }
    else
    {
        DES(uszKey, uszResult, password);
    }
    
    memcpy((char*) uszResult, (char*) password, 8);
    uszResult[8] = '\0';
    
    return SUCC;
}

/* ----------------------------------------------------------------
 * ��    �ܣ�ANSI X9.8    ����ģ��
 * ���������uszKey       ������Կ����
 *           szPan        �˺�
 *           uszPasswd     ��������
 *           iFlag        �㷨��ʶ: ����DES��3DES
 * ���������uszResult    ����ansi98���ܺ����������
 * �� �� ֵ��-1  ����ʧ�ܣ�  0  �ɹ�
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int _ANSIX98(unsigned char *uszKey, char *szPan, unsigned char *uszPwd,
             int iFlag, unsigned char *uszResult)
{
    unsigned char  a_value [ 17 ];
    
    if (iFlag == TRIPLE_DES)
    {
        _TriDES(uszKey, uszPwd, a_value);
    }
    else
    {
        _DES(uszKey, uszPwd, a_value);
    }
    
    return(_A_(a_value, szPan, uszResult));
}

/* ----------------------------------------------------------------
 * ��    �ܣ������������˺������
 * ���������szPan        �˺�
 *           uszPasswd    ��������
 *           iPwdLen      ���볤��
 * ���������uszResult    ������
 * �� �� ֵ��SUCC  �ɹ�   FAIL  ʧ��
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int A_(unsigned char *uszPasswd, char *szPan, int iPwdLen, unsigned char *uszResult)
{
    unsigned char  uszPasswd0[17], tmp[17], tmp1[10];
    int            i;
    	
    memcpy (uszPasswd0, uszPasswd, iPwdLen);
    
    for (i = iPwdLen; i < 16; i++)  
    {
        uszPasswd0 [ i ] = 'F'; 
    }
    
    AscToBcd(uszPasswd0, 16, 0, tmp1);
    memcpy (tmp, szPan + 3, 13);
    
    for (i = 0; i < 13; i++) 
    {
        if (tmp[i] < '0' || tmp[i] > '9')	
        {
            tmp [ i ] = 'F';
        }
    }

    AscToBcd(tmp, 12, 0, uszPasswd0);
    	
    sprintf((char *)tmp, "0%d", iPwdLen);
    AscToBcd(tmp, 2, 0, uszResult);
    
    * (++uszResult) = tmp1[0];
    
    uszResult ++;
    
    for (i = 0; i <= 5; i++) 
    {
        *(uszResult + i) = tmp1[i + 1] ^ uszPasswd0[i];
    }
    
    return SUCC;
}


/* ----------------------------------------------------------------
 * ��    �ܣ��������Ļ�ԭ
 * ���������uszValuse    ���˺����������
 *           szPan        �˺�
 * ���������uszResult    ��������
 * �� �� ֵ��SUCC  �ɹ�   FAIL  ʧ��
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int _A_(unsigned char *uszValue, char *szPan, unsigned char *uszResult)
{
    unsigned char  tmp[17], tmp1[17], passwd0[17];
    int            i, len;
    
    memcpy(tmp, szPan + 3, 13);
    
    for (i = 0; i < 13; i++) 
    {
        if (tmp[i] < '0' || tmp[i] > '9')	
        {
            tmp[i] = 'F';
        }
    }
    
    AscToBcd(tmp, 12, 0, tmp1);
    
    tmp[0] = uszValue[0];
    tmp[1] = uszValue[1];
    
    for (i = 0; i < 6; i++) 
    {
        tmp[i+2] = uszValue[2+i]^tmp1[i];
    }
    
    BcdToAsc(tmp, 16, 0, passwd0);
    
    memcpy((char *) tmp1, (char *)passwd0, 2);
    tmp1[2] = '\0';
    
    len = atoi (tmp1);
    
    if (len > 8)
    {
        return FAIL;
    }
    
    memcpy((char *)uszResult, (char *)passwd0 + 2, len);
    uszResult[len] = '\0';
    
    return SUCC;
}

