/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨web�����������ģ�� ������ҳ��Ϣ
** �� �� �ˣ����
** �������ڣ�2012-12-18
**
** $Revision: 1.5 $
** $Log: DownFirstPage.ec,v $
** Revision 1.5  2013/06/18 02:33:26  fengw
**
** 1������������ҳ��Ϣ���δ��ֵBUG��
**
** Revision 1.4  2012/12/25 07:02:05  fengw
**
** 1��������������������UPDATE��䡣
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
    int     iFirstPage;                 /* ��ҳ��Ϣ��� */
    char    szDeptDetail[70+1];         /* �����㼶��Ϣ */
    char    szShopNo[15+1];             /* �̻��� */
    char    szPosNo[15+1];              /* �ն˺� */
    int     iAppType;                   /* Ӧ������ */
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ�������ҳ��Ϣ
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
int DownFirstPage(T_App *ptApp)
{
    memset(szShopNo, 0, sizeof(szShopNo));
    memset(szPosNo, 0, sizeof(szPosNo));
    memset(szDeptDetail, 0, sizeof(szDeptDetail));

    iFirstPage = atoi(gszBitmap);

    BeginTran();

	switch(giDownType)
	{
        /* ����ָ���ն� */
        case DOWN_SPECIFY_POS:
            strcpy(szShopNo, ptApp->szShopNo);
            strcpy(szPosNo, ptApp->szPosNo);

            EXEC SQL
                UPDATE terminal SET first_page = :iFirstPage
                WHERE shop_no = :szShopNo AND pos_no = :szPosNo;
            break;
        /* ����ָ���̻��ն� */
        case DOWN_SPECIFY_SHOP:
            strcpy(szShopNo, ptApp->szShopNo);

            EXEC SQL
                UPDATE terminal SET first_page = :iFirstPage
                WHERE shop_no = :szShopNo;
            break;
        /* ���������ն� */
        case DOWN_ALL:
            EXEC SQL
                UPDATE terminal SET first_page = :iFirstPage;
            break;
        /* ����ָ��Ӧ�������ն� */
        case DOWN_SPECIFY_TYPE:
            iAppType = atoi(ptApp->szShopNo);

            EXEC SQL
                UPDATE terminal SET first_page = :iFirstPage
                WHERE app_type = :iAppType;
            break;
        /* ����ָ���������ն� */
        case DOWN_SPECIFY_DEPT:
            strcpy(szDeptDetail, ptApp->szDeptDetail);

            EXEC SQL
                UPDATE terminal SET first_page = :iFirstPage
                WHERE EXISTS
                (SELECT 1 FROM terminal t, shop s
                WHERE t.shop_no = s.shop_no AND
                INSTR(s.dept_detail, :szDeptDetail) = 1);
            break;
        default:
            strcpy(ptApp->szRetCode, ERR_UNDEF_DOWNTYPE);

            WriteLog(ERROR, "��������:[%d]δ����!", giDownType);

            return FAIL;
    }

    if(SQLCODE)
	{
		RollbackTran();

		strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

        WriteLog(ERROR, "�����ն˱� �̻�[%s] �ն�[%s] Ӧ������[%d] ������Ϣ[%s] first_page��־ʧ��!SQLCODE=%d SQLERR=%s",
                        szShopNo, szPosNo, iAppType, szDeptDetail, SQLCODE, SQLERR);

		return FAIL;
	}

    CommitTran();

    return SUCC;
}
