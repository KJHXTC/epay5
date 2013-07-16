/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨web�����������ģ�� web���״���
** �� �� �ˣ����
** �������ڣ�2012-12-18
**
** $Revision: 1.3 $S
** $Log: ProcWebTrans.c,v $
** Revision 1.3  2012/12/21 02:05:32  fengw
**
** 1�����ļ���ʽ��DOSתΪUNIX��
**
** Revision 1.2  2012/12/21 02:04:03  fengw
**
** 1���޸�Revision��Log��ʽ��
**
*******************************************************************/

#define _EXTERN_

#include "comweb.h"

/****************************************************************
** ��    �ܣ�web���״���
** ���������
**        ptApp                 app�ṹָ��
** ���������
**        ��
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
int ProcWebTrans(T_App *ptApp)
{
    int     iRet;                           /* �������ý�� */

    /* ���ݽ��׵��ô����� */
    switch(ptApp->iTransType)
    {
        case CENDOWN_TERM_PARA:             /* �����ն˲���ģ�� */
            iRet = DownTermPara(ptApp);
            break;
        case CENDOWN_PSAM_PARA:             /* ���°�ȫ����ģ�� */
            iRet = DownPsamPara(ptApp);
            break;
        case CENDOWN_MENU:                  /* ���²˵� */
            iRet = DownMenu(ptApp);
            break;
        case CENDOWN_ALL_OPERATION:         /* ����Ӧ�� */
            iRet = DownApp(ptApp);
            break;
        case CENDOWN_PAYLIST:               /* �����˵� */
            iRet = DownPayList(ptApp);
            break;
        /*
        case CENDOWN_COMM_PARA:             ����ͨѶ����
            iRet = DownCommPara(ptApp);
            break;
        */
        case CENDOWN_OPERATION_INFO:        /* ���²�����ʾ */
            iRet = DownOperation(ptApp);
            break;
        case CENDOWN_FUNCTION_INFO:         /* ���¹�����ʾ */
            iRet = DownFunction(ptApp);
            break;
        case CENDOWN_PRINT_INFO:            /* ���´�ӡ��¼ */
            iRet = DownPrint(ptApp);
            break;
        case CENDOWN_MSG:                   /* ���¶��� */
            iRet = DownMsg(ptApp);
            break;
        case CENDOWN_FIRST_PAGE:            /* ������ҳ��Ϣ */
            iRet = DownFirstPage(ptApp);
            break;
        default:
            strcpy(ptApp->szRetCode, ERR_INVALID_TRANS);

            WriteLog(ERROR, "δ���彻������[%d]!", ptApp->iTransType);

            return FAIL;
    }

    if(iRet != SUCC)
    {
        return FAIL;
    }
    else if(giDownMode == DOWN_MODE_IMMEDIATE)
    {
        switch(giDownType)
        {
            /* ����ָ���ն� */
            case DOWN_SPECIFY_POS:
                iRet = DownByPos(ptApp, glTimeOut);
                break;
            /* ����ָ���̻��ն� */
            case DOWN_SPECIFY_SHOP:
                iRet = DownByShop(ptApp, glTimeOut);
                break;
            /* ���������ն� */
            case DOWN_ALL:
                iRet = DownByAll(ptApp, glTimeOut);
                break;
            /* ����ָ��Ӧ�������ն� */
            case DOWN_SPECIFY_TYPE:
                iRet = DownByAppType(ptApp, glTimeOut);
                break;
            /* ����ָ���������ն� */
            case DOWN_SPECIFY_DEPT:
                iRet = DownByDept(ptApp, glTimeOut);
                break;
            default:
                strcpy(ptApp->szRetCode, ERR_UNDEF_DOWNTYPE);

                WriteLog(ERROR, "��������:[%d]δ����!", giDownType);

                return FAIL;
        }
    }

    if(iRet == SUCC)
    {
        strcpy(ptApp->szRetCode, TRANS_SUCC);
    }

    return iRet;
}