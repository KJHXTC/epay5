/*******************************************************************************
 * Copyright(C)2012��2015 �������������豸���޹�˾
 * ��Ҫ���ݣ�ScriptPosģ�� POSӦ�������
 * �� �� �ˣ�Robin
 * �������ڣ�2012/11/30
 * $Revision: 1.1 $
 * $Log: GetNextTransCmd.c,v $
 * Revision 1.1  2013/01/18 08:32:37  fengw
 *
 * 1����ֺ�����
 *
 ******************************************************************************/

#define _EXTERN_

#include "ScriptPos.h"
  
int GetNextTransCmd(T_App *ptApp)
{
    int     iTransType;                 /* ������������ */
    char    szCmd[512+1];               /* ����ָ�� */
    int     iCmdCount;                  /* ָ����� */
    int     iLenCmd;                    /* ָ��� */
    char    szDataSource[32+1];         /* ָ������Դ */
    int     iDSCount;                   /* ָ������Դ���� */
    int     iCtlLen;                    /* ���Ʋ������� */
    int     szCtlPara[128+1];           /* ���Ʋ��� */

    /* ���Һ����������� */
    if(GetTranType(ptApp->szNextTransCode, &iTransType) != SUCC)
    {
        WriteLog( ERROR, "get next trans type fail" );

        return FAIL;
    }

    /* ���Һ�������ָ�� */
    memset(szCmd, 0, sizeof(szCmd));
    memset(szDataSource, 0, sizeof(szDataSource));
    memset(szCtlPara, 0, sizeof(szCtlPara));
    iCmdCount = 0;
    iLenCmd = 0;
    iDSCount = 0;
    iCtlLen = 0;

    if(GetCommands(iTransType, '0', szCmd, &iCmdCount,
                   &iLenCmd, szDataSource, &iDSCount, &iCtlLen, szCtlPara) != SUCC)
    {
        WriteLog(ERROR, "��ȡ��������[%d]����ָ��ʧ��", iTransType);

        return FAIL;
    }

    /* ����ָ�� */
    memcpy(ptApp->szCommand+ptApp->iCommandLen, szCmd, iLenCmd);
    ptApp->iCommandLen += iLenCmd;
    ptApp->iCommandNum += iCmdCount;

    /* ���Ʋ��� */
    memcpy(ptApp->szControlPara + ptApp->iControlLen, szCtlPara, iCtlLen);
    ptApp->iControlLen += iCtlLen;
    
    /* ������Դ */
    memcpy(ptApp->szDataSource+ptApp->iDataNum, szDataSource, iDSCount);
    ptApp->iDataNum += iDSCount;
    
    return SUCC;
}