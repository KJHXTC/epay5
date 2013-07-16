/*******************************************************************************
 * Copyright(C)2012��2015 �������������豸���޹�˾
 * ��Ҫ���ݣ�������Ϣ��֯
 *         
 * �� �� �ˣ�Robin
 * �������ڣ�2012/11/19
 *
 * $Revision: 1.4 $
 * $Log: Return.ec,v $
 * Revision 1.4  2013/01/18 08:32:37  fengw
 *
 * 1����ֺ�����
 *
 * Revision 1.3  2013/01/06 05:33:06  fengw
 *
 * 1��ɾ��GetReturnDescribe�������滻Ϊepay����GetResult������
 *
 * Revision 1.2  2012/12/21 06:53:07  wukj
 * ����ע��
 *
 * Revision 1.1  2012/12/21 02:58:00  wukj
 * �޸��ļ���
 *
 * Revision 1.6  2012/12/20 07:00:56  wukj
 * *** empty log message ***
 *
 * Revision 1.5  2012/12/20 01:15:10  wukj
 * ɾ��ChangeAmountReal����
 *
 * Revision 1.4  2012/12/19 09:07:20  chenrb
 * *** empty log message ***
 *
 * Revision 1.3  2012/12/19 02:13:21  wukj
 * �淶����д
 *
 *
 ******************************************************************************/

#define _EXTERN_

#include "ScriptPos.h"

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL EnD DECLARE SECTION;
#endif


