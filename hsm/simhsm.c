/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:����ܽӿں���
           
** �� �� ��:Robin 
** ��������:2009/08/29


$Revision: 1.11 $
$Log: simhsm.c,v $
Revision 1.11  2012/12/28 07:37:08  fengw

1���޸�SimhsmGetWorkKey�����й�����Կ����˳��

Revision 1.10  2012/12/10 07:52:07  wukj
ANS��غ�����������

Revision 1.9  2012/12/05 06:32:14  wukj
*** empty log message ***

Revision 1.8  2012/12/03 03:24:46  wukj
int����ǰ׺�޸�Ϊi

Revision 1.7  2012/11/29 07:51:43  wukj
�޸���־����,�޸�ascbcdת������

Revision 1.6  2012/11/21 04:13:38  wukj
�޸�hsmincl.h Ϊhsm.h

Revision 1.5  2012/11/21 03:20:31  wukj
1:���ܻ����������޸� 2: ȫ�ֱ�������hsmincl.h


*******************************************************************/

#include "hsm.h"

extern char gszMasterKeySim[17];
char gszTmk[17] = "\x11\x11\x11\x11\x11\x11\x11\x11\x11\x11\x11\x11\x11\x11\x11\x11";
char gszWk[17] = "\x11\x11\x11\x11\x11\x11\x11\x11\x11\x11\x11\x11\x11\x11\x11\x11";

/*****************************************************************
** ��    ��:�������Ź淶���绰֧���ն�MAC�㷨(ECB�����㷨)
** �������:
           iAlog     �㷨��ʶ
           szMacKey  MacKey����
           szMacBuf  ����mac�����ݴ�
           iInLen    ���ݴ�����
** �������:
           szMac     �����MACֵ
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
/*
void
CalcMacTelecom( iAlog, szMacKey, szMacBuf, iInLen, szMac )
int    iAlog;
char    *szMacKey;
char    *szMacBuf;
int    iInLen;
char     *szMac;
{ 
    unsigned char    szMacKeyTmp[17];
    int     i, j;
    char     szTmp[20], szBuf[20];
    char     szMacTemp[10];

    //ASSERT ( iInLen <= 0 );

    memset( szMac, '\0', 8 );
    memset( szMacTemp, '\0', 10 );

    //����szMacKey
    memcpy( szMacKeyTmp, szMacKey, 16 );
    for ( i = 0; i < iInLen; i += 8 ) 
    {
        // right-justified with append 0x00 
        if ( ( iInLen-i ) < 8 ) 
        {
            memset( szTmp, '\0', 8 );
            memcpy( szTmp, szMacBuf+i, iInLen-i );
            for ( j = 0; j < 8; j ++ ) 
            {
                szMacTemp[j] ^= szTmp[j];
            }
        } 
        else 
        {
            for ( j = 0; j < 8; j ++ ) 
            {
                szMacTemp[j] ^= szMacBuf[i+j];
            }
        }
    }

    if( iAlog == MAC_ALOG_CCB ||
        iAlog == MAC_ALOG_TELECOM )
    {
        TriDES( szMacKeyTmp, szMacTemp, szMac );
    }
    else
    {
        DES( szMacKeyTmp, szMacTemp, szMac );
    }

    return;
}
*/
/*****************************************************************
** ��    ��:�����淶�绰֧���ն�MAC�㷨(ECB�����㷨)
** �������:
           iAlog     �㷨��ʶ
           szMacKey  MacKey����
           szMacBuf  ����mac�����ݴ�
           iInLen    ���ݴ�����
** �������:
           szMac     �����MACֵ
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
void
CalcMacUnionpay( iAlog, szMacKey, szMacBuf, iInLen, szMac )
int    iAlog;
char    *szMacKey;
char    *szMacBuf;
int    iInLen;
char     *szMac;
{ 
    unsigned char    szMacKeyTmp[17];
    int     i, j;
    char     szTmp[20], szMacTemp[20];

    //ASSERT ( iInLen <= 0 );

    memset( szMac, '\0', 8 );
    memset( szMacTemp, '\0', 10 );

    //����szMacKeyTmp
    memcpy( szMacKeyTmp, szMacKey, 16 );

    //ÿ8���ֽ��������������8���ֽڣ������0x00
    for ( i = 0; i < iInLen; i += 8 ) 
    {
        //����8�ı��������Ҳ�0x00
        if ( ( iInLen-i ) < 8 ) 
        {
            memset( szTmp, '\0', 8 );
            memcpy( szTmp, szMacBuf+i, iInLen-i );
            for ( j = 0; j < 8; j ++ ) 
            {
                szMacTemp[j] ^= szTmp[j];
            }
        } 
        else 
        {
            for ( j = 0; j < 8; j ++ ) 
            {           
                szMacTemp[j] ^= szMacBuf[i+j];
            }

        }
    }

    //������������8���ֽ�(RESULT BLOCK)ת����16�ֽ�HEXDECIMAL
    BcdToAsc( (unsigned char*)szMacTemp,16,0,(unsigned char*)szTmp );

    //ȡǰ8���ֽ���szMacKeyTmp����
    if( iAlog == TRIPLE_DES )
    {
        TriDES( szMacKeyTmp, szTmp, szMacTemp );
    }
    else
    {
        DES( szMacKeyTmp, szTmp, szMacTemp );
    }

    //���ܺ�Ľ�����8���ֽ����
    for( i=0; i<8; i++ )
    {
        szTmp[i] = szMacTemp[i]^szTmp[i+8];
    }    

    //���Ľ���ٽ���һ�ε�������Կ�㷨����
    DES( szMacKeyTmp, szTmp, szMacTemp );

    //�������ת����16�ֽ�HEXDECIMAL��ǰ8���ֽ���ΪMACֵ
    BcdToAsc( (unsigned char*)szMacTemp ,8,0,(unsigned char*)szMac );

    return;
}

/*****************************************************************
** ��    ��:����mac
** �������:
          tInterface->szData      ��������mac����macbuf
          tInterface->szMacKey    �ն˵�mackey����
          tInterface->iDataLen    macbuf����
** �������:
           tInterface->szData     �����MACֵ
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int SimhsmCalcMacOld( T_Interface *tInterface )
{
    char szMacData[512], szMacKey[17], szEnMacKey[17], szTmpData[20];
    char szMac[20], szTmk[17];
    int iLen;    

    iLen = tInterface->iDataLen;
    memcpy( szMacData, tInterface->szData, iLen );
    memcpy( szEnMacKey, tInterface->szMacKey, 16 );

    /*��ɢ����õ��ն�����Կ*/
    _TriDES( gszMasterKeySim, tInterface->szPsamNo, szTmk );
    _TriDES( gszMasterKeySim, tInterface->szPsamNo+8, szTmk+8 );

    /*�����ն�MacKey*/
