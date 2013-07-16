/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:56�����ܻ��ӿ�(racal�汾)
** �� �� ��:
** ��������:


$Revision: 1.11 $
$Log: Sjl06eRacal.c,v $
Revision 1.11  2012/12/26 01:44:17  wukj
%s/commu_with_hsm/CommuWithHsm/g

Revision 1.10  2012/12/26 01:41:49  wukj
CommuWithHsm����ֵ����С�ڼ��ܻ�����ͷ���½����˳��Ĵ���

Revision 1.9  2012/12/05 06:32:13  wukj
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


extern char gszPospZMKSjl06ERacal[33], gszPoscZMKSjl06ERacal[33];
/*****************************************************************
** ��    ��:���ܻ���������ն�����ԿTMK�����������ĺͼ��ֵ���ظ�����
** �������:
          ��
** �������:
           tInterface->szData   TMK(�������32Bytes)+CheckValue(4Bytes)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:
** ��    ��:
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/

int Sjl06eRacalGetTmk_back( T_Interface *tInterface )
{
    char    szInData[1024], szOutData[1024], szRetCode[3];
    char    szSndData[1024], szRcvData[1024];
       int     iLen, iRet, iSndLen, i;

    iLen = 0;
    /*����*/
    memcpy( szInData, "A0", 2 );    
    iLen += 2;
    /*ģʽ ����ҪZMK����*/
    memcpy( szInData+iLen, "0",  1 );    
    iLen += 1;
    /*��Կ���� TMK*/
    memcpy( szInData+iLen, "002", 3 );    
    iLen += 3;
    /*��Կ����(LMK�¼�����Կ����)��˫������Կ*/
    memcpy( szInData+iLen, "X", 1 ); 
    iLen += 1;
    szInData[iLen] = 0;

    memset( szRcvData, 0, 1024 );
    memset( szOutData, 0, 1024 );
    memcpy( szSndData, SJL06E_RACAL_HEAD_DATA, SJL06E_RACAL_HEAD_LEN );    
    memcpy( szSndData+SJL06E_RACAL_HEAD_LEN, szInData, iLen );    
    iLen += SJL06E_RACAL_HEAD_LEN;
    iRet = CommuWithHsm( szSndData, iLen, szRcvData ); 
    if(iRet == FAIL)
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    else if( iRet - SJL06E_RACAL_HEAD_LEN >= 0)
    {
        memcpy( szOutData, szRcvData+SJL06E_RACAL_HEAD_LEN, iRet-SJL06E_RACAL_HEAD_LEN );
    }
    else
    {
        WriteLog(ERROR,"������ܻ���Ϣͷ���ȣ��Ƿ�>=[%d]" , SJL06E_RACAL_HEAD_LEN );
        return FAIL;
    }
    if( memcmp(szOutData, "A1", 2) != 0  ||
        memcmp(szOutData+2, "00", 2) != 0 )
    {
        DispSjl06eRacalErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%2.2s]", szOutData+2 );
        return SUCC;
    }

    memcpy( tInterface->szData, szOutData+5, 32 );
    memcpy( tInterface->szData+32, szOutData+37, 4 );
    tInterface->iDataLen = 36;
       strcpy( tInterface->szReturnCode, TRANS_SUCC );

    return SUCC;
}

/*****************************************************************
** ��    ��:���ܻ���������ն�����ԿTMK���ֱ���LMK��ZMK���ܣ����������ĺͼ��ֵ���ظ�����
** �������:
          ��
** �������:
           tInterface->szData 
           TMK(LMK���ܴ��������32Bytes)+
           TMK(ZMK���ַܷ����ն�32Bytes)+ 
           CheckValue(4Bytes)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:
** ��    ��:
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl06eRacalGetTmk( T_Interface *tInterface )
{
    char    szInData[1024], szOutData[1024], szRetCode[3];
    char    szSndData[1024], szRcvData[1024];
       int     iLen, iRet, iSndLen, i;

    iLen = 0;
    /*����*/
    memcpy( szInData, "A0", 2 );    
    iLen += 2;
    /*ģʽ ��ҪZMK����*/
    memcpy( szInData+iLen, "1",  1 );    
    iLen += 1;
    /*��Կ���� TMK*/
    memcpy( szInData+iLen, "002", 3 );    
    iLen += 3;
    /*��Կ����(LMK�¼�����Կ����)��˫������Կ*/
    memcpy( szInData+iLen, "X", 1 ); 
    iLen += 1;
    /*ZMK����*/
    memcpy( szInData+iLen, gszPoscZMKSjl06ERacal, 32 ); 
    iLen += 32;
    /*��Կ����(ZMK�¼�����Կ����)��˫������Կ*/
    memcpy( szInData+iLen, "X", 1 ); 
    iLen += 1;
    szInData[iLen] = 0;

    memset( szRcvData, 0, 1024 );
    memset( szOutData, 0, 1024 );
    memcpy( szSndData, SJL06E_RACAL_HEAD_DATA, SJL06E_RACAL_HEAD_LEN );    
    memcpy( szSndData+SJL06E_RACAL_HEAD_LEN, szInData, iLen );    
    iLen += SJL06E_RACAL_HEAD_LEN;
    iRet = CommuWithHsm( szSndData, iLen, szRcvData ); 

    if(iRet == FAIL)
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    else if( iRet - SJL06E_RACAL_HEAD_LEN >= 0)
    {
        memcpy( szOutData, szRcvData+SJL06E_RACAL_HEAD_LEN, iRet-SJL06E_RACAL_HEAD_LEN );
    }
    else
    {
        WriteLog(ERROR,"������ܻ���Ϣͷ���ȣ��Ƿ�>=[%d]" , SJL06E_RACAL_HEAD_LEN );
        return FAIL;
    }

    if( memcmp(szOutData, "A1", 2) != 0  ||
        (memcmp(szOutData+2, "00", 2) != 0 && 
             memcmp(szOutData+2, "10", 2) != 0) )
    {
        DispSjl06eRacalErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%2.2s]", szOutData+2 );
        return SUCC;
    }

    /* LMK��(14-15)�����µ�TMK */
    memcpy( tInterface->szData, szOutData+5, 32 );
    /* ZMK�����µ�TMK */
    memcpy( tInterface->szData+32, szOutData+38, 32 );
    /* ��ԿУ��ֵ */
    memcpy( tInterface->szData+64, szOutData+70, 4 );
    tInterface->iDataLen = 68;
    strcpy( tInterface->szReturnCode, TRANS_SUCC );

    return SUCC;
}