/*****************************************************************
** ��    ��:���ݽ���������֯���׽����Ϣ 
** �������:
           ptAppStru
** �������:
           szRetData   ��ʾ����
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
int GetReturnData( ptAppStru, szRetData )
T_App    *ptAppStru;
unsigned char    *szRetData;
{
    int iRetLen, iTotal, iBegin, iEnd;
    int iFormatLen;
    unsigned long    lAmt, lAmount;
    char    szTmpStr[512], szBuf[512];
    int iRet;
    if( memcmp(ptAppStru->szRetCode, TRANS_SUCC, 2) == 0 )
    {
        memset(szBuf,0x00,sizeof(szBuf));
        //�������ݿ�����,��ʽ��������Ϣ
        iRet = FormatRetDesc(ptAppStru,szBuf,&iFormatLen);
        if(iRet == SUCC)
        {
            iRetLen = 0;
            //��ʾ��ʽ
            szRetData[iRetLen] = ptAppStru->cDispType;
            //szRetData[iRetLen] = 0;
            iRetLen ++;
        
            //Ӧ����         
            memcpy( szRetData+iRetLen, ptAppStru->szRetCode, 2 );
            iRetLen += 2;
            //������Ϣ
            memcpy(szRetData+3,szBuf,iFormatLen);
            iRetLen += iFormatLen;
            return iRetLen;
        }
        //���ʧ�ܻ�δ������ȡĬ��ֵ

        switch( ptAppStru->iTransType){
        case AUTO_VOID:
            strcpy(ptAppStru->szRetDesc, "�Զ������ɹ�");
            break;
        case CENDOWN_FUNCTION_INFO:
        case AUTODOWN_FUNCTION_INFO:
        case DOWN_FUNCTION_INFO:
            strcpy(ptAppStru->szRetDesc, "���¹�����ʾ�ɹ�");
            break;
        case CENDOWN_OPERATION_INFO:
        case AUTODOWN_OPERATION_INFO:
        case DOWN_OPERATION_INFO:
            strcpy(ptAppStru->szRetDesc, "���²�����ʾ�ɹ�");
            break;
        case CENDOWN_PRINT_INFO:
        case AUTODOWN_PRINT_INFO:
        case DOWN_PRINT_INFO:
            strcpy(ptAppStru->szRetDesc, "���´�ӡ��¼�ɹ�");
            break;
        case CENDOWN_TERM_PARA:
        case AUTODOWN_TERM_PARA:
        case DOWN_TERM_PARA:
            strcpy(ptAppStru->szRetDesc, "�����ն˲����ɹ�");
            break;
        case CENDOWN_PSAM_PARA:
        case AUTODOWN_PSAM_PARA:
        case DOWN_PSAM_PARA:
            strcpy(ptAppStru->szRetDesc, "���°�ȫ�����ɹ�");
            break;
        case CENDOWN_ERROR:
        case AUTODOWN_ERROR:
        case DOWN_ERROR:
            strcpy(ptAppStru->szRetDesc, "���´�����Ϣ�ɹ�");
            break;
        case CENDOWN_MENU:
        case AUTODOWN_MENU:
        case DOWN_MENU:
            strcpy(ptAppStru->szRetDesc, "���²˵��ɹ�");
            break;
        case DOWN_ALL_PSAM:
            strcpy(ptAppStru->szRetDesc, "����Ӧ�óɹ�");
            break;
        case QUERY_DETAIL_SELF:
        case QUERY_DETAIL_OTHER:
            strcpy(ptAppStru->szRetDesc, "��ѯ������ϸ�ɹ�");
            break;
        case TERM_REGISTER:
            strcpy(ptAppStru->szRetDesc, "�ն�Ԥ�Ǽǳɹ�,�뵽WEB����ƽ̨���");
            break;
        case DOWN_TMS:
            strcpy(ptAppStru->szRetDesc, "����TMS�����ɹ�");
        case DOWN_TMS_END:
            strcpy(ptAppStru->szRetDesc, "����TMS�����ɹ�");
            break;
        default:
            strcpy(ptAppStru->szRetDesc, "���׳ɹ�");
            break;
        }
    }
    else
    {
        GetResult(ptAppStru->szRetCode, ptAppStru->szRetDesc);
    }

    iRetLen = 0;
    //��ʾ��ʽ
    szRetData[iRetLen] = ptAppStru->cDispType;
    iRetLen ++;

    //Ӧ����    
    memcpy( szRetData+iRetLen, ptAppStru->szRetCode, 2 );
    iRetLen += 2;

    if( memcmp(ptAppStru->szRetCode, TRANS_SUCC, 2) != 0 )
    {
        //Ӧ����Ϣ
#ifdef    ADD_0A_LINE
        memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
        iRetLen ++;
#endif
        memcpy( szRetData+iRetLen, ptAppStru->szRetDesc, 
            strlen(ptAppStru->szRetDesc) );
        iRetLen += strlen(ptAppStru->szRetDesc);
        return iRetLen;
    }

    switch ( ptAppStru->iTransType)
    {
    //���Ų�Ӧ�ɷ�
    case CHINATELECOM_INQ:
    //����CDMA��Ӧ�ɷ�
    case CHINATELECOM_CDMA_INQ:
    //��Ѳ�Ӧ�ɷ�
    case ELECTRICITY_INQ:
    //ú����Ӧ�ɷ�
    case GAS_INQ:
    //ˮ�Ѳ�Ӧ�ɷ�
    case WATER_INQ:
    //��ͨ��Ӧ�ɷ�
    case NETCOM_INQ:
    //��ͨ��Ӧ�ɷ�
    case CHINAUNICOM_INQ:
    //�ƶ���Ӧ�ɷ�
    case CHINAMOBILE_INQ:
    //��Ӧ�ɷ�-����
    case TEST_INQ:
    //����ŵ�ǰ���
    case CHINATELECOM_QUERY:
    //�����CDMA��ǰ���
    case CHINATELECOM_CDMA_QUERY:
    //����ͨ��ǰ���
    case CHINAUNICOM_QUERY:
    //���ƶ���ǰ���
    case CHINAMOBILE_QUERY:
    //��ͨ�鵱ǰ���
    case NETCOM_QUERY:
        sprintf( szTmpStr, "�û���:%s", ptAppStru->szHolderName);
        sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
        iRetLen += 20;

        memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
        iRetLen ++;

        if( ptAppStru->iTransType == CHINATELECOM_QUERY ||
            ptAppStru->iTransType == CHINAUNICOM_QUERY ||
            ptAppStru->iTransType == NETCOM_QUERY ||
            ptAppStru->iTransType == CHINATELECOM_CDMA_QUERY ||
            ptAppStru->iTransType == CHINAMOBILE_QUERY )
        {

            sprintf( szTmpStr, "��ֵ����:%s", ptAppStru->szBusinessCode);
            sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
            iRetLen += 20;

            memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
            iRetLen ++;

            sprintf( szTmpStr, "��ǰ���:%u.%02ldԪ", atoll(ptAppStru->szAddiAmount)/100,atoll(ptAppStru->szAddiAmount)%100);
        }
        else
        {
            sprintf( szTmpStr, "�ɷѺ���:%s", ptAppStru->szBusinessCode);
            sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
            iRetLen += 20;

            memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
            iRetLen ++;

            sprintf( szTmpStr, "Ӧ�ɽ��:%u.%02ldԪ", atoll(ptAppStru->szAmount)/100,atoll(ptAppStru->szAmount)%100);
        }
        sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
        iRetLen += 20;
        memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
        iRetLen ++;

        // ������ʾ
        strcpy( szTmpStr, "ȷ�ϼ����� ȡ�����˳�" );
        sprintf( szRetData+iRetLen, "%-21.21s", szTmpStr );
        iRetLen += 21;
        break;
    //����������
    case PAY_CREDIT_QUERY:
    case TRANS_QUERY:
    case TRAN_IN_QUERY:
    case TRAN_OUT_QUERY:
        // �տ���
        if( strlen(ptAppStru->szHolderName) > 0 )
        {
            sprintf( szTmpStr, "�տ���:%s", ptAppStru->szHolderName);
        }
        else
        {
            strcpy( szTmpStr, "�տ��" );
        }
        sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
        iRetLen += 20;
        memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
        iRetLen ++;

        // �տ��ʺ�
        sprintf( szTmpStr, "%s", ptAppStru->szAccount2);
        sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
        iRetLen += 20;
        memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
        iRetLen ++;

        /* ������ */
        lAmt = atoll( ptAppStru->szAddiAmount);
        sprintf( szTmpStr, "������:%u.%02ldԪ", lAmt/100L, lAmt%100L );
        sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
        iRetLen += 20;
        memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
        iRetLen ++;

        // ������ʾ
        strcpy( szTmpStr, "ȷ�ϼ����� ȡ�����˳�" );
        sprintf( szRetData+iRetLen, "%-21.21s", szTmpStr );
        iRetLen += 21;

        break;
    case TRAN_OTHER_QUERY:
        //��һ�����׽����ʾ
        if( ptAppStru->iSteps == 1 )
        {
            // �տ���
            if( strlen(ptAppStru->szHolderName) > 0 )
            {
                sprintf( szTmpStr, "�տ���:%s", ptAppStru->szHolderName );
                sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
                iRetLen += 20;
                memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
                iRetLen ++;
            }
            else
            {
                // �տ��Ϣ
                strcpy( szTmpStr, "�տ:" );
                sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
                iRetLen += 20;
                memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
                iRetLen ++;
            }

            //��ѯ��ת�������ƣ�����ʾ
            if( strlen(ptAppStru->szReserved) > 0 )
            {
                //ת����
                strcpy( szTmpStr, ptAppStru->szReserved);
                sprintf( szRetData+iRetLen, "%-40.40s", szTmpStr );
                iRetLen += 40;
                memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
                iRetLen ++;
            }

            // ������ʾ
            strcpy( szTmpStr, "ȷ�ϼ����� ȡ�����˳�" );
            sprintf( szRetData+iRetLen, "%-21.21s", szTmpStr );
            iRetLen += 21;
        }
        else
        {
            // �տ��ʺ�
            sprintf( szTmpStr, "%s", ptAppStru->szAccount2);
            sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
            iRetLen += 20;
            memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
            iRetLen ++;

            // ��� 
            sprintf( szTmpStr, "��  ��:%lfԪ", atoll(ptAppStru->szAmount)/100.00);
            sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
            iRetLen += 20;
            memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
            iRetLen ++;

            //������
            lAmt = atoll( ptAppStru->szAddiAmount);
            sprintf( szTmpStr, "������:%u.%02ldԪ", lAmt/100L, lAmt%100L );
            sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
            iRetLen += 20;
            memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
            iRetLen ++;

            // ������ʾ
            strcpy( szTmpStr, "ȷ�ϼ����� ȡ�����˳�" );
            sprintf( szRetData+iRetLen, "%-21.21s", szTmpStr );
            iRetLen += 21;
        }

        break;
    //�����
    case INQUERY:
        sprintf( szRetData+iRetLen, "����:%15.15s", " " );
        iRetLen += 20;

        memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
        iRetLen ++;

        sprintf( szRetData+iRetLen, "%-20.20s", ptAppStru->szPan);
        iRetLen += 20;

        memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
        iRetLen ++;


        //sprintf(szTmpStr, "���:%sԪ", atoll(ptAppStru->szAddiAmount)/100.00);
        ChgAmtZeroToDot(ptAppStru->szAddiAmount,0,szBuf); 
        sprintf(szTmpStr, "���:%sԪ", szBuf);

        sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
        iRetLen += 20;
        break;
    //��ѯ��ˮ
    case QUERY_DETAIL_SELF:
    case QUERY_DETAIL_OTHER:
    case QUERY_TODAY_DETAIL:
        memcpy( szTmpStr, ptAppStru->szReserved+6, 6 );
        szTmpStr[6] = 0;
        iTotal = atol(szTmpStr);

        memcpy( szTmpStr, ptAppStru->szReserved+12, 6 );
        szTmpStr[6] = 0;
        iBegin = atol(szTmpStr);

        memcpy( szTmpStr, ptAppStru->szReserved+18, 6 );
        szTmpStr[6] = 0;
        iEnd = atol(szTmpStr);

        if( iTotal == 0 )
        {
            strcpy( szTmpStr, "δ�ҵ�������������ˮ" );
            sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
            iRetLen += 20;
        }
        else
        {
#ifdef    ADD_0A_LINE
            memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
            iRetLen ++;
#endif
            sprintf( szTmpStr, "��%ld�� ����%ld-%ld��", iTotal, iBegin, iEnd );
            sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
            iRetLen += 20;
        }
        break;
    case QUERY_LAST_DETAIL:
        /* �������� */
        sprintf( szTmpStr, "%-8.8s ��ˮ%-6ld", ptAppStru->szReserved, ptAppStru->lOldPosTrace);
        sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
        iRetLen += 20;

        memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
        iRetLen ++;

        /* ��һ���� */
        if( ptAppStru->iOldTransType == TRANS || ptAppStru->iOldTransType == TRAN_IN || 
            ptAppStru->iOldTransType == TRAN_OTHER ||
            ptAppStru->iOldTransType == TRAN_OUT || ptAppStru->iOldTransType == PAY_CREDIT )
        {
            sprintf( szTmpStr, "��%s", ptAppStru->szPan );
        }    
        else
        {
            sprintf( szTmpStr, "����%s", ptAppStru->szPan);
        }
        sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
        iRetLen += 20;

        memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
        iRetLen ++;

        /* �ڶ����Ż��û��� */
        if( ptAppStru->iOldTransType == TRANS || ptAppStru->iOldTransType == TRAN_IN || 
            ptAppStru->iOldTransType == TRAN_OTHER ||
            ptAppStru->iOldTransType == TRAN_OUT || ptAppStru->iOldTransType == PAY_CREDIT )
        {
            sprintf( szTmpStr, "��%s", ptAppStru->szAccount2);
        }    
        else if( ptAppStru->iOldTransType == PURCHASE )
        {
            sprintf( szTmpStr, "��Ȩ��:%s", ptAppStru->szAuthCode);
        }
        else
        {
            sprintf( szTmpStr, "�û���:%s", ptAppStru->szBusinessCode);
        }
        sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
        iRetLen += 20;

        memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
        iRetLen ++;

        /* ���׽�� */
        lAmt = atoll(ptAppStru->szAmount);
        sprintf( szTmpStr, "���:%u.%02ldԪ", lAmt/100L, lAmt%100L );
        sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
        iRetLen += 20;

        memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
        iRetLen ++;

        /* ����ʱ�� */
        sprintf( szTmpStr, "%4.4s-%2.2s-%2.2s %2.2s:%2.2s:%2.2s|", ptAppStru->szPosDate, ptAppStru->szPosDate+4, 
            ptAppStru->szPosDate+6, ptAppStru->szPosTime, ptAppStru->szPosTime+2, ptAppStru->szPosTime+4 );
        sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
        iRetLen += 20;
    case QUERY_TOTAL:
        memcpy( szRetData+iRetLen, ptAppStru->szReserved, 
            ptAppStru->iReservedLen );    
        iRetLen += ptAppStru->iReservedLen;
        break;
    case TRAFFIC_AMERCE_INQ:
    case TRAFFIC_AMERCE_NO_INQ:
        if( ptAppStru->iTransType == TRAFFIC_AMERCE_NO_INQ )
        {
            //���ƺ�
            sprintf( szTmpStr, "���ƺ�:%s", ptAppStru->szReserved );
        }
        else
        {
            // ������
            sprintf( szTmpStr, "������:%s", ptAppStru->szHolderName );
        }
        sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
        iRetLen += 20;
        memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
        iRetLen ++;

         /* ����� */
        sprintf( szTmpStr, "�����:%lfԪ", atoll(ptAppStru->szAmount)/100.00);
        sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
        iRetLen += 20;
        memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
        iRetLen ++;

        /* ���ɽ� */
        lAmt = atoll( ptAppStru->szAddiAmount);
        sprintf( szTmpStr, "���ɽ�:%u.%02ldԪ", lAmt/100L, lAmt%100L );
        sprintf( szRetData+iRetLen, "%-20.20s", szTmpStr );
        iRetLen += 20;
        memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
        iRetLen ++;

        // ������ʾ
        strcpy( szTmpStr, "ȷ�ϼ����� ȡ�����˳�" );
        sprintf( szRetData+iRetLen, "%-21.21s", szTmpStr );
        iRetLen += 21;

        break;
    default:
        //Ӧ����Ϣ
