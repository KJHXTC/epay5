
/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:

** �����б�:
** �� �� ��:
** ��������:


$Revision: 1.3 $
$Log: DownPaylist.ec,v $
Revision 1.3  2013/01/24 07:41:31  wukj
QLCODE��ӡ��ʽ�޸�Ϊ%d

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
** ��    ��:δ֧���ʵ�����(һ������һ��)
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
int DownPaylist( ptAppStru ) 
T_App    *ptAppStru;
{
    EXEC SQL BEGIN DECLARE SECTION;

        struct T_PAY_LIST{
            char    szPsamNo[17];
            int     iListClass;
            int     iListType;
            char    szGenDate[9];
            int     iListNo;
            char    szListData[201];
            double  dAmount;
            char    szPayDate[9];
            char    szDownFlag[2];
            char    szPayStatus[2];
        } tPayList;       

        struct T_PAY_TYPE{
            int     iListClass;
            int     iListType;
            char    szTypeName[31];
            char    szTransCode[9];
        }tPayType;

        char    szPsamNo[17], szGenDate[9];
        int    iTransType, iCnt, iTelNo, iListClass, iListType, iListNo;
    EXEC SQL END DECLARE SECTION;

    int    iCurPos, iCmdLen, iCmdNum, iRet, iDataLen, iDataNum;
    int    iPreCmdLen, iPreCmdNum;
    long    lAmt;
    char    szTmpStr[50], szBuf[512], szCmd[512], szPayData[512];
    char    szPreCmd[50], szDataSource[30];
    int    iCtlLen;
    char   szCtlPara[101];

    //���ķ����ף������ж��Ƿ���comweb
    strcpy( ptAppStru->szAuthCode, "YES" );

    ptAppStru->iReservedLen = 0;

    strcpy( szPsamNo, ptAppStru->szPsamNo );

    //�ն˷����ϴ��ʵ����ؽ��
    if( memcmp( ptAppStru->szTransCode, "00", 2 ) != 0 )
    {
        //�ʵ����سɹ��������ʵ����ر�ʶ
        if( memcmp( ptAppStru->szHostRetCode, "00", 2 ) == 0 )
        {
            memcpy( szTmpStr, ptAppStru->szReserved+1, 3 );    
            szTmpStr[3] = 0;
            iListClass = atol(szTmpStr);

            memcpy( szTmpStr, ptAppStru->szReserved+4, 3 );    
            szTmpStr[3] = 0;
            iListType = atol(szTmpStr);

            memcpy( szGenDate, ptAppStru->szReserved+7, 8 );    
            szGenDate[8] = 0;

            memcpy( szTmpStr, ptAppStru->szReserved+15, 6 );    
            szTmpStr[6] = 0;
            iListNo = atol(szTmpStr);

            EXEC SQL UPDATE PAY_LIST set down = 'Y'
            WHERE psam_no = :szPsamNo  and 
                  list_class = :iListClass and
                  list_type = :iListType and
                  gen_date = :szGenDate and
                  list_no = :iListNo;
            if( SQLCODE )
            {
                ptAppStru->iReservedLen = 0;
                strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
                WriteLog( ERROR, "update PAY_LIST fail %d", SQLCODE );
                RollbackTran();
                return FAIL;
            }
            CommitTran();
        }
    }

    //�ն˷����ϴν��׽�������û����ն�&comweb
    if( memcmp( ptAppStru->szTransCode, "FF", 2 ) == 0 )
    {
        strcpy( ptAppStru->szAuthCode, "NO" );
        strcpy( ptAppStru->szRetCode, TRANS_SUCC );
        return SUCC;
    }

    EXEC SQL SELECT count(*) INTO :iCnt
    FROM PAY_LIST
    WHERE PSAM_NO = :szPsamNo  and DOWN_FLAG = 'N' and PAY_STATUS = 'N';
    if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "count PAY_LIST fail %d", SQLCODE );
        return FAIL;
    }

    //��δ֧���ʵ�
    if( iCnt == 0 )
    {
        strcpy( ptAppStru->szRetCode, ERR_NOT_PAYLIST );
        WriteLog( ERROR, "not PAY_LIST" );
        return FAIL;
    }
    
    EXEC SQL DECLARE pay_cur cursor for
    SELECT 
        PSAM_NO,
        NVL(LIST_CLASS,0),
        NVL(LIST_TYPE,0),
        NVL(GEN_DATE,' '),
        NVL(LIST_NO, 0),
        NVL(LIST_DATA,' '),
        NVL(AMUONT,0.00),
        NVL(PAY_DATE,' '),
        NVL(DOWN_FLAG,'N'),
        NVL(PAY_STATUS,'N')        
    FROM PAY_LIST
    WHERE psam_no = :szPsamNo and down_flag = 'N' and pay_status = 'N'
    ORDER BY  gen_date, list_no;
    if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "declare pay_cur fail %d", SQLCODE );
        EXEC SQL CLOSE pay_cur;
        return FAIL;
    }

    EXEC SQL OPEN pay_cur;
    if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "open pay_cur fail %d", SQLCODE );
        EXEC SQL CLOSE pay_cur;
        return FAIL;
    }

    iCurPos = 0;
    EXEC SQL FETCH pay_cur 
    INTO :tPayList;
    if( SQLCODE == SQL_NO_RECORD )
    {
        strcpy( ptAppStru->szRetCode, ERR_NOT_PAYLIST );
        WriteLog( ERROR, "not PAY_LIST" );
        EXEC SQL CLOSE pay_cur;
        return FAIL;
    }
    else if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "fetch pay_cur fail %d", SQLCODE );
        EXEC SQL CLOSE pay_cur;
        return FAIL;
    }
    EXEC SQL CLOSE pay_cur;

    lAmt = (long)(tPayList.dAmount*100.0+0.5);
    sprintf( ptAppStru->szAmount, "%012ld", lAmt );

    //��ȡ֧����Ŀ˵�����������״���
    EXEC SQL SELECT 
        LIST_CLASS,
        NVL(LIST_TYPE,0),
        NVL(TYPE_NAME,' '),
        NVL(TRANS_CODE,' ')
    INTO 
        :tPayType.iListClass,
        :tPayType.iListType,
        :tPayType.szTypeName,
        :tPayType.szTransCode
    FROM PAY_TYPE 
    WHERE list_class = :tPayList.iListClass and
          list_type = :tPayList.iListType;
    if( SQLCODE == SQL_NO_RECORD )
    {
        strcpy( ptAppStru->szRetCode, ERR_INVALID_PAYLIST );
        WriteLog( ERROR, "list_class[%d] list_type[%d] not exist", tPayList.iListClass, tPayList.iListType);
        return FAIL;
    }
    else if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "get pay_type fail %d", SQLCODE );
        return FAIL;
    }

    //֧����Ŀ˵������
    DelTailSpace( tPayType.szTypeName);
    szBuf[iCurPos] = strlen( tPayType.szTypeName);
    iCurPos ++;
    //֧����Ŀ˵��
    memcpy( szBuf+iCurPos, tPayType.szTypeName, strlen(tPayType.szTypeName) );
    iCurPos += strlen(tPayType.szTypeName);

    //���״���
    AscToBcd( (uchar*)tPayType.szTransCode, 8, 0 ,(uchar*)szBuf+iCurPos);
    iCurPos += 4;

    EXEC SQL SELECT trans_type, telephone_no 
    INTO :iTransType, :iTelNo
    FROM TRANS_DEF 
    WHERE TRANS_CODE = :tPayType.szTransCode;
    if( SQLCODE == SQL_NO_RECORD )
    {
        strcpy( ptAppStru->szRetCode, ERR_INVALID_PAYLIST );
        WriteLog( ERROR, "trans[%s] not exist", tPayType.szTransCode );
        return FAIL;
    }
    else if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "SELECT trans_def fail[%d]", SQLCODE );
        return FAIL;
    }

    iRet = GetCommands( iTransType, '0', szCmd, &iCmdNum, &iCmdLen,
        szDataSource, &iDataNum ,&iCtlLen,szCtlPara);
    if( iRet != SUCC )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "get command fail" );
        return FAIL;
    }

    //����(��淶��һ�£�֣��˵�������ж���һλ)
    szBuf[iCurPos] = 0x00;
    iCurPos ++;

    //���̴��볤��
    szBuf[iCurPos] = iCmdLen+1;
    iCurPos ++;
    //���̴���(�����̴������)
    szBuf[iCurPos] = iCmdNum;
    iCurPos ++;
    memcpy( szBuf+iCurPos, szCmd, iCmdLen );
    iCurPos += iCmdLen;

    DelTailSpace( tPayList.szListData );
    //��֯�ʵ�֧������
    iDataLen = 0;    
    //����ϵͳ�������
    szPayData[iDataLen] = iTelNo;
    iDataLen++;
    //�ʵ�����
    sprintf( szPayData+iDataLen, "%03ld", tPayList.iListClass);
    iDataLen += 3;
    //�ʵ�С��
    sprintf( szPayData+iDataLen, "%03ld", tPayList.iListType);
    iDataLen += 3;
    //�ʵ�����
    memcpy( szPayData+iDataLen, tPayList.szGenDate, 8 );
    iDataLen += 8;
    //�ʵ�˳���
    sprintf( szPayData+iDataLen, "%06ld", tPayList.iListNo);
    iDataLen += 6;
    //�ʵ�����
    memcpy( szPayData+iDataLen, tPayList.szListData, strlen(tPayList.szListData) );
    iDataLen += strlen(tPayList.szListData);

    sprintf( ptAppStru->szPan, "%03ld%03ld%6.6s%06ld", tPayList.szListData,
        tPayList.iListType, tPayList.szGenDate+2, tPayList.iListNo);

    //�ʵ�֧�����ݳ���
    szBuf[iCurPos] = iDataLen;
    iCurPos ++;
    memcpy( szBuf+iCurPos, szPayData, iDataLen );
    iCurPos += iDataLen;

    if( iCurPos > 255 )
    {
        WriteLog( ERROR, "����̫��[%d]", iCurPos );
        strcpy( ptAppStru->szRetCode, ERR_DATA_TOO_LONG );
        return FAIL;
    }

    ptAppStru->iReservedLen = iCurPos;
    memcpy( ptAppStru->szReserved, szBuf, iCurPos );
    
    /* ��Ҫ���к������� */
    if( iCnt > 1 )
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
        memcpy( ptAppStru->szCommand+iCmdLen, "\x9E", 1 );    //�洢�ʵ�
        iCmdLen += 1;

        memcpy( ptAppStru->szCommand+iCmdLen, szPreCmd, iPreCmdLen );
        iCmdLen += iPreCmdLen;

        ptAppStru->iCommandNum = iPreCmdNum+1;
        ptAppStru->iCommandLen = iCmdLen;

        //��Ҫ���к������أ�����comweb
        strcpy( ptAppStru->szAuthCode, "NO" );
    }
    //�ʵ��������
    else
    {
        strcpy( ptAppStru->szNextTransCode, "FF" );
        memcpy( ptAppStru->szNextTransCode+2, ptAppStru->szTransCode+2, 6 );
        ptAppStru->szNextTransCode[8] = 0;
    }

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}
