
/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:�ն������ཻ��

** �����б�:
** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.2 $
$Log: DownTermPara.ec,v $
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
** ��    ��:�ն˲�������
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
int DownTermPara( ptAppStru ) 
T_App    *ptAppStru;
{
    EXEC SQL BEGIN DECLARE SECTION;
        struct T_TERMINAL_PARA{
            int     iModuleId;
            char    szDescribe[21];
            char    szLineType[2];
            int     iInPutTimeOut;
            int     iTransTimeOut;
            char    szManagerPwd[9];
            char    szOperatorPwd[7];
            int     iTelephoneNo;
            int     iPinMaxLen;
            char    szAuthKey[9];
            char    szInnerKey[33];
            char    szExtKey[33];
            char    szPreTeleNo[13];
            int     iWaitTime;
            char    szTipSwitch[2];
            char    szAutoAnswer[2];
            int     iDelayTime;
            char    szHandDial[2];
            char    szSaveList[2];
            char    szPrintOrNot[2];
            char    szReader[2];
            char    szPinInput[2];
        }tTerminalPara;

        int iModuleId, iTransType;
        long lTrace, lLimitAmt, lFeeRate, lFee1, lFee2;
        char szPsamNo[17];
    EXEC SQL END DECLARE SECTION;

    char szBuf[512], szTmpStr[20], szKey[17], szCheckVal[9];
    char szRec[20];
    int i, iCurPos, iTotalRecNum, iMaxRecNum;

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
            set down_term = 'N'
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

        //Ӧ���������һ��-�ն˲������أ��޸����ر�ʶ
        if( ptAppStru->iTransType == DOWN_ALL_TERM )
        {
            iTransType = DOWN_ALL_OPERATION;
            EXEC SQL UPDATE terminal
            set down_all = 'N', all_transtype = :iTransType
            WHERE psam_no = :szPsamNo;
            if( SQLCODE )
            {
                WriteLog( ERROR, "update down_all fail %d", SQLCODE );
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
    if( ptAppStru->iTransType == DOWN_ALL_TERM )
    {
        WriteLog( TRACE, "begin down %s", ptAppStru->szTransName );
        iTransType = DOWN_ALL_TERM;

        EXEC SQL UPDATE terminal
        SET all_transtype = :iTransType, 
            down_print = 'N', print_recno = 0
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

    iModuleId = ptAppStru->iTermModule;

    EXEC SQL SELECT 
            MODULE_ID,
            NVL(DESCRIBE,' '),
            NVL(LINE_TYPE,' '),
            NVL(INPUT_TIMEOUT, 30),
            NVL(TRANS_TIMEOUT, 30),
            NVL(MANAGER_PWD,'20060101'),
            NVL(OPERATOR_PWD,'123456'),
            NVL(TELEPHONE_NO,0),
            NVL(PIN_MAX_LEN,6),
            NVL(AUTH_KEY,'12345678'),
            NVL(INTER_KEY,' '),
            NVL(EXT_KEY,' '),
            NVL(PRE_TELE_NO,'0'),
            NVL(WAIT_TIME,30),
            NVL(TIP_SWITCH,' '),
            NVL(AUTO_ANSWER,'0'),
            NVL(DELAY_TIME,30),
            NVL(HAND_DIAL,' '),
            NVL(SAVE_LIST,' '),
            NVL(PRINT_OR_NOT, ' '),
            NVL(READER,' '),
            NVL(PIN_INPUT,' ')
    INTO 
            :tTerminalPara.iModuleId,
            :tTerminalPara.szDescribe,
            :tTerminalPara.szLineType,
            :tTerminalPara.iInPutTimeOut,
            :tTerminalPara.iTransTimeOut,
            :tTerminalPara.szManagerPwd,
            :tTerminalPara.szOperatorPwd,
            :tTerminalPara.iTelephoneNo,
            :tTerminalPara.iPinMaxLen,
            :tTerminalPara.szAuthKey,
            :tTerminalPara.szInnerKey,
            :tTerminalPara.szExtKey,
            :tTerminalPara.szPreTeleNo,
            :tTerminalPara.iWaitTime,
            :tTerminalPara.szTipSwitch,
            :tTerminalPara.szAutoAnswer,
            :tTerminalPara.iDelayTime,
            :tTerminalPara.szHandDial,
            :tTerminalPara.szSaveList,
            :tTerminalPara.szPrintOrNot,
            :tTerminalPara.szReader,
            :tTerminalPara.szPinInput
    FROM TERMINAL_PARA 
    WHERE module_id = :iModuleId;
    if( SQLCODE == SQL_NO_RECORD )
    {
        strcpy( ptAppStru->szRetCode, ERR_TERM_MODULE );
        WriteLog( ERROR, "term_para [%ld] not exist", iModuleId );
        return FAIL;
    }
    else if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "SELECT term_para fail %d", SQLCODE );
        return FAIL;
    }

    iMaxRecNum = 8;
    iCurPos = 0;
    iTotalRecNum = 0;
    strcpy( ptAppStru->szPan, "rec" );
    for( i=1; i<=iMaxRecNum; i++ )
    {
        /* 1-��ʾҪ���� 0-��ʾ��Ҫ���� */
        if( ptAppStru->szReserved[i-1] == '0' || i == 10 || 
            i == 11 || i == 17 || i == 20 || i == 22 || 
            i == 23 )
            continue;

        /* �������ķ�����ն˲������أ��������޸��ն˲������� */
        if( i == 5 )
        {
            if( ptAppStru->iTransType != AUTODOWN_TERM_PARA &&
                ptAppStru->iTransType != CENDOWN_TERM_PARA )
            {
                continue;
            }
        }
        
        if( i <= 8 )
        {
            sprintf( szRec, " %d", i );
            strcat( ptAppStru->szPan, szRec );
        }

        szBuf[iCurPos] = i;    //�ն��м�¼��
        iCurPos ++;
        switch (i){
        //���뷽ʽ
        case 1:
            szBuf[iCurPos] = 1;    //���ݳ���
            iCurPos ++;
            szBuf[iCurPos] = tTerminalPara.szLineType[0];
            iCurPos ++;
            iTotalRecNum ++;
            break;
        //���Ƴ�ʱʱ��
        case 2:
            szBuf[iCurPos] = 2;    //���ݳ���
            iCurPos ++;
            sprintf( szTmpStr, "%02ld", tTerminalPara.iInPutTimeOut );
            memcpy( szBuf+iCurPos, szTmpStr, 2 );
            iCurPos += 2;
            iTotalRecNum ++;
            break;
        //���׳�ʱʱ��
        case 3:
            szBuf[iCurPos] = 2;    //���ݳ���
            iCurPos ++;
            sprintf( szTmpStr, "%02ld", tTerminalPara.iTransTimeOut );
            memcpy( szBuf+iCurPos, szTmpStr, 2 );
            iCurPos += 2;
            iTotalRecNum ++;
            break;
        //�ն˹���Ա����
        case 4:
            szBuf[iCurPos] = 8;    //���ݳ���
            iCurPos ++;
            memcpy( szBuf+iCurPos, tTerminalPara.szManagerPwd, 8 );
            iCurPos += 8;
            iTotalRecNum ++;
            break;
        //�ն˲�������(����֧������)
        case 5:
            szBuf[iCurPos] = 6;    //���ݳ���
            iCurPos ++;
            memcpy( szBuf+iCurPos, tTerminalPara.szOperatorPwd, 6 );
            iCurPos += 6;
            iTotalRecNum ++;
            break;
        //ȱʡϵͳ�������
        case 6:
            szBuf[iCurPos] = 1;    //���ݳ���
            iCurPos ++;
            szBuf[iCurPos] = tTerminalPara.iTelephoneNo +'0';
            iCurPos ++;
            iTotalRecNum ++;
            break;
        //������󳤶�
        case 7:
            szBuf[iCurPos] = 1;    //���ݳ���
            iCurPos ++;
            szBuf[iCurPos] = tTerminalPara.iPinMaxLen +'0';
            iCurPos ++;
            iTotalRecNum ++;
            break;
        //������֤��Կ
        case 8:
            szBuf[iCurPos] = 4;    //���ݳ���
            iCurPos ++;
            AscToBcd( (uchar*)tTerminalPara.szAuthKey, 8, 0 ,(uchar*)szBuf+iCurPos);
            iCurPos += 4;
            iTotalRecNum ++;
            break;
        //������ˮ��
        //����ȡ���޶�(�ൺ����ר��)
        case 9:
            EXEC SQL SELECT cur_trace INTO :lTrace
            FROM terminal
            WHERE psam_no = :szPsamNo;
            if( SQLCODE == SQL_NO_RECORD )
            {
                WriteLog( ERROR, "term[%s] not exist", szPsamNo );
                strcpy( ptAppStru->szRetCode, ERR_INVALID_TERM );
                return FAIL;
            }
            else if( SQLCODE )
            {
                WriteLog( ERROR, "SELECT trace fail %ld", SQLCODE );
                strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
                return FAIL;
            }
            szBuf[iCurPos] = 6;    //���ݳ���
            iCurPos ++;
            sprintf( szTmpStr, "%06ld", lTrace );
            memcpy( szBuf+iCurPos, szTmpStr, 6 );
            iCurPos += 6;
            iTotalRecNum ++;
            break;
        /* �����ѷ���+���������+��������� */    
        case 10:
            break;
        //˫����֤��Կ
        case 12:
            szBuf[iCurPos] = 32;    //���ݳ���
            iCurPos ++;
            AscToBcd( (uchar*)tTerminalPara.szExtKey, 32, 0 ,(uchar*)szBuf+iCurPos);
            iCurPos += 16;
            AscToBcd( (uchar*)tTerminalPara.szInnerKey, 32, 0 ,(uchar*)szBuf+iCurPos);
            iCurPos += 16;
            iTotalRecNum ++;
            break;
        //Ԥ�����ߺ���
        case 13:
            DelTailSpace( tTerminalPara.szPreTeleNo);
            //���ݳ���
            szBuf[iCurPos] = strlen(tTerminalPara.szPreTeleNo);    
            iCurPos ++;

            memcpy( szBuf+iCurPos, tTerminalPara.szPreTeleNo, 
                strlen(tTerminalPara.szPreTeleNo) );
            iCurPos += strlen(tTerminalPara.szPreTeleNo);
            iTotalRecNum ++;
            break;
        //���ŵȴ�ʱ��
        case 14:
            szBuf[iCurPos] = 2;    //���ݳ���
            iCurPos ++;
            sprintf( szTmpStr, "%02ld", tTerminalPara.iWaitTime);
            memcpy( szBuf+iCurPos, szTmpStr, 2 );
            iCurPos += 2;
            iTotalRecNum ++;
            break;
        //������ʾ������
        case 15:
            szBuf[iCurPos] = 1;    //���ݳ���
            iCurPos ++;
            szBuf[iCurPos] = tTerminalPara.szTipSwitch[0];
            iCurPos ++;
            iTotalRecNum ++;
            break;
        //�����Զ�Ӧ��
        case 16:
            szBuf[iCurPos] = 1;    //���ݳ���
            iCurPos ++;
            szBuf[iCurPos] = tTerminalPara.szAutoAnswer[0];
            iCurPos ++;
            iTotalRecNum ++;
            break;
        //������ʱ�ӵȼ�
        case 18:
            szBuf[iCurPos] = 1;    //���ݳ���
            iCurPos ++;
            szBuf[iCurPos] = tTerminalPara.iDelayTime +'0';
            iCurPos ++;
            iTotalRecNum ++;
            break;
        //�ն�ͨ������
        case 19:
            szBuf[iCurPos] = 1;    //���ݳ���
            iCurPos ++;
            szBuf[iCurPos] = tTerminalPara.szHandDial[0];
            iCurPos ++;
            iTotalRecNum ++;
            break;
        //������֧���ʵ�
        case 21:
            szBuf[iCurPos] = 1;    //���ݳ���
            iCurPos ++;
            szBuf[iCurPos] = tTerminalPara.szSaveList[0];
            iCurPos ++;
            iTotalRecNum ++;
            break;
        //��ӡ����
        case 24:
            szBuf[iCurPos] = 1;    //���ݳ���
            iCurPos ++;
            szBuf[iCurPos] = tTerminalPara.szPrintOrNot[0];
            iCurPos ++;
            iTotalRecNum ++;
            break;
        //�����Ķ�����
        case 25:
            szBuf[iCurPos] = 1;    //���ݳ���
            iCurPos ++;
            szBuf[iCurPos] = tTerminalPara.szReader[0];
            iCurPos ++;
            iTotalRecNum ++;
            break;
        //�������뷽ʽ
        case 26:
            szBuf[iCurPos] = 1;    //���ݳ���
            iCurPos ++;
            szBuf[iCurPos] = tTerminalPara.szPinInput[0];
            iCurPos ++;
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

    memcpy( ptAppStru->szNextTransCode, "FF", 2 );
    memcpy( ptAppStru->szNextTransCode+2, ptAppStru->szTransCode+2, 6 );
    ptAppStru->szNextTransCode[8] = 0;

    ptAppStru->iReservedLen = iCurPos+1;    
    ptAppStru->szReserved[0] = iTotalRecNum;    //��¼����
    memcpy( ptAppStru->szReserved+1, szBuf, iCurPos );

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}

