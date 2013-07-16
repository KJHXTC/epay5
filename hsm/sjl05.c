/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:�ɶ���ʿͨӲ�����ܻ����ܽӿ�
            ���ܻ��汾��:WT101C-v1.9.4-JRIC1-060707
** �� �� ��:Robin 
** ��������:2009/08/29


$Revision: 1.11 $
$Log: sjl05.c,v $
Revision 1.11  2012/12/10 07:52:07  wukj
ANS��غ�����������

Revision 1.10  2012/12/05 06:32:14  wukj
*** empty log message ***

Revision 1.9  2012/12/03 03:24:46  wukj
int����ǰ׺�޸�Ϊi

Revision 1.8  2012/11/29 07:51:43  wukj
�޸���־����,�޸�ascbcdת������

Revision 1.7  2012/11/29 01:57:55  wukj
��־�����޸�

Revision 1.6  2012/11/21 04:13:38  wukj
�޸�hsmincl.h Ϊhsm.h

Revision 1.5  2012/11/21 03:20:31  wukj
1:���ܻ����������޸� 2: ȫ�ֱ�������hsmincl.h

*******************************************************************/

#include "hsm.h"

/*****************************************************************
** ��    ��:���ܻ���������ն�����ԿTMK,����������(��ZMK����)�ͼ��ֵ���ظ�����
** �������:
           ��
** �������:
           tInterface->szData   TMK(�������32Bytes)+CheckValue(4Bytes)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/29 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl05GetTmk0404( T_Interface *tInterface, int iSekTmkIndex, int iTekIndex )
{
    char    szInData[1024], szOutData[1024], szTmpStr[100];
    int     iLen, iRet, iSndLen, i;

    iLen = 0;
    /*����*/
    memcpy( szInData, "\x04\x04", 2 );    
    iLen += 2;
    /*��������Կ������,���ڼ����ն�����Կ*/
    sprintf( szTmpStr, "%04x", iSekTmkIndex );
    AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)(szInData+iLen)); 
    iLen += 2;
    /*�����㷨,3DES*/
    szInData[iLen] = 0x00;
    /*��Կ����*/
    szInData[iLen] = 8;
    iLen ++;
    szInData[iLen] = 0;
    memset( szOutData, 0, 1024 );
    iRet = CommuWithSjl05hsm( szInData, iLen, szOutData ); 
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    if( szOutData[0] == 'E' )
    {
        DispSjl05ErrorMsg( szOutData+1, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%02x]", szOutData[1]&0xFF );
        return SUCC;
    }

    BcdToAsc((uchar *)szOutData+2, 32, 0 , (uchar *)tInterface->szData);
    BcdToAsc((uchar *)szOutData+18, 4, 0 , (uchar *)(tInterface->szData+32));
    tInterface->iDataLen = 36;
    strcpy( tInterface->szReturnCode, TRANS_SUCC );

    return SUCC;
}

/*****************************************************************
** ��    ��:���ܻ���������ն�����ԿTMK,����������(��ZMK����)�ͼ��ֵ���ظ�����
** �������:
           ��
** �������:
           tInterface->szData  TMK(�������32Bytes)+CheckValue(4Bytes) 
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/29 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl05GetTmk( T_Interface *tInterface, int iSekTmkIndex, int iTekIndex )
{
    char    szInData[1024], szOutData[1024], szTmpStr[100];
    int     iLen, iRet, iSndLen, i;

    iLen = 0;
    /*����*/
    memcpy( szInData, "\x04\x20", 2 );    
    iLen += 2;
    /*��������Կ1������,���ڼ����ն�����Կ*/
    sprintf( szTmpStr, "%04x", iSekTmkIndex );
    AscToBcd( (uchar *)szTmpStr, 4, 0,(uchar *)(szInData+iLen) ); 
    iLen += 2;
    /*��������Կ2������,���ڼ����ն�����Կ*/
    sprintf( szTmpStr, "%04x", iTekIndex );
    AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)(szInData+iLen)); 
    iLen += 2;
    /*��Կ����*/
    szInData[iLen] = 1;
    iLen ++;
    szInData[iLen] = 0;
    memset( szOutData, 0, 1024 );
    iRet = CommuWithSjl05hsm( szInData, iLen, szOutData ); 
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    if( szOutData[0] == 'E' )
    {
        DispSjl05ErrorMsg( szOutData+1, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%02x]", szOutData[1]&0xFF );
        return SUCC;
    }

    BcdToAsc((uchar *)szOutData+1, 68, 0 ,(uchar *)tInterface->szData);
    tInterface->iDataLen = 68;
    strcpy( tInterface->szReturnCode, TRANS_SUCC );

    return SUCC;
}

