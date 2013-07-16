/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� ��ȡ��������
** �� �� �ˣ����
** �������ڣ�2012-11-08
**
** $Revision: 1.3 $
** $Log: GetEpayConf.c,v $
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
** ��    �ܣ���ȡ�ն˲�������
** ���������
**        ptApp                app�ṹָ��
** ���������
**        ptEpayConf           ��������
** �� �� ֵ��
**        CONF_GET_SUCC        ������ѯ�ɹ�
**        CONF_GET_FAIL        ������ѯʧ��
**        CONF_NOT_FOUND       δ�������
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/08
** ����˵����
**
** �޸���־��
****************************************************************/
int GetEpayConf(T_App *ptApp, T_EpayConf *ptEpayConf)
{
    int iRet;

    /* ��ȡ�ն˲��� */
    iRet = GetPosConf(ptApp->iTransType, ptApp->szShopNo, ptApp->szPosNo, ptEpayConf);
    if(iRet != CONF_NOT_FOUND)
    {
        return iRet;
    }

    /* ��ȡ�̻����� */
    iRet = GetShopConf(ptApp->iTransType, ptApp->szShopNo, ptEpayConf);
    if(iRet != CONF_NOT_FOUND)
    {
        return iRet;
    }

    /* ��ȡ�������� */
    iRet = GetDeptConf(ptApp->iTransType, ptApp->szDeptDetail, ptEpayConf);
    if(iRet != CONF_NOT_FOUND)
    {
        return iRet;
    }

    /* ��ȡ���ײ��� */
    iRet = GetTransConf(ptApp->iTransType, ptEpayConf);
    if(iRet != CONF_NOT_FOUND)
    {
        return iRet;
    }

    return iRet;
}
