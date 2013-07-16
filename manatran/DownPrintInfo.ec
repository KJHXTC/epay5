
/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:�ն������ཻ��

** �����б�:
** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.3 $
$Log: DownPrintInfo.ec,v $
Revision 1.3  2013/01/24 07:41:31  wukj
QLCODE��ӡ��ʽ�޸�Ϊ%d

Revision 1.2  2012/12/25 08:31:18  wukj
*** empty log message ***

Revision 1.1  2012/12/18 10:04:56  wukj
*** empty log message ***

*******************************************************************/

# include "manatran.h"

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL EnD DECLARE SECTION;
#endif
extern int gnPrintNum;

/*****************************************************************
** ��    ��:��ӡ��Ϣ����
** �������:
           ptAppStru
** �������:
           ptAppStru->szReserved        ��ӡ��Ϣ
           ptAppStru->iReservedLen    ��ӡ��Ϣ����
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
int DownPrintInfo( ptAppStru, iDownloadNew ) 
T_App    *ptAppStru;
int    iDownloadNew;
{
    EXEC SQL BEGIN DECLARE SECTION;
        
        struct T_PRINT_INFO {
             int     iRecNo;
             char    szInfo[61];
             int     iDataIndex;
             char    szUpdateDate[9];
        }tPrintInfo;
        char    szPsamNo[17], szUpdateDate[9];
        int    iBeginRecNo, iTransType;
        int    iMaxRecNo, iNeedDownMax;
    EXEC SQL END DECLARE SECTION;

    char szBuf[512], szData[512];
    int i, iCurPos, iTotalRecNum, iLastIndex, iCmdLen, iDataLen;
    int iPreCmdLen, iPreCmdNum, iRet;
    char szPreCmd[512], szFlag[2];

    strcpy( szPsamNo, ptAppStru->szPsamNo );

    //���ķ����ף������ж��Ƿ���comweb
    strcpy( ptAppStru->szAuthCode, "YES" );

    //�ն˷������һ�������׽�������û����ն�&comweb
    if( memcmp( ptAppStru->szTransCode, "FF", 2 ) == 0 )
    {
        strcpy( ptAppStru->szAuthCode, "NO" );
        if( memcmp( ptAppStru->szHostRetCode, "00", 2 ) == 0 )
        {
            EXEC SQL UPDATE terminal
            set down_print = 'N', print_recno = 0
            WHERE psam_no = :szPsamNo;
            if( SQLCODE )
            {
                WriteLog( ERROR, "update down_print fail %d", SQLCODE );
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
    if( ptAppStru->iTransType == DOWN_ALL_PRINT &&
            memcmp( ptAppStru->szTransCode, "00", 2 ) == 0 )
    {
        WriteLog( TRACE, "begin down %s", ptAppStru->szTransName );
        iTransType = DOWN_ALL_PRINT;

        //�и��½��&trans_codeǰ��λΪ00��������ӡ��¼���ظտ�ʼ��
        //����ʼ��¼Ϊ0
        if( memcmp(ptAppStru->szHostRetCode, "NN", 2) != 0 )
        {
            EXEC SQL UPDATE terminal
            set all_transtype = :iTransType, print_recno = 0,
                down_menu = 'N', menu_recno = 0
            WHERE psam_no = :szPsamNo;
        }
        //�޸��½��&trans_codeǰ��λΪ00�������Ǵ�ӡ��¼���صĶϵ�
        //����������Ҫ������ʼ��¼��
        else
        {
            EXEC SQL UPDATE terminal
            set all_transtype = :iTransType
            WHERE psam_no = :szPsamNo;
        }

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

    for( i=254; i>=0; i-- )
    {
        if( ptAppStru->szReserved[i] == '1' )
        {
            iNeedDownMax = i+1;
            break;
        }
    }

    //�׸����ذ�����Ҫ����user_code2�ж��Ƕϵ�������������������
    if( memcmp( ptAppStru->szTransCode, "00", 2 ) == 0 )
    {
        //�ϵ�����
        if( ptAppStru->szControlCode[1] == '1' )
        {
WriteLog( TRACE, "%s �ϵ�����", ptAppStru->szTransName );
            EXEC SQL SELECT NVL(print_recno,0) INTO :iBeginRecNo
            FROM terminal
            WHERE psam_no = :szPsamNo;
            if( SQLCODE == SQL_NO_RECORD )
            {
                strcpy( ptAppStru->szRetCode, ERR_INVALID_TERM );
                WriteLog( ERROR, "term[%s] not exist", szPsamNo );
                return FAIL;
            }
            else if( SQLCODE )
            {
                strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
                WriteLog( ERROR, "sel print_recno fail %d", SQLCODE );
                return FAIL;
            }
        }
        /* �������� */
        else
        {
            iBeginRecNo = 0;
        }
    }
    else
    {
        AscToBcd( (uchar*)(ptAppStru->szTransCode), 2, 0 , (uchar*)szBuf);
        szBuf[1] = 0;
        iBeginRecNo = (uchar)szBuf[0];

        //�ն˸��³ɹ������������ؼ�¼��
        if( memcmp(ptAppStru->szHostRetCode, "00", 2) == 0 )
        {
            EXEC SQL UPDATE terminal 
            set print_recno = :iBeginRecNo
            WHERE psam_no = :szPsamNo;
            if( SQLCODE )
            {
                WriteLog( ERROR, "update print_recno fail %d", SQLCODE );
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

    /* �ն�ѡ�������ط�ʽ�����ն�ѡ��Ϊ׼��������ƽ̨����Ϊ׼ */
    if( ptAppStru->szControlCode[0] == '1' )
    {
        iDownloadNew = 1;
    }
    else if( ptAppStru->szControlCode[0] == '0' )
    {
        iDownloadNew = 0;
    }

    /* ��������������Զ���������أ���λͼ�������صĲ�����������ȫ���� */
    if( ptAppStru->iTransType == CENDOWN_PRINT_INFO || ptAppStru->iTransType == AUTODOWN_PRINT_INFO )
    {
        iDownloadNew = 0;
    }

    //��������
    if( iDownloadNew == 1 )
    {
        /* ֻ��Ҫ����Ӧ�ð汾��֮������� */
        BcdToAsc( (uchar *)(ptAppStru->szAppVer), 8, 0 ,(uchar *)szUpdateDate);
        szUpdateDate[8] = 0;
    }
    //��ȫ����
    else
    {
        strcpy( szUpdateDate, "20000101" );
    }

    /*ȡ���¼�ţ������ж��Ƿ���Ҫ֪ͨ
      �ն˽��к������أ��������ն˵���һ������*/
    EXEC SQL SELECT max(rec_no) INTO :iMaxRecNo
    FROM print_info;
    if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "count print_cur fail %d", SQLCODE );
        return FAIL;
    }

    if( iMaxRecNo < iNeedDownMax )
    {
        iNeedDownMax = iMaxRecNo;
    }

    EXEC SQL DECLARE print_cur cursor for
    SELECT
        REC_NO,
        NVL(INFO, ' '),
        NVL(DATA_INDEX, 1),
        NVL(UPDATE_DATE,'20080101')        
    FROM print_info
    WHERE rec_no > :iBeginRecNo and
         (update_date >= :szUpdateDate or rec_no = :iNeedDownMax)
    ORDER BY rec_no;
    if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "delare print_cur fail %d", SQLCODE );
        return FAIL;
    }

    EXEC SQL OPEN print_cur;
    if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "open print_cur fail %d", SQLCODE );
        EXEC SQL CLOSE print_cur;
        return FAIL;
    }

    iTotalRecNum = 0;
    iDataLen = 0;
    while(1)
    {
        EXEC SQL FETCH print_cur 
        INTO 
        :tPrintInfo.iRecNo,
        :tPrintInfo.szInfo,
        :tPrintInfo.iDataIndex,
        :tPrintInfo.szUpdateDate;
        if( SQLCODE == SQL_NO_RECORD )
        {
            EXEC SQL CLOSE print_cur;
            break;
        }
        else if( SQLCODE )
        {
            strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
            WriteLog( ERROR, "fetch print_cur fail %d", SQLCODE );
            EXEC SQL CLOSE print_cur;
            return FAIL;
        }

        /* �ﵽÿ�������������� */
        if( iTotalRecNum >= gnPrintNum )
        {
            EXEC SQL CLOSE print_cur;
            break;
        }

        //������¼��������
        if( tPrintInfo.iRecNo > iNeedDownMax )
        {
            EXEC SQL CLOSE print_cur;
            break;
        }

        //������¼����Ҫ����
        if( ptAppStru->szReserved[tPrintInfo.iRecNo-1] == '0' && tPrintInfo.iRecNo != iNeedDownMax )
        {
            continue;
        }

        iCurPos = 0;
        DelTailSpace( tPrintInfo.szInfo );
        szBuf[iCurPos] = tPrintInfo.iRecNo;
        iCurPos ++;

        /* ���з� */
        if( tPrintInfo.iRecNo == PRINT_ENTER )
        {
            szBuf[iCurPos] = 1;
            iCurPos ++;
            memcpy( szBuf+iCurPos, "\x0A", 1 );
            iCurPos += 1;
        }
        /* �հ� */
        else if( tPrintInfo.iRecNo == PRINT_BLANK )
        {
            szBuf[iCurPos] = 0;
            iCurPos ++;
        }
        else
        {
            szBuf[iCurPos] = strlen(tPrintInfo.szInfo);
            iCurPos ++;
            memcpy( szBuf+iCurPos, tPrintInfo.szInfo, strlen(tPrintInfo.szInfo) );
            iCurPos += strlen(tPrintInfo.szInfo);
        }

        if( (iDataLen+iCurPos+1) <= 255 )
        {
            memcpy( szData+iDataLen, szBuf, iCurPos );
            iDataLen += iCurPos;
            iLastIndex = tPrintInfo.iRecNo;
            iTotalRecNum ++;
        }
        else
        {
            EXEC SQL CLOSE print_cur;
            break;
        }
    }

    ptAppStru->iReservedLen = iDataLen+1;    
    ptAppStru->szReserved[0] = iTotalRecNum;
    memcpy( ptAppStru->szReserved+1, szData, iDataLen );
    sprintf( ptAppStru->szPan, "����%03d-%03d / %03d", iBeginRecNo+1, iLastIndex, iNeedDownMax );

    /* ��Ҫ���к������� */
    if( iLastIndex < iNeedDownMax )
    {
        //�������״���ǰ2λ��ʾ�����ؼ�¼����¼�ţ���6λΪ��ǰ����
        //�����6λ
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
            memcpy( ptAppStru->szCommand+iCmdLen, "\xAF", 1 );    
            iCmdLen += 1;
            ptAppStru->iCommandNum ++;
        }
        memcpy( ptAppStru->szCommand+iCmdLen, "\x1C\xFF", 2 );//���´�ӡ��¼
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
        if( ptAppStru->iTransType == DOWN_ALL_PRINT )
        {
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
    }

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}