/*****************************************************************
** ��    ��: ����������ԿPIK/MAK/MGK,���������ĺͼ��ֵ���ظ�����
** �������:
           tInterface->szData �ն�����Կ����(32)
** �������:
           tInterface->szData 
                PIK(�������32Bytes)+PIK(�´�POS32Bytes)+CheckValue(16Bytes)+
                MAC(�������32Bytes)+MAC(�´�POS32Bytes)+CheckValue(168Bytes) 
                MAG(�������32Bytes)+MAG(�´�POS32Bytes)+CheckValue(16Bytes)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/29 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl05GetWorkKey(T_Interface *tInterface, int iSekTmkIndex, 
        int iSekWorkIndex )
{
    char    szInData[1024], szOutData[1024], szTmpStr[100];
    char    szEnTmk[33];
    int     iLen, iRet, iSndLen, i;
    char    cChr;

    memcpy( szEnTmk, tInterface->szData, 32 );
    
    /* һ����������������Կ,������Ҫ����������Կ,�����Ҫ����2�� */
    for( i=0; i<2; i++ )
    {
        iLen = 0;
        /*����*/
        memcpy( szInData, "\x04\x21", 2 );    
        iLen += 2;
        /*���ڼ��ܹ�����Կ����������Կ1*/
        sprintf( szTmpStr, "%04x", iSekWorkIndex );
        AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)(szInData+iLen)); 
        iLen += 2;
        /*���ڽ����ն�����Կ����������Կ2*/
        sprintf( szTmpStr, "%04x", iSekTmkIndex );
        AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)(szInData+iLen)); 
        iLen += 2;
        /*������Կ1����*/
        szInData[iLen] = 1;            
        iLen ++;
        /*������Կ2����*/
        szInData[iLen] = 1;            
        iLen ++;
        /*�ն�����Կ����*/
        szInData[iLen] = 1;            
        iLen ++;
        /*�ն�����Կ����*/
        AscToBcd( (uchar *)szEnTmk, 32, 0 ,(uchar *)(szInData+iLen));    
        iLen += 16;
        szInData[iLen] = 0;
        memset( szOutData, 0, 1024 );
        iRet = CommuWithSjl05hsm( szInData, iLen, szOutData ); 
        if( iRet != SUCC )
        {
            WriteLog( ERROR, "commu with hsm fail" );
            strcpy( tInterface->szReturnCode, ERR_SYSTEM_ERROR );
            return FAIL;
        }
        if( szOutData[0] == 'E' )
        {
            DispSjl05ErrorMsg( szOutData+1, tInterface->szReturnCode );
            WriteLog( ERROR, "hsm fail[%02x]", szOutData[1]&0xFF );
            return SUCC;
        }

        if( i == 0 )
        {
            BcdToAsc(szOutData+1, 160, 0 ,tInterface->szData);
        }
        else
        {
            BcdToAsc(szOutData+1,  80, 0 ,tInterface->szData+160);
        }
    }

    tInterface->iDataLen = 240;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}
