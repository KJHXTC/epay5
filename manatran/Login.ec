/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:�ն�ǩ���ཻ��

** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.3 $
$Log: Login.ec,v $
Revision 1.3  2013/01/24 07:41:31  wukj
QLCODE��ӡ��ʽ�޸�Ϊ%d

Revision 1.2  2012/12/27 07:21:09  fengw

1�������ַ�����ʼ����䡣

Revision 1.1  2012/12/18 10:23:33  wukj
*** empty log message ***

Revision 1.9  2012/12/18 04:29:59  wukj
*** empty log message ***

Revision 1.8  2012/12/05 06:32:01  wukj
*** empty log message ***

Revision 1.7  2012/12/03 03:25:08  wukj
int����ǰ׺�޸�Ϊi

Revision 1.6  2012/11/29 10:09:03  wukj
��־,bcdascת�����޸�

Revision 1.5  2012/11/20 07:45:39  wukj
�滻\tΪ�ո����

Revision 1.4  2012/11/19 01:58:29  wukj
�޸�app�ṹ����,����ͨ��

Revision 1.3  2012/11/16 08:38:12  wukj
�޸�app�ṹ��������

Revision 1.2  2012/11/16 03:25:05  wukj
����CVS REVSION LOGע��

*******************************************************************/

# include "manatran.h"

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
    EXEC SQL INCLUDE "../incl/DbStru.h";
EXEC SQL EnD DECLARE SECTION;
#endif


extern int gnSpec;

int
//proc_echo_test( ptAppStru ) 
ProcEchoTest( ptAppStru ) 
T_App    *ptAppStru;
{
    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}

