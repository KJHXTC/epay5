/******************************************************************
** Copyright(C)2012 - 2015���������豸���޹�˾
** ��Ҫ���ݣ����屾ϵͳ�Զ���ĺ�
** �� �� �ˣ�������
** �������ڣ�2012/11/8
** $Revision: 1.13 $
** $Log: user.h,v $
** Revision 1.13  2013/06/14 02:34:48  fengw
**
** 1�������ն�����Կ����TERM_KEY�궨�塣
** 2������8583����62��FIELD62�궨�塣
**
** Revision 1.12  2013/03/11 07:07:21  fengw
**
** 1�������Զ���ָ����غ궨�塣
**
** Revision 1.11  2012/12/21 05:43:23  chenrb
** *** empty log message ***
**
** Revision 1.10  2012/12/18 10:16:39  wukj
** *** empty log message ***
**
** Revision 1.9  2012/12/18 07:16:26  wukj
** *** empty log message ***
**
** Revision 1.8  2012/12/11 06:38:05  chenrb
** �������з��궨��
**
** Revision 1.7  2012/11/29 07:10:06  zhangwm
**
** �����Ƿ��ӡ��־�ж�
**
** Revision 1.6  2012/11/27 06:02:55  chenrb
** ����AscBcd��ת��sock���ͺ궨��
**
** Revision 1.5  2012/11/27 05:11:45  epay5
** *** empty log message ***
**
** Revision 1.4  2012/11/27 03:40:15  chenrb
** ɾ��һЩδ�õĺ궨��
**
** Revision 1.3  2012/11/27 03:35:19  zhangwm
**
** ����־��صĹ��ú궨����õ�user.h��
**
** Revision 1.2  2012/11/27 02:34:00  epay5
** modified by gaomx �޸�ͷ�ļ�
**
** Revision 1.1  2012/11/22 01:42:35  epay5
** add by gaomx
**
*******************************************************************/
/* ������������� */
#define MAX_TRANS_DATA_INDEX 512

/* ������־�ķּ����� */
#define DEBUG_TLOG    0x01
#define DEBUG_HLOG    0x02
#define DEBUG_MLOG    0x04
#define DEBUG_ALOG    0x08

/*���ݿⶨ��*/
#define DB_ORACLE    1

/*�Ƿ�����������ǩ��������������ǩ��������������ǩ��*/
#define LOGIN_TO_HOST    1

/*�Ƿ�����0A���з�������ն���ʾ�����Ϣ�����п�ʼ��ʾ��Ϊ��ʹ���ն���ʾ�ﵽ������ʾЧ�����壻���򲻶���*/
#define ADD_0A_LINE    1

/*����Կ���ȶ���Ϊ˫���������򵥱�����ֻ�����������*/
#define MKEY_TRIDES    1

/* ����󶨿����׵����� 0-���� 1-�տ� 2-�ɷ�*/
#define TRAN_TYPE_OUT       '0'
#define TRAN_TYPE_IN        '1'
#define TRAN_TYPE_JIAOFEI   '2'

/*������ 0-�տ� 1-��*/
#define NORMAL_CARD     0
#define GOLD_CARD       1

/*���� 0-��ǿ� 1-���ǿ� 2-���⿨ 3-׼���ǿ�*/
#define DEBIT_CARD      '0'
#define CREDIT_CARD     '1'
#define ANY_CARD        '2'
#define PRECREDIT_CARD  '3'

/* ������ 1-���п� 2�����б��ؿ� 3-������ؿ� */
#define OTHER_BANK                  1
#define LOCAL_BANK_LOCAL_CITY       2
#define LOCAL_BANK_OTHER_CITY       3

/*�̻��������� 0-�������� 1-VIP����*/
#define NORMAL_RATE     0
#define VIP_RATE        1

/* ��Կ���Ͷ��� */
#define    TERM_KEY       0
#define    PIN_KEY        1
#define    MAC_KEY        2
#define    MAG_KEY        3

/* �Ƿ�ĺ궨�� */
#define YES   1
#define NO    0    