#ifdef MKEY_TRIDES
    _TriDES( szTmk, szEnMacKey, szMacKey );
    _TriDES( szTmk, szEnMacKey+8, szMacKey+8 );
#else
    _DES( szTmk, szEnMacKey, szMacKey );
    _DES( szTmk, szEnMacKey+8, szMacKey+8 );
#endif

    CalcMacUnionpay( tInterface->iAlog, szMacKey, szMacData, iLen, szMac );

    tInterface->iDataLen = 8;
    memcpy( tInterface->szData, szMac, 8 );

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
    return SUCC;
}

/*****************************************************************
** ��    ��:�������
** �������:
            szResult      
            iAlog
            cPinBlock
            szKey
            szPasswd       
            szPan         
** �������:
           
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int
DecryptPin( szResult, iAlog, cPinBlock, szKey, szPasswd, szPan )
unsigned char    * szResult, * szKey, * szPasswd, * szPan;
int iAlog;
char cPinBlock;
{
    unsigned char    szAValue[17], szTmpPin[17];
    int    iPinLen, iRet, iPinAlog;

    //δ�������룬����Ҫת����
    if( memcmp( szPasswd, "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF", 8 ) == 0 )
    {
        memset( szResult, 0xFF, 8 );
        return SUCC;
    }

    if( iAlog == SINGLE_DES )
    {
        iPinAlog = SINGLE_DES;
    }
    else
    {
        iPinAlog = TRIPLE_DES;
    }

    if( iPinAlog == SINGLE_DES )
    {
        _DES( szKey, szPasswd, szAValue );
    }
    else
    {
        _TriDES( szKey, szPasswd, szAValue );
    }

    //���ʺŲ���
    iRet = _A_( szTmpPin, szAValue, szPan );
    if( iRet == SUCC )
    {
        iPinLen = strlen((char *)szTmpPin);        
    }

    if( iRet != SUCC )
    {
        return iRet;
    }

    return (SUCC);
}

/*****************************************************************
** ��    ��:ת����
** �������:
           tInterface->szData            �˺�(16byte)+��������(8byte)
           tInterface->szPsamNo
           tInterface->szPinKey
           tInterface->iPinBlock       pin block��֯,int����
           tInterface->iAlog
** �������:
           tInterface->szData            8�ֽ�ת����֮�����������
           tInterface->iDataLen

** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int SimhsmChangePinOld( T_Interface *tInterface )
{
    char szPinKey[17], szEnPinKey[17], szPin[9], szPan[17];
    char szTmk[17], szResult[9];
    int iLen;    

    memcpy( szEnPinKey, tInterface->szPinKey, 16 );
    memcpy( szPan, tInterface->szData, 16 );
    memcpy( szPin, tInterface->szData+16, 8 );

    /*��ɢ����õ��ն�����Կ*/
    _TriDES( gszMasterKeySim, tInterface->szPsamNo, szTmk );
    _TriDES( gszMasterKeySim, tInterface->szPsamNo+8, szTmk+8 );

    /*�����ն�PinKey*/
