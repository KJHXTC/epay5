/*******************************************************************************
 * Copyright(C)2012��2015 �������������豸���޹�˾
 * ��Ҫ���ݣ���ӡ��غ���
 * �� �� �ˣ�Robin
 * �������ڣ�2012/12/11
 *
 * $Revision: 1.6 $
 * $Log: Print.ec,v $
 * Revision 1.6  2013/02/21 06:50:25  fengw
 *
 * 1���޸Ĵ�ӡ���׽������ѽ�����ݸ�ʽ��
 *
 * Revision 1.5  2013/01/18 08:32:37  fengw
 *
 * 1����ֺ�����
 *
 * Revision 1.4  2012/12/25 08:24:32  wukj
 * �����ն˱����汾�жϴ�ӡ��������
 *
 * Revision 1.3  2012/12/21 06:53:07  wukj
 * ����ע��
 *
 * Revision 1.2  2012/12/21 03:57:11  chenrb
 * ɾ��ChangeAmount�����ÿ⺯���е�ChgAmtZeorToDot���Ҳ����ݵͰ汾
 *
 * Revision 1.1  2012/12/21 02:58:00  wukj
 * �޸��ļ���
 *
 * Revision 1.6  2012/12/18 09:14:02  wukj
 * *** empty log message ***
 *
 * Revision 1.5  2012/12/12 07:43:54  wukj
 * *** empty log message ***
 *
 * Revision 1.4  2012/12/12 07:17:56  wukj
 * *** empty log message ***
 *
 * Revision 1.3  2012/12/12 07:10:39  wukj
 * *** empty log message ***
 *
 * Revision 1.2  2012/12/12 07:10:04  wukj
 * �淶����д
 *
 * Revision 1.1  2012/12/12 02:22:02  chenrb
 * ��ʼ�汾
 *
 ******************************************************************************/

#define _EXTERN_

#include "ScriptPos.h"

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL EnD DECLARE SECTION;
#endif