/*****************************************************************
** ��    ��:����������ԿPIK/MAK/MGK,���������ĺͼ��ֵ���ظ�����
** ע    ��:��Կ����Ϊ16λ,����8λ����8λһ��,�Ա㵽���������м�ҵ��ƽ̨���Ե���
            Sjl05ChangePin_PIK2TMK()����
** �������:
           tInterface->szData �ն�����Կ����(32)
** �������:
           tInterface->szData 
                PIK(�������32Bytes)+PIK(�´�POS32Bytes)+CheckValue(16Bytes)+
                MAC(�������32Bytes)+MAC(�´�POS32Bytes)+CheckValue(168Bytes) 
                MAG(�������32Bytes)+MAG(�´�POS32Bytes)+CheckValue(16Bytes)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/29 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl05GetWorkKey_FJICBC(T_Interface *tInterface, int iSekTmkIndex, 
        int iSekWorkIndex )
{
    char    szInData[1024], szOutData[1024], szTmpStr[100];
    char    szEnTmk[33];
    int     iLen, iRet, iSndLen, i;
    char    cChr;

    memcpy( szEnTmk, tInterface->szData, 32 );
    
    /* һ����������������Կ,������Ҫ����������Կ,�����Ҫ����2�� */
    for( i=0; i<2; i++ )
    {
        iLen = 0;
        /*����*/
        memcpy( szInData, "\x04\x21", 2 );    
        iLen += 2;
        /*���ڼ��ܹ�����Կ����������Կ1*/
        sprintf( szTmpStr, "%04x", iSekWorkIndex );
        AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)(szInData+iLen)); 
        iLen += 2;
        /*���ڽ����ն�����Կ����������Կ2*/
        sprintf( szTmpStr, "%04x", iSekTmkIndex );
        AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)(szInData+iLen)); 
        iLen += 2;
        /*������Կ1����*/
        szInData[iLen] = 0;            
        iLen ++;
        /*������Կ2����*/
        szInData[iLen] = 0;            
        iLen ++;
        /*�ն�����Կ����*/
        szInData[iLen] = 1;            
        iLen ++;
        /*�ն�����Կ����*/
        AscToBcd( (uchar *)szEnTmk, 32, 0,(uchar *)(szInData+iLen) );    
        iLen += 16;
        szInData[iLen] = 0;
        memset( szOutData, 0, 1024 );
        iRet = CommuWithSjl05hsm( szInData, iLen, szOutData ); 
        if( iRet != SUCC )
        {
            WriteLog( ERROR, "commu with hsm fail" );
            strcpy( tInterface->szReturnCode, ERR_SYSTEM_ERROR );
            return FAIL;
        }
        if( szOutData[0] == 'E' )
        {
            DispSjl05ErrorMsg( szOutData+1, tInterface->szReturnCode );
            WriteLog( ERROR, "hsm fail[%02x]", szOutData[1]&0xFF );
            return SUCC;
        }

        if( i == 0 )
        {
            //������Կ1������1��8λ(����������Կ1����)
            BcdToAsc(  szOutData+1, 16, 0 ,tInterface->szData);

            //������Կ1������1��8λ(����������Կ1����)
            BcdToAsc( szOutData+1, 16, 0 ,tInterface->szData+16);

            //������Կ1������2��8λ(���ն�����Կ����)
            BcdToAsc( szOutData+9, 16, 0 ,tInterface->szData+32);

            //������Կ1������2��8λ(���ն�����Կ����)
            BcdToAsc( szOutData+9, 16, 0 ,tInterface->szData+48);

            //������Կ1��chkval
            BcdToAsc( szOutData+17, 16, 0 ,tInterface->szData+64);


            //������Կ2������1��8λ(����������Կ1����)
            BcdToAsc( szOutData+25, 16, 0 ,tInterface->szData+80);

            //������Կ2������1��8λ(����������Կ1����)
            BcdToAsc( szOutData+25, 16, 0 ,tInterface->szData+96);

            //������Կ2������2��8λ(���ն�����Կ����)
            BcdToAsc( szOutData+33, 16, 0 ,tInterface->szData+112);

            //������Կ2������2��8λ(���ն�����Կ����)
            BcdToAsc( szOutData+33, 16, 0 ,tInterface->szData+128);

            //������Կ2��chkval
            BcdToAsc( szOutData+41, 16, 0 ,tInterface->szData+144);

        }
        else
        {
            //������Կ1������1��8λ(����������Կ1����)
            BcdToAsc( szOutData+1, 16, 0 ,tInterface->szData+160);

            //������Կ1������1��8λ(����������Կ1����)
            BcdToAsc( szOutData+1, 16, 0,tInterface->szData+176 );

            //������Կ1������2��8λ(���ն�����Կ����)
            BcdToAsc( szOutData+9, 16, 0 ,tInterface->szData+192);

            //������Կ1������2��8λ(���ն�����Կ����)
            BcdToAsc( szOutData+9, 16, 0 ,tInterface->szData+208);

            //������Կ1��chkval
            BcdToAsc( szOutData+17, 16, 0 ,tInterface->szData+224);
        }
    }

    tInterface->iDataLen = 240;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��:��ANSI X9.9 MAC�㷨��������MAC 
** �������:
           tInterface->szData ����MAC���������,������data_lenָ��
** �������:
           tInterface->szData MAC(8�ֽ�)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/29 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl05CalcMac(T_Interface *tInterface, int iSekIndex)
{
    char    szInData[2048], szOutData[2048], szTmpStr[100];
    int     iLen, iRet, iSndLen;

    iLen = 0;
    /* ���� */
    memcpy( szInData, "\x04\x10", 2 );    
    iLen += 2;

    /*��������Կ���� 1-��������Կ 2-�ն�����Կ 0-��������Կ*/
    szInData[iLen] = 1;
    iLen ++;

    /*��������Կ����*/
    sprintf( szTmpStr, "%04x", iSekIndex );
    AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)(szInData+iLen)); 
    iLen += 2;

    /*MAC��Կ����*/
    szInData[iLen] = 16;
    iLen ++;
    
    /* MAC�㷨 1-X9.9 2-X9.19 3-XOR*/
    if( tInterface->iAlog == X99_CALC_MAC )
    {
        szInData[iLen] = 1;        
    }
    else if( tInterface->iAlog == X919_CALC_MAC )
    {
        szInData[iLen] = 2;
    }
    else
    {
        szInData[iLen] = 3;
    }
    iLen += 1;

    /*MAC��Կ����*/
    memcpy( szInData+iLen, tInterface->szMacKey, 16 );    
    iLen += 16;

    /*��ʼ����*/
    memcpy( szInData+iLen, "\x00\x00\x00\x00\x00\x00\x00\x00", 8 );    
    iLen += 8;

    /*���ݳ���*/
    sprintf( szTmpStr, "%04x", tInterface->iDataLen );
    AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)(szInData+iLen));
    iLen += 2;

    /*����*/
       memcpy( szInData+iLen, tInterface->szData, tInterface->iDataLen );
    iLen += tInterface->iDataLen;
    szInData[iLen] = 0;
    
    iRet = CommuWithSjl05hsm( szInData, iLen, szOutData ); 
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "commu with hsm fail" );
        strcpy( tInterface->szReturnCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    if( szOutData[0] == 'E' )
    {
        DispSjl05ErrorMsg( szOutData+1, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%02x]", szOutData[1]&0xFF );
              return SUCC;
       }

       memcpy( tInterface->szData, szOutData+1, 8 );
    tInterface->iDataLen = 8;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��:��ԴPIN������ԴPIK����,����PIN��ʽת��,Ȼ����Ŀ��PIK�������
** ע    ��:����1�ʺ�Ϊȫ0ʱ,ת���ܲ���,����BUG,�������0406ָ��
** �������:
           tInterface->szData Դ�ʺ�(16�ֽ�)+��������(8�ֽ�)+Ŀ���ʺ�(16�ֽ�)
** �������:
           tInterface->szData ת���ܺ����������(8�ֽ�)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/29 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl05ChangePin0402(T_Interface *tInterface, int iSekPosIndex, int iSekHostIndex)
{
    char    szInData[1024], szOutData[1024], szPanBlock[17], szTargetPan[17], szTmpStr[100];
    int     iLen, iRet, iSndLen;

    sprintf( szPanBlock, "0000%12.12s", tInterface->szData+3 );
    szPanBlock[16] = 0;

    /*���ܻ���һ��BUG*/
    if( memcmp( szPanBlock, "0000000000000000", 16 ) == 0 )
    {
        sprintf( szTargetPan, "000%13.13s", tInterface->szData+27 );
        szTargetPan[16] = 0;
    }
    else
    {
        sprintf( szTargetPan, "0000%12.12s", tInterface->szData+27 );
        szTargetPan[16] = 0;
    }

    iLen = 0;
    /* ���� */
    memcpy( szInData, "\x04\x02", 2 );    
    iLen += 2;

    /* ����ԴPIK����������Կ����*/
    sprintf( szTmpStr, "%04x", iSekPosIndex );
    AscToBcd( (uchar *)szTmpStr, 4, 0,(uchar *)(szInData+iLen) );
    iLen += 2;

    /* ԴPIK�����㷨 */
    szInData[iLen] = 1;    
    iLen ++;

    /* ԴPIK��Կ���� */
    szInData[iLen] = 16;    
    iLen ++;

    /* ԴPIK��Կ���� */
    memcpy( szInData+iLen, tInterface->szPinKey, 16 );
    iLen += 16;

    /* ԴPinBlock�����㷨 */
    szInData[iLen] = 1;    
    iLen ++;

    /* ԴPinBlock���� */
    memcpy( szInData+iLen, tInterface->szData+16, 8 ); 
    iLen += 8;

    /* Դ�ʺ� */
    AscToBcd( szPanBlock, 16, 0, (uchar *)(szInData+iLen));    
    iLen += 8;

    /* ����Ŀ��PIK����������Կ����*/
    sprintf( szTmpStr, "%04x", iSekHostIndex );
    AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)(szInData+iLen));
    iLen += 2;

    /* Ŀ��PIK�����㷨 */
    szInData[iLen] = 1;    
    iLen ++;

    /* Ŀ��PIK��Կ���� */
    szInData[iLen] = 16;    
    iLen ++;

    /* Ŀ��PIK��Կ���� */
    memcpy( szInData+iLen, tInterface->szMacKey, 16 );
    iLen += 16;

    /* Ŀ��PinBlock�����㷨 */
    szInData[iLen] = 1;    
    iLen ++;

    /* Ŀ���ʺ� */
    AscToBcd( szTargetPan, 16, 0 ,(uchar *)(szInData+iLen));    
    iLen += 8;

    szInData[iLen] = 0;

    iRet = CommuWithSjl05hsm( szInData, iLen, szOutData ); 
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "commu with hsm fail" );
        strcpy( tInterface->szReturnCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    if( szOutData[0] == 'E' )
    {
        DispSjl05ErrorMsg( szOutData+1, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%02x]", szOutData[1]&0xFF );
              return SUCC;
       }

       memcpy( tInterface->szData, szOutData+1, 8 );
    tInterface->iDataLen = 8;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��: ��ԴPIN������ԴPIK����,����PIN��ʽת��,Ȼ����Ŀ��PIK�������
** �������:
           tInterface->szData Դ�ʺ�(16�ֽ�)+��������(8�ֽ�)+Ŀ���ʺ�(16�ֽ�)
** �������:
           tInterface->szData ת���ܺ����������(8�ֽ�)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/29 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl05ChangePin(T_Interface *tInterface, int iSekPosIndex, int iSekHostIndex)
{
    char    szInData[1024], szOutData[1024], szPanBlock[17], szTargetPan[17], szTmpStr[100];
    int     iLen, iRet, iSndLen;

    sprintf( szPanBlock, "%16.16s", tInterface->szData );
    szPanBlock[16] = 0;

    sprintf( szTargetPan, "%16.16s", tInterface->szData+24 );
    szTargetPan[16] = 0;

    iLen = 0;
    /* ���� */
    memcpy( szInData, "\x04\x06", 2 );    
    iLen += 2;

    /* ����ԴPIK����������Կ����*/
    sprintf( szTmpStr, "%04x", iSekPosIndex );
    AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)(szInData+iLen));
    iLen += 2;

    /* ԴPIK��Կ���� */
    szInData[iLen] = 16;    
    iLen ++;

    /* ԴPIK��Կ���� */
    memcpy( szInData+iLen, tInterface->szPinKey, 16 );
    iLen += 16;

    /* ����Ŀ��PIK����������Կ����*/
    sprintf( szTmpStr, "%04x", iSekHostIndex );
    AscToBcd( (uchar *)szTmpStr, 4, 0,(uchar *)(szInData+iLen) );
    iLen += 2;

    /* Ŀ��PIK��Կ���� */
    szInData[iLen] = 16;    
    iLen ++;

    /* Ŀ��PIK��Կ���� */
    memcpy( szInData+iLen, tInterface->szMacKey, 16 );
    iLen += 16;

    /* ԴPinBlock��ʽ */
    szInData[iLen] = 1;    
    iLen ++;

    /* Ŀ��PinBlock��ʽ */
    szInData[iLen] = 1;    
    iLen ++;

    /* ԴPinBlock���� */
    memcpy( szInData+iLen, tInterface->szData+16, 8 ); 
    iLen += 8;

    /* Դ�ʺ� */
    memcpy( szInData+iLen, szPanBlock, 16 );    
    iLen += 16;

    /* �ָ��� */
    szInData[iLen] = ';';    
    iLen ++;

    /* Ŀ���ʺ� */
    memcpy( szInData+iLen, szTargetPan, 16 );    
    iLen += 16;

    /* �ָ��� */
    szInData[iLen] = ';';    
    iLen ++;

    szInData[iLen] = 0;

    iRet = CommuWithSjl05hsm( szInData, iLen, szOutData ); 
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "commu with hsm fail" );
        strcpy( tInterface->szReturnCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    if( szOutData[0] == 'E' )
    {
        DispSjl05ErrorMsg( szOutData+1, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%02x]", szOutData[1]&0xFF );
              return SUCC;
       }

       memcpy( tInterface->szData, szOutData+1, 8 );
    tInterface->iDataLen = 8;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}
