/******************************************************************
 * ** Copyright(C)2012 - 2015���������豸���޹�˾
 * ** ��Ҫ���ݣ�epay���ļ�,��Ҫ��ӡAPP�Ƚṹ����־����
 * ** �� �� �ˣ�������
 * ** �������ڣ�2012/11/8
 * ** $Revision: 1.13 $
 * ** $Log: WriteStruLog.c,v $
 * ** Revision 1.13  2013/02/25 01:11:16  fengw
 * **
 * ** 1���޸�TPDU��ַ��־��ӡ��ʽ��
 * **
 * ** Revision 1.12  2012/12/17 06:41:46  chenrb
 * ** app�ṹ���ӿ��Ʋ������ȡ����Ʋ���2���ֶΣ��޸�WriteAppStru��Ӧ
 * **
 * ** Revision 1.11  2012/12/11 03:28:49  chenrb
 * ** iMenuItem�޸ĳ�iaMenuItem
 * **
 * ** Revision 1.10  2012/12/11 03:08:23  chenrb
 * ** WriteAppStru���Ӽ����ֶε���ʾ
 * **
 * ** Revision 1.9  2012/12/10 02:43:32  fengw
 * **
 * ** 1���滻sgetdate����ΪGetSysDate��
 * **
 * ** Revision 1.8  2012/11/30 06:07:49  zhangwm
 * **
 * ** ���ܻ���ת��־��ӡ����������־��ӡ����
 * **
 * ** Revision 1.7  2012/11/29 07:09:22  zhangwm
 * **
 * ** �����ж��Ƿ��ӡ��־
 * **
 * ** Revision 1.6  2012/11/29 06:04:22  chenrb
 * ** ɾ��lLastVisitTime�ֶ�
 * **
 * ** Revision 1.5  2012/11/29 05:40:45  gaomx
 * ** �޶���Ϣ���ͱ���
 * **
 * ** Revision 1.4  2012/11/29 02:23:44  gaomx
 * ** *** empty log message ***
 * **
 * ** Revision 1.3  2012/11/28 08:14:06  yezt
 * **
 * ** ���Ӻ���ע��
 * **
 * ** Revision 1.2  2012/11/28 07:49:42  gaomx
 * ** �����ṹ�嶨��
 * **
 * ** Revision 1.1  2012/11/28 01:54:30  gaomx
 * ** *** empty log message ***
 * **
 * ** Revision 1.4  2012/11/28 01:50:11  gaomx
 * ** *** empty log message ***
 * **
 * ** Revision 1.3  2012/11/28 01:48:23  gaomx
 * ** ���±༭��ʽ
 * **
 * *******************************************************************/

#include <stdio.h>
#include <memory.h>
#include <stdlib.h>
#include <sys/types.h>
#include "../../incl/app.h"
#include "../../incl/user.h"

