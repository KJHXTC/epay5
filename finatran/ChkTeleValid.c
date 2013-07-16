/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� �绰����Ϸ��Լ��
** �� �� �ˣ����
** �������ڣ�2012-11-12
**
** $Revision: 1.6 $
** $Log: ChkTeleValid.c,v $
** Revision 1.6  2013/06/28 06:03:30  fengw
**
** 1�������ն����к��������BUG��
**
** Revision 1.5  2013/06/07 02:14:40  fengw
**
** 1�������Ƿ��������ж���ش��롣
**
** Revision 1.4  2012/12/04 01:24:28  fengw
**
** 1���滻ErrorLogΪWriteLog��
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
** ��    �ܣ��绰����Ϸ��Լ��
** ���������
**        gszTelephone          �󶨵绰����
**        giTeleChkLen          �绰������λ��
** ���������
**        ��
** �� �� ֵ��
**        SUCC                  ���ɹ�
**        FAIL                  ���ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/12
** ����˵����
**        1.����ն����к����Ƿ����ն������ն˵ǼǺ���һ�¡���
**          �Ǽ�����Ϊ00000000ʱ�����ͺ���ΪFFFFFFFFʱ��������顣
**        2.����ն����ͱ��к��������������ͱ��к����Ƿ�һ�¡�
** �޸���־��
****************************************************************/
int ChkTeleValid(T_App *ptApp)
{
    int     iChkLen;        /* �绰������λ�� */
    int     iTeleLen;       /* �ն����͵绰���볤�� */
    int     iLen;           /* �Ǽ����ϵ绰���볤�� */

    /* �ж��Ƿ������� */
    if(giTeleChkType == 0)
    {
        return SUCC;
    }

    /* �ն����к����� */
    /* �ն������е绰����Ϊ00000000ʱ����������к��� */
    /* �ն��������к���ΪFFFFFFFFʱ����������к��룬����ƽ̨������ */
    if(memcmp(gszTelephone, "00000000", 8) != 0 &&
       memcmp(ptApp->szCallingTel, "FFFFFFFF", 8) != 0)
    {
        iTeleLen = strlen(ptApp->szCallingTel);
        iLen = strlen(gszTelephone);

        /* �����õĵ绰������λ���������͵绰���볤�Ȼ�Ǽ����Ϻ��볤�� */
        /* ��鳤�����������г�����С���Ǹ����볤��Ϊ׼ */
        /* ���������õļ��λ��Ϊ׼ */
        if(giTeleChkLen > iLen || giTeleChkLen > iTeleLen)
        {
            iChkLen = iLen>iTeleLen?iTeleLen:iLen;
        }
        else
        {
            iChkLen = giTeleChkLen;
        }

        if(memcmp(ptApp->szCallingTel + iTeleLen - iChkLen,
                  gszTelephone + iLen - iChkLen,
                  iChkLen) != 0)
        {
            strcpy(ptApp->szRetCode, ERR_INVALID_PHONE);

            WriteLog(ERROR, "�ն�[%s]���к���Ƿ����ն�����:[%s] ���ϵǼ�:[%s]",
                     ptApp->szPsamNo, ptApp->szCallingTel, giTeleChkLen);

            return FAIL;
        }
	}

	/* ���к����� */
    if(strcmp(ptApp->szCalledTelByTerm, ptApp->szCalledTelByNac) != 0)
    {
        strcpy(ptApp->szRetCode, ERR_INVALID_PHONE);

        WriteLog(ERROR, "�ն�[%s]���нк���Ƿ����ն�����:[%s] ��������:[%s]",
                 ptApp->szPsamNo, ptApp->szCalledTelByTerm, ptApp->szCalledTelByNac);

        return FAIL;
    }

	return SUCC;
}