/*****************************************************************
** ��    ��:���°�ȫģ�鹤����Կ��״̬
** �������:
           ptAppStru->szPsamNo
** �������:
           ptAppStru->szReserved        �·����ն˵���Կ��Ϣ
           ptAppStru->iReservedLen    ��Ϣ����
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
Login( ptAppStru ) 
T_App    *ptAppStru;
{
    EXEC SQL BEGIN DECLARE SECTION;
        char szPsamNo[17], szTmk[33];
        long    lPosTrace;

        int     iKeyIndex;
        char    szMasterKey[33];
        char    szMasterKeyLMK[33];
        char    szMasterChk[5];
        char    szPinKey[33];
        char    szMacKey[33];
        char    szMagKey[33];
    EXEC SQL END DECLARE SECTION;

    char szBuf[512], szKey[17], szCheckVal[9];
    char szKeyData[256];
    int i, iCurPos, iTotalRecNum, iRet;

    strcpy( szPsamNo, ptAppStru->szPsamNo );

    /*ȡPOS��ǰ��ˮ�ţ��Ա��ն˸��µ�ǰ��ˮ��*/
    EXEC SQL select cur_trace into :lPosTrace
    from terminal
    where psam_no = :szPsamNo;
    if( SQLCODE == SQL_NO_RECORD )
    {
        WriteLog( ERROR, "term[%s] not exist", szPsamNo );
        strcpy( ptAppStru->szRetCode, ERR_INVALID_TERM );
        return FAIL;
    }
    else if( SQLCODE )
    {
        WriteLog( ERROR, "select trace fail %d", SQLCODE );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }
    ptAppStru->lPosTrace = lPosTrace;

    /* ȡ�ն�����Կ���� */
    memcpy( szBuf, ptAppStru->szPsamNo+8, 8 );
    szBuf[8] = 0;
    iKeyIndex = atol(szBuf);

    EXEC SQL SELECT 
            master_key_LMK 
    INTO :szTmk
    FROM pos_key 
    WHERE key_index = :iKeyIndex;
    if( SQLCODE == SQL_NO_RECORD )
    {
        strcpy( ptAppStru->szRetCode, ERR_NOT_KEY );
        WriteLog( ERROR, "invalid key_index[%s]", ptAppStru->szPsamNo );
        return FAIL;
    }
    else if( SQLCODE )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "select master_key fail %d", SQLCODE );
        return FAIL;
    }
    
    /* ���ܻ�������ɹ�����Կ */
    memcpy( szKeyData, szTmk, 32 );
    iRet = HsmGetWorkKey( ptAppStru, szKeyData );
    if( iRet != SUCC )
    {
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "get hsm work key fail" );
        return FAIL;
    }
    
    memset(szPinKey, 0, sizeof(szPinKey));
    memset(szMacKey, 0, sizeof(szMacKey));
    memset(szMagKey, 0, sizeof(szMagKey));

    memcpy( szPinKey, szKeyData, 32 );
    memcpy( szMacKey, szKeyData+80, 32 );
        memcpy( szMagKey, szKeyData+160, 32 );

    EXEC SQL UPDATE pos_key 
        SET pin_key = :szPinKey, mac_key = :szMacKey,
            mag_key = :szMagKey
        WHERE key_index = :iKeyIndex;
    if( SQLCODE )
    {
        WriteLog( ERROR, "update pos_key fail!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        RollbackTran();
        return FAIL;
    }
    CommitTran();

    iTotalRecNum = 0;
    iCurPos = 0;

    for( i=8; i<=14; i++ )
    {
        //ֻ�õ�������Կ������������Կ
        if( i == 9 || i == 10 || i == 14 )
        {
            continue;
        }

        szBuf[iCurPos] = i;    //��ȫģ�鿨�м�¼��
        iCurPos ++;
        switch (i){
        //��ȫģ��״̬
        case 8:
            szBuf[iCurPos] = 1;    //���ݳ���
            iCurPos ++;
            szBuf[iCurPos] = '0';
            iCurPos ++;
            iTotalRecNum ++;
            break;
        //����PINKEY
        case 9:
            szBuf[iCurPos] = 20;    //��Կ����
            iCurPos ++;

            AscToBcd( (uchar *)(szKeyData+32), 40, 0 ,(uchar *)(szBuf+iCurPos));
            iCurPos += 20;

            iTotalRecNum ++;
            break;
        //����MACKEY
        case 10:
            szBuf[iCurPos] = 20;    //��Կ����
            iCurPos ++;

            AscToBcd( (uchar *)(szKeyData+112), 40, 0 ,(uchar *)(szBuf+iCurPos));
            iCurPos += 20;

            iTotalRecNum ++;
            break;
        //����������PINKEY
        case 11:
            szBuf[iCurPos] = 20;    //��Կ����
            iCurPos ++;

            AscToBcd( (uchar *)(szKeyData+32), 40, 0 ,(uchar *)(szBuf+iCurPos));
            iCurPos += 20;

            iTotalRecNum ++;
            break;
        //����������MACKEY
        case 12:
            szBuf[iCurPos] = 20;    //��Կ����
            iCurPos ++;

            AscToBcd( (uchar *)(szKeyData+112), 40, 0 ,(uchar *)(szBuf+iCurPos));
            iCurPos += 20;

            iTotalRecNum ++;
            break;
        //����������MAGKEY
        case 13:
            szBuf[iCurPos] = 20;    //��Կ����
            iCurPos ++;
            
            AscToBcd( (uchar *)(szKeyData+192), 40, 0 ,(uchar *)(szBuf+iCurPos));
            iCurPos += 20;

            iTotalRecNum ++;
            break;
        //����MAGKEY
        case 14:
            szBuf[iCurPos] = 20;    //��Կ����
            iCurPos ++;

            AscToBcd( (uchar *)(szKeyData+192), 40, 0 ,(uchar *)(szBuf+iCurPos));
            iCurPos += 20;

            iTotalRecNum ++;
            break;
        }
    }

    ptAppStru->szReserved[0] = iTotalRecNum;
    memcpy( ptAppStru->szReserved+1, szBuf, iCurPos );
    ptAppStru->iReservedLen = iCurPos+1;

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}


