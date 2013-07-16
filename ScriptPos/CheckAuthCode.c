/*******************************************************************************
 * Copyright(C)2012��2015 �������������豸���޹�˾
 * ��Ҫ���ݣ�ScriptPosģ�� У��������֤��
 * �� �� �ˣ�Robin
 * �������ڣ�2012/11/30
 * $Revision: 1.1 $
 * $Log: CheckAuthCode.c,v $
 * Revision 1.1  2013/01/18 08:32:37  fengw
 *
 * 1����ֺ�����
 *
 ******************************************************************************/

#define _EXTERN_

#include "ScriptPos.h"

/*******************************************************************************
 * �������ܣ�У��������֤��
 * ���������
 *           uszAuthCode - ������֤��
 *           szPsamNo    - ��ȫģ���
 * ���������
 *           ��
 * �� �� ֵ�� 
 *           SUCC    -  ͨ��У�� 
 *           FAIL    -  δͨ��У��
 * ��    �ߣ�Robin
 * ��    �ڣ�2012/11/30
 * �޶���־��
 *
 ******************************************************************************/
int CheckAuthCode( uchar* uszAuthCode, char* szPsamNo )
{
    uchar uszPlain[8], uszCrypt[8];
    int i;

    XOR( szPsamNo, 16, uszPlain );

    TriDES( gszAuthKey, uszPlain, uszCrypt );

    if( memcmp(uszCrypt, uszAuthCode, 4) == 0 )
    {
        return SUCC;
    }
    else
    {
        WriteLog( ERROR, "auth code not right" );

        return FAIL;
    }
}