/*���ܻ��������ͺ궨��*/
#define DECRYPT_PIN     0
#define CALC_MAC        1
#define GET_WORK_KEY    3
#define CHANGE_PIN      4
#define DECRYPT_TRACK   5
#define GET_MASTER_KEY  6
#define VERIFY_PIN      7
#define CALC_CHKVAL     8
#define CHANGE_KEY      9
#define CHANGE_PIN_PIK2TMK    10

/* MAC�㷨��ʶ */
#define X99_CALC_MAC    1
#define XOR_CALC_MAC    2
#define X919_CALC_MAC   3

/*��·����*/
#define LINK_CLIENT     1
#define LINK_SERVER     2

/*������ʶ�궨��*/
#define UNIONPAY_PPP    0    /*��������֧��ƽ̨*/
#define BOC             1    /*�й�����*/
#define ABC             2    /*�й�ũҵ����*/
#define ICBC            3    /*�й���������*/
#define CCB             4    /*�й���������*/
#define BCC             5    /*��ͨ����*/
#define CMB             6    /*��������*/
#define CB              7    /*��ҵ����*/
#define CIB             8    /*��������*/
#define MSB             9    /*�й���������*/
#define HXB             10   /*��������*/
#define CEB             11   /*�������*/
#define SPDB            12   /*�Ϻ��ֶ���չ����*/
#define POST            13   /*��������*/
#define SDB             14   /*�չ*/
#define NXS             15   /*ũ����*/
#define FIB             16   /*��ҵ*/
#define JXBOC_CONET     17   /*��������CONET*/
#define JXBOC_CSP       18   /*��������CSP*/
#define ICBC_ZJYW       19   /*�����м�ҵ��ƽ̨*/
#define GFB             20   /*������*/
#define CIC             97   /*��������*/
#define CCUN            98   /*CCUN*/
#define YLPOSP          99   /*����POSP*/
#define YLGGZF          100  /*��������֧��*/


/*ͨѶģʽ*/
#define FSK_COMMU       1
#define MODEM_COMMU     2

/*��������*/
#define SUCC            0
#define FAIL            -1
#define DUPLICATE       -2
#define TIMEOUT         -3
#define INVALID_PACK    -4


/*��ý�彻���������궨�壬�������������ʽͨѶ�豸��MAX_FSK_NUMֻ��Ϊ1 */
#define MAX_FSK_NUM             1
#define MAX_DSP_MODULE_NUM      3    
#define MAX_CHANNEL_NUM         256
#define MAX_COMPOS_NUM          60
#define MAX_QUERY_LEN           420

/* ��bin��������� */
#define MAX_CARD_NUM    4000

/*ISO8583��궨��*/
#define MSG_ID          0        
#define BIT_MAP         1
#define PAN             2
#define PROC_CODE       3
#define AMOUNT          4
#define DATE_TIME       7
#define POS_TRACE       11
#define LOCAL_TIME      12
#define LOCAL_DATE      13
#define EXPIRY          14
#define SETTLE_DATE     15
#define MERCH_TYPE      18
#define MODE            22
#define NII             24
#define SERVER_CODE     25
#define PIN_MODE        26
#define FIELD28         28
#define ACQUIRER_ID     32
#define SENDER_ID       33
#define TRACK_2         35
#define TRACK_3         36
#define RETR_NUM        37
#define AUTH_ID         38
#define RET_CODE        39
#define POS_ID          41
#define CUSTOM_ID       42
#define CUSTOM_NAME     43
#define FIELD44         44
#define FIELD48         48
#define FUND_TYPE       49
#define PIN_DATA        52
#define SEC_CTRL_CODE   53
#define ADDI_AMOUNT     54
#define FIELD59         59
#define FIELD60         60
#define HOLDER_ID       61
#define FIELD62         62
#define FIELD63         63
#define NET_MANAGE_CODE 70
#define ORIG_DATA       90
#define DESTINATION_CODE   100
#define MAC             128

