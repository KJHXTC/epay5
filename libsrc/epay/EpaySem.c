/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨epay������ �ź�������
** �� �� �ˣ����
** �������ڣ�2012-11-27
**
** $Revision: 1.6 $
** $Log: EpaySem.c,v $
** Revision 1.6  2013/06/28 08:35:16  fengw
**
** 1����Ӵ�����ɾ��ʱ��¼TRACE��־�����ֹ���ʱ���ڸ���ȷ�����⡣
**
** Revision 1.5  2013/06/25 01:57:46  fengw
**
** 1�����Ӵ����ɹ����¼TRACE��־��
**
** Revision 1.4  2012/12/21 02:11:36  fengw
**
** 1���޸�Revision��Log��ʽ��
**
*******************************************************************/

#include "EpaySem.h"

int CreateEpaySem()
{
    char    szFileName[128+1];

    memset(szFileName, 0, sizeof(szFileName));

    WriteLog(TRACE, "����EPAY�ź�����ʼ");

    GetFullName("WORKDIR", SEM_FILE, szFileName); 

    /* ����ACCESS�ź��� */
    if((giSemAccessID = CreateSem(szFileName, SEM_ACCESS_ID, 1)) == FAIL)
    {
        WriteLog(ERROR, "����ACCESS�ź���ʧ��");
        
        RmSem(giSemAccessID);

        return FAIL;
    }

    /* ����TDI�ź��� */
    if((giSemTdiID = CreateSem(szFileName, SEM_TDI_ID, 1)) == FAIL)
    {
        WriteLog(ERROR, "����TDI�ź���ʧ��");
        
        RmSem(giSemAccessID);
        RmSem(giSemTdiID);

        return FAIL;
    }

    /* ����HOST�ź��� */
    if((giSemHostID = CreateSem(szFileName, SEM_HOST_ID, 1)) == FAIL)
    {
        WriteLog(ERROR, "����HOST�ź���ʧ��");

        RmSem(giSemAccessID);
        RmSem(giSemTdiID);
        RmSem(giSemHostID);

        return FAIL;
    }

    WriteLog(TRACE, "����EPAY�ź����ɹ�");

    return SUCC;
}

int GetEpaySem(int iSemType)
{
    char    szFileName[128+1];

    memset(szFileName, 0, sizeof(szFileName));

    GetFullName("WORKDIR", SEM_FILE, szFileName); 

    switch(iSemType)
    {
        case SEM_ACCESS_ID:
            if(giSemAccessID <= 0 &&
               (giSemAccessID = GetSem(szFileName, SEM_ACCESS_ID)) == FAIL)
            {
                WriteLog(ERROR, "��ȡACCESS�ź���ʧ��!");

                return FAIL;
            }

            return giSemAccessID;
        case SEM_TDI_ID:
            if(giSemTdiID <= 0 &&
               (giSemTdiID = GetSem(szFileName, SEM_TDI_ID)) == FAIL)
            {
                WriteLog(ERROR, "��ȡTDI�ź���ʧ��!");

                return FAIL;
            }

            return giSemTdiID;
        case SEM_HOST_ID:
            if(giSemHostID <= 0 &&
               (giSemHostID = GetSem(szFileName, SEM_HOST_ID)) == FAIL)
            {
                WriteLog(ERROR, "��ȡHOSE�ź���ʧ��!");

                return FAIL;
            }

            return giSemHostID;
        default:
            WriteLog(ERROR, "�ź�������:[%d]δ����!", iSemType);
            
            return FAIL;
    }
}

int RmEpaySem()
{
    WriteLog(TRACE, "ɾ��EPAY�ź�����ʼ");

    /* ɾ��ACCESS�ź��� */
    if(GetEpaySem(SEM_ACCESS_ID) == FAIL)
    {
        WriteLog(ERROR, "��ȡACCESS�ź���ʧ��!");

        return FAIL;
    }

    if(RmSem(giSemAccessID) != SUCC)
    {
        WriteLog(ERROR, "ɾ��ACCESS�ź���ʧ��!");

        return FAIL;
    }

    /* ɾ��TDI�ź��� */
    if(GetEpaySem(SEM_TDI_ID) == FAIL)
    {
        WriteLog(ERROR, "��ȡTDI�ź���ʧ��!");

        return FAIL;
    }

    if(RmSem(giSemTdiID) != SUCC)
    {
        WriteLog(ERROR, "ɾ��TDI�ź���ʧ��!");

        return FAIL;
    }

    /* ɾ��HOST�ź��� */
    if(GetEpaySem(SEM_HOST_ID) == FAIL)
    {
        WriteLog(ERROR, "��ȡHOST�ź���ʧ��!");

        return FAIL;
    }

    if(RmSem(giSemHostID) != SUCC)
    {
        WriteLog(ERROR, "ɾ��HOST�ź���ʧ��!");

        return FAIL;
    }

    WriteLog(TRACE, "ɾ��EPAY�ź����ɹ�");

    return SUCC;
}

int PSem(int iSemType, int iResource)
{
    int     iSemID;

    if((iSemID = GetEpaySem(iSemType)) == FAIL)
    {
        return FAIL;
    }

    return P(iSemID, iResource);
}

int VSem(int iSemType, int iResource)
{
    int     iSemID;

    if((iSemID = GetEpaySem(iSemType)) == FAIL)
    {
        return FAIL;
    }

    return V(iSemID, iResource);
}
