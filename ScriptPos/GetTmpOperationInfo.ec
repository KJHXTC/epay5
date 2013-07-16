/*******************************************************************************
 * Copyright(C)2012��2015 �������������豸���޹�˾
 * ��Ҫ���ݣ�ScriptPosģ�� ��֯��ʱ������ʾ��Ϣ
 * �� �� �ˣ�Robin
 * �������ڣ�2012/11/30
 * $Revision: 1.1 $
 * $Log: GetTmpOperationInfo.ec,v $
 * Revision 1.1  2013/01/18 08:32:37  fengw
 *
 * 1����ֺ�����
 *
 ******************************************************************************/

#define _EXTERN_

#include "ScriptPos.h"

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
	EXEC SQL INCLUDE SQLCA;
EXEC SQL EnD DECLARE SECTION;
#else
	$include sqlca;
#endif

/*******************************************************************************
 * �������ܣ���֯��ʱ������ʾ��Ϣ
 * ���������
 *           ptApp      -  �������ݽṹָ��
 *           iDataIndex -  Դ���������� 
 *           iMenuId    -  ��̬�˵�ID��
 * ���������
 *           szMenuData -  ��̬�˵�����
 * �� �� ֵ�� 
 *           FAIL       -  ʧ��
 *           >=0        -  �˵����ݳ���
 * ��    �ߣ�Robin
 * ��    �ڣ�2012/11/30
 * �޶���־��
 *
 ******************************************************************************/
