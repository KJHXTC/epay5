/*******************************************************************************
** Copyright(C)2012 - 2015���������豸���޹�˾
** ��Ҫ���ݣ��������ͺ궨��
** �� �� �ˣ�Robin
** �������ڣ�2012/12/17
**
** $Revision: 1.8 $
** $Log: transtype.h,v $
** Revision 1.8  2013/03/29 02:51:20  fengw
**
** 1������EMV����ѯ��EMV���ѳ����������ͺ궨�塣
**
** Revision 1.7  2013/03/11 07:07:41  fengw
**
** 1������EMV��ؽ������ͺ궨�塣
**
** Revision 1.6  2012/12/19 08:41:59  chenrb
** ���ӽɷ��ཻ�׶���
**
** Revision 1.5  2012/12/17 05:30:28  chenrb
** �����ط����׺궨��
**
** Revision 1.4  2012/12/17 05:04:49  chenrb
** *** empty log message ***
**
*******************************************************************************/
#ifndef _TRANSTYPE_H_
#define _TRANSTYPE_H_

//�����ཻ�ף���1��99
#define ECHO_TEST           1
#define DOWN_PAYLIST        2
#define DOWN_ALL_OPERATION  3
#define AUTO_VOID           4
#define LOGIN               5
#define SEND_INFO           6
#define REGISTER            7
#define TERM_REGISTER       8
#define SEND_TRACE          10
#define SEND_ERR_LOG        11

#define DOWN_TMS            12
#define DOWN_TMS_END        13

#define QUERY_CUSTOMER      15
#define ADD_CUSTOMER        16
#define DEL_CUSTOMER        17
#define REPRINT             18
#define PPP_LOGIN           19
#define OPER_LOGIN          20
#define SETTLE              21    
#define BATCHUP             22
#define SETTLE2             23
#define LOGOUT              24
#define OPER_PWD            25
#define ADD_OPER            26
#define DEL_OPER            27
#define PWD_INIT            28
#define HOST_SETTLE         29
#define DOWN_PARAMETER      30

//��Ӧ������(�ն˷���&���ķ�����)
#define DOWN_ALL_FUNCTION    31
#define DOWN_ALL_MENU        32
#define DOWN_ALL_PRINT       33
#define DOWN_ALL_TERM        34
#define DOWN_ALL_PSAM        35
#define DOWN_ALL_ERROR       36
#define UNREGISTER_CARD      38
#define REGISTER_CARD        39

//���ķ���ĵ�������
#define CENDOWN_FIRST_PAGE      40
#define CENDOWN_FUNCTION_INFO   41
#define CENDOWN_OPERATION_INFO  42
#define CENDOWN_PRINT_INFO      43
#define CENDOWN_TERM_PARA       44
#define CENDOWN_PSAM_PARA       45
#define CENDOWN_ERROR           46
#define CENDOWN_MSG             47
#define CENDOWN_PAYLIST         48
#define CENDOWN_MENU            49

//�ն˷��������
#define DOWN_FIRST_PAGE         50
#define DOWN_FUNCTION_INFO      51
#define DOWN_OPERATION_INFO     52
#define DOWN_PRINT_INFO         53
#define DOWN_TERM_PARA          54
#define DOWN_PSAM_PARA          55
#define DOWN_ERROR              56
#define DOWN_MSG                57
#define DOWN_STATIC_MENU        58    
#define DOWN_MENU               59

//��̬�˵����̿���
#define DYNAMIC_CONTR           60
//��������
#define TEST_DIG_CHK_INPUT      61
#define TEST_DIG_CHK_TWO_INPUT  62
#define TEST_DISP_OPER_INFO     63
#define TEST_PAYLIST            64
#define TEST_OTHER              65

#define GET_DYMENU_66        66
#define GET_DYMENU_67        67
#define GET_DYMENU_68        68
#define GET_DYMENU_69        69

