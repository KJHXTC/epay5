/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:
           ����ר�ü��ܻ��ӿ�
** �� �� ��:Robin 
** ��������:2009/08/29


$Revision: 1.10 $
$Log: unionpayhsm.c,v $
Revision 1.10  2012/12/26 01:44:17  wukj
%s/commu_with_hsm/CommuWithHsm/g

Revision 1.9  2012/12/05 06:32:14  wukj
*** empty log message ***

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
** ��    ��:���ܻ���������ն�����ԿTMK�����������ĺͼ��ֵ���ظ�����.
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
int Sjl06UphsmGetTmk( T_Interface *tInterface, int iSekTmkIndex, int iTekIndex )
{
    char    szInData[1024], szOutData[1024], szRetCode[3];
    int     iLen, iRet, iSndLen, i;

    iLen = 0;
    /*����*/
    memcpy( szInData, "K0", 2 );    
    iLen += 2;
    /* sek */
    sprintf( szInData+iLen, "S%04ld", iSekTmkIndex ); 
    iLen += 5;
    /* tek */
    sprintf( szInData+iLen, "T%04ld", iTekIndex ); 
    iLen += 5;
    szInData[iLen] = 'Y';
    iLen ++;
    szInData[iLen] = 0;
    memset( szOutData, 0, 1024 );
    iRet = CommuWithHsm( szInData, iLen, szOutData ); 
    if( iRet == FAIL )
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    if( memcmp(szOutData, "K1", 2) != 0  ||
        memcmp(szOutData+2, "00", 2) != 0 )
    {
        DispUphsmErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%2.2s]", szOutData+2 );
        return SUCC;
    }

    memcpy( tInterface->szData, szOutData+4, 68 );
    tInterface->iDataLen = 68;
    strcpy( tInterface->szReturnCode, TRANS_SUCC );

    return SUCC;
}

/*****************************************************************
** ��    ��:����������ԿPIK/MAK�����������ĺͼ��ֵ���ظ�����.
** �������:
           ��
** �������:
           tInterface->szData   
                  PIK(�������32Bytes)+PIK(�´�POS32Bytes)+CheckValue(16Bytes)+ 
                  MAK(�������32Bytes)+PIK(�´�POS32Bytes)+CheckValue(168Bytes)
                  MAG(�������32Bytes)+PIK(�´�POS32Bytes)+CheckValue(16Bytes)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/29 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl06UphsmGetWorkKey(T_Interface *tInterface, int iSekTmkIndex,
        int iSekWorkIndex )
{
    char    szInData[1024], szOutData[1024], szPsamNo[17], szRand[33];
    char    szEnTmk[33];
    int     iLen, iRet, iSndLen, i;
    char    cChr;

    memcpy( szEnTmk, tInterface->szData, 32 );
    
    for( i=0; i<3; i++ )
    {
        iLen = 0;
        /*����*/
        memcpy( szInData, "K2", 2 );    
        iLen += 2;
        /*���ڽ����ն�����Կ�Ĵ洢������Կ����*/
        sprintf( szInData+iLen, "S%04ld", iSekTmkIndex ); 
        iLen += 5;
        /*���ڼ��ܹ�����Կ�Ĵ洢������Կ����*/
        sprintf( szInData+iLen, "S%04ld", iSekWorkIndex ); 
        iLen += 5;
        /*�ն�����Կ���ȱ�ʶ��16λ��*/
        szInData[iLen] = 'Y';            
        iLen ++;
        memcpy( szInData+iLen, szEnTmk, 32 );    
        iLen += 32;
        /*���ɵĹ�����Կ���ȱ�ʶ��16λ��*/
        szInData[iLen] = 'Y';    
        iLen ++;
        szInData[iLen] = 0;
        memset( szOutData, 0, 1024 );
        iRet = CommuWithHsm( szInData, iLen, szOutData ); 
        if( iRet == FAIL )
        {
            WriteLog( ERROR, "commu with hsm fail" );
            strcpy( tInterface->szReturnCode, ERR_SYSTEM_ERROR );
            return FAIL;
        }
        if( memcmp(szOutData, "K3", 2) != 0  ||
            memcmp(szOutData+2, "00", 2) != 0 )
        {
            DispUphsmErrorMsg( szOutData+2, tInterface->szReturnCode );
            WriteLog( ERROR, "hsm fail[%2.2s]", szOutData+2 );
            return SUCC;
        }

        memcpy( tInterface->szData+i*80, szOutData+4, 80 );
    }

    tInterface->iDataLen = 240;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��: ��ANSI X9.9 MAC�㷨��������MAC. 
