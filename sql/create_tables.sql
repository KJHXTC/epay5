--****************************************************************************
-- Copyright(C)2012 - 2015���������豸���޹�˾                               
-- ��Ҫ���ݣ����ݿ�����ű�                                                
-- �� �� �ˣ�������                                                          
-- �������ڣ�2012/11/8                                                       
-----------------------------------------------------------------------------
-- $Revision: 1.14 $                                                         
-- $Log: create_tables.sql,v $
-- Revision 1.14  2013/06/14 02:20:50  fengw
--
-- 1���޸�HOST_TERM_KEY������host_no��mag_key�ֶΡ�
--
-- Revision 1.13  2013/03/11 05:42:05  fengw
--
-- 1������emv_key��emv_para��
--
-- Revision 1.12  2013/02/22 02:49:44  fengw
--
-- 1��trans_def������business_type�ֶΡ�
--
-- Revision 1.11  2013/02/21 06:17:31  fengw
--
-- 1���޸�my_customer����䡣
--
-- Revision 1.10  2013/01/05 08:09:32  fengw
--
-- 1��trans_def������excep_times�ֶ�(�쳣�������)������Ϊinteger��
--
-- Revision 1.9  2012/12/28 03:28:50  fengw
--
-- 1��posls��history_ls��void_ls������dept_detail�ֶΡ�
--
-- Revision 1.8  2012/12/18 07:16:40  chenrb
-- commands�����ӿ��Ʋ���control_para�����Ʋ�������control_len�����ֶ�
--
-- Revision 1.7  2012/12/18 05:30:16  fengw
--
-- 1����terminal���msg_recno�ֶγ����޸�Ϊ256��
--
-- Revision 1.6  2012/12/17 06:29:13  chenrb
-- trans_commands���ӿ��Ʋ������ȡ����Ʋ���2���ֶ�
--
-- Revision 1.5  2012/12/04 03:11:19  fengw
--
-- 1���޸�cards��������
--
-- Revision 1.4  2012/11/29 07:35:57  chenrb
-- dos2unixת��
--
-- Revision 1.3  2012/11/29 07:31:14  chenrb
-- terminal������port�ֶ�
--                                                                     
--***************************************************************************

drop table APP_DEF;
create table APP_DEF
(
  APP_TYPE INTEGER,
  APP_NAME VARCHAR(20),
  DESCRIBE VARCHAR(30),
  APP_VER  CHAR(8)
)
;
comment on table APP_DEF
  is 'Ӧ�ö����';
comment on column APP_DEF.APP_TYPE
  is 'Ӧ�����ͺ�';
comment on column APP_DEF.APP_NAME
  is 'Ӧ������';
comment on column APP_DEF.DESCRIBE
  is 'Ӧ������';
comment on column APP_DEF.APP_VER
  is 'Ӧ�ð汾��';
create unique index APP_TYPE_IDX1 on APP_DEF (APP_TYPE);

drop table APP_MENU;
create table APP_MENU
(
  MENU_NO     INTEGER,
  UP_MENU_NO  INTEGER,
  APP_TYPE    INTEGER,
  LEVEL_1     INTEGER,
  LEVEL_2     INTEGER,
  LEVEL_3     INTEGER,
  MENU_NAME   VARCHAR(20),
  TRANS_CODE  CHAR(8),
  IS_VALID    CHAR(1),
  UPDATE_DATE CHAR(8)
)
;
comment on table APP_MENU
  is 'Ӧ�ò˵�';
comment on column APP_MENU.MENU_NO
  is '�˵�ID';
comment on column APP_MENU.UP_MENU_NO
  is '�ϼ��˵�ID';
comment on column APP_MENU.APP_TYPE
  is 'Ӧ�����ͺ�';
comment on column APP_MENU.LEVEL_1
  is 'һ���˵��е�λ��';
comment on column APP_MENU.LEVEL_2
  is '�����˵��е�λ��';
comment on column APP_MENU.LEVEL_3
  is '�����˵��е�λ��';
comment on column APP_MENU.MENU_NAME
  is '�˵�����';
comment on column APP_MENU.TRANS_CODE
  is '���״���';
comment on column APP_MENU.IS_VALID
  is '��Ч��ʶ 0-���� 1-��ʾ';
comment on column APP_MENU.UPDATE_DATE
  is '����������';
create unique index APP_MENU_IDX1 on APP_MENU (APP_TYPE, LEVEL_1, LEVEL_2, LEVEL_3);
create unique index APP_MENU_IDX2 on APP_MENU (MENU_NO);

drop table ARTCONF;
create table ARTCONF
(
  PARA_ID    VARCHAR(20),
  PARA_NAME  VARCHAR(40),
  PARA_VALUE VARCHAR(40),
  DESCRIBE  VARCHAR(60)
)
;
comment on table ARTCONF
  is 'ϵͳ����������';
comment on column ARTCONF.PARA_ID
  is 'ID����';
comment on column ARTCONF.PARA_NAME
  is '������';
comment on column ARTCONF.PARA_VALUE
  is '����ֵ';
comment on column ARTCONF.DESCRIBE
  is '��������';

drop table BIND_CARD;
create table BIND_CARD
(
  PAN           VARCHAR(19),
  REGISTER_DATE CHAR(8)
)
;
comment on table BIND_CARD
  is '����������';
comment on column BIND_CARD.PAN
  is '����';
comment on column BIND_CARD.REGISTER_DATE
  is '������';
create unique index BIND_CARD_IDX on BIND_CARD (PAN);

drop table BIND_CARD_BALANCE;
create table BIND_CARD_BALANCE
(
  PAN     CHAR(19),
  BALANCE NUMERIC(12,2)
)
;
comment on table BIND_CARD_BALANCE
  is '�󶨿��վ�����';
comment on column BIND_CARD_BALANCE.PAN
  is '����';
comment on column BIND_CARD_BALANCE.BALANCE
  is '�վ����';
create unique index BIND_CARD_BALANCE_IDX on BIND_CARD_BALANCE (PAN);

drop table CARDS;
create table CARDS
(
  BANK_NAME   VARCHAR(20),
  BANK_ID     CHAR(11),
  CARD_NAME   VARCHAR(40),
  CARD_ID     VARCHAR(19) not null,
  CARD_NO_LEN INTEGER not null,
  CARD_SITE2  INTEGER not null,
  EXP_SITE2   INTEGER default 19,
  PAN_SITE3   INTEGER default 0,
  CARD_SITE3  INTEGER default 0,
  EXP_SITE3   INTEGER default 0,
  CARD_TYPE   CHAR(1),
  CARD_LEVEL  INTEGER default 0
)
;
comment on table CARDS
  is '����';
comment on column CARDS.BANK_NAME
  is '��������';
comment on column CARDS.BANK_ID
  is '���б�ʶ';
comment on column CARDS.CARD_NAME
  is '������';
comment on column CARDS.CARD_ID
  is '����ʶ��';
comment on column CARDS.CARD_NO_LEN
  is '���ų���';
comment on column CARDS.CARD_SITE2
  is '���ŵ�����λ��';
comment on column CARDS.EXP_SITE2
  is '���ŵ�����Ч��λ��';
comment on column CARDS.PAN_SITE3
  is '���ŵ��˺�λ��';
comment on column CARDS.CARD_SITE3
  is '���ŵ�����λ��';
comment on column CARDS.EXP_SITE3
  is '���ŵ���Ч��λ��';
comment on column CARDS.CARD_TYPE
  is '������ 0-��ǿ� 1-���ǿ� 2-���⿨ 3-׼���ǿ�';
comment on column CARDS.CARD_LEVEL
  is '������ 0-�տ� 1-��';
CREATE UNIQUE INDEX cards_idx ON cards (card_id, card_no_len);

drop table CEN_OPER;
create table CEN_OPER
(
  OPERATOR   CHAR(4),
  OPER_PWD   CHAR(6),
  OPER_FLAG  CHAR(1),
  OPER_LEVEL CHAR(1)
)
;
comment on table CEN_OPER
  is '���Ĳ���Ա��';
comment on column CEN_OPER.OPERATOR
  is '����Ա��';
comment on column CEN_OPER.OPER_PWD
  is '����Ա����';
comment on column CEN_OPER.OPER_FLAG
  is '����Ա״̬';
comment on column CEN_OPER.OPER_LEVEL
  is '����Ա����';
create unique index CEN_OPER_IDX on CEN_OPER (OPERATOR);

drop table COMMANDS;
create table COMMANDS
(
  CMD_INDEX    INTEGER,
  ORG_COMMAND   CHAR(2),
  DEST_COMMAND  CHAR(2),
  OPER_INDEX   INTEGER,
  ALOG         CHAR(8),
  COMMAND_NAME VARCHAR(30),
  CONTROL_LEN   INTEGER default 0,
  CONTROL_PARA  CHAR(60)
)
;
comment on table COMMANDS
  is '�ն�ָ���';
comment on column COMMANDS.CMD_INDEX
  is '˳��ţ����ڽ��׶���ʱ����';
comment on column COMMANDS.ORG_COMMAND
  is 'ԭʼָ����';
comment on column COMMANDS.DEST_COMMAND
  is 'Ĭ��ָ����';
comment on column COMMANDS.OPER_INDEX
  is 'Ĭ�ϲ�����ʾ��Ϣ������';
comment on column COMMANDS.ALOG
  is '���ܼ�У���㷨';
comment on column COMMANDS.COMMAND_NAME
  is 'ָ������';
comment on column COMMANDS.CONTROL_LEN
  is 'Ĭ�Ͽ��Ʋ�������';
comment on column COMMANDS.CONTROL_PARA
  is 'Ĭ�Ͽ��Ʋ���';
create unique index COMMANDS_IDX on COMMANDS (CMD_INDEX);

drop table COMWEB_PID;
create table COMWEB_PID
(
  SHOP_NO CHAR(15),
  POS_NO  CHAR(15),
  PID     INTEGER
)
;
comment on table COMWEB_PID
  is 'COMWEB���̵ǼǱ�';
comment on column COMWEB_PID.SHOP_NO
  is '�̻���';
comment on column COMWEB_PID.POS_NO
  is '�ն˺�';
comment on column COMWEB_PID.PID
  is 'COMWEB����ID';
create unique index COMWEB_PID_IDX on COMWEB_PID (SHOP_NO, POS_NO);

drop table DEPT;
create table DEPT
(
  DEPT_NO     VARCHAR(15),
  DEPT_NAME   VARCHAR(45),
  UP_DEPT_NO  VARCHAR(15),
  DEPT_DETAIL VARCHAR(70)
)
;
comment on table DEPT
  is '������';
comment on column DEPT.DEPT_NO
  is '������';
comment on column DEPT.DEPT_NAME
  is '��������';
comment on column DEPT.UP_DEPT_NO
  is '�ϼ�������';
comment on column DEPT.DEPT_DETAIL
  is '�����㼶��Ϣ';
create unique index DEPT_IDX on DEPT (DEPT_NO);

drop table DICT_CAT;
create table DICT_CAT
(
  CAT_CODE VARCHAR(20) not null,
  CAT_TEXT VARCHAR(40)
)
;
comment on table DICT_CAT
  is '�����ֵ��';
comment on column DICT_CAT.CAT_CODE
  is '�ֵ����';
comment on column DICT_CAT.CAT_TEXT
  is '�ֵ�����';
alter table DICT_CAT
  add constraint PK_DICT_CAT primary key (CAT_CODE);

drop table DICT_ITEM;
create table DICT_ITEM
(
  CAT_CODE  VARCHAR(20) not null,
  ITEM_CODE VARCHAR(20) not null,
  ITEM_TEXT VARCHAR(40)
)
;
comment on table DICT_ITEM
  is '�����ֵ���Ŀ';
comment on column DICT_ITEM.CAT_CODE
  is '�ֵ����';
comment on column DICT_ITEM.ITEM_CODE
  is '��Ŀ����';
comment on column DICT_ITEM.ITEM_TEXT
  is '��Ŀ����';
alter table DICT_ITEM
   add constraint PK_DICT_ITEM primary key (CAT_CODE, ITEM_CODE);
create index DICT_ITEM_IDX on DICT_ITEM (CAT_CODE);

drop table DYNAMIC_MENU;
create table DYNAMIC_MENU
(
  REC_NO      INTEGER not null,
  MENU_TITLE  VARCHAR(30),
  DESCRIBE   VARCHAR(40),
  MENU_NUM    INTEGER,
  MENU_NAME1  VARCHAR(20),
  TRANS_CODE1 CHAR(8),
  MENU_NAME2  VARCHAR(20),
  TRANS_CODE2 CHAR(8),
  MENU_NAME3  VARCHAR(20),
  TRANS_CODE3 CHAR(8),
  MENU_NAME4  VARCHAR(20),
  TRANS_CODE4 CHAR(8),
  MENU_NAME5  VARCHAR(20),
  TRANS_CODE5 CHAR(8),
  MENU_NAME6  VARCHAR(20),
  TRANS_CODE6 CHAR(8),
  MENU_NAME7  VARCHAR(20),
  TRANS_CODE7 CHAR(8),
  MENU_NAME8  VARCHAR(20),
  TRANS_CODE8 CHAR(8),
  MENU_NAME9  VARCHAR(20),
  TRANS_CODE9 CHAR(8)
)
;
comment on table DYNAMIC_MENU
  is '��̬�˵���';
comment on column DYNAMIC_MENU.REC_NO
  is '��¼��';
comment on column DYNAMIC_MENU.MENU_TITLE
  is '�˵�����';
comment on column DYNAMIC_MENU.DESCRIBE
  is '����';
comment on column DYNAMIC_MENU.MENU_NUM
  is '�˵�����';
comment on column DYNAMIC_MENU.MENU_NAME1
  is '�˵�һ����';
comment on column DYNAMIC_MENU.TRANS_CODE1
  is '���״���һ';
comment on column DYNAMIC_MENU.MENU_NAME2
  is '�˵�������';
comment on column DYNAMIC_MENU.TRANS_CODE2
  is '���״����';
comment on column DYNAMIC_MENU.MENU_NAME3
  is '�˵�������';
comment on column DYNAMIC_MENU.TRANS_CODE3
  is '���״�����';
comment on column DYNAMIC_MENU.MENU_NAME4
  is '�˵�������';
comment on column DYNAMIC_MENU.TRANS_CODE4
  is '���״�����';
comment on column DYNAMIC_MENU.MENU_NAME5
  is '�˵�������';
comment on column DYNAMIC_MENU.TRANS_CODE5
  is '���״�����';
comment on column DYNAMIC_MENU.MENU_NAME6
  is '�˵�������';
comment on column DYNAMIC_MENU.TRANS_CODE6
  is '���״�����';
comment on column DYNAMIC_MENU.MENU_NAME7
  is '�˵�������';
comment on column DYNAMIC_MENU.TRANS_CODE7
  is '���״�����';
comment on column DYNAMIC_MENU.MENU_NAME8
  is '�˵�������';
comment on column DYNAMIC_MENU.TRANS_CODE8
  is '���״����';
comment on column DYNAMIC_MENU.MENU_NAME9
  is '�˵�������';
comment on column DYNAMIC_MENU.TRANS_CODE9
  is '���״����';
create unique index DYNAMIC_MENU_IDX on DYNAMIC_MENU (REC_NO);

drop table EPAY_MONI;
create table EPAY_MONI
(
  MONI_TIME   CHAR(14) not null,
  HOST_NO     INTEGER not null,
  HOST_NAME   CHAR(32),
  PROC_STATUS VARCHAR(1024),
  MSG_STATUS  VARCHAR(1024),
  COMM_STATUS VARCHAR(1024),
  SYS_INFO    CLOB
)
;
comment on table EPAY_MONI
  is 'ϵͳ״̬��ر�';
comment on column EPAY_MONI.MONI_TIME
  is '���ʱ�� YYYYMMDDHHMMSS';
comment on column EPAY_MONI.HOST_NO
  is '������ʶ';
comment on column EPAY_MONI.HOST_NAME
  is '��������';
comment on column EPAY_MONI.PROC_STATUS
  is '����״̬';
comment on column EPAY_MONI.MSG_STATUS
  is '��Ϣ����״̬';
comment on column EPAY_MONI.COMM_STATUS
  is 'ͨѶ�˿�״̬';
