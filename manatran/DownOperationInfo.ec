
/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:�ն������ཻ��

** �����б�:
** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.2 $
$Log: DownOperationInfo.ec,v $
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
** ��    ��: ������Ϣ����
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
int  DownOperationInfo( ptAppStru, iDownloadNew ) 
T_App    *ptAppStru;
int iDownloadNew;
{
    EXEC SQL BEGIN DECLARE SECTION;
        
        struct T_OPERATION_INFO {
            int     iOperIndex;
            char    szOpFlag[2];
            int     iModuleNum;
            char    szInfo1Format[3];
            char    szInfo1[41];
            char    szInfo2Format[3];
            char    szInfo2[41];
            char    szInfo3Format[3];
            char    szInfo3[41];
            char    szUpdateDate[9];
        }tOperationInfo;
        char    szPsamNo[17], szUpdateDate[9];
        int    iBeginRecNo;
        int    iMaxRecNo, iTransType, iNeedDownMax;
    EXEC SQL END DECLARE SECTION;

    char szBuf[2048], szData[2048];
    int i, iCmdLen, iDataLen, iRet, iLastIndex;
    int iCurPos, iTotalRecNum, iModuNum, iInfo1Len, iInfo2Len, iInfo3Len;

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
            set down_operate = 'N', operate_recno = 0
            WHERE psam_no = :szPsamNo;
            if( SQLCODE )
            {
                WriteLog( ERROR, "update down_operate fail %d", SQLCODE );
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
    if( ( ptAppStru->iTransType == CENDOWN_ALL_OPERATION ||
          ptAppStru->iTransType == AUTODOWN_ALL_OPERATION ||
          ptAppStru->iTransType == DOWN_ALL_OPERATION ) &&
        memcmp( ptAppStru->szTransCode, "00", 2 ) == 0 )
    {
        iTransType = DOWN_ALL_OPERATION;

        EXEC SQL UPDATE terminal
        set all_transtype = :iTransType
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

    for( i=254; i>=0; i-- )
    {
        if( ptAppStru->szReserved[i] == '1' )
        {
            iNeedDownMax = i+1;
            break;
        }
    }

    //�׸����ذ�����Ҫ����control_code�ж��Ƕϵ�������������������
    if( memcmp( ptAppStru->szTransCode, "00", 2 ) == 0 )
    {
        //�ϵ�����
        if( ptAppStru->szControlCode[1] == '1' )
        {
WriteLog( TRACE, "%s �ϵ�����", ptAppStru->szTransName );
            EXEC SQL SELECT NVL(operate_recno,0) INTO :iBeginRecNo
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
                WriteLog( ERROR, "sel operate_recno fail %d", SQLCODE );
                return FAIL;
            }
        }
        /* �������� */
        else
        {
            iBeginRecNo = 0;
        }
        //add by gaomx 20110415 for test
        //nBeginRecNo = 0;
    }
    else
    {
        AscToBcd((uchar*)(ptAppStru->szTransCode), 2, 0 ,(uchar*)szBuf);
        szBuf[1] = 0;
        iBeginRecNo = (uchar)szBuf[0];

        //�ն˸��³ɹ������������ؼ�¼��
        if( memcmp(ptAppStru->szHostRetCode, "00", 2) == 0 )
        {
            EXEC SQL UPDATE terminal 
            set operate_recno = :iBeginRecNo
            WHERE psam_no = :szPsamNo;
            if( SQLCODE )
            {
                WriteLog( ERROR, "update operate_recno fail %d", SQLCODE );
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
        if( ptAppStru->iTransType == CENDOWN_OPERATION_INFO || ptAppStru->iTransType == AUTODOWN_OPERATION_INFO )
        {
                iDownloadNew = 0;
        }

    //��������add by gaomx 20110415 for test
    //nDownloadNew =0;
    if( iDownloadNew == 1 )
    {
        /* ֻ��Ҫ����Ӧ�ð汾��֮������ */
        BcdToAsc( (uchar *)(ptAppStru->szAppVer), 8, 0,(uchar *)szUpdateDate );
        szUpdateDate[8] = 0;
    }
    //��ȫ����
    else
    {
        strcpy( szUpdateDate, "20000101" );
    }

    /*ȡ����¼�ţ������ж��Ƿ���Ҫ֪ͨ
      �ն˽��к������أ��������ն˵���һ������*/
    EXEC SQL SELECT max(oper_index) INTO :iMaxRecNo
    FROM operation_info;
    if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "count operation fail %d", SQLCODE );
        return FAIL;
    }

    if( iMaxRecNo < iNeedDownMax )
    {
        iNeedDownMax = iMaxRecNo;
    }

    ptAppStru->iReservedLen = 0;
    
    EXEC SQL DECLARE op_cur cursor for
    SELECT    
        OPER_INDEX,
        OP_FLAG,
        MODULE_NUM,
        NVL(INFO1_FORMAT,' '),
        NVL(INFO1, ' '),
        NVL(INFO2_FORMAT,' '),
        NVL(INFO2, ' '),
        NVL(INFO3_FORMAT,' '),
        NVL(INFO3, ' '),
        NVL(UPDATE_DATE,' ')
    FROM operation_info
    WHERE oper_index > :iBeginRecNo and 
         (update_date >= :szUpdateDate or oper_index = :iNeedDownMax)
    ORDER BY oper_index;

    if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "delare op_cur fail %d", SQLCODE );
        return FAIL;
    }

    EXEC SQL OPEN op_cur;
    if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "open op_cur fail %d", SQLCODE );
        EXEC SQL CLOSE op_cur;
        return FAIL;
    }

    iTotalRecNum = 0;
    iDataLen = 0;
    while(1)
    {
        EXEC SQL FETCH op_cur 
        INTO 
            :tOperationInfo.iOperIndex,
            :tOperationInfo.szOpFlag,
            :tOperationInfo.iModuleNum,
            :tOperationInfo.szInfo1Format,
            :tOperationInfo.szInfo1,
            :tOperationInfo.szInfo2Format,
            :tOperationInfo.szInfo2,
            :tOperationInfo.szInfo3Format,
            :tOperationInfo.szInfo3;
        if( SQLCODE == SQL_NO_RECORD )
        {
            EXEC SQL CLOSE op_cur;
            break;
        }
        else if( SQLCODE )
        {
            strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
            WriteLog( ERROR, "fetch op_cur fail %d", SQLCODE );
            EXEC SQL CLOSE op_cur;
            return FAIL;
        }

        //������¼��������
        if( tOperationInfo.iOperIndex > iNeedDownMax )
        {
            EXEC SQL CLOSE op_cur;
            break;
        }

        //������¼����Ҫ����
        if( ptAppStru->szReserved[tOperationInfo.iOperIndex-1] == '0' && tOperationInfo.iOperIndex!= iNeedDownMax )
        {
            continue;
        }

        DelTailSpace( tOperationInfo.szInfo1 );
        DelTailSpace( tOperationInfo.szInfo2 );
        DelTailSpace( tOperationInfo.szInfo3 );

        iInfo1Len = strlen( tOperationInfo.szInfo1 );
        iInfo2Len = strlen( tOperationInfo.szInfo2 );
        iInfo3Len = strlen( tOperationInfo.szInfo3 );

        iModuNum = 0;
        if( memcmp( tOperationInfo.szInfo1Format, "FF", 2 ) != 0 )
        {
            iModuNum ++;
        }
        if( memcmp( tOperationInfo.szInfo2Format, "FF", 2 ) != 0 )
        {
            iModuNum ++;
        }
        if( memcmp( tOperationInfo.szInfo3Format, "FF", 2 ) != 0 )
        {
            iModuNum ++;
        }

        iCurPos = 0;
        //��ʾ��Ϣ����
        szBuf[iCurPos] = tOperationInfo.iOperIndex;
        iCurPos ++;
        //��Ϣ������ʶ
        szBuf[iCurPos] = tOperationInfo.szOpFlag[0];
        iCurPos ++;
        //��Ϣ���ݳ���
        szBuf[iCurPos] = iInfo1Len + iInfo2Len + iInfo3Len + iModuNum*2+1;
        iCurPos ++;
        //ģ����
        szBuf[iCurPos] = iModuNum;
        iCurPos ++;
        
        //ģ��1����
        if( memcmp( tOperationInfo.szInfo1Format, "FF", 2 ) != 0 )
        {
            //��ʾ��ʽ
            AscToBcd((uchar*)(tOperationInfo.szInfo1Format), 2, 0,(uchar*)szBuf+iCurPos );
            iCurPos ++;
            //���ݳ���
            szBuf[iCurPos] = iInfo1Len;
            iCurPos ++;

            if( iInfo1Len > 0 )
            {
                memcpy(szBuf+iCurPos, tOperationInfo.szInfo1, iInfo1Len);
                iCurPos += iInfo1Len;
            }
        }

        //ģ��2����
        if( memcmp( tOperationInfo.szInfo2Format, "FF", 2 ) != 0 )
        {
            //��ʾ��ʽ
            AscToBcd((uchar*)(tOperationInfo.szInfo2Format), 2, 0, (uchar*)szBuf+iCurPos);
            iCurPos ++;
            //���ݳ���
            szBuf[iCurPos] = iInfo2Len;
            iCurPos ++;

            if( iInfo2Len > 0 )
            {
                memcpy(szBuf+iCurPos, tOperationInfo.szInfo2, iInfo2Len);
                iCurPos += iInfo2Len;
            }
        }

        //ģ��3����
        if( memcmp( tOperationInfo.szInfo3Format, "FF", 2 ) != 0 )
        {
            //��ʾ��ʽ
            AscToBcd((uchar*)(tOperationInfo.szInfo3Format), 2, 0,(uchar*)szBuf+iCurPos);
            iCurPos ++;
            //���ݳ���
            szBuf[iCurPos] = iInfo3Len;
            iCurPos ++;

            if( iInfo3Len > 0 )
            {
                memcpy(szBuf+iCurPos, tOperationInfo.szInfo3, iInfo3Len);
                iCurPos += iInfo3Len;
            }
        }

        if( (iDataLen+iCurPos+1) <= 255 )
        {
            memcpy( szData+iDataLen, szBuf, iCurPos );
            iDataLen += iCurPos;
            iLastIndex = tOperationInfo.iOperIndex;
            iTotalRecNum ++;
        }
        //���ݹ�����������¼���¸�������
        else
        {
            EXEC SQL CLOSE op_cur;
            break;
        }
    }

    ptAppStru->szReserved[0] = iTotalRecNum;
    memcpy( ptAppStru->szReserved+1, szData, iDataLen );
    ptAppStru->iReservedLen = iDataLen+1;    
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
        memcpy( ptAppStru->szCommand+iCmdLen, "\x1A\xFF", 2 );//���²�����ʾ
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
        if( ptAppStru->iTransType == DOWN_ALL_OPERATION ||
            ptAppStru->iTransType == CENDOWN_ALL_OPERATION ||
            ptAppStru->iTransType == AUTODOWN_ALL_OPERATION )
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
