/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:��̬�˵����ƺ���

** �� �� ��:Robin
** ��������:2009/08/29


<<<<<<< control.ec
$Revision: 1.4 $
=======
$Revision: 1.4 $
>>>>>>> 1.13
$Log: Control.ec,v $
Revision 1.4  2013/01/24 07:41:31  wukj
QLCODE��ӡ��ʽ�޸�Ϊ%d

Revision 1.3  2012/12/24 04:45:03  wukj
GetCommans����ָ�����

Revision 1.2  2012/12/21 01:38:58  wukj
*** empty log message ***

Revision 1.1  2012/12/18 10:23:01  wukj
*** empty log message ***

Revision 1.15  2012/12/18 04:57:16  wukj
*** empty log message ***

Revision 1.14  2012/12/18 04:37:53  wukj
*** empty log message ***

<<<<<<< control.ec
Revision 1.11  2012/12/11 03:31:59  chenrb
iMenuItem�޸ĳ�iaMenuItem

=======
Revision 1.13  2012/12/17 09:26:07  wukj
*** empty log message ***

Revision 1.12  2012/12/14 02:09:24  wukj
*** empty log message ***

Revision 1.11  2012/12/11 03:31:59  chenrb
iMenuItem�޸ĳ�iaMenuItem

>>>>>>> 1.13
Revision 1.10  2012/12/10 05:32:12  wukj
*** empty log message ***

Revision 1.9  2012/12/05 06:32:01  wukj
*** empty log message ***

Revision 1.8  2012/12/03 03:25:08  wukj
int����ǰ׺�޸�Ϊi

Revision 1.7  2012/11/29 10:09:03  wukj
��־,bcdascת�����޸�

Revision 1.6  2012/11/20 07:45:39  wukj
�滻\tΪ�ո����

Revision 1.5  2012/11/19 01:58:29  wukj
�޸�app�ṹ����,����ͨ��

Revision 1.4  2012/11/16 08:38:12  wukj
�޸�app�ṹ��������

Revision 1.3  2012/11/16 06:27:09  wukj
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


/**************************************************************************
 �������ܣ�
                ���Žɷѿ��ƺ���
 ��ڲ�����
                T_App *ptAppStru           �ڲ��ṹ��
 ���ڲ�����
                T_App *ptAppStru           �ڲ��ṹ��
 ��    �أ�
                FAIL            ʧ��
                SUCC            �ɹ�
 ��    �ߣ�
                Robin
 ��    �ڣ�
                2009/03/22
 �� �� �ˣ�        gaomx

 �޸����ڣ�        2011/01/07

 *************************************************************************/
int ChinaunicomControlBak( ptAppStru ) 
T_App    *ptAppStru;
{
    int iRet, iCmdLen, iCmdNum, iDataNum;
    char szCmd[512], szFlag[2], szDataSource[30];
    int iCtlLen;
    char  szCtlPara[101];

    //�����ɷѣ����ú����������̣����ô���
    if( ptAppStru->szReserved[0] == '1' )
    {
    }
    //���ɷѣ��Ҷ���·
    else if( ptAppStru->szReserved[0] == '0' )
    {
        //�����ն����̴���(ָ�������)
        ptAppStru->iCommandNum = 1;
        //�����ն����̴���(ָ���뼯)
        iCmdLen = 0;
        memcpy( ptAppStru->szCommand+iCmdLen, "\xA6", 1 );    //�Ҷ���·
        iCmdLen += 1;
        ptAppStru->iCommandLen = iCmdLen;
    }
    //�������(����0��Ҳ����1)����������
    else
    {
        memcpy( ptAppStru->szNextTransCode, ptAppStru->szTransCode, 8 );
                szFlag[0] = '0';        //֮ǰָ��
                szFlag[1] = 0;

        iRet = GetCommands( ptAppStru->iTransType, szFlag[0], szCmd,
                        &iCmdNum, &iCmdLen, szDataSource, &iDataNum ,&iCtlLen,szCtlPara);
        if( iRet != SUCC )
        {
            WriteLog( ERROR, "get commands fail" );
            strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
            return FAIL;
        }
        memcpy( ptAppStru->szDataSource, szDataSource, iDataNum );
        ptAppStru->iDataNum = iDataNum;
        ptAppStru->iCommandNum = iCmdNum;
        ptAppStru->iCommandLen = iCmdLen;
        memcpy( ptAppStru->szCommand, szCmd, iCmdLen );
        //����ָ�����
        ptAppStru->iControlLen = iCtlLen;
        memcpy(ptAppStru->szControlPara,szCtlPara,iCtlLen);
    }

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );

    return ( SUCC );
}

/**************************************************************************
 �������ܣ�
                ��̬�˵����ƺ���
 ��ڲ�����
                T_App *ptAppStru           �ڲ��ṹ��
 ���ڲ�����
                T_App *ptAppStru           �ڲ��ṹ��
 ��    �أ�
                FAIL            ʧ��
                SUCC            �ɹ�
 ��    �ߣ�
                Robin
 ��    �ڣ�
                2009/03/22
 �� �� �ˣ�        gaomx

 �޸����ڣ�        2011/01/07

 *************************************************************************/