comment on column EPAY_MONI.SYS_INFO
  is 'ϵͳ��ϸ��Ϣ';
create unique index EPAY_MONI_IDX on EPAY_MONI (MONI_TIME, HOST_NO);

drop table ERROR_CODE;
create table ERROR_CODE
(
  RETURN_CODE CHAR(2) not null,
  RETURN_NAME VARCHAR(12),
  POS_MSG     VARCHAR(20),
  HOST1_RET   VARCHAR(40),
  HOST2_RET   VARCHAR(40),
  HOST3_RET   VARCHAR(40),
  HOST4_RET   VARCHAR(40)
)
;
comment on table ERROR_CODE
  is '��������ձ�';
comment on column ERROR_CODE.RETURN_CODE
  is '�ն˷�����';
comment on column ERROR_CODE.RETURN_NAME
  is '������������ʾ�ڼ����';
comment on column ERROR_CODE.POS_MSG
  is '�ն���ʾ������Ϣ';
comment on column ERROR_CODE.HOST1_RET
  is '����������1';
comment on column ERROR_CODE.HOST2_RET
  is '����������2';
comment on column ERROR_CODE.HOST3_RET
  is '����������3';
comment on column ERROR_CODE.HOST4_RET
  is '����������4';
create unique index ERROR_CODE_IDX on ERROR_CODE (RETURN_CODE);

drop table ERROR_INFO;
create table ERROR_INFO
(
  ERROR_INDEX  INTEGER not null,
  OP_FLAG      CHAR(1),
  MODULE_NUM   INTEGER not null,
  INFO1_FORMAT CHAR(2),
  INFO1        VARCHAR(100),
  INFO2_FORMAT CHAR(2),
  INFO2        VARCHAR(100),
  INFO3_FORMAT CHAR(2),
  INFO3        VARCHAR(100),
  UPDATE_DATE  CHAR(8)
)
;
comment on table ERROR_INFO
  is '������ʾ��Ϣ��';
comment on column ERROR_INFO.ERROR_INDEX
  is '������ʾ��Ϣ����';
comment on column ERROR_INFO.OP_FLAG
  is '��Ϣ������־';
comment on column ERROR_INFO.MODULE_NUM
  is 'ģ����';
comment on column ERROR_INFO.INFO1_FORMAT
  is 'ģ��1���ݸ�ʽ';
comment on column ERROR_INFO.INFO1
  is 'ģ��1����';
comment on column ERROR_INFO.INFO2_FORMAT
  is 'ģ��2���ݸ�ʽ';
comment on column ERROR_INFO.INFO2
  is 'ģ��2����';
comment on column ERROR_INFO.INFO3_FORMAT
  is 'ģ��3���ݸ�ʽ';
comment on column ERROR_INFO.INFO3
  is 'ģ��3����';
comment on column ERROR_INFO.UPDATE_DATE
  is '����������';
create unique index ERROR_INFO_IDX on ERROR_INFO (ERROR_INDEX);

drop table FILES_MGR;
create table FILES_MGR
(
  FILE_ID    INTEGER not null,
  FILE_NAME   VARCHAR(40),
  LAST_DATE   VARCHAR(20),
  LAST_MENDER VARCHAR(20),
  DESCRIBE  VARCHAR(200)
)
;
comment on table FILES_MGR
  is '�ļ������';
comment on column FILES_MGR.FILE_ID
  is '�ļ�id';
comment on column FILES_MGR.FILE_NAME
  is '�ļ�����';
comment on column FILES_MGR.LAST_DATE
  is '����޸�ʱ��';
comment on column FILES_MGR.LAST_MENDER
  is '����޸���';
comment on column FILES_MGR.DESCRIBE
  is '�ļ�����';

drop table FIRST_PAGE;
create table FIRST_PAGE
(
  REC_NO     INTEGER,
  PAGE_TITLE VARCHAR(30),
  DESCRIBE  VARCHAR(200),
  VALID_DATE CHAR(8)
)
;
comment on table FIRST_PAGE
  is '��ҳ��Ϣ��';
comment on column FIRST_PAGE.REC_NO
  is '��¼��';
comment on column FIRST_PAGE.PAGE_TITLE
  is '��Ϣ����';
comment on column FIRST_PAGE.DESCRIBE
  is '��Ϣ����';
comment on column FIRST_PAGE.VALID_DATE
  is '��Ч��ֹ����';
create unique index FIRST_PAGE_IDX on FIRST_PAGE (REC_NO);

drop table FUNCTION_INFO;
create table FUNCTION_INFO
(
  FUNC_INDEX   INTEGER,
  OP_FLAG      CHAR(1),
  MODULE_NUM   INTEGER,
  INFO1_FORMAT CHAR(2),
  INFO1        VARCHAR(100),
  INFO2_FORMAT CHAR(2),
  INFO2        VARCHAR(100),
  INFO3_FORMAT CHAR(2),
  INFO3        VARCHAR(100),
  UPDATE_DATE  CHAR(8)
)
;
comment on table FUNCTION_INFO
  is '������ʾ��Ϣ��';
comment on column FUNCTION_INFO.FUNC_INDEX
  is '������ʾ��Ϣ����';
comment on column FUNCTION_INFO.OP_FLAG
  is '��Ϣ������־';
comment on column FUNCTION_INFO.MODULE_NUM
  is 'ģ����';
comment on column FUNCTION_INFO.INFO1_FORMAT
  is 'ģ��1���ݸ�ʽ';
comment on column FUNCTION_INFO.INFO1
  is 'ģ��1����';
comment on column FUNCTION_INFO.INFO2_FORMAT
  is 'ģ��2���ݸ�ʽ';
comment on column FUNCTION_INFO.INFO2
  is 'ģ��2����';
comment on column FUNCTION_INFO.INFO3_FORMAT
  is 'ģ��3���ݸ�ʽ';
comment on column FUNCTION_INFO.INFO3
  is 'ģ��3����';
comment on column FUNCTION_INFO.UPDATE_DATE
  is '����������';
create unique index FUNCTION_INFO_IDX on FUNCTION_INFO (FUNC_INDEX);

drop table HISTORY_LS;
create table HISTORY_LS
(
  HOST_DATE      CHAR(8),
  HOST_TIME      CHAR(6),
  PAN            VARCHAR(19),
  AMOUNT         NUMERIC(12,2),
  CARD_TYPE      CHAR(1),
  TRANS_TYPE     INTEGER,
  BUSINESS_TYPE  INTEGER,
  RETRI_REF_NUM  CHAR(12),
  AUTH_CODE      CHAR(6),
  POS_NO         CHAR(15),
  SHOP_NO        CHAR(15),
  ACCOUNT2       VARCHAR(19),
  ADDI_AMOUNT    NUMERIC(12,2),
  BATCH_NO       INTEGER,
  PSAM_NO        CHAR(16),
  INVOICE        INTEGER,
  RETURN_CODE    CHAR(2),
  HOST_RET_CODE  VARCHAR(6),
  HOST_RET_MSG	 VARCHAR(40),
  CANCEL_FLAG    CHAR(1),
  RECOVER_FLAG   CHAR(1),
  POS_SETTLE     CHAR(1),
  POS_BATCH      CHAR(1),
  HOST_SETTLE    CHAR(1),
  SYS_TRACE     INTEGER,
  OLD_RETRI_REF_NUM 	CHAR(12),
  POS_DATE       CHAR(8),
  POS_TIME       CHAR(6),
  FINANCIAL_CODE VARCHAR(40),
  BUSINESS_CODE  VARCHAR(40),
  BANK_ID        VARCHAR(11),
  SETTLE_DATE    CHAR(8),
  OPER_NO        CHAR(4),
  MAC            CHAR(16),
  POS_TRACE      INTEGER,
  DEPT_DETAIL    VARCHAR(70)
)
;
comment on table HISTORY_LS
  is '��ʷ��ˮ��';
comment on column HISTORY_LS.HOST_DATE
  is '������������';
comment on column HISTORY_LS.HOST_TIME
  is '��������ʱ��';
comment on column HISTORY_LS.PAN
  is '���ţ�ת������';
comment on column HISTORY_LS.AMOUNT
  is '���׽��';
comment on column HISTORY_LS.CARD_TYPE
  is '������ 0-��ǿ� 1-���ǿ� 2-���⿨ 3-׼���ǿ�';
comment on column HISTORY_LS.TRANS_TYPE
  is '��������';
comment on column HISTORY_LS.BUSINESS_TYPE
  is 'ҵ�����ͣ����ڷ���ͳ�ơ����׶�ȿ���';
comment on column HISTORY_LS.RETRI_REF_NUM
  is '���ײο���';
comment on column HISTORY_LS.AUTH_CODE
  is '��Ȩ��';
comment on column HISTORY_LS.POS_NO
  is '�ն˺�';
comment on column HISTORY_LS.SHOP_NO
  is '�̻���';
comment on column HISTORY_LS.ACCOUNT2
  is '����2��ת�뿨��';
comment on column HISTORY_LS.ADDI_AMOUNT
  is '�����ѣ����ӽ��';
comment on column HISTORY_LS.BATCH_NO
  is '���κ�';
comment on column HISTORY_LS.PSAM_NO
  is '��ȫģ���';
comment on column HISTORY_LS.INVOICE
  is '��Ʊ��';
comment on column HISTORY_LS.RETURN_CODE
  is 'POS������';
comment on column HISTORY_LS.HOST_RET_CODE
  is '����������';
comment on column HISTORY_LS.HOST_RET_MSG
  is '����������Ϣ'; 
comment on column HISTORY_LS.CANCEL_FLAG
  is '������ʶλ Y-�ѳ��� N-δ����';
comment on column HISTORY_LS.RECOVER_FLAG
  is '������ʶλ Y-�ѳ��� N-δ���� U-���������';
comment on column HISTORY_LS.POS_SETTLE
  is 'POS�����־λ Y-�ѽ��� N-δ����';
comment on column HISTORY_LS.POS_BATCH
  is 'POS�����ͱ�ʶλ';
comment on column HISTORY_LS.HOST_SETTLE
  is '���������ʶλ';
comment on column HISTORY_LS.SYS_TRACE
  is 'ϵͳ��ˮ��';
comment on column HISTORY_LS.OLD_RETRI_REF_NUM
  is 'ԭ���ײο���';
comment on column HISTORY_LS.POS_DATE
  is 'POS��������';
comment on column HISTORY_LS.POS_TIME
  is 'POS����ʱ��';
comment on column HISTORY_LS.FINANCIAL_CODE
  is '����Ӧ�ú�';
comment on column HISTORY_LS.BUSINESS_CODE
  is '����Ӧ�ú�';
comment on column HISTORY_LS.BANK_ID
  is '���б�ʶ��';
comment on column HISTORY_LS.SETTLE_DATE
  is '��������';
comment on column HISTORY_LS.OPER_NO
  is '����Ա��';
comment on column HISTORY_LS.MAC
  is 'MACֵ';
comment on column HISTORY_LS.POS_TRACE
  is '�ն���ˮ��';
comment on column HISTORY_LS.DEPT_DETAIL
  is '�����㼶��Ϣ';
create index HISTORY_LS_IDX1 on HISTORY_LS (HOST_DATE);
create index HISTORY_LS_IDX2 on HISTORY_LS (POS_NO, SHOP_NO,POS_DATE, POS_TRACE);
create index HISTORY_LS_IDX3 on HISTORY_LS (SYS_TRACE);

drop table HOST_ERROR;
create table HOST_ERROR
(
  RETURN_CODE VARCHAR(6) not null,
  ERROR_MSG   VARCHAR(80)
)
;
comment on table HOST_ERROR
  is '�����������';
comment on column HOST_ERROR.RETURN_CODE
  is '������';
comment on column HOST_ERROR.ERROR_MSG
  is '������Ϣ';
create unique index HOST_ERROR_IDX on HOST_ERROR (RETURN_CODE);

drop table HOST_KEY;
create table HOST_KEY
(
  HOST_ID   INTEGER not null,
  HOST_NAME VARCHAR(40),
  MAC_KEY   CHAR(32),
  PIN_KEY   CHAR(32)
)
;
comment on table HOST_KEY
  is '������Կ��������ʽ�ԽӲ��ø���Կ��洢������Կ';
comment on column HOST_KEY.HOST_ID
  is '����ID��';
comment on column HOST_KEY.HOST_NAME
  is '��������';
comment on column HOST_KEY.MAC_KEY
  is 'MAC��Կ';
comment on column HOST_KEY.PIN_KEY
  is 'PIN��Կ';
create unique index HOST_KEY_IDX on HOST_KEY (HOST_ID);

drop table HOST_TERM_KEY;
create table HOST_TERM_KEY
(
  HOST_NO           INTEGER NOT NULL,
  SHOP_NO          	CHAR(15) not null,
  POS_NO           	CHAR(15) not null,
  MASTER_KEY       	CHAR(32),
  PIN_KEY           CHAR(32),
  MAC_KEY          	CHAR(32),
  MAG_KEY          	CHAR(32),
  TERM_VERSION      	CHAR(7),
  CAPK_VERSION      	CHAR(8),
  PARA_VERSION      	CHAR(12) default '2',
  CARD_TABLE_VERSION 	CHAR(14)
)
;
comment on table HOST_TERM_KEY
  is '�����ն���Կ���ն˷�ʽ�ԽӲ��ø���Կ��洢��Կ';
comment on column HOST_TERM_KEY.HOST_NO
  is '������';
comment on column HOST_TERM_KEY.SHOP_NO
  is '�̻���';
comment on column HOST_TERM_KEY.POS_NO
  is '�ն˺�';
comment on column HOST_TERM_KEY.MASTER_KEY
  is '�ն�����Կ';
comment on column HOST_TERM_KEY.PIN_KEY
  is 'PIN��Կ';
comment on column HOST_TERM_KEY.MAC_KEY
  is 'MAC��Կ';
comment on column HOST_TERM_KEY.MAG_KEY
  is 'MAG��Կ';
comment on column HOST_TERM_KEY.TERM_VERSION
  is '�ն˰汾';
comment on column HOST_TERM_KEY.CAPK_VERSION
  is 'CAPK�汾';
comment on column HOST_TERM_KEY.PARA_VERSION
  is '�����汾';
comment on column HOST_TERM_KEY.CARD_TABLE_VERSION
  is '�������汾';
create unique index HOST_TERM_KEY_IDX on HOST_TERM_KEY (HOST_NO, SHOP_NO, POS_NO);

drop table VOID_LS;
create table VOID_LS
(
  HOST_DATE      CHAR(8),
  HOST_TIME      CHAR(6),
  PAN            VARCHAR(19),
  AMOUNT         NUMERIC(12,2),
  CARD_TYPE      CHAR(1),
  TRANS_TYPE     INTEGER,
  BUSINESS_TYPE  INTEGER,
  RETRI_REF_NUM  CHAR(12),
  AUTH_CODE      CHAR(6),
  POS_NO         CHAR(15),
  SHOP_NO        CHAR(15),
  ACCOUNT2       VARCHAR(19),
  ADDI_AMOUNT    NUMERIC(12,2),
  BATCH_NO       INTEGER,
  PSAM_NO        CHAR(16),
  INVOICE        INTEGER,
  RETURN_CODE    CHAR(2),
  HOST_RET_CODE  VARCHAR(6),
  HOST_RET_MSG	 VARCHAR(40),
  CANCEL_FLAG    CHAR(1),
  RECOVER_FLAG   CHAR(1),
  POS_SETTLE     CHAR(1),
  POS_BATCH      CHAR(1),
  HOST_SETTLE    CHAR(1),
  SYS_TRACE     INTEGER,
  OLD_RETRI_REF_NUM 	CHAR(12),
  POS_DATE       CHAR(8),
  POS_TIME       CHAR(6),
  FINANCIAL_CODE VARCHAR(40),
  BUSINESS_CODE  VARCHAR(40),
  BANK_ID        VARCHAR(11),
  SETTLE_DATE    CHAR(8),
  OPER_NO        CHAR(4),
  MAC            CHAR(16),
  POS_TRACE      INTEGER,
  DEPT_DETAIL    VARCHAR(70)
)
;
comment on table VOID_LS
  is '������ˮ��';
comment on column VOID_LS.HOST_DATE
  is '������������';