//���׼�⵽���ն��Զ����������
#define AUTODOWN_ALL_OPERATION      70
#define AUTODOWN_FUNCTION_INFO      71
#define AUTODOWN_OPERATION_INFO     72
#define AUTODOWN_PRINT_INFO         73
#define AUTODOWN_TERM_PARA          74
#define AUTODOWN_PSAM_PARA          75
#define AUTODOWN_ERROR              76
#define AUTODOWN_MENU               77
#define AUTODOWN_PAYLIST            78
#define AUTODOWN_MSG                80

//���ķ������Ӧ������-���ز�����ʾ
#define CENDOWN_ALL_OPERATION       79

//��������
#define TEST_NORMAL_INPUT       81
#define TEST_TWO_INPUT          82
#define TEST_NORMAL_DISP_INPUT  83
#define TEST_TWO_DISP_INPUT     84
#define TEST_PRINT              85
#define TEST_CLEAR_MENU         86
#define TEST_CLEAR_AUTOVOID     87
#define TEST_SEND_CARDNO        88
#define TEST_INQ                89
#define TEST_PAY                300    

/* EMV */
#define DOWN_EMV_PARA           90              /* EMV�������� */
#define DOWN_EMV_KEY            91              /* EMV��Կ���� */


//���Ღ��
/*
#define DIAL_TELE0          90
#define DIAL_TELE1          91
#define DIAL_TELE2          92
#define DIAL_TELE3          93
#define DIAL_TELE4          94
#define DIAL_TELE5          95
*/
//��ֹ�ɷ�
#define STOP_PAY            99


//�����ཻ�����100�Ժ�ʼ���壬�Ҳ������ظ�
#define PURCHASE                101                     /* ���� */
#define PUR_CANCEL              102                     /* ���ѳ��� */
#define REFUND                  103                     /* �˻� */
#define PUR_NOTICE              104                     /* ����֪ͨ */
#define PRE_AUTH                105                     /* Ԥ��Ȩ */
#define PRE_CANCEL              106                     /* Ԥ��Ȩ���� */
#define CONFIRM                 107                     /* Ԥ��Ȩ��� */
#define CON_CANCEL              108                     /* Ԥ��Ȩ��ɳ��� */
#define TRANS                   109                     /* ����ת�� */
#define TRAN_CANCEL             110                     /* ת�˳��� */
#define TRAN_OUT                111                     /* ת��ת�� */
#define TRAN_OUT_CANCEL         112                     /* ת������ */
#define TRAN_IN                 113                     /* ת��ת�� */
#define TRAN_IN_CANCEL          114                     /* ת�볷�� */
#define INQUERY                 115                     /* ���п�����ѯ */
#define TRANS_QUERY             119                     /* ת��Ԥ��ѯ */
#define TRAN_IN_QUERY           120                     /* ת��ת��Ԥ��ѯ */
#define TRAN_OUT_QUERY          121                     /* ת��ת��Ԥ��ѯ */
#define PAY_CREDIT_QUERY        122                     /* ���ÿ�����Ԥ��ѯ */
#define PAY_CREDIT              123                     /* ���ÿ����� */
#define TRAN_OTHER              124                     /* ���л�� */
#define TRAN_OTHER_QUERY        125                     /* ���л��Ԥ��ѯ */

#define EMV_PUR_TRANS           151                     /* EMV������������ */
#define EMV_PUR_ONLINE          152                     /* EMV�����������ݴ��� */
#define EMV_INQUERY             153                     /* EMV����ѯ */
#define EMV_PUR_CANCEL          154                     /* EMV���ѳ��� */

//Ԥ���ѽɷѽ���
#define CHINATELECOM_PREPAY	    170                     /* ���ų�ֵ */
#define CHINATELECOM_QUERY	    171                     /* ���Ų���� */
#define CHINAUNICOM_PREPAY	    172                     /* ��ͨ��ֵ */
#define CHINAUNICOM_QUERY	    173                     /* ��ͨ����� */
#define CHINAMOBILE_PREPAY	    174                     /* �ƶ���ֵ */
#define CHINAMOBILE_QUERY	    175                     /* �ƶ������ */
#define CHINATELECOM_CDMA_PREPAY    176                 /* ���ų�ֵ-CDMA */
#define CHINATELECOM_CDMA_QUERY     177                 /* ���Ų����-CDMA */
#define NETCOM_PREPAY           178                     /* ��ͨ��ֵ */
#define NETCOM_QUERY            179                     /* ��ͨ����� */

//�󸶷ѽɷѽ���
#define	CHINAUNICOM_INQ		    201                     /* ��ͨ��Ӧ�ɷ� */
#define	CHINAUNICOM_PAY		    202                     /* ��ͨ�ɷ� */
#define	CHINAMOBILE_INQ		    203                     /* �ƶ���Ӧ�ɷ� */
#define	CHINAMOBILE_PAY		    204                     /* �ƶ��ɷ� */
#define	CHINAMOBILE_PIN		    205                     /* �ƶ����� */
#define	CHINATELECOM_INQ	    206                     /* ���Ų�Ӧ�ɷ� */
#define	CHINATELECOM_PAY	    207                     /* ���Žɷ� */
#define	ELECTRICITY_INQ		    208                     /* ��Ӧ�ɵ�� */
#define	ELECTRICITY_PAY		    209                     /* �ɵ�� */
#define	GAS_INQ			        210                     /* ��Ӧ��ú���� */
#define	GAS_PAY			        211                     /* ú���ɷ� */
#define TRAFFIC_AMERCE_INQ	    212                     /* �ֳ���û��ѯ */
#define TRAFFIC_AMERCE_PAY	    213                     /* �ֳ���û */
#define TRAFFIC_AMERCE_NO_INQ	214                     /* ���ֳ���û��ѯ */
#define TRAFFIC_AMERCE_NO_PAY	215                     /* ���ֳ���û */
#define WATER_INQ               216                     /* ˮ��Ӧ�ɷѲ�ѯ */
#define WATER_PAY               217                     /* ˮ�ѽɷ� */
#define NETCOM_INQ              218                     /* ��ͨӦ�ɷѲ�ѯ */
#define NETCOM_PAY              219                     /* ��ͨ�ɷ� */
#define CHINATELECOM_CDMA_INQ   220                     /* ����CDMAӦ�ɷѲ�ѯ */
#define CHINATELECOM_CDMA_PAY   221                     /* ����CDMA�ɷ� */

//������֧��
#define PLANE_TICKET_PAYLIST    250                     /* ��Ʊ֧�� */

//��ˮ��ϸ��ѯ
#define QUERY_DETAIL_SELF       310                     /* ��ѯ���ն���ˮ */
#define QUERY_DETAIL_OTHER      311                     /* ��ѯ�����ն���ˮ */
#define QUERY_TOTAL             312                     /* ���ܲ�ѯ */
#define QUERY_LAST_DETAIL       313                     /* ��ѯĩ�ʽ��� */
#define QUERY_TODAY_DETAIL      314                     /* ��ѯ������ˮ */

#define RESEND                  500                     /* �ط� */

//���׼�⵽���ն��Զ���������ؽ��׽��״���
#define LOGIN_CODE                      "00000005"
#define DOWN_TMS_CODE                   "00000012"
#define DOWN_TMS_END_CODE               "00000013"
#define AUTODOWN_ALL_OPERATION_CODE     "00000070"
#define AUTODOWN_FUNCTION_INFO_CODE     "00000071"
#define AUTODOWN_OPERATION_INFO_CODE    "00000072"
#define AUTODOWN_PRINT_INFO_CODE        "00000073"
#define AUTODOWN_TERM_PARA_CODE         "00000074"
#define AUTODOWN_PSAM_PARA_CODE         "00000075"
#define AUTODOWN_ERROR_CODE             "00000076"
#define AUTODOWN_MENU_CODE              "00000077"
#define AUTODOWN_PAYLIST_CODE           "00000078"
#define AUTODOWN_MSG_CODE               "00000080"

#define STOP_PAY_CODE                   "00000099"

#endif
