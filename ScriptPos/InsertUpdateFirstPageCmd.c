/*******************************************************************************
 * Copyright(C)2012��2015 �������������豸���޹�˾
 * ��Ҫ���ݣ��ն����ϱ���ز�������
 * �� �� �ˣ�Robin
 * �������ڣ�2012/12/11
 *
 * $Revision: 1.1 $
 * $Log: InsertUpdateFirstPageCmd.c,v $
 * Revision 1.1  2013/01/18 08:32:37  fengw
 *
 * 1����ֺ�����
 *
 ******************************************************************************/

#define _EXTERN_

#include "ScriptPos.h"

/*****************************************************************
** ��    ��:���ԭ���̴����д��ڼ���MACָ��/��������ָ��򽫸�����ҳ��Ϣָ�����
            ����MACָ��/��������ָ��֮ǰ�����򽫸�����ҳ��Ϣ׷����ԭ���̴���֮��
** �������:
           ptAppStru
** �������:
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**
****************************************************************/
void  InsertUpdateFirstPageCmd( ptAppStru )
T_App *ptAppStru;
{
    int i, iCmdLen, iCmdNum, iLen, iCmdBytes, iFlag;
    uchar ucCmd;
    char    szCmd[100], szTmpStr[256];

    iFlag = 0;

    memcpy( szCmd, ptAppStru->szCommand, ptAppStru->iCommandLen);
    iCmdNum = ptAppStru->iCommandNum;
    iCmdLen = ptAppStru->iCommandLen;

    //���Ҽ���MACָ��/��������ָ������λ��
    for( i=1, iLen=0; i<=iCmdNum; i++ )
    {
        iCmdBytes = CalcCmdBytes( (uchar)szCmd[iLen] );

        ucCmd = szCmd[iLen]&0x3F;

        //����MACָ��
        if( ucCmd == 0x0D )
        {
            iFlag = 1;
            break;
        }
        //��������ָ��
        if( ucCmd == 0x24 )
        {
            iFlag = 1;
            break;
        }

        iLen = iLen+iCmdBytes;
    }

    //���̴����д��ڼ���MACָ��/��������ָ��
    if( iFlag == 1 )
    {
        memcpy( szTmpStr, szCmd, iLen );    
        memcpy( szTmpStr+iLen, "\x9B", 1 );
        memcpy( szTmpStr+iLen+1, szCmd+iLen, iCmdLen-iLen );
        szTmpStr[iCmdLen+1] = 0;
    }
    else
    {
        memcpy( szTmpStr, szCmd, iCmdLen );
        memcpy( szTmpStr+iCmdLen, "\x9B", 1 );
        szTmpStr[iCmdLen+1] = 0;
    }

    ptAppStru->iCommandLen = iCmdLen+1;
    ptAppStru->iCommandNum ++;

    memcpy( ptAppStru->szCommand, szTmpStr, iCmdLen+1 );

    return;
}