comment on column VOID_LS.HOST_TIME
  is '��������ʱ��';
comment on column VOID_LS.PAN
  is '���ţ�ת������';
comment on column VOID_LS.AMOUNT
  is '���׽��';
comment on column VOID_LS.CARD_TYPE
  is '������ 0-��ǿ� 1-���ǿ� 2-���⿨ 3-׼���ǿ�';
comment on column VOID_LS.TRANS_TYPE
  is '��������';
comment on column VOID_LS.BUSINESS_TYPE
  is 'ҵ�����ͣ����ڷ���ͳ�ơ����׶�ȿ���';
comment on column VOID_LS.RETRI_REF_NUM
  is '���ײο���';
comment on column VOID_LS.AUTH_CODE
  is '��Ȩ��';
comment on column VOID_LS.POS_NO
  is '�ն˺�';
comment on column VOID_LS.SHOP_NO
  is '�̻���';
comment on column VOID_LS.ACCOUNT2
  is '����2��ת�뿨��';
comment on column VOID_LS.ADDI_AMOUNT
  is '�����ѣ����ӽ��';
comment on column VOID_LS.BATCH_NO
  is '���κ�';
comment on column VOID_LS.PSAM_NO
  is '��ȫģ���';
comment on column VOID_LS.INVOICE
  is '��Ʊ��';
comment on column VOID_LS.RETURN_CODE
  is 'POS������';
comment on column VOID_LS.HOST_RET_CODE
  is '����������';
comment on column VOID_LS.HOST_RET_MSG
  is '����������Ϣ'; 
comment on column VOID_LS.CANCEL_FLAG
  is '������ʶλ Y-�ѳ��� N-δ����';
comment on column VOID_LS.RECOVER_FLAG
  is '������ʶλ Y-�ѳ��� N-δ���� U-���������';
comment on column VOID_LS.POS_SETTLE
  is 'POS�����־λ Y-�ѽ��� N-δ����';
comment on column VOID_LS.POS_BATCH
  is 'POS�����ͱ�ʶλ';
comment on column VOID_LS.HOST_SETTLE
  is '���������ʶλ';
comment on column VOID_LS.SYS_TRACE
  is 'ϵͳ��ˮ��';
comment on column VOID_LS.OLD_RETRI_REF_NUM
  is 'ԭ���ײο���';
comment on column VOID_LS.POS_DATE
  is 'POS��������';
comment on column VOID_LS.POS_TIME
  is 'POS����ʱ��';
comment on column VOID_LS.FINANCIAL_CODE
  is '����Ӧ�ú�';
comment on column VOID_LS.BUSINESS_CODE
  is '����Ӧ�ú�';
comment on column VOID_LS.BANK_ID
  is '���б�ʶ��';
comment on column VOID_LS.SETTLE_DATE
  is '��������';
comment on column VOID_LS.OPER_NO
  is '����Ա��';
comment on column VOID_LS.MAC
  is 'MACֵ';
comment on column VOID_LS.POS_TRACE
  is '�ն���ˮ��';
comment on column VOID_LS.DEPT_DETAIL
  is '�����㼶��Ϣ';
create index VOID_LS_IDX1 on VOID_LS (HOST_DATE);
create index VOID_LS_IDX2 on VOID_LS (POS_NO, SHOP_NO, POS_DATE,POS_TRACE);
create index VOID_LS_IDX3 on VOID_LS (SYS_TRACE);

drop table ISO8583;
create table ISO8583
(
  BANK_TYPE  INTEGER not null,
  FIELD_ID   INTEGER not null,
  MAX_LEN    INTEGER,
  FIELD_TYPE INTEGER,
  FIELD_FLAG INTEGER,
  LEN_FLAG   INTEGER default 2
)
;
comment on table ISO8583
  is 'ISO8583���������ñ�';
comment on column ISO8583.BANK_TYPE
  is '��������';
comment on column ISO8583.FIELD_ID
  is '���';
comment on column ISO8583.MAX_LEN
  is '����󳤶�';
comment on column ISO8583.FIELD_TYPE
  is '������ 0-ASC 1-��λ����Ǳ�ʶ 2-�Ҷ���ѹ��BCD 3-�����ѹ��BCD 8-����������';
comment on column ISO8583.FIELD_FLAG
  is '���ȱ�ʶ 0-���� 1-LLVAR��(2�ֽڱ�ʾ����) 2--LLLVAR��(3�ֽڱ�ʾ����)';
comment on column ISO8583.LEN_FLAG
  is '���ȱ�ʾ��ʽ 0-ʮ���Ƴ��ȣ�"\x31\x32"��ʾ����Ϊ12; 1-ʮ�����Ƴ��ȣ�"\x01\x00"��ʾ����Ϊ256; 2-ѹ��BCD�볤�ȣ�"\x01\x23"��ʾ����Ϊ123';
alter table ISO8583
  add constraint PK_ISO8583 primary key (BANK_TYPE, FIELD_ID);
create unique index ISO8583_IDX on ISO8583(FIELD_ID, BANK_TYPE);

drop table ISO8583_REQ_FIELD;
create table ISO8583_REQ_FIELD
(
  BANK_TYPE    INTEGER not null,
  TRANS_TYPE   INTEGER not null,
  FIELD_ID     INTEGER not null,
  FIELD_NAME   VARCHAR(50),
  FIELD_FORMAT VARCHAR(40),
  DEFAULT_DATA VARCHAR(40),
  MONDARY      INTEGER default 0
)
;
comment on table ISO8583_REQ_FIELD
  is 'ISO8583���������ñ�';
comment on column ISO8583_REQ_FIELD.BANK_TYPE
  is '��������';
comment on column ISO8583_REQ_FIELD.TRANS_TYPE
  is '��������';
comment on column ISO8583_REQ_FIELD.FIELD_ID
  is '���';
comment on column ISO8583_REQ_FIELD.FIELD_NAME
  is '������';
comment on column ISO8583_REQ_FIELD.FIELD_FORMAT
  is '���ʽ';
comment on column ISO8583_REQ_FIELD.DEFAULT_DATA
  is '��Ĭ������';
comment on column ISO8583_REQ_FIELD.MONDARY
  is '�Ƿ��ѡ,0-��,1-��';
alter table ISO8583_REQ_FIELD
  add constraint PK_ISO8583_REQ_FIELD primary key (BANK_TYPE, TRANS_TYPE, FIELD_ID);

drop table ISO8583_RSP_FIELD;
create table ISO8583_RSP_FIELD
(
  BANK_TYPE    INTEGER not null,
  TRANS_TYPE   INTEGER not null,
  FIELD_ID     INTEGER not null,
  FIELD_NAME   VARCHAR(50),
  FIELD_FORMAT VARCHAR(40),
  DEFAULT_DATA VARCHAR(40),
  MONDARY      INTEGER	default 0
)
;
comment on table ISO8583_RSP_FIELD
  is 'ISO8583��Ӧ���������ñ�';
comment on column ISO8583_RSP_FIELD.BANK_TYPE
  is '��������';
comment on column ISO8583_RSP_FIELD.TRANS_TYPE
  is '��������';
comment on column ISO8583_RSP_FIELD.FIELD_ID
  is '���';
comment on column ISO8583_RSP_FIELD.FIELD_NAME
  is '������';
comment on column ISO8583_RSP_FIELD.FIELD_FORMAT
  is '���ʽ';
comment on column ISO8583_RSP_FIELD.DEFAULT_DATA
  is '��Ĭ������';
comment on column ISO8583_RSP_FIELD.MONDARY
  is '�Ƿ��ѡ,0-��,1-��';
alter table ISO8583_RSP_FIELD
  add constraint PK_ISO8583_RSP_FIELD primary key (BANK_TYPE, TRANS_TYPE, FIELD_ID);

drop table LOCAL_CARD;
create table LOCAL_CARD
(
  CARD_ID     VARCHAR(16) not null,
  CARD_NAME   VARCHAR(40) not null,
  CARD_NO_LEN INTEGER not null,
  CARD_TYPE   CHAR(1) default '0' not null
)
;
comment on table LOCAL_CARD
  is '���ؿ���';
comment on column LOCAL_CARD.CARD_ID
  is '����';
comment on column LOCAL_CARD.CARD_NAME
  is '������';
comment on column LOCAL_CARD.CARD_NO_LEN
  is '���ų���';
comment on column LOCAL_CARD.CARD_TYPE
  is '������';
create unique index LOCAL_CARD_IDX on LOCAL_CARD (CARD_ID);

drop table MARKET;
create table MARKET
(
  DEPT_NO     VARCHAR(15),
  MARKET_NO   INTEGER,
  MARKET_NAME VARCHAR(40)
)
;
comment on table MARKET
  is '�г���Ϣ��';
comment on column MARKET.DEPT_NO
  is '������';
comment on column MARKET.MARKET_NO
  is '�г���';
comment on column MARKET.MARKET_NAME
  is '�г�����';
create unique index MARKET_IDX on MARKET (MARKET_NO);

drop table MODULE;
create table MODULE
(
  MODULE_ID   INTEGER,
  MODULE_NAME VARCHAR(32),
  MSG_TYPE    INTEGER,
  PARA1       VARCHAR(15),
  PARA2       VARCHAR(10),
  PARA3       VARCHAR(10),
  PARA4       VARCHAR(10),
  PARA5       VARCHAR(10),
  PARA6       VARCHAR(10),
  RUN         INTEGER
)
;
comment on table MODULE
  is 'ģ���';
comment on column MODULE.MODULE_ID
  is 'ģ��ID';
comment on column MODULE.MODULE_NAME
  is 'ģ������(��������)';
comment on column MODULE.MSG_TYPE
  is '������Ϣ����';
comment on column MODULE.PARA1
  is '��������1';
comment on column MODULE.PARA2
  is '��������2';
comment on column MODULE.PARA3
  is '��������3';
comment on column MODULE.PARA4
  is '��������4';
comment on column MODULE.PARA5
  is '��������5';
comment on column MODULE.PARA6
  is '��������6';
comment on column MODULE.RUN
  is '�Ƿ����� 1-���� 0-������';
create unique index MODULE_IDX on MODULE (MODULE_ID);

drop table MY_CUSTOMER;
create table MY_CUSTOMER
(
  SHOP_NO       CHAR(15) not null,
  POS_NO        CHAR(15) not null,
  PAN           VARCHAR(19) not null,
  ACCT_NAME     VARCHAR(40),
  EXPIRE_DATE   CHAR(4),
  BANK_ID       CHAR(12),
  BANK_NAME     VARCHAR(20),
  REGISTER_DATE CHAR(8),
  REC_NO        INTEGER default 0 not null
)
;
comment on table MY_CUSTOMER
  is '�տ�����Ϣ��';
comment on column MY_CUSTOMER.SHOP_NO
  is '�̻���';
comment on column MY_CUSTOMER.POS_NO
  is '�ն˺�';
comment on column MY_CUSTOMER.PAN
  is '����';
comment on column MY_CUSTOMER.ACCT_NAME
  is '����';
comment on column MY_CUSTOMER.EXPIRE_DATE
  is '��Ч��';
comment on column MY_CUSTOMER.BANK_ID
  is '�����к�';
comment on column MY_CUSTOMER.BANK_NAME
  is '������';
comment on column MY_CUSTOMER.REGISTER_DATE
  is '�Ǽ�����';
comment on column MY_CUSTOMER.REC_NO
  is '���';
create unique index MY_CUSTOMER_IDX on MY_CUSTOMER (shop_no, pos_no, pan);

drop table OPER;
create table OPER
(
  OPER_NO      VARCHAR(8) not null,
  OPER_NAME    VARCHAR(40),
  REAL_ROLE_ID INTEGER,
  PASSWORD     CHAR(32),
  AUTH_CODE    CHAR(12),
  DEPT_NO      VARCHAR(15),
  DEPT_NAME    VARCHAR(40),
  CREATE_DATE  VARCHAR(20),
  IS_VALID     CHAR(1),
  LAST_LOGIN   VARCHAR(20),
  BRANCH_ID    CHAR(6),
  IS_ADMIN     CHAR(1),
  ENTER_DATE   CHAR(8),
  FAIL_TIMES   INTEGER,
  EFFECT_DATE  CHAR(8),
  MAC          CHAR(14),
  DEPT_DETAIL  VARCHAR(70)
)
;
comment on table OPER
  is '������ϵͳ����Ա��';
comment on column OPER.OPER_NO
  is '����ԱID';
comment on column OPER.OPER_NAME
  is '����Ա����';
comment on column OPER.REAL_ROLE_ID
  is '������ɫID';
comment on column OPER.PASSWORD
  is '����Ա����';
comment on column OPER.AUTH_CODE
  is '��Ȩ��';
comment on column OPER.DEPT_NO
  is '��������';
comment on column OPER.DEPT_NAME
  is '��������';
comment on column OPER.CREATE_DATE
  is '��������';
comment on column OPER.IS_VALID
  is '�Ƿ���Ч';
comment on column OPER.LAST_LOGIN
  is '�����¼ʱ��';
comment on column OPER.IS_ADMIN
  is '�Ƿ�admin';
comment on column OPER.ENTER_DATE
  is '��ǰ��¼����';
comment on column OPER.FAIL_TIMES
  is '����������';
comment on column OPER.EFFECT_DATE
  is '��Ч��������';
comment on column OPER.MAC
  is '�����¼���Ʋ���';
comment on column OPER.DEPT_DETAIL
  is '�����㼶��Ϣ';
alter table OPER
  add constraint PK_T_OPER_INFO primary key (OPER_NO);

drop table OPERATION_INFO;
create table OPERATION_INFO
(
  OPER_INDEX   INTEGER,
  OP_FLAG      CHAR(1),
  MODULE_NUM   INTEGER,
  INFO1_FORMAT CHAR(2),
  INFO1        VARCHAR(40),
  INFO2_FORMAT CHAR(2),
  INFO2        VARCHAR(40),
  INFO3_FORMAT CHAR(2),
  INFO3        VARCHAR(40),
  UPDATE_DATE  CHAR(8)
)
;
comment on table OPERATION_INFO
  is '������ʾ��Ϣ��';
comment on column OPERATION_INFO.OPER_INDEX
  is '������ʾ��Ϣ����';
comment on column OPERATION_INFO.OP_FLAG
  is '������ʶ';
comment on column OPERATION_INFO.MODULE_NUM
  is 'ģ����';
comment on column OPERATION_INFO.INFO1_FORMAT
  is '��ʾ��Ϣ1���ݸ�ʽ';
comment on column OPERATION_INFO.INFO1
  is '��ʾ��Ϣ1����';
comment on column OPERATION_INFO.INFO2_FORMAT
  is '��ʾ��Ϣ2���ݸ�ʽ';
comment on column OPERATION_INFO.INFO2
  is '��ʾ��Ϣ2����';
comment on column OPERATION_INFO.INFO3_FORMAT
  is '��ʾ��Ϣ3���ݸ�ʽ';
comment on column OPERATION_INFO.INFO3
  is '��ʾ��Ϣ3����';
comment on column OPERATION_INFO.UPDATE_DATE
  is '����������';
create unique index OPERATION_INFO_IDX on OPERATION_INFO (OPER_INDEX);

drop table OPERATION_TEMP;
create table OPERATION_TEMP
(
  OPER_INDEX   INTEGER,
  OP_FLAG      CHAR(1),
  MODULE_NUM   INTEGER,
  INFO1_FORMAT CHAR(2),
  INFO1        VARCHAR(40),
  INFO2_FORMAT CHAR(2),
  INFO2        VARCHAR(40),
  INFO3_FORMAT CHAR(2),
  INFO3        VARCHAR(40),
  UPDATE_DATE  CHAR(8)
)
;
comment on table OPERATION_TEMP
  is '��ʱ��ʾ��Ϣ��';
comment on column OPERATION_TEMP.OPER_INDEX
  is '������ʾ��Ϣ����';
comment on column OPERATION_TEMP.OP_FLAG
  is '��Ϣ������־';
comment on column OPERATION_TEMP.MODULE_NUM
  is 'ģ����';
comment on column OPERATION_TEMP.INFO1_FORMAT
  is '������ʾ1���ݸ�ʽ';
comment on column OPERATION_TEMP.INFO1
  is '������ʾ1����';
