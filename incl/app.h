/******************************************************************
** Copyright(C)2012 - 2015���������豸���޹�˾
** ��Ҫ���ݣ����屾ϵͳģ���ͨѶ�Ĺ������ݽṹ
** �� �� �ˣ�������
** �������ڣ�2012/11/8
** $Log: app.h,v $
** Revision 1.20  2013/06/14 02:33:54  fengw
**
** 1�����ӹ�����Կ�ṹ�嶨�塣
**
** Revision 1.19  2012/12/20 09:04:37  fengw
**
** 1������cExcepHandle(�����쳣�������)�ֶΡ�
**
** Revision 1.18  2012/12/17 06:34:10  chenrb
** app�ṹ���ӿ��Ʋ�������iControlLen�����Ʋ���szControlPara�����ֶ�
**
** Revision 1.17  2012/12/13 07:33:06  chenrb
** szTermSerialNo������11��Ϊ10
**
** Revision 1.16  2012/12/11 03:26:02  chenrb
** iMenuItem�޸ĳ�iaMenuItem
**
** Revision 1.15  2012/12/11 02:48:24  chenrb
** �����ն��ͺ�szPosType
**
** Revision 1.14  2012/11/29 05:58:37  chenrb
** ɾ��lLastVisitTime
**
** Revision 1.13  2012/11/29 02:47:59  chenrb
** �޸�·���ֶ�����
**
** Revision 1.12  2012/11/27 07:03:17  gaomx
** *** empty log message ***
**
** Revision 1.11  2012/11/27 06:25:36  epay5
** *** empty log message ***
**
** Revision 1.9  2012/11/20 06:05:04  epay5
** modified by gaomx �޸���ͻ
**
** Revision 1.8  2012/11/20 01:40:14  fengw
**
** 1��APPSIZE©�ģ������޸��ύ��
**
** Revision 1.7  2012/11/20 01:36:44  fengw
**
** 1���޸�APPSIZE��HSMSIZEд����
** 2����ʽ���롣
**
** Revision 1.6  2012/11/19 08:11:01  epay5
** ������Ϣ���д�����󳤶�ֵ�ĺ�MAX_MSG_SIZE
**
** Revision 1.5  2012/11/19 07:48:58  epay5
**
** modified by gaomx 2012/11/19 ������Ϣ���нṹ�嶨��
**
** Revision 1.4  2012/11/16 01:25:56  fengw
**
** 1�����Ӻ�̨������Ϣ(szHostRetMsg)�ֶΣ����ڱ����̨����Ӧ���еĴ�����ʾ��Ϣ
**
** Revision 1.3  2012/11/14 06:54:04  chenrb
** 1�����ն˳���汾szPosCodeVer��15�ֽڱ�Ϊ9�ֽڡ�
** 2��ɾ��ISO8583����60��62�Զ�����
** 3����IC�����к�szEmvCardNo����2�ֽڱ�Ϊ3�ֽڡ�
**
** Revision 1.2  2012/11/12 04:24:57  fengw
**
** ���ӻ�����(szDeptNo)�������㼶��Ϣ(szDeptDetail)��ҵ������(iBusinessType)�ֶ�
**
** Revision 1.1.1.1  2012/11/12 02:10:42  epay5
** V5 Init
**
*******************************************************************/

#ifndef _APP_H_
#define _APP_H_