#ifdef MKEY_TRIDES
    _TriDES( szTmk, szEnPinKey, szPinKey );
    _TriDES( szTmk, szEnPinKey+8, szPinKey+8 );
#else
    _DES( szTmk, szEnPinKey, szPinKey );
    _DES( szTmk, szEnPinKey+8, szPinKey+8 );
#endif

    DecryptPin( szResult, tInterface->iAlog, tInterface->iPinBlock, 
        szPinKey, szPin, szPan );

    tInterface->iDataLen = 8;
    memcpy( tInterface->szData, szResult, 8 );

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
    return SUCC;
}

/*****************************************************************
** ��    ��:ת���ܹ�����Կ
** �������:
           tInterface->szData
              32byte����Կ��Կ+32bytePIK����+32byteMIK����
** �������:
          tInterface->szData
              32bytePIK����+32byteMIK����+32byte����Կ����
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int SimhsmChangeWorkKey( T_Interface *tInterface )
{
    char szKey[33], szPinKey[17], szEnPinKey[17], szMacKey[17], szEnMacKey[17];
    char szEnTmk[33], szTmk[17], szResult[9];
    int iLen;    

    memcpy( szEnTmk, tInterface->szData, 32 );
    /* ����TMK */
    AscToBcd( (uchar *)(tInterface->szData), 32, 0, (uchar *)szKey );
    _TriDES( gszMasterKeySim, szKey, szTmk );
    _TriDES( gszMasterKeySim, szKey+8, szTmk+8 );
/*
debug_disp( "ChangeWorkKey:gszMasterKeySim", gszMasterKeySim, 16 );
debug_disp( "ChangeWorkKey:ENTmk", szKey, 16 );
debug_disp( "ChangeWorkKey:  Tmk", szTmk, 16 );
*/
    /* ��TMK����PIK */
    AscToBcd( (uchar *)(tInterface->szData+32), 32, 0 , (uchar *)szKey);
    _TriDES( szTmk, szKey, szPinKey );
    _TriDES( szTmk, szKey+8, szPinKey+8 );
/*
debug_disp( "ChangeWorkKey:TMK_ENPIK", szKey, 16 );
debug_disp( "ChangeWorkKey:      PIk", szPinKey, 16 );
*/
    /* ��gszMasterKeySim����PIK */
    TriDES( gszMasterKeySim, szPinKey, szEnPinKey);
    TriDES( gszMasterKeySim, szPinKey+8, szEnPinKey+8 );

//debug_disp( "ChangeWorkKey:LMK_ENPIk", szEnPinKey, 16 );

    /* ��TMK����MACK */
    AscToBcd( (uchar *)(tInterface->szData+64), 32, 0 , (uchar *)szKey);
    _TriDES( szTmk, szKey, szMacKey );
    _TriDES( szTmk, szKey+8, szMacKey+8 );
/*
debug_disp( "ChangeWorkKey:TMK_ENMAK", szKey, 16 );
debug_disp( "ChangeWorkKey:      MAk", szMacKey, 16 );
*/
    /* ��gszMasterKeySim����PIK */
    TriDES( gszMasterKeySim, szMacKey, szEnMacKey);
    TriDES( gszMasterKeySim, szMacKey+8, szEnMacKey+8 );