comment on column OPERATION_TEMP.INFO2_FORMAT
  is '������ʾ2���ݸ�ʽ';
comment on column OPERATION_TEMP.INFO2
  is '������ʾ2����';
comment on column OPERATION_TEMP.INFO3_FORMAT
  is '������ʾ3���ݸ�ʽ';
comment on column OPERATION_TEMP.INFO3
  is '������ʾ3����';
comment on column OPERATION_TEMP.UPDATE_DATE
  is '����������';
create unique index OPERATION_TEMP_IDX on OPERATION_TEMP (OPER_INDEX);

drop table OPERATION_LOG;
create table OPERATION_LOG
(
  ID	      INTEGER not null,
  MODULE_NAME VARCHAR(30),
  METHOD_DESC VARCHAR(20),
  KEY_ID      VARCHAR(20),
  KEY_NAME    VARCHAR(50),
  USER_NAME   VARCHAR(20),
  OPER_TIME   VARCHAR(30)
)
;
comment on table OPERATION_LOG
  is '������ϵͳ������־��';
comment on column OPERATION_LOG.ID
  is 'ϵͳ�Զ�ά��id';
comment on column OPERATION_LOG.MODULE_NAME
  is 'ģ������';
comment on column OPERATION_LOG.METHOD_DESC
  is '�������������ӡ�ɾ�����޸ĵ�';
comment on column OPERATION_LOG.KEY_ID
  is '���������¼�ؼ�ֵid���������Ա��';
comment on column OPERATION_LOG.KEY_NAME
  is '���������¼�ؼ�ֵ���ƣ��������Ա����';
comment on column OPERATION_LOG.USER_NAME
  is '����Ա����';
comment on column OPERATION_LOG.OPER_TIME
  is '����ʱ��';

drop table PAY_CLASS;
create table PAY_CLASS
(
  LIST_CLASS INTEGER,
  CLASS_NAME VARCHAR(30),
  CONTACTOR  VARCHAR(10),
  TELEPHONE  VARCHAR(26),
  ADDR       VARCHAR(48)
)
;
comment on table PAY_CLASS
  is '�˵������';
comment on column PAY_CLASS.LIST_CLASS
  is '�˵����';
comment on column PAY_CLASS.CLASS_NAME
  is '�������';
comment on column PAY_CLASS.CONTACTOR
  is '��ϵ��';
comment on column PAY_CLASS.TELEPHONE
  is '��ϵ�绰';
comment on column PAY_CLASS.ADDR
  is '��ַ';
create unique index PAY_CLASS_IDX on PAY_CLASS (LIST_CLASS);

drop table PAY_LIST;
create table PAY_LIST
(
  PSAM_NO    CHAR(16),
  LIST_CLASS INTEGER,
  LIST_TYPE  INTEGER,
  GEN_DATE   CHAR(8),
  LIST_NO    INTEGER,
  LIST_DATA  CHAR(200),
  AMOUNT     NUMERIC(12,2),
  PAY_DATE   CHAR(8),
  DOWN_FLAG  CHAR(1) default 'N',
  PAY_STATUS     CHAR(1) default 'N'
)
;
comment on table PAY_LIST
  is '֧���˵���';
comment on column PAY_LIST.PSAM_NO
  is '��ȫģ���';
comment on column PAY_LIST.LIST_CLASS
  is '�˵�����';
comment on column PAY_LIST.LIST_TYPE
  is '�˵�С��';
comment on column PAY_LIST.GEN_DATE
  is '�˵���������';
comment on column PAY_LIST.LIST_NO
  is '�˵���';
comment on column PAY_LIST.LIST_DATA
  is '�˵�����';
comment on column PAY_LIST.AMOUNT
  is '���';
comment on column PAY_LIST.PAY_DATE
  is '֧������';
comment on column PAY_LIST.DOWN_FLAG
  is '���ر�ʶ Y-������ N-δ����';
comment on column PAY_LIST.PAY_STATUS
  is '֧����ʶ Y-��֧�� N-δ֧��';

drop table PAY_TYPE;
create table PAY_TYPE
(
  LIST_CLASS INTEGER,
  LIST_TYPE  INTEGER,
  TYPE_NAME  VARCHAR(30),
  TRANS_CODE CHAR(8)
)
;
comment on table PAY_TYPE
  is '�˵�С���';
comment on column PAY_TYPE.LIST_CLASS
  is '�˵�����';
comment on column PAY_TYPE.LIST_TYPE
  is '�˵�С��';
comment on column PAY_TYPE.TYPE_NAME
  is '��������';
comment on column PAY_TYPE.TRANS_CODE
  is '���״���';
create unique index PAY_TYPE_IDX on PAY_TYPE (LIST_CLASS, LIST_TYPE);

drop table TDI_MATCH;
create table TDI_MATCH
(
  TRANS_DATA_INDEX        INTEGER,
  LOCAL_DATE CHAR(8),
  SHOP_NO    CHAR(15),
  POS_NO     CHAR(15),
  SEND_TIME  INTEGER,
  SYS_TRACE INTEGER
)
;
comment on table TDI_MATCH
  is '������������ƥ���';
comment on column TDI_MATCH.TRANS_DATA_INDEX
  is '��������������';
comment on column TDI_MATCH.LOCAL_DATE
  is '��������';
comment on column TDI_MATCH.SHOP_NO
  is '�̻���';
comment on column TDI_MATCH.POS_NO
  is '�ն˺�';
comment on column TDI_MATCH.SEND_TIME
  is '����ʱ�䣬�����жϽ����Ƿ�ʱ����';
comment on column TDI_MATCH.SYS_TRACE
  is 'ϵͳ��ˮ��';
create unique index TDI_MATCH_IDX on TDI_MATCH(SHOP_NO, POS_NO, SYS_TRACE);

drop table POSLS;
create table POSLS
(
  HOST_DATE      CHAR(8),
  HOST_TIME      CHAR(6),
  PAN            VARCHAR(19),
  AMOUNT         NUMERIC(12,2),
  CARD_TYPE      CHAR(1),
  TRANS_TYPE     INTEGER,
  BUSINESS_TYPE  INTEGER,
  RETRI_REF_NUM  CHAR(12),
  AUTH_CODE      CHAR(6),
  POS_NO         CHAR(15),
  SHOP_NO        CHAR(15),
  ACCOUNT2       VARCHAR(19),
  ADDI_AMOUNT    NUMERIC(12,2),
  BATCH_NO       INTEGER,
  PSAM_NO        CHAR(16),
  INVOICE        INTEGER,
  RETURN_CODE    CHAR(2),
  HOST_RET_CODE  VARCHAR(6),
  HOST_RET_MSG	 VARCHAR(40),
  CANCEL_FLAG    CHAR(1),
  RECOVER_FLAG   CHAR(1),
  POS_SETTLE     CHAR(1),
  POS_BATCH      CHAR(1),
  HOST_SETTLE    CHAR(1),
  SYS_TRACE     INTEGER,
  OLD_RETRI_REF_NUM 	CHAR(12),
  POS_DATE       CHAR(8),
  POS_TIME       CHAR(6),
  FINANCIAL_CODE VARCHAR(40),
  BUSINESS_CODE  VARCHAR(40),
  BANK_ID        VARCHAR(11),
  SETTLE_DATE    CHAR(8),
  OPER_NO        CHAR(4),
  MAC            CHAR(16),
  POS_TRACE      INTEGER,
  DEPT_DETAIL    VARCHAR(70)
)
;
comment on table POSLS
  is 'POS��ˮ��';
comment on column POSLS.HOST_DATE
  is '������������';
comment on column POSLS.HOST_TIME
  is '��������ʱ��';
comment on column POSLS.PAN
  is '���ţ�ת������';
comment on column POSLS.AMOUNT
  is '���׽��';
comment on column POSLS.CARD_TYPE
  is '������ 0-��ǿ� 1-���ǿ� 2-���⿨ 3-׼���ǿ�';
comment on column POSLS.TRANS_TYPE
  is '��������';
comment on column POSLS.BUSINESS_TYPE
  is 'ҵ�����ͣ����ڷ���ͳ�ơ����׶�ȿ���';
comment on column POSLS.RETRI_REF_NUM
  is '���ײο���';
comment on column POSLS.AUTH_CODE
  is '��Ȩ��';
comment on column POSLS.POS_NO
  is '�ն˺�';
comment on column POSLS.SHOP_NO
  is '�̻���';
comment on column POSLS.ACCOUNT2
  is '����2��ת�뿨��';
comment on column POSLS.ADDI_AMOUNT
  is '�����ѣ����ӽ��';
comment on column POSLS.BATCH_NO
  is '���κ�';
comment on column POSLS.PSAM_NO
  is '��ȫģ���';
comment on column POSLS.INVOICE
  is '��Ʊ��';
comment on column POSLS.RETURN_CODE
  is 'POS������';
comment on column POSLS.HOST_RET_CODE
  is '����������';
comment on column POSLS.HOST_RET_MSG
  is '����������Ϣ';  
comment on column POSLS.CANCEL_FLAG
  is '������ʶλ Y-�ѳ��� N-δ����';
comment on column POSLS.RECOVER_FLAG
  is '������ʶλ Y-�ѳ��� N-δ���� U-���������';
comment on column POSLS.POS_SETTLE
  is 'POS�����־λ Y-�ѽ��� N-δ����';
comment on column POSLS.POS_BATCH
  is 'POS�����ͱ�ʶλ';
comment on column POSLS.HOST_SETTLE
  is '���������ʶλ';
comment on column POSLS.SYS_TRACE
  is 'ϵͳ��ˮ��';
comment on column POSLS.OLD_RETRI_REF_NUM
  is 'ԭ���ײο���';
comment on column POSLS.POS_DATE
  is 'POS��������';
comment on column POSLS.POS_TIME
  is 'POS����ʱ��';
comment on column POSLS.FINANCIAL_CODE
  is '����Ӧ�ú�';
comment on column POSLS.BUSINESS_CODE
  is '����Ӧ�ú�';
comment on column POSLS.BANK_ID
  is '���б�ʶ��';
comment on column POSLS.SETTLE_DATE
  is '��������';
comment on column POSLS.OPER_NO
  is '����Ա��';
comment on column POSLS.MAC
  is 'MACֵ';
comment on column POSLS.POS_TRACE
  is '�ն���ˮ��';
comment on column POSLS.DEPT_DETAIL
  is '�����㼶��Ϣ';
create unique index POSLS_IDX on POSLS (SHOP_NO, POS_NO,POS_DATE, POS_TRACE);

drop table POS_KEY;
create table POS_KEY
(
  KEY_INDEX      INTEGER,
  MASTER_KEY     CHAR(32),
  MASTER_KEY_LMK CHAR(32),
  MASTER_CHK     CHAR(4),
  PIN_KEY        CHAR(32),
  MAC_KEY        CHAR(32),
  MAG_KEY        CHAR(32)
)
;
comment on table POS_KEY
  is '�ն���Կ��';
comment on column POS_KEY.KEY_INDEX
  is '��Կ����';
comment on column POS_KEY.MASTER_KEY
  is '�ַ����ն˵��ն�����Կ';
comment on column POS_KEY.MASTER_KEY_LMK
  is 'LKM���ܺ���ն�����Կ';
comment on column POS_KEY.MASTER_CHK
  is '�ն�����ԿУ��ֵ';
comment on column POS_KEY.PIN_KEY
  is 'pin��Կ';
comment on column POS_KEY.MAC_KEY
  is 'mac��Կ';
comment on column POS_KEY.MAG_KEY
  is 'mag��Կ';
create unique index POS_KEY_IDX on POS_KEY (KEY_INDEX);

drop table PRINT_DATA;
create table PRINT_DATA
(
  DATA_INDEX   INTEGER,
  DATA_NAME    VARCHAR(40),
  DATA_EXAMPLE VARCHAR(40)
)
;
comment on table PRINT_DATA
  is '��ӡ�������';
comment on column PRINT_DATA.DATA_INDEX
  is '��������';
comment on column PRINT_DATA.DATA_NAME
  is '��������';
comment on column PRINT_DATA.DATA_EXAMPLE
  is '���ݸ�ʽ����';
create unique index PRINT_DATA_IDX on PRINT_DATA (DATA_INDEX);

drop table PRINT_INFO;
create table PRINT_INFO
(
  REC_NO      INTEGER,
  INFO        VARCHAR(60),
  DATA_INDEX  INTEGER,
  UPDATE_DATE CHAR(8)
)
;
comment on table PRINT_INFO
  is '��ӡ��¼��';
comment on column PRINT_INFO.REC_NO
  is '��¼��';
comment on column PRINT_INFO.INFO
  is '������Ϣ';
comment on column PRINT_INFO.DATA_INDEX
  is '��������';
comment on column PRINT_INFO.UPDATE_DATE
  is '��������';
create unique index PRINT_INFO_IDX  on PRINT_INFO (REC_NO);

drop table PRINT_MODULE;
create table PRINT_MODULE
(
  MODULE_ID  INTEGER,
  DESCRIBE VARCHAR(40),
  PRINT_NUM  INTEGER,
  TITLE1     INTEGER default 0,
  TITLE2     INTEGER default 0,
  TITLE3     INTEGER default 0,
  SIGN1      INTEGER default 0,
  SIGN2      INTEGER default 0,
  SIGN3      INTEGER default 0,
  REC_NUM    INTEGER,
  REC_NO     VARCHAR(80)
)
;
comment on table PRINT_MODULE
  is '��ӡƾ��ģ���';
comment on column PRINT_MODULE.MODULE_ID
  is 'ģ����';
comment on column PRINT_MODULE.DESCRIBE
  is '����';
comment on column PRINT_MODULE.PRINT_NUM
  is '��ӡ����';
comment on column PRINT_MODULE.TITLE1
  is '����1';
comment on column PRINT_MODULE.TITLE2
  is '����2';
comment on column PRINT_MODULE.TITLE3
  is '����3';
comment on column PRINT_MODULE.SIGN1
  is '���1';
comment on column PRINT_MODULE.SIGN2
  is '���2';
comment on column PRINT_MODULE.SIGN3
  is '���3';
comment on column PRINT_MODULE.REC_NUM
  is '��¼��';
comment on column PRINT_MODULE.REC_NO
  is '��¼��';
create unique index PRINT_MODULE_IDX on PRINT_MODULE (MODULE_ID);

drop table PSAM_PARA;
create table PSAM_PARA
(
  MODULE_ID          INTEGER,
  DESCRIBE          VARCHAR(20),
  PIN_KEY_INDEX      INTEGER,
  MAC_KEY_INDEX      INTEGER,
  FSK_TELE_NUM       INTEGER,
  FSK_TELE_NO1       VARCHAR(15),
  FSK_TELE_NO2       VARCHAR(15),
  FSK_TELE_NO3       VARCHAR(15),
  FSK_DOWN_TELE_NUM  INTEGER,
  FSK_DOWN_TELE_NO1  VARCHAR(15),
  FSK_DOWN_TELE_NO2  VARCHAR(15),
  FSK_DOWN_TELE_NO3  VARCHAR(15),
  HDLC_TELE_NUM      INTEGER,
  HDLC_TELE_NO1      VARCHAR(15),
  HDLC_TELE_NO2      VARCHAR(15),
  HDLC_TELE_NO3      VARCHAR(15),
  HDLC_DOWN_TELE_NUM INTEGER,
  HDLC_DOWN_TELE_NO1 VARCHAR(15),
  HDLC_DOWN_TELE_NO2 VARCHAR(15),
  HDLC_DOWN_TELE_NO3 VARCHAR(15),
  FSKBAK_TELE_NUM    INTEGER,
  FSKBAK_TELE_NO1    VARCHAR(15),
  FSKBAK_TELE_NO2    VARCHAR(15),
  FSKBAK_TELE_NO3    VARCHAR(15),
  HDLCBAK_TELE_NUM   INTEGER,
  HDLCBAK_TELE_NO1   VARCHAR(15),
  HDLCBAK_TELE_NO2   VARCHAR(15),
  HDLCBAK_TELE_NO3   VARCHAR(15)
)
;
comment on table PSAM_PARA
  is '����ģ���';
comment on column PSAM_PARA.MODULE_ID
  is '����ģ����';
