/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:TMS��غ���

** �����б�:
** �� �� ��:Robin
** ��������:2009/08/29


$Revision: 1.1 $
$Log: Tms.ec,v $
Revision 1.1  2012/12/18 10:25:53  wukj
*** empty log message ***

Revision 1.9  2012/12/10 05:32:12  wukj
*** empty log message ***

Revision 1.8  2012/12/05 06:32:01  wukj
*** empty log message ***

Revision 1.7  2012/12/03 03:25:09  wukj
int����ǰ׺�޸�Ϊi

Revision 1.6  2012/11/29 10:09:04  wukj
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
extern T_TMS_PARA gtTmsPara;

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
        T_TMS_PARA tTmsPara; 
        char    szShopNo[20+1];
        char     szPosNo[20+1];
    EXEC SQL END DECLARE SECTION;
    int iPos = 0;
    char szTmsPara[310+1];
    memset(szTmsPara, 0, sizeof(szTmsPara));
    memset(&tTmsPara, 0, sizeof(T_TMS_PARA));
    memcpy(&tTmsPara, &gtTmsPara, sizeof(T_TMS_PARA));    
    memset(szShopNo, 0, sizeof(szShopNo));
    memset(szPosNo, 0, sizeof(szPosNo));
    strcpy(szShopNo, ptAppStru->szShopNo);
    strcpy(szPosNo, ptAppStru->szPosNo);
        
    EXEC SQL SELECT NOTICE_BTIME,NOTICE_EDATE
    INTO   :tTmsPara.szDownTime,
           :tTmsPara.szValidDate
    FROM   TM_VPOS_INFO
    WHERE  TRIM(SHOPNO) = :szShopNo
             AND    TRIM(POSNO)  = :szPosNo
             AND    NOTICE_FLAG = '1'; 
    if( SQLCODE )
    {
        WriteLog( ERROR, "TM_VPOS_INFO %d", SQLCODE );
        return( FAIL );
    }
    
    WriteLog( TRACE, "tTmsPara.szDownTime=[%s]",tTmsPara.szDownTime);
    memcpy(szTmsPara+iPos,tTmsPara.szDownTime ,14);
    iPos +=14;
    WriteLog( TRACE, "tTmsPara.szValidDate=[%s]",tTmsPara.szValidDate);
    memcpy(szTmsPara+iPos,tTmsPara.szValidDate ,8);
    iPos +=8;
WriteLog( TRACE, "tTmsPara.szTmsTelNo1=[%s]",tTmsPara.szTmsTelNo1);
    sprintf(szTmsPara+iPos,"%-40.40s",tTmsPara.szTmsTelNo1);
    iPos +=40;
WriteLog( TRACE, "tTmsPara.szTmsTelNo2=[%s]",tTmsPara.szTmsTelNo2);
    sprintf(szTmsPara+iPos,"%-40.40s",tTmsPara.szTmsTelNo2);
    iPos +=40;
        
    ptAppStru->iTmsLen = iPos;
    memcpy(ptAppStru->szTmsData, szTmsPara, iPos);
    ptAppStru->szTmsData[iPos]=0;
WriteLog( TRACE, "shopno=[%s],posno=[%s]",szShopNo,szPosNo);        
    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}
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
        T_TMS_PARA tTmsPara; 
        char    szShopNo[20+1];
        char     szPosNo[20+1];
    EXEC SQL END DECLARE SECTION;
    int iPos = 0;
    char szTmsPara[310+1];
    memset(szTmsPara, 0, sizeof(szTmsPara));
    memset(&tTmsPara, 0, sizeof(T_TMS_PARA));
    memcpy(&tTmsPara, &gtTmsPara, sizeof(T_TMS_PARA));    
    memset(szShopNo, 0, sizeof(szShopNo));
    memset(szPosNo, 0, sizeof(szPosNo));
    strcpy(szShopNo, ptAppStru->szShopNo);
    strcpy(szPosNo, ptAppStru->szPosNo);
        
    EXEC SQL SELECT NOTICE_BTIME,NOTICE_EDATE
    INTO   :tTmsPara.szDownTime,
           :tTmsPara.szValidDate
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

    memcpy(szTmsPara+iPos,tTmsPara.szSysCode ,8);
    iPos +=8;
    memcpy(szTmsPara+iPos,"27" ,2);
    iPos +=2;
    memcpy(tTmsPara.szDownBitMap,"02",2);
    memcpy(szTmsPara+iPos,tTmsPara.szDownBitMap ,2);
    iPos +=2;
    memcpy(szTmsPara+iPos,"28" ,2);
    iPos +=2;
    sprintf(tTmsPara.szDownFileName,"%-72.72s","���ز����ļ�");
    memcpy(szTmsPara+iPos,tTmsPara.szDownFileName ,72);
    iPos +=72;
    memcpy(szTmsPara+iPos,"29" ,2);
    iPos +=2;
WriteLog( TRACE, "tTmsPara.szValidDate=[%s]",tTmsPara.szValidDate);
    memcpy(szTmsPara+iPos,tTmsPara.szValidDate ,8);
    iPos +=8;
    memcpy(szTmsPara+iPos,"30" ,2);
    iPos +=2;
    sprintf(tTmsPara.szAppName,"%-72.72s","Ӧ������");
    memcpy(szTmsPara+iPos,tTmsPara.szAppName ,72);
    iPos +=72;
    memcpy(szTmsPara+iPos,"31" ,2);
    iPos +=2;
    memcpy(szTmsPara+iPos,"1001" ,4);
    iPos +=4;
    memcpy(szTmsPara+iPos,"32" ,2);
    iPos +=2;
WriteLog( TRACE, "tTmsPara.szTmsTelNo1=[%s]",tTmsPara.szTmsTelNo1);
    memcpy(szTmsPara+iPos,tTmsPara.szTmsTelNo1 ,20);
    iPos +=20;
    memcpy(szTmsPara+iPos,"33" ,2);
    iPos +=2;
WriteLog( TRACE, "tTmsPara.szTmsTelNo2=[%s]",tTmsPara.szTmsTelNo2);
    memcpy(szTmsPara+iPos,tTmsPara.szTmsTelNo2 ,20);
    iPos +=20;
    memcpy(szTmsPara+iPos,"34" ,2);
    iPos +=2;
WriteLog( TRACE, "tTmsPara.szTmsIpPort1=[%s]",tTmsPara.szTmsIpPort1);
    memcpy(szTmsPara+iPos,tTmsPara.szTmsIpPort1 ,30);
    iPos +=30;
    memcpy(szTmsPara+iPos,"35" ,2);
    iPos +=2;
WriteLog( TRACE, "tTmsPara.szTmsIpPort2=[%s]",tTmsPara.szTmsIpPort2);
    memcpy(szTmsPara+iPos,tTmsPara.szTmsIpPort2 ,30);
    iPos +=30;
    memcpy(szTmsPara+iPos,"36" ,2);
    iPos +=2;
WriteLog( TRACE, "tTmsPara.szDownTime=[%s]",tTmsPara.szDownTime);
    memcpy(szTmsPara+iPos,tTmsPara.szDownTime ,14);
    iPos +=14;
        
    ptAppStru->iTmsLen = iPos;
    memcpy(ptAppStru->szTmsData, szTmsPara, iPos);
    ptAppStru->szTmsData[iPos]=0;
WriteLog( TRACE, "shopno=[%s],posno=[%s]",szShopNo,szPosNo);        
    strcpy( ptAppStru->szRetCode, TRANS_SUCC );
    return ( SUCC );
}