/* ��ӡ��¼�ź궨�壬Ӧ�������ݿ��print_info(��ӡ��¼��Ϣ��)�ж���һ�� */
#define PRINT_TRANS_TYPE        1    /* �������� */
#define PRINT_CARD_NO           2    /* ���� */
#define PRINT_CARD_IN           3    /* ת�뿨�� */
#define PRINT_CARD_OUT          4    /* ת������ */
#define PRINT_PAY_CARD_NO       5    /* ����� */
#define PRINT_PAN               6    /* �����˺� */
#define PRINT_AMOUNT            7    /* ���׽�� */
#define PRINT_SYS_TRACE         8    /* ϵͳ�ο��� */
#define PRINT_TRACE             9    /* ��ˮ�� */
#define PRINT_DATE_TIME         10   /* ����ʱ�� */
#define PRINT_AWARD             11   /* �н���Ϣ */
#define PRINT_PAY_CODE1         12   /* �ɷѺ��� */
#define PRINT_PAY_CODE2         13   /* ��ֵ����*/
#define PRINT_TELEPHONE         14   /* �ֻ����� */
#define PRINT_USER_CODE         15   /* ������ */
#define PRINT_SIGN              16   /* �ֿ���ǩ�� */
#define PRINT_TITLE1            17   /* ���� */
#define PRINT_SHOP_SLIP         18   /* ���1 */
#define PRINT_HOLDER_SLIP       19   /* ���2 */
#define PRINT_TERM_NO           20   /* �ն˺� */
#define PRINT_SHOP_NO           21   /* �̻��� */
#define PRINT_SHOP_NAME         22   /* �̻����� */
#define PRINT_NOTE0             23   /* ��ע0 */
#define PRINT_NOTE1             24   /* ��ע1 */
#define PRINT_NOTE2             25   /* ��ע2 */
#define PRINT_NOTE3             26   /* ��ע3 */
#define PRINT_LINE              27   /* ���� */
#define PRINT_BALANCE           28   /* ��� */
#define PRINT_AUTH_CODE         29   /* ��Ȩ�� */
#define PRINT_FEE               30   /* ������ */
#define PRINT_ISSUER_BANK       31   /* �����к� */
#define PRINT_ACQ_BANK          32   /* �յ��к� */
#define PRINT_EXP_DATE          33   /* ��Ч�� */
#define PRINT_ENTER             34   /* ���з� */
#define PRINT_REPRINT           35   /* �ش�ӡ */
#define PRINT_BANK_OUT          36   /* ת���� */
#define PRINT_BANK_IN           37   /* ת���� */
#define PRINT_YINGJIAO_AMT      38   /* Ӧ�ɽ�� */
#define PRINT_SHIJIAO_AMT       39   /* ʵ�ɽ�� */
#define PRINT_HOLDER_NAME       40   /* �û��� */
#define PRINT_BLANK             41   /* �ո� */
#define PRINT_TOTAL_AMT         42   /* �ϼƽ�� */

/*���������궨�壬��print_data(��ӡ����������)����Ҫһ�£�����ָ��������Դ��
  �������ݽṹ���ĸ��ֶ�*/
