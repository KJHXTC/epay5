/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨web�����������ģ�� �����Ĳ��
** �� �� �ˣ����
** �������ڣ�2012-12-18
**
** $Revision: 1.3 $
** $Log: UnpackWebReq.c,v $
** Revision 1.3  2012/12/25 07:01:15  fengw
**
** 1�������������ʹ���ֵBUG��
**
** Revision 1.2  2012/12/21 02:03:53  fengw
**
** 1���޸�GetTransTypeByTransCode����ΪGetTranInfo��
** 2���޸�Revision��Log��ʽ��
**
*******************************************************************/

#define _EXTERN_

#include "comweb.h"

/****************************************************************
** ��    �ܣ������Ĳ��
** ���������
**        szReqBuf              ����������
**        iLen                  ���ĳ���
** ���������
**        ptApp                 app�ṹָ��
** �� �� ֵ��
**        SUCC                  �ɹ�
**        FAIL                  ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/12/18
** ����˵����
**
** �޸���־��
****************************************************************/
int UnpackWebReq(T_App *ptApp, char *szReqBuf, int iLen)
{
    int     iIndex;                 /* buf���� */
    int     iMsgCount;              /* ���ż�¼�� */
    
    iIndex = 0;
    
    /* ���״��� */
    memcpy(ptApp->szTransCode, szReqBuf+iIndex, 8);
    iIndex += 8;

    /* ���ݽ��״����ȡ���׶��� */
    if(GetTranInfo(ptApp) != SUCC)
    {
        return FAIL;
    }

    /* ���·�ʽ */
    giDownType = szReqBuf[iIndex] - '0';
    iIndex += 1;

	switch(giDownType)
	{
        /* ����ָ���ն� */
        case DOWN_SPECIFY_POS:
            memcpy(ptApp->szShopNo, szReqBuf+iIndex, 15);
            iIndex += 15;
            DelTailSpace(ptApp->szShopNo);

            memcpy(ptApp->szPosNo, szReqBuf+iIndex, 15);
            iIndex += 15;
            DelTailSpace(ptApp->szPosNo);

            iIndex += 40;

            break;
        /* ����ָ���̻��ն� */
        case DOWN_SPECIFY_SHOP:
            memcpy(ptApp->szShopNo, szReqBuf+iIndex, 15);
            iIndex += 15;
            DelTailSpace(ptApp->szShopNo);

            iIndex += 55;

            break;
        /* ���������ն� */
        case DOWN_ALL:
            iIndex += 70;

            break;
        /* ����ָ��Ӧ�������ն� */
        case DOWN_SPECIFY_TYPE:
            memcpy(ptApp->szShopNo, szReqBuf+iIndex, 10);
            iIndex += 10;

            iIndex += 60;

            break;
        /* ����ָ���������ն� */
        case DOWN_SPECIFY_DEPT:
            memcpy(ptApp->szDeptDetail, szReqBuf+iIndex, 70);
            iIndex += 70;
            DelTailSpace(ptApp->szDeptDetail);

            break;
        default:
            strcpy(ptApp->szRetCode, ERR_UNDEF_DOWNTYPE);

            WriteLog(ERROR, "��������:[%d]δ����!", giDownType);

            return FAIL;
    }

    /* ����ģʽ */
    giDownMode = szReqBuf[iIndex] - '0';
    iIndex += 1;

    /* ���ݽ��ײ�ⱨ�� */
    switch(ptApp->iTransType)
    {
        case CENDOWN_TERM_PARA:             /* �����ն˲���ģ�� */
        case CENDOWN_PSAM_PARA:             /* ���°�ȫ����ģ�� */
            /* ����λͼ */
            memcpy(gszBitmap, szReqBuf+iIndex, 32);
            iIndex += 32;

            break;
        case CENDOWN_MENU:                  /* ���²˵� */
        case CENDOWN_ALL_OPERATION:         /* ����Ӧ�� */
        case CENDOWN_PAYLIST:               /* �����˵� */
        /*
        case CENDOWN_COMM_PARA:             ����ͨѶ����
            break;
        */
        case CENDOWN_OPERATION_INFO:        /* ���²�����ʾ */
        case CENDOWN_FUNCTION_INFO:         /* ���¹�����ʾ */
        case CENDOWN_PRINT_INFO:            /* ���´�ӡ��¼ */
            /* ����λͼ */
            memcpy(gszBitmap, szReqBuf+iIndex, 256);
            iIndex += 256;

            break;
        case CENDOWN_MSG:                   /* ���¶��� */
            /* ���ż�¼�� */
            iMsgCount = szReqBuf[iIndex] - '0';

            memcpy(gszBitmap, szReqBuf+iIndex, 1+6*iMsgCount);
            iIndex += 1+6*iMsgCount;

            break;
        case CENDOWN_FIRST_PAGE:            /* ������ҳ��Ϣ */
            /* ���¼�¼�� */
            memcpy(gszBitmap, szReqBuf+iIndex, 6);
            iIndex += 6;

            break;
        default:
            strcpy(ptApp->szRetCode, ERR_INVALID_TRANS);

            WriteLog(ERROR, "δ���彻������[%d]�����Ľӿ�!", ptApp->iTransType);

            return FAIL;
    }

    /* POS�������ڡ�ʱ�� */
	GetSysDate(ptApp->szPosDate);
	GetSysTime(ptApp->szPosTime);

    /* ��Ӧ�� */
	strcpy(ptApp->szRetCode, "NN");
	strcpy(ptApp->szHostRetCode, "NN");

    /* �������� */
	ptApp->iCallType = CALLTYPE_CENTER;

	return SUCC;
}
