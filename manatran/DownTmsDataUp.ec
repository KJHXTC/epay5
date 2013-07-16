/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:TMS��غ���

** �����б�:
** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.1 $
$Log: DownTmsDataUp.ec,v $
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
** ��    ��:TMS֪ͨ��������,TMS������������׼
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
int DownTmsDataUp( ptAppStru ) 
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
    
    memcpy(szTmsPara+iPos,"26" ,2);
    iPos +=2;

    memcpy(szTmsPara+iPos,szSysCode ,8);
    iPos +=8;
    memcpy(szTmsPara+iPos,"27" ,2);
    iPos +=2;
    memcpy(szDownBitMap,"02",2);
    memcpy(szTmsPara+iPos,szDownBitMap ,2);
    iPos +=2;
    memcpy(szTmsPara+iPos,"28" ,2);
    iPos +=2;
    sprintf(szDownFileName,"%-72.72s","���ز����ļ�");
    memcpy(szTmsPara+iPos,szDownFileName ,72);
    iPos +=72;
    memcpy(szTmsPara+iPos,"29" ,2);
    iPos +=2;
WriteLog( TRACE, "szValidDate=[%s]",szValidDate);
    memcpy(szTmsPara+iPos,szValidDate ,8);
    iPos +=8;
    memcpy(szTmsPara+iPos,"30" ,2);
    iPos +=2;
    sprintf(szAppName,"%-72.72s","Ӧ������");
    memcpy(szTmsPara+iPos,szAppName ,72);
    iPos +=72;
    memcpy(szTmsPara+iPos,"31" ,2);
    iPos +=2;
    memcpy(szTmsPara+iPos,"1001" ,4);
    iPos +=4;
    memcpy(szTmsPara+iPos,"32" ,2);
    iPos +=2;
WriteLog( TRACE, "szTmsTelNo1=[%s]",szTmsTelNo1);
    memcpy(szTmsPara+iPos,szTmsTelNo1 ,20);
    iPos +=20;
    memcpy(szTmsPara+iPos,"33" ,2);
    iPos +=2;
WriteLog( TRACE, "szTmsTelNo2=[%s]",szTmsTelNo2);
    memcpy(szTmsPara+iPos,szTmsTelNo2 ,20);
    iPos +=20;
    memcpy(szTmsPara+iPos,"34" ,2);
    iPos +=2;
WriteLog( TRACE, "szTmsIpPort1=[%s]",szTmsIpPort1);
    memcpy(szTmsPara+iPos,szTmsIpPort1 ,30);
    iPos +=30;
    memcpy(szTmsPara+iPos,"35" ,2);
    iPos +=2;
WriteLog( TRACE, "szTmsIpPort2=[%s]",szTmsIpPort2);
    memcpy(szTmsPara+iPos,szTmsIpPort2 ,30);
    iPos +=30;
    memcpy(szTmsPara+iPos,"36" ,2);
    iPos +=2;
WriteLog( TRACE, "szDownTime=[%s]",szDownTime);
    memcpy(szTmsPara+iPos,szDownTime ,14);
    iPos +=14;
        
    ptAppStru->iTmsLen = iPos;
    memcpy(ptAppStru->szTmsData, szTmsPara, iPos);
    ptAppStru->szTmsData[iPos]=0;
WriteLog( TRACE, "shopno=[%s],posno=[%s]",szShopNo,szPosNo);        
    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}