//debug_disp( "ChangeWorkKey:LMK_ENMAk", szEnMacKey, 16 );

    BcdToAsc( szEnPinKey,32,0,(uchar *)(tInterface->szData) );
    BcdToAsc( szEnMacKey ,32,0,(uchar *)(tInterface->szData+32));
    memcpy( tInterface->szData+64, szEnTmk, 32 );
    tInterface->iDataLen = 96;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
    return SUCC;
}
/*****************************************************************
** ��    ��:�ŵ�����
** �������:
           tInterface->szData
              �ŵ�����
           tInterface->szPinKey 
              ���MAGKEY
** �������:
          tInterface->szData
              32bytePIK����+32byteMIK����+32byte����Կ����
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/

int SimhsmDecryptTrack( tInterface )
T_Interface *tInterface;
{ 
    unsigned char    szMagKey[17], szEnMagKey[17], szTrack2[40];
    char    szTrack3[105], szTmk[17];
    int     i, j, iMacAlog, iAlog, iLen, iTrack2Len, iTrack3Len;
    unsigned char     szBuf[200], szStr[400], szInData[256];

    iAlog = tInterface->iAlog;
    iLen = tInterface->iDataLen;
    memcpy( szEnMagKey, tInterface->szPinKey, 16 );
    memcpy( szInData, tInterface->szData, iLen );
    /*����szMagKey*/
    if( iAlog == SINGLE_DES )
    {
        iMacAlog = SINGLE_DES;
    }
    else
    {
        iMacAlog = TRIPLE_DES;
    }
    //add by gaomx 20121015 ������Կ������������Կ����
    memset(szTmk,0,sizeof(szTmk));
    strcpy(szTmk, gszWk);
    //add end
    if( iMacAlog == TRIPLE_DES )
    {
#ifdef MKEY_TRIDES
        _TriDES( szTmk, szEnMagKey, szMagKey );
        _TriDES( szTmk, szEnMagKey+8, szMagKey+8 );
#else
        _DES( szTmk, szEnMagKey, szMagKey );
        _DES( szTmk, szEnMagKey+8, szMagKey+8 );
#endif

        for ( i = 0; i < iLen; i += 8 ) 
        {
            _TriDES( szMagKey, szInData+i, szBuf+i );
        }
    }
    else
    {
#ifdef MKEY_TRIDES
        _TriDES( szTmk, szEnMagKey, szMagKey );
#else
        _DES( szTmk, szEnMagKey, szMagKey );
#endif

        for ( i = 0; i < iLen; i += 8 ) 
        {
            _DES( szMagKey, szInData+i, szBuf+i );
        }
    }
    memset(szStr,0, sizeof(szStr));
    memcpy(szStr, szBuf, iLen);
    memset(szBuf, 0, sizeof(szBuf));
    BcdToAsc( szStr, iLen*2, 0 ,szBuf);
    
    //ȡ��2�ŵ�
    for( i=0; i<iLen*2 && i<37; i++ )
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
    for( j=i; j<iLen*2; j++ )
    {
        if( szBuf[j] != 'F')
            break;
    }

    //ȡ��3�ŵ�
    for( i=j; i<iLen*2; i++ )
    {
        if( szBuf[i] == 'D')
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

/*****************************************************************
** ��    ��:��������ն�����ԿTMK�����������ĺͼ��ֵ���ظ�����
** �������:
            ��
** �������:
           tInterface->szData        TMK(�������32Bytes)+CheckValue(4Bytes) 

** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int SimhsmGetTmk( T_Interface *tInterface )
{
    char    szTMK[17], szTmpStr[100], szTmpBuf[100];

    memcpy( szTMK, gszTmk, 16 );

    TriDES( gszMasterKeySim, szTMK, szTmpStr );
    TriDES( gszMasterKeySim, szTMK+8, szTmpStr+8 );
/*
debug_disp( "SEK", gszMasterKeySim, 16 );
debug_disp( "TMK", szTMK, 16 );
debug_disp( "enTMK", szTmpStr, 16 );
*/
    BcdToAsc((uchar *)szTmpStr,32,0,(uchar *)szTmpBuf);    
    memcpy( tInterface->szData, szTmpBuf, 32 );
    memcpy( tInterface->szData+32, szTmpBuf, 32 );

    memset( szTmpStr, 0, 8 );
    TriDES( szTMK, szTmpStr, szTmpBuf );
    BcdToAsc( (uchar *)szTmpBuf, 16,0, (uchar *)szTmpStr);    
    memcpy( tInterface->szData+64, szTmpStr, 4 );
    tInterface->iDataLen = 68;
    strcpy( tInterface->szReturnCode, TRANS_SUCC );

    return SUCC;
}