int DynamicControl( ptAppStru ) 
T_App    *ptAppStru;
{
    int i, iTransType, iRet, iCmdLen, iCmdNum, iDataNum;
    char szCmd[512], szDataSource[30];
    int iCtlLen;
    char szCtlPara[101];
    
    EXEC SQL BEGIN DECLARE SECTION;
        int    iMenuItem, iRecNo1;

        int     iRecNo;
        char    szMenuTitle[31];
        char    szDescribe[41];
        int     iMenuNum;
        char    szMenuName1[21];
        char    szTransCode1[9];
        char    szMenuName2[21];
        char    szTransCode2[9];
        char    szMenuName3[21];
        char    szTransCode3[9];
        char    szMenuName4[21];
        char    szTransCode4[9];
        char    szMenuName5[21];
        char    szTransCode5[9];
        char    szMenuName6[21];
        char    szTransCode6[9];
        char    szMenuName7[21];
        char    szTransCode7[9];
        char    szMenuName8[21];
        char    szTransCode8[9];
        char    szMenuName9[21];
        char    szTransCode9[9];
    EXEC SQL END DECLARE SECTION;

    char    szTransCode[9];

    for( i=0; i<ptAppStru->iMenuNum; i++ )
    {
        iMenuItem = ptAppStru->iaMenuItem[i];
        iRecNo1 = ptAppStru->iMenuRecNo[i];

        EXEC SQL SELECT 
                REC_NO,
                NVL(MENU_TITLE,' '),
                NVL(DESCRIBE,' '),
                NVL(MENU_NUM ,0),
                NVL(MENU_NAME1 ,' '),
                NVL(TRANS_CODE1 ,' '),
                NVL(MENU_NAME2 ,' '),
                NVL(TRANS_CODE2 ,' '),
                NVL(MENU_NAME3, ' '),
                NVL(TRANS_CODE3 ,' '),
                NVL(MENU_NAME4 ,' '),
                NVL(TRANS_CODE4, ' '),
                NVL(MENU_NAME5  , ' '),
                NVL(TRANS_CODE5 , ' '),
                NVL(MENU_NAME6 , ' '),
                NVL(TRANS_CODE6 ,' '),
                NVL(MENU_NAME7 ,' '),
                NVL(TRANS_CODE7 ,' '),
                NVL(MENU_NAME8 ,' '),
                NVL(TRANS_CODE8 , ' '),
                NVL(MENU_NAME9  ,' '),
                NVL(TRANS_CODE9 ,' ')
        INTO 
                :iRecNo,
                :szMenuTitle,
                :szDescribe,
                :iMenuNum,
                :szMenuName1,
                :szTransCode1,
                :szMenuName2,
                :szTransCode2,
                :szMenuName3,
                :szTransCode3,
                :szMenuName4,
                :szTransCode4,
                :szMenuName5,
                :szTransCode5,
                :szMenuName6,
                :szTransCode6,
                :szMenuName7,
                :szTransCode7,
                :szMenuName8,
                :szTransCode8,
                :szMenuName9,
                :szTransCode9
        FROM dynamic_menu
        WHERE   REC_NO = :iRecNo1;
        if( SQLCODE == SQL_NO_RECORD )
        {
            strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
            WriteLog(ERROR, "dynamic menu[%ld] not exist", iRecNo);
            return FAIL;
        }
        else if( SQLCODE )
        {
            strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
            WriteLog( ERROR, "get dynamic menu fail %d", SQLCODE );
            return FAIL;
        }

        switch (iMenuItem){
        /* �û������ؼ����˳��� */
        case 0:
            strcpy( szTransCode, STOP_PAY_CODE );
            break;
        case 1:
            strcpy( szTransCode, szTransCode1 );
            break;
        case 2:
            strcpy( szTransCode, szTransCode2 );
            break;
        case 3:
            strcpy( szTransCode, szTransCode3 );
            break;
        case 4:
            strcpy( szTransCode, szTransCode4 );
            break;
        case 5:
            strcpy( szTransCode, szTransCode5 );
            break;
        case 6:
            strcpy( szTransCode, szTransCode6 );
            break;
        case 7:
            strcpy( szTransCode, szTransCode7 );
            break;
        case 8:
            strcpy( szTransCode, szTransCode8 );
            break;
        case 9:
            strcpy( szTransCode, szTransCode9 );
            break;
        }

        iRet = GetTranType( szTransCode, &iTransType );
        if( iRet != SUCC )
        {
            WriteLog( ERROR, "get trans_type fail" );
            strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
            return FAIL;
        }

        iRet = GetCommands(iTransType, '0', szCmd, &iCmdNum, &iCmdLen,
            szDataSource, &iDataNum);
        if( iRet != SUCC )
        {
            strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
            WriteLog( ERROR, "get command fail" );
            return FAIL;
        }

        if( i == 0 )
        {
            strcpy( ptAppStru->szNextTransCode, szTransCode );
        }
        memcpy( ptAppStru->szDataSource+ptAppStru->iDataNum, szDataSource, 
            iDataNum );
        ptAppStru->iDataNum += iDataNum;
        memcpy( ptAppStru->szCommand+ptAppStru->iCommandLen, szCmd, iCmdLen );
        ptAppStru->iCommandNum += iCmdNum;
        ptAppStru->iCommandLen += iCmdLen;
        //����ָ�����
        memcpy(ptAppStru->szControlPara + ptAppStru->iControlLen,szCtlPara,iCtlLen);
        ptAppStru->iControlLen += iCtlLen;
    }

    strcpy( ptAppStru->szRetCode, TRANS_SUCC );

    return ( SUCC );
}


int GetDynamicMenu( ptAppStru ) 
T_App    *ptAppStru;
{
    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}
