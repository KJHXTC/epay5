/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:�ն������ཻ��

** �����б�:
** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.3 $
$Log: DownStaticMenu.ec,v $
Revision 1.3  2013/02/21 06:22:52  fengw

1���޸ľ�̬�˵���ʾ���ݡ�

Revision 1.2  2013/01/24 07:41:31  wukj
QLCODE��ӡ��ʽ�޸�Ϊ%d

Revision 1.1  2012/12/18 10:04:56  wukj
*** empty log message ***

*******************************************************************/

# include "manatran.h"

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL EnD DECLARE SECTION;
#endif


int gnStaticMenuNum = 10;

/*****************************************************************
** ��    ��:��̬�˵�����
** �������:
           ptAppStru
** �������:
           ptAppStru->szReserved        ��̬�˵���Ϣ
           ptAppStru->iReservedLen    ��̬�˵���Ϣ����
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
int DownStaticMenuBak( ptAppStru ) 
T_App    *ptAppStru;
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szShopNo[20+1];
        char     szPosNo[20+1];
    EXEC SQL END DECLARE SECTION;
    int iPos = 0;
    char szTmpBuf[90+1];
    int iLen=0;
    char szStaticMenuPara[1204+1];
    memset(szStaticMenuPara, 0, sizeof(szStaticMenuPara));
    memset(szTmpBuf,0,sizeof(szTmpBuf));
    
    szStaticMenuPara[iPos] = 0x02;
    iPos++;
    
    szStaticMenuPara[iPos] = 0x01;
    iPos++;
    
    szStaticMenuPara[iPos] = 0x06;
    iPos++;
    
    //�˵�IDΪ1�ĸ��˵�
        //�Ӳ˵�����
        szStaticMenuPara[iPos] = 0x01;
        iPos++;
        //��ʾ����
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        strcpy(szTmpBuf,"������");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
        //��ʾ����
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        sprintf(szTmpBuf,"%s\n%s\n%s\n","�˺�:6225885912347654","����:������","������:��������");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
        //�������
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        sprintf(szTmpBuf,"%s","6225885912347654");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
        
        szStaticMenuPara[iPos] = 0x02;
        iPos++;
        //��ʾ����
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        strcpy(szTmpBuf,"�����");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
        //��ʾ����
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        sprintf(szTmpBuf,"%s\n%s\n%s\n","�˺�:622577","����:�����","��ͨ");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
        //�������
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        sprintf(szTmpBuf,"%s","622577");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
    
        szStaticMenuPara[iPos] = 0x03;
        iPos++;
        //��ʾ����
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        strcpy(szTmpBuf,"����");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
        //��ʾ����
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        sprintf(szTmpBuf,"%s\n%s\n%s\n","�˺�:622566","����:����","����");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
        //�������
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        sprintf(szTmpBuf,"%s","622566");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;

        szStaticMenuPara[iPos] = 0x04;
        iPos++;
        //��ʾ����
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        strcpy(szTmpBuf,"����");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
        //��ʾ����
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        sprintf(szTmpBuf,"%s\n%s\n%s\n","�˺�:6225555","����:����","����");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
        //�������
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        sprintf(szTmpBuf,"%s","6225555");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
        
        szStaticMenuPara[iPos] = 0x05;
        iPos++;
        //��ʾ����
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        strcpy(szTmpBuf,"�⿪��");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
        //��ʾ����
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        sprintf(szTmpBuf,"%s\n%s\n%s\n","�˺�:622544","����:�⿪��","����");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
        //�������
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        sprintf(szTmpBuf,"%s","622544");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
        
        szStaticMenuPara[iPos] = 0x06;
        iPos++;
        //��ʾ����
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        strcpy(szTmpBuf,"��ΰ��");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
        //��ʾ����
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        sprintf(szTmpBuf,"%s\n%s\n%s\n","�˺�:622533","����:��ΰ��","����");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
        //�������
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        sprintf(szTmpBuf,"%s","622533");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
    
    szStaticMenuPara[iPos] = 0x02;
    iPos++;    
    szStaticMenuPara[iPos] = 0x01;
    iPos++;    
        //�Ӳ˵�
        szStaticMenuPara[iPos] = 0x01;
        iPos++;
        //��ʾ����
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        strcpy(szTmpBuf,"�����");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
        //��ʾ����
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        sprintf(szTmpBuf,"%s\n%s\n%s\n","�˺�:622522","����:�����","ƽ��");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
        //�������
        memset(szTmpBuf,0,sizeof(szTmpBuf));
        sprintf(szTmpBuf,"%s","622522");
        iLen = strlen(szTmpBuf);
        szStaticMenuPara[iPos] = iLen;
        iPos++;
        memcpy(szStaticMenuPara+iPos,szTmpBuf,iLen);
        iPos += iLen;
        
//    ptAppStru->iReservedLen = iPos+2;    
//    ptAppStru->szReserved[0] = iPos/256;
//    ptAppStru->szReserved[1] = iPos%256;
    ptAppStru->iReservedLen = iPos;
    memcpy( ptAppStru->szReserved, szStaticMenuPara, iPos );

    ptAppStru->szReserved[iPos]=0;
    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    
    return ( SUCC );
}

/*****************************************************************
** ��    ��:��̬�˵�����
** �������:
           ptAppStru
** �������:
           ptAppStru->szReserved        ��̬�˵���Ϣ
           ptAppStru->iReservedLen    ��̬�˵���Ϣ����
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
int DownStaticMenu( ptAppStru , iDownloadNew) 
T_App    *ptAppStru;
int    iDownloadNew;
{
    EXEC SQL BEGIN DECLARE SECTION;
        struct T_MYCUSTOMER {
            char    szShopNo[16];
            char    szPosNo[16];
            char    szPan[20];
            char    szAcctName[41];
            char    szExpireDate[5];
            char    szBankName[21];
            char    szRegisterDate[9];
            int     iRecNo;
        }tMyCustomer;
        
        char    szShopNo[15+1];
        char    szPosNo[8+1];
        char    szPsamNo[17], szUpdateDate[9];
        int    iBeginRecNo, iTransType;
        int    iMaxRecNo, iNeedDownMax;
    EXEC SQL END DECLARE SECTION;
    struct T_MENU_ITEM {
        int     iItemId;                        //�˵�����
        char    szDispTitle[20+1];      //��ʾ����
        char    szDispData[90+1];       //��ʾ����
        char    szOutData[30+1];        //�������
    }tMenuItem;

    char szBuf[1024], szData[1024];
    int i, iCurPos, iTotalRecNum, iLastIndex, iCmdLen, iDataLen;
    int iPreCmdLen, iPreCmdNum, iRet;
    char szPreCmd[512], szFlag[2];
    
    memset(szBuf, 0, sizeof(szBuf));
    strcpy( szPsamNo, ptAppStru->szPsamNo );
    strcpy( szShopNo,ptAppStru->szShopNo);
    strcpy( szPosNo,ptAppStru->szPosNo);
    //���ķ����ף������ж��Ƿ���comweb
    strcpy( ptAppStru->szAuthCode, "YES" );

    //�ն˷������һ�������׽�������û����ն�&comweb
    if( memcmp( ptAppStru->szTransCode, "FF", 2 ) == 0 )
    {
        strcpy( ptAppStru->szAuthCode, "NO" );
        if( memcmp( ptAppStru->szHostRetCode, "00", 2 ) == 0 )
        {
            EXEC SQL UPDATE static_menu_cfg
            set DOWN_STATIC_MENU = 'N', STATIC_MENU_recno = 0
            where psam_no = :szPsamNo and static_menu_id = 1;
            if( SQLCODE )
            {
                WriteLog( ERROR, "update static_menu_cfg fail %d", SQLCODE );
                strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
                RollbackTran();
                return FAIL;
            }
            CommitTran();
        }
        strcpy( ptAppStru->szRetCode, TRANS_SUCC );
        return SUCC;
    }

    //Ӧ�����أ����µ�ǰ���ز���
    if( ptAppStru->iTransType == DOWN_STATIC_MENU &&
            memcmp( ptAppStru->szTransCode, "00", 2 ) == 0 )
    {
        WriteLog( TRACE, "begin down %s", ptAppStru->szTransName );

        //�и��½��&trans_codeǰ��λΪ00��������¼���ظտ�ʼ��
        //����ʼ��¼Ϊ0
        if( memcmp(ptAppStru->szHostRetCode, "NN", 2) != 0 )
        {
            EXEC SQL UPDATE static_menu_cfg
            set static_menu_recno = 0,
                down_static_menu = 'N'
            where psam_no = :szPsamNo and static_menu_id = 1;
                
            if( SQLCODE )
            {
                WriteLog( ERROR, "update static_menu_cfg fail %d", SQLCODE );
                strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
                RollbackTran();
                return FAIL;
            }
            CommitTran();
        
        }
        else
        {
            EXEC SQL SELECT 
                       NVL(STATIC_MENU_ID,0),
                       NVL(DOWN_STATIC_MENU ,' '),
                       NVL(STATIC_MENU_RECNO ,0),
                       NVL(PSAM_NO,' ')
                     FROM  static_menu_cfg
                     WHERE PSAM_NO = :szPsamNo and static_menu_id = 1;
            if( SQLCODE == SQL_NO_RECORD)
            {
                EXEC SQL INSERT INTO STATIC_MENU_CFG (STATIC_MENU_ID, DOWN_STATIC_MENU,STATIC_MENU_RECNO,PSAM_NO)
                         VALUES (1,'N',0,:szPsamNo);
                if( SQLCODE )
                {
                    WriteLog( ERROR, "insert static_menu_cfg fail %d", SQLCODE );
                    strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
                    RollbackTran();
                    return FAIL;
                }
                CommitTran();                    
            }
            else if( SQLCODE )
            {
                WriteLog( ERROR, "select static_menu_cfg fail %d", SQLCODE );
                strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
                return FAIL;
            }
                
        }        
    }

    ptAppStru->iReservedLen = 0;


    //�׸����ذ�
    if( memcmp( ptAppStru->szTransCode, "00", 2 ) == 0 )
    {        
        iBeginRecNo = 0;        
    }
    else
    {
        AscToBcd( (uchar*)(ptAppStru->szTransCode), 2, 0 , (uchar*)szBuf);
        szBuf[1] = 0;
        iBeginRecNo = (uchar)szBuf[0];

        //�ն˸��³ɹ������������ؼ�¼��
        if( memcmp(ptAppStru->szHostRetCode, "00", 2) == 0 )
        {
            EXEC SQL UPDATE static_menu_cfg 
            set static_menu_recno = :iBeginRecNo
            where psam_no = :szPsamNo and static_menu_id = 1;
            if( SQLCODE )
            {
                WriteLog( ERROR, "update static_menu_cfg fail %d", SQLCODE );
                strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
                RollbackTran();
                return FAIL;
                
            }
            CommitTran();
        }
        else
        {
            WriteLog( ERROR, "�ն�[%s]����ʧ��[%s]", szPsamNo, ptAppStru->szHostRetCode );
            sprintf( ptAppStru->szPan, "�ն˸��½��" );
            return FAIL;
        }
    }

    // �ն�ѡ�������ط�ʽ�����ն�ѡ��Ϊ׼��������ƽ̨����Ϊ׼ 
    if( ptAppStru->szControlCode[0] == '1' )
    {
        iDownloadNew = 1;
    }
    else if( ptAppStru->szControlCode[0] == '0' )
    {
        iDownloadNew = 0;
    }


    //��������
    if( iDownloadNew == 1 )
    {
        // ֻ��Ҫ����Ӧ�ð汾��֮������� 
        BcdToAsc( (uchar *)(ptAppStru->szAppVer), 8, 0 ,(uchar *)szUpdateDate);
        szUpdateDate[8] = 0;
    }
    //��ȫ����
    else
    {
        strcpy( szUpdateDate, "20000101" );
    }

    //ȡ���¼�ţ������ж��Ƿ���Ҫ֪ͨ
    //  �ն˽��к������أ��������ն˵���һ������
    EXEC SQL SELECT NVL(max(rec_no),0) into :iMaxRecNo
    FROM my_customer
    WHERE rec_no > :iBeginRecNo and
          shop_no = :szShopNo and pos_no = :szPosNo and
         register_date >= :szUpdateDate ;
    if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "count my_customer_cur fail %d", SQLCODE );
        return FAIL;
    }
    if (iMaxRecNo == 0)
    {
        strcpy( ptAppStru->szRetCode, ERR_LAST_RECORD);
        WriteLog( ERROR, " û�з��������ľ�̬�˵���Ϣ" );
        return FAIL;
    }
     /*if( iMaxRecNo < iNeedDownMax )
    {
        iNeedDownMax = iMaxRecNo;
    }
        */
    EXEC SQL DECLARE my_customer_cur cursor for
    SELECT
        shop_no,
        NVL(pan, '6225'),
        NVL(acct_name, 1),
        NVL(expire_date,'0000'),
        NVL(BANK_NAME,'����'),
        NVL(REGISTER_DATE,'20080101'),        
        NVL(rec_no,0)
    FROM my_customer
    WHERE rec_no > :iBeginRecNo and
         shop_no = :szShopNo and pos_no = :szPosNo and
         register_date >= :szUpdateDate
    ORDER BY rec_no;
    if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "delare my_customer_cur fail %d", SQLCODE );
        return FAIL;
    }

    EXEC SQL OPEN my_customer_cur;
    if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "open my_customer_cur fail %d", SQLCODE );
        EXEC SQL CLOSE my_customer_cur;
        return FAIL;
    }

    iTotalRecNum = 0;
    iDataLen = 0;
    iCurPos = 0;
    //��̬�˵�����
    szBuf[iCurPos]=1;
    iCurPos++;
    //��̬�˵�ID
    szBuf[iCurPos]=1;
    iCurPos++;
    //�˵�ѡ�����
    iCurPos++;
    while(1)
    {
        memset(&tMyCustomer, 0, sizeof(struct T_MYCUSTOMER));
        memset(&tMenuItem, 0, sizeof(struct T_MENU_ITEM));
    
        EXEC SQL FETCH my_customer_cur 
        INTO 
            :tMyCustomer.szShopNo,
            :tMyCustomer.szPan,
            :tMyCustomer.szAcctName,
            :tMyCustomer.szExpireDate,
            :tMyCustomer.szBankName,
            :tMyCustomer.szRegisterDate,
            :tMyCustomer.iRecNo;
        if( SQLCODE == SQL_NO_RECORD )
        {
            EXEC SQL CLOSE my_customer_cur;
            break;
        }
        else if( SQLCODE )
        {
            strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
            WriteLog( ERROR, "fetch my_customer_cur fail %d", SQLCODE );
            EXEC SQL CLOSE my_customer_cur;
            return FAIL;
        }

        if (iCurPos > 350)
        {
            EXEC SQL CLOSE my_customer_cur;
            break;
        }

        // �ﵽÿ�������������� 
        if( iTotalRecNum >= gnStaticMenuNum )
        {
            EXEC SQL CLOSE my_customer_cur;
            break;
        }

        //������¼��������
        if( tMyCustomer.iRecNo> iMaxRecNo )
        {
            EXEC SQL CLOSE my_customer_cur;
            break;
        }

        //������¼����Ҫ����
        if( ptAppStru->szReserved[tMyCustomer.iRecNo-1] == '0' && tMyCustomer.iRecNo!= iNeedDownMax )
        {
            continue;
        }

        DelTailSpace( tMyCustomer.szPan );
        DelTailSpace( tMyCustomer.szAcctName );
        DelTailSpace( tMyCustomer.szExpireDate );
        DelTailSpace( tMyCustomer.szBankName );
        
        //�Ӳ˵�����
        tMenuItem.iItemId = tMyCustomer.iRecNo;
                
        //��ʾ����        
        memcpy(tMenuItem.szDispTitle,tMyCustomer.szAcctName,strlen(tMyCustomer.szAcctName));
        
        //��ʾ����    
        sprintf(tMenuItem.szDispData,"�˺�:%s\n����:%s\n������:%s\n",tMyCustomer.szPan,tMyCustomer.szAcctName,tMyCustomer.szBankName);
        //�������        
        sprintf(tMenuItem.szOutData,"%s",tMyCustomer.szPan);
                
        szBuf[iCurPos] = tMenuItem.iItemId;
        iCurPos ++;
        
        szBuf[iCurPos] = strlen(tMenuItem.szDispTitle);
        iCurPos ++;
        memcpy(szBuf+iCurPos, tMenuItem.szDispTitle, strlen(tMenuItem.szDispTitle));
        iCurPos += strlen(tMenuItem.szDispTitle);
        
        szBuf[iCurPos] = strlen(tMenuItem.szDispData);
        iCurPos ++;
        memcpy(szBuf+iCurPos, tMenuItem.szDispData, strlen(tMenuItem.szDispData));
        iCurPos += strlen(tMenuItem.szDispData);

        szBuf[iCurPos] = strlen(tMenuItem.szOutData);
        iCurPos ++;
        memcpy(szBuf+iCurPos, tMenuItem.szOutData, strlen(tMenuItem.szOutData));
        iCurPos += strlen(tMenuItem.szOutData);
        
        iLastIndex = tMyCustomer.iRecNo;
        iTotalRecNum ++;    
        
    }
    szBuf[2]= iTotalRecNum;
    ptAppStru->iReservedLen = iCurPos;    
    memcpy( ptAppStru->szReserved, szBuf, iCurPos );
    sprintf( ptAppStru->szPan, "����%03d-%03d / %03d", iBeginRecNo+1, iLastIndex, iMaxRecNo );

    // ��Ҫ���к������� 
    if( iLastIndex < iMaxRecNo )
    {
        //�������״���ǰ2λ��ʾ�����ؼ�¼����¼�ţ���6λΪ��ǰ����
        //�����6λ
        memset(szBuf, 0, sizeof(szBuf));
        szBuf[0] = iLastIndex;
        szBuf[1] = 0;
        BcdToAsc( (uchar*)szBuf, 2, 0 ,(uchar*)(ptAppStru->szNextTransCode));
        memcpy( ptAppStru->szNextTransCode+2, ptAppStru->szTransCode+2, 6 );
        ptAppStru->szNextTransCode[8] = 0;
        
        iCmdLen = 0;
        ptAppStru->iCommandNum = 0;
        if( memcmp(ptAppStru->szTransCode, "00", 2) == 0 )
        {
            //��ʱ��ʾ��Ϣ
            memcpy( ptAppStru->szCommand + iCmdLen, "\xAF", 1 );    
            iCmdLen += 1;
            ptAppStru->iCommandNum ++;
        }
        memcpy( ptAppStru->szCommand+iCmdLen, "\x2C\xFF", 2 );//���¾�̬�˵�
        iCmdLen += 2;
        ptAppStru->iCommandNum ++;
        memcpy( ptAppStru->szCommand+iCmdLen, "\x8D", 1 );    //����MAC
        iCmdLen += 1;
        ptAppStru->iCommandNum ++;
        memcpy( ptAppStru->szCommand+iCmdLen, "\x24\x03", 2 );//��������
        iCmdLen += 2;
        ptAppStru->iCommandNum ++;
        memcpy( ptAppStru->szCommand+iCmdLen, "\x25\x04", 2 );//��������
        iCmdLen += 2;
        ptAppStru->iCommandNum ++;

        ptAppStru->iCommandLen = iCmdLen;

        //��Ҫ���к������أ�����comweb
        strcpy( ptAppStru->szAuthCode, "NO" );
    }
    else
    {        
        memcpy( ptAppStru->szNextTransCode, "FF", 2 );
        memcpy( ptAppStru->szNextTransCode+2, 
            ptAppStru->szTransCode+2, 6 );
        ptAppStru->szNextTransCode[8] = 0;        
    }

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}