/*****************************************************************
** ��    ��:����������ԿPIK/MAK/MAG�����������ĺͼ��ֵ���ظ�����
** �������:
           tInterface->szData �ն�����Կ����(32Bytes�����������ĵ�)
** �������:
           tInterface->szData 
           PIK(�������32Bytes)+PIK(�´�POS32Bytes)+CheckValue(16Bytes)+
           MAK(�������32Bytes)+PIK(�´�POS32Bytes)+CheckValue(168Bytes)
           MAG(�������32Bytes)+PIK(�´�POS32Bytes)+CheckValue(16Bytes)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:
** ��    ��:
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl06eRacalGetWorkKey(T_Interface *tInterface )
{
    char    szInData[1024], szOutData[1024], szPsamNo[17], szRand[33];
    char    szSndData[1024], szRcvData[1024];
    char    szEnTmk[33];
    int     iLen, iRet, iSndLen, i;
    char    cChr;

    memcpy( szEnTmk, tInterface->szData, 32 );
    
    /*��ȡ���������ԿPIK(TPK)*/
    iLen = 0;
    /*����*/
    memcpy( szInData, "HC", 2 );    
    iLen += 2;
    /*�ն�����Կ���ȱ�ʶ��16λ��*/
    szInData[iLen] = 'X';    
    iLen ++;
    /*�ն�����Կ*/
    memcpy( szInData+iLen, szEnTmk, 32 );    
    iLen += 32;
    /*�ָ��*/
    szInData[iLen] = ';';            
    iLen ++;
    /*TMK�¼�����Կ����*/
    szInData[iLen] = 'X';    
    iLen ++;
    /*LMK�¼�����Կ����*/
    szInData[iLen] = 'X';    
    iLen ++;
    /*��ԿУ��ֵ����*/
    szInData[iLen] = '0';    
    iLen ++;
    szInData[iLen] = 0;

    memset( szRcvData, 0, 1024 );
    memset( szOutData, 0, 1024 );
    memcpy( szSndData, SJL06E_RACAL_HEAD_DATA, SJL06E_RACAL_HEAD_LEN );    
    memcpy( szSndData+SJL06E_RACAL_HEAD_LEN, szInData, iLen );    
    iLen += SJL06E_RACAL_HEAD_LEN;
    iRet = CommuWithHsm( szSndData, iLen, szRcvData ); 

    if(iRet == FAIL)
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    else if( iRet - SJL06E_RACAL_HEAD_LEN >= 0)
    {
        memcpy( szOutData, szRcvData+SJL06E_RACAL_HEAD_LEN, iRet-SJL06E_RACAL_HEAD_LEN );
    }
    else
    {
        WriteLog(ERROR,"������ܻ���Ϣͷ���ȣ��Ƿ�>=[%d]" , SJL06E_RACAL_HEAD_LEN );
        return FAIL;
    }
    memcpy( szOutData, szRcvData+SJL06E_RACAL_HEAD_LEN, iRet-SJL06E_RACAL_HEAD_LEN );

    if( memcmp(szOutData, "HD", 2) != 0  ||
        memcmp(szOutData+2, "00", 2) != 0 )
    {
        DispSjl06eRacalErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%2.2s]", szOutData+2 );
        return SUCC;
    }

    /*LMK��(14-15)���ܵ�PIK�����ر���*/
    memcpy( tInterface->szData, szOutData+38, 32 );
    /*TMK���ܵ�PIK�������ն�*/
    memcpy( tInterface->szData+32, szOutData+5, 32 );
    /*CheckVal*/
    memcpy( tInterface->szData+64, szOutData+70, 16 );

    for( i=1; i<=2; i++ )
    {
        /*��ȡ�ն���֤��ԿMAK(TAK)*/
        iLen = 0;
        /*����*/
        memcpy( szInData, "HA", 2 );    
        iLen += 2;
        /*�ն�����Կ���ȱ�ʶ��16λ��*/
        szInData[iLen] = 'X';    
        iLen ++;
        /*�ն�����Կ*/
        memcpy( szInData+iLen, szEnTmk, 32 );    
        iLen += 32;
        /*�ָ��*/
        szInData[iLen] = ';';            
        iLen ++;
        /*TMK�¼�����Կ����*/
        szInData[iLen] = 'X';    
        iLen ++;
        /*LMK�¼�����Կ����*/
        szInData[iLen] = 'X';    
        iLen ++;
        /*��ԿУ��ֵ����:0-KCV������ 1-KCV6H*/
        szInData[iLen] = '0';    
        iLen ++;
        szInData[iLen] = 0;

        memset( szRcvData, 0, 1024 );
        memset( szOutData, 0, 1024 );
        memcpy( szSndData, SJL06E_RACAL_HEAD_DATA, SJL06E_RACAL_HEAD_LEN );    
        memcpy( szSndData+SJL06E_RACAL_HEAD_LEN, szInData, iLen );    
        iLen += SJL06E_RACAL_HEAD_LEN;
        iRet = CommuWithHsm( szSndData, iLen, szRcvData ); 

        if(iRet == FAIL)
        {
            WriteLog( ERROR, "commu with hsm fail" );
            return FAIL;
        }
        else if( iRet - SJL06E_RACAL_HEAD_LEN >= 0)
        {
            memcpy( szOutData, szRcvData+SJL06E_RACAL_HEAD_LEN, iRet-SJL06E_RACAL_HEAD_LEN );
        }
        else
        {
            WriteLog(ERROR,"������ܻ���Ϣͷ���ȣ��Ƿ�>=[%d]" , SJL06E_RACAL_HEAD_LEN );
            return FAIL;
        }

        memcpy( szOutData, szRcvData+SJL06E_RACAL_HEAD_LEN, iRet-SJL06E_RACAL_HEAD_LEN );

        if( memcmp(szOutData, "HB", 2) != 0  ||
            memcmp(szOutData+2, "00", 2) != 0 )
        {
            DispSjl06eRacalErrorMsg( szOutData+2, tInterface->szReturnCode );
            WriteLog( ERROR, "hsm fail[%2.2s]", szOutData+2 );
            return SUCC;
        }

        /*LMK��(16-17)���ܵ�MAK������������*/
        memcpy( tInterface->szData+80*i, szOutData+38, 32 );

        /*TMK���ܵ�MAK�������ն�*/
        memcpy( tInterface->szData+80*i+32, szOutData+5, 32 );

        /*��ԿУ��ֵ*/
        memcpy( tInterface->szData+80*i+64, szOutData+70, 16 );
    }

    tInterface->iDataLen = 240;

       strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��:MAC���� 
