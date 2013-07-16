/*******************************************************************************
 * Copyright(C)2012��2015 �������������豸���޹�˾
 * ��Ҫ���ݣ��ն����ϱ���ز�������
 * �� �� �ˣ�Robin
 * �������ڣ�2012/12/11
 *
 * $Revision: 1.2 $
 * $Log: ChkTmsUpdate.ec,v $
 * Revision 1.2  2013/06/14 06:32:54  fengw
 *
 * 1���ļ���ʽת����
 *
 * Revision 1.1  2013/01/18 08:32:37  fengw
 *
 * 1����ֺ�����
 *
 ******************************************************************************/

#define _EXTERN_

#include "ScriptPos.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL EnD DECLARE SECTION;

/*****************************************************************
** ��    ��:���Ӽ��TMS֪ͨ��ʶ
** �������:
           ptApp
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
int ChkTmsUpdate(T_App *ptApp)
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szShopNo[20+1];                 /* �̻��� */
        char    szPosNo[20+1];                  /* �ն˺� */
        int     iCnt;                           /* ��¼�� */
    EXEC SQL END DECLARE SECTION;

    /* ��Ч�նˣ��������� */
    if(memcmp(ptApp->szRetCode, ERR_INVALID_TERM, 2) == 0 ||
       memcmp(ptApp->szRetCode, ERR_DUPLICATE_PSAM_NO, 2) == 0 ||
       memcmp(ptApp->szRetCode, ERR_INVALID_MERCHANT, 2) == 0 ||
       memcmp(ptApp->szTransCode, DOWN_TMS_CODE, 8) == 0 ||
       strlen(ptApp->szNextTransCode) >= 8)
    {
        return SUCC;
    }

    memset(szShopNo, 0, sizeof(szShopNo));
    memset(szPosNo, 0, sizeof(szPosNo));

    strcpy(szShopNo, ptApp->szShopNo);
    strcpy(szPosNo, ptApp->szPosNo);

    EXEC SQL SELECT COUNT(*) 
        INTO :iCnt 
        FROM tm_vpos_info
        WHERE TRIM(shop_no) = :szShopNo AND
              TRIM(pos_no) = :szPosNo AND notice_flag = '1';
    if(SQLCODE)
    {
        strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "��ѯ �̻���[%s] �ն˺�:[%s] TMS����֪ͨʧ��!SQLCODE=%d SQLERR=%s",
                 szShopNo, szPosNo, SQLCODE, SQLERR);

        return FAIL;
    }

    if(iCnt == 1)
    {
        strcpy(ptApp->szNextTransCode, DOWN_TMS_CODE);

        return FAIL;   
    }    

    return SUCC;
}