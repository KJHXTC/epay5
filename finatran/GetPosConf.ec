/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ�� ��ȡ�ն˲�������
** �� �� �ˣ����
** �������ڣ�2012-11-08
**
** $Revision: 1.2 $
** $Log: GetPosConf.ec,v $
** Revision 1.2  2012/12/04 01:24:28  fengw
**
** 1���滻ErrorLogΪWriteLog��
**
** Revision 1.1  2012/11/23 09:09:16  fengw
**
** ���ڽ��״���ģ���ʼ�汾
**
** Revision 1.1  2012/11/21 07:20:46  fengw
**
** ���ڽ��״���ģ���ʼ�汾
**
*******************************************************************/

#define _EXTERN_

#include "finatran.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL END DECLARE SECTION;

/****************************************************************
** ��    �ܣ���ȡ�ն˲�������
** ���������
**        iTransType           ��������
**        szShopNo             �̻���
**        szPosNo              �ն˺�
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
int GetPosConf(int iTransType, char *szShopNo, char *szPosNo, T_EpayConf *ptEpayConf)
{
    EXEC SQL BEGIN DECLARE SECTION;
        int     iHostType;                          /* �������� */
        char    szHostShopNo[15+1];                 /* �̻��� */
        char    szHostPosNo[15+1];                  /* �ն˺� */
        double  dAmountSingle;                      /* �����޶� */
        double  dAmountSum;                         /* �����ۼ��޶� */
        int     iMaxCount;                          /* ��������ױ��� */
        double  dCreditAmountSingle;                /* ���ÿ������޶� */
        double  dCreditAmountSum;                   /* ���ÿ������ۼ��޶� */
        int     iCreditMaxCount;                    /* ���ÿ���������ױ��� */
        char    szCardTypeOut[9+1];                 /* ת������ɿ����� */
        char    szCardTypeIn[9+1];                  /* ת�뿨��ɿ����� */
        int     iFeeCalcType;                       /* �����Ѽ��㷽ʽ */
    EXEC SQL END DECLARE SECTION;

    memset(szHostShopNo, 0, sizeof(szHostShopNo));
    memset(szHostPosNo, 0, sizeof(szHostPosNo));
    memset(szCardTypeOut, 0, sizeof(szCardTypeOut));
    memset(szCardTypeIn, 0, sizeof(szCardTypeIn));

    iHostType = iTransType;
    strcpy(szHostShopNo, szShopNo);
    strcpy(szHostPosNo, szPosNo);

    EXEC SQL
        SELECT amount_single, amount_sum, max_count,
               credit_amount_single, credit_amount_sum, credit_max_count,
               card_type_out, card_type_in, fee_calc_type
        INTO :dAmountSingle, :dAmountSum, :iMaxCount,
             :dCreditAmountSingle, :dCreditAmountSum, :iCreditMaxCount,
             :szCardTypeOut, :szCardTypeIn, :iFeeCalcType
        FROM pos_conf
        WHERE shop_no = :szHostShopNo AND pos_no = :szHostPosNo AND trans_type = :iHostType;
    if(SQLCODE == SQL_NO_RECORD)
    {
        return CONF_NOT_FOUND;
    }
    else if(SQLCODE)
    {
        WriteLog(ERROR, "�̻�[%s] �ն�[%s] ��������[%d] ��ѯ����ʧ��!SQLCODE=%d SQLERR=%s",
                 szHostShopNo, szHostPosNo, iHostType, SQLCODE, SQLERR);

        return CONF_GET_FAIL;
    }

    /* ������ֵ */
    ptEpayConf->dAmountSingle = dAmountSingle;
    ptEpayConf->dAmountSum = dAmountSum;
    ptEpayConf->iMaxCount = iMaxCount;
    ptEpayConf->dCreditAmountSingle = dCreditAmountSingle;
    ptEpayConf->dCreditAmountSum = dCreditAmountSum;
    ptEpayConf->iCreditMaxCount = iCreditMaxCount;
    memcpy(ptEpayConf->szCardTypeOut, szCardTypeOut, strlen(szCardTypeOut));
    memcpy(ptEpayConf->szCardTypeIn, szCardTypeIn, strlen(szCardTypeIn));
    ptEpayConf->iFeeCalcType = iFeeCalcType;

    return CONF_GET_SUCC;
}
