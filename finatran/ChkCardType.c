/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� ������ɼ��
** �� �� �ˣ����
** �������ڣ�2012-11-08
**
** $Revision: 1.4 $
** $Log: ChkCardType.c,v $
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
** ��    �ܣ���鿨���Ƿ����
** ���������
**        cCardType             ������ '0'-��ǿ� '1'-���ǿ� '3'-׼���ǿ�
**        iOutCardBelong        ������ 0-���б��� 1-������� 2-����
**        szCardAllowedType     ��ɿ������ͣ�ÿλ����ĳ�ֿ��Ƿ������ף�1Ϊ����0Ϊ������
**                              ��һλ�����н�ǿ�
**                              �ڶ�λ�����д��ǿ�
**                              ����λ������׼���ǿ�
**                              ����λ�����н�ǿ�
**                              ����λ�����д��ǿ�
**                              ����λ������׼���ǿ�
**                              ����λ�����ؽ�ǿ�
**                              �ڰ�λ�����ش��ǿ�
**                              �ھ�λ������׼���ǿ�
** ���������
**        ��
** �� �� ֵ��
**        SUCC                  ����ÿ��ֽ���
**        FAIL                  ��ֹ�ÿ��ֽ���
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/08
** ����˵����
**
** �޸���־��
****************************************************************/
int ChkCardType(char cCardType, int iCardBelong, char *szCardAllowedType)
{
    int iIndex;

    /* ȫ1��ʾ���п���֧�֣�ֱ�ӷ��ؼ��ɹ� */
    if(memcmp(szCardAllowedType, "111111111", 9) == 0)
    {
        return SUCC;
    }

    /* ���ݿ������������ͻ�ȡ��ɱ�־λ����ֵ */
    iIndex = 0;

    switch(iCardBelong)
    {
        /* ���б��� */
        case LOCAL_BANK_LOCAL_CITY:
            iIndex += 6;
            break;
        /* ������� */
        case LOCAL_BANK_OTHER_CITY:
            iIndex += 3;
            break;
        /* ���� */
        case OTHER_BANK:
            iIndex += 0;
            break;
        default:
            WriteLog(ERROR, "����������[%d]δ����", iCardBelong);
            return FAIL;
    }

    switch(cCardType)
    {
        /* ��ǿ� */
        case DEBIT_CARD:
            iIndex += 0;
            break;
        /* ���ǿ� */
        case CREDIT_CARD:
            iIndex += 1;
            break;
        /* ׼���ǿ� */
        case PRECREDIT_CARD:
            iIndex += 2;
            break;
        default:
            WriteLog(ERROR, "������[%c]δ����", cCardType);
            return FAIL;
    }

    if(szCardAllowedType[iIndex] == '1')
    {
        return SUCC;
    }

    return FAIL;
}
