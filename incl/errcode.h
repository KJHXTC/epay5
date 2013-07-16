#ifndef  __ERRORCODE__
#define __ERRORCODE__

#define	TRANS_SUCC              "00"    /* ���׳ɹ� */
#define ERR_INVALID_MERCHANT    "03"    /* ��Ч�̻� */
#define ERR_DECLINE             "05"    /* ����ж� */
#define ERR_INVALID_TRANS       "12"    /* ��Ч���� */
#define ERR_INVALID_AMOUNT      "13"    /* ��Ч��� */
#define	ERR_INVALID_CARD        "14"    /* ��Ч���� */
#define ERR_INVALID_BANK        "15"    /* �޴˷����� */
#define ERR_UNACCEPTABLE_FEE    "23"    /* �����Ѵ��� */
#define ERR_TRANS_NOT_EXIST     "25"    /* ��ԭ���� */
#define ERR_DATA_FORMAT         "30"    /* ���ݸ�ʽ�� */
#define ERR_NOT_SUPPORTED       "40"    /* ���ܲ�֧�� */
#define ERR_NOT_PERMIT_HOLDER   "57"    /* ������ֿ��� */
#define ERR_NOT_PERMIT_TERM     "58"    /* �������ն� */
#define ERR_EXCEED_TOTAL        "61"    /* ���� */
#define ERR_ORIG_AMOUNT         "64"    /* ԭ���� */
#define ERR_EXCEED_TIMES        "65"    /* ��ȡ����� */
#define ERR_TIMEOUT             "68"    /* ���׳�ʱ */
#define ERR_CUT_OFF             "90"    /* ���մ����� */
#define ERR_ROUTE               "92"    /* ������� */
#define ERR_DUPLICATE           "94"    /* �ظ����� */
#define ERR_RECONCILE           "95"    /* ���˲�ƽ */
#define ERR_SYSTEM_ERROR        "96"    /* ϵͳ���� */
#define ERR_INVALID_TERM        "97"    /* ��Ч�ն� */
#define ERR_COMMU               "98"    /* ���������� */
#define ERR_PIN_BLOCK           "99"    /* PIN��ʽ�� */
#define ERR_MAC                 "A0"    /* MACУ��� */

#define ERR_HAS_PAY             "A2"    /* �����ѽ��� */
#define ERR_AUTHCODE            "A9"    /* ���ĸ�ʽ�� */
#define ERR_EXCEED_SINGLE       "AA"    /* ���ʽ��� */

#define ERR_PSAM_MODULE         "P1"    /* ��Ч��ȫģ�� */
#define ERR_TERM_MODULE         "P2"    /* ��Ч�ն�ģ�� */
#define ERR_INVALID_MENU        "P3"    /* �˵����ƴ� */
#define ERR_INVALID_PAYLIST     "P4"    /* �˵����ƴ� */
#define ERR_NOT_PAYLIST         "P5"    /* ���˵����� */
#define ERR_DATA_TOO_LONG       "P6"    /* ���ݹ��� */
#define ERR_INVALID_APP         "P7"    /* δ����Ӧ�� */
#define ERR_TERM_STATUS         "P8"    /* �ն�δ��ͨ */
#define ERR_NOT_PAY             "P9"    /* δǷ�� */

#define ERR_UNIT_CODE           "Q0"    /* �շѻ�����ȫ */
#define ERR_NOT_RET_MSG         "Q1"    /* ���ز����� */
#define ERR_DOWN_FINISH         "Q2"    /* ��������� */
#define ERR_TRANS_DEFINE        "Q3"    /* ���׶���� */
#define ERR_TERM_NOT_REGISTER   "Q4"    /* �ն�δ�Ǽ� */
#define ERR_INVALID_FIRST_PAGE  "Q5"    /* ��Ч��ҳ��Ϣ */
#define ERR_OPER_NOT_LOGIN      "Q7"    /* ��Աδǩ�� */
#define ERR_TERM_NOT_LOGIN      "Q8"    /* �ն�δǩ�� */
#define ERR_RESP_MAC            "Q9"    /* ��ӦMAC�� */

#define ERR_IN_CARD_NOT_REGISTER    "R0"    /* δ��ת�뿨 */  
#define ERR_VOID_VOID               "R1"    /* ԭ���ײ��ܳ��� */
#define ERR_SYSTEM_PAUSE            "R2"    /* ϵͳ��ͣ */
#define ERR_INVALID_OPER            "R3"    /* �Ƿ���Ա */
#define ERR_OPERPWD_ERROR           "R4"    /* ����Ա����� */
#define ERR_CREDIT_CARD             "R5"    /* ��֧�����ÿ� */
#define ERR_MERCHANT_CODE           "R6"    /* �̻����벻ȫ */
#define ERR_CARD_TYPE               "R7"    /* δ��ʶ�� */
#define ERR_INVALID_PHONE           "R8"    /* �ն˷Ƿ����� */
#define ERR_NOT_KEY                 "R9"    /* ���ն���Կ */