comment on column PSAM_PARA.DESCRIBE
  is '����ģ��˵��';
comment on column PSAM_PARA.PIN_KEY_INDEX
  is 'Pin��Կ����';
comment on column PSAM_PARA.MAC_KEY_INDEX
  is 'Mac��Կ����';
comment on column PSAM_PARA.FSK_TELE_NUM
  is 'fsk�绰������';
comment on column PSAM_PARA.FSK_TELE_NO1
  is 'fsk�绰����1';
comment on column PSAM_PARA.FSK_TELE_NO2
  is 'fsk�绰����2';
comment on column PSAM_PARA.FSK_TELE_NO3
  is 'fsk�绰����3';
comment on column PSAM_PARA.FSK_DOWN_TELE_NUM
  is 'fsk���ص绰��';
comment on column PSAM_PARA.FSK_DOWN_TELE_NO1
  is 'fsk���ص绰1';
comment on column PSAM_PARA.FSK_DOWN_TELE_NO2
  is 'fsk���ص绰2';
comment on column PSAM_PARA.FSK_DOWN_TELE_NO3
  is 'fsk���ص绰3';
comment on column PSAM_PARA.HDLC_TELE_NUM
  is 'HDLC�绰��';
comment on column PSAM_PARA.HDLC_TELE_NO1
  is 'HDLC�绰����1';
comment on column PSAM_PARA.HDLC_TELE_NO2
  is 'HDLC�绰����2';
comment on column PSAM_PARA.HDLC_TELE_NO3
  is 'HDLC�绰����3';
comment on column PSAM_PARA.HDLC_DOWN_TELE_NUM
  is 'HDLC���ص绰��';
comment on column PSAM_PARA.HDLC_DOWN_TELE_NO1
  is 'HDLC���ص绰����1';
comment on column PSAM_PARA.HDLC_DOWN_TELE_NO2
  is 'HDLC���ص绰����2';
comment on column PSAM_PARA.HDLC_DOWN_TELE_NO3
  is 'HDLC���ص绰����3';
comment on column PSAM_PARA.FSKBAK_TELE_NUM
  is 'fsk���õ绰��';
comment on column PSAM_PARA.FSKBAK_TELE_NO1
  is 'fsk���õ绰����1';
comment on column PSAM_PARA.FSKBAK_TELE_NO2
  is 'fsk���õ绰����2';
comment on column PSAM_PARA.FSKBAK_TELE_NO3
  is 'fsk���õ绰����3';
comment on column PSAM_PARA.HDLCBAK_TELE_NUM
  is 'HDLC���õ绰��';
comment on column PSAM_PARA.HDLCBAK_TELE_NO1
  is 'HDLC���õ绰����1';
comment on column PSAM_PARA.HDLCBAK_TELE_NO2
  is 'HDLC���õ绰����2';
comment on column PSAM_PARA.HDLCBAK_TELE_NO3
  is 'HDLC���õ绰����3';
create unique index PSAM_PARA_IDX on PSAM_PARA (MODULE_ID);

drop table QUERY_CONDITION;
create table QUERY_CONDITION
(
  PSAM_NO    CHAR(16),
  PAN        VARCHAR(19),
  BEGIN_DATE CHAR(8),
  END_DATE   CHAR(8),
  SHOP_NO    CHAR(16),
  POS_NO     CHAR(16),
  AMOUNT     NUMERIC(12,2)
)
;
comment on table QUERY_CONDITION
  is '��ѯ���������';
comment on column QUERY_CONDITION.PSAM_NO
  is '��ȫģ���';
comment on column QUERY_CONDITION.PAN
  is '����';
comment on column QUERY_CONDITION.BEGIN_DATE
  is '��ʼ����';
comment on column QUERY_CONDITION.END_DATE
  is '��������';
comment on column QUERY_CONDITION.SHOP_NO
  is '�̻���';
comment on column QUERY_CONDITION.POS_NO
  is '�ն˺�';
comment on column QUERY_CONDITION.AMOUNT
  is '���';
create unique index QUERY_CONDITION_IDX on QUERY_CONDITION (PSAM_NO);

drop table QUERY_RESULT;
create table QUERY_RESULT
(
  PSAM_NO      CHAR(16),
  POS_TRACE   INTEGER,
  RESULT VARCHAR(1024)
)
;
comment on table QUERY_RESULT
  is '��ѯ��������';
comment on column QUERY_RESULT.PSAM_NO
  is '��ȫģ���';
comment on column QUERY_RESULT.POS_TRACE
  is 'POS��ˮ��';
comment on column QUERY_RESULT.RESULT
  is '��ѯ���';
create unique index QUERY_RESULT_IDX on QUERY_RESULT (PSAM_NO, POS_TRACE);

drop table REAL_ROLE;
create table REAL_ROLE
(
  REAL_ROLE_ID INTEGER not null,
  ROLE_NAME  VARCHAR(20),
  DEPT_NO    VARCHAR(15)
)
;
comment on table REAL_ROLE
  is 'ʵ�ʽ�ɫ��';
comment on column REAL_ROLE.REAL_ROLE_ID
  is '��ɫID��';
comment on column REAL_ROLE.ROLE_NAME
  is '��ɫ����';
comment on column REAL_ROLE.DEPT_NO
  is '��ɫ��������';
alter table REAL_ROLE
  add constraint PK_REAL_ROLE primary key (REAL_ROLE_ID);

drop table REAL_SUB;
create table REAL_SUB
(
  REAL_ROLE_ID INTEGER not null,
  SUB_ROLE_ID  INTEGER not null,
  DEPT_NO    VARCHAR(15)
)
;
comment on table REAL_SUB
  is 'ʵ�ʽ�ɫ�ӽ�ɫ������';
comment on column REAL_SUB.REAL_ROLE_ID
  is 'ʵ�ʽ�ɫID��';
comment on column REAL_SUB.SUB_ROLE_ID
  is '�ӽ�ɫID��';
comment on column REAL_SUB.DEPT_NO
  is '��ɫ��������';
alter table REAL_SUB
  add constraint PK_REAL_SUB primary key (REAL_ROLE_ID, SUB_ROLE_ID);
create index REAL_SUB_IDX1 on REAL_SUB (SUB_ROLE_ID);
create index REAL_SUB_IDX2 on REAL_SUB (REAL_ROLE_ID);

drop table REGISTER_CARD;
create table REGISTER_CARD
(
  SHOP_NO       CHAR(15),
  POS_NO        CHAR(15),
  PAN           VARCHAR(19),
  ACCT_NAME     VARCHAR(40),
  EXPIRE_DATE   CHAR(4),
  REGISTER_DATE CHAR(8),
  REGISTER_TIME CHAR(6),
  BANK_NAME     VARCHAR(20),
  TRANSTYPE     CHAR(1),
  OPER_NO       VARCHAR(16),
  STATUS        INTEGER default 0
)
;
comment on table REGISTER_CARD
  is '���󶨱�';
comment on column REGISTER_CARD.SHOP_NO
  is '�̻���';
comment on column REGISTER_CARD.POS_NO
  is '�ն˺�';
comment on column REGISTER_CARD.PAN
  is '����';
comment on column REGISTER_CARD.ACCT_NAME
  is '�û���';
comment on column REGISTER_CARD.EXPIRE_DATE
  is '����Ч��';
comment on column REGISTER_CARD.REGISTER_DATE
  is '������';
comment on column REGISTER_CARD.REGISTER_TIME
  is '��ʱ��';
comment on column REGISTER_CARD.BANK_NAME
  is '��������';
comment on column REGISTER_CARD.TRANSTYPE
  is '��������';
comment on column REGISTER_CARD.OPER_NO
  is '����Ա��';
comment on column REGISTER_CARD.STATUS
  is '�Ƿ����� 0-δ���� 1-����';
create unique index REGISTER_CARD_IDX on REGISTER_CARD (SHOP_NO, POS_NO, TRANSTYPE);

drop table RET_DESC;
create table RET_DESC
(
  TRANS_TYPE   INTEGER not null,
  FIELD_NAME   VARCHAR(80),
  FIELD_FORMAT VARCHAR(150),
  STATUS       CHAR(1) default '1' not null
)
;
comment on table RET_DESC
  is '������Ϣ���ñ�';
comment on column RET_DESC.TRANS_TYPE
  is '��������';
comment on column RET_DESC.FIELD_NAME
  is 'Ҫ��ʾ��app�ֶ�,�Է�Ÿ���';
comment on column RET_DESC.FIELD_FORMAT
  is '��װFIELD_NAME�ĸ�ʽ,��Ӧapp�ֶ���%s��ʾ';
comment on column RET_DESC.STATUS
  is '״̬λ,1-��Ч��0-��Ч';
create unique index RET_DESC_IDX on RET_DESC (TRANS_TYPE);

drop table SHOP;
create table SHOP
(
  SHOP_NO            CHAR(15) not null,
  MARKET_NO          INTEGER default 0,
  SHOP_NAME          VARCHAR(40),
  ACQ_BANK           CHAR(11),
  CONTACTOR          VARCHAR(10),
  TELEPHONE          VARCHAR(25),
  ADDR               VARCHAR(47),
  FEE                INTEGER,
  FAX_NUM            VARCHAR(25),
  SIGN_FLAG          INTEGER,
  SIGN_DATE          CHAR(8),
  UNSIGN_DATE        CHAR(8),
  DEPT_NO            CHAR(15),
  ACQ_BANK_CODE      VARCHAR(11),
  PROCEDURE_FEE      VARCHAR(15),
  BALANCE_DAY        VARCHAR(10),
  PROCEDURE_DAY      VARCHAR(10),
  LAWPER_NAME        VARCHAR(30),
  LAWPER_CERTIFICATE VARCHAR(30),
  REGISTER_CODE      VARCHAR(30),
  BUS_AREA           VARCHAR(40),
  FORM_CODE          VARCHAR(30),
  TAX_CODE           VARCHAR(30),
  ACQ_BANK_NAME      VARCHAR(60),
  IS_BLACK           CHAR(1),
  ACQ_NAME           VARCHAR(30),
  PAN_TYPE           CHAR(1),
  ACQ_PLACE          VARCHAR(30),
  ACQ_CITY           VARCHAR(30),
  ACQ_DEAFBANK_NAME  VARCHAR(50),
  ACQ_MANMOBILE      CHAR(11),
  ADD_AMOUNT         NUMERIC(12,2) default 0.00,
  DEPT_DETAIL        VARCHAR(70),
  MCC_CODE           CHAR(4) default '0000' 
)
;
comment on table SHOP
  is '�̻����ϱ�';
comment on column SHOP.SHOP_NO
  is '�̻���';
comment on column SHOP.MARKET_NO
  is '�г�����';
comment on column SHOP.SHOP_NAME
  is '�̻�����';
comment on column SHOP.ACQ_BANK
  is '�յ���';
comment on column SHOP.CONTACTOR
  is '��ϵ��';
comment on column SHOP.TELEPHONE
  is '�绰';
comment on column SHOP.ADDR
  is '��ַ';
comment on column SHOP.FEE
  is '�������ۿ���';
comment on column SHOP.FAX_NUM
  is '�������';
comment on column SHOP.SIGN_FLAG
  is 'ǩԼ��־';
comment on column SHOP.SIGN_DATE
  is 'ǩԼ����';
comment on column SHOP.UNSIGN_DATE
  is '��������';
comment on column SHOP.DEPT_NO
  is '��������';
comment on column SHOP.ACQ_BANK_CODE
  is '�������˺�';
comment on column SHOP.PROCEDURE_FEE
  is '�����ѷ���';
comment on column SHOP.BALANCE_DAY
  is '�ʽ��������';
comment on column SHOP.PROCEDURE_DAY
  is ' �����ѽ�������';
comment on column SHOP.LAWPER_NAME
  is '��������';
comment on column SHOP.LAWPER_CERTIFICATE
  is '����֤������';
comment on column SHOP.REGISTER_CODE
  is '	Ӫҵִ��ע����';
comment on column SHOP.BUS_AREA
  is ' 	��Ӫ��Χ';
comment on column SHOP.FORM_CODE
  is ' 	��֯��������֤';
comment on column SHOP.TAX_CODE
  is ' 	˰��Ǽ�֤����';
comment on column SHOP.ACQ_BANK_NAME
  is '�յ�������';
comment on column SHOP.IS_BLACK
  is '�Ƿ�������̻�';
comment on column SHOP.ACQ_NAME
  is '�տ�������';
comment on column SHOP.PAN_TYPE
  is '�˻�����(0-���ˣ�1-��ҵ)';
comment on column SHOP.ACQ_PLACE
  is '��������(�б�ѡ��ʡ�ݻ�ֱϽ��)';
comment on column SHOP.ACQ_CITY
  is '��������(30Bytes���ֹ�����)';
comment on column SHOP.ACQ_DEAFBANK_NAME
  is '֧�����ƣ�50Bytes����';
comment on column SHOP.ACQ_MANMOBILE
  is '�տ����ֻ���(11Bytes)';
comment on column SHOP.ADD_AMOUNT
  is '���ʽ���λԪ�������̻�����ʱ���ʽ��Ϊ0(�������޸�)��';
comment on column SHOP.DEPT_DETAIL
  is '�����㼶��Ϣ';
comment on column SHOP.MCC_CODE
  is '�̻����ͣ���ӦMCC��';
create unique index SHOP_IDX on SHOP (SHOP_NO);

drop table SHOP_TYPE;
create table SHOP_TYPE
(
  MCC_CODE CHAR(4),
  DESCRIBE VARCHAR(40)
)
;
comment on table SHOP_TYPE
  is '�̻����ͱ�';
comment on column SHOP_TYPE.MCC_CODE
  is 'MCC��';
comment on column SHOP_TYPE.DESCRIBE
  is 'MCC˵��';

drop table SHORT_MESSAGE;
create table SHORT_MESSAGE
(
  REC_NO       INTEGER,
  MSG_TITLE   VARCHAR(30),
  MSG_CONTENT VARCHAR(140),
  VALID_DATE  CHAR(8)
)
;
comment on table SHORT_MESSAGE
  is '���Ź����';
comment on column SHORT_MESSAGE.REC_NO
  is '���ż�¼��';
comment on column SHORT_MESSAGE.MSG_TITLE
  is '���ű���';
comment on column SHORT_MESSAGE.MSG_CONTENT
  is '��������';
comment on column SHORT_MESSAGE.VALID_DATE
  is '��Ч��ֹ����';
create unique index SHORT_MESSAGE_IDX on SHORT_MESSAGE (REC_NO);

drop table STATIC_MENU_CFG;
create table STATIC_MENU_CFG
(
  STATIC_MENU_ID    INTEGER not null,
  DOWN_STATIC_MENU  CHAR(1) default 'N',
  STATIC_MENU_RECNO INTEGER default 0,
  PSAM_NO           CHAR(16)
)
;
comment on table STATIC_MENU_CFG
  is '��̬�˵����ñ�';
comment on column STATIC_MENU_CFG.STATIC_MENU_ID
  is '��̬�˵�ID';
comment on column STATIC_MENU_CFG.STATIC_MENU_RECNO
  is 'Ŀǰ���صĲ˵����';
comment on column STATIC_MENU_CFG.PSAM_NO
  is '��ȫģ���';

drop table STAT_LINE;
create table STAT_LINE
(
  SHOP_NO        CHAR(15) not null,
  POS_NO         CHAR(15) not null,
  TRANS_DATE     VARCHAR(8) not null,
  MARKET_NO      INTEGER default 0,
  BIND_CARD_NO   VARCHAR(19),
  PUR_COUNT      INTEGER,
  PUR_AMOUNT     NUMERIC(12,2),
  PUR_FEE        NUMERIC(12,2),
  PAY_IN_COUNT   INTEGER,
  PAY_IN_AMOUNT  NUMERIC(12,2),
  PAY_IN_FEE     NUMERIC(12,2),
  PAY_OUT_COUNT  INTEGER,
  PAY_OUT_AMOUNT NUMERIC(12,2),
  PAY_OUT_FEE    NUMERIC(12,2),
  TYPE_1_COUNT   INTEGER,
  TYPE_1_AMOUNT  NUMERIC(12,2),
  TYPE_1_FEE     NUMERIC(12,2),
  TYPE_2_COUNT   INTEGER,
  TYPE_2_AMOUNT  NUMERIC(12,2),
  TYPE_2_FEE     NUMERIC(12,2),
  TYPE_3_COUNT   INTEGER,
  TYPE_3_AMOUNT  NUMERIC(12,2),
  TYPE_3_FEE     NUMERIC(12,2),
  RESERVE_1      VARCHAR(50),
  DEPT_DETAIL    VARCHAR(70),
  DEPT_NAME      VARCHAR(45),
  SHOP_NAME      VARCHAR(40),
  MARKET_NAME    VARCHAR(40),
  DEL_FLAG       INTEGER default 0
)
;
comment on table STAT_LINE
  is '���׻��ܱ�';
comment on column STAT_LINE.SHOP_NO
  is '�̻���';
comment on column STAT_LINE.POS_NO
  is '�ն˺�';
comment on column STAT_LINE.TRANS_DATE
  is '��������';
comment on column STAT_LINE.MARKET_NO
  is '�����г�';
comment on column STAT_LINE.BIND_CARD_NO
  is '�󶨿��� ';
comment on column STAT_LINE.PUR_COUNT
  is '���ѱ���';
comment on column STAT_LINE.PUR_AMOUNT
  is '���ѽ��';
comment on column STAT_LINE.PUR_FEE
  is '����������';
comment on column STAT_LINE.PAY_IN_COUNT
  is '�տ����';
comment on column STAT_LINE.PAY_IN_AMOUNT
  is '�տ���';
comment on column STAT_LINE.PAY_IN_FEE
  is '�տ�������';
comment on column STAT_LINE.PAY_OUT_COUNT
  is '�������';
comment on column STAT_LINE.PAY_OUT_AMOUNT
  is '������';
comment on column STAT_LINE.PAY_OUT_FEE
  is '����������';
comment on column STAT_LINE.TYPE_1_COUNT
  is 'Ԥ���������ͽ��ױ���';
comment on column STAT_LINE.TYPE_1_AMOUNT
  is 'Ԥ���������ͽ��׽��';
comment on column STAT_LINE.TYPE_1_FEE
  is 'Ԥ���������ͽ���������';
comment on column STAT_LINE.TYPE_2_COUNT
  is 'Ԥ���������ͽ��ױ���';
comment on column STAT_LINE.TYPE_2_AMOUNT
  is 'Ԥ���������ͽ��׽��';
comment on column STAT_LINE.TYPE_2_FEE
  is 'Ԥ���������ͽ���������';
comment on column STAT_LINE.TYPE_3_COUNT
  is 'Ԥ���������ͽ��ױ���';
comment on column STAT_LINE.TYPE_3_AMOUNT
  is 'Ԥ���������ͽ��׽��';
comment on column STAT_LINE.TYPE_3_FEE
  is 'Ԥ���������ͽ���������';
comment on column STAT_LINE.RESERVE_1
  is 'Ԥ���ֶ�';
comment on column STAT_LINE.DEPT_DETAIL
  is '�����㼶��Ϣ';
comment on column STAT_LINE.DEPT_NAME
  is '��������';
comment on column STAT_LINE.SHOP_NAME
  is '�̻�����';
comment on column STAT_LINE.MARKET_NAME
  is '�г�����';
comment on column STAT_LINE.DEL_FLAG
  is '�ն�ɾ����ʶ 0-�ն�δɾ�� 1-�ն���ɾ��';
alter table STAT_LINE
  add constraint PK_T_STAT_LINE primary key (SHOP_NO, POS_NO, TRANS_DATE);
create index STAT_LINE_IDX1 on STAT_LINE (DEPT_DETAIL);

drop table SUB_ROLE;
create table SUB_ROLE
(
  SUB_ROLE_ID   INTEGER not null,
  SYS_ID       VARCHAR(10),
  SUB_ROLE_NAME VARCHAR(20),
  DEPT_NO     VARCHAR(15)
)
;
comment on table SUB_ROLE
  is '��ϵͳ��ɫ��';
comment on column SUB_ROLE.SUB_ROLE_ID
  is '�ӽ�ɫID';
comment on column SUB_ROLE.SYS_ID
  is '��ϵͳID';
comment on column SUB_ROLE.SUB_ROLE_NAME
  is '��ɫ����';
comment on column SUB_ROLE.DEPT_NO
  is '������';
alter table SUB_ROLE
  add constraint PK_SUB_ROLE primary key (SUB_ROLE_ID);
create index SUB_ROLE_IDX on SUB_ROLE (SYS_ID);

drop table SUB_ROLE_FUNC;
create table SUB_ROLE_FUNC
(
  MODULE_ID  INTEGER not null,
  SUB_ROLE_ID INTEGER not null,
  BUTTON_MAP VARCHAR(20),
  DEPT_NO   VARCHAR(15)
)
;
comment on table SUB_ROLE_FUNC
  is '�ӽ�ɫ���ܱ�';
comment on column SUB_ROLE_FUNC.MODULE_ID
  is 'ģ��ID';
comment on column SUB_ROLE_FUNC.SUB_ROLE_ID
  is '�ӽ�ɫID';
comment on column SUB_ROLE_FUNC.BUTTON_MAP
  is '����λͼ�����ڸý�ɫ�Ƿ�߱�����ɾ���ġ���Ȩ��';
comment on column SUB_ROLE_FUNC.DEPT_NO
  is '��������';
alter table SUB_ROLE_FUNC
  add constraint PK_SUB_ROLE_FUNC primary key (MODULE_ID, SUB_ROLE_ID);
create index SUB_ROLE_FUNC_IDX1	on SUB_ROLE_FUNC (MODULE_ID);
create index SUB_ROLE_FUNC_IDX2	on SUB_ROLE_FUNC (SUB_ROLE_ID);

drop table SUB_SYS;
create table SUB_SYS
(
  SYS_ID   VARCHAR(10) not null,
  SYS_NAME VARCHAR(20)
)
;
comment on table SUB_SYS
  is '��ϵͳ�����';
comment on column SUB_SYS.SYS_ID
  is 'ϵͳID';
comment on column SUB_SYS.SYS_NAME
  is 'ϵͳ����';
alter table SUB_SYS
  add constraint PK_SUBSYS primary key (SYS_ID);

drop table SYSTEM_PARAMETER;
create table SYSTEM_PARAMETER
(
  CUR_KEY_INDEX  INTEGER,
  BATCH_NO       INTEGER,
  SYS_TRACE     INTEGER not null
)
;
comment on table SYSTEM_PARAMETER
  is 'ϵͳ������';
comment on column SYSTEM_PARAMETER.CUR_KEY_INDEX
  is '��ǰ��Կ������';
comment on column SYSTEM_PARAMETER.BATCH_NO
  is '��ǰ���κ�';
comment on column SYSTEM_PARAMETER.SYS_TRACE
  is '��ǰϵͳ��ˮ��';

drop table TCPCOM_PID;
create table TCPCOM_PID
(
  IP      CHAR(15),
  PID     INTEGER,
  HOST_NO INTEGER
)
;
comment on table TCPCOM_PID
  is '���̵ǼǱ�';
comment on column TCPCOM_PID.IP
  is 'IP��ַ';
comment on column TCPCOM_PID.PID
  is '���̺�';
comment on column TCPCOM_PID.HOST_NO
  is '���������';

drop table TERMINAL;
create table TERMINAL
(
  SHOP_NO         CHAR(15) not null,
  POS_NO          CHAR(15) not null,
  PSAM_NO         CHAR(16) not null,
  TELEPHONE       VARCHAR(15),
  TERM_MODULE     INTEGER,
  PSAM_MODULE     INTEGER,
  APP_TYPE        INTEGER,
  DESCRIBE        VARCHAR(20),
  POS_TYPE        VARCHAR(40),
  ADDRESS         VARCHAR(40),
  PUT_DATE        CHAR(8),
  CUR_TRACE       INTEGER default 1,
  IP              CHAR(15),
  PORT            INTEGER,
  DOWN_MENU       CHAR(1),
  DOWN_TERM       CHAR(1),
  DOWN_PSAM       CHAR(1),
  DOWN_PRINT      CHAR(1),
  DOWN_OPERATE    CHAR(1),
  DOWN_FUNCTION   CHAR(1),
  DOWN_ERROR      CHAR(1),
  DOWN_ALL        CHAR(1),
  DOWN_PAYLIST    CHAR(1),
  MENU_RECNO      INTEGER default 0,
  PRINT_RECNO     INTEGER default 0,
  OPERATE_RECNO   INTEGER default 0,
  FUNCTION_RECNO  INTEGER default 0,
  ERROR_RECNO     INTEGER default 0,
  ALL_TRANSTYPE   INTEGER default 3,
  TERM_BITMAP     CHAR(8),
  PSAM_BITMAP     CHAR(8),
  PRINT_BITMAP    CHAR(64),
  OPERATE_BITMAP  CHAR(64),
  FUNCTION_BITMAP CHAR(64),
  ERROR_BITMAP    CHAR(64),
  MSG_RECNUM      INTEGER default 0,
  MSG_RECNO       VARCHAR(256),
  FIRST_PAGE      INTEGER default 0,
  STATUS          INTEGER default 0,
  CUR_BATCH       INTEGER default 1
)
;
comment on table TERMINAL
  is '�ն˱�';
comment on column TERMINAL.SHOP_NO
  is '�̻���';
comment on column TERMINAL.POS_NO
  is '�ն˺�';
comment on column TERMINAL.PSAM_NO
  is '��ȫģ���';
comment on column TERMINAL.TELEPHONE
  is '�󶨵绰��00000000��ʾ�����е绰����󶨼��';
comment on column TERMINAL.TERM_MODULE
  is '�ն�ģ��';
comment on column TERMINAL.PSAM_MODULE
  is '��ȫ����ģ��';
comment on column TERMINAL.APP_TYPE
  is 'Ӧ������';
comment on column TERMINAL.DESCRIBE
  is '˵��������';
comment on column TERMINAL.POS_TYPE
  is '�ն��ͺ�';
comment on column TERMINAL.ADDRESS
  is '��װ��ַ';
comment on column TERMINAL.PUT_DATE
  is '��װ����';
comment on column TERMINAL.CUR_TRACE
  is '��ǰ��ˮ��';
comment on column TERMINAL.IP
  is '����IP';
comment on column TERMINAL.PORT
  is '����˿�';
comment on column TERMINAL.DOWN_MENU
  is '�Ƿ���Ҫ���ز˵�';
comment on column TERMINAL.DOWN_TERM
  is '�Ƿ���Ҫ�����ն˲���';
comment on column TERMINAL.DOWN_PSAM
  is '�Ƿ���Ҫ���ذ�ȫ����';
comment on column TERMINAL.DOWN_PRINT
  is '�Ƿ���Ҫ���ش�ӡģ��';
comment on column TERMINAL.DOWN_OPERATE
  is '�Ƿ���Ҫ���ز�����ʾ';
comment on column TERMINAL.DOWN_FUNCTION
  is '�Ƿ���Ҫ���ع�����ʾ';
comment on column TERMINAL.DOWN_ERROR
  is '�Ƿ���Ҫ���ش�����ʾ';
comment on column TERMINAL.DOWN_ALL
  is '�Ƿ���Ҫ����ȫ������';
comment on column TERMINAL.DOWN_PAYLIST
  is '�Ƿ���Ҫ�����˵�';
comment on column TERMINAL.MENU_RECNO
  is '�����ز˵���¼��';
comment on column TERMINAL.PRINT_RECNO
  is '�����ش�ӡģ���¼��';
comment on column TERMINAL.OPERATE_RECNO
  is '�����ز�����ʾ��¼��';
comment on column TERMINAL.FUNCTION_RECNO
  is '�����ع�����ʾ��¼��';
comment on column TERMINAL.ERROR_RECNO
  is '�����ش�����ʾ��¼��';
comment on column TERMINAL.ALL_TRANSTYPE
  is '��ǰ���ع���';
comment on column TERMINAL.TERM_BITMAP
  is '�ն˲�������λͼ';
comment on column TERMINAL.PSAM_BITMAP
  is '��ȫ��������λͼ';
comment on column TERMINAL.PRINT_BITMAP
  is '��ӡλͼ';
comment on column TERMINAL.OPERATE_BITMAP
  is '������ʾλͼ';
comment on column TERMINAL.FUNCTION_BITMAP
  is '������ʾλͼ';
comment on column TERMINAL.ERROR_BITMAP
  is '������ʾλͼ';
comment on column TERMINAL.MSG_RECNUM
  is '��Ҫ���ض��ż�¼��';
comment on column TERMINAL.MSG_RECNO
  is '��Ҫ���ض��ż�¼�����';
comment on column TERMINAL.FIRST_PAGE
  is '��Ҫ������ҳ��Ϣ��¼��';
comment on column TERMINAL.STATUS
  is '״̬,0ͣ��,1-����';
comment on column TERMINAL.CUR_BATCH
  is '��ǰ���κ�';
create index TERMINAL_IDX on TERMINAL (PSAM_NO);

drop table TERMINAL_OPER;
create table TERMINAL_OPER
(
  SHOP_NO      CHAR(15),
  POS_NO       CHAR(15),
  OPER_NO      CHAR(4),
  OPER_PWD     CHAR(6),
  OPER_NAME    CHAR(20),
  DEL_FLAG     INTEGER,
  LOGIN_STATUS INTEGER
)
;
comment on table TERMINAL_OPER
  is '�ն˲���Ա��';
comment on column TERMINAL_OPER.SHOP_NO
  is '�̻���';
comment on column TERMINAL_OPER.POS_NO
  is '�ն˺�';
comment on column TERMINAL_OPER.OPER_NO
  is '����Ա��';
comment on column TERMINAL_OPER.OPER_PWD
  is '����Ա����';
comment on column TERMINAL_OPER.OPER_NAME
  is '����Ա����';
comment on column TERMINAL_OPER.DEL_FLAG
  is 'ɾ����ʶ  1-��ɾ�� 0-δɾ��';
comment on column TERMINAL_OPER.LOGIN_STATUS
  is 'ǩ��״̬  1-ǩ��  0-ǩ��';

drop table TERMINAL_PARA;
create table TERMINAL_PARA
(
  MODULE_ID     INTEGER,
  DESCRIBE      VARCHAR(20),
  LINE_TYPE     CHAR(1),
  INPUT_TIMEOUT INTEGER,
  TRANS_TIMEOUT INTEGER,
  MANAGER_PWD   CHAR(8),
  OPERATOR_PWD  CHAR(6),
  TELEPHONE_NO  INTEGER,
  PIN_MAX_LEN   INTEGER,
  AUTH_KEY      CHAR(8),
  INTER_KEY     CHAR(32),
  EXT_KEY       CHAR(32),
  PRE_TELE_NO   VARCHAR(12),
  WAIT_TIME     INTEGER,
  TIP_SWITCH    CHAR(1),
  AUTO_ANSWER   CHAR(1),
  DELAY_TIME    INTEGER,
  HAND_DIAL     CHAR(1),
  SAVE_LIST     CHAR(1),
  PRINT_OR_NOT  CHAR(1),
  READER        CHAR(1),
  PIN_INPUT     CHAR(1)
)
;
comment on table TERMINAL_PARA
  is '�ն˲���ģ���';
comment on column TERMINAL_PARA.MODULE_ID
  is '����ģ����';
comment on column TERMINAL_PARA.DESCRIBE
  is '����ģ��˵��';
comment on column TERMINAL_PARA.LINE_TYPE
  is '����ģʽ 0-FSK���� 1-HDLC���� 2-DTMF���� 3-���Ž���';
comment on column TERMINAL_PARA.INPUT_TIMEOUT
  is '���Ƴ�ʱʱ�ޣ���λ��';
comment on column TERMINAL_PARA.TRANS_TIMEOUT
  is '���׳�ʱʱ�ޣ���λ��';
comment on column TERMINAL_PARA.MANAGER_PWD
  is '�ն˹�������';
comment on column TERMINAL_PARA.OPERATOR_PWD
  is '�ն˲�������';
comment on column TERMINAL_PARA.TELEPHONE_NO
  is 'ȱʡϵͳ�������';
comment on column TERMINAL_PARA.PIN_MAX_LEN
  is '������󳤶�';