int GetTmpOperationInfo( ptApp, iDataIndex, szOutData )
T_App   *ptApp;
int     iDataIndex;
char   *szOutData;
{
    EXEC SQL BEGIN DECLARE SECTION;
        int iOperIndex;
        struct T_OPERATION_INFO{
            int     iOperIndex;
            char    szOpFlag[2];
            int     iModuleNum;
            char    szInfo1Format[3];
            char    szInfo1[41];
            char    szInfo2Format[3];
            char    szInfo2[41];
            char    szInfo3Format[3];
            char    szInfo3[41];
            char    szUpdateDate[9];
        } tOpInfo;
    EXEC SQL END DECLARE SECTION;

    int iCurPos, iInfo1Len, iInfo2Len, iInfo3Len, iModuNum, iRet, iMsgLen;
    char szData[512], szMsg[100];

    if( ptApp->iTransType == DOWN_ALL_OPERATION || 
        ptApp->iTransType == CENDOWN_ALL_OPERATION ||
        ptApp->iTransType == AUTODOWN_ALL_OPERATION ||
        ptApp->iTransType == CENDOWN_OPERATION_INFO ||
        ptApp->iTransType == AUTODOWN_OPERATION_INFO ||
        ptApp->iTransType == DOWN_OPERATION_INFO )
    {
        iCurPos = 0;
        //ģ����
        szData[iCurPos] = 1;
        iCurPos ++;
        
        //��ʾ��ʽ
        szData[iCurPos] = 0xA0;    
        iCurPos ++;

        strcpy( szMsg, "���²�����ʾ��Ϣ..." );
        iMsgLen = strlen(szMsg);
        //���ݳ���
        szData[iCurPos] = iMsgLen;
        iCurPos ++;

        memcpy( szData+iCurPos, szMsg, iMsgLen );
        iCurPos += iMsgLen;

        memcpy( szOutData, szData, iCurPos );
        
        return iCurPos;    
    }
    else if( ptApp->iTransType == DOWN_ALL_FUNCTION || 
            ptApp->iTransType == CENDOWN_FUNCTION_INFO ||
            ptApp->iTransType == AUTODOWN_FUNCTION_INFO ||
            ptApp->iTransType == DOWN_FUNCTION_INFO )
    {
        iCurPos = 0;
        //ģ����
        szData[iCurPos] = 1;
        iCurPos ++;
        
        //��ʾ��ʽ
        szData[iCurPos] = 0xA0;    
        iCurPos ++;

        strcpy( szMsg, "���¹�����ʾ��Ϣ..." );
        iMsgLen = strlen(szMsg);
        //���ݳ���
        szData[iCurPos] = iMsgLen;
        iCurPos ++;

        memcpy( szData+iCurPos, szMsg, iMsgLen );
        iCurPos += iMsgLen;

        memcpy( szOutData, szData, iCurPos );
        
        return iCurPos;    
    }
    else if( ptApp->iTransType == DOWN_ALL_ERROR || 
            ptApp->iTransType == CENDOWN_ERROR ||
            ptApp->iTransType == AUTODOWN_ERROR ||
            ptApp->iTransType == DOWN_ERROR )
    {
        iCurPos = 0;
        //ģ����
        szData[iCurPos] = 1;
        iCurPos ++;
        
        //��ʾ��ʽ
        szData[iCurPos] = 0xA0;    
        iCurPos ++;

        strcpy( szMsg, "���´�����ʾ��Ϣ..." );
        iMsgLen = strlen(szMsg);
        //���ݳ���
        szData[iCurPos] = iMsgLen;
        iCurPos ++;

        memcpy( szData+iCurPos, szMsg, iMsgLen );
        iCurPos += iMsgLen;

        memcpy( szOutData, szData, iCurPos );
        
        return iCurPos;    
    }
    else if( ptApp->iTransType == DOWN_ALL_PRINT || 
            ptApp->iTransType == CENDOWN_PRINT_INFO ||
            ptApp->iTransType == AUTODOWN_PRINT_INFO ||
            ptApp->iTransType == DOWN_PRINT_INFO )
    {
        iCurPos = 0;
        //ģ����
        szData[iCurPos] = 1;
        iCurPos ++;
        
        //��ʾ��ʽ
        szData[iCurPos] = 0xA0;    
        iCurPos ++;

        strcpy( szMsg, "���´�ӡ��¼��Ϣ..." );
        iMsgLen = strlen(szMsg);
        //���ݳ���
        szData[iCurPos] = iMsgLen;
        iCurPos ++;

        memcpy( szData+iCurPos, szMsg, iMsgLen );
        iCurPos += iMsgLen;

        memcpy( szOutData, szData, iCurPos );
        
        return iCurPos;    
    }
    else if( ptApp->iTransType == DOWN_ALL_MENU ||
            ptApp->iTransType == CENDOWN_MENU ||
            ptApp->iTransType == AUTODOWN_MENU ||
            ptApp->iTransType == DOWN_MENU )
    {
        iCurPos = 0;
        //ģ����
        szData[iCurPos] = 1;
        iCurPos ++;
        
        //��ʾ��ʽ
        szData[iCurPos] = 0xA0;    
        iCurPos ++;

        strcpy( szMsg, "����Ӧ�ò˵�..." );
        iMsgLen = strlen(szMsg);
        //���ݳ���
        szData[iCurPos] = iMsgLen;
        iCurPos ++;

        memcpy( szData+iCurPos, szMsg, iMsgLen );
        iCurPos += iMsgLen;

        memcpy( szOutData, szData, iCurPos );
        
        return iCurPos;    
    }
    else if( ptApp->iTransType == DOWN_ALL_TERM ||
            ptApp->iTransType == CENDOWN_TERM_PARA ||
            ptApp->iTransType == AUTODOWN_TERM_PARA ||
            ptApp->iTransType == DOWN_TERM_PARA )
    {
        iCurPos = 0;
        //ģ����
        szData[iCurPos] = 1;
        iCurPos ++;
        
        //��ʾ��ʽ
        szData[iCurPos] = 0xA0;    
        iCurPos ++;

        strcpy( szMsg, "�����ն˲���..." );
        iMsgLen = strlen(szMsg);
        //���ݳ���
        szData[iCurPos] = iMsgLen;
        iCurPos ++;

        memcpy( szData+iCurPos, szMsg, iMsgLen );
        iCurPos += iMsgLen;

        memcpy( szOutData, szData, iCurPos );
        
        return iCurPos;    
    }
    else if( ptApp->iTransType == DOWN_ALL_PSAM || 
            ptApp->iTransType == CENDOWN_PSAM_PARA ||
            ptApp->iTransType == AUTODOWN_PSAM_PARA ||
            ptApp->iTransType == DOWN_PSAM_PARA )
    {
        iCurPos = 0;
        //ģ����
        szData[iCurPos] = 1;
        iCurPos ++;
        
        //��ʾ��ʽ
        szData[iCurPos] = 0xA0;    
        iCurPos ++;

        strcpy( szMsg, "���°�ȫģ�����..." );
        iMsgLen = strlen(szMsg);
        //���ݳ���
        szData[iCurPos] = iMsgLen;
        iCurPos ++;

        memcpy( szData+iCurPos, szMsg, iMsgLen );
        iCurPos += iMsgLen;

        memcpy( szOutData, szData, iCurPos );
        
        return iCurPos;    
    }
/*
    // ����ѯ�Ӻ�̨��ѯ��ת�뷽�����Ϣ���ڶ�����ʱ������ʾ��Ϣ
    else if( ptApp->iTransType == TRAN_OUT_OTHER_CALC_FEE && iDataIndex == 0 )
    {
        iCurPos = 0;
        //ģ����
        szData[iCurPos] = 2;
        iCurPos ++;
        
        //��ʾ��ʽ
        szData[iCurPos] = 0x01;    
        iCurPos ++;

        sprintf( szMsg, "�տ���:%s", ptApp->szHolderName );
        iMsgLen = strlen(szMsg);

        //���ݳ���
        szData[iCurPos] = iMsgLen;
        iCurPos ++;

        memcpy( szData+iCurPos, szMsg, iMsgLen );
        iCurPos += iMsgLen;

        //��ʾ��ʽ
        szData[iCurPos] = 0x20;    
        iCurPos ++;

        strcpy( szMsg, "�Ƿ�����? 1.�� 0.��" );
        iMsgLen = strlen(szMsg);

        //���ݳ���
        szData[iCurPos] = iMsgLen;
        iCurPos ++;

        memcpy( szData+iCurPos, szMsg, iMsgLen );
        iCurPos += iMsgLen;

        memcpy( szOutData, szData, iCurPos );
        
        return iCurPos;    
    }
    // ���ף���ʱ��ʾ��Ϣ���ڴ�ӡʱ��ʾ�����ݺ�̨�����룬������ӡʱ����ʾ��Ϣ
    else if( ptApp->iTransType == TRAN_OUT_OTHER )
    {
        iCurPos = 0;
        //ģ����
        szData[iCurPos] = 2;
        iCurPos ++;
        
        //��ʾ��ʽ
        szData[iCurPos] = 0x01;    
        iCurPos ++;

        if( memcmp( ptApp->szHostRetCode, "80000", 5 ) == 0 )
        {
            strcpy( szMsg, "Ӧ����:00-80000" );
            iMsgLen = strlen(szMsg);

            //���ݳ���
            szData[iCurPos] = iMsgLen;
            iCurPos ++;

            memcpy( szData+iCurPos, szMsg, iMsgLen );
            iCurPos += iMsgLen;

            //��ʾ��ʽ
            szData[iCurPos] = 0x20;    
            iCurPos ++;

            sprintf( szMsg, "%-20.20s %-20.20s", "�����ɹ�������δ֪", "���ڴ�ӡ..." );
            iMsgLen = strlen(szMsg);
        }
        else
        {
            strcpy( szMsg, "Ӧ����:00" );
            iMsgLen = strlen(szMsg);

            //���ݳ���
            szData[iCurPos] = iMsgLen;
            iCurPos ++;

            memcpy( szData+iCurPos, szMsg, iMsgLen );
            iCurPos += iMsgLen;

            //��ʾ��ʽ
            szData[iCurPos] = 0x20;    
            iCurPos ++;

            sprintf( szMsg, "%-20.20s %-20.20s", "���׳ɹ�", "���ڴ�ӡ..." );
            iMsgLen = strlen(szMsg);
        }

        //���ݳ���
        szData[iCurPos] = iMsgLen;
        iCurPos ++;

        memcpy( szData+iCurPos, szMsg, iMsgLen );
        iCurPos += iMsgLen;

        memcpy( szOutData, szData, iCurPos );
        
        return iCurPos;    
    }
*/

    iOperIndex = ptApp->szDataSource[iDataIndex];
    //ѡ�������ʾ��Ϣ
    EXEC SQL SELECT 
        NVL(OPER_INDEX,0),
        NVL(OP_FLAG ,' '),
        NVL(MODULE_NUM,0),
        NVL(INFO1_FORMAT,' '),
        NVL(INFO1,' '),
        NVL(INFO2_FORMAT,' '),
        NVL(INFO2,' '),
        NVL(INFO3_FORMAT,' '),
        NVL(INFO3,' '),
        NVL(UPDATE_DATE, ' ')
    INTO :tOpInfo.iOperIndex,
         :tOpInfo.szOpFlag,
         :tOpInfo.iModuleNum,
         :tOpInfo.szInfo1Format,
         :tOpInfo.szInfo1,
         :tOpInfo.szInfo2Format,
         :tOpInfo.szInfo2,
         :tOpInfo.szInfo3Format,
         :tOpInfo.szInfo3,
         :tOpInfo.szUpdateDate
    FROM operation_temp 
    WHERE OPER_INDEX = :iOperIndex;
    if( SQLCODE == SQL_NO_RECORD )
    {
        strcpy( ptApp->szRetCode, ERR_INVALID_APP );
        WriteLog( ERROR, "data_index[%d] not exist", iDataIndex );
        return FAIL;
    }
    else if( SQLCODE )
    {
        strcpy( ptApp->szRetCode, ERR_SYSTEM_ERROR );
        WriteLog( ERROR, "sel operation_temp fail %ld[%d]", SQLCODE,iOperIndex );
        return FAIL;
    }
    DelTailSpace( tOpInfo.szInfo1 );
    DelTailSpace( tOpInfo.szInfo2 );
    DelTailSpace( tOpInfo.szInfo3 );

    iInfo1Len = strlen( tOpInfo.szInfo1 );
    iInfo2Len = strlen( tOpInfo.szInfo2 );
    iInfo3Len = strlen( tOpInfo.szInfo3 );

    iModuNum = 0;
    if( memcmp( tOpInfo.szInfo1Format, "FF", 2 ) != 0 )
    {
        iModuNum ++;
    }
    if( memcmp( tOpInfo.szInfo2Format, "FF", 2 ) != 0 )
    {
        iModuNum ++;
    }
    if( memcmp( tOpInfo.szInfo3Format, "FF", 2 ) != 0 )
    {
        iModuNum ++;
    }

    iCurPos = 0;
    //ģ����
    szData[iCurPos] = iModuNum;
    iCurPos ++;
        
    //ģ��1����
    if( memcmp( tOpInfo.szInfo1Format, "FF", 2 ) != 0 )
    {
        //��ʾ��ʽ
        AscToBcd((uchar*)(szData+iCurPos), 2, 0, (uchar*)(tOpInfo.szInfo1Format));
        iCurPos ++;
        //���ݳ���
        szData[iCurPos] = iInfo1Len;
        iCurPos ++;

        if( iInfo1Len > 0 )
        {
            memcpy(szData+iCurPos, tOpInfo.szInfo1, iInfo1Len);
            iCurPos += iInfo1Len;
        }
    }

    //ģ��2����
    if( memcmp( tOpInfo.szInfo2Format, "FF", 2 ) != 0 )
    {
        //��ʾ��ʽ
        AscToBcd((uchar*)(szData+iCurPos), 2, 0, (uchar*)(tOpInfo.szInfo2Format));
        iCurPos ++;
        //���ݳ���
        szData[iCurPos] = iInfo2Len;
        iCurPos ++;

        if( iInfo2Len > 0 )
        {
            memcpy(szData+iCurPos, tOpInfo.szInfo2, iInfo2Len);
            iCurPos += iInfo2Len;
        }
    }

    //ģ��3����
    if( memcmp( tOpInfo.szInfo3Format, "FF", 2 ) != 0 )
    {
        //��ʾ��ʽ
        AscToBcd((uchar*)(szData+iCurPos), 2, 0, (uchar*)(tOpInfo.szInfo3Format));
        iCurPos ++;
        //���ݳ���
        szData[iCurPos] = iInfo3Len;
        iCurPos ++;

        if( iInfo3Len > 0 )
        {
            memcpy(szData+iCurPos, tOpInfo.szInfo3, iInfo3Len);
            iCurPos += iInfo3Len;
        }
    }

    memcpy( szOutData, szData, iCurPos );

    return iCurPos;
}