typedef struct
{
    /* ����Э�鲿�� */
    int  iFskId;                    /* ����ƽ̨ID */
    int  iModuleId;                 /* ģ��� */
    int  iChannelId;                /* ͨ���� */
    int  iCallType;                 /* �������� 1-�ն����� 2-�������� */
    int  iSteps;                    /* ����ͬ����� */
    long lTransDataIdx;             /* �������������� */
    char szMsgVer[2+1];             /* �ն˱���Э��汾�� */
    char szAppVer[4+1];             /* �ն�Ӧ�ýű��汾�� */
    char szPosCodeVer[8+1];         /* �ն˳���汾�� */
    char szPosType[10+1];           /* �ն��ͺ� */

    /* �����к��� */
    char szCalledTelByTerm[15+1];   /* �ն����͵ı������ĺ��� */
    char szCalledTelByNac[15+1];    /* ���������͵ı������ĺ��� */
    char szCallingTel[15+1];        /* �ն����к��� */

    /* ����·����Ϣ */
    char szSourceTpdu[2+1];         /* Դ��ַ */
    char szTargetTpdu[2+1];         /* Ŀ�ĵ�ַ */
    long lProcToAccessMsgType;      /* �������ս���Ӧ����Ϣ���ͣ�Ϊ����ģ����̺ţ����״���㷵�ؽ���Ӧ��ʱ��Ϊ��Ϣ���� */
    long lPresentToProcMsgType;     /* ���״������ս���Ӧ����Ϣ���ͣ�Ϊ���״���ģ����̺ţ�ҵ���ύ�㷵�ؽ���Ӧ��ʱ��Ϊ��Ϣ���� */
    long lAccessToProcMsgType;      /* ���״������ս���������Ϣ���ͣ�����㷢�ͽ�������ʱ��Ϊ��Ϣ���ͣ��ڽ��׶���ʱ���� */
    long lProcToPresentMsgType;     /* ҵ���ύ����ս���������Ϣ���ͣ�ҵ����㷢�ͽ�������ʱ��Ϊ��Ϣ���ͣ��ڽ��׶���ʱ���� */
    char szIp[15+1];                /* ����IP */

    /* �ն˲ɼ���Ϣ */
    int  iTransNum;                 /* ������0x06��ָ����� */
    char szFinancialCode[40+1];	    /* ����Ӧ�ú� */
    char szBusinessCode[40+1];	    /* ����Ӧ�ú� */
    char szInDate[8+1];             /* ���ڣ�YYYYMMDD��0x0a��ָ����� */
    char szInMonth[6+1];            /* ���£�YYYYMM��0x0b��ָ����� */
    char szUserData[80+1];          /* �û��������ݣ�0x0c��ָ����� */
    int  iaMenuItem[5];             /* ѡ�еĶ�̬�˵��0x2B��ָ����� */
    int  iMenuNum;                  /* ��̬�˵�����, ���֧��5����̬�˵� */
    int  iMenuRecNo[5];	            /* ��̬�˵���Ӧ�Ĳ˵���ʶ */
    int  iStaticMenuId;             /* ��̬�˵�ID */
    int  iStaticMenuItem;           /* ѡ�еľ�̬�˵��0x2D�ž�̬�˵���ʾ��ѡ��ָ�����(�˵���ID) */
    char szStaticMenuOut[30+1];	    /* ѡ�еľ�̬�˵����ݣ�0x2D�ž�̬�˵���ʾ��ѡ��ָ�����(�˵�������) */
    long lRate;                     /* 0x36��ָ���ȡ������� */
    char szTermRetCode[2+1];        /* ���и�����ָ��ķ��ؽ�� */

    /* �յ���(�̻��ն�)���� */
    char szPsamNo[16+1];            /* ��ȫģ��� */
    char szTermSerialNo[10+1];      /* �ն�Ӳ�����к� */
    char szDeptNo[15+1];            /* ������ */
    char szDeptDetail[70+1];        /* �����㼶��Ϣ */
    char szShopNo[15+1];            /* �̻��� */ 
    char szPosNo[15+1];             /* �ն˺� */
    char szAcqBankId[11+1];         /* �յ��� */
    long lBatchNo;                  /* �������κ� */						
    long lPosTrace;                 /* �ն���ˮ�� */
    long lOldPosTrace;              /* ԭPOS��ˮ�� */
    char szPosDate[8+1];            /* �ն˽������ڣ���ʽYYYYMMDD */
    char szPosTime[6+1];            /* �ն˽���ʱ�䣬��ʽHHMMSS */
    char szShopName[40+1];          /* �̻����� */
    char szShopType[4+1];           /* �̻����� */
    long lMarketNo;                 /* �г���� */
    char szMacKey[16+1];            /* �ն�MAC��Կ */
    char szPinKey[16+1];            /* �ն�PIN��Կ */
    char szTrackKey[16+1];          /* �ն˴ŵ�������Կ */
    char szKeyIndex;                /* ��Կ������ */
    int  iTermModule;	            /* �ն˲���ģ��� */
    int  iPsamModule;               /* Psam����ģ��� */
    char szOperNo[4+1];             /* ����Ա��� */
    char szOperPwd[6+1];            /* ����Ա���� */
    char szEntryMode[3+1];          /* ��������뷽ʽ��, COMWEBԶ�����ؽ������ڱ�������ʱ�� */

    /* ����Ҫ�� */
    int  iTransType;                /* �������� */
    int  iOldTransType;             /* ԭ�������� */
    int  iBusinessType;             /* ҵ������ */
    char szTransCode[8+1];          /* �ն˽��״��� */
    char szNextTransCode[8+1];      /* �������״��� */
    char szTransName[20+1];         /* �������� */
    char szAmount[12+1];            /* ���׽���Ӧ�ɽ�� */
    char szAddiAmount[14+1];        /* ���������� */
    char szFundType[3+1];           /* ���Ҵ��� */
    int  iCommandNum;	            /* ���������=��ǰ���׺������������+��������֮ǰ���������*/
    int  iCommandLen;	            /* ���̴��볤�� */
    char szCommand[99+1];    	    /* ���̴��� */
    int  iControlLen;               /* ���Ʋ������� */
    char szControlPara[100+1];      /* ���Ʋ��� */
    char szMac[8+1];                /* ����MAC */

    /* ת�����˻���Ϣ���ڽ�����ȡ��ֵ */
    char szPan[19+1];               /* ���˻� */
    char szPasswd[8+1];             /* ������/����Ա���� */
    char szNewPasswd[8+1];          /* ��������/����Ա������ */
    char szTrack2[37+1];            /* 2�ŵ����� */ 
    char szTrack3[104+1];           /* 3�ŵ����� */
    char szExpireDate[4+1];         /* ����Ч�� */
    char szOutBankId[11+1];         /* ������ID */
    char szOutBankName[20+1];	    /* ���������� */
    char szOutCardName[32+1];	    /* ���п����� */
    char cOutCardType;              /* ת�������� '0'-��ǿ� '1'-���ǿ� '3'-׼���ǿ� */
    int  iOutCardLevel;             /* ������  0-�տ�  1-�� */
    int	 iOutCardBelong;            /* ������  0-���б���  1-�������  2-���� */
    char szHolderName[40+1];        /* �ֿ������� */

    /* ת�뿨�˻���Ϣ���ڽ�����ȡ��ֵ */
    char szAccount2[19+1];          /* ת���˺� */ 
    char szInBankId[11+1];          /* ת�뿨������ID */
    char szInBankName[20+1];        /* ת�뿨���������� */
    char cInCardType;               /* ת�뿨���� '0'-��ǿ� '1'-���ǿ� '3'-׼���ǿ� */
    int	 iInCardBelong;	     	    /* ת�뿨����  0-���б���  1-�������  2-���� */

    /* ƽ̨����̨��Ϣ */
    char szHostDate[8+1];           /* ƽ̨�������ڣ���ʽYYYYMMDD */
    char szHostTime[6+1];           /* ƽ̨����ʱ�䣬��ʽHHMMSS */
    long lSysTrace;                 /* ƽ̨��ˮ�� */
    long lOldSysTrace;              /* ԭƽ̨��ˮ�� */
    char szRetriRefNum[12+1];       /* ��̨�����ο��� */
    char szOldRetriRefNum[12+1];    /* ԭ��̨�����ο��� */
    char szAuthCode[6+1];           /* ��Ȩ�� */		    
    char szRetCode[2+1];            /* ƽ̨������ */
    char szHostRetCode[6+1];        /* ��̨������*/
    char szHostRetMsg[40+1];        /* ��̨������Ϣ */
    char szRetDesc[20+1];           /* ������Ϣ���� */

    /* �Զ������� */
    int  iReservedLen;              /* �Զ������ݳ��� */        
    char szReserved[1024+1];        /* �Զ������� */

    /* TMSӦ������ */
    int  iTmsLen;     	            /* TMS���ݳ��� */        
    char szTmsData[310+1];          /* TMS�������� */

    /* IC��Ӧ������ */
    char szEmvRet[2+1];	            /* EMV�������ݴ����� */
    char szEmvCardNo[3+1];          /* EMV�����к� */
    char szEmvParaVer[12+1];	    /* EMV�����汾�� */
    int  iEmvParaLen;               /* EMV�������� */
    char szEmvPara[512+1];          /* EMV���� */
    char szEmvKeyVer[8+1];          /* EMV��Կ�汾�� */
    int  iEmvKeyLen;                /* MEV��Կ���� */
    char szEmvKey[512+1];           /* EMV��Կ */
    int  iEmvTcLen;                 /* EMV����֤�鳤�� */
    char szEmvTc[512+1];            /* EMV����֤�� */
    int  iEmvDataLen;               /* EMV���ݳ��� */
    char szEmvData[512+1];          /* EMV���� */
    int  iEmvScriptLen;             /* EMV�ű����� */
    char szEmvScript[512+1];	    /* EMV�ű� */

    /* 8583����� */
    char szMsgId[4+1];              /* field 0 */
    char szProcCode[6+1];           /* field 3     */
    char szSettleDate[4+1];         /* field 15 �������� */
    char szServerCode[2+1];         /* field 25    */
    char szCaptureCode[2+1];	    /* field 26    */

    /* ���� */
    int  iDataNum;                  /* ����Դ���� */
    char szDataSource[20+1];	    /* ����Դ��ʶ��ÿ���ֽڱ�ʶһ������Դ */
    char cExcepHandle;              /* �����쳣������� 0-���������ط� 1-���� 2-�ط� */
    char cDispType;                 /* �����ʾ��ʽ '0'-��ˢ�� '1'-ˢ����ʾ��ҳ */
    char szControlCode[5];          /* ���̿����룬���֧��5�����̿���, 1���ֽڴ���1�����̿��� 1-�� 0-�� */

    /* ����Ŀ�Զ������� */
} T_App;
#define APPSIZE sizeof(T_App)