#define HOST_DATETIME_IDX       1    /* ��������ʱ�� */
#define POS_DATETIME_IDX        2    /* �ն�����ʱ�� */
#define PAN_IDX                 3    /* ���˻� */
#define AMOUNT_IDX              4    /* ���׽���Ӧ�ɽ�� */
#define TRANS_NAME_IDX          5    /* �������� */
#define POS_TRACE_IDX           6    /* �ն���ˮ�� */
#define RETRI_REF_NUM_IDX       7    /* ��̨�����ο��� */      
#define AUTH_CODE_IDX           8    /* ��Ȩ�� */
#define SHOP_NO_IDX             9    /* �̻��� */
#define POS_NO_IDX              10   /* �ն˺� */
#define SHOP_NAME_IDX           11   /* �̻����� */
#define PSAM_NO_IDX             12   /* ��ȫģ��� */
#define SYS_TRACE_IDX           13   /* ƽ̨��ˮ�� */ 
#define ACCOUNT2_IDX            14   /* ת���˺� */
#define OUT_CARD_NAME_IDX       15   /* ���п����� */
#define OLD_POS_TRACE_IDX       16   /* ԭ�ն���ˮ�� */
#define OLD_RETRI_REF_NUM_IDX   17   /* ԭ��̨�����ο��� */
#define FINANCIAL_CODE_IDX      18   /* ����Ӧ�ú� */
#define BUSINESS_CODE_IDX       19   /* ����Ӧ�ú� */
#define HOST_DATE_IDX           20   /* ƽ̨�������ڣ���ʽYYYYMMDD */
#define POS_DATE_IDX            21   /* �ն˽������ڣ���ʽYYYYMMDD */
#define HOST_TIME_IDX           22   /* ƽ̨����ʱ�䣬��ʽHHMMSS */
#define POS_TIME_IDX            23   /* �ն˽���ʱ�䣬��ʽHHMMSS */
#define EXPIRE_DATE_IDX         24   /* ����Ч�� */
#define SHOP_TYPE_IDX           25   /* �̻����� */
#define TRANS_NUM_IDX           26   /* ���� */
#define RATE_IDX                27   /* ���� */
#define TRACK2_IDX              28   /* ���ŵ����� */    
#define TRACK3_IDX              29   /* ���ŵ����� */
#define MAC_IDX                 30   /* ����MAC */
#define RET_CODE_IDX            31   /* ƽ̨������ */
#define RET_DESC_IDX            32   /* ������Ϣ���� */
#define BATCH_NO_IDX            33   /* �������κ� */
#define RESERVED_IDX            34   /* �Զ������� */
#define ADDI_AMOUNT_IDX         35   /* ���������� */
#define OUT_BANK_ID_IDX         36   /* ת����ID */
#define ACQ_BANK_ID_IDX         37   /* �յ���ID */
#define TOTAL_AMT_IDX           38   /* ���׽���ܶ�  */
#define OUT_BANK_NAME_IDX       39   /* ת�������� */
#define IN_BANK_ID_IDX          40   /* ת�뿨������ID */
#define IN_BANK_NAME_IDX        41   /* ת�뿨���������� */
#define MENU_NAME_IDX           42   /* �˵����� */
#define HOLDER_NAME_IDX         43   /* �ֿ������� */
#define HAND_INPUT_DATE_IDX         45   /* �ֹ��������� */

/* ����Ŀ¼�ĺ궨�� */
#define WORKDIR        "WORKDIR"

#define uchar   unsigned char
#define uint    unsigned int
#define ulong   unsigned long

/* ״̬��ʶ ��Ӧ���ݿ���status�ֶ� 0-��Ч 1-��Ч*/
#define VALID    0
#define INVALID    1

/* �ն��쳣������� '0'-���������ط� '1'-���� '2'-�ط�'*/
#define POS_NO_VOID_RESEND      '0'
#define POS_MUST_VOID           '1'
#define POS_MUST_RESEND         '2'

/* �����Ѽ��㷽ʽ 0-������ 1-������ 2-������'*/
#define NO_CALC_FEE        0
#define CALC_FEE_BY_RATE   1
#define CALC_FEE_BY_AREA   2

/* ASC��BCD��ת�������뷽ʽ */
#define LEFT_ALIGN      0       //����룬�Ҳ�0
#define RIGHT_ALIGN     1       //�Ҷ��룬��0

/* ������������ */
#define HEX_DATA        0
#define ASC_DATA        1
#define BCD_DATA        2

/* �ն����� */
#define POS_CALLING     1
/* �������� */
#define EPAY_CALLING    2

/* ����sock�������ͣ�����CreateSrvSocket()�����ĵ�2������ */
#define SOCK_TCP        "tcp"
#define SOCK_UDP        "udp"

/* ��־��ӡ��غ궨�� */
#define E_ERROR     0
#define T_TRACE     1

/* ƽ̨�Զ���ָ����غ궨�� */
#define SPECIAL_CMD_HEAD    0xC0            /* �Զ���ָ��ͷ�ֽ� */
#define SPECIAL_CMD_LEN     3               /* �Զ���ָ��� */

#define ERROR       __FILE__, __LINE__, E_ERROR
#define TRACE       __FILE__, __LINE__, T_TRACE
