
/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:�ն������ཻ��

** �����б�:
** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.4 $
$Log: DownMsg.ec,v $
Revision 1.4  2013/06/18 06:04:09  fengw

1�����ݿ���У����ű�Ŵ洢��ʽ�޸�Ϊ6λ��� + '.'�ָ������޸���Ӧ���롣

Revision 1.3  2013/01/24 07:41:31  wukj
QLCODE��ӡ��ʽ�޸�Ϊ%d

Revision 1.2  2013/01/05 06:41:53  fengw

1������SQL������ֶ�������

Revision 1.1  2012/12/18 10:04:56  wukj
*** empty log message ***

$Date: 2013/06/18 06:04:09 $
*******************************************************************/

# include "manatran.h"

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL EnD DECLARE SECTION;
#endif

/*****************************************************************
** ��    ��:����֪ͨ�·�(һ������һ��)
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
int DownMsg( ptAppStru ) 
T_App    *ptAppStru;
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szPsamNo[17], szRecNo[61], szMsgRec[61], szMessage[256];
        char    szDate[9];
        int    iTransType, iRecNum, iSmsNo;
    EXEC SQL END DECLARE SECTION;

    int    i, iCurPos, iCmdLen, iCmdNum, iRet;
    int    iPreCmdLen, iPreCmdNum;
    char    szTmpStr[50], szBuf[512], szCmd[512];
    char    szPreCmd[50];

    //���ķ����ף������ж��Ƿ���comweb
    strcpy( ptAppStru->szAuthCode, "YES" );

    ptAppStru->iReservedLen = 0;

    strcpy( szPsamNo, ptAppStru->szPsamNo );

    EXEC SQL SELECT NVL(msg_recnum,0), NVL(msg_recno,' ') 
    INTO :iRecNum, :szRecNo
    FROM terminal
    WHERE psam_no = :szPsamNo;
    if( SQLCODE )
    {
        WriteLog( ERROR, "SELECT term fail %d", SQLCODE );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }
    DelTailSpace(szRecNo);

    //�ն˷����ϴ����ؽ��
    if( memcmp( ptAppStru->szTransCode, "00", 2 ) != 0 )
    {
        //���سɹ������¶���������Ϣ
        if( memcmp( ptAppStru->szHostRetCode, "00", 2 ) == 0 )
        {
            if( iRecNum >= 1 )
            {
                iRecNum --;
                memcpy( szMsgRec, szRecNo+7, iRecNum*7 );
                szMsgRec[iRecNum*7] = 0;

                EXEC SQL UPDATE terminal 
                set msg_recnum = :iRecNum,
                        msg_recno = :szMsgRec
                WHERE psam_no = :szPsamNo;
                if( SQLCODE )
                {
                    strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
                    WriteLog( ERROR, "update term fail %d", SQLCODE );
                    RollbackTran();
                    return FAIL;
                }
                CommitTran();
            }
            else
            {    
                WriteLog( ERROR, "msg_recnum=0" );
            }
        }
    }
    else
    {
        memcpy( szMsgRec, szRecNo, iRecNum*7 );
    }

    //�ն˷����ϴν��׽�������û����ն�&&comweb
    if( memcmp( ptAppStru->szTransCode, "FF", 2 ) == 0 )
    {
        strcpy( ptAppStru->szAuthCode, "NO" );
        strcpy( ptAppStru->szRetCode, TRANS_SUCC );
        return SUCC;
    }

    //�޶���
    if( iRecNum == 0 )
    {
        strcpy( ptAppStru->szRetCode, ERR_DOWN_FINISH );
        WriteLog( ERROR, "not short_message" );
        return FAIL;
    }

    GetSysDate( szDate );

    for( i=0; i<iRecNum; i++ )
    {
        memcpy( szTmpStr, szMsgRec+i*7, 6 );
        szTmpStr[6] = 0;
        iSmsNo = atol(szTmpStr);

        EXEC SQL SELECT msg_content INTO :szMessage
        FROM short_message
        WHERE rec_no = :iSmsNo and valid_date >= :szDate;
        //��Ӧ��¼�����Ѿ���ɾ�����ѹ���Ч��
        if( SQLCODE == SQL_NO_RECORD )
        {
            WriteLog( TRACE, "sms[%d] has been deleted or invalid", iSmsNo );
            continue;
        }
        else if( SQLCODE )
        {
            strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
            WriteLog( ERROR, "SELECT sms fail %d", SQLCODE );
            return FAIL;
        }
        break;
    }

    //��Щ���ż�¼�Ѿ���ɾ�����ѹ���
    if( i > 0 )
    {
        iRecNum -= i;
        memcpy( szRecNo, szMsgRec+i*7, iRecNum*7 );
        szRecNo[iRecNum*7] = 0;

        EXEC SQL UPDATE terminal 
        set msg_recnum = :iRecNum,
            msg_recno = :szRecNo
        WHERE psam_no = :szPsamNo;
        if( SQLCODE )
        {
            strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
            WriteLog( ERROR, "update term fail %d", SQLCODE );
            RollbackTran();
            return FAIL;
        }
        CommitTran();
    }

    //�޶���
    if( iRecNum == 0 )
    {
        strcpy( ptAppStru->szRetCode, ERR_DOWN_FINISH );
        WriteLog( ERROR, "not short_message" );
        return FAIL;
    }

    sprintf( ptAppStru->szPan, "��¼��%06ld", iSmsNo );
    DelTailSpace( szMessage );
    ptAppStru->iReservedLen = strlen( szMessage );
    memcpy( ptAppStru->szReserved, szMessage, ptAppStru->iReservedLen );

    /* ��Ҫ���к������� */
    if( iRecNum > 1 )
    {
        //�������״���ǰ2λ01��ʾ��Ҫ���к������أ�FF��ʾ����
        strcpy( ptAppStru->szNextTransCode, "01" );
        memcpy( ptAppStru->szNextTransCode+2, ptAppStru->szTransCode+2, 6 );
        ptAppStru->szNextTransCode[8] = 0;
        
        iPreCmdLen = 5;
        memcpy( szPreCmd, "\x8D\x24\x03\x25\x04", iPreCmdLen );
        iPreCmdNum = 3;

        //�����ն����̴���(ָ���뼯)
        iCmdLen = 0;
        memcpy( ptAppStru->szCommand+iCmdLen, "\xA0", 1 );    //�洢����
        iCmdLen += 1;

        memcpy( ptAppStru->szCommand+iCmdLen, szPreCmd, iPreCmdLen );
        iCmdLen += iPreCmdLen;

        ptAppStru->iCommandNum = iPreCmdNum+1;
        ptAppStru->iCommandLen = iCmdLen;

        //��Ҫ���к������أ�����comweb
        strcpy( ptAppStru->szAuthCode, "NO" );
    }
    else
    {
        strcpy( ptAppStru->szNextTransCode, "FF" );
        memcpy( ptAppStru->szNextTransCode+2, ptAppStru->szTransCode+2, 6 );
        ptAppStru->szNextTransCode[8] = 0;
    }

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}