#ifdef    ADD_0A_LINE
        memcpy( szRetData+iRetLen, "\x0A", 1 );    //����
        iRetLen ++;
#endif

        memcpy( szRetData+iRetLen, ptAppStru->szRetDesc, 
            strlen(ptAppStru->szRetDesc) );
        iRetLen += strlen(ptAppStru->szRetDesc);
        break;
    }

    return iRetLen;
}


/*****************************************************************
** ��    ��:����ѯ��������ݿ���ȡ����ͬʱɾ���ü�¼ 
** �������:
           ptAppStru
** �������:
           szRetData   �����Ϣ
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
GetQueryResult( ptAppStru, szRetData )
T_App    *ptAppStru;
uchar    *szRetData;
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szPsamNo[17], szResult[2049];
        int    lTrace;
    EXEC SQL END DECLARE SECTION;
    char    szTmpStr[100];
    int    iLen;
    int    i, j, k, iLine, iBegin, iEnd, iTotalLine;
    
    strcpy( szPsamNo, ptAppStru->szPsamNo);
    lTrace = ptAppStru->lPosTrace;

    memcpy( szTmpStr, ptAppStru->szReserved, 6 );
    szTmpStr[6] = 0;
    iLen = atol(szTmpStr);

    EXEC SQL SELECT result 
    INTO :szResult
    FROM query_result
    WHERE psam_no = :szPsamNo AND POS_TRACE = :lTrace;
    if( SQLCODE )
    {
        WriteLog( ERROR, "select result fail %ld", SQLCODE );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        return FAIL;    
    }
    szResult[iLen] = 0;
    memcpy( szRetData, szResult, iLen );

    EXEC SQL DELETE FROM query_result
    WHERE psam_no = :szPsamNo AND POS_TRACE = :lTrace;
    if( SQLCODE )
    {
        WriteLog( ERROR, "delete result fail %ld", SQLCODE );
        strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
        RollbackTran();
        return FAIL;    
    }
    CommitTran();

    return iLen;
}
