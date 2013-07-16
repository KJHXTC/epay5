/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:TMS��غ���

** �����б�:
** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.1 $
$Log: DownTmsDataMs.ec,v $
Revision 1.1  2012/12/18 04:57:16  wukj
*** empty log message ***


*******************************************************************/

# include "manatran.h"

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
        EXEC SQL INCLUDE SQLCA;
EXEC SQL EnD DECLARE SECTION;
#endif

/*****************************************************************
** ��    ��:TMS֪ͨ��������, TMS�������������б�׼
** �������:
        
** �������:
           tmsdata 
           tms_len
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
int DownTmsDataMs( ptAppStru ) 
T_App    *ptAppStru;
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szShopNo[20+1];
        char     szPosNo[20+1];

        char    szSysCode[8+1];       /*ƽ̨��ʶ��*/
        char    szDownBitMap[2+1];    /*�������ݱ�־*/
        char    szDownFileName[72+1]; /*�����ļ���*/
        char    szValidDate[8+1];         /*��������*/
        char    szAppName[72+1];          /*Ӧ�ñ�ʶ*/
        char    szDownTypeFlag[4+1];  /*����ʱ����ʾ*/
        char    szTmsTelNo1[20+1];        /*TMS�绰����1*/
        char    szTmsTelNo2[20+1];        /*TMS�绰����2*/
        char    szTmsIpPort1[30+1];       /*TMS IP�Ͷ˿�1*/
        char    szTmsIpPort2[30+1];       /*TMS IP�Ͷ˿�2*/
        char    szDownTime[14+1];         /*TMS����ʱ��*/
    EXEC SQL END DECLARE SECTION;
    int iPos = 0;
    char szTmsPara[310+1];
    memset(szTmsPara, 0, sizeof(szTmsPara));
    memset(szShopNo, 0, sizeof(szShopNo));
    memset(szPosNo, 0, sizeof(szPosNo));
    strcpy(szShopNo, ptAppStru->szShopNo);
    strcpy(szPosNo, ptAppStru->szPosNo);
        
    EXEC SQL SELECT NOTICE_BTIME,NOTICE_EDATE
    INTO   :szDownTime,
           :szValidDate
    FROM   TM_VPOS_INFO
    WHERE  TRIM(SHOPNO) = :szShopNo
             AND    TRIM(POSNO)  = :szPosNo
             AND    NOTICE_FLAG = '1'; 
    if( SQLCODE )
    {
        WriteLog( ERROR, "TM_VPOS_INFO %d", SQLCODE );
        return( FAIL );
    }
    
    WriteLog( TRACE, "szDownTime=[%s]",szDownTime);
    memcpy(szTmsPara+iPos,szDownTime ,14);
    iPos +=14;
    WriteLog( TRACE, "szValidDate=[%s]",szValidDate);
    memcpy(szTmsPara+iPos,szValidDate ,8);
    iPos +=8;
WriteLog( TRACE, "szTmsTelNo1=[%s]",szTmsTelNo1);
    sprintf(szTmsPara+iPos,"%-40.40s",szTmsTelNo1);
    iPos +=40;
WriteLog( TRACE, "szTmsTelNo2=[%s]",szTmsTelNo2);
    sprintf(szTmsPara+iPos,"%-40.40s",szTmsTelNo2);
    iPos +=40;
        
    ptAppStru->iTmsLen = iPos;
    memcpy(ptAppStru->szTmsData, szTmsPara, iPos);
    ptAppStru->szTmsData[iPos]=0;
WriteLog( TRACE, "shopno=[%s],posno=[%s]",szShopNo,szPosNo);        
    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}