/*****************************************************************
** ��    ��:��ʽ������
** �������:
           iDispMode �Ƿ����ο��ţ�YES-����  NO-������ 
           szPan 
** �������:
           szOutData ��ʽ��֮��Ŀ���
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
void ChangePan( int iDispMode, char *szPan, char *szOutData )
{
    char    szTmpStr[100], szNewPan[20];
    int    iLen, i;

    memset( szTmpStr, 0, 100 );
    if( iDispMode == YES )
    {
        strcpy( szNewPan, szPan );
        iLen = strlen(szPan)-10;
        for( i=0; i<iLen; i++ )
        {
            szNewPan[6+i] = '*';    
        }
        sprintf( szTmpStr, "%4.4s %4.4s %4.4s %s", szNewPan, szNewPan+4, 
            szNewPan+8, szNewPan+12 );
    }
    else
    {
        sprintf( szTmpStr, "%4.4s %4.4s %4.4s %s", szPan, szPan+4, 
            szPan+8, szPan+12 );
    }
    
    strcpy( szOutData, szTmpStr );

    return;
}

/*****************************************************************
** ��    ��: �û��Զ����ӡ���� 
** �������:
            ptAppStru 
** �������:
            szPrintData  ��ӡ����
            iPrintNum    ��ӡ���ݸ���
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
int UserGetPrintData( ptAppStru, szPrintData, iPrintNum )
T_App    *ptAppStru;
unsigned char    *szPrintData;
int *iPrintNum;
{
    int iPrintLen, iNum, iCurPos, i, iLastLen;
    char szTmpStr[100], szData[1024];

    iPrintLen = 0;
    iCurPos = 0;
    iNum = 2;    //��ӡ����
    /*��ӡ���Ʒ���(3 bytes):%Bn��ʾ��n�ݱ��⣬��1�о���
                  %FFΪ����
                  %En��ʾ��n�������1�о���
      ģ���¼��(1 bytes)
      ��ӡ��Ϣ:��ӡ��Ϣ��Ϊ"FFFF" ����ʾʹ�ò˵���ʾ�����滻
    */
    /*���� & ���*/
    for( i=1; i<=iNum; i++ )
    {
        /* ���� */
        memcpy( szData+iCurPos, "%B", 2 );    //���Ʒ�
        iCurPos += 2;
        szData[iCurPos] = i+'0';
        iCurPos ++;
        szData[iCurPos] = PRINT_TITLE1;        //����ģ���¼��
        iCurPos ++;
        szData[iCurPos] = 0x00;            //��¼����
        iCurPos ++;

        /* ��� */
        memcpy( szData+iCurPos, "%E", 2 );    //���Ʒ�
        iCurPos += 2;
        szData[iCurPos] = i+'0';
        iCurPos ++;
        if( i == 1 )
        {
            szData[iCurPos] = PRINT_SHOP_SLIP;    //���ģ���¼��
        }
        else
        {
            szData[iCurPos] = PRINT_HOLDER_SLIP;    //���ģ���¼��
        }
        iCurPos ++;
        szData[iCurPos] = 0x00;            //��¼����
        iCurPos ++;
    }

    //�̻���
    memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
    iCurPos += 3;
    szData[iCurPos] = PRINT_SHOP_NO;    //��ӡ��Ϣ��¼��
    iCurPos ++;
    memcpy( szData+iCurPos, ptAppStru->szShopNo, strlen(ptAppStru->szShopNo) );    //��ӡ��Ϣ
    iCurPos += strlen(ptAppStru->szShopNo);
    szData[iCurPos] = 0x00;            //��¼����
    iCurPos ++;

    //�̻�����
    memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
    iCurPos += 3;
    szData[iCurPos] = PRINT_SHOP_NAME;    //��ӡ��Ϣ��¼��
    iCurPos ++;
    memcpy( szData+iCurPos, ptAppStru->szShopName, 
            strlen( ptAppStru->szShopName) );//��ӡ��Ϣ
    iCurPos += strlen(ptAppStru->szShopName);
    szData[iCurPos] = 0x00;            //��¼����
    iCurPos ++;

    //�ն˺�
    memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
    iCurPos += 3;
    szData[iCurPos] = PRINT_TERM_NO;    //��ӡ��Ϣ��¼��
    iCurPos ++;
    memcpy( szData+iCurPos, ptAppStru->szPosNo, strlen(ptAppStru->szPosNo) );    //��ӡ��Ϣ
    iCurPos += strlen(ptAppStru->szPosNo);
    szData[iCurPos] = 0x00;            //��¼����
    iCurPos ++;
    
    //��������
    memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
    iCurPos += 3;
    szData[iCurPos] = PRINT_TRANS_TYPE;    //��ӡ��Ϣ��¼��
    iCurPos ++;
    memcpy( szData+iCurPos, ptAppStru->szTransName, 
        strlen(ptAppStru->szTransName) );    //��ӡ��Ϣ��ȡ�˵�����
    iCurPos += strlen(ptAppStru->szTransName);
    szData[iCurPos] = 0x00;            //��¼����
    iCurPos ++;

    //����
    memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
    iCurPos += 3;
    szData[iCurPos] = PRINT_CARD_NO;    //��ӡ��Ϣ��¼��
    iCurPos ++;
    ChangePan( giDispMode, ptAppStru->szPan, szTmpStr );
    sprintf( szData+iCurPos, "%s", szTmpStr );    //��ӡ��Ϣ
    iCurPos += strlen(szTmpStr);
    szData[iCurPos] = 0x00;            //��¼����
    iCurPos ++;

    //���׽��
    memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
    iCurPos += 3;
    szData[iCurPos] = PRINT_AMOUNT;    //��ӡ��Ϣ��¼��
    iCurPos ++;
    ChgAmtZeroToDot( ptAppStru->szAmount, 1, szTmpStr );
    sprintf( szData+iCurPos, "%s", szTmpStr );//��ӡ��Ϣ
    iCurPos += strlen(szTmpStr);
    szData[iCurPos] = 0x00;            //��¼����
    iCurPos ++;

    //����ʱ��
    memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
    iCurPos += 3;
    szData[iCurPos] = PRINT_DATE_TIME;    //��ӡ��Ϣ��¼��
    iCurPos ++;
    sprintf( szData+iCurPos, "%4.4s/%2.2s/%2.2s %2.2s:%2.2s:%2.2s", 
        ptAppStru->szHostDate, ptAppStru->szHostDate+4, ptAppStru->szHostDate+6,
        ptAppStru->szHostTime, ptAppStru->szHostTime+2, ptAppStru->szHostTime+4);    //��ӡ��Ϣ
    iCurPos += 19;
    szData[iCurPos] = 0x00;            //��¼����
    iCurPos ++;

    //������ˮ��
    memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
    iCurPos += 3;
    szData[iCurPos] = PRINT_TRACE;    //��ӡ��Ϣ��¼��
    iCurPos ++;
    sprintf( szTmpStr, "%06ld", ptAppStru->lPosTrace);    //��ӡ��Ϣ
    memcpy( szData+iCurPos, szTmpStr, strlen(szTmpStr) );
    iCurPos += strlen(szTmpStr);
    szData[iCurPos] = 0x00;            //��¼����
    iCurPos ++;

    iLastLen = iCurPos;
        
    //��ע0
    memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
    iCurPos += 3;
    szData[iCurPos] = PRINT_NOTE0;    //��ӡ��Ϣ��¼��
    iCurPos ++;
    szData[iCurPos] = 0x00;            //��¼����
    iCurPos ++;

    //��ע1
    memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
    iCurPos += 3;
    szData[iCurPos] = PRINT_NOTE1;    //��ӡ��Ϣ��¼��
    iCurPos ++;
    szData[iCurPos] = 0x00;            //��¼����
    iCurPos ++;

    //��ע2
    memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
    iCurPos += 3;
    szData[iCurPos] = PRINT_NOTE2;    //��ӡ��Ϣ��¼��
    iCurPos ++;
    szData[iCurPos] = 0x00;            //��¼����
    iCurPos ++;

    //��ע3
    memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
    iCurPos += 3;
    szData[iCurPos] = PRINT_NOTE3;    //��ӡ��Ϣ��¼��
    iCurPos ++;
    szData[iCurPos] = 0x00;            //��¼����
    iCurPos ++;
        
    iPrintLen = iCurPos;

    *iPrintNum = iNum;
    memcpy( szPrintData, szData, iPrintLen );

    return iPrintLen;
}

