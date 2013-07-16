
/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:�ն������ཻ��

** �����б�:
** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.2 $
$Log: DownPsamPara.ec,v $
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

/*****************************************************************
** ��    ��:PSAM����������
** �������:
           ptAppStru
** �������:
           ptAppStru->szReserved        ������Ϣ
           ptAppStru->iReservedLen    ������Ϣ����
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
int DownPsamPara( ptAppStru ) 
T_App    *ptAppStru;
{
    EXEC SQL BEGIN DECLARE SECTION;
        
        struct T_PSAM_PARA {
            int     iModuleId;
            char    szDescribe[21];
            int     iPinKeyIndex;
            int     iMacKeyIndex;
            int     iFskTeleNum;
            char    szFskTeleNo1[16];
            char    szFskTeleNo2[16];
            char    szFskTeleNo3[16];
            int     iFskDownTeleNum;
            char    szFskDownTeleNo1[16];
            char    szFskDownTeleNo2[16];
            char    szFskDOwnTeleNo3[16];
            int     iHdlcTeleNum;
            char    szHdlcTeleNo1[16];
            char    szHdlcTeleNo2[16];
            char    szHdlcTeleNo3[16];
            int     iHdlcDownTeleNum;
            char    szHdlcDownTeleNo1[16];
            char    szHdlcDownTeleNo2[16];
            char    szHdlcDownTeleNo3[16];
            int     iFskBakTeleNum;
            char    szFskBakTeleNo1[16];
            char    szFskBakTeleNo2[16];
            char    szFskBakTeleNo3[16];
            int     iHdlcBakTeleNum;
            char    szHdlcBakTeleNo1[16];
            char    szHdlcBakTeleNo2[16];
            char    szHdlcBakTeleNo3[16];
        }tPsamPara;

        int iModuleId, iTransType;
        char    szPsamNo[17];
    EXEC SQL END DECLARE SECTION;

    char szBuf[512], szCheckVal[9], szKey[9], szRec[20];
    int i, j, iCurPos, iTotalRecNum, iLen, iTmpLen, iLenPos;

    strcpy( szPsamNo, ptAppStru->szPsamNo );

    //���ķ����ף������ж��Ƿ���comweb
    strcpy( ptAppStru->szAuthCode, "YES" );

    //�ն˷����ϴν��׽�������û����ն�&comweb
    if( memcmp( ptAppStru->szTransCode, "FF", 2 ) == 0 )
    {
        strcpy( ptAppStru->szAuthCode, "NO" );
        if( memcmp( ptAppStru->szHostRetCode, "00", 2 ) == 0 )
        {
            EXEC SQL UPDATE terminal
            set down_psam = 'N'
            WHERE psam_no = :szPsamNo;
            if( SQLCODE )
            {
                WriteLog( ERROR, "update down_term fail %d", SQLCODE );
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
    if( ptAppStru->iTransType == DOWN_ALL_PSAM )
    {
        WriteLog( TRACE, "begin down %s", ptAppStru->szTransName );
        iTransType = DOWN_ALL_PSAM;
        EXEC SQL UPDATE terminal
        set all_transtype = :iTransType, down_term = 'N'
        WHERE psam_no = :szPsamNo;
        if( SQLCODE )
        {
            WriteLog( ERROR, "update all_transtype fail %d", SQLCODE );
            strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
            RollbackTran();
            return FAIL;
        }
        CommitTran();
    }
    
    ptAppStru->iReservedLen = 0;

    iModuleId = ptAppStru->iPsamModule;

    EXEC SQL SELECT 
            MODULE_ID,
              NVL(DESCRIBE,' '),
              NVL(PIN_KEY_INDEX ,0) ,
              NVL(MAC_KEY_INDEX,0),
              NVL(FSK_TELE_NUM,0),
              NVL(FSK_TELE_NO1,' '),
              NVL(FSK_TELE_NO2,' '),
              NVL(FSK_TELE_NO3,' '),
              NVL(FSK_DOWN_TELE_NUM,0),
              NVL(FSK_DOWN_TELE_NO1,' '),
              NVL(FSK_DOWN_TELE_NO2,' '),
              NVL(FSK_DOWN_TELE_NO3,' '),
              NVL(HDLC_TELE_NUM,0),
              NVL(HDLC_TELE_NO1,' '),
              NVL(HDLC_TELE_NO2,' '),
              NVL(HDLC_TELE_NO3,' '),
              NVL(HDLC_DOWN_TELE_NUM,0),
              NVL(HDLC_DOWN_TELE_NO1,' '),
              NVL(HDLC_DOWN_TELE_NO2,' '),
              NVL(HDLC_DOWN_TELE_NO3,' '),
              NVL(FSKBAK_TELE_NUM,0),
              NVL(FSKBAK_TELE_NO1,' '),
              NVL(FSKBAK_TELE_NO2,' '),
              NVL(FSKBAK_TELE_NO3,' '),
              NVL(HDLCBAK_TELE_NUM,0) ,
              NVL(HDLCBAK_TELE_NO1,' ') ,
              NVL(HDLCBAK_TELE_NO2,' '),
              NVL(HDLCBAK_TELE_NO3,' ') 
    INTO 
            :tPsamPara.iModuleId,
            :tPsamPara.szDescribe,
            :tPsamPara.iPinKeyIndex,
            :tPsamPara.iMacKeyIndex,
            :tPsamPara.iFskTeleNum,
            :tPsamPara.szFskTeleNo1,
            :tPsamPara.szFskTeleNo2,
            :tPsamPara.szFskTeleNo3,
            :tPsamPara.iFskDownTeleNum,
            :tPsamPara.szFskDownTeleNo1,
            :tPsamPara.szFskDownTeleNo2,
            :tPsamPara.szFskDOwnTeleNo3,
            :tPsamPara.iHdlcTeleNum,
            :tPsamPara.szHdlcTeleNo1,
            :tPsamPara.szHdlcTeleNo2,
            :tPsamPara.szHdlcTeleNo3,
            :tPsamPara.iHdlcDownTeleNum,
            :tPsamPara.szHdlcDownTeleNo1,
            :tPsamPara.szHdlcDownTeleNo2,
            :tPsamPara.szHdlcDownTeleNo3,
            :tPsamPara.iFskBakTeleNum,
            :tPsamPara.szFskBakTeleNo1,
            :tPsamPara.szFskBakTeleNo2,
            :tPsamPara.szFskBakTeleNo3,
            :tPsamPara.iHdlcBakTeleNum,
            :tPsamPara.szHdlcBakTeleNo1,
            :tPsamPara.szHdlcBakTeleNo2,
            :tPsamPara.szHdlcBakTeleNo3
    FROM PSAM_PARA
    WHERE module_id = :iModuleId;
    if( SQLCODE == SQL_NO_RECORD )
    {
        strcpy( ptAppStru->szRetCode, ERR_PSAM_MODULE );
        WriteLog( ERROR, "psam_para [%ld] not exist", iModuleId );
        return FAIL;
    }
    else if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "SELECT psam_para fail %d", SQLCODE );
        return FAIL;
    }

    iCurPos = 0;
    iTotalRecNum = 0;
    strcpy( ptAppStru->szPan, "rec" );    
    for( i=1; i<=7; i++ )
    {
        /* 1-��ʾҪ���� 0-��ʾ��Ҫ���� */
        if( ptAppStru->szReserved[i-1] == '0' )
            continue;

        if( i <= 8 )
        {
            sprintf( szRec, " %d", i );
            strcat( ptAppStru->szPan, szRec );
        }
        
        szBuf[iCurPos] = i;    //PSAM���м�¼��
        iCurPos ++;
        switch (i){
        //��Կ����
        case 1:
            szBuf[iCurPos] = 2;    //���ݳ���
            iCurPos ++;
            szBuf[iCurPos] = tPsamPara.iPinKeyIndex;
            iCurPos ++;
            szBuf[iCurPos] = tPsamPara.iMacKeyIndex;
            iCurPos ++;
            iTotalRecNum ++;
            break;
        //FSKϵͳ����
        case 2:
            iLen = 0;
            iLenPos = iCurPos;    //��¼��������λ��
            szBuf[iCurPos] = iLen;    //���ݳ���(��ʱ��ֵ)
            iCurPos ++;
            szBuf[iCurPos] = tPsamPara.iFskTeleNum;    //�������    
            iCurPos ++;
            iLen ++;
            for( j=1; j<=tPsamPara.iFskTeleNum; j++ )
            {
                switch( j ){
                case 1:
                    DelTailSpace(tPsamPara.szFskTeleNo1);
                    iTmpLen = strlen(tPsamPara.szFskTeleNo1);
                    szBuf[iCurPos] = iTmpLen;
                    iCurPos ++;
                    iLen ++;
                    memcpy( szBuf+iCurPos, tPsamPara.szFskTeleNo1, iTmpLen );
                    iCurPos += iTmpLen;
                    iLen += iTmpLen;
                    break;
                case 2:
                    DelTailSpace(tPsamPara.szFskTeleNo2);
                    iTmpLen = strlen(tPsamPara.szFskTeleNo2);
                    szBuf[iCurPos] = iTmpLen;
                    iCurPos ++;
                    iLen ++;
                    memcpy( szBuf+iCurPos, tPsamPara.szFskTeleNo2, iTmpLen );
                    iCurPos += iTmpLen;
                    iLen += iTmpLen;
                    break;
                case 3:
                    DelTailSpace(tPsamPara.szFskTeleNo3);
                    iTmpLen = strlen(tPsamPara.szFskTeleNo3);
                    szBuf[iCurPos] = iTmpLen;
                    iCurPos ++;
                    iLen ++;
                    memcpy( szBuf+iCurPos, tPsamPara.szFskTeleNo3, iTmpLen );
                    iCurPos += iTmpLen;
                    iLen += iTmpLen;
                    break;
                }
            }
            szBuf[iLenPos] = iLen;    //���ݳ���(���ո�ֵ)
            iTotalRecNum ++;
            break;
        //FSK����ϵͳ����
        case 3:
            iLen = 0;
            iLenPos = iCurPos;    //��¼��������λ��
            szBuf[iCurPos] = iLen;    //���ݳ���(��ʱ��ֵ)
            iCurPos ++;
            szBuf[iCurPos] = tPsamPara.iFskDownTeleNum;    //�������    
            iCurPos ++;
            iLen ++;
            for( j=1; j<=tPsamPara.iFskDownTeleNum; j++ )
            {
                switch( j ){
                case 1:
                    DelTailSpace(tPsamPara.szFskDownTeleNo1);
                    iTmpLen = strlen(tPsamPara.szFskDownTeleNo1);
                    szBuf[iCurPos] = iTmpLen;
                    iCurPos ++;
                    iLen ++;
                    memcpy( szBuf+iCurPos, tPsamPara.szFskDownTeleNo1, iTmpLen );
                    iCurPos += iTmpLen;
                    iLen += iTmpLen;
                    break;
                case 2:
                    DelTailSpace(tPsamPara.szFskDownTeleNo2);
                    iTmpLen = strlen(tPsamPara.szFskDownTeleNo2);
                    szBuf[iCurPos] = iTmpLen;
                    iCurPos ++;
                    iLen ++;
                    memcpy( szBuf+iCurPos, tPsamPara.szFskDownTeleNo2, iTmpLen );
                    iCurPos += iTmpLen;
                    iLen += iTmpLen;
                    break;
                case 3:
                    DelTailSpace(tPsamPara.szFskDOwnTeleNo3);
                    iTmpLen = strlen(tPsamPara.szFskDOwnTeleNo3);
                    szBuf[iCurPos] = iTmpLen;
                    iCurPos ++;
                    iLen ++;
                    memcpy( szBuf+iCurPos, tPsamPara.szFskDOwnTeleNo3, iTmpLen );
                    iCurPos += iTmpLen;
                    iLen += iTmpLen;
                    break;
                }
            }
            szBuf[iLenPos] = iLen;    //���ݳ���(���ո�ֵ)
            iTotalRecNum ++;
            break;
        //HDLCϵͳ����
        case 4:
            iLen = 0;
            iLenPos = iCurPos;    //��¼��������λ��
            szBuf[iCurPos] = iLen;    //���ݳ���(��ʱ��ֵ)
            iCurPos ++;
            szBuf[iCurPos] = tPsamPara.iHdlcTeleNum;    //�������    
            iCurPos ++;
            iLen ++;
            for( j=1; j<=tPsamPara.iHdlcTeleNum; j++ )
            {
                switch( j ){
                case 1:
                    DelTailSpace(tPsamPara.szHdlcTeleNo1);
                    iTmpLen = strlen(tPsamPara.szHdlcTeleNo1);
                    szBuf[iCurPos] = iTmpLen;
                    iCurPos ++;
                    iLen ++;
                    memcpy( szBuf+iCurPos, tPsamPara.szHdlcTeleNo1, iTmpLen );
                    iCurPos += iTmpLen;
                    iLen += iTmpLen;
                    break;
                case 2:
                    DelTailSpace(tPsamPara.szHdlcTeleNo2);
                    iTmpLen = strlen(tPsamPara.szHdlcTeleNo2);
                    szBuf[iCurPos] = iTmpLen;
                    iCurPos ++;
                    iLen ++;
                    memcpy( szBuf+iCurPos, tPsamPara.szHdlcTeleNo2, iTmpLen );
                    iCurPos += iTmpLen;
                    iLen += iTmpLen;
                    break;
                case 3:
                    DelTailSpace(tPsamPara.szHdlcTeleNo3);
                    iTmpLen = strlen(tPsamPara.szHdlcTeleNo3);
                    szBuf[iCurPos] = iTmpLen;
                    iCurPos ++;
                    iLen ++;
                    memcpy( szBuf+iCurPos, tPsamPara.szHdlcTeleNo3, iTmpLen );
                    iCurPos += iTmpLen;
                    iLen += iTmpLen;
                    break;
                }
            }
            szBuf[iLenPos] = iLen;    //���ݳ���(���ո�ֵ)
            iTotalRecNum ++;
            break;
        //HDLC����ϵͳ����
        case 5:
            iLen = 0;
            iLenPos = iCurPos;    //��¼��������λ��
            szBuf[iCurPos] = iLen;    //���ݳ���(��ʱ��ֵ)
            iCurPos ++;
            szBuf[iCurPos] = tPsamPara.iHdlcDownTeleNum;    //�������    
            iCurPos ++;
            iLen ++;
            for( j=1; j<=tPsamPara.iHdlcDownTeleNum; j++ )
            {
                switch( j ){
                case 1:
                    DelTailSpace(tPsamPara.szHdlcDownTeleNo1);
                    iTmpLen = strlen(tPsamPara.szHdlcDownTeleNo1);
                    szBuf[iCurPos] = iTmpLen;
                    iCurPos ++;
                    iLen ++;
                    memcpy( szBuf+iCurPos, tPsamPara.szHdlcDownTeleNo1, iTmpLen );
                    iCurPos += iTmpLen;
                    iLen += iTmpLen;
                    break;
                case 2:
                    DelTailSpace(tPsamPara.szHdlcDownTeleNo2);
                    iTmpLen = strlen(tPsamPara.szHdlcDownTeleNo2);
                    szBuf[iCurPos] = iTmpLen;
                    iCurPos ++;
                    iLen ++;
                    memcpy( szBuf+iCurPos, tPsamPara.szHdlcDownTeleNo2, iTmpLen );
                    iCurPos += iTmpLen;
                    iLen += iTmpLen;
                    break;
                case 3:
                    DelTailSpace(tPsamPara.szHdlcDownTeleNo3);
                    iTmpLen = strlen(tPsamPara.szHdlcDownTeleNo3);
                    szBuf[iCurPos] = iTmpLen;
                    iCurPos ++;
                    iLen ++;
                    memcpy( szBuf+iCurPos, tPsamPara.szHdlcDownTeleNo3, iTmpLen );
                    iCurPos += iTmpLen;
                    iLen += iTmpLen;
                    break;
                }
            }
            szBuf[iLenPos] = iLen;    //���ݳ���(���ո�ֵ)
            iTotalRecNum ++;
            break;
        //FSK����ϵͳ����
        case 6:
            iLen = 0;
            iLenPos = iCurPos;    //��¼��������λ��
            szBuf[iCurPos] = iLen;    //���ݳ���(��ʱ��ֵ)
            iCurPos ++;
            szBuf[iCurPos] = tPsamPara.iFskBakTeleNum;    //�������    
            iCurPos ++;
            iLen ++;
            for( j=1; j<=tPsamPara.iFskBakTeleNum; j++ )
            {
                switch( j ){
                case 1:
                    DelTailSpace(tPsamPara.szFskBakTeleNo1);
                    iTmpLen = strlen(tPsamPara.szFskBakTeleNo1);
                    szBuf[iCurPos] = iTmpLen;
                    iCurPos ++;
                    iLen ++;
                    memcpy( szBuf+iCurPos, tPsamPara.szFskBakTeleNo1, iTmpLen );
                    iCurPos += iTmpLen;
                    iLen += iTmpLen;
                    break;
                case 2:
                    DelTailSpace(tPsamPara.szFskBakTeleNo2);
                    iTmpLen = strlen(tPsamPara.szFskBakTeleNo2);
                    szBuf[iCurPos] = iTmpLen;
                    iCurPos ++;
                    iLen ++;
                    memcpy( szBuf+iCurPos, tPsamPara.szFskBakTeleNo2, iTmpLen );
                    iCurPos += iTmpLen;
                    iLen += iTmpLen;
                    break;
                case 3:
                    DelTailSpace(tPsamPara.szFskBakTeleNo3);
                    iTmpLen = strlen(tPsamPara.szFskBakTeleNo3);
                    szBuf[iCurPos] = iTmpLen;
                    iCurPos ++;
                    iLen ++;
                    memcpy( szBuf+iCurPos, tPsamPara.szFskBakTeleNo3, iTmpLen );
                    iCurPos += iTmpLen;
                    iLen += iTmpLen;
                    break;
                }
            }
            szBuf[iLenPos] = iLen;    //���ݳ���(���ո�ֵ)
            iTotalRecNum ++;
            break;
        //HDLC����ϵͳ����
        case 7:
            iLen = 0;
            iLenPos = iCurPos;    //��¼��������λ��
            szBuf[iCurPos] = iLen;    //���ݳ���(��ʱ��ֵ)
            iCurPos ++;
            szBuf[iCurPos] = tPsamPara.iHdlcBakTeleNum;    //�������    
            iCurPos ++;
            iLen ++;
            for( j=1; j<=tPsamPara.iHdlcBakTeleNum; j++ )
            {
                switch( j ){
                case 1:
                    DelTailSpace(tPsamPara.szHdlcBakTeleNo1);
                    iTmpLen = strlen(tPsamPara.szHdlcBakTeleNo1);
                    szBuf[iCurPos] = iTmpLen;
                    iCurPos ++;
                    iLen ++;
                    memcpy( szBuf+iCurPos, tPsamPara.szHdlcBakTeleNo1, iTmpLen );
                    iCurPos += iTmpLen;
                    iLen += iTmpLen;
                    break;
                case 2:
                    DelTailSpace(tPsamPara.szHdlcBakTeleNo2);
                    iTmpLen = strlen(tPsamPara.szHdlcBakTeleNo2);
                    szBuf[iCurPos] = iTmpLen;
                    iCurPos ++;
                    iLen ++;
                    memcpy( szBuf+iCurPos, tPsamPara.szHdlcBakTeleNo2, iTmpLen );
                    iCurPos += iTmpLen;
                    iLen += iTmpLen;
                    break;
                case 3:
                    DelTailSpace(tPsamPara.szHdlcBakTeleNo3);
                    iTmpLen = strlen(tPsamPara.szHdlcBakTeleNo3);
                    szBuf[iCurPos] = iTmpLen;
                    iCurPos ++;
                    iLen ++;
                    memcpy( szBuf+iCurPos, tPsamPara.szHdlcBakTeleNo3, iTmpLen );
                    iCurPos += iTmpLen;
                    iLen += iTmpLen;
                    break;
                }
            }
            szBuf[iLenPos] = iLen;    //���ݳ���(���ո�ֵ)
            iTotalRecNum ++;
            break;
        }
    }

    if( (iCurPos+1) > 255 )
    {
        WriteLog( ERROR, "����̫��[%d]", iCurPos+1 );
        strcpy( ptAppStru->szRetCode, ERR_DATA_TOO_LONG );
        return FAIL;
    }

    if( ptAppStru->iTransType == DOWN_ALL_TERM )
    {
        //��Ҫ���к������أ�����comweb
        strcpy( ptAppStru->szAuthCode, "NO" );
    }
    else
    {
        strcpy( ptAppStru->szNextTransCode, "FF" );
        memcpy( ptAppStru->szNextTransCode+2, ptAppStru->szTransCode+2, 6 );
        ptAppStru->szNextTransCode[8] = 0;
    }

    ptAppStru->iReservedLen = iCurPos+1;    
    ptAppStru->szReserved[0] = iTotalRecNum;    //��¼����
    memcpy( ptAppStru->szReserved+1, szBuf, iCurPos );

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}