/* ----------------------------------------------------------------
 * ��    �ܣ� ��ӡӦ�ó���ṹ����App��־��
 * ���������
 *            ptApp      Ӧ�ó���ṹ��
 *            szTitle    �ַ���ָ��(���뱨��ͷ)
 * ��������� ��
 * �� �� ֵ�� FAIL  ʧ��/ SUCC    �ɹ�
 * ��    �ߣ�
 * ��    �ڣ� 2012/11/28
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
    int
WriteAppStru( ptApp, szTitle )
    T_App    *ptApp;
    char *szTitle;
{
    FILE    *fd;
    char    szFileName[80], szTmpBuf[2048], szDate[20];
    int i;

    if(IsPrint(DEBUG_ALOG) == NO)
    {
        return FAIL;
    }

    GetFullName( "WORKDIR", "/log/Applog", szFileName);
    GetSysDate( szDate );
    strcat( szFileName, szDate );
    if( (fd = fopen( szFileName, "a+") ) == NULL )
    {
        WriteLog( ERROR , "fopen [%s] err",szFileName);
        return( FAIL );
    }
    fprintf( fd , "%s==================\n", szTitle );
    fprintf( fd , "=========����Э�鲿��=========\n" );
    fprintf( fd, "iFskId(����ƽ̨ID)[%d]  ", ptApp->iFskId );
    fprintf( fd, "iModuleId(ģ���)[%d]   ", ptApp->iModuleId );
    fprintf( fd, "iChannelId(ͨ����)[%d]  \n", ptApp->iChannelId );
    fprintf( fd, "iCallType(��������)[%d]  ", ptApp->iCallType );
    fprintf( fd, "iSteps(����ͬ�����)[%d]  ", ptApp->iSteps );
    fprintf( fd, "lTransDataIdx(��������������)[%ld]\n", ptApp->lTransDataIdx );
    fprintf( fd, "szMsgVer(�ն˱���Э��汾)[%02x%02x]  ", ptApp->szMsgVer[0], ptApp->szMsgVer[1] );
    fprintf( fd, "szAppVer(�ն�Ӧ�ýű��汾)[%02x%02x%02x%02x]  ", 
                 ptApp->szAppVer[0], ptApp->szAppVer[1], 
                 ptApp->szAppVer[2], ptApp->szAppVer[3] );
    fprintf( fd, "szPosCodeVer(�ն˳���汾)[%s]  ", ptApp->szPosCodeVer );
    fprintf( fd, "szPosType(�ն��ͺ�)[%s]  \n",  ptApp->szPosType );
    

    fprintf( fd , "=========�����к���=========\n" );
    fprintf( fd, "szCalledTelByTerm(�ն����͵ı������ĺ���)[%s]  \n", ptApp->szCalledTelByTerm );
    fprintf( fd, "szCalledTelByNac(���������͵ı������ĺ���)[%s]  \n", ptApp->szCalledTelByNac );
    fprintf( fd, "szCallingTel(�ն����к���)[%s]  \n", ptApp->szCallingTel );

    fprintf( fd , "=========����·����Ϣ=========\n" );
    fprintf( fd, "szSourceTpdu(Դ��ַ)[%02x%02x]  \n", ptApp->szSourceTpdu[0] & 0xFF, ptApp->szSourceTpdu[1] & 0xFF );
    fprintf( fd, "szTargetTpdu(Ŀ�ĵ�ַ)[%02x%02x]  \n", ptApp->szTargetTpdu[0] & 0xFF, ptApp->szTargetTpdu[1] & 0xFF );
    fprintf( fd, "lProcToAccessMsgType(�������ս�������Ӧ����Ϣ����)[%ld]  \n", ptApp->lProcToAccessMsgType );
    fprintf( fd, "lPresentToProcMsgType(���״�������Ӧ����Ϣ����)[%ld]  \n", ptApp->lPresentToProcMsgType );
    fprintf( fd, "lAccessToProcMsgType(���״������ս���������Ϣ����)[%ld]  \n", ptApp->lAccessToProcMsgType );
    fprintf( fd, "lProcToPresentMsgType(ҵ���ύ����ս���������Ϣ����)[%ld]  \n", ptApp->lProcToPresentMsgType );
    fprintf( fd, "szIp(����IP)[%s]  \n", ptApp->szIp );

    fprintf( fd , "=========�ն˲ɼ���Ϣ=========\n" );
    fprintf( fd, "iTransNum(����)[%d]  \n", ptApp->iTransNum );
    fprintf( fd, "szFinancialCode(����Ӧ�ú�)[%s]  \n", ptApp->szFinancialCode );
    fprintf( fd, "szBusinessCode(����Ӧ�ú�)[%s]  \n", ptApp->szBusinessCode );
    fprintf( fd, "szInDate(����)[%s]  \n", ptApp->szInDate );
    fprintf( fd, "szInMonth(����)[%s]  \n", ptApp->szInMonth );
    fprintf( fd, "szUserData(�û���������)[%s]  \n", ptApp->szUserData );

    fprintf( fd, "iMenuNum(��̬�˵�����)[%d]  iMenuRecNo��̬�˵���Ӧ�Ĳ˵���ʶ)/iMenuItem(ѡ�еĶ�̬�˵���)[", ptApp->iMenuNum );
    for( i=0; i<ptApp->iMenuNum; i++ )
    {
        fprintf( fd, "%d/%d ", ptApp->iMenuRecNo[i], ptApp->iaMenuItem[i] );
    }
    fprintf( fd, "]\n" );

    fprintf( fd, "iStaticMenuId(��̬�˵�ID)[%d]  \n", ptApp->iStaticMenuId );
    fprintf( fd, "iStaticMenuItem(ѡ�еľ�̬�˵���)[%d]  \n", ptApp->iStaticMenuItem );
    fprintf( fd, "szStaticMenuOut(ѡ�еľ�̬�˵�����)[%s]  \n", ptApp->szStaticMenuOut );
    fprintf( fd, "lRate(0x36��ָ���ȡ�������)[%ld]  \n", ptApp->lRate );
    fprintf( fd, "szTermRetCode(���и�����ָ��ķ��ؽ��)[%s]  \n", ptApp->szTermRetCode );

    fprintf( fd, "=========�յ���(�̻��ն�)����=========  \n" );
    fprintf( fd, "szPsamNo(��ȫģ���)[%s]  \n", ptApp->szPsamNo );
    fprintf( fd, "szTermSerialNo(�ն�Ӳ�����к�)[%s]  \n", ptApp->szTermSerialNo );
    fprintf( fd, "szDeptNo(������)[%s]  \n", ptApp->szDeptNo );
    fprintf( fd, "szDeptDetail(�����㼶��Ϣ)[%s]  \n", ptApp->szDeptDetail );
    fprintf( fd, "szShopNo(�̻���)[%s]  \n", ptApp->szShopNo );
    fprintf( fd, "szPosNo(�ն˺�)[%s]  \n", ptApp->szPosNo );
    fprintf( fd, "szAcqBankId(�յ���)[%s]  \n", ptApp->szAcqBankId );    
    fprintf( fd, "lBatchNo(�������κ�)[%ld]  \n", ptApp->lBatchNo );
    fprintf( fd, "lPosTrace(�ն���ˮ��)[%ld]  \n", ptApp->lPosTrace );
    fprintf( fd, "lOldPosTrace(ԭPOS��ˮ��)[%ld]  \n", ptApp->lOldPosTrace );
    fprintf( fd, "szPosDate(�ն˽�������)[%s]  \n", ptApp->szPosDate );
    fprintf( fd, "szPosTime(�ն˽���ʱ��)[%s]  \n", ptApp->szPosTime );
    fprintf( fd, "szShopName(�̻�����)[%s]  \n", ptApp->szShopName );
    fprintf( fd, "szShopType(�̻�����)[%s]  \n", ptApp->szShopType );   
    fprintf( fd, "lMarketNo(�г����)[%ld]  \n", ptApp->lMarketNo );
    fprintf( fd, "szOperNo(����Ա���)[%s]  \n", ptApp->szOperNo );
    fprintf( fd, "szEntryMode(��������뷽ʽ��)[%s]  \n", ptApp->szEntryMode );    

    fprintf( fd, "=========����Ҫ��=========  \n" );
    fprintf( fd, "iTransType(��������)[%ld]  \n", ptApp->iTransType );
    fprintf( fd, "iOldTransType(ԭ��������)[%ld]  \n", ptApp->iOldTransType );
    fprintf( fd, "iBusinessType(ҵ������)[%ld]  \n", ptApp->iBusinessType );
    fprintf( fd, "szTransCode(�ն˽��״���)[%s]  \n", ptApp->szTransCode );
    fprintf( fd, "szNextTransCode(�������״���)[%s]  \n", ptApp->szNextTransCode );
    fprintf( fd, "szTransName(��������)[%s]  \n", ptApp->szTransName );
    fprintf( fd, "szAmount(���׽���Ӧ�ɽ��)[%s]  \n", ptApp->szAmount );   
    fprintf( fd, "szAddiAmount(����������)[%s]  \n", ptApp->szAddiAmount );
    fprintf( fd, "iCommandNum(���������)[%d]  \n", ptApp->iCommandNum );
    BcdToAsc( (uchar*)ptApp->szCommand, ptApp->iCommandLen*2, LEFT_ALIGN,  (uchar*)szTmpBuf);
    szTmpBuf[ptApp->iCommandLen*2] = 0;    
    fprintf( fd, "iCommandLen[%d] szCommand[%s]\n", ptApp->iCommandLen, szTmpBuf );
    BcdToAsc( (uchar*)ptApp->szMac, 16, LEFT_ALIGN,  (uchar*)szTmpBuf);    
    szTmpBuf[16] = 0;
    fprintf( fd, "iControlLen(���Ʋ�������)[%d]  ", ptApp->iControlLen );
    BcdToAsc( (uchar*)ptApp->szControlPara, ptApp->iControlLen*2, LEFT_ALIGN,  (uchar*)szTmpBuf);
    szTmpBuf[ptApp->iControlLen*2] = 0;    
    fprintf( fd, "szControlPara(���Ʋ���)[%s]\n", szTmpBuf );
    fprintf( fd, "MAC[%s] \n", szTmpBuf );   

    fprintf( fd, "=========ת�����˻���Ϣ=========  \n" );
    fprintf( fd, "szPan(���˻�)[%s]  \n", ptApp->szPan );
    fprintf( fd, "szTrack2(2�ŵ�����)[%s]  \n", ptApp->szTrack2 );
    fprintf( fd, "szTrack3(3�ŵ�����)[%s]  \n", ptApp->szTrack3 );
    fprintf( fd, "szExpireDate(����Ч��)[%s]  \n", ptApp->szExpireDate );
    fprintf( fd, "szOutBankId(������ID)[%s]  \n", ptApp->szOutBankId );
    fprintf( fd, "szOutBankName(����������)[%s]  \n", ptApp->szOutBankName );
    fprintf( fd, "szOutCardName(���п�����)[%s]  \n", ptApp->szOutCardName );
    fprintf( fd, "cOutCardType(ת��������)[%c]  \n", ptApp->cOutCardType );   
    fprintf( fd, "iOutCardLevel(������)[%d]  \n", ptApp->iOutCardLevel );
    fprintf( fd, "iOutCardBelong( ������ )[%d]  \n", ptApp->iOutCardBelong );
    fprintf( fd, "szHolderName(�ֿ�������)[%s]  \n", ptApp->szHolderName );

    fprintf( fd, "=========ת�뿨�˻���Ϣ=========  \n" );
    fprintf( fd, "szAccount2(ת���˺�)[%s]  \n", ptApp->szAccount2 );
    fprintf( fd, "szInBankId(ת�뿨������ID)[%s]  \n", ptApp->szInBankId );
    fprintf( fd, "szInBankName(ת�뿨����������)[%s]  \n", ptApp->szInBankName );
    fprintf( fd, "cInCardType(ת�뿨����)[%c]  \n", ptApp->cInCardType );
    fprintf( fd, "iInCardBelong(ת�뿨����)[%d]  \n", ptApp->iInCardBelong );

    fprintf( fd, "=========ƽ̨����̨��Ϣ=========  \n" );
    fprintf( fd, "szHostDate(ƽ̨��������)[%s]  \n", ptApp->szHostDate );
    fprintf( fd, "szHostTime(ƽ̨����ʱ��)[%s]  \n", ptApp->szHostTime );
    fprintf( fd, "lSysTrace(ƽ̨��ˮ��)[%ld]  \n", ptApp->lSysTrace );
    fprintf( fd, "lOldSysTrace(ԭƽ̨��ˮ��)[%ld]  \n", ptApp->lOldSysTrace );
    fprintf( fd, "szRetriRefNum(��̨�����ο���)[%s]  \n", ptApp->szRetriRefNum );
    fprintf( fd, "szOldRetriRefNum(ԭ��̨�����ο���)[%s]  \n", ptApp->szOldRetriRefNum );
    fprintf( fd, "szAuthCode(��Ȩ��)[%s]  \n", ptApp->szAuthCode );
    fprintf( fd, "szRetCode(ƽ̨������)[%s]  \n", ptApp->szRetCode );
    fprintf( fd, "szHostRetCode(��̨������)[%s]  \n", ptApp->szHostRetCode );
    fprintf( fd, "szHostRetMsg(��̨������Ϣ)[%s]  \n", ptApp->szHostRetMsg );
    fprintf( fd, "szRetDesc(������Ϣ����)[%s]  \n", ptApp->szRetDesc );

    fprintf( fd, "=========����=========  \n" );    
    fprintf( fd, "szControlCode(���̿�����)[%s]  \n", ptApp->szControlCode );    
    fprintf( fd, "DataNum(����Դ����)[%d]  DataSource(����Դ��ʶ)[", ptApp->iDataNum );
    for( i=0; i< ptApp->iDataNum; i++ )
    {
        fprintf( fd, "%d ", ptApp->szDataSource[i] );
    }
    fprintf( fd, "]\n" );    

    fprintf( fd , " END ==================\n\n");
    fclose( fd );

    return(SUCC);
}


/* ----------------------------------------------------------------
 * ��    �ܣ� ��ӡ���ܻ�����Ϣ��ṹ��App��־��
 * ���������
 *            ptFace     ���ܻ�����Ϣ��ṹ
 *            szTitle    �ַ���ָ��(���뱨��ͷ)
 * ��������� ��
 * �� �� ֵ�� FAIL  ʧ��/ SUCC    �ɹ�
 * ��    �ߣ�
 * ��    �ڣ� 2012/11/28
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
    int
WriteHsmStru( ptFace, szTitle )
    T_Interface *ptFace;
    char *szTitle;
{
    FILE    *fd;
    char    szFileName[80], szDate[20];

    if(IsPrint(DEBUG_ALOG) == NO)
    {
        return FAIL;
    }

    GetFullName( "WORKDIR", "/log/Hsmlog", szFileName);
    GetSysDate( szDate );
    strcat( szFileName, szDate );
    if( (fd = fopen( szFileName, "a+") ) == NULL )
    {
        WriteLog( ERROR , "fopen [%s] err",szFileName);
        return( FAIL );
    }
    fprintf( fd , "%s==================\n", szTitle );

    fprintf( fd, "lSourceType(���̺�)[%ld]  ", ptFace->lSourceType );
    fprintf( fd, "iTransType(��������)[%d]  ", ptFace->iTransType );
    fprintf( fd, "szPsamNo(��������)[%s]  ", ptFace->szPsamNo );
    fprintf( fd, "iAlog(��������)[%d]  ", ptFace->iAlog );
    fprintf( fd, "iPinBlock(��������)[%d]  ", ptFace->iPinBlock );
    fprintf( fd, "szPinKey(��������)[%s]  ", ptFace->szPinKey );
    fprintf( fd, "szMacKey(��������)[%s]  ", ptFace->szMacKey );
    fprintf( fd, "iDataLen(��������)[%d]  ", ptFace->iDataLen );
    fprintf( fd, "szData(��������)[%s]  ", ptFace->szData );
    fprintf( fd, "szReturnCode(��������)[%s]  ", ptFace->szReturnCode );

    fprintf( fd , " END ==================\n\n");
    fclose( fd );
    return(SUCC);
}