** �������:
           tInterface->szData    ����MAC���������
           tInterface-.datalen ����
** �������:
           tInterface->szData    MAC(8�ֽ�)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/29 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl06UphsmCalcMac(T_Interface *tInterface, int iSekIndex)
{
    char    szInData[2048], szOutData[2048];
    int     iLen, iRet, iSndLen;

    iLen = 0;
    memcpy( szInData, "M0", 2 );    /* ���� */
    iLen += 2;

    /* MAC�㷨 1-XOR 2-X9.9 3-X9.19 */
    if( tInterface->iAlog == X99_CALC_MAC )
    {
        szInData[iLen] = '2';        
    }
    else if( tInterface->iAlog == XOR_CALC_MAC )
    {
        szInData[iLen] = '1';
    }
    else
    {
        szInData[iLen] = '3';
    }
    iLen += 1;

    sprintf( szInData+iLen, "S%04ld", iSekIndex );    /* ������Կ���� */
    iLen += 5;

    szInData[iLen] = 'Y';            /* ��Կ���ȱ�ʶ��16λ�� */
    iLen ++;

    BcdToAsc( (uchar *)(tInterface->szMacKey), 32, 0, (uchar *)(szInData+iLen) );    /*MAC��Կ����*/
    iLen += 32;

    sprintf( szInData+iLen, "%04ld", tInterface->iDataLen );
    iLen += 4;

    memcpy( szInData+iLen, tInterface->szData, tInterface->iDataLen );
    iLen += tInterface->iDataLen;
    
    iRet = CommuWithHsm( szInData, iLen, szOutData ); 
    if( iRet == FAIL )
    {
        WriteLog( ERROR, "commu with hsm fail" );
        strcpy( tInterface->szReturnCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    if( memcmp(szOutData, "M1", 2) != 0 ||
        memcmp(szOutData+2, "00", 2) != 0 )
    {
        DispUphsmErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm calc mac fail[%2.2s]", szOutData+2 );
        return SUCC;
    }

    AscToBcd( (uchar *)(szOutData+4), 16, 0 ,(uchar *)(tInterface->szData));
    tInterface->iDataLen = 8;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��: ��ԴPIN������ԴPIK���ܣ�����PIN��ʽת����Ȼ����Ŀ��PIK�������.
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
int Sjl06UphsmChangePin(T_Interface *tInterface, int iSekPosIndex, int iSekPppIndex)
{
    char    szInData[1024], szOutData[1024], szPanBlock[17], szTargetPan[17];
    int     iLen, iRet, iSndLen;

    sprintf( szPanBlock, "0000%12.12s", tInterface->szData+3 );
    szPanBlock[16] = 0;

    sprintf( szTargetPan, "0000%12.12s", tInterface->szData+27 );
    szTargetPan[16] = 0;

    iLen = 0;
    memcpy( szInData, "P0", 2 );    /* ���� */
    iLen += 2;

    /* ����ԴPIK�Ĵ洢������Կ���� */
    sprintf( szInData+iLen, "S%04ld", iSekPosIndex );
    iLen += 5;

    /* ����Ŀ��PIK�Ĵ洢������Կ���� */
    sprintf( szInData+iLen, "S%04ld", iSekPppIndex );
    iLen += 5;

    /* ԴPIK��Կ���ȱ�ʶ��16λ�� */
    szInData[iLen] = 'Y';    
    iLen ++;

    /* ԴPIK��Կ���� */
    BcdToAsc( (uchar *)(tInterface->szPinKey), 32, 0 ,(uchar *)(szInData+iLen));    
    iLen += 32;

    /* Ŀ��PIK��Կ���ȱ�ʶ��16λ�� */
    szInData[iLen] = 'Y';    
    iLen ++;

    /* Ŀ��PIK��Կ���� */
    BcdToAsc( (uchar *)(tInterface->szMacKey), 32, 0 ,(uchar *)(szInData+iLen));    
    iLen += 32;

    /* ԴPinBlock��ʽ */
    memcpy( szInData+iLen, "01", 2 );    
    iLen += 2;

    /* Ŀ��PinBlock��ʽ */
    memcpy( szInData+iLen, "01", 2 );    
    iLen += 2;

    /* ԴPinBlock���� */
    BcdToAsc( (uchar *)(tInterface->szData+16), 16, 0 ,(uchar *)(szInData+iLen));    
    iLen += 16;

    /* Դ�ʺ� */
    memcpy( szInData+iLen, szPanBlock, 16 );    
    iLen += 16;

    /* Ŀ���ʺ� */
    memcpy( szInData+iLen, szTargetPan, 16 );    
    iLen += 16;

    iRet = CommuWithHsm( szInData, iLen, szOutData ); 
    if( iRet == FAIL )
    {
        WriteLog( ERROR, "commu with hsm fail" );
        strcpy( tInterface->szReturnCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    if( memcmp(szOutData, "P1", 2) != 0 ||
        memcmp(szOutData+2, "00", 2) != 0 )
    {
        DispUphsmErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm pin change fail[%2.2s]", szOutData+2 );
        return SUCC;
    }

    AscToBcd( (uchar *)(szOutData+4), 16, 0 ,(uchar *)(tInterface->szData));
    tInterface->iDataLen = 8;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��:  ��֤�ն����͵�PIN�Ƿ������ݿ��е�PINһ��
              ��2��:
              1.��PIK��PIN���ļ���
              2.���ն����͵����Ľ��бȽ�
** �������:
           tInterface->szData     ���ݿ�����������(8�ֽ�)+�ն�PIN����(8�ֽ�)
** �������:
           tInterface->szData     SUCC-һ��  FAIL-��һ��
** �� �� ֵ: 
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/29 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl06UphsmVerifyPin(T_Interface *tInterface, int iSekPosIndex)
{
    char    szInData[1024], szOutData[1024], szPanBlock[17], szEncPin[17];
    int     iLen, iRet, iSndLen;

    memset( szPanBlock, '0', 16 );
    szPanBlock[16] = 0;

    iLen = 0;
    memcpy( szInData, "60", 2 );    /* ���� */
    iLen += 2;

    /* ����PIK�Ĵ洢������Կ���� */
    sprintf( szInData+iLen, "S%04ld", iSekPosIndex );
    iLen += 5;

    /* PIK��Կ���ȱ�ʶ��16λ�� */
    szInData[iLen] = 'Y';    
    iLen ++;

    /* PIK��Կ���� */
    BcdToAsc( (uchar *)(tInterface->szPinKey), 32, 0 ,(uchar *)(szInData+iLen));    
    iLen += 32;

    /* PinBlock��ʽ */
    memcpy( szInData+iLen, "01", 2 );    
    iLen += 2;

    /* PIN���� */
    memcpy( szInData+iLen, "08", 2 );
    iLen += 2;
    memcpy( szInData+iLen, tInterface->szData, 8 );
    iLen += 8;
    memcpy( szInData+iLen, "FFFFFFFF", 6 );
    iLen += 6;

    /* �ʺ� */
    memcpy( szInData+iLen, szPanBlock, 16 );    
    iLen += 16;

    iRet = CommuWithHsm( szInData, iLen, szOutData ); 
    if( iRet == FAIL )
    {
        WriteLog( ERROR, "commu with hsm fail" );
        strcpy( tInterface->szReturnCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    if( memcmp(szOutData, "61", 2) != 0 ||
        memcmp(szOutData+2, "00", 2) != 0 )
    {
        DispUphsmErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm encrypt pin fail[%2.2s]", szOutData+2 );
        return SUCC;
    }

    AscToBcd( (uchar *)(szOutData+4), 16, 0 ,(uchar *)szEncPin);
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
** ��    ��: ������Կ��У��ֵ
** �������:
           tInterface->szData   ��Կ����(32�ֽ�)
** �������:
           tInterface->szData   У��ֵ(16)
** �� �� ֵ: 
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/29 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl06UphsmCalcChkval(T_Interface *tInterface, int iSekIndex)
{
    char    szInData[1024], szOutData[1024], szPanBlock[17];
       int     iLen, iRet, iSndLen;

    iLen = 0;
    memcpy( szInData, "3A", 2 );    /* ���� */
    iLen += 2;

    /* ����PIK�Ĵ洢������Կ���� */
    sprintf( szInData+iLen, "S%04ld", iSekIndex );
    iLen += 5;

    /* ��Կ���ȱ�ʶ��16λ�� */
    szInData[iLen] = 'Y';    
    iLen ++;

    /* ��Կ���� */
    memcpy( szInData+iLen, tInterface->szData, 32 );
    iLen += 32;

    iRet = CommuWithHsm( szInData, iLen, szOutData ); 
    if( iRet == FAIL )
    {
        WriteLog( ERROR, "commu with hsm fail" );
        strcpy( tInterface->szReturnCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    if( memcmp(szOutData, "3B", 2) != 0 ||
        memcmp(szOutData+2, "00", 2) != 0 )
    {
        DispUphsmErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm encrypt pin fail[%2.2s]", szOutData+2 );
        return SUCC;
    }

    memcpy( tInterface->szData, szOutData+4, 8 );
    tInterface->iDataLen = 8;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��: ���ܻ�ת���ܹ�����Կ��������TMK���ܵĹ�����Կ��ԭ�����ģ�Ȼ������ָ����SEK����
** �������:
           tInterface->szData   TMK����(32Bytes)+PIK����(32Bytes)+MAK����(32Bytes)��������Կ��TMK����
           iSekTmkIndex       ����TMK��SEK��Կ����
           iSekWorkKeyIndex   ���ܹ�����Կ��SEK��Կ����
** �������:
           tInterface->szData   PIK����(32Bytes)+MAK����(32Bytes)+TMK����(32Bytes)��������Կ��ָ��SEK����
** �� �� ֵ: 
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/29 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl06UphsmChangeWorkKey( T_Interface *tInterface, int iSekTmkIndex, int iSekWorkIndex )
{
    char    szInData[1024], szOutData[1024], szRetCode[3], szTmk[33];
    char    szOutKey[256];
    int     iLen, iRet, iSndLen, i;

    memcpy( szTmk, tInterface->szData, 32 );
    for( i=1; i<=2; i++ )
    {
        iLen = 0;
        /*����*/
        memcpy( szInData, "KI", 2 );    
        iLen += 2;
        /* sek1 */
        sprintf( szInData+iLen, "S%04ld", iSekWorkIndex ); 
        iLen += 5;
        /* sek2 */
        sprintf( szInData+iLen, "S%04ld", iSekTmkIndex); 
        iLen += 5;
        /* TMK��Կ���� */
        szInData[iLen] = 'Y';
        iLen ++;
        /* TMK���� */
        memcpy( szInData+iLen, szTmk, 32 );
        iLen += 32;
        /* ת����ʶ 0����SEK��TMK���� 1����TMK��SEK���� */
        szInData[iLen] = '1';
        iLen ++;
        /* PIK��Կ���� */
        szInData[iLen] = 'Y';
        iLen ++;
        /* PIK/MAC���� */
        memcpy( szInData+iLen, tInterface->szData+32*i, 32 );
        iLen += 32;
        szInData[iLen] = 0;
        memset( szOutData, 0, 1024 );
        iRet = CommuWithHsm( szInData, iLen, szOutData ); 
        if( iRet == FAIL )
        {
            WriteLog( ERROR, "commu with hsm fail" );
            return FAIL;
        }
        if( memcmp(szOutData, "KJ", 2) != 0  ||
            memcmp(szOutData+2, "00", 2) != 0 )
        {
            DispUphsmErrorMsg( szOutData+2, tInterface->szReturnCode );
            WriteLog( ERROR, "hsm fail[%2.2s]", szOutData+2 );
            return SUCC;
        }

        memcpy( szOutKey+32*(i-1), szOutData+4, 32 );
    }
    memcpy( tInterface->szData, szOutKey, 64 );
    memcpy( tInterface->szData+64, szTmk, 32 );
    tInterface->iDataLen = 96;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );

    return SUCC;
}
