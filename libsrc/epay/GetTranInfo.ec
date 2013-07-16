/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨epay������ ���ݽ������ȡ���׶���
** �� �� �ˣ����
** �������ڣ�2012-12-20
**
** $Revision: 1.7 $
** $Log: GetTranInfo.ec,v $
** Revision 1.7  2013/02/22 02:49:55  fengw
**
** 1��trans_def������business_type�ֶΡ�
**
** Revision 1.6  2013/01/14 06:22:56  fengw
**
** 1���޸�ָ��������Դ�������롣
**
** Revision 1.5  2012/12/26 08:31:11  fengw
**
** 1������GetCommands��������ʱ����������ʹ���
**
** Revision 1.4  2012/12/24 04:44:15  wukj
** ȡָ�������ָ�����
**
** Revision 1.3  2012/12/20 09:20:59  wukj
** *** empty log message ***
**
*******************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "app.h"
#include "user.h"
#include "dbtool.h"
#include "errcode.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ����ý�����������ƥ��
** ���������
**        ptApp->szTransCode        ������
** ���������
**        ptApp                     app�ṹָ��
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/12/20
** ����˵����
**
** �޸���־��
****************************************************************/
int GetTranInfo(T_App *ptApp) 
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szTransCode[8+1];                   /* ������ */
        int     iTransType;                         /* �������� */
        char    szNextTransCode[8+1];               /* ���������� */
        int     iBusinessType;                      /* ����ҵ������ */
        char    szExcepHandle[1+1];                 /* �쳣������� */
        char    szPinBlock[1+1];                    /* PinBlock�����㷨 */
        int     iFunctionIndex;                     /* ��ʾ��Ϣ���� */
        char    szTransName[20+1];                  /* �������� */
        int     iTelephoneNo;                       /* �绰���� */
        char    szDispType[1+1];                    /* ˢ�·�ʽ */
        int     iToTransMsgType;                    /* ���״���ģ�������Ϣ���� */
        int     iToHostMsgType;                     /* ��̨�ӿ�ģ�������Ϣ���� */
    EXEC SQL END DECLARE SECTION;
    
    char    szCmd[512+1];                           /* ����ָ�� */
    int     iCmdCount;                              /* ָ����� */
    int     iLenCmd;                                /* ָ��� */
    char    szDataSource[32+1];                     /* ָ������Դ */
    int     iDSCount;                               /* ָ������Դ���� */
    int     iCtlLen = 0;                            /*ָ���������*/
    int     szCtlPara[101];                         /*ָ�����*/

    memset(szTransCode, 0, sizeof(szTransCode));
    memcpy(szTransCode, "__", 2);
    memcpy(szTransCode+2, ptApp->szTransCode+2, 6);
    
    memset(szNextTransCode, 0, sizeof(szNextTransCode));
    memset(szExcepHandle, 0, sizeof(szExcepHandle));
    memset(szPinBlock, 0, sizeof(szPinBlock));
    memset(szTransName, 0, sizeof(szTransName));
    memset(szDispType, 0, sizeof(szDispType));
    memset(szCtlPara, 0, sizeof(szCtlPara));

    EXEC SQL
    SELECT trans_type, next_trans_code, business_type, excep_handle, pin_block, NVL(function_index, 0), trans_name,
               NVL(telephone_no, 0), disp_type, NVL(totrans_msg_type, 0), NVL(tohost_msg_type, 0)
    INTO :iTransType, :szNextTransCode, :iBusinessType, :szExcepHandle, :szPinBlock, :iFunctionIndex, :szTransName,
             :iTelephoneNo, :szDispType, :iToTransMsgType, :iToHostMsgType
    FROM trans_def
    WHERE trans_code LIKE :szTransCode;
    if(SQLCODE == SQL_NO_RECORD)
    {
        WriteLog(ERROR, "������[%s]δ����!SQLCODE=%d SQLERR=%s", szTransCode, SQLCODE, SQLERR);
        strcpy(ptApp->szRetCode, ERR_INVALID_TRANS);
        strcpy(ptApp->szTransName, ptApp->szTransCode);
        return FAIL;
    }
    else if(SQLCODE)
    {
        WriteLog(ERROR, "��ѯ ������[%s] ���׶���ʧ��!SQLCODE=%d SQLERR=%s", szTransCode, SQLCODE, SQLERR);
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);
        strcpy(ptApp->szTransName, ptApp->szTransCode);
        ptApp->cDispType = '1';
        return FAIL;
    }

    DelTailSpace(szNextTransCode);
    DelTailSpace(szTransName);

    /* �ֵ����ɷѣ��ն����ò�ͬ�Ľ��״������֣��Ա�ݴ˴����ݿ���в��Ҷ�Ӧ��
           �շѻ������롣�����Ҫ�ڽ��׶����trans_def�ж�����������֮��Ӧ������
           ��Ҫ�������̴��롣����ֻ��Ҫ����һ�������ɷѽ��ף�
           ��Щ�ֵ����ɷѵĽ��״������λ������ɷѱ�����ͬ����̨�Ľ��״������̶�
       ���û����ɷѵĽ������� */
    if(iTransType > 100000)
    {
        ptApp->iTransType = iTransType % 1000;
    }
    else
    {
        ptApp->iTransType = iTransType;
    }

    /* ��סԭʼ�Ľ��ף��Ա����������Ҫ�ж�ԭʼ����ʱʹ�� */
    if(ptApp->iSteps == 1)
    {
        ptApp->iOldTransType = iTransType;
    }

    strcpy(ptApp->szNextTransCode, szNextTransCode);
    strcpy(ptApp->szTransName, szTransName);
    ptApp->cExcepHandle = szExcepHandle[0];
    ptApp->iBusinessType = iBusinessType;
    ptApp->cDispType = szDispType[0];
    ptApp->lAccessToProcMsgType = iToTransMsgType;
    ptApp->lProcToPresentMsgType = iToHostMsgType;

    /* ȡ�����׵ĺ���ָ�� */
    memset(szCmd, 0, sizeof(szCmd));
    memset(szDataSource, 0, sizeof(szDataSource));
        
    if(GetCommands(ptApp->iTransType, '1', szCmd, &iCmdCount,
                   &iLenCmd, szDataSource, &iDSCount,&iCtlLen,szCtlPara) != SUCC)
    {
        WriteLog(ERROR, "��ȡ��������[%d]����ָ��ʧ��", ptApp->iTransType);

        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        return FAIL;
    }

    /* ����ָ�� */
    memcpy(ptApp->szCommand+ptApp->iCommandLen, szCmd, iLenCmd);
    ptApp->iCommandLen += iLenCmd;
    ptApp->iCommandNum += iCmdCount;
    //����ָ�����
    memcpy(ptApp->szControlPara + ptApp->iControlLen, szCtlPara, iCtlLen);
    ptApp->iControlLen += iCtlLen;

    /* ������Դ */
    memcpy(ptApp->szDataSource+ptApp->iDataNum, szDataSource, iDSCount);
    ptApp->iDataNum += iDSCount;

    /* ȡ�������׵�ָ������ڱ����׵ĺ���ָ��֮�� */
    if(strlen(ptApp->szNextTransCode) == 8)
    {
        iTransType = atol(ptApp->szNextTransCode);

        memset(szCmd, 0, sizeof(szCmd));
        memset(szDataSource, 0, sizeof(szDataSource));
            
        if(GetCommands(iTransType, '0', szCmd, &iCmdCount,
                &iLenCmd, szDataSource, &iDSCount,&iCtlLen,szCtlPara) != SUCC)
        {
            WriteLog(ERROR, "��ȡ��������[%d]����ָ��ʧ��", iTransType);

            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

            return FAIL;
        }

        /* ����ָ�� */
        memcpy(ptApp->szCommand+ptApp->iCommandLen, szCmd, iLenCmd);
        ptApp->iCommandLen += iLenCmd;
        ptApp->iCommandNum += iCmdCount;
        //����ָ�����
        memcpy(ptApp->szControlPara+ptApp->iControlLen, szCtlPara, iCtlLen);
        ptApp->iControlLen += iCtlLen;

        /* ������Դ */
        memcpy(ptApp->szDataSource, szDataSource, iDSCount);
        ptApp->iDataNum = iDSCount;
    }

    return SUCC;
}
