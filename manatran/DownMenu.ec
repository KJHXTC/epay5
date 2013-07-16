
/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:�ն������ཻ��

** �����б�:
** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.8 $
$Log: DownMenu.ec,v $
Revision 1.8  2013/01/24 07:41:31  wukj
QLCODE��ӡ��ʽ�޸�Ϊ%d

Revision 1.7  2013/01/15 02:09:23  fengw

1���޸ķ�ĩ���˵����Ʋ������ȸ�ֵ��

Revision 1.6  2013/01/06 05:05:44  fengw

1��trans_def������excep_times�ֶ�(�쳣�������)���޸���ش��롣

Revision 1.5  2013/01/05 08:39:22  wukj
*** empty log message ***

Revision 1.4  2013/01/05 06:41:24  fengw

1������SQL������ֶ�������

Revision 1.3  2012/12/26 01:53:07  wukj
��ָ��������Ȳ�Ϊ0ʱ,��Ҫ����ָ�����

Revision 1.2  2012/12/24 04:45:03  wukj
GetCommans����ָ�����

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
** ��    ��: �˵���Ϣ����
** �������:
           ptAppStru
** �������:
           ptAppStru->szReserved        �˵���Ϣ
           ptAppStru->iReservedLen    �˵���Ϣ����
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
DownMenu( ptAppStru ) 
T_App    *ptAppStru;
{
    EXEC SQL BEGIN DECLARE SECTION;
        int     iLevel1, iLevel2, iLevel3;
        int    iAppType, iCount, iBeginMenu, iTransType;
        char    szPsamNo[17];
        
        struct T_APP_MENU {
            int     iMenuNo;
            int     iUpMenuNo;
            int     iAppType;
            int     iLevel1;
            int     iLevel2;
            int     iLevel3;
            char    szMenuName[21];
            char    szTransCode[9];
            char    szIsValid[2];
            char    szUpdateDate[9];
        }tAppMenu;

        
        struct T_APP_DEF {
            int     iAppType;
            char    szAppName[21];
            char    szAppDescribe[31];
            char    szAppVer[9];
        }tAppDef;


        
        struct T_TRANS_DEF {
            int     iTransType;
            char    szTransCode[9];
            char    szNextTransCode[9];
            char    szExcepHandle[2];
            int     iExcepTimes;
            char    szPinBlock[2];
            int     iFunctionIndex;
            char    szTransName[21];
            int     iTelephoneNo;
            char    szDispType[2];
            int     iToTransMsgType;
            int     iToHostMsgType;
            char    szIsVisible[2];
        } tTransDef;

        
        struct T_TRANS_COMMANDS {
            int     iTransType;
            int     iStep;
            char    szTransFlag[2];
            char    szCommand[3];
            int     iOperIndex;
            char    szAlog[9];
            char    szCommandName[31];
            char    szOrgCommand[3];
            int     iDataIndex;
        }tTransCmd;
    EXEC SQL END DECLARE SECTION;
    
    int     iMenuNo;    //�˵����
    int     iCurPos, iMenuNum, iRet, iCmdNum, iCmdLen, iMenuLen, iDataNum, iRealType;
    char    szBuf[1024], szCmd[512], szTmpStr[20], szMenuData[1024];
    int     iPreCmdLen, iPreCmdNum;
    char    szPreCmd[512], szFlag[2], szDataSource[30];
    int     iCtlLen;
    char    szCtlPara[101];

    strcpy( szPsamNo, ptAppStru->szPsamNo );

    //���ķ����ף������ж��Ƿ���comweb
    strcpy( ptAppStru->szAuthCode, "YES" );

    //�ն˷������һ�������׽�������û����ն�
    if( memcmp( ptAppStru->szTransCode, "FF", 2 ) == 0 )
    {
        strcpy( ptAppStru->szAuthCode, "NO" );
        if( memcmp( ptAppStru->szHostRetCode, "00", 2 ) == 0 )
        {
            EXEC SQL UPDATE terminal
            set down_menu = 'N', menu_recno = 0
            WHERE psam_no = :szPsamNo;
            if( SQLCODE )
            {
                WriteLog( ERROR, "update down_menu fail %d", SQLCODE );
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
    if( ptAppStru->iTransType == DOWN_ALL_MENU && 
            memcmp( ptAppStru->szTransCode, "00", 2 ) == 0 )
    {
        iTransType = DOWN_ALL_MENU;

        //�и��½��&trans_codeǰ��λΪ00�������˵����ظտ�ʼ��
        //����ʼ��¼Ϊ0
        if( memcmp(ptAppStru->szHostRetCode, "NN", 2) != 0 )
        {
            EXEC SQL UPDATE terminal
            set all_transtype = :iTransType, menu_recno = 0,
                down_function = 'N', function_recno = 0
            WHERE psam_no = :szPsamNo;
        }
        //�޸��½��&trans_codeǰ��λΪ00�������ǲ˵����صĶϵ�
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

    EXEC SQL SELECT app_type INTO :iAppType
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
        WriteLog( ERROR, "get app_type fail %d", SQLCODE );
        return FAIL;
    }

    //�׸����ذ�����Ҫ����control_code�ж��Ƕϵ�������������������
    if( memcmp( ptAppStru->szTransCode, "00", 2 ) == 0 )
    {
        //�ϵ�����
        if( ptAppStru->szControlCode[0] == '1' )
        {
WriteLog( TRACE, "%s �ϵ�����", ptAppStru->szTransName );
            EXEC SQL SELECT NVL(menu_recno,0) INTO :iBeginMenu
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
                WriteLog( ERROR, "sel menu_recno fail %d", SQLCODE );
                return FAIL;
            }
        }
        /* �������� */
        else
        {
            iBeginMenu = 0;
        }
    }
    else
    {
        AscToBcd( (uchar*)(ptAppStru->szTransCode), 2, 0 , (uchar*)szBuf );
        szBuf[1] = 0;
        iBeginMenu = (uchar)szBuf[0];

        //�ն˸��³ɹ������������ؼ�¼��
        if( memcmp(ptAppStru->szHostRetCode, "00", 2) == 0 )
        {
            EXEC SQL UPDATE terminal 
            set menu_recno = :iBeginMenu
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

    /*ͳ���ܲ˵������������ж��Ƿ���Ҫ֪ͨ
      �ն˽��к������أ��������ն˵���һ������*/
    EXEC SQL SELECT count(*) INTO :iCount
    FROM app_menu
    WHERE app_type = :iAppType;
    if( SQLCODE == SQL_NO_RECORD )
    {
        strcpy( ptAppStru->szRetCode, ERR_INVALID_APP );
        WriteLog( ERROR, "term[%s] app[%d] iot exist", szPsamNo, iAppType );
        return FAIL;
    }
    else if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "count app_menu fail %d", SQLCODE );
        return FAIL;
    }

    if( iBeginMenu >= iCount )
    {
        strcpy( ptAppStru->szRetCode, ERR_DOWN_FINISH );
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
        WriteLog( ERROR, "SELECT app_def fail %d", SQLCODE );
        return FAIL;
    }

    EXEC SQL DECLARE menu_cur cursor for
    SELECT  
        MENU_NO,
        UP_MENU_NO,
        APP_TYPE,
        NVL(LEVEL_1,0),
        NVL(LEVEL_2,1),
        NVL(LEVEL_3,2),
        NVL(MENU_NAME,' '),
        NVL(TRANS_CODE,' '),
        NVL(IS_VALID, ' '),
        NVL(UPDATE_DATE,' ')
    FROM app_menu
    WHERE app_type = :iAppType and level_1 <= 9 and level_2 <= 9 and 
          level_3 <= 9 and level_1 >= 0 and level_2 >= 0 and
          level_3 >= 0
    ORDER BY level_1, level_2, level_3;
    if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "delare menu_cur fail %d", SQLCODE );
        return FAIL;
    }

    EXEC SQL OPEN menu_cur;
    if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "open menu_cur fail %d", SQLCODE );
        EXEC SQL CLOSE menu_cur;
        return FAIL;
    }

    iMenuNum = 0;
    iMenuNo = 0;
    iMenuLen = 0;
    while(1)
    {
        EXEC SQL FETCH menu_cur 
        INTO 
            :tAppMenu.iMenuNo,
            :tAppMenu.iUpMenuNo,
            :tAppMenu.iAppType,
            :tAppMenu.iLevel1,
            :tAppMenu.iLevel2,
            :tAppMenu.iLevel3,
            :tAppMenu.szMenuName,
            :tAppMenu.szTransCode,
            :tAppMenu.szIsValid,
            :tAppMenu.szUpdateDate;
        if( SQLCODE == SQL_NO_RECORD )
        {
            EXEC SQL CLOSE menu_cur;
            break;
        }
        else if( SQLCODE )
        {
            strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
            WriteLog( ERROR, "fetch fun_cur fail %d", SQLCODE );
            EXEC SQL CLOSE menu_cur;
            return FAIL;
        }

        iMenuNo ++;
        iLevel1 = tAppMenu.iLevel1;
        iLevel2 = tAppMenu.iLevel2;
        iLevel3 = tAppMenu.iLevel3;
        DelTailSpace(tAppMenu.szMenuName);

        //�ò˵��Ѿ����أ�����
        if( iMenuNo <= iBeginMenu )
        {
            continue;
        }

        iCurPos = 0;
        //�˵�������ʶ
        szBuf[iCurPos] = tAppMenu.szIsValid[0]; 
        iCurPos ++;

        //�˵�����
        szTmpStr[0] = tAppMenu.iLevel1+'0';    
        szTmpStr[1] = tAppMenu.iLevel2+'0';
        szTmpStr[2] = tAppMenu.iLevel3+'0';
        szTmpStr[3] = '0';
        AscToBcd(  (uchar*)szTmpStr, 4, 0 , (uchar*)(szBuf+iCurPos));
        iCurPos += 2;

        //���״���
        AscToBcd( (uchar*)tAppMenu.szTransCode, 8, 0 ,  (uchar*)(szBuf+iCurPos));
        iCurPos += 4;

        /* ��ĩ���˵� */
        if( memcmp( tAppMenu.szTransCode, "00000000", 8 ) == 0 )
        {
            //������ʶ
            szBuf[iCurPos] = '0';
            iCurPos ++;

            //ҵ�����ͱ�ʶ
            szBuf[iCurPos] = 0;
            iCurPos ++;

            //������ʾ����
            szBuf[iCurPos] = 0;
            iCurPos ++;

            //ϵͳ�������
            szBuf[iCurPos] = '0';
            iCurPos ++;

            //���̴��볤��
            szBuf[iCurPos] = 0;
            iCurPos ++;
            
            //ָ���������
            szBuf[iCurPos] = 0;
            iCurPos++;
        }
        /* ĩ���˵������ݽ��״���ȡ֮ǰ���� */
        else
        {
            EXEC SQL SELECT 
                TRANS_TYPE,
                TRANS_CODE,
                NVL(NEXT_TRANS_CODE, ' '),
                NVL(EXCEP_HANDLE,' '),
                NVL(excep_times, 0),
                NVL(PIN_BLOCK, ' '),
                NVL(FUNCTION_INDEX, 0),
                NVL(TRANS_NAME, ' '),
                NVL(TELEPHONE_NO, 0),
                NVL(DISP_TYPE, ' '),
                NVL(TOTRANS_MSG_TYPE, 0),
                NVL(TOHOST_MSG_TYPE, 0),
                NVL(IS_VISIBLE, ' ')
             INTO 
                :tTransDef.iTransType,
                :tTransDef.szTransCode,
                :tTransDef.szNextTransCode,
                :tTransDef.szExcepHandle,
                :tTransDef.iExcepTimes,
                :tTransDef.szPinBlock,
                :tTransDef.iFunctionIndex,
                :tTransDef.szTransName,
                :tTransDef.iTelephoneNo,
                :tTransDef.szDispType,
                :tTransDef.iToTransMsgType,
                :tTransDef.iToHostMsgType,
                :tTransDef.szIsVisible
            FROM TRANS_DEF
            WHERE trans_code = :tAppMenu.szTransCode;
            if( SQLCODE == SQL_NO_RECORD )
            {
                strcpy( ptAppStru->szRetCode, ERR_INVALID_MENU );
                WriteLog( ERROR, "trans[%s] not exist", tAppMenu.szTransCode );
                return FAIL;
            }
            else if( SQLCODE )
            {
                strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
                WriteLog( ERROR, "SELECT trans_def [%s] fail[%d:%s]", tAppMenu.szTransCode, SQLCODE, SQLERR );
                return FAIL;
            }

            /* �ն��϶�����ɷѽ��׿ɶ�Ӧ��̨һ�����ף����Ǻ���λһ�� */
            iRealType = tTransDef.iTransType%1000L;
            iRet = GetCommands( iRealType, '0', 
                szCmd, &iCmdNum, &iCmdLen, szDataSource, &iDataNum ,&iCtlLen,szCtlPara);
            if( iRet != SUCC )
            {
                strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
                WriteLog( ERROR, "get command fail" );
                return FAIL;
            }

            //ҵ�����ͱ�ʶ
            szBuf[iCurPos] = tTransDef.szPinBlock[0]-'0';
            iCurPos ++;

            //������ʶ
            szBuf[iCurPos] = ((tTransDef.szExcepHandle[0] - '0') << 4) | tTransDef.iExcepTimes;
            iCurPos ++;

            //������ʾ����
            szBuf[iCurPos] = tTransDef.iFunctionIndex;
            iCurPos ++;

            //ϵͳ�������
            szBuf[iCurPos] = tTransDef.iTelephoneNo+'0';
            iCurPos ++;

            //���̴��볤��
            szBuf[iCurPos] = iCmdLen+1;
            iCurPos ++;

            //���̴���(����ָ�����)
            szBuf[iCurPos] = iCmdNum;
            iCurPos ++;
            memcpy( szBuf+iCurPos, szCmd, iCmdLen );
            iCurPos += iCmdLen;
 
            if(iCtlLen > 0)
            {
                //ָ���������
                szBuf[iCurPos] = iCtlLen;
                iCurPos ++;
                memcpy( szBuf + iCurPos, szCtlPara, iCtlLen);
                iCurPos += iCtlLen;
            }
            else
            {
                //ָ���������
                szBuf[iCurPos] = 0;
                iCurPos++;
            }
        }

        //��ʾ���ݳ���(�˵�����)
        szBuf[iCurPos] = strlen(tAppMenu.szMenuName);
        iCurPos ++;

        //��ʾ����(�˵�)
        memcpy( szBuf+iCurPos, tAppMenu.szMenuName, strlen(tAppMenu.szMenuName) );
        iCurPos += strlen(tAppMenu.szMenuName);

        if( (iMenuLen+iCurPos+6) <= 255 )
        {
            iMenuNum ++;
            memcpy( szMenuData+iMenuLen, szBuf, iCurPos );
            iMenuLen += iCurPos;
        }
        //���ݰ������������˵������¸�������
        else
        {
            iMenuNo --;
            break;
        }
    }

    //Ӧ�ð汾ԭֵ���أ���������һ���������¸�ֵΪtAppDef.szAppVer
    memcpy( ptAppStru->szReserved, ptAppStru->szAppVer, 4 );    

    ptAppStru->szReserved[4] = '2';    //����ģʽ���洢����ʾ
    ptAppStru->szReserved[5] = iMenuNum;        //�˵�����
    memcpy( ptAppStru->szReserved+6, szMenuData, iMenuLen);    //�˵�����
    ptAppStru->iReservedLen = 6+iMenuLen;

    sprintf( ptAppStru->szPan, "����%03d-%03d / %03d", iBeginMenu+1, iMenuNo, iCount );

    /* ��Ҫ���к������� */
    if( iCount > iMenuNo )
    {
        //�������״���ǰ2λ��ʾ�����ز˵�������6λΪ��ǰ���״����6λ
        szBuf[0] = iMenuNo;
        szBuf[1] = 0;
        BcdToAsc( (uchar*)szBuf, 2, 0, (uchar*)(ptAppStru->szNextTransCode) );
        memcpy( ptAppStru->szNextTransCode+2, ptAppStru->szTransCode+2, 6 );
        ptAppStru->szNextTransCode[8] = 0;

        //�����ն����̴���(ָ���뼯)
        iCmdLen = 0;
        ptAppStru->iCommandNum = 0;
        if( iBeginMenu == 0 )
        {
            //�����׸��˵�ǰ����Ҫ��ղ˵�
            memcpy( ptAppStru->szCommand+iCmdLen, "\xBB", 1 );    
            iCmdLen += 1;
            ptAppStru->iCommandNum ++;
        }

        if( memcmp(ptAppStru->szTransCode, "00", 2) == 0 )
        {
            //��ʱ��ʾ��Ϣ
            memcpy( ptAppStru->szCommand+iCmdLen, "\xAF", 1 );    
            iCmdLen += 1;
            ptAppStru->iCommandNum ++;
        }
        memcpy( ptAppStru->szCommand+iCmdLen, "\x18\xFF", 2 );//����Ӧ�ò˵�
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
        AscToBcd( (uchar*)(tAppDef.szAppVer), 8, 0,(uchar*)(ptAppStru->szReserved));  //Ӧ�ð汾
        //�����׸��˵�ǰ����Ҫ��ղ˵�
        if( iBeginMenu == 0 )
        {
            ptAppStru->iCommandNum++;
            memcpy( szCmd, "\xBB", 1 );    //��ղ˵�    
            memcpy(szCmd+1, ptAppStru->szCommand, ptAppStru->iCommandLen);
            memcpy(ptAppStru->szCommand, szCmd, ptAppStru->iCommandLen+1);
            ptAppStru->iCommandLen ++;
        }

        if( ptAppStru->iTransType == DOWN_ALL_MENU )
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
