/*****************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨ϵͳ״̬���ģ�� ��ȡ��Ϣ������Ϣ
** �� �� �ˣ����
** �������ڣ�2012/10/30
**
** $Revision: 1.4 $
** $Log: GetEpayStatus.c,v $
** Revision 1.4  2012/12/21 02:08:15  fengw
**
** 1������Revision��Log��
**
*******************************************************************/

#define _EXTERN_

#include "epaymoni.h"

/****************************************************************
** ��    �ܣ�������״̬
** ���������
**        szFileName            ��ϸ��Ϣ�ļ���
** ���������
**        szProcStatus          ����״̬�����Ϣ
**        szMsgStatus           ��Ϣ����״̬�����Ϣ
**        szCommStatus          ͨѶ�˿�״̬�����Ϣ
** �� �� ֵ��
**        SUCC                  ���ɹ�
**        FAIL                  ���ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/10/31
** ����˵����
**        ״̬��ϸ��Ϣֱ��д���ļ�
** �޸���־��
****************************************************************/
int GetEpayStatus(char *szFileName, char *szProcStatus, char *szMsgStatus, char *szCommStatus)
{
    /* ����ϸ��Ϣ�ļ� */
    fpStatusFile = fopen(szFileName, "w");
    if(fpStatusFile == NULL)
    {
        WriteLog(ERROR, "������ϸ��Ϣ�ļ�[%s]ʧ��!", szFileName);

        return FAIL;
    }

    /* ��ȡ���̼����Ϣ */
    memset(szProcStatus, 0, sizeof(szProcStatus));
    if(GetProcStatus(szProcStatus) != SUCC)
    {
        WriteLog(ERROR, "���ɽ���״̬��Ϣʧ��!");

        fclose(fpStatusFile);

        return FAIL;
    }

    /* ��ȡ��Ϣ���м����Ϣ */
    memset(szMsgStatus, 0, sizeof(szMsgStatus));
    if(GetMsgStatus(szMsgStatus) != SUCC)
    {
        WriteLog(ERROR, "������Ϣ����״̬��Ϣʧ��!");

        fclose(fpStatusFile);

        return FAIL;
    }

    /* ��ȡͨѶ�˿ڼ����Ϣ */
    memset(szCommStatus, 0, sizeof(szCommStatus));
    if(GetCommStatus(szCommStatus) != SUCC)
    {
        WriteLog(ERROR, "����ͨѶ�˿�״̬��Ϣʧ��!");

        fclose(fpStatusFile);

        return FAIL;
    }

    fclose(fpStatusFile);

    return SUCC;
}