/*****************************************************************
** ��    ��: ��֤�ն����͵�PIN�Ƿ������ݿ��е�PINһ��
             ��2��:
             1����PIK��PIN���ļ���
             2�����ն����͵����Ľ��бȽ�
** �������:
           tInterface->szData  ���ݿ�����������(8�ֽ�)+�ն�PIN����(8�ֽ�)
** �������:
           tInterface->szData  SUCC-һ��  FAIL-��һ��
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/29 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl05VerifyPin(T_Interface *tInterface, int iSekPosIndex)
{
    char    szInData[1024], szOutData[1024], szPanBlock[17], szPinBlock[17], szEncPin[17], szTmpStr[100];
    int     iLen, i, iRet, iSndLen;

    memset( szPanBlock, 0x00, 8 );

    sprintf( szTmpStr, "08%8.8sFFFFFF", tInterface->szData );
    AscToBcd( szTmpStr, 16, 0 ,(uchar *)szPinBlock);
    
    for( i=0; i<8; i++ )
    {
        szTmpStr[i] = szPinBlock[i]^szPanBlock[i];
    }
    memcpy( szPinBlock, szTmpStr, 8 );

    iLen = 0;
    /* ���� */
    memcpy( szInData, "\x04\x05", 2 );    
    iLen += 2;

    /* ����PIK����������Կ����*/
    sprintf( szTmpStr, "%04x", iSekPosIndex );
    AscToBcd( (uchar *)szTmpStr, 4, 0,(uchar *)(szInData+iLen) );
    iLen += 2;

    /* PIK�����㷨 */
    szInData[iLen] = 1;    
    iLen ++;

    /* PIK��Կ���� */
    szInData[iLen] = 16;    
    iLen ++;

    /* PIK��Կ���� */
    memcpy( szInData+iLen, tInterface->szPinKey, 16 );
    iLen += 16;

    /* PinBlock */
    memcpy( szInData+iLen, szPinBlock, 8 );
    iLen += 8;

    szInData[iLen] = 0;

    iRet = CommuWithSjl05hsm( szInData, iLen, szOutData ); 
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "commu with hsm fail" );
        strcpy( tInterface->szReturnCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    if( szOutData[0] == 'E' )
    {
        DispSjl05ErrorMsg( szOutData+1, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%02x]", szOutData[1]&0xFF );
              return SUCC;
       }

       memcpy( szEncPin, szOutData+1, 8 );
    if( memcmp( tInterface->szData+8, szEncPin, 8 ) == 0 )
    {
        strcpy( tInterface->szData, "SUCC" );
    }
    else
    {
        strcpy( tInterface->szData, "FAIL" );
    }
    tInterface->iDataLen = 4;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��: ����PIN
** �������:
           tInterface->szData   �ʺ�(16�ֽ�)+�ն�PIN����(8�ֽ�)
** �������:
           tInterface->szData   ��������
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/29 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl05DecryptPin(T_Interface *tInterface, int iSekPosIndex)
{
    char    szInData[1024], szOutData[1024], szPanBlock[17], szBcdPanBlock[17], szEncPin[17], szTmpStr[100];
    int     iLen, i, iRet, iSndLen;

    sprintf( szPanBlock, "0000%12.12s", tInterface->szData+3 );
    AscToBcd( (uchar *)szPanBlock, 16, 0 , (uchar *)szBcdPanBlock);

    memcpy( szEncPin, tInterface->szData+16, 8 );
    
    iLen = 0;
    /* ���� */
    memcpy( szInData, "\x04\x22", 2 );    
    iLen += 2;

    /* ����PIK����������Կ����*/
    sprintf( szTmpStr, "%04x", iSekPosIndex );
    AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)(szInData+iLen));
    iLen += 2;

    /* �������� */
    memcpy( szInData+iLen, szEncPin, 8 );
    iLen += 8;

    /* ���ʺ� */
    memcpy( szInData+iLen, szBcdPanBlock, 8 );
    iLen += 8;

    /* PIK���� */
    memcpy( szInData+iLen, "\x10", 1 );    
    iLen += 1;

    /* PIK��Կ���� */
    memcpy( szInData+iLen, tInterface->szPinKey, 16 );
    iLen += 16;

    szInData[iLen] = 0;

    iRet = CommuWithSjl05hsm( szInData, iLen, szOutData ); 
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "commu with hsm fail" );
        strcpy( tInterface->szReturnCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    if( szOutData[0] == 'E' )
    {
        DispSjl05ErrorMsg( szOutData+1, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%02x]", szOutData[1]&0xFF );
              return SUCC;
       }

    iLen = (uchar)szOutData[1];
    if( iLen < 4 || iLen > 8 )
    {
        WriteLog( ERROR, "pin_len error �������볤�ȴ���" );
        strcpy( tInterface->szReturnCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }
    BcdToAsc( szOutData+2, 14, 0 ,(uchar *)szTmpStr);
    memcpy( tInterface->szData, szTmpStr, iLen );
    tInterface->szData[iLen] = 0;
    tInterface->iDataLen = iLen;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��: ������Կ��У��ֵ
** �������:
           tInterface->szData  ��Կ����(32�ֽ�)
** �������:
           tInterface->szData  У��ֵ(16)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/29 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl05CalcChkval(T_Interface *tInterface, int iSekIndex)
{
    char    szInData[1024], szOutData[1024], szTmpStr[100];
    int     iLen, iRet, iSndLen;

    iLen = 0;
    /* ���� */
    memcpy( szInData, "\x04\x23", 2 );    
    iLen += 2;

    /* ����PIK�Ĵ洢������Կ���� */
    sprintf( szTmpStr, "%04x", iSekIndex );
    AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)(szInData+iLen));
    iLen += 2;

    /* ��Կ���� */
    szInData[iLen] = 16;    
    iLen ++;

    /* ��Կ���� */
    AscToBcd( (uchar *)tInterface->szData, 32, 0 ,(uchar *)(szInData+iLen));
    iLen += 16;

    iRet = CommuWithSjl05hsm( szInData, iLen, szOutData ); 
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "commu with hsm fail" );
        strcpy( tInterface->szReturnCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    if( szOutData[0] == 'E' )
    {
        DispSjl05ErrorMsg( szOutData+1, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%02x]", szOutData[1]&0xFF );
              return SUCC;
       }

    BcdToAsc( (uchar *)(szOutData+1), 8, 0 , (uchar *)tInterface->szData);
    tInterface->iDataLen = 8;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��: ���ܻ�ת���ܹ�����Կ,������TMK���ܵĹ�����Կ��ԭ������,Ȼ������ָ����SEK����
** �������:
           tInterface->szData    TMK����(32Bytes)+PIK����(32Bytes)+MAK����(32Bytes),����
           iSekTmkIndex        ����TMK��SEK��Կ����
           iSekWorkKeyIndex    ���ܹ�����Կ��SEK��Կ����
** �������:
           tInterface->szData    PIK����(32Bytes)+MAK����(32Bytes)+TMK����(32Bytes),������Կ��ָ��SEK����
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/29 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl05ChangeWorkKey( T_Interface *tInterface, int iSekTmkIndex, int iSekWorkIndex )
{
    char    szInData[1024], szOutData[1024], szTmk[33], szEnKey[256];
    char    szOutKey[256], szTmpStr[100];
    int     iLen, iRet, iSndLen, i;

    AscToBcd( (uchar *)tInterface->szData, 32, 0 ,(uchar *)szTmk);

    AscToBcd( (uchar *)tInterface->szData+32, 64, 0,(uchar *)szEnKey );

    /* =================���ն�����Կ����������Կ====================== */
    iLen = 0;
    /*����*/
    memcpy( szInData, "\x71", 1 );    
    iLen += 1;

    /* �����ն�����Կ����������Կ���� */
    sprintf( szTmpStr, "%04x", iSekTmkIndex );
    AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)(szInData+iLen));
    iLen += 2;

    /* TMK���� */
    memcpy( szInData+iLen, szTmk, 16 );
    iLen += 16;

    /* ��ʼ���� */
    memcpy( szInData+iLen, "\x00\x00\x00\x00\x00\x00\x00\x00", 8 );    
    iLen += 8;

    /* �ӽ��ܱ�־,1-���� 0-���� */
    szInData[iLen] = 0;
    iLen += 1;

    /* �㷨��ʶ */
    szInData[iLen] = 0;
    iLen += 1;

    /* ������Կ���� */
    sprintf( szTmpStr, "%04x", 32 );
    AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)(szInData+iLen));
    iLen += 2;

    /* ������Կ���� */
    memcpy( szInData+iLen, szEnKey, 32 );
    iLen += 32;
    szInData[iLen] = 0;

    memset( szOutData, 0, 1024 );
    iRet = CommuWithSjl05hsm( szInData, iLen, szOutData ); 
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    if( szOutData[0] == 'E' )
    {
        DispSjl05ErrorMsg( szOutData+1, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%02x]", szOutData[1]&0xFF );
        return SUCC;
    }
    memcpy( szOutKey, szOutData+3, 32 );


    /* ===================����������Կ����������Կ==================== */
    iLen = 0;
    /*����*/
    memcpy( szInData, "\x72", 1 );    
    iLen += 1;

    /* ����������Կ����������Կ */
    sprintf( szTmpStr, "%04x", iSekWorkIndex );
    AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)(szInData+iLen));
    iLen += 2;

    /* ��ʼ���� */
    memcpy( szInData+iLen, "\x00\x00\x00\x00\x00\x00\x00\x00", 8 );    
    iLen += 8;

    /* �ӽ��ܱ�־,1-���� 0-���� */
    szInData[iLen] = 1;
    iLen += 1;

    /* �㷨��ʶ */
    szInData[iLen] = 0;
    iLen += 1;

    /* ������Կ���� */
    sprintf( szTmpStr, "%04x", 32 );
    AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)(szInData+iLen));
    iLen += 2;

    /* ������Կ���� */
    memcpy( szInData+iLen, szOutKey, 32 );
    iLen += 32;
    szInData[iLen] = 0;

    memset( szOutData, 0, 1024 );
    iRet = CommuWithSjl05hsm( szInData, iLen, szOutData ); 
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    if( szOutData[0] == 'E' )
    {
        DispSjl05ErrorMsg( szOutData+1, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%02x]", szOutData[1]&0xFF );
        return SUCC;
    }

    BcdToAsc(szOutData+3, 64, 0 ,(uchar *)tInterface->szData);
    BcdToAsc( szTmk, 32, 0 ,(uchar *)tInterface->szData+64);
    tInterface->iDataLen = 96;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );

    return SUCC;
}