/*ϵͳ�ڲ�·����Ϣ���нṹ*/
#define MAX_MSG_SIZE        10

typedef struct
{
    long    lMsgType;
    char    szMsgText[MAX_MSG_SIZE];
} T_MessageStru;

/* �������ܻ�����Ϣ��ṹ */
typedef struct
{
    long    lSourceType;            /*���̺�*/
    int     iTransType;             /*��������*/
    char    szPsamNo[16+1];         /*��ȫģ���*/
    int     iAlog;                  /*�����㷨*/
    int     iPinBlock;              /*pin block��֯*/
    char    szPinKey[32+1];         /*pin_key����*/
    char    szMacKey[32+1];         /*mac_key���ģ�����ת����ʱ���Ŀ��PIK����*/
    int     iDataLen;               /*���ݳ���*/
    char    szData[1024];           /*����*/
    char    szReturnCode[2+1];      /*������*/
} T_Interface;
#define HSMSIZE sizeof(T_Interface)

typedef struct
{
    long    lMsgType;               /* ��Ϣ��ʶ */
    char    szMsgText[HSMSIZE];     /* ��Ϣ */
} T_HsmStru;

/* ������Կ�ṹ�嶨�� */
typedef struct
{
    char    szPinKey[32+1];
    char    szPIKChkVal[8+1];
    char    szMacKey[32+1];
    char    szMAKChkVal[8+1];
    char    szMagKey[32+1];
    char    szMGKChkVal[8+1];
}T_WorkKey;

#endif
