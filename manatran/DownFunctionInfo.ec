
/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:�ն������ཻ��

** �����б�:
** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.3 $
$Log: DownFunctionInfo.ec,v $
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

/*****************************************************************
** ��    ��:������ʾ��Ϣ����
** �������:
           ptAppStru
** �������:
           ptAppStru->szReserved        ������ʾ��Ϣ
           ptAppStru->iReservedLen    ������ʾ��Ϣ����
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
int DownFunctionInfo( ptAppStru, iDownloadNew ) 
T_App    *ptAppStru;
int iDownloadNew;
{
    EXEC SQL BEGIN DECLARE SECTION;
        
        struct T_FUNCTION_INFO {
            int     iFuncIndex;
            char    szOpFlag[2];
            int     iModuleNum;
            char    szInfo1Format[3];
            char    szInfo1[101];
            char    szInfo2Format[3];
            char    szInfo2[101];
            char    szInfo3Format[3];
            char    szInfo3[101];
            char    szUpdatedate[9];
        }tFunInfo;
        struct T_APP_DEF {
            int     iAppType;
            char    szAppName[21];
            char    szAppDescribe[31];
            char    szAppVer[9];
        }tAppDef;

        int    iBeginRecNo, iAppType, iCurRecNo;
        char    szPsamNo[17], szUpdateDate[9];
        int    iMaxRecNo, iTransType, iNeedDownMax;
    EXEC SQL END DECLARE SECTION;

    char szBuf[512], szData[512];
    int i, iCmdLen, iLastIndex, iDataLen;
    int iCurPos, iTotalRecNum, iModuNum, iInfo1Len, iInfo2Len, iInfo3Len;
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
            set down_function = 'N', function_recno = 0
            WHERE psam_no = :szPsamNo;
            if( SQLCODE )
            {
                WriteLog( ERROR, "update down_function fail %d", SQLCODE );
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
    if( ptAppStru->iTransType == DOWN_ALL_FUNCTION &&
        memcmp( ptAppStru->szTransCode, "00", 2 ) == 0 )
    {
        WriteLog( TRACE, "begin down %s", ptAppStru->szTransName );
        iTransType = DOWN_ALL_FUNCTION;

        //�и��½��&trans_codeǰ��λΪ00������������ʾ���ظտ�ʼ��
        //����ʼ��¼Ϊ0
        if( memcmp(ptAppStru->szHostRetCode, "NN", 2) != 0 )
        {
            EXEC SQL UPDATE terminal
            set all_transtype = :iTransType, function_recno = 0,
                down_operate = 'N', operate_recno = 0
            WHERE psam_no = :szPsamNo;
        }
        //�޸��½��&trans_codeǰ��λΪ00�������ǹ�����ʾ���صĶϵ�
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

    for( i=254; i>=0; i-- )
    {
        if( ptAppStru->szReserved[i] == '1' )
        {
            iNeedDownMax = i+1;
            break;
        }
    }

    EXEC SQL SELECT app_type, NVL(function_recno,0) INTO :iAppType, :iCurRecNo
    FROM terminal
    WHERE psam_no = :szPsamNo;
    if( SQLCODE == SQL_NO_RECORD )
    {
        strcpy( ptAppStru->szRetCode, ERR_INVALID_TERM );
        WriteLog( ERROR, "term[%s] iot exist", szPsamNo );
        return FAIL;
    }
    else if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "get app_type fail %d", SQLCODE );
        return FAIL;
    }
    EXEC SQL SELECT 
        APP_TYPE,
        NVL(APP_NAME,' '),
        NVL(DESCRIBE, ' '),
        NVL(APP_VER, ' ')
    INTO 
        :tAppDef.iAppType,
        :tAppDef.szAppName,
        :tAppDef.szAppDescribe,
        :tAppDef.szAppVer
    FROM app_def
    WHERE app_type = :iAppType;
    if( SQLCODE == SQL_NO_RECORD )
    {
        strcpy( ptAppStru->szRetCode, ERR_INVALID_APP );
        WriteLog( ERROR, "term[%s] app[%d] not exist", szPsamNo, iAppType );
        return FAIL;
    }
    else if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "count app_menu fail %d", SQLCODE );
        return FAIL;
    }

    //�׸����ذ�����Ҫ����control_code�ж��Ƕϵ�������������������
    if( memcmp( ptAppStru->szTransCode, "00", 2 ) == 0 )
    {
        //�ϵ�����
        if( ptAppStru->szControlCode[1] == '1' )
        {
WriteLog( TRACE, "%s �ϵ�����", ptAppStru->szTransName );
            iBeginRecNo = iCurRecNo;
        }
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
            set function_recno = :iBeginRecNo
            WHERE psam_no = :szPsamNo;
            if( SQLCODE )
            {
                WriteLog( ERROR, "update function_recno fail %d", SQLCODE );
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
    if( ptAppStru->iTransType == CENDOWN_FUNCTION_INFO || ptAppStru->iTransType == AUTODOWN_FUNCTION_INFO )
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

    /*ȡ����¼�ţ������ж��Ƿ���Ҫ֪ͨ
      �ն˽��к������أ��������ն˵���һ������*/
    EXEC SQL SELECT max(func_index) INTO :iMaxRecNo
    FROM function_info;
    if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "count function_info fail %d", SQLCODE );
        return FAIL;
    }

    if( iMaxRecNo < iNeedDownMax )
    {
        iNeedDownMax = iMaxRecNo;
    }

    ptAppStru->iReservedLen = 0;
    
    EXEC SQL DECLARE fun_cur cursor for
    SELECT  
        FUNC_INDEX,
        OP_FLAG,
        MODULE_NUM,
        NVL(INFO1_FORMAT,' '),
        NVL(INFO1, ' '),
        NVL(INFO2_FORMAT,' '),
        NVL(INFO2, ' '),
        NVL(INFO3_FORMAT,' '),
        NVL(INFO3, ' '),
        NVL(UPDATE_DATE,' ')
    FROM function_info
    WHERE func_index > :iBeginRecNo and
              (update_date >= :szUpdateDate or func_index = :iNeedDownMax)
    ORDER BY func_index;
    if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "delare fun_cur fail %d", SQLCODE );
        return FAIL;
    }

    EXEC SQL OPEN fun_cur;
    if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "open fun_cur fail %d", SQLCODE );
        EXEC SQL CLOSE fun_cur;
        return FAIL;
    }

    iTotalRecNum = 0;
    iDataLen = 0;
    while(1)
    {
        EXEC SQL FETCH fun_cur 
        INTO 
            :tFunInfo.iFuncIndex,
            :tFunInfo.szOpFlag,
            :tFunInfo.iModuleNum,
            :tFunInfo.szInfo1Format,
            :tFunInfo.szInfo1,
            :tFunInfo.szInfo2Format,
            :tFunInfo.szInfo2,
            :tFunInfo.szInfo3Format,
            :tFunInfo.szInfo3;
        if( SQLCODE == SQL_NO_RECORD )
        {
            EXEC SQL CLOSE fun_cur;
            break;
        }
        else if( SQLCODE )
        {
            strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
            WriteLog( ERROR, "fetch fun_cur fail %d", SQLCODE );
            EXEC SQL CLOSE fun_cur;
            return FAIL;
        }

        //������¼��������
        if( tFunInfo.iFuncIndex > iNeedDownMax )
        {
            EXEC SQL CLOSE fun_cur;
            break;
        }

        //������¼����Ҫ����
        if( ptAppStru->szReserved[tFunInfo.iFuncIndex-1] == '0' && tFunInfo.iFuncIndex != iNeedDownMax )
        {
            continue;
        }

        DelTailSpace( tFunInfo.szInfo1 );
        DelTailSpace( tFunInfo.szInfo2 );
        DelTailSpace( tFunInfo.szInfo3 );

        iInfo1Len = strlen( tFunInfo.szInfo1 );
        iInfo2Len = strlen( tFunInfo.szInfo2 );
        iInfo3Len = strlen( tFunInfo.szInfo3 );

        iModuNum = 0;
        if( memcmp( tFunInfo.szInfo1Format, "FF", 2 ) != 0 )
        {
            iModuNum ++;
        }
        if( memcmp( tFunInfo.szInfo2Format, "FF", 2 ) != 0 )
        {
            iModuNum ++;
        }
        if( memcmp( tFunInfo.szInfo3Format, "FF", 2 ) != 0 )
        {
            iModuNum ++;
        }

        iCurPos = 0;
        //��ʾ��Ϣ����
        szBuf[iCurPos] = tFunInfo.iFuncIndex;
        iCurPos ++;
        //��Ϣ������ʶ
        szBuf[iCurPos] = tFunInfo.szOpFlag[0];
        iCurPos ++;
        //��Ϣ���ݳ���
        szBuf[iCurPos] = iInfo1Len + iInfo2Len+iInfo3Len+iModuNum*2+1;
        iCurPos ++;
        //ģ����
        szBuf[iCurPos] = iModuNum;
        iCurPos ++;
        
        //ģ��1����
        if( memcmp( tFunInfo.szInfo1Format, "FF", 2 ) != 0 )
        {
            //��ʾ��ʽ
            AscToBcd((uchar*)tFunInfo.szInfo1Format, 2, 0, (uchar*)szBuf+iCurPos);
            iCurPos ++;
            //���ݳ���
            szBuf[iCurPos] = iInfo1Len;
            iCurPos ++;

            if( iInfo1Len > 0 )
            {
                memcpy(szBuf+iCurPos, tFunInfo.szInfo1, iInfo1Len);
                iCurPos += iInfo1Len;
            }
        }

        //ģ��2����
        if( memcmp( tFunInfo.szInfo2Format, "FF", 2 ) != 0 )
        {
            //��ʾ��ʽ
            AscToBcd((uchar*)tFunInfo.szInfo2Format, 2, 0,(uchar*)szBuf+iCurPos);
            iCurPos ++;
            //���ݳ���
            szBuf[iCurPos] = iInfo2Len;
            iCurPos ++;

            if( iInfo2Len > 0 )
            {
                memcpy(szBuf+iCurPos, tFunInfo.szInfo2, iInfo2Len);
                iCurPos += iInfo2Len;
            }
        }

        //ģ��3����
        if( memcmp( tFunInfo.szInfo3Format, "FF", 2 ) != 0 )
        {
            //��ʾ��ʽ
            AscToBcd((uchar*)tFunInfo.szInfo3Format, 2, 0,(uchar*)szBuf+iCurPos);
            iCurPos ++;
            //���ݳ���
            szBuf[iCurPos] = iInfo3Len;
            iCurPos ++;

            if( iInfo3Len > 0 )
            {
                memcpy(szBuf+iCurPos, tFunInfo.szInfo3, iInfo3Len);
                iCurPos += iInfo3Len;
            }
        }

        if( (iDataLen+iCurPos+5) <= 255 )
        {
            memcpy( szData+iDataLen, szBuf, iCurPos );
            iDataLen += iCurPos;
            iLastIndex = tFunInfo.iFuncIndex;
            iTotalRecNum ++;
        }
        else
        {
            EXEC SQL CLOSE fun_cur;
            break;
        }
    }

    //Ӧ�ð汾�Ÿ�ԭֵ����Ϊ���һ�������¸�ֵΪtAppDef.app_ver
    memcpy( ptAppStru->szReserved, ptAppStru->szAppVer, 4 ); 

    ptAppStru->szReserved[4] = iTotalRecNum;
    memcpy( ptAppStru->szReserved+5, szData, iDataLen );
    ptAppStru->iReservedLen = iDataLen+5;    
    sprintf( ptAppStru->szPan, "����%03d-%03d / %03d", iBeginRecNo+1, iLastIndex, iNeedDownMax );

    /* ��Ҫ���к������� */
    if( iLastIndex < iNeedDownMax )
    {
        //�������״���ǰ2λ��ʾ�����ؼ�¼����¼�ţ���6λΪ��ǰ����
        //�����6λ
        szBuf[0] = iLastIndex;
        szBuf[1] = 0;
        BcdToAsc( (uchar*)szBuf, 2, 0 , (uchar*)(ptAppStru->szNextTransCode));
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
        memcpy( ptAppStru->szCommand+iCmdLen, "\x19\xFF", 2 );//���¹�����ʾ
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

        //��Ҫ�������أ�����comweb
        strcpy( ptAppStru->szAuthCode, "NO" );
    }
    else
    {
        /* Ӧ�ð汾�ţ����һ�������¸�ֵΪtAppDef.szAppVer
        ����ֵ�����²˵����ٸ�ֵ
        AscToBcd( (uchar*)tAppDef.szAppVer, 8, 0 ,(uchar*)(ptAppStru->szReserved)); 
        */

        if( ptAppStru->iTransType == DOWN_ALL_FUNCTION )
        {
            //��Ҫ�������أ�����comweb
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