/*****************************************************************
** ��    ��: �û��Զ����ӡ���� 
** �������:
            ptAppStru 
** �������:
            szPrintData  ��ӡ����
            iPrintNum    ��ӡ���ݸ���
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
GetStaticPrintData( ptAppStru, szPrintData, iPrintNum )
T_App    *ptAppStru;
unsigned char    *szPrintData;
int *iPrintNum;
{
    int iPrintLen, iNum, iCurPos, i;
    char szTmpStr[100], szData[512], szBeginDate[9], szEndDate[9];

    iPrintLen = 0;
    iCurPos = 0;
    iNum = 1;    //��ӡ����
    /*��ӡ���Ʒ���(3 bytes):%Bn��ʾ��n�ݱ��⣬��1�о���
                  %FFΪ����
                  %En��ʾ��n�������1�о���
      ģ���¼��(1 bytes)
      ��ӡ��Ϣ:��ӡ��Ϣ��Ϊ"FFFF" ����ʾʹ�ò˵���ʾ�����滻
    */
    /*���� & ���*/
    for( i=1; i<=iNum; i++ )
    {
        /* ���� */
        memcpy( szData+iCurPos, "%B", 2 );    //���Ʒ�
        iCurPos += 2;
        szData[iCurPos] = i+'0';
        iCurPos ++;
        szData[iCurPos] = PRINT_TITLE1;        //����ģ���¼��
        iCurPos ++;
        szData[iCurPos] = 0x00;            //��¼����
        iCurPos ++;

        /* ��� */
        memcpy( szData+iCurPos, "%E", 2 );    //���Ʒ�
        iCurPos += 2;
        szData[iCurPos] = i+'0';
        iCurPos ++;
        if( i == 1 )
        {
            szData[iCurPos] = PRINT_SHOP_SLIP;    //���ģ���¼��
        }
        else
        {
            szData[iCurPos] = PRINT_HOLDER_SLIP;    //���ģ���¼��
        }
        iCurPos ++;
        szData[iCurPos] = 0x00;            //��¼����
        iCurPos ++;
    }

    //�̻�����
    memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
    iCurPos += 3;
    szData[iCurPos] = PRINT_SHOP_NAME;    //��ӡ��Ϣ��¼��
    iCurPos ++;
    memcpy( szData+iCurPos, ptAppStru->szShopName, 
            strlen( ptAppStru->szShopName) );//��ӡ��Ϣ
    iCurPos += strlen(ptAppStru->szShopName);
    szData[iCurPos] = 0x00;            //��¼����
    iCurPos ++;

    //�ն˺�
    memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
    iCurPos += 3;
    szData[iCurPos] = PRINT_TERM_NO;    //��ӡ��Ϣ��¼��
    iCurPos ++;
    memcpy( szData+iCurPos, ptAppStru->szPosNo, strlen(ptAppStru->szPosNo) );    //��ӡ��Ϣ
    iCurPos += strlen(ptAppStru->szPosNo);
    szData[iCurPos] = 0x00;            //��¼����
    iCurPos ++;

    //���׻���
    memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
    iCurPos += 3;
    szData[iCurPos] = PRINT_BLANK;        //��ӡ��Ϣ��¼��
    iCurPos ++;
    if( strcmp( ptAppStru->szInDate, "FFFFFFFF" ) == 0 )
    {
        strcpy( szBeginDate, "20090101" );
    }
    else
    {
        strcpy( szBeginDate, ptAppStru->szInDate );
    }
    if( strcmp( ptAppStru->szHostDate, "FFFFFFFF" ) == 0 )
    {
        GetSysDate( szEndDate );
    }
    else
    {
        strcpy( szEndDate, ptAppStru->szHostDate );
    }
    sprintf( szTmpStr, "����:%8.8s-%8.8s", szBeginDate, szEndDate );
    memcpy( szData+iCurPos, szTmpStr, strlen(szTmpStr) );    //��ӡ��Ϣ
    iCurPos += strlen(szTmpStr);
    szData[iCurPos] = 0x00;            //��¼����
    iCurPos ++;
    
    //����
    memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
    iCurPos += 3;
    szData[iCurPos] = PRINT_BLANK;        //��ӡ��Ϣ��¼��
    iCurPos ++;
    strcpy( szTmpStr, "���� ����(��)  ���(Ԫ)" );
    memcpy( szData+iCurPos, szTmpStr, strlen(szTmpStr) );    //��ӡ��Ϣ
    iCurPos += strlen(szTmpStr);
    szData[iCurPos] = 0x00;            //��¼����
    iCurPos ++;

    //����
    memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
    iCurPos += 3;
    szData[iCurPos] = PRINT_BLANK;    //��ӡ��Ϣ��¼��
    iCurPos ++;
    sprintf( szTmpStr, "����:%16.16s", ptAppStru->szReserved+25 );
    memcpy( szData+iCurPos, szTmpStr, strlen(szTmpStr) );    //��ӡ��Ϣ
    iCurPos += strlen(szTmpStr);
    szData[iCurPos] = 0x00;            //��¼����
    iCurPos ++;
    
    //�˻�
    memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
    iCurPos += 3;
    szData[iCurPos] = PRINT_BLANK;    //��ӡ��Ϣ��¼��
    iCurPos ++;
    sprintf( szTmpStr, "�˻�:%16.16s", ptAppStru->szReserved+46 );
    memcpy( szData+iCurPos, szTmpStr, strlen(szTmpStr) );    //��ӡ��Ϣ
    iCurPos += strlen(szTmpStr);
    szData[iCurPos] = 0x00;            //��¼����
    iCurPos ++;

    iPrintLen = iCurPos;

    *iPrintNum = iNum;
    memcpy( szPrintData, szData, iPrintLen );

    return iPrintLen;
}