#define ERR_CARD_HAS_REGISTER       "S0"    /* �ն��Ѱ󶨿� */
#define ERR_NO_TRACE                "S1"    /* �޽�����ϸ */
#define ERR_OUT_CARD_NOT_REGISTER   "S2"    /* δ��ת���� */
#define ERR_HAS_LOGIN               "S3"    /* �ն���ǩ�� */
#define ERR_NOT_STOP                "S4"    /* ��ֹ���� */
#define ERR_ONE_CARD                "S5"    /* ͬ������ת�� */
#define ERR_AWARDED                 "S6"    /* �Ѷҽ� */
#define ERR_AWARD_VOID              "S7"    /* ��ȡ���ҽ� */
#define ERR_TRAN_IN_OTHER           "S8"    /* ת�뿨��� */
#define ERR_AWARD_EXP               "S9"    /* ���ҽ��� */
#define ERR_NAME                    "SA"    /* �������� */
#define ERR_ID                      "SB"    /* ֤������ */
#define ERR_YIDI_CARD               "SC"    /* ����˻� */
#define ERR_SERVICE_SYSTEM          "SD"    /* ����ϵͳ���� */
#define ERR_SERVICE_FAIL            "SE"    /* ���񷽽���ʧ�� */
#define ERR_USER_CODE               "SF"    /* �޴��û��� */
#define ERR_NO_CUSTOMER             "SG"    /* �޴��տ��� */
#define	ERR_SELF_CARD               "SH"    /* �ǰ󶨿� */
#define	ERR_NO_NET_OPER             "SI"    /* ������Ϣ��ȫ */
#define ERR_EXIST_CUSTOMER          "SJ"    /* �ֻ��˲����� */
/* SK->SZ  ������׼ʹ�� */

#define ERR_NO_FEE_RECORD           "T0"    /* ���ʱ�ȫ */
#define ERR_SHOP_STATUS             "T3"    /* �̻�״̬�Ƿ� */
/* TA->TZ  ������׼ʹ�� */

#define ERR_JIAOFEI_CARD_NOT_REGISTER   "E0"    /* δ�󶨽ɷѿ� */
#define ERR_AMOUNT_50                   "E1"    /* ��50������ */
#define ERR_OTHER_BANK                  "E2"    /* ��֧�����п� */
#define ERR_OUT_YIDI                    "E3"    /* ת������� */
#define ERR_NOT_HOST_KEY                "E4"    /* ������ǩ�� */
#define ERR_CHK_VAL                     "E5"    /* ������Կ�� */
#define ERR_DEBIT_CARD                  "E6"    /* ת���ǿ� */
#define ERR_NEED_INIT_KEY               "E7"    /* ��ʼ����Կ */
#define ERR_REG_CARD_NOT_APPROVE        "E8"    /* �󶨿�δ�� */
#define ERR_ZNJ                         "E9"    /* ���ɽ𲻷� */
#define ERR_MAC_NOT_LOGIN               "EA"    /* MACУ��� */
#define ERR_SEL_PURCHASE                "EB"    /* ���п����� */
#define ERR_IN_OTHER_BANK               "EC"    /* ���ù��п� */
#define ERR_DUPLICATE_PSAM_NO           "ED"    /* PSAM�����ظ� */
#define ERR_NO_OTHER_BANK               "EE"    /* ��������Ϣ */
#define ERR_NEED_DOWN_APP               "EF"    /* ������Ӧ�� */
#define ERR_BANK_CODE                   "EG"    /* �����к� */
#define ERR_TRAN_OUT_OTHER_STOP         "EI"    /* �ǽ���ʱ�� */
/* EH->EZ  ������׼ʹ�� */

#define ERR_LAST_RECORD         "F0"    /* ĩ����¼ */
#define ERR_IN_SELF_BANK        "F1"    /* �տ�����п� */
#define ERR_USER_CODE2          "F2"    /* �޴��û��� */
#define ERR_DUPLICATE_TERM      "F3"    /* �ն˺��ظ� */
#define ERR_CREDIT_LIMIT        "F4"    /* ���ǿ����׳��޴� */
#define PSAMNO_INVALID          "F5"    /* PSAM�����ѵǼ� */
#define SHOP_TERM_INVALID       "F6"    /* �̻��ն˺��ѵǼ� */
#define ERR_NOT_PERMIT_CARD     "F7"    /* ��֧�ֿ��� */

#define ERR_EPOS_OPERPWD_NOCHG  "82"    /* ��ʼ����δ�޸� */
#define ERR_EPOS_OPERPWD_ERROR  "83"    /* ���볤�ȷǷ� */
#define ERR_EPOS_OPT_INVALID    "84"    /* ��Ȩ����Ա�� */
#define ERR_DEL_ADMIN_ERROR     "85"    /* ����Ա����ɾ�� */
#define ERR_OPER_DUPLICATE      "86"    /* ����Ա���ظ� */

#define ERR_ZJYW_NO_OTHER_BANK  "79999"
#define ERR_ZJYW_BANK_CODE      "79997"

/* ����궨�� */
#define ERR_UNDEF_FEECALCTYPE           "U1"        /* �����Ѽ��㷽ʽδ���� */
#define ERR_REFUND_ERRDATE              "U2"        /* ���������˻� */
#define ERR_REFUNE_ERRAMT               "U3"        /* �˻����������ԭ���׽�� */
/*
#define ERR_SHOP_STATUS                 "U4"        ��Ч�̻�״̬
*/
#define ERR_OLDTRANS_CARDERR            "U5"        /* ԭ������ˢ����Ϣ���� */
#define ERR_OLDTRANS_AUTHERR            "U6"        /* ԭ��Ȩ�������벻�� */
#define ERR_OLDTRANS_FAIL               "U7"        /* ԭ���ײ��ɹ� */
#define ERR_OLDTRANS_CANCEL             "U8"        /* ԭ�����ѳ��� */
#define ERR_OLDTRANS_RECOVER            "U9"        /* ԭ�����ѳ��� */
#define ERR_OLDTRANS_SETTLE             "UA"        /* ԭ�����ѽ��� */

#define ERR_UNDEF_DOWNTYPE              "UB"        /* ���ط�ʽδ���� */

#endif