** �������:
           tInterface->szData ����MAC��������ݣ�������tInterface->iDataLenָ��
** �������:
           tInterface->szData MAC(8�ֽ�)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:
** ��    ��:
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl06eRacalCalcMac(T_Interface *tInterface)
{
    char    szInData[1024], szOutData[1024];
    char    szSndData[1024], szRcvData[1024], szTmpStr[20];
       int     iLen, iRet, iSndLen;

    iLen = 0;
    memcpy( szInData, "MS", 2 );    /* ���� */
    iLen += 2;

    /*��Ϣ���:0-��1�� 1-��1�� 2-�м�� 3-β�� */
    memcpy( szInData+iLen, "0", 1 );
    iLen += 1;

    /*��Կ����:0-TAK�ն���֤��Կ 1-ZAK������֤��Կ */
    memcpy( szInData+iLen, "0", 1 );
    iLen += 1;

    /*��Կ����:0-�������� 1-˫������ */
    memcpy( szInData+iLen, "1", 1 );
    iLen += 1;

    /*��Ϣ����:0-������ 1-��չʮ������ */
    memcpy( szInData+iLen, "0", 1 );
    iLen += 1;

    /*MAC��Կ���� */
    memcpy( szInData+iLen, "X", 1 );
    iLen += 1;

    /*MAC��Կ����*/
    BcdToAsc((uchar *)(tInterface->szMacKey), 32, 0 , (uchar *)(szInData+iLen));    
    iLen += 32;

    /* MAC�㷨 1-XOR 2-X9.9 3-X9.19 */
    if( tInterface->iAlog == XOR_CALC_MAC )
    {
        /*��Ϣ����*/
        memcpy( szInData+iLen, "0008", 8 );
        iLen += 4;

        /*��Ϣ��*/
        XOR( tInterface->szData, tInterface->iDataLen, szOutData );
           memcpy( szInData+iLen, szOutData, 8 );
        iLen += 8;
    }
    else
    {
        /*��Ϣ����*/
        szTmpStr[0] = tInterface->iDataLen/256;
        szTmpStr[1] = tInterface->iDataLen%256;
        BcdToAsc( (uchar *)szTmpStr, 4, 0 , (uchar *)(szInData+iLen));
        iLen += 4;

        /*��Ϣ��*/
           memcpy( szInData+iLen, tInterface->szData, tInterface->iDataLen );
        iLen = iLen+tInterface->iDataLen;
    }
    szInData[iLen] = 0;

    memset( szRcvData, 0, 1024 );
    memset( szOutData, 0, 1024 );
    memcpy( szSndData, SJL06E_RACAL_HEAD_DATA, SJL06E_RACAL_HEAD_LEN );    
    memcpy( szSndData+SJL06E_RACAL_HEAD_LEN, szInData, iLen );    
    iLen += SJL06E_RACAL_HEAD_LEN;
    iRet = CommuWithHsm( szSndData, iLen, szRcvData ); 
    if(iRet == FAIL)
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    else if( iRet - SJL06E_RACAL_HEAD_LEN >= 0)
    {
        memcpy( szOutData, szRcvData+SJL06E_RACAL_HEAD_LEN, iRet-SJL06E_RACAL_HEAD_LEN );
    }
    else
    {
        WriteLog(ERROR,"������ܻ���Ϣͷ���ȣ��Ƿ�>=[%d]" , SJL06E_RACAL_HEAD_LEN );
        return FAIL;
    }
    if( memcmp(szOutData, "MT", 2) != 0 ||
        memcmp(szOutData+2, "00", 2) != 0 )
    {
        DispSjl06eRacalErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm calc mac fail[%2.2s]", szOutData+2 );
        return SUCC;
    }

    AscToBcd( (uchar *)(szOutData+4), 16, 0 ,(uchar *)(tInterface->szData));

    tInterface->iDataLen = 8;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��:��ԴPIN������ԴPIK���ܣ�����PIN��ʽת����Ȼ����Ŀ��PIK�������.
** �������:
           tInterface->szData �ʺ�(16�ֽ�)+��������(8�ֽ�)
** �������:
           tInterface->szData ת���ܺ����������(8�ֽ�)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:
** ��    ��:
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl06eRacalChangePin(T_Interface *tInterface)
{
    char    szInData[1024], szOutData[1024], szPanBlock[17];
    char    szSndData[1024], szRcvData[1024];
    int     iLen, iRet, iSndLen;

    sprintf( szPanBlock, "%12.12s", tInterface->szData+3 );
    szPanBlock[12] = 0;

    iLen = 0;
    memcpy( szInData, "CA", 2 );    /* ���� */
    iLen += 2;

    /* ԴPIK��Կ���ȱ�ʶ��16λ�� */
    szInData[iLen] = 'X';    
    iLen ++;

    /* ԴPIK��Կ���� */
    BcdToAsc( (uchar *)(tInterface->szPinKey), 32, 0 , (uchar *)(szInData+iLen));    
    iLen += 32;

    /* Ŀ��PIK��Կ���ȱ�ʶ��16λ�� */
    szInData[iLen] = 'X';    
    iLen ++;

    /* Ŀ��PIK��Կ���� */
    BcdToAsc( (uchar *)(tInterface->szMacKey), 32, 0 , (uchar *)(szInData+iLen));    
    iLen += 32;
    /* ���PIN���� */
    memcpy( szInData+iLen, "12", 2 );    
    iLen += 2;

    /* ԴPinBlock���� */
    BcdToAsc( (uchar *)(tInterface->szData+16), 16, 0 , (uchar *)(szInData+iLen));    
    iLen += 16;

    /* ԴPinBlock��ʽ */
    memcpy( szInData+iLen, "01", 2 );    
    iLen += 2;

    /* Ŀ��PinBlock��ʽ */
    memcpy( szInData+iLen, "01", 2 );    
    iLen += 2;

    /* Դ�ʺ� */
    memcpy( szInData+iLen, szPanBlock, 12 );    
    iLen += 12;
    szInData[iLen] = 0;

    memset( szRcvData, 0, 1024 );
    memset( szOutData, 0, 1024 );
    memcpy( szSndData, SJL06E_RACAL_HEAD_DATA, SJL06E_RACAL_HEAD_LEN );    
    memcpy( szSndData+SJL06E_RACAL_HEAD_LEN, szInData, iLen );    
    iLen += SJL06E_RACAL_HEAD_LEN;
    iRet = CommuWithHsm( szSndData, iLen, szRcvData ); 
    if(iRet == FAIL)
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    else if( iRet - SJL06E_RACAL_HEAD_LEN >= 0)
    {
        memcpy( szOutData, szRcvData+SJL06E_RACAL_HEAD_LEN, iRet-SJL06E_RACAL_HEAD_LEN );
    }
    else
    {
        WriteLog(ERROR,"������ܻ���Ϣͷ���ȣ��Ƿ�>=[%d]" , SJL06E_RACAL_HEAD_LEN );
        return FAIL;
    }

    if( memcmp(szOutData, "CB", 2) != 0 ||
        memcmp(szOutData+2, "00", 2) != 0 )
    {
        DispSjl06eRacalErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm pin change fail[%2.2s]", szOutData+2 );
        return SUCC;
    }

    AscToBcd( (uchar *)(szOutData+6), 16, 0 ,(uchar *)(tInterface->szData));
    tInterface->iDataLen = 8;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��:��PIN������ԴPIK���ܣ�����PIN��ʽת����Ȼ����LMK��(02-03)�������.
** �������:
           tInterface->szData �ʺ�(16�ֽ�)+��������(8�ֽ�)
** �������:
           tInterface->szData ת���ܺ����������(8�ֽ�)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:
** ��    ��:
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl06eRacalChangePin_TPK2LMK(T_Interface *tInterface)
{
    char    szInData[1024], szOutData[1024], szPanBlock[17];
    char    szSndData[1024], szRcvData[1024];
    int     iLen, iRet, iSndLen;

    sprintf( szPanBlock, "%12.12s", tInterface->szData+3 );
    szPanBlock[12] = 0;

    iLen = 0;
    memcpy( szInData, "JC", 2 );    /* ���� */
    iLen += 2;

    /* ԴPIK��Կ���ȱ�ʶ��16λ�� */
    szInData[iLen] = 'X';    
    iLen ++;

    /* ԴPIK��Կ���� */
    BcdToAsc( (uchar *)(tInterface->szPinKey), 32, 0 , (uchar *)(szInData+iLen));
    iLen += 32;

    /* PinBlock���� */
    BcdToAsc( (uchar *)(tInterface->szData+16), 16, 0 , (uchar *)(szInData+iLen));
    iLen += 16;

    /* PinBlock��ʽ */
    memcpy( szInData+iLen, "01", 2 );    
    iLen += 2;

    /* �ʺ� */
    memcpy( szInData+iLen, szPanBlock, 12 );    
    iLen += 12;
    szInData[iLen] = 0;

//WriteLog( TRACE, "ChgPinSnd[%s]", szInData );

    memset( szRcvData, 0, 1024 );
    memset( szOutData, 0, 1024 );
    memcpy( szSndData, SJL06E_RACAL_HEAD_DATA, SJL06E_RACAL_HEAD_LEN );    
    memcpy( szSndData+SJL06E_RACAL_HEAD_LEN, szInData, iLen );    
    iLen += SJL06E_RACAL_HEAD_LEN;
    iRet = CommuWithHsm( szSndData, iLen, szRcvData ); 
    if(iRet == FAIL)
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    else if( iRet - SJL06E_RACAL_HEAD_LEN >= 0)
    {
        memcpy( szOutData, szRcvData+SJL06E_RACAL_HEAD_LEN, iRet-SJL06E_RACAL_HEAD_LEN );
    }
    else
    {
        WriteLog(ERROR,"������ܻ���Ϣͷ���ȣ��Ƿ�>=[%d]" , SJL06E_RACAL_HEAD_LEN );
        return FAIL;
    }

    if( memcmp(szOutData, "JD", 2) != 0 ||
        memcmp(szOutData+2, "00", 2) != 0 )
    {
        DispSjl06eRacalErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm pin change fail[%2.2s]", szOutData+2 );
        return SUCC;
    }
/*
WriteLog( TRACE, "ChgPinRcv[%s]", szOutData );
*/
    tInterface->iDataLen = strlen(szOutData)-4;
    memcpy( tInterface->szData, szOutData+4, tInterface->iDataLen );
    tInterface->szData[tInterface->iDataLen] = 0;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��: ����PIN
** �������:
           tInterface->szData �ʺ�(16�ֽ�)+�ն�PIN����(8�ֽڣ�LMK��(02-03)����)
** �������:
           tInterface->szData ��������
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:
** ��    ��:
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl06eRacalDecryptPin(T_Interface *tInterface)
{
    char    szInData[1024], szOutData[1024], szPanBlock[17];
    char    szSndData[1024], szRcvData[1024], szLmkEnPin[9];
    int     iLen, iRet, iSndLen;

    sprintf( szPanBlock, "%12.12s", tInterface->szData+3 );
    szPanBlock[12] = 0;

    iRet = Sjl06eRacalChangePin_TPK2LMK( tInterface );
    if( iRet != SUCC || strcmp(tInterface->szReturnCode, TRANS_SUCC) != 0 )
    {
        WriteLog( ERROR, "change pin fail" );
        return SUCC;
    }
    strcpy( szLmkEnPin, tInterface->szData );    

    iLen = 0;
    memcpy( szInData, "NG", 2 );    /* ���� */
    iLen += 2;

    /* �ʺ� */
    memcpy( szInData+iLen, szPanBlock, 12 );    
    iLen += 12;

    /* PinBlock���� LMK��(02-03)���� */
    memcpy( szInData+iLen, tInterface->szData, tInterface->iDataLen );
    iLen += tInterface->iDataLen;

    szInData[iLen] = 0;

//WriteLog( TRACE, "DecPinSnd[%s]", szInData );

    memset( szRcvData, 0, 1024 );
    memset( szOutData, 0, 1024 );
    memcpy( szSndData, SJL06E_RACAL_HEAD_DATA, SJL06E_RACAL_HEAD_LEN );    
    memcpy( szSndData+SJL06E_RACAL_HEAD_LEN, szInData, iLen );    
    iLen += SJL06E_RACAL_HEAD_LEN;
    iRet = CommuWithHsm( szSndData, iLen, szRcvData ); 
    if(iRet == FAIL)
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    else if( iRet - SJL06E_RACAL_HEAD_LEN >= 0)
    {
        memcpy( szOutData, szRcvData+SJL06E_RACAL_HEAD_LEN, iRet-SJL06E_RACAL_HEAD_LEN );
    }
    else
    {
        WriteLog(ERROR,"������ܻ���Ϣͷ���ȣ��Ƿ�>=[%d]" , SJL06E_RACAL_HEAD_LEN );
        return FAIL;
    }

//WriteLog( TRACE, "DecPinRcv[%s]", szOutData );

    if( memcmp(szOutData, "NH", 2) != 0 ||
        memcmp(szOutData+2, "00", 2) != 0 )
    {
        DispSjl06eRacalErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm pin change fail[%2.2s]", szOutData+2 );
        return SUCC;
    }

    memcpy( tInterface->szData, szOutData+4, 8 );
    tInterface->szData[8] = 0;
    tInterface->iDataLen = 8;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;
}

/*****************************************************************
** ��    ��: ��֤�ն����͵�PIN�Ƿ������ݿ��е�PINһ��
             ��3��:
             1����LMK��PIN���ļ��ܣ���szLmkEncPin1
             2�����ն�PIN���Ĵ�TPK���뵽LMK����szLmkEncPin2
             3���Ƚ�szLmkEncPin1 szLmkEncPin2
** �������:
           tInterface->szData ���ݿ�����������(8�ֽ�)+�ն�PIN����(8�ֽ�)
** �������:
           tInterface->szData SUCC-һ��  FAIL-��һ��
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:
** ��    ��:
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl06eRacalVerifyPin(T_Interface *tInterface)
{
    char    szInData[1024], szOutData[1024], szPanBlock[17], szLmkEncPin1[17], szLmkEncPin2[17];
    char    szSndData[1024], szRcvData[1024];
    int     iLen, iRet, iSndLen;

    memset( szPanBlock, '0', 16 );
    szPanBlock[16] = 0;

    /*========��LMK��PIN���ļ���   ��ʼ==============*/
    iLen = 0;
    memcpy( szInData, "BA", 2 );    /* ���� */
    iLen += 2;

    /* PIN���� */
    memcpy( szInData+iLen, tInterface->szData, 8 );
    iLen += 8;
    memcpy( szInData+iLen, "FFFF", 4 );
    iLen += 4;

    /* �ʺ� */
    memcpy( szInData+iLen, szPanBlock, 12 );    
    iLen += 12;
    szInData[iLen] = 0;

    memset( szRcvData, 0, 1024 );
    memset( szOutData, 0, 1024 );
    memcpy( szSndData, SJL06E_RACAL_HEAD_DATA, SJL06E_RACAL_HEAD_LEN );    
    memcpy( szSndData+SJL06E_RACAL_HEAD_LEN, szInData, iLen );    
    iLen += SJL06E_RACAL_HEAD_LEN;
    iRet = CommuWithHsm( szSndData, iLen, szRcvData ); 
    if(iRet == FAIL)
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    else if( iRet - SJL06E_RACAL_HEAD_LEN >= 0)
    {
        memcpy( szOutData, szRcvData+SJL06E_RACAL_HEAD_LEN, iRet-SJL06E_RACAL_HEAD_LEN );
    }
    else
    {
        WriteLog(ERROR,"������ܻ���Ϣͷ���ȣ��Ƿ�>=[%d]" , SJL06E_RACAL_HEAD_LEN );
        return FAIL;
    }

    if( memcmp(szOutData, "BB", 2) != 0 ||
        memcmp(szOutData+2, "00", 2) != 0 )
    {
        DispSjl06eRacalErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm encrypt pin fail[%2.2s]", szOutData+2 );
        return SUCC;
    }
    memcpy( szLmkEncPin1, szOutData+4, 16 );
    /*========��LMK��PIN���ļ���   ����=============*/

    /*========���ն�PIN���Ĵ�TPK���뵽LMK  ��ʼ=============*/
    iLen = 0;
    memcpy( szInData, "JC", 2 );    /* ���� */
    iLen += 2;

    /* PIK��Կ���ȱ�ʶ��16λ�� */
    szInData[iLen] = 'X';    
    iLen ++;

    /* PIK��Կ���� */
    BcdToAsc( (uchar *)(tInterface->szPinKey), 32, 0, (uchar *)(szInData+iLen) );
    iLen += 32;

    /* �ն�PIN���� */
    BcdToAsc(  (uchar *)(tInterface->szData+8), 16, 0 , (uchar *)(szInData+iLen));
    iLen += 16;

    /* PIN���ʽ���� */
    memcpy( szInData+iLen, "01", 2 );
    iLen += 2;

    /* �ʺ� */
    memcpy( szInData+iLen, szPanBlock, 12 );    
    iLen += 12;
    szInData[iLen] = 0;

    memset( szRcvData, 0, 1024 );
    memset( szOutData, 0, 1024 );
    memcpy( szSndData, SJL06E_RACAL_HEAD_DATA, SJL06E_RACAL_HEAD_LEN );    
    memcpy( szSndData+SJL06E_RACAL_HEAD_LEN, szInData, iLen );    
    iLen += SJL06E_RACAL_HEAD_LEN;
    iRet = CommuWithHsm( szSndData, iLen, szRcvData ); 
    if(iRet == FAIL)
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    else if( iRet - SJL06E_RACAL_HEAD_LEN >= 0)
    {
        memcpy( szOutData, szRcvData+SJL06E_RACAL_HEAD_LEN, iRet-SJL06E_RACAL_HEAD_LEN );
    }
    else
    {
        WriteLog(ERROR,"������ܻ���Ϣͷ���ȣ��Ƿ�>=[%d]" , SJL06E_RACAL_HEAD_LEN );
        return FAIL;
    }

    if( memcmp(szOutData, "JD", 2) != 0 ||
        memcmp(szOutData+2, "00", 2) != 0 )
    {
        DispSjl06eRacalErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm encrypt pin fail[%2.2s]", szOutData+2 );
        return SUCC;
    }
    memcpy( szLmkEncPin2, szOutData+4, 16 );
    /*========��PIN��TPK���뵽LMK  ����=============*/

    if( memcmp( szLmkEncPin1, szLmkEncPin2, 16 ) == 0 )
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
** ��    ��:������Կ��У��ֵ
** �������:
           tInterface->szData ��Կ����(32�ֽ�)
** �������:
           tInterface->szData У��ֵ(16)
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:
** ��    ��:
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl06eRacalCalcChkval(T_Interface *tInterface)
{
    char    szInData[1024], szOutData[1024], szPanBlock[17];
    char    szSndData[1024], szRcvData[1024];
    int     iLen, iRet, iSndLen;
    memset(szInData,0x00,sizeof(szInData));
    iLen = 0;
    memcpy( szInData, "BU", 2 );    /* ���� */
    iLen += 2;

    /* ������Կ���ʹ��� */
    sprintf(szInData+iLen,"%02d",tInterface->iAlog);   //alog�ɵ��ú�������,��ֵ����LMK�Դ���
    iLen += 2;

    /* ��Կ���ȱ�ʶ��16λ�� */
    szInData[iLen] = '1';    
    iLen ++;

    /* ��Կ���ȱ�ʶ��16λ�� */
    szInData[iLen] = 'X';    
    iLen ++;

    /* ��Կ���� */
    memcpy( szInData+iLen, tInterface->szData, 32 );
    iLen += 32;
    
    szInData[iLen] = 0;

    memset( szRcvData, 0, 1024 );
    memset( szOutData, 0, 1024 );
    memcpy( szSndData, SJL06E_RACAL_HEAD_DATA, SJL06E_RACAL_HEAD_LEN );    
    memcpy( szSndData+SJL06E_RACAL_HEAD_LEN, szInData, iLen );    
    iLen += SJL06E_RACAL_HEAD_LEN;
    iRet = CommuWithHsm( szSndData, iLen, szRcvData ); 
    if(iRet == FAIL)
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    else if( iRet - SJL06E_RACAL_HEAD_LEN >= 0)
    {
        memcpy( szOutData, szRcvData+SJL06E_RACAL_HEAD_LEN, iRet-SJL06E_RACAL_HEAD_LEN );
    }
    else
    {
        WriteLog(ERROR,"������ܻ���Ϣͷ���ȣ��Ƿ�>=[%d]" , SJL06E_RACAL_HEAD_LEN );
        return FAIL;
    }

    if(memcmp(szOutData+2, "00", 2) != 0 )
    {
        DispSjl06eRacalErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm encrypt pin fail[%2.2s]", szOutData+2 );
        return SUCC;
    }

    memcpy( tInterface->szData, szOutData+4, 8 );
    tInterface->iDataLen = 8;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );
   
    return SUCC;

}

/*****************************************************************
** ��    ��:���ܻ�ת���ܹ�����Կ��������TMK���ܵ�PIK��ԭ�����ģ�Ȼ������LMK��(06-07)����
            �����ͬʱ����TMK���ܵ�MAK��ԭ�����ģ�Ȼ������LMK��(16-17)�������.Ϊ����Ҫ
                  �����²������:
                  1����TMK��ZMK(ͨѶ˫��Լ��)��ԭ�����ģ�Ȼ����LMK��(04-05)�����������TMK
                     ת����ZMK��
                  2����PIK��ZMK(TMKת������)��ԭ�����ģ�Ȼ������LMK��(06-07)�������.
                  3����MAK��ZMK(TMKת������)��ԭ�����ģ�Ȼ������LMK��(16-17)�������.
                  4����TMK��ZMK(ͨѶ˫��Լ��)��ԭ�����ģ�Ȼ����LMK��(16-17)�������.
** �������:
           tInterface->szData TMK����(32Bytes)+PIK����(32Bytes)+MAK����(32Bytes), ������Կ��TMK����
** �������:
           tInterface->szData PIK����(32Bytes)+MAK����(32Bytes)+TMK����(32Bytes),������Կ�ֱ���LMK��(06-07)��LMK��(16-17)��LMK��(16-17)����
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:
** ��    ��:
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int Sjl06eRacalChangeWorkkey( T_Interface *tInterface )
{
    char    szInData[1024], szOutData[1024], szRetCode[3];
    char    szSndData[1024], szRcvData[1024];
    char    szTmkZmk[33], szEnTmk[33];
    int     iLen, iRet, iSndLen;

    /*============����1:TMKת����ZMK================*/
    iLen = 0;
    /*����*/
    memcpy( szInData, "A6", 2 );    
    iLen += 2;
    /*�����Կ����:ZMK */
    memcpy( szInData+iLen, "000", 3 );    
    iLen += 3;
    /*ZMK��Կ����*/
    memcpy( szInData+iLen, "X", 1 ); 
    iLen += 1;
    /*ZMK����*/
    memcpy( szInData+iLen, gszPospZMKSjl06ERacal, 32 );    
    iLen += 32;
    /*TMK��Կ����*/
    memcpy( szInData+iLen, "X", 1 ); 
    iLen += 1;
    /*TMK����*/
    memcpy( szInData+iLen, tInterface->szData, 32 );    
    iLen += 32;
    memcpy( szEnTmk, tInterface->szData, 32 );
    /*��Կ����(LMK�¼�����Կ����)��˫������Կ*/
    memcpy( szInData+iLen, "X", 1 ); 
    iLen += 1;
    szInData[iLen] = 0;

    memset( szRcvData, 0, 1024 );
    memset( szOutData, 0, 1024 );
    memcpy( szSndData, SJL06E_RACAL_HEAD_DATA, SJL06E_RACAL_HEAD_LEN );    
    memcpy( szSndData+SJL06E_RACAL_HEAD_LEN, szInData, iLen );    
    iLen += SJL06E_RACAL_HEAD_LEN;
    iRet = CommuWithHsm( szSndData, iLen, szRcvData ); 
    if(iRet == FAIL)
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    else if( iRet - SJL06E_RACAL_HEAD_LEN >= 0)
    {
        memcpy( szOutData, szRcvData+SJL06E_RACAL_HEAD_LEN, iRet-SJL06E_RACAL_HEAD_LEN );
    }
    else
    {
        WriteLog(ERROR,"������ܻ���Ϣͷ���ȣ��Ƿ�>=[%d]" , SJL06E_RACAL_HEAD_LEN );
        return FAIL;
    }

    if( memcmp(szOutData, "A7", 2) != 0  ||
        memcmp(szOutData+2, "00", 2) != 0 )
    {
        DispSjl06eRacalErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%2.2s]", szOutData+2 );
        return SUCC;
    }

    memcpy( szTmkZmk, szOutData+5, 32 );

    /*============����2:PIK��TMK����ת������LMK��(06-07)����=========*/
    iLen = 0;
    /*����*/
    memcpy( szInData, "A6", 2 );    
    iLen += 2;
    /*�����Կ����:ZPK */
    memcpy( szInData+iLen, "001", 3 );    
    iLen += 3;
    /*ZMK��Կ����*/
    memcpy( szInData+iLen, "X", 1 ); 
    iLen += 1;
    /*ZMK����(TMKת������)*/
    memcpy( szInData+iLen, szTmkZmk, 32 );    
    iLen += 32;
    /*PIK��Կ����*/
    memcpy( szInData+iLen, "X", 1 ); 
    iLen += 1;
    /*PIK����*/
    memcpy( szInData+iLen, tInterface->szData+32, 32 );    
    iLen += 32;
    /*��Կ����(LMK�¼�����Կ����)��˫������Կ*/
    memcpy( szInData+iLen, "X", 1 ); 
    iLen += 1;
    szInData[iLen] = 0;

    memset( szRcvData, 0, 1024 );
    memset( szOutData, 0, 1024 );
    memcpy( szSndData, SJL06E_RACAL_HEAD_DATA, SJL06E_RACAL_HEAD_LEN );    
    memcpy( szSndData+SJL06E_RACAL_HEAD_LEN, szInData, iLen );    
    iLen += SJL06E_RACAL_HEAD_LEN;
    iRet = CommuWithHsm( szSndData, iLen, szRcvData ); 
    if(iRet == FAIL)
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    else if( iRet - SJL06E_RACAL_HEAD_LEN >= 0)
    {
        memcpy( szOutData, szRcvData+SJL06E_RACAL_HEAD_LEN, iRet-SJL06E_RACAL_HEAD_LEN );
    }
    else
    {
        WriteLog(ERROR,"������ܻ���Ϣͷ���ȣ��Ƿ�>=[%d]" , SJL06E_RACAL_HEAD_LEN );
        return FAIL;
    }

    if( memcmp(szOutData, "A7", 2) != 0  ||
        memcmp(szOutData+2, "00", 2) != 0 )
    {
        DispSjl06eRacalErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%2.2s]", szOutData+2 );
        return SUCC;
    }
    memcpy( tInterface->szData, szOutData+5, 32 );

    /*============����3:MAK��TMK����ת������LMK��(16-17)����=========*/
    iLen = 0;
    /*����*/
    memcpy( szInData, "A6", 2 );    
    iLen += 2;
    /*�����Կ����:TAK */
    memcpy( szInData+iLen, "003", 3 );    
    iLen += 3;
    /*ZMK��Կ����*/
    memcpy( szInData+iLen, "X", 1 ); 
    iLen += 1;
    /*ZMK����(TMKת������)*/
    memcpy( szInData+iLen, szTmkZmk, 32 );    
    iLen += 32;
    /*MAK��Կ����*/
    memcpy( szInData+iLen, "X", 1 ); 
    iLen += 1;
    /*MAK����*/
    memcpy( szInData+iLen, tInterface->szData+64, 32 );    
    iLen += 32;
    /*��Կ����(LMK�¼�����Կ����)��˫������Կ*/
    memcpy( szInData+iLen, "X", 1 ); 
    iLen += 1;
    szInData[iLen] = 0;

    memset( szRcvData, 0, 1024 );
    memset( szOutData, 0, 1024 );
    memcpy( szSndData, SJL06E_RACAL_HEAD_DATA, SJL06E_RACAL_HEAD_LEN );    
    memcpy( szSndData+SJL06E_RACAL_HEAD_LEN, szInData, iLen );    
    iLen += SJL06E_RACAL_HEAD_LEN;
    iRet = CommuWithHsm( szSndData, iLen, szRcvData ); 
    if(iRet == FAIL)
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    else if( iRet - SJL06E_RACAL_HEAD_LEN >= 0)
    {
        memcpy( szOutData, szRcvData+SJL06E_RACAL_HEAD_LEN, iRet-SJL06E_RACAL_HEAD_LEN );
    }
    else
    {
        WriteLog(ERROR,"������ܻ���Ϣͷ���ȣ��Ƿ�>=[%d]" , SJL06E_RACAL_HEAD_LEN );
        return FAIL;
    }

    if( memcmp(szOutData, "A7", 2) != 0  ||
        memcmp(szOutData+2, "00", 2) != 0 )
    {
        DispSjl06eRacalErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%2.2s]", szOutData+2 );
        return SUCC;
    }

    memcpy( tInterface->szData+32, szOutData+5, 32 );

    /*============����4:TMKת������LMK��(16-17)����================*/
    iLen = 0;
    /*����*/
    memcpy( szInData, "A6", 2 );    
    iLen += 2;
    /*�����Կ����:TAK */
    memcpy( szInData+iLen, "003", 3 );    
    iLen += 3;
    /*ZMK��Կ����*/
    memcpy( szInData+iLen, "X", 1 ); 
    iLen += 1;
    /*ZMK����*/
    memcpy( szInData+iLen, gszPospZMKSjl06ERacal, 32 );    
    iLen += 32;
    /*TMK��Կ����*/
    memcpy( szInData+iLen, "X", 1 ); 
    iLen += 1;
    /*TMK����*/
    memcpy( szInData+iLen, szEnTmk, 32 );    
    iLen += 32;
    /*��Կ����(LMK�¼�����Կ����)��˫������Կ*/
    memcpy( szInData+iLen, "X", 1 ); 
    iLen += 1;
    szInData[iLen] = 0;

    memset( szRcvData, 0, 1024 );
    memset( szOutData, 0, 1024 );
    memcpy( szSndData, SJL06E_RACAL_HEAD_DATA, SJL06E_RACAL_HEAD_LEN );    
    memcpy( szSndData+SJL06E_RACAL_HEAD_LEN, szInData, iLen );    
    iLen += SJL06E_RACAL_HEAD_LEN;
    iRet = CommuWithHsm( szSndData, iLen, szRcvData ); 
    if(iRet == FAIL)
    {
        WriteLog( ERROR, "commu with hsm fail" );
        return FAIL;
    }
    else if( iRet - SJL06E_RACAL_HEAD_LEN >= 0)
    {
        memcpy( szOutData, szRcvData+SJL06E_RACAL_HEAD_LEN, iRet-SJL06E_RACAL_HEAD_LEN );
    }
    else
    {
        WriteLog(ERROR,"������ܻ���Ϣͷ���ȣ��Ƿ�>=[%d]" , SJL06E_RACAL_HEAD_LEN );
        return FAIL;
    }

    if( memcmp(szOutData, "A7", 2) != 0  ||
        memcmp(szOutData+2, "00", 2) != 0 )
    {
        DispSjl06eRacalErrorMsg( szOutData+2, tInterface->szReturnCode );
        WriteLog( ERROR, "hsm fail[%2.2s]", szOutData+2 );
        return SUCC;
    }

    memcpy( tInterface->szData+64, szOutData+5, 32 );
    tInterface->szData[96] = 0;
    tInterface->iDataLen = 96;

    strcpy( tInterface->szReturnCode, TRANS_SUCC );

    return SUCC;
}