/*****************************************************************
** ��    ��:����������ԿPIK/MAK�����������ĺͼ��ֵ���ظ�����
** �������:
           tInterface->szData        �ն�����Կ����(32)
** �������:
           tInterface->szData        PIK(�������32Bytes)+PIK(�´�POS32Bytes)+CheckValue(16Bytes)+
                                   MAK(�������32Bytes)+PIK(�´�POS32Bytes)+CheckValue(168Bytes)+
                                   MAG(�������32Bytes)+PIK(�´�POS32Bytes)+CheckValue(16Bytes)

** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int SimhsmGetWorkKey(T_Interface *tInterface)
{
    char    szTmpStr[100], szTmpBuf[100];
    char    szWorkKey[17], szSekEnKey[17], szSekAscKey[33];
    char    szTmk[17];
    char    szTmkEnKey[17], szTmkAscKey[33], szChkVal[17];
    int     i;

    memcpy( szTmk, gszTmk, 16 );
    memcpy( szWorkKey, gszWk, 16 );
    
    TriDES( gszMasterKeySim, szWorkKey, szSekEnKey );
    TriDES( gszMasterKeySim, szWorkKey+8, szSekEnKey+8 );
    BcdToAsc((uchar *)szSekEnKey ,32,0, (uchar *)szSekAscKey);    

    TriDES( szTmk, szWorkKey, szTmkEnKey );
    TriDES( szTmk, szWorkKey+8, szTmkEnKey+8 );
    BcdToAsc((uchar *)szTmkEnKey,32,0, (uchar *)szTmkAscKey);    

    memset( szTmpStr, 0, 8 );
    TriDES( szWorkKey, szTmpStr, szTmpBuf );
    BcdToAsc((uchar *)szTmpBuf,16,0,(uchar *)szChkVal);
    for( i=0; i<3; i++ )
    {
        memcpy( tInterface->szData+i*80, szTmkAscKey, 32 );
        memcpy( tInterface->szData+i*80+32, szSekAscKey, 32 );
        memcpy( tInterface->szData+i*80+64, szChkVal, 16 );
    }

    tInterface->iDataLen = 240;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��:��ANSI X9.9 MAC�㷨��������MAC�� 
** �������:
           tInterface->szData        ����MAC���������
           tInterface->iDataLen    ���ݳ���
** �������:
           tInterface->szData        MAC(8�ֽ�)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int SimhsmCalcMac(T_Interface *tInterface)
{
    char    szMacData[1024], szMac[9], szEnMacKey[17], szMacKey[17];
       int     iLen;

    memcpy( szEnMacKey, tInterface->szMacKey, 16 );
//debug_disp( "LMK_ENMAK", szEnMacKey, 16 );
    _TriDES( gszMasterKeySim, szEnMacKey, szMacKey );
    _TriDES( gszMasterKeySim, szEnMacKey+8, szMacKey+8 );
//debug_disp( "   MacKey", szMacKey, 16 );

    if( tInterface->iAlog == X99_CALC_MAC )
    {

        memcpy( szMacData, tInterface->szData, tInterface->iDataLen );
        iLen = tInterface->iDataLen;

        ANSIX99( (uchar *)szMacKey, (uchar *)szMacData, iLen, TRIPLE_DES ,(uchar *)szMac);
    }
    else if( tInterface->iAlog == X919_CALC_MAC )
    {

        memcpy( szMacData, tInterface->szData, tInterface->iDataLen );
        iLen = tInterface->iDataLen;

        ANSIX919( (uchar *)szMacKey, (uchar *)szMacData, iLen, (uchar *)szMac );
    }
    else
    {
        XOR( tInterface->szData, tInterface->iDataLen, szMacData );
        iLen = 8;

        ANSIX99( (uchar *)szMacKey, (uchar *)szMacData, iLen, TRIPLE_DES ,(uchar *)szMac );
    }

    memcpy( tInterface->szData, szMac, 8 );

    tInterface->iDataLen = 8;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��:��ԴPIN������ԴPIK���ܣ�����PIN��ʽת����Ȼ����Ŀ��PIK���������
** �������:
           tInterface->szData        �ʺ�(16�ֽ�)+��������(8�ֽ�)
** �������:
           tInterface->szData        ת���ܺ����������(8�ֽ�)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int SimhsmChangePin(T_Interface *tInterface)
{
    char    szOutData[1024], szPwd[9], szPan[17], szTargetPan[17];
    char    szEnPinKey1[17], szPinKey1[17], szEnPinKey2[17], szPinKey2[17];
    int     iLen;

    memcpy( szEnPinKey1, tInterface->szPinKey, 16 );
//debug_disp( "EnPinKey1", szEnPinKey1, 16 );
    _TriDES( gszMasterKeySim, szEnPinKey1, szPinKey1 );
    _TriDES( gszMasterKeySim, szEnPinKey1+8, szPinKey1+8 );
//debug_disp( "PinKey1", szPinKey1, 16 );

    memcpy( szEnPinKey2, tInterface->szMacKey, 16 );
//debug_disp( "LMK_EnPIK2", szEnPinKey2, 16 );
    _TriDES( gszMasterKeySim, szEnPinKey2, szPinKey2 );
    _TriDES( gszMasterKeySim, szEnPinKey2+8, szPinKey2+8 );
//debug_disp( "   PinKey2", szPinKey2, 16 );

    memcpy( szPan, tInterface->szData, 16 );
    memcpy( szPwd, tInterface->szData+16, 8 );
    memcpy( szTargetPan, tInterface->szData+24, 16 );
    memset( szOutData, 0, 8 );
    _ANSIX98( (uchar *)szPinKey1,(uchar *)szPan, (uchar *)szPwd,  TRIPLE_DES,(uchar *)szOutData );

    iLen = strlen(szOutData);

    ANSIX98( (uchar *)szPinKey2,(uchar *)szTargetPan, (uchar *)szPwd, iLen, TRIPLE_DES ,(uchar *)szOutData);

    memcpy( tInterface->szData, szPwd, 8 );
    tInterface->iDataLen = 8;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��:��֤�ն����͵�PIN�Ƿ������ݿ��е�PINһ��
            ��2��:
            1����PIK��PIN���ļ���
            2�����ն����͵����Ľ��бȽ�
** �������:
           tInterface->szData        �ʺ�(16�ֽ�)+��������(8�ֽ�)
** �������:
           tInterface->szData        SUCC-һ��  FAIL-��һ��
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int SimhsmVerifyPin(T_Interface *tInterface)
{
    char    szOutData[1024], szPwd[9], szPan[17];
    char    szPinKey[17];
    int     iLen;

    memcpy( szPinKey, gszWk, 16 );
    memset( szPan, '0', 16 );
    memcpy( szPwd, tInterface->szData, 8 );
    memset( szOutData, 0, 8 );

    iLen = 8;
    ANSIX98( (uchar *)szPinKey,(uchar *)szPan, (uchar *)szPwd, iLen, TRIPLE_DES ,(uchar *)szOutData);

    if( memcmp( tInterface->szData+8, szOutData, 8 ) == 0 )
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
** ��    ��:����PIN
** �������:
           tInterface->szData        �ʺ�(16�ֽ�)+�ն�PIN����(8�ֽ�)
** �������:
           tInterface->szData        ��������
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int SimhsmDecryptPin(T_Interface *tInterface, int iSekPosIndex)
{
    char    szPanBlock[17], szEncPin[17], szTmpStr[100], szPinKey[17];
    int     iLen, iRet;

    memcpy( szPanBlock, tInterface->szData, 16 );

    memcpy( szEncPin, tInterface->szData+16, 8 );

    /* ����PIK */
    _TriDES( gszMasterKeySim, tInterface->szPinKey, szPinKey );
    _TriDES( gszMasterKeySim, tInterface->szPinKey+8, szPinKey+8 );
    
    _ANSIX98( szPinKey,szPanBlock, szEncPin, TRIPLE_DES ,szTmpStr);

    strcpy( tInterface->szData, szTmpStr );
    tInterface->iDataLen = strlen(szTmpStr);

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��:������Կ��У��ֵ
** �������:
           tInterface->szData        ��Կ����(32�ֽ�)
** �������:
           tInterface->szData        У��ֵ(16)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int SimhsmCalcChkval(T_Interface *tInterface)
{
    char    szInData[1024], szOutData[1024];
    char    szKey[17];

    /* ��Կ���� */
    AscToBcd( (uchar *)(tInterface->szData), 32, 0, (uchar *)szKey );
    //modified by gaomx 20120229

    _TriDES( gszMasterKeySim, szKey, szKey );
    _TriDES( gszMasterKeySim, szKey+8, szKey+8 );

    memset( szInData, 0, 8 );
    
    TriDES( szKey, szInData, szOutData );
    BcdToAsc( (uchar *)szOutData, 8,0, (uchar *)(tInterface->szData));
    tInterface->iDataLen = 8;
    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}