comment on column TERMINAL_PARA.AUTH_KEY
  is '������֤��Կ��ASC��';
comment on column TERMINAL_PARA.INTER_KEY
  is '�ڲ���֤��Կ��ASC��';
comment on column TERMINAL_PARA.EXT_KEY
  is '�ⲿ��֤��Կ��ASC��';
comment on column TERMINAL_PARA.PRE_TELE_NO
  is 'Ԥ�����ߺ���';
comment on column TERMINAL_PARA.WAIT_TIME
  is '���ŵȴ�ʱ��';
comment on column TERMINAL_PARA.TIP_SWITCH
  is '������ʾ������ 0���ر�  1-��';
comment on column TERMINAL_PARA.AUTO_ANSWER
  is '�����Զ�Ӧ�� 0���ر�  1-��';
comment on column TERMINAL_PARA.DELAY_TIME
  is '������ʱ�ӵȼ� 1-200���� 2-400���� 3-600���� 4-800���� 5-1000����';
comment on column TERMINAL_PARA.HAND_DIAL
  is '�ն�ͨ������ 0��������  1-����';
comment on column TERMINAL_PARA.SAVE_LIST
  is '����֧���˵� 0-��  1-��';
comment on column TERMINAL_PARA.PRINT_OR_NOT
  is '�Ƿ��ӡ����ƾ�� 0-��  1-��';
comment on column TERMINAL_PARA.READER
  is '֧�������Ķ� 0-��  1-��';
comment on column TERMINAL_PARA.PIN_INPUT
  is '�������뷽ʽ 0-�����������  1-����������';
create unique index TERMINAL_PARA_IDX on TERMINAL_PARA (MODULE_ID);

drop table TM_APP_FILE_INFO;
create table TM_APP_FILE_INFO
(
  APP_NO     VARCHAR(50) not null,
  MODEL_NO   VARCHAR(40) not null,
  APP_VER    VARCHAR(40) not null,
  ISSUE_DATE VARCHAR(20)
)
;
comment on table TM_APP_FILE_INFO
  is 'Ӧ���ļ���Ϣ��';
comment on column TM_APP_FILE_INFO.APP_NO
  is 'Ӧ�ñ��';
comment on column TM_APP_FILE_INFO.MODEL_NO
  is '�ն��ͺ�';
comment on column TM_APP_FILE_INFO.APP_VER
  is 'Ӧ�ð汾';
comment on column TM_APP_FILE_INFO.ISSUE_DATE
  is '�����ϴ�����';
alter table TM_APP_FILE_INFO
  add constraint PK_TM_APP_FILE primary key (APP_NO, MODEL_NO, APP_VER);

drop table TM_APP_VER_INFO;
create table TM_APP_VER_INFO
(
  APP_NO      VARCHAR(50) not null,
  APP_VER     VARCHAR(40) not null,
  REMARK     VARCHAR(40),
  CREATE_DATE VARCHAR(20),
  DEPT_NO     VARCHAR(15)
)
;
comment on table TM_APP_VER_INFO
  is 'Ӧ�ð汾��Ϣ';
comment on column TM_APP_VER_INFO.APP_NO
  is 'Ӧ�ñ��';
comment on column TM_APP_VER_INFO.APP_VER
  is 'Ӧ�ð汾';
comment on column TM_APP_VER_INFO.REMARK
  is 'Ӧ������';
comment on column TM_APP_VER_INFO.CREATE_DATE
  is '����ʱ��';
comment on column TM_APP_VER_INFO.DEPT_NO
  is '����';
alter table TM_APP_VER_INFO
  add constraint PK_TM_APP_VER primary key (APP_NO, APP_VER);

drop table TM_APP_INFO;
create table TM_APP_INFO
(
  APP_NO     VARCHAR(50) not null,
  APP_NAME   VARCHAR(80) not null,
  SHARE_FLAG CHAR(1),
  ISSUE_DATE VARCHAR(20),
  STATUS    VARCHAR(20),
  DEPT_NO   VARCHAR(15)
)
;
comment on table TM_APP_INFO
  is 'Ӧ����Ϣ';
comment on column TM_APP_INFO.APP_NO
  is 'Ӧ�ñ��';
comment on column TM_APP_INFO.APP_NAME
  is 'Ӧ������';
comment on column TM_APP_INFO.SHARE_FLAG
  is '�����־';
comment on column TM_APP_INFO.ISSUE_DATE
  is '��������';
comment on column TM_APP_INFO.STATUS
  is '״̬';
comment on column TM_APP_INFO.DEPT_NO
  is '����';
alter table TM_APP_INFO
  add constraint PK_TM_APP_INFO primary key (APP_NO);

drop table TM_FACTORY_INFO;
create table TM_FACTORY_INFO
(
  FAC_NO      VARCHAR(20) not null,
  FAC_NAME    VARCHAR(40),
  CONTACT_MAN VARCHAR(50),
  ADDRESS    VARCHAR(80),
  TELE       VARCHAR(50),
  FAX        VARCHAR(50),
  POST_CODE   VARCHAR(50)
)
;
comment on table TM_FACTORY_INFO
  is '������Ϣ';
comment on column TM_FACTORY_INFO.FAC_NO
  is '���̱��';
comment on column TM_FACTORY_INFO.FAC_NAME
  is '��������';
comment on column TM_FACTORY_INFO.CONTACT_MAN
  is '��ϵ��';
comment on column TM_FACTORY_INFO.ADDRESS
  is '������ַ';
comment on column TM_FACTORY_INFO.TELE
  is '��ϵ�绰';
comment on column TM_FACTORY_INFO.FAX
  is '����';
comment on column TM_FACTORY_INFO.POST_CODE
  is '��������';
alter table TM_FACTORY_INFO
  add constraint PK_TM_FACTORY primary key (FAC_NO);

drop table TM_MODEL_INFO;
create table TM_MODEL_INFO
(
  MODEL_NO    VARCHAR(20) not null,
  MODEL_NAME  VARCHAR(30),
  PLUG_IN_NAME VARCHAR(100),
  FAC_NO      VARCHAR(50),
  FOLDER_PATH VARCHAR(255)
)
;
comment on table TM_MODEL_INFO
  is '�ն��ͺ���Ϣ';
comment on column TM_MODEL_INFO.MODEL_NO
  is '�ն��ͺű��';
comment on column TM_MODEL_INFO.MODEL_NAME
  is '�ն��ͺ�����';
comment on column TM_MODEL_INFO.PLUG_IN_NAME
  is '���ز��·��';
comment on column TM_MODEL_INFO.FAC_NO
  is '���̴���';
comment on column TM_MODEL_INFO.FOLDER_PATH
  is '�ն˳���Ŀ¼';
alter table TM_MODEL_INFO
  add constraint PK_TM_MODEL primary key (MODEL_NO);

drop table TM_TRADE_INFO;
create table TM_TRADE_INFO
(
  ID        VARCHAR(20) not null,
  SHOP_NO   VARCHAR(20),
  POS_NO    VARCHAR(20),
  SN        VARCHAR(20),
  TRANS_DATE VARCHAR(20),
  TRANS_TIME VARCHAR(20),
  APP_FLAG   CHAR(1),
  STATUS    VARCHAR(50),
  VPOS_ID    VARCHAR(32)
)
;
comment on table TM_TRADE_INFO
  is '������ˮ��';
comment on column TM_TRADE_INFO.ID
  is 'ID';
comment on column TM_TRADE_INFO.SHOP_NO
  is '�̻���';
comment on column TM_TRADE_INFO.POS_NO
  is '�ն˺�';
comment on column TM_TRADE_INFO.SN
  is 'Ӳ�����к�';
comment on column TM_TRADE_INFO.TRANS_DATE
  is '��������';
comment on column TM_TRADE_INFO.TRANS_TIME
  is '����ʱ��';
comment on column TM_TRADE_INFO.APP_FLAG
  is 'Ӧ�ñ�־';
comment on column TM_TRADE_INFO.STATUS
  is '״̬';
comment on column TM_TRADE_INFO.VPOS_ID
  is '��Ӧ�ñ��';
alter table TM_TRADE_INFO
  add constraint PK_TM_TRADE primary key (ID);

drop table TM_VPOS_APP_INFO;
create table TM_VPOS_APP_INFO
(
  ID         VARCHAR(32) not null,
  APP_NO      VARCHAR(20),
  APP_VER     VARCHAR(20),
  APP_CHANGE  VARCHAR(20),
  PARAM_NO    VARCHAR(20),
  PARA_CHANGE VARCHAR(1),
  VPOS_ID     VARCHAR(32)
)
;
comment on table TM_VPOS_APP_INFO
  is '�߼��ն�Ӧ����Ϣ';
comment on column TM_VPOS_APP_INFO.ID
  is 'ID';
comment on column TM_VPOS_APP_INFO.APP_NO
  is 'Ӧ�ñ��';
comment on column TM_VPOS_APP_INFO.APP_VER
  is 'Ӧ�ð汾';
comment on column TM_VPOS_APP_INFO.APP_CHANGE
  is 'Ӧ���޸ı�־';
comment on column TM_VPOS_APP_INFO.PARAM_NO
  is '����ģ����';
comment on column TM_VPOS_APP_INFO.PARA_CHANGE
  is '�����޸ı�־';
comment on column TM_VPOS_APP_INFO.VPOS_ID
  is '��Ӧ�ñ��';
alter table TM_VPOS_APP_INFO
  add constraint PK_TM_VPOS_APP_INFO primary key (ID);
create unique index TM_VPOS_APP_INFO_IDX on TM_VPOS_APP_INFO (APP_NO, APP_VER, VPOS_ID);

drop table TM_VPOS_INFO;
create table TM_VPOS_INFO
(
  VPOS_ID       VARCHAR(32) not null,
  POS_NO       VARCHAR(20),
  NOTICE_FLAG  CHAR(1),
  NOTICE_BTIME VARCHAR(14),
  NOTICE_EDATE VARCHAR(8),
  DOWN_FLAG     VARCHAR(10),
  SHOP_NO      VARCHAR(20),
  DEPT_NO      VARCHAR(15)
)
;
comment on table TM_VPOS_APP_INFO
  is '�߼��ն���Ϣ';
comment on column TM_VPOS_INFO.VPOS_ID
  is 'ID';
comment on column TM_VPOS_INFO.POS_NO
  is '�ն˺�';
comment on column TM_VPOS_INFO.NOTICE_FLAG
  is '֪ͨ��־';
comment on column TM_VPOS_INFO.NOTICE_BTIME
  is '֪ͨ��ʼʱ��';
comment on column TM_VPOS_INFO.NOTICE_EDATE
  is '֪ͨ��������';
comment on column TM_VPOS_INFO.DOWN_FLAG
  is '���ر�־';
comment on column TM_VPOS_INFO.SHOP_NO
  is '�̻���';
comment on column TM_VPOS_INFO.DEPT_NO
  is '������';
alter table TM_VPOS_INFO
  add constraint PK_TM_VPOS primary key (VPOS_ID);

drop table TRANS_BALANCE;
create table TRANS_BALANCE
(
  COLLATE_DATE   CHAR(8),
  SHOP_NO        CHAR(15),
  POS_NO         CHAR(15),
  TRANS_DATE     CHAR(10),
  TRANS_TIME     CHAR(8),
  AMOUNT         NUMERIC(12,2),
  COST           NUMERIC(12,2),
  PURE_INCOME    NUMERIC(12,2),
  PAN            VARCHAR(19),
  ACCOUNT2       VARCHAR(19) not null,
  RETRI_REF_NUM    CHAR(12),
  OLD_RETRI_REF_NUM CHAR(12),
  BALANCE        VARCHAR(20)
)
;
comment on table TRANS_BALANCE
  is '�����վ�����';
comment on column TRANS_BALANCE.COLLATE_DATE
  is '�տ�����';
comment on column TRANS_BALANCE.SHOP_NO
  is '�̻���';
comment on column TRANS_BALANCE.POS_NO
  is '�ն˺�';
comment on column TRANS_BALANCE.TRANS_DATE
  is '��������';
comment on column TRANS_BALANCE.TRANS_TIME
  is '����ʱ��';
comment on column TRANS_BALANCE.AMOUNT
  is '���׽��';
comment on column TRANS_BALANCE.COST
  is '�ɱ�';
comment on column TRANS_BALANCE.PURE_INCOME
  is '������';
comment on column TRANS_BALANCE.PAN
  is '����';
comment on column TRANS_BALANCE.ACCOUNT2
  is 'ת�뿨��';
comment on column TRANS_BALANCE.RETRI_REF_NUM
  is '�ο���';
comment on column TRANS_BALANCE.OLD_RETRI_REF_NUM
  is 'ԭ�ο���';
comment on column TRANS_BALANCE.BALANCE
  is '�վ����';
create unique index BALANCE_IDX on TRANS_BALANCE (SHOP_NO, POS_NO, TRANS_DATE, TRANS_TIME, RETRI_REF_NUM);

drop table TRANS_COMMANDS;
create table TRANS_COMMANDS
(
  TRANS_TYPE    INTEGER,
  STEP          INTEGER,
  TRANS_FLAG    CHAR(1),
  COMMAND       CHAR(2),
  OPER_INDEX    INTEGER,
  ALOG          CHAR(8),
  COMMAND_NAME  VARCHAR(30),
  ORG_COMMAND   CHAR(2),
  CONTROL_LEN   INTEGER default 0,
  CONTROL_PARA  CHAR(60),
  DATA_INDEX    INTEGER
)
;
comment on table TRANS_COMMANDS
  is '����ָ���';
comment on column TRANS_COMMANDS.TRANS_TYPE
  is '���״���';
comment on column TRANS_COMMANDS.STEP
  is '������';
comment on column TRANS_COMMANDS.TRANS_FLAG
  is '��ʶλ 0-֮ǰ���� 1-��������';
comment on column TRANS_COMMANDS.COMMAND
  is 'ʵ��ָ��';
comment on column TRANS_COMMANDS.OPER_INDEX
  is '������ʾ����';
comment on column TRANS_COMMANDS.ALOG
  is '���ܡ�У���㷨';
comment on column TRANS_COMMANDS.COMMAND_NAME
  is 'ָ������';
comment on column TRANS_COMMANDS.ORG_COMMAND
  is 'ԭʼָ��';
comment on column TRANS_COMMANDS.CONTROL_LEN
  is '���Ʋ�������';
comment on column TRANS_COMMANDS.CONTROL_PARA
  is '���Ʋ���';
comment on column TRANS_COMMANDS.DATA_INDEX
  is '����������ָ��������Դ';
create unique index TRANS_COMMANDS_IDX on TRANS_COMMANDS (TRANS_TYPE, STEP, TRANS_FLAG);

drop table TRANS_DEF;
create table TRANS_DEF
(
  TRANS_TYPE       INTEGER,
  TRANS_CODE       CHAR(8),
  NEXT_TRANS_CODE  CHAR(8),
  BUSINESS_TYPE    INTEGER default 0,
  EXCEP_HANDLE	   CHAR(1),
  EXCEP_TIMES      INTEGER default 0,
  PIN_BLOCK        CHAR(1) default '1',
  FUNCTION_INDEX   INTEGER,
  TRANS_NAME       VARCHAR(20),
  TELEPHONE_NO     INTEGER default 1,
  DISP_TYPE        CHAR(1),
  TOTRANS_MSG_TYPE INTEGER,
  TOHOST_MSG_TYPE  INTEGER,
  IS_VISIBLE       CHAR(1) default '1'
)
;
comment on table TRANS_DEF
  is '���׶����';
comment on column TRANS_DEF.TRANS_TYPE
  is '��������';
comment on column TRANS_DEF.TRANS_CODE
  is '���״���';
comment on column TRANS_DEF.NEXT_TRANS_CODE
  is '�������״��룬�޺�������Ϊ��';
comment on column TRANS_DEF.BUSINESS_TYPE
  is '����ҵ������';
comment on column TRANS_DEF.EXCEP_HANDLE
  is '�쳣�������(��Ӧ��ʱ����֤MAC��) 0-���������ط� 1-���� 2-�ط�';
comment on column TRANS_DEF.EXCEP_TIMES
  is '�쳣�������';
comment on column TRANS_DEF.PIN_BLOCK
  is 'pin_block�����㷨  0-��ͨ 1-������ 2-�ɷ���';