/*****************************************************************
** ��    ��: ȡ��ӡ���� 
** �������:
            ptAppStru 
** �������:
            szPrintData  ��ӡ����
            iPrintNum    ��ӡ���ݸ���
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
int GetPrintData( ptAppStru, iIndex, szPrintData, iPrintNum )
T_App    *ptAppStru;
int    iIndex;
unsigned char    *szPrintData;
int *iPrintNum;
{
    EXEC SQL BEGIN DECLARE SECTION;
        int    iPrintModule, iPrintRecNo, iDataIndex;
        struct T_PRINT_MODULE {
            int     iModuleId;
            char    szDescribe[41];
            int     iPrintNum;
            int     iTitle1;
            int     iTitle2;
            int     iTitle3;
            int     iSign1;
            int     iSign2;
            int     iSign3;
            int     iRecNum;
            char    szRecNo[81];
        }tPrintModule;
        
    EXEC SQL END DECLARE SECTION;

    int iPrintLen, iNum, iCurPos, i, iRet, iLastLen;
    long lAmt, lFee;
    char szTmpStr[100], szAmtStr[13], szData[1024], szBuf[200];
    char szRecNo[200];
    int  iTooLong;

    if( ptAppStru->iTransType == REPRINT || ptAppStru->iTransType == QUERY_LAST_DETAIL )
    {
        iPrintModule = ptAppStru->iTransNum;
    }
    iPrintModule = ptAppStru->szDataSource[iIndex];

    //δ�����ӡģ��ţ�����Ӳ���뷽ʽʵ�ִ�ӡ������֯
    if( iPrintModule == 0 )
    {
        if( ptAppStru->iTransType == QUERY_TOTAL )
        {
            iPrintLen = GetStaticPrintData( ptAppStru, szPrintData, iPrintNum );
        }
        else
        {
            iPrintLen = UserGetPrintData( ptAppStru, szPrintData, iPrintNum );
        }
        return iPrintLen;
    }

    //��ȡ��ӡģ��
    EXEC SQL SELECT 
        MODULE_ID,
        NVL(DESCRIBE,' '),
        NVL(PRINT_NUM, 1),
        NVL(TITLE1, 0),
        NVL(TITLE2, 0),
        NVL(TITLE3, 0),
        NVL(SIGN1, 0),
        NVL(SIGN2, 0),
        NVL(SIGN3,0),
        NVL(REC_NUM, 1),
        NVL(REC_NO, ' ')
    INTO 
        :tPrintModule.iModuleId,
        :tPrintModule.szDescribe,
        :tPrintModule.iPrintNum,
        :tPrintModule.iTitle1,
        :tPrintModule.iTitle2,
        :tPrintModule.iTitle3,
        :tPrintModule.iSign1,
        :tPrintModule.iSign2,
        :tPrintModule.iSign3,
        :tPrintModule.iRecNum,
        :tPrintModule.szRecNo
    FROM print_module
    WHERE module_id = :iPrintModule;

    if( SQLCODE == SQL_NO_RECORD )
    {
        WriteLog( ERROR, "PrintModule[%d] not exist", iPrintModule );
        iPrintLen = UserGetPrintData( ptAppStru, szPrintData, iPrintNum );
        return iPrintLen;
    }
    else if( SQLCODE )
    {
        WriteLog( ERROR, "get print module fail %ld", SQLCODE );
        iPrintLen = UserGetPrintData( ptAppStru, szPrintData, iPrintNum );
        return iPrintLen;
    }

    iPrintLen = 0;
    iLastLen = 0;
    iCurPos = 0;
    iNum = tPrintModule.iPrintNum;
    /*��ӡ���Ʒ���(3 bytes):%Bn��ʾ��n�ݱ��⣬��1�о���
                  %FFΪ����
                  %En��ʾ��n�������1�о���
      ģ���¼��(1 bytes)
      ��ӡ��Ϣ:��ӡ��Ϣ��Ϊ"FFFF" ����ʾʹ�ò˵���ʾ�����滻
    */
    /*���� & ���*/
    for( i=1; i<=iNum; i++ )
    {
        /* ���� */
        memcpy( szData+iCurPos, "%B", 2 );    //���Ʒ�
        iCurPos += 2;
        szData[iCurPos] = i+'0';
        iCurPos ++;
        switch ( i ){
        case 1:
            szData[iCurPos] = tPrintModule.iTitle1;//����1ģ���¼��
            break;
        case 2:
            szData[iCurPos] = tPrintModule.iTitle2;//����2ģ���¼��
            break;
        case 3:
            szData[iCurPos] = tPrintModule.iTitle3;//����3ģ���¼��
            break;
        }
        iCurPos ++;
        szData[iCurPos] = 0x00;            //��¼����
        iCurPos ++;

        /* ��� */
        memcpy( szData+iCurPos, "%E", 2 );    //���Ʒ�
        iCurPos += 2;
        szData[iCurPos] = i+'0';
        iCurPos ++;
        switch ( i ){
        case 1:
            szData[iCurPos] = tPrintModule.iSign1;//���1ģ���¼��
            break;
        case 2:
            szData[iCurPos] = tPrintModule.iSign2;//���2ģ���¼��
            break;
        case 3:
            szData[iCurPos] = tPrintModule.iSign3;//���3ģ���¼��
            break;
        }
        iCurPos ++;
        szData[iCurPos] = 0x00;            //��¼����
        iCurPos ++;
    }

    AscToBcd( (unsigned char*)(tPrintModule.szRecNo),tPrintModule.iRecNum*2, 0 ,(unsigned char*)szRecNo);
    
    iLastLen = iCurPos;
    //����
    for( i=0; i<tPrintModule.iRecNum; i++ )
    {
        memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
        iCurPos += 3;
        szData[iCurPos] = (unsigned char)szRecNo[i];    //��ӡ���ݼ�¼��
        iCurPos ++;
        iPrintRecNo = (unsigned char)szRecNo[i];

        EXEC SQL SELECT nvl(data_index, 0) 
                INTO :iDataIndex
        FROM print_info
        WHERE rec_no = :iPrintRecNo;
        if( SQLCODE == SQL_NO_RECORD )
        {
            WriteLog( ERROR, "print rec_no[%d] not exist", iPrintRecNo );    
            iDataIndex = 0;
        }
        else if( SQLCODE )
        {
            WriteLog( ERROR, "get data_index[%ld] fail %ld", iPrintRecNo, SQLCODE );
            iDataIndex = 0;
        }

        //������������ȡ��ӡ��Ϣ
        if( iDataIndex > 0 )
        {
            memset( szTmpStr, 0, 100 );
            switch ( iDataIndex ){
            case HOST_DATETIME_IDX:
                sprintf( szTmpStr, "%4.4s/%2.2s/%2.2s %2.2s:%2.2s:%2.2s", 
                         ptAppStru->szHostDate, ptAppStru->szHostDate+4, 
                         ptAppStru->szHostDate+6, ptAppStru->szHostTime, 
                         ptAppStru->szHostTime+2, ptAppStru->szHostTime+4 );
                break;
            case POS_DATETIME_IDX:
                sprintf( szTmpStr, "%4.4s/%2.2s/%2.2s %2.2s:%2.2s:%2.2s", 
                         ptAppStru->szPosDate, ptAppStru->szPosDate+4, 
                         ptAppStru->szPosDate+6, ptAppStru->szPosTime, 
                         ptAppStru->szPosTime+2, ptAppStru->szPosTime+4 );
                break;
            case PAN_IDX:
                ChangePan( giDispMode, ptAppStru->szPan, szTmpStr );
                break;
            case AMOUNT_IDX:
                ChgAmtZeroToDot( ptAppStru->szAmount, 1, szBuf );
                sprintf(szTmpStr, "%sԪ", szBuf);
                break;
            case TRANS_NAME_IDX:
                if( ptAppStru->iTransType == REPRINT || ptAppStru->iTransType == QUERY_LAST_DETAIL )
                {
                    strcpy( szTmpStr, ptAppStru->szReserved );
                }
                else
                {
                    strcpy( szTmpStr, ptAppStru->szTransName );
                }
                break;
            case POS_TRACE_IDX:
                if( ptAppStru->iTransType == REPRINT || ptAppStru->iTransType == QUERY_LAST_DETAIL )
                {
                    sprintf(szTmpStr, "%06ld", ptAppStru->lOldPosTrace);
                }
                else
                {
                    sprintf(szTmpStr, "%06ld", ptAppStru->lPosTrace);
                }
                break;
            case RETRI_REF_NUM_IDX:
                strcpy( szTmpStr, ptAppStru->szRetriRefNum );
                break;
            case AUTH_CODE_IDX:
                strcpy( szTmpStr, ptAppStru->szAuthCode);
                break;
            case SHOP_NO_IDX:
                strcpy( szTmpStr, ptAppStru->szShopNo );
                break;
            case POS_NO_IDX:
                strcpy( szTmpStr, ptAppStru->szPosNo );
                break;
            case SHOP_NAME_IDX:
                strcpy( szTmpStr, ptAppStru->szShopName );
                break;
            case PSAM_NO_IDX:
                strcpy( szTmpStr, ptAppStru->szPsamNo );
                break;
            case SYS_TRACE_IDX:
                sprintf(szTmpStr, "%06ld", ptAppStru->lSysTrace);
                break;
            case ACCOUNT2_IDX:
                ChangePan( giDispMode, ptAppStru->szAccount2, 
                    szTmpStr );
                break;
            case OLD_POS_TRACE_IDX:
                if( ptAppStru->iTransType == REPRINT || ptAppStru->iTransType == QUERY_LAST_DETAIL )
                {
                    sprintf(szTmpStr, "%06ld", ptAppStru->lRate);
                }
                else
                {
                    sprintf(szTmpStr, "%06ld", ptAppStru->lOldPosTrace);
                }
                break;
            case OLD_RETRI_REF_NUM_IDX:
                strcpy( szTmpStr, ptAppStru->szOldRetriRefNum );
                break;
            case FINANCIAL_CODE_IDX:
                strcpy( szTmpStr, ptAppStru->szFinancialCode);
                break;
            case BUSINESS_CODE_IDX:
                strcpy( szTmpStr, ptAppStru->szBusinessCode);
                break;
            case HOST_DATE_IDX:
                sprintf( szTmpStr, "%4.4s/%2.2s/%2.2s", ptAppStru->szHostDate, 
                         ptAppStru->szHostDate+4, ptAppStru->szHostDate+6 );
                break;
            case POS_DATE_IDX:
                sprintf( szTmpStr, "%4.4s/%2.2s/%2.2s", ptAppStru->szPosDate, 
                         ptAppStru->szPosDate+4, ptAppStru->szPosDate+6 );
                break;
            case HOST_TIME_IDX:
                sprintf( szTmpStr, "%2.2s:%2.2s:%2.2s", ptAppStru->szHostTime, 
                         ptAppStru->szHostTime+2, ptAppStru->szHostTime+4 );
                break;
            case POS_TIME_IDX:
                sprintf( szTmpStr, "%2.2s:%2.2s:%2.2s", ptAppStru->szPosTime, 
                         ptAppStru->szPosTime+2, ptAppStru->szPosTime+4 );
                break;
            case EXPIRE_DATE_IDX:
                sprintf( szTmpStr, "%2.2s/%2.2s", ptAppStru->szExpireDate+2, 
                         ptAppStru->szExpireDate );
                break;
            case SHOP_TYPE_IDX:
                strcpy( szTmpStr, ptAppStru->szShopType );
                break;
            case TRANS_NUM_IDX:
                sprintf(szTmpStr, "%06ld", ptAppStru->iTransNum);
                break;
            case RATE_IDX:
                sprintf(szTmpStr, "%ld", ptAppStru->lRate);
                break;
            case TRACK2_IDX:
                strcpy( szTmpStr, ptAppStru->szTrack2);
                break;
            case TRACK3_IDX:
                strcpy( szTmpStr, ptAppStru->szTrack3);
                break;
            case MAC_IDX:
                BcdToAsc( (unsigned char*)(ptAppStru->szMac), 8, LEFT_ALIGN ,(unsigned char*)szTmpStr);
                szTmpStr[8] = ' ';
                BcdToAsc((unsigned char*)(ptAppStru->szMac+4), 8, LEFT_ALIGN, (unsigned char*)szBuf);
                memcpy( szTmpStr+9, szBuf, 8 );
                szTmpStr[17] = 0;
                break;
            case RET_CODE_IDX:
                strcpy( szTmpStr, ptAppStru->szRetCode);
                break;
            case RET_DESC_IDX:
                strcpy( szTmpStr, ptAppStru->szRetDesc );
                break;
            case BATCH_NO_IDX:
                sprintf( szTmpStr, "%06ld", ptAppStru->lBatchNo );
                break;
            case RESERVED_IDX:
                strcpy( szTmpStr, ptAppStru->szReserved );
                break;
            case ADDI_AMOUNT_IDX:
                ChgAmtZeroToDot( ptAppStru->szAddiAmount, 1, szBuf );
                sprintf(szTmpStr, "%sԪ", szBuf);
                break;
            case TOTAL_AMT_IDX:
                memcpy( szTmpStr, ptAppStru->szAddiAmount, 12 );
                szTmpStr[12] = 0;
                lFee = atoll( szTmpStr );

                memcpy( szTmpStr, ptAppStru->szAmount, 12 );
                szTmpStr[12] = 0;
                lAmt = atoll( szTmpStr );
                sprintf(szAmtStr, "%012u", lAmt+lFee);
                ChgAmtZeroToDot( szAmtStr, 1, szTmpStr );
                strcat( szTmpStr, "Ԫ" );
                break;
            case IN_BANK_ID_IDX:
                strcpy( szTmpStr, ptAppStru->szInBankId);
                break;
            case OUT_BANK_ID_IDX:
                strcpy( szTmpStr, ptAppStru->szOutBankId);
                break;
            case ACQ_BANK_ID_IDX:
                strcpy( szTmpStr, ptAppStru->szAcqBankId);
                break;
            case IN_BANK_NAME_IDX:
                strcpy( szTmpStr, ptAppStru->szInBankName);
                break;
            case OUT_BANK_NAME_IDX:
                strcpy( szTmpStr, ptAppStru->szOutBankName);
                break;
            case MENU_NAME_IDX:
                if( ptAppStru->iTransType == REPRINT || ptAppStru->iTransType == QUERY_LAST_DETAIL )
                {
                    strcpy( szTmpStr, ptAppStru->szReserved );
                }
                else
                {
                    strcpy( szTmpStr, "FFFF" );
                }
                break;
            case HOLDER_NAME_IDX:
                sprintf( szTmpStr, "*%s", ptAppStru->szHolderName+2 );
                break;
            case HAND_INPUT_DATE_IDX:
                sprintf( szTmpStr, "%4.4s/%2.2s/%2.2s", ptAppStru->szInDate, 
                         ptAppStru->szInDate+4, ptAppStru->szInDate+6 );
                break;
            default:
                strcpy( szTmpStr, "XXXX" );
                break;
            }

            sprintf( szData+iCurPos, "%s", szTmpStr );
            iCurPos += strlen(szTmpStr);
        }

        szData[iCurPos] = 0x00;            //��¼����
        iCurPos ++;

        iLastLen = iCurPos;
        //2010�汾��ӡ���ݿ��Գ���254
        if( memcmp(ptAppStru->szMsgVer, "\x20\x10", 2) < 0 )
        {
            if( iCurPos <= 254 )
            {
                iLastLen = iCurPos;
            }
            else
            {
                iTooLong = 1;
                break;
            }
        }
        else
        {
            iLastLen = iCurPos;
        }
    }

    /* �ش�ӡ��Ҫ�����ش�ӡ�ı�ʶ */
    if( ptAppStru->iTransType == REPRINT || ptAppStru->iTransType == QUERY_LAST_DETAIL )
    {
        memcpy( szData+iCurPos, "%FF", 3 );    //���Ʒ�
        iCurPos += 3;
        szData[iCurPos] = PRINT_REPRINT;    //��ӡ���ݼ�¼��
        iCurPos ++;
        szData[iCurPos] = 0x00;        //��¼����*/
        iCurPos ++;

        iLastLen = iCurPos;

        //2010�汾��ӡ���ݿ��Գ���254
        if( memcmp(ptAppStru->szMsgVer, "\x20\x10", 2) < 0 )
        {
            if( iCurPos <= 254 )
            {
                iLastLen = iCurPos;
            }
            else
            {
                iTooLong = 1;
            }
        }
        else
        {
            iLastLen = iCurPos;
        }
    }


    iPrintLen = iCurPos;

    if( iTooLong == 1 )
    {
        WriteLog( ERROR, "��ӡ����̫��������� %d %d", iCurPos, iLastLen );
        iPrintLen = iLastLen;
    }

    *iPrintNum = iNum;
    memcpy( szPrintData, szData, iPrintLen );

    return iPrintLen;
}