/*****************************************************************
** ��    ��: ��ԴPIN������ԴPIK����,����PIN��ʽת��,Ȼ����TMK�������ת��PIN��PIK���ܵ�TMK����
** �������:
           tInterface->szData    Դ�ʺ�(16�ֽ�)+��������(8�ֽ�)+Ŀ���ʺ�(16�ֽ�)
** �������:
           tInterface->szData    ת���ܺ����������(8�ֽ�)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/29 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl05ChangePin_PIK2TMK(T_Interface *tInterface, int iSekPosIndex, int iTmkIndex)
{
    char    szInData[1024], szOutData[1024], szPanBlock[17], szTargetPan[17], szTmpStr[100];
    int     iLen, iRet, iSndLen;

    sprintf( szPanBlock, "%16.16s", tInterface->szData );
    szPanBlock[16] = 0;

    sprintf( szTargetPan, "%16.16s", tInterface->szData+24 );
    szTargetPan[16] = 0;

    iLen = 0;
    /* ���� */
    memcpy( szInData, "\x6E", 1 );    
    iLen += 1;

    /* ����ԴPIK����������Կ����*/
    sprintf( szTmpStr, "%04x", iSekPosIndex );
    AscToBcd( (uchar *)szTmpStr, 4, 0,(uchar *)(szInData+iLen) );
    iLen += 2;

    /* TMK��Կ���� */
    sprintf( szTmpStr, "%04x", iTmkIndex );
    AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)(szInData+iLen));
    iLen += 2;

    /* ԴPIK��Կ���� */
    memcpy( szInData+iLen, tInterface->szPinKey, 8 );
    iLen += 8;

    /* ԴPinBlock���� */
    memcpy( szInData+iLen, tInterface->szData+16, 8 ); 
    iLen += 8;

    /* Դ�ʺ� */
    AscToBcd( (uchar *)szPanBlock, 16, 0 ,(uchar *)(szInData+iLen));    
    iLen += 8;

    /* Ŀ���ʺ� */
    AscToBcd( (uchar *)szTargetPan, 16, 0 ,(uchar *)szInData+iLen);    
    iLen += 8;

    szInData[iLen] = 0;

    iRet = CommuWithSjl05hsm( szInData, iLen, szOutData ); 
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "commu with hsm fail" );
        strcpy( tInterface->szReturnCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    if( szOutData[0] == 'E' )
    {
        DispSjl05ErrorMsg( szOutData+1, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%02x]", szOutData[1]&0xFF );
              return SUCC;
       }

       memcpy( tInterface->szData, szOutData+1, 8 );
    tInterface->iDataLen = 8;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��: ���ܴŵ�����
** �������:
           tInterface->szData    �ŵ�����
** �������:
           tInterface->szData    �ŵ���������
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/29 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl05DecryptTrack(T_Interface *tInterface, int iSekPosIndex)
{
    char    szInData[1024], szOutData[1024], szTargetPan[17], szTmpStr[100];
    int     iLen ,iRet, iSndLen;
    unsigned char    szMagKey[17], szEnMagKey[17], szTrack2[40];
    char    szTrack3[105], szTmk[17];
    int     i, j, iMacAlog, iAlog, iLenTmp, iTrack2Len, iTrack3Len;
    char szBuf[200];
    memset(szBuf, 0, sizeof(szBuf));
    iAlog = tInterface->iAlog;
    
    memcpy( szEnMagKey, tInterface->szPinKey, 16 );

    iLen = 0;
    /* ���� */
    memcpy( szInData, "\x71", 1 );    
    iLen += 1;

    /* ����KEY����������Կ����*/
    sprintf( szTmpStr, "%04x", iSekPosIndex );
    AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)szInData+iLen);
    iLen += 2;
    /* �ӽ��ܵ�KEY����*/
    
    memcpy( szInData+iLen, tInterface->szPinKey, 16 );
    iLen += 16;
    
    /*CBC���ܵĳ�ʼ����*/
    memcpy( szInData+iLen, "\x00\x00\x00\x00\x00\x00\x00\x00", 8 );
    iLen += 8;
    
    /*���ܱ�ʶ*/
    memcpy( szInData+iLen, "\x00", 1 ); 
    iLen += 1;
    /* �㷨��ʶ */
    memcpy( szInData+iLen, "\x00", 1 ); 
    iLen += 1;
    /*�������ݵĳ���*/
    memset(szTmpStr, 0, sizeof(szTmpStr));
    sprintf( szTmpStr, "%04x", tInterface->iDataLen );
    AscToBcd( (uchar *)szTmpStr, 4, 0 ,(uchar *)szInData+iLen);
    iLen += 2;
    
    /*���������*/
    memcpy( szInData+iLen, tInterface->szData, tInterface->iDataLen  );
    iLen += tInterface->iDataLen;
    

    szInData[iLen] = 0;
    iRet = CommuWithSjl05hsm( szInData, iLen, szOutData ); 
    if( iRet != SUCC )
    {
        WriteLog( ERROR, "commu with hsm fail" );
        strcpy( tInterface->szReturnCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }
    if( szOutData[0] == 'E' )
    {
        DispSjl05ErrorMsg( szOutData+1, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%02x]", szOutData[1]&0xFF );
              return SUCC;
       }
       tInterface->iDataLen = szOutData[1]*256 + szOutData[2];
       memcpy( szTmpStr, szOutData+1+2, tInterface->iDataLen );
       iLenTmp = tInterface->iDataLen;
    

    BcdToAsc( szTmpStr, iLenTmp*2, 0 ,szBuf);
    //ȡ��2�ŵ�
    for( i=0; i<iLenTmp*2 && i<37; i++ )
    {
        if( szBuf[i] == 'D' )
        {
            szBuf[i] = '=';
        }
        else if( szBuf[i] == 'F' )
        {
            break;
        }
    }
    memcpy( szTrack2, szBuf, i );
    szTrack2[i] = 0;
    iTrack2Len = i;

    //����F
    for( j=i; j<iLenTmp*2; j++ )
    {
        if( szBuf[j] != 'F' )
            break;
    }

    //ȡ��3�ŵ�
    for( i=j; i<iLenTmp*2; i++ )
    {
        if( szBuf[i] == 'D' )
        {
            szBuf[i] = '=';
        }
        else if( szBuf[i] == 'F' )
        {
            break;
        }
    }
    memcpy( szTrack3, szBuf+j, i-j );
    szTrack3[i-j] = 0;
    iTrack3Len = i-j;

    i = 0;
    tInterface->szData[i] = iTrack2Len;
    i ++;
    memcpy( tInterface->szData+i, szTrack2, iTrack2Len );
    i += iTrack2Len;

    tInterface->szData[i] = iTrack3Len;
    i ++;
    memcpy( tInterface->szData+i, szTrack3, iTrack3Len );
    i += iTrack3Len;

    tInterface->iDataLen = i;
    strcpy( tInterface->szReturnCode, TRANS_SUCC );
    
   
    return SUCC;
}