/*****************************************************************
** ��    ��:���°�ȫģ�鹤����Կ��״̬
** �������:
           ptAppStru->szPsamNo
** �������:
           ptAppStru->szReserved        �·����ն˵���Կ��Ϣ
           ptAppStru->iReservedLen    ��Ϣ����
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
Login39( ptAppStru )
T_App     *ptAppStru;
{
        EXEC SQL BEGIN DECLARE SECTION;
                char szPsamNo[17], szTmk[33];
                long    lPosTrace;

                int     iKeyIndex;
                char    szMasterKey[33];
                char    szMasterKeyLMK[33];
                char    szMasterChk[5];
                char    szPinKey[33];
                char    szMacKey[33];
                char    szMagKey[33];
        EXEC SQL END DECLARE SECTION;

        char szBuf[512], szKey[17], szCheckVal[9];
        char szKeyData[256];
        int i, iCurPos, iRet;

        strcpy( szPsamNo, ptAppStru->szPsamNo );

        /*ȡPOS��ǰ��ˮ�ţ��Ա��ն˸��µ�ǰ��ˮ��*/
        EXEC SQL select cur_trace into :lPosTrace
        from terminal
        where psam_no = :szPsamNo;
        if( SQLCODE == SQL_NO_RECORD )
        {
                WriteLog( ERROR, "term[%s] not exist", szPsamNo );
                strcpy( ptAppStru->szRetCode, ERR_INVALID_TERM );
                return FAIL;
        }
        else if( SQLCODE )
        {
             WriteLog( ERROR, "select trace fail %d", SQLCODE );
                strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
                return FAIL;
        }
        ptAppStru->lPosTrace = lPosTrace;

        /* ȡ�ն�����Կ���� */
        memcpy( szBuf, ptAppStru->szPsamNo+8, 8 );
        szBuf[8] = 0;
        iKeyIndex = atol(szBuf);

        EXEC SQL SELECT 
                master_key_LMK 
        INTO :szTmk
        FROM pos_key
        WHERE key_index = :iKeyIndex;
        if( SQLCODE == SQL_NO_RECORD )
        {
                strcpy( ptAppStru->szRetCode, ERR_NOT_KEY );
                WriteLog( ERROR, "invalid key_index[%s]", ptAppStru->szPsamNo );
                return FAIL;
        }
        else if( SQLCODE )
        {
                strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
                WriteLog( ERROR, "select master_key fail %d", SQLCODE );
                return FAIL;
        }

        /* ���ܻ�������ɹ�����Կ */
        memcpy( szKeyData, szTmk, 32 );
        iRet = HsmGetWorkKey( ptAppStru, szKeyData );
        if( iRet != SUCC )
        {
                strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
                WriteLog( ERROR, "get hsm work key fail" );
                return FAIL;
        }

        memcpy( szPinKey, szKeyData, 32 );
        memcpy( szMacKey, szKeyData+80, 32 );
        memcpy( szMagKey, szKeyData+160, 32 );

        EXEC SQL UPDATE pos_key
                SET pin_key = :szPinKey, mac_key = :szMacKey,
                    mag_key = :szMagKey
                WHERE key_index = :iKeyIndex;
        if( SQLCODE )
        {        
                WriteLog( ERROR, "update pos_key fail %d", SQLCODE );
                strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
                RollbackTran();
                return FAIL;
        }
        CommitTran();

        iCurPos = 0;
        for( i=1; i<=3; i++ )
        {           

            switch (i){
            //PINKEY
            case 1:
                    szBuf[iCurPos] = 41;    //������¼��
                    iCurPos ++;
                    szBuf[iCurPos] = 16;    //��Կ����
                    iCurPos ++;

                    AscToBcd( (uchar *)(szKeyData+32), 32, 0 ,(uchar *)(szBuf+iCurPos));
                    iCurPos += 16;

                    break;
            //MACKEY
            case 2:
                    szBuf[iCurPos] = 42;    //������¼��
                    iCurPos ++;
                    szBuf[iCurPos] = 16;    //��Կ����
                    iCurPos ++;

                    AscToBcd( (uchar *)(szKeyData+112), 32, 0 ,(uchar *)(szBuf+iCurPos));
                    iCurPos += 16;
                    break;               
            //MAGKEY
            case 3:
                    szBuf[iCurPos] = 43;    //������¼��
                    iCurPos ++;
                    szBuf[iCurPos] = 16;    //��Կ����
                    iCurPos ++;

                    AscToBcd( (uchar *)(szKeyData+192), 32, 0 ,(uchar *)(szBuf+iCurPos));
                    iCurPos += 16;

                    break;                
            }
        }

    /* ��Կ������ */
        ptAppStru->szReserved[0] = 0x00;
        memcpy( ptAppStru->szReserved+1, szBuf, iCurPos );
        ptAppStru->iReservedLen = iCurPos+1;
        strcpy( ptAppStru->szRetCode, TRANS_SUCC );
        return ( SUCC );
}
