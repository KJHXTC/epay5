/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨web�����������ģ�� ����ָ���ն�
** �� �� �ˣ����
** �������ڣ�2012-12-18
**
** $Revision: 1.4 $
** $Log: DownByShop.ec,v $
** Revision 1.4  2012/12/25 07:00:07  fengw
**
** 1���޸�web���׼��ͨѶ�˿ںű�������Ϊ�ַ�����
**
** Revision 1.3  2012/12/21 02:05:32  fengw
**
** 1�����ļ���ʽ��DOSתΪUNIX��
**
** Revision 1.2  2012/12/21 02:04:02  fengw
**
** 1���޸�Revision��Log��ʽ��
**
*******************************************************************/

#define _EXTERN_

#include "comweb.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ�����ָ���ն�
** ���������
**        ptApp                 app�ṹָ��
**        lTimeOut              ���׳�ʱʱ��
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
int DownByShop(T_App *ptApp, long lTimeOut)
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szShopNo[15+1];             /* �̻��� */
        char    szPosNo[15+1];              /* �ն˺� */
        char    szPsamNo[16+1];             /* ��ȫģ��� */
        char    szIp[15+1];                 /* IP��ַ */
        char    szTelephone[15+1];          /* �绰���� */
        int     iTermModule;                /* �ն˲���ģ�� */
        int     iPsamModule;                /* ��ȫ����ģ�� */
    EXEC SQL END DECLARE SECTION;

    memset(szShopNo, 0, sizeof(szShopNo));

	strcpy(szShopNo, ptApp->szShopNo);

    EXEC SQL
        DECLARE cur_down_by_shop CURSOR FOR
        SELECT shop_no, pos_no, psam_no, ip, telephone, term_module, psam_module 
        FROM terminal
        WHERE shop_no = :szShopNo;
    if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "�����α�cur_down_by_shopʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

        return FAIL;
    }

    EXEC SQL OPEN cur_down_by_shop;
    if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "���α�cur_down_by_shopʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

        return FAIL;
    }

    while(1)
    {
        memset(szShopNo, 0, sizeof(szShopNo));
        memset(szPosNo, 0, sizeof(szPosNo));
        memset(szPsamNo, 0, sizeof(szPsamNo));
        memset(szIp, 0, sizeof(szIp));
        memset(szTelephone, 0, sizeof(szTelephone));

        EXEC SQL
            FETCH cur_down_by_shop INTO :szShopNo, :szPosNo, :szPsamNo, :szIp, :szTelephone, :iTermModule, :iPsamModule;
        if(SQLCODE == SQL_NO_RECORD)
        {
            EXEC SQL CLOSE cur_down_by_shop;

            break;
        }
        else if(SQLCODE)
        {
            EXEC SQL CLOSE cur_down_by_shop;

            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

            WriteLog(ERROR, "��ȡ�α�cur_down_by_shopʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

            return FAIL;
        }

        DelTailSpace(szShopNo);
        DelTailSpace(szPosNo);        
        DelTailSpace(szPsamNo);
        DelTailSpace(szIp);
        DelTailSpace(szTelephone);

        strcpy(ptApp->szShopNo, szShopNo);
        strcpy(ptApp->szPosNo, szPosNo);
        strcpy(ptApp->szPsamNo, szPsamNo);
        strcpy(ptApp->szIp, szIp);
        strcpy(ptApp->szCallingTel, szTelephone);
        ptApp->iTermModule = iTermModule;
        ptApp->iPsamModule = iPsamModule;

        if(SendWebReq(ptApp) != SUCC)
        {
            /* ����WEB��� */
            WebDispMoni(ptApp, ptApp->szTransName, gszMoniIP, gszMoniPort);
        }
	}

	return SUCC;
}