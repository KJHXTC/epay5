/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� ���ؽ���Ӧ��
** �� �� �ˣ����
** �������ڣ�2012-11-13
**
** $Revision: 1.7 $
** $Log: SendRspToPos.c,v $
** Revision 1.7  2013/06/14 06:26:30  fengw
**
** 1�����Ӽ����־��¼���롣
**
** Revision 1.6  2013/01/05 06:37:25  fengw
**
** 1�����SetApp�������á�
**
** Revision 1.5  2012/12/25 06:54:43  fengw
**
** 1���޸�web���׼��ͨѶ�˿ںű�������Ϊ�ַ�����
**
** Revision 1.4  2012/12/07 02:04:10  fengw
**
** 1���޸���Ϣ���з��ͺ�����
** 2�����ӷ���web��ء�
**
** Revision 1.3  2012/11/26 01:33:05  fengw
**
** 1���޸��ļ�����׺Ϊec�������ϴ���ģ�����
**
** Revision 1.1  2012/11/21 07:20:46  fengw
**
** ���ڽ��״���ģ���ʼ�汾
**
*******************************************************************/

#define _EXTERN_

#include "finatran.h"

/****************************************************************
** ��    �ܣ����ؽ���Ӧ��
** ���������
**        ptApp                app�ṹָ��
** ���������
**        ��
** �� �� ֵ��
**        ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/13
** ����˵����
**
** �޸���־��
****************************************************************/
void SendRspToPos(T_App *ptApp)
{
    /* ��app�ṹ���ݱ����������ڴ� */
    if(SetApp(ptApp->lTransDataIdx, ptApp) != SUCC)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "����app�ṹ�������ڴ�ʧ��!TransDataIdx:[%ld]",
                 ptApp->lTransDataIdx);

        return;
    }

    SendProcToAccessQue(ptApp->lProcToAccessMsgType, ptApp->lTransDataIdx);

    /* �ǼǼ����Ϣ */

    WebDispMoni(ptApp, ptApp->szTransName, gszMoniIP, gszMoniPort);

    WriteMoniLog(ptApp, ptApp->szTransName);

    return;
}