comment on column TRANS_DEF.FUNCTION_INDEX
  is '������ʾ��Ϣ������0-����ʾ';
comment on column TRANS_DEF.TRANS_NAME
  is '��������';
comment on column TRANS_DEF.TELEPHONE_NO
  is 'ʹ�õĵ绰�������';
comment on column TRANS_DEF.DISP_TYPE
  is '�����ʾˢ�·�ʽ 0-��ˢ�� 1-ˢ����ʾ��ҳ';
comment on column TRANS_DEF.TOTRANS_MSG_TYPE
  is '���״���ģ�������Ϣ���ͣ����ڽ����ѡ����·��';
comment on column TRANS_DEF.TOHOST_MSG_TYPE
  is '��̨�ӿ�ģ�������Ϣ���ͣ����ڽ��״����ѡ����·��';
comment on column TRANS_DEF.IS_VISIBLE
  is '�Ƿ��ڽ��������б��г���  0-������  1-����';
create unique index TRANS_DEF_IDX1 on TRANS_DEF (TRANS_CODE);
create unique index TRANS_DEF_IDX2 on TRANS_DEF (TRANS_TYPE);

drop table TRANS_TYPES_8583;
create table TRANS_TYPES_8583
(
  BANK_TYPE     INTEGER not null,
  TRANS_TYPE    INTEGER not null,
  REQ_MSG_ID    CHAR(4) not null,
  REQ_PROC_CODE CHAR(6),
  RSP_MSG_ID    CHAR(4) not null,
  RSP_PROC_CODE CHAR(6),
  TRANS_NAME    VARCHAR(40)
)
;
comment on table TRANS_TYPES_8583
  is '8583���������Ͷ����';
comment on column TRANS_TYPES_8583.BANK_TYPE
  is '�������';
comment on column TRANS_TYPES_8583.TRANS_TYPE
  is '��������';
comment on column TRANS_TYPES_8583.REQ_MSG_ID
  is '������Ϣ��';
comment on column TRANS_TYPES_8583.REQ_PROC_CODE
  is '��������';
comment on column TRANS_TYPES_8583.RSP_MSG_ID
  is '��Ӧ��Ϣ��';
comment on column TRANS_TYPES_8583.RSP_PROC_CODE
  is '��Ӧ������';
comment on column TRANS_TYPES_8583.TRANS_NAME
  is '��������';
alter table TRANS_TYPES_8583
  add constraint PK_TRANS_TYPES_8583 primary key (BANK_TYPE, TRANS_TYPE);

drop table UNIT_INFO;
create table UNIT_INFO
(
  TRANS_CODE CHAR(8),
  UNIT_CODE  CHAR(8),
  UNIT_NAME  VARCHAR(40)
)
;
comment on table UNIT_INFO
  is '�շѻ�����Ϣ��';
comment on column UNIT_INFO.TRANS_CODE
  is '���״���';
comment on column UNIT_INFO.UNIT_CODE
  is '�շѻ�������';
comment on column UNIT_INFO.UNIT_NAME
  is '�շѻ�������';
create unique index UNIT_INFO_IDX on UNIT_INFO (TRANS_CODE);

drop table UNKNOWN_CARD;
create table UNKNOWN_CARD
(
  TRACK2 VARCHAR(40) not null,
  TRACK3 VARCHAR(107),
  S_DATE CHAR(8),
  FLAG   CHAR(2)
)
;
comment on table UNKNOWN_CARD
  is 'δ֪����';
comment on column UNKNOWN_CARD.TRACK2
  is '�ŵ�2��Ϣ';
comment on column UNKNOWN_CARD.TRACK3
  is '�ŵ�3��Ϣ';
comment on column UNKNOWN_CARD.S_DATE
  is '��¼����';
comment on column UNKNOWN_CARD.FLAG
  is '�����ʶ 00-δ����  01-�Ѵ���';

drop table WEB_MENU;
create table WEB_MENU
(
  MODULE_ID     INTEGER not null,
  SYS_ID        VARCHAR(10) not null,
  MENU_NAME  VARCHAR(20) not null,
  ROUTE VARCHAR(255),
  UP_MODULE_ID    INTEGER not null,
  SPLIT        CHAR(1)
)
;
comment on table WEB_MENU
  is '������ϵͳ�˵���';
comment on column WEB_MENU.MODULE_ID
  is '�˵�ID';
comment on column WEB_MENU.SYS_ID
  is 'ϵͳID';
comment on column WEB_MENU.MENU_NAME
  is '�˵�����';
comment on column WEB_MENU.ROUTE
  is '·��';
comment on column WEB_MENU.UP_MODULE_ID
  is '�ϼ��˵�ID';
alter table WEB_MENU
  add constraint PK_MODULE primary key (MODULE_ID);
create index WEB_MENU_IDX on WEB_MENU (SYS_ID);

drop table trans_conf;
create table trans_conf
(
	trans_type		INTEGER NOT NULL,
	amount_single		NUMERIC(12,2) DEFAULT 0,
	amount_sum		NUMERIC(12,2) DEFAULT 0,
	max_count		INTEGER DEFAULT 0,
	credit_amount_single	NUMERIC(12,2) DEFAULT 0,
	credit_amount_sum	NUMERIC(12,2) DEFAULT 0,
	credit_max_count	INTEGER DEFAULT 0,
	card_type_out		CHAR(9) DEFAULT '111111111',
	card_type_in		CHAR(9) DEFAULT '111111111',
	fee_calc_type		INTEGER DEFAULT 0
);
comment on table trans_conf
	is '���׷�ز�����';
comment on column trans_conf.trans_type
	is '��������';
comment on column trans_conf.amount_single
	is '���ʽ����޶�';
comment on column trans_conf.amount_sum
	is '�����ۼ��޶�';
comment on column trans_conf.max_count
	is '��������ױ���';
comment on column trans_conf.credit_amount_single
	is '���ÿ����ʽ����޶�';
comment on column trans_conf.credit_amount_sum
	is '���ÿ������ۼ��޶�';
comment on column trans_conf.credit_max_count
	is '���ÿ�����ױ���';
comment on column trans_conf.card_type_out
	is 'ת������ɿ���,ÿλ����ĳ�ֿ��Ƿ�������,1Ϊ����,0Ϊ��������һλ�����н�ǿ� �ڶ�λ�����д��ǿ� ����λ������׼���ǿ� ����λ�����н�ǿ�
	    ����λ�����д��ǿ� ����λ������׼���ǿ� ����λ�����ؽ�ǿ� �ڰ�λ�����ش��ǿ� �ھ�λ������׼���ǿ�';
comment on column trans_conf.card_type_in
	is 'ת�뿨��ɿ���';
comment on column trans_conf.fee_calc_type
	is '�����Ѽ��㷽ʽ 0-������ 1-������ 2-������';
create unique index trans_conf_idx ON trans_conf(trans_type);

drop table dept_conf;
create table dept_conf
(
	dept_no			CHAR(15) NOT NULL,
	dept_detail		VARCHAR(70) NOT NULL,
	trans_type		INTEGER NOT NULL,
	amount_single		NUMERIC(12,2) DEFAULT 0,
	amount_sum		NUMERIC(12,2) DEFAULT 0,
	max_count		INTEGER DEFAULT 0,
	credit_amount_single	NUMERIC(12,2) DEFAULT 0,
	credit_amount_sum	NUMERIC(12,2) DEFAULT 0,
	credit_max_count	INTEGER DEFAULT 0,
	card_type_out		CHAR(9) DEFAULT '111111111',
	card_type_in		CHAR(9) DEFAULT '111111111',
	fee_calc_type		INTEGER DEFAULT 0
)
;
comment on table dept_conf
	is '������ز�����';
comment on column dept_conf.dept_no
	is '������';
comment on column dept_conf.dept_detail
	is '�����㼶��Ϣ';
comment on column dept_conf.trans_type
	is '��������';
comment on column dept_conf.amount_single
	is '���ʽ����޶�';
comment on column dept_conf.amount_sum
	is '�����ۼ��޶�';
comment on column dept_conf.max_count
	is '��������ױ���';
comment on column dept_conf.credit_amount_single
	is '���ÿ����ʽ����޶�';
comment on column dept_conf.credit_amount_sum
	is '���ÿ������ۼ��޶�';
comment on column dept_conf.credit_max_count
	is '���ÿ�����ױ���';
comment on column dept_conf.card_type_out
	is 'ת������ɿ���';
comment on column dept_conf.card_type_in
	is 'ת�뿨��ɿ���';
comment on column dept_conf.fee_calc_type
	is '�����Ѽ��㷽ʽ 0-������ 1-������ 2-������';
create unique index dept_conf_idx ON dept_conf(dept_no, trans_type);

drop table shop_conf;
create table shop_conf
(
	shop_no			CHAR(15) NOT NULL,
	trans_type		INTEGER NOT NULL,
	amount_single		NUMERIC(12,2) DEFAULT 0,
	amount_sum		NUMERIC(12,2) DEFAULT 0,
	max_count		INTEGER DEFAULT 0,
	credit_amount_single	NUMERIC(12,2) DEFAULT 0,
	credit_amount_sum	NUMERIC(12,2) DEFAULT 0,
	credit_max_count	INTEGER DEFAULT 0,
	card_type_out		CHAR(9) DEFAULT '111111111',
	card_type_in		CHAR(9) DEFAULT '111111111',
	fee_calc_type		INTEGER DEFAULT 0
)
;
comment on table shop_conf
	is '�̻���ز�����';
comment on column shop_conf.shop_no
	is '�̻���';
comment on column shop_conf.trans_type
	is '��������';
comment on column shop_conf.amount_single
	is '���ʽ����޶�';
comment on column shop_conf.amount_sum
	is '�����ۼ��޶�';
comment on column shop_conf.max_count
	is '��������ױ���';
comment on column shop_conf.credit_amount_single
	is '���ÿ����ʽ����޶�';
comment on column shop_conf.credit_amount_sum
	is '���ÿ������ۼ��޶�';
comment on column shop_conf.credit_max_count
	is '���ÿ�����ױ���';
comment on column shop_conf.card_type_out
	is 'ת������ɿ���';
comment on column shop_conf.card_type_in
	is 'ת�뿨��ɿ���';
comment on column shop_conf.fee_calc_type
	is '�����Ѽ��㷽ʽ 0-������ 1-������ 2-������';
create unique index shop_conf_idx ON shop_conf(shop_no, trans_type);

drop table pos_conf;
create table pos_conf
(
	shop_no			CHAR(15) NOT NULL,
	pos_no			CHAR(15) NOT NULL,
	trans_type		INTEGER NOT NULL,
	amount_single		NUMERIC(12,2) DEFAULT 0,
	amount_sum		NUMERIC(12,2) DEFAULT 0,
	max_count		INTEGER DEFAULT 0,
	credit_amount_single	NUMERIC(12,2) DEFAULT 0,
	credit_amount_sum	NUMERIC(12,2) DEFAULT 0,
	credit_max_count	INTEGER DEFAULT 0,
	card_type_out		CHAR(9) DEFAULT '111111111',
	card_type_in		CHAR(9) DEFAULT '111111111',
	fee_calc_type		INTEGER DEFAULT 0
)
;
comment on table pos_conf
	is '�ն˷�ز�����';
comment on column pos_conf.shop_no
	is '�̻���';
comment on column pos_conf.pos_no
	is '�ն˺�';
comment on column pos_conf.trans_type
	is '��������';
comment on column pos_conf.amount_single
	is '���ʽ����޶�';
comment on column pos_conf.amount_sum
	is '�����ۼ��޶�';
comment on column pos_conf.max_count
	is '��������ױ���';
comment on column pos_conf.credit_amount_single
	is '���ÿ����ʽ����޶�';
comment on column pos_conf.credit_amount_sum
	is '���ÿ������ۼ��޶�';
comment on column pos_conf.credit_max_count
	is '���ÿ���������ױ���';
comment on column pos_conf.card_type_out
	is 'ת������ɿ���';
comment on column pos_conf.card_type_in
	is 'ת�뿨��ɿ���';
comment on column pos_conf.fee_calc_type
	is '�����Ѽ��㷽ʽ 0-������ 1-������ 2-������';
create unique index pos_conf_idx ON pos_conf(shop_no, pos_no, trans_type);

drop table dept_fee_rate;
create table dept_fee_rate
(
	dept_no			CHAR(15) NOT NULL,
	dept_detail		VARCHAR(70) NOT NULL,
	trans_type		INTEGER NOT NULL,
	fee_type		INTEGER NOT NULL,
	card_type		INTEGER DEFAULT 0,
	amount_begin		NUMERIC(12,2) NOT NULL,
	fee_rate		INTEGER NOT NULL,
	fee_base		NUMERIC(12,2) NOT NULL,
	fee_min			NUMERIC(12,2) NOT NULL,
	fee_max			NUMERIC(12,2) NOT NULL
)
;
comment on table dept_fee_rate
	is '�����������ʱ�';
comment on column dept_fee_rate.dept_no
	is '������';
comment on column dept_fee_rate.dept_detail
	is '�����㼶��Ϣ';
comment on column dept_fee_rate.trans_type
	is '��������';
comment on column dept_fee_rate.fee_type
	is '�������� 1������ͬ��ת���� 2���������ת���� 3������ת���� 4�����п��ۿ��� 5�����п��ۿ���';
comment on column dept_fee_rate.card_type
	is '����';
comment on column dept_fee_rate.amount_begin
	is '������ʼ���';
comment on column dept_fee_rate.fee_rate
	is '��������';
comment on column dept_fee_rate.fee_base
	is '��������';
comment on column dept_fee_rate.fee_min
	is '���������';
comment on column dept_fee_rate.fee_max
	is '���������';
create unique index dept_fee_rate_idx ON dept_fee_rate (dept_no, trans_type, fee_type, card_type, amount_begin);

drop table shop_fee_rate;
create table shop_fee_rate
(
	shop_no			CHAR(15) NOT NULL,
	trans_type		INTEGER NOT NULL,
	fee_type		INTEGER NOT NULL,
	card_type		INTEGER DEFAULT 0,
	amount_begin		NUMERIC(12,2) NOT NULL,
	fee_rate		INTEGER NOT NULL,
	fee_base		NUMERIC(12,2) NOT NULL,
	fee_min			NUMERIC(12,2) NOT NULL,
	fee_max			NUMERIC(12,2) NOT NULL
)
;
comment on table shop_fee_rate
	is '�̻��������ʱ�';
comment on column shop_fee_rate.shop_no
	is '�̻���';
comment on column shop_fee_rate.trans_type
	is '��������';
comment on column shop_fee_rate.fee_type
	is '�������� 1������ͬ��ת���� 2���������ת���� 3������ת���� 4�����п��ۿ��� 5�����п��ۿ���';
comment on column shop_fee_rate.card_type
	is '����';
comment on column shop_fee_rate.amount_begin
	is '������ʼ���';
comment on column shop_fee_rate.fee_rate
	is '��������';
comment on column shop_fee_rate.fee_base
	is '��������';
comment on column shop_fee_rate.fee_min
	is '���������';
comment on column shop_fee_rate.fee_max
	is '���������';
create unique index shop_fee_rate_idx ON shop_fee_rate (shop_no, trans_type, fee_type, card_type, amount_begin);


DROP TABLE emv_key;
CREATE TABLE emv_key
(
    key_ver             CHAR(8) NOT NULL,
    key_data            VARCHAR(1204)
)
;
COMMENT ON TABLE emv_key
    is 'EMV��Կ��';
COMMENT ON COLUMN emv_key.key_ver
    is 'EMV��Կ�汾��';
COMMENT ON COLUMN emv_key.key_data
    is 'EMV��Կ';
CREATE UNIQUE INDEX emv_key_idx ON emv_key (key_ver);

DROP TABLE emv_para;
CREATE TABLE emv_para
(
    para_ver             CHAR(12) NOT NULL,
    para_data            VARCHAR(1204)
)
;
COMMENT ON TABLE emv_para
    is 'EMV������';
COMMENT ON COLUMN emv_para.para_ver
    is 'EMV�����汾��';
COMMENT ON COLUMN emv_para.para_data
    is 'EMV����';
CREATE UNIQUE INDEX emv_para_idx ON emv_para (para_ver);
