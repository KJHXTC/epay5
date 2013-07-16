/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨web�����������ģ�� ���¶���
** �� �� �ˣ����
** �������ڣ�2012-12-18
**
** $Revision: 1.6 $
** $Log: DownMsg.ec,v $
** Revision 1.6  2013/03/11 05:41:17  fengw
**
** 1���޸�SQL�ж������������������ʱ����
**
** Revision 1.5  2012/12/27 02:32:15  fengw
**
** 1���޸ĸ���SQL����ѯ������
**
** Revision 1.4  2012/12/25 07:02:05  fengw
**
** 1��������������������UPDATE��䡣
**
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

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
    char    szMsgNo[7+1];               /* ���ű�� */
    char    szDeptDetail[70+1];         /* �����㼶��Ϣ */
    char    szShopNo[15+1];             /* �̻��� */
    char    szPosNo[15+1];              /* �ն˺� */
    int     iAppType;                   /* Ӧ������ */
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ����¶���
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
int DownMsg(T_App *ptApp)
{
    int     i;
    int     iMsgCount;                  /* ���ż�¼�� */

    memset(szShopNo, 0, sizeof(szShopNo));
    memset(szPosNo, 0, sizeof(szPosNo));
    memset(szDeptDetail, 0, sizeof(szDeptDetail));

    iMsgCount = gszBitmap[0] - '0';

    BeginTran();

    for(i=0;i<iMsgCount;i++)
    {
        memset(szMsgNo, 0, sizeof(szMsgNo));

        memcpy(szMsgNo, gszBitmap+1+6*i, 6);
        szMsgNo[6] = '.';

        switch(giDownType)
        {
            /* ����ָ���ն� */
            case DOWN_SPECIFY_POS:
                strcpy(szShopNo, ptApp->szShopNo);
                strcpy(szPosNo, ptApp->szPosNo);

                EXEC SQL
                    UPDATE terminal SET msg_recnum = NVL(msg_recnum, 0)+1,
                    msg_recno = CONCAT(msg_recno, :szMsgNo)
                    WHERE shop_no = :szShopNo AND pos_no = :szPosNo AND
                    (msg_recno IS NULL OR INSTR(msg_recno, :szMsgNo) = 0) AND
                    LENGTH(NVL(msg_recno, 0)) < 250;
                break;
            /* ����ָ���̻��ն� */
            case DOWN_SPECIFY_SHOP:
                strcpy(szShopNo, ptApp->szShopNo);

                EXEC SQL
                    UPDATE terminal SET msg_recnum = NVL(msg_recnum, 0)+1,
                    msg_recno = CONCAT(msg_recno, :szMsgNo)
                    WHERE shop_no = :szShopNo AND
                    (msg_recno IS NULL OR INSTR(msg_recno, :szMsgNo) = 0) AND
                    LENGTH(NVL(msg_recno, 0)) < 250;
                break;
            /* ���������ն� */
            case DOWN_ALL:
                EXEC SQL
                    UPDATE terminal SET msg_recnum = NVL(msg_recnum, 0)+1,
                    msg_recno = CONCAT(msg_recno, :szMsgNo)
                    WHERE (msg_recno IS NULL OR INSTR(msg_recno, :szMsgNo) = 0) AND
                    LENGTH(NVL(msg_recno, 0)) < 250;
                break;
            /* ����ָ��Ӧ�������ն� */
            case DOWN_SPECIFY_TYPE:
                iAppType = atoi(ptApp->szShopNo);

                EXEC SQL
                    UPDATE terminal SET msg_recnum = NVL(msg_recnum, 0)+1,
                    msg_recno = CONCAT(msg_recno, :szMsgNo)
                    WHERE app_type = :iAppType AND
                    (msg_recno IS NULL OR INSTR(msg_recno, :szMsgNo) = 0) AND
                    LENGTH(NVL(msg_recno, 0)) < 250;
                break;
            /* ����ָ���������ն� */
            case DOWN_SPECIFY_DEPT:
                strcpy(szDeptDetail, ptApp->szDeptDetail);

                EXEC SQL
                    UPDATE terminal SET msg_recnum = NVL(msg_recnum, 0)+1, msg_recno = CONCAT(msg_recno, :szMsgNo)
                    WHERE EXISTS
                    (SELECT 1 FROM terminal t, shop s
                    WHERE t.shop_no = s.shop_no AND
                    INSTR(s.dept_detail, :szDeptDetail) = 1 AND
                    (t.msg_recno IS NULL OR INSTR(t.msg_recno, :szMsgNo) = 0));
                break;
            default:
                strcpy(ptApp->szRetCode, ERR_UNDEF_DOWNTYPE);

                WriteLog(ERROR, "��������:[%d]δ����!", giDownType);

                return FAIL;
        }

        if(SQLCODE && SQLCODE != SQL_NO_RECORD)
        {
            RollbackTran();

            strcpy(ptApp->szRetCode, ERR_SYSTEM_ERROR);

            WriteLog(ERROR, "�����ն˱� �̻�[%s] �ն�[%s] Ӧ������[%d] ������Ϣ[%s] msg_recnum��־ʧ��!SQLCODE=%d SQLERR=%s",
                     szShopNo, szPosNo, iAppType, szDeptDetail, SQLCODE, SQLERR);

            return FAIL;
        }
    }

    CommitTran();

    return SUCC;
}
