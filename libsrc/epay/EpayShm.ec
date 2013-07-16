/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨epay������ �����ڴ����
** �� �� �ˣ����
** �������ڣ�2012-11-27
**
** $Revision: 1.15 $
** $Log: EpayShm.ec,v $
** Revision 1.15  2013/06/28 08:35:16  fengw
**
** 1����Ӵ�����ɾ��ʱ��¼TRACE��־�����ֹ���ʱ���ڸ���ȷ�����⡣
**
** Revision 1.14  2013/06/25 01:57:46  fengw
**
** 1�����Ӵ����ɹ����¼TRACE��־��
**
** Revision 1.13  2013/01/14 06:24:11  fengw
**
** 1���޸�DelAccessPid����������
**
** Revision 1.12  2012/12/24 08:55:50  wukj
** ɾ�������ڴ�ʱ,�������ڴ�ָ��ȫ�ֱ�����ΪNULL
**
** Revision 1.11  2012/12/20 09:22:33  wukj
** *** empty log message ***
**
*******************************************************************/

#include "EpayShm.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL END DECLARE SECTION;

static int _LoadCard();
static int _LoadLocalCard();
static int _GetCard(char *szCardNo, int iType, char *szBankID, T_CARDS *ptCard, int *piCardBelong);
static int _InsertUnknowCard(char *szTrack2, char *szTrack3);

/****************************************************************
** ��    �ܣ�����EPAY�����ڴ�
** ���������
**        ��
** ���������
**        ��
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/27
** ����˵����
**
** �޸���־��
****************************************************************/
int CreateEpayShm()
{
    char    szFileName[128+1];

    memset(szFileName, 0, sizeof(szFileName));

    WriteLog(TRACE, "����EPAY�����ڴ濪ʼ");

    GetFullName("WORKDIR", SHM_FILE, szFileName);

    /* ����EPAY�����ڴ� */
    if((giShmEpayID = CreateShm(szFileName, EPAY_SHM_ID, SHM_EPAY_SIZE)) == FAIL)
    {
        WriteLog(ERROR, "����EPAY�����ڴ�ʧ��");

        return FAIL;
    }

    /* ��ʼ�������ڴ� */
    if(InitEpayShm() != SUCC)
    {
        /* ɾ��EPAY�����ڴ� */
        RmShm(giShmEpayID);

        return FAIL;
    }

    WriteLog(TRACE, "����EPAY�����ڴ�ɹ�");

    return SUCC;
}

/****************************************************************
** ��    �ܣ���ȡEPAY�����ڴ�ID����ӳ��
** ���������
**        ��
** ���������
**        ��
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/29
** ����˵����
**
** �޸���־��
****************************************************************/
int GetEpayShm()
{
    char    szFileName[128+1];

    memset(szFileName, 0, sizeof(szFileName));

    GetFullName("WORKDIR", SHM_FILE, szFileName);

    /* ��ȡ�����ڴ� */
    if(gpShmEpay == NULL)
    {
        if(giShmEpayID <= 0 && (giShmEpayID = GetShm(szFileName, EPAY_SHM_ID, SHM_EPAY_SIZE)) == FAIL)
        {
            WriteLog(ERROR, "��ȡEPAY�����ڴ�IDʧ��!");

            return FAIL;
        }

        /* ӳ�乲���ڴ� */
        if((gpShmEpay = (T_SHM_EPAY *)AtShm(giShmEpayID)) == NULL)
        {
            WriteLog(ERROR, "ӳ��EPAY�����ڴ�ʧ��");

            return FAIL;
        }
    }

    return SUCC;
}

/****************************************************************
** ��    �ܣ���ʼ��EPAY�����ڴ�
** ���������
**        ��
** ���������
**        ��
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/28
** ����˵����
**
** �޸���־��
****************************************************************/
int InitEpayShm()
{
    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return FAIL;
    }

    /* �����ڴ��ʼ�� */
    memset((char *)gpShmEpay, 0, SHM_EPAY_SIZE);

    /* ���뿨�����ݵ������ڴ� */
    if(LoadCardToShm() != SUCC)
    {
        return FAIL;
    }

    return SUCC;
}

/****************************************************************
** ��    �ܣ����뿨�����ݵ������ڴ�
** ���������
**        ��
** ���������
**        ��
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/19
** ����˵����
**
** �޸���־��
****************************************************************/
int LoadCardToShm()
{
    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return FAIL;
    }
    
    if(_LoadCard() != SUCC)
    {
        WriteLog(ERROR, "���뿨������ʧ��!");
        
        return FAIL;
    }
    
    if(_LoadLocalCard() != SUCC)
    {
        WriteLog(ERROR, "���뱾�ؿ�������ʧ��!");
        
        return FAIL;
    }
    
    return SUCC;
}

/****************************************************************
** ��    �ܣ����뿨�����ݵ������ڴ�
** ���������
**        ��
** ���������
**        ��
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/19
** ����˵����
**
** �޸���־��
****************************************************************/
static int _LoadCard()
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szBankName[20+1];               /* �������� */
        char    szBankID[11+1];                 /* ���б�ʶ */
        char    szCardName[40+1];               /* ������ */
        char    szCardID[19+1];                 /* ����ʶ�� */
        int     iCardNoLen;                     /* ���ų��� */
        int     iCardSite2;                     /* ���ŵ�����λ�� */
        int     iExpSite2;                      /* ���ŵ�����Ч��λ�� */
        int     iPanSite3;                      /* ���ŵ��˺�λ�� */
        int     iCardSite3;                     /* ���ŵ�����λ�� */
        int     iExpSite3;                      /* ���ŵ���Ч��λ�� */
        char    szCardType[1+1];                /* ������ 0-��ǿ� 1-���ǿ� 2-���⿨ 3-׼���ǿ� */
        int     iCardLevel;                     /* ������ 0-�տ� 1-�� */
    EXEC SQL END DECLARE SECTION;

    T_CARDS     *ptCard;

    /* �����α� */
    EXEC SQL
        DECLARE cur_Card CURSOR FOR
        SELECT bank_name, bank_id, card_name, card_id, card_no_len, card_site2,
               exp_site2, pan_site3, card_site3, exp_site3, card_type, card_level
        FROM cards;
    if(SQLCODE)
    {
        WriteLog(ERROR, "�����α�cur_Cardʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

        return FAIL;
    }

    /* ���α� */
    EXEC SQL OPEN cur_Card;
    if(SQLCODE)
    {
        WriteLog(ERROR, "���α�cur_Cardʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

        return FAIL;
    }

    gpShmEpay->iCardNum = 0;

    while(1)
    {
        memset(szBankName, 0, sizeof(szBankName));
        memset(szBankID, 0, sizeof(szBankID));
        memset(szCardName, 0, sizeof(szCardName));
        memset(szCardID, 0, sizeof(szCardID));
        memset(szCardType, 0, sizeof(szCardType));

        EXEC SQL
            FETCH cur_Card
            INTO :szBankName, :szBankID, :szCardName, :szCardID, :iCardNoLen, :iCardSite2,
                 :iExpSite2, :iPanSite3, :iCardSite3, :iExpSite3, :szCardType, :iCardLevel;
        if(SQLCODE == SQL_NO_RECORD)
        {
            EXEC SQL CLOSE cur_Card;

            break;
        }
        else if(SQLCODE)
        {
            WriteLog(ERROR, "��ȡ�α�cur_Cardʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

            EXEC SQL CLOSE cur_Card;

            return FAIL;
        }

        /* ��ֵ */
        ptCard = gpShmEpay->tCards + gpShmEpay->iCardNum;

        DelTailSpace(szBankName);
        DelTailSpace(szBankID);
        DelTailSpace(szCardName);
        DelTailSpace(szCardID);

        strcpy(ptCard->szBankName, szBankName);
        strcpy(ptCard->szBankId, szBankID);
        strcpy(ptCard->szCardName, szCardName);
        strcpy(ptCard->szCardId, szCardID);
        ptCard->iCardNoLen = iCardNoLen;
        ptCard->iCardSite2 = iCardSite2;
        ptCard->iExpSite2 = iExpSite2;
        ptCard->iPanSite3 = iPanSite3;
        ptCard->iCardSite3 = iCardSite3;
        ptCard->iExpSite3 = iExpSite3;
        ptCard->szCardType[0] = szCardType[0];
        ptCard->iCardLevel = iCardLevel;

        (gpShmEpay->iCardNum)++;

        /* �ж��Ƿ񳬹���󿨱��¼ */
        if(gpShmEpay->iCardNum >= MAX_CARD_NUM)
        {
            WriteLog(ERROR, "Cards too much MAX_CARD_NUM:[%d]", MAX_CARD_NUM);

            EXEC SQL CLOSE cur_Card;

            return FAIL;
        }
    }

    return SUCC;
}

/****************************************************************
** ��    �ܣ����뱾�ؿ������ݵ������ڴ�
** ���������
**        ��
** ���������
**        ��
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/19
** ����˵����
**
** �޸���־��
****************************************************************/
static int _LoadLocalCard()
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szLocalCardID[16+1];            /* ����ʶ�� */
        char    szLocalCardName[40+1];          /* ������ */
        int     iLocalCardNoLen;                /* ���ų��� */
        char    szLocalCardType[1+1];           /* ������ 0-��ǿ� 1-���ǿ� 2-���⿨ 3-׼���ǿ� */
    EXEC SQL END DECLARE SECTION;

    T_LOCALCARDS     *ptLocalCard;

    /* �����α� */
    EXEC SQL
        DECLARE cur_LocalCard CURSOR FOR
        SELECT card_id, card_name, card_no_len, card_type
        FROM local_card;
    if(SQLCODE)
    {
        WriteLog(ERROR, "�����α�cur_LocalCardʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

        return FAIL;
    }

    /* ���α� */
    EXEC SQL OPEN cur_LocalCard;
    if(SQLCODE)
    {
        WriteLog(ERROR, "���α�cur_LocalCardʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

        return FAIL;
    }

    gpShmEpay->iLocalCardNum = 0;

    while(1)
    {
        memset(szLocalCardID, 0, sizeof(szLocalCardID));
        memset(szLocalCardName, 0, sizeof(szLocalCardName));
        memset(szLocalCardType, 0, sizeof(szLocalCardType));

        EXEC SQL
            FETCH cur_LocalCard
            INTO :szLocalCardID, :szLocalCardName, :iLocalCardNoLen, :szLocalCardType;
        if(SQLCODE == SQL_NO_RECORD)
        {
            EXEC SQL CLOSE cur_LocalCard;

            break;
        }
        else if(SQLCODE)
        {
            WriteLog(ERROR, "��ȡ�α�cur_LocalCardʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

            EXEC SQL CLOSE cur_LocalCard;

            return FAIL;
        }

        /* ��ֵ */
        ptLocalCard = gpShmEpay->tLocalCards + gpShmEpay->iLocalCardNum;

        DelTailSpace(szLocalCardID);
        DelTailSpace(szLocalCardName);

        strcpy(ptLocalCard->szCardId, szLocalCardID);
        strcpy(ptLocalCard->szCardName, szLocalCardName);
        ptLocalCard->iCardNoLen = iLocalCardNoLen;
        ptLocalCard->szCardType[0] = szLocalCardType[0];

        (gpShmEpay->iLocalCardNum)++;

        /* �ж��Ƿ񳬹���󿨱��¼ */
        if(gpShmEpay->iLocalCardNum >= MAX_CARD_NUM)
        {
            WriteLog(ERROR, "Local Cards too much MAX_CARD_NUM:[%d]", MAX_CARD_NUM);

            EXEC SQL CLOSE cur_LocalCard;

            return FAIL;
        }
    }

    return SUCC;
}

/****************************************************************
** ��    �ܣ�ɾ��EPAY�����ڴ�
** ���������
**        ��
** ���������
**        ��
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/28
** ����˵����
**
** �޸���־��
****************************************************************/
int RmEpayShm()
{
    WriteLog(TRACE, "ɾ��EPAY�����ڴ濪ʼ");

    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return FAIL;
    }

    /* ɾ�������ڴ� */
    if(RmShm(giShmEpayID) != SUCC)
    {
        WriteLog(ERROR, "ɾ��EPAY�����ڴ�ʧ��");
    }

    WriteLog(TRACE, "ɾ��EPAY�����ڴ�ɹ�");

    gpShmEpay = NULL;

    return SUCC;
}

/****************************************************************
** ��    �ܣ�����������ȡ�������ݹ����ڴ��ַ
** ���������
**        iTransDataIdx             ������������
** ���������
**        ��     
** �� �� ֵ��
**        ��NULL                    �ṹָ��
**        NULL                      ��ȡʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/12/03
** ����˵����
**
** �޸���־��
****************************************************************/
T_App* GetAppAddress(int iTransDataIdx)
{
    if(iTransDataIdx < 0 || iTransDataIdx >= MAX_TRANS_DATA_INDEX)
    {
        WriteLog(ERROR, "������������ֵ����!iTransDataIdx:[%d] MAX_TRANS_DATA_INDEX:[%d]",
                 iTransDataIdx, MAX_TRANS_DATA_INDEX);

        return NULL;
    }

    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return NULL;
    }

    return gpShmEpay->tApp + iTransDataIdx;
}

/****************************************************************
** ��    �ܣ�����������ȡ��������ָ��
** ���������
**        iTransDataIdx             ������������
** ���������
**        ptApp                     app�ṹָ��     
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/28
** ����˵����
**
** �޸���־��
****************************************************************/
int GetApp(int iTransDataIdx, T_App *ptApp)
{
    if(iTransDataIdx < 0 || iTransDataIdx >= MAX_TRANS_DATA_INDEX)
    {
        WriteLog(ERROR, "������������ֵ����!iTransDataIdx:[%d] MAX_TRANS_DATA_INDEX:[%d]",
                 iTransDataIdx, MAX_TRANS_DATA_INDEX);

        return FAIL;
    }

    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return FAIL;
    }

    memcpy(ptApp, gpShmEpay->tApp + iTransDataIdx, sizeof(T_App));

    return SUCC;
}

/****************************************************************
** ��    �ܣ������������ý������ݵ������ڴ�
** ���������
**        iTransDataIdx             ������������
** ���������
**        ptApp                     app�ṹָ��     
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/30
** ����˵����
**
** �޸���־��
****************************************************************/
int SetApp(int iTransDataIdx, T_App *ptApp)
{
    if(iTransDataIdx < 0 || iTransDataIdx >= MAX_TRANS_DATA_INDEX)
    {
        WriteLog(ERROR, "������������ֵ����!iTransDataIdx:[%d] MAX_TRANS_DATA_INDEX:[%d]",
                 iTransDataIdx, MAX_TRANS_DATA_INDEX);

        return FAIL;
    }

    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return FAIL;
    }

    memcpy(gpShmEpay->tApp + iTransDataIdx, ptApp, sizeof(T_App));

    return SUCC;
}

/****************************************************************
** ��    �ܣ����ݴŵ���ȡת�����Ŀ��š������͡������е���Ϣ
** ���������
**        ptApp->szTrack2           ���ŵ�
**        ptApp->szTrack3           ���ŵ�
**        ptApp->szAcqBankId        �յ���ID
** ���������
**        ptApp->szPan              ת��������
**        ptApp->szExpireDate       ת������Ч��
**        ptApp->szOutBankId        ת����������ID
**        ptApp->szOutBankName      ת��������������
**        ptApp->szOutCardName      ת��������
**        ptApp->cOutCardType       ת��������
**        ptApp->iOutCardLevel      ת��������
**        ptApp->iOutCardBelong     ת��������
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/29
** ����˵����
**
** �޸���־��
****************************************************************/
int GetCardType(T_App *ptApp)
{
    T_CARDS     tCard;
    int         iCardBelong;

    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return FAIL;
    }

    if(strlen(ptApp->szTrack2) > 0 &&
       _GetCard(ptApp->szTrack2, CARD_TRACK2, ptApp->szAcqBankId, &tCard, &iCardBelong) == SUCC)
    {
        /* ���� */
        memcpy(ptApp->szPan, ptApp->szTrack2+tCard.iCardSite2, tCard.iCardNoLen);

        /* Ĭ�ϴŵ���Ϣ�еȺź���λΪ��Ч�� */
        memcpy(ptApp->szExpireDate, ptApp->szTrack2+tCard.iCardSite2+tCard.iCardNoLen+1, 4);

        /* ������ID */
        strcpy(ptApp->szOutBankId, tCard.szBankId);

        /* ���������� */
        strcpy(ptApp->szOutBankName, tCard.szBankName);

        /* ������ */
        strcpy(ptApp->szOutCardName, tCard.szCardName);

        /* ������ */
        ptApp->cOutCardType = tCard.szCardType[0];

        /* ������ */
        ptApp->iOutCardLevel = tCard.iCardLevel;

        /* ������ */
        ptApp->iOutCardBelong = iCardBelong;

        return SUCC;
    }
    else if(strlen(ptApp->szTrack3) > 0 &&
       _GetCard(ptApp->szTrack3, CARD_TRACK3, ptApp->szAcqBankId, &tCard, &iCardBelong) == SUCC)
    {
        /* ���� */
        memcpy(ptApp->szPan, ptApp->szTrack3+tCard.iCardSite3, tCard.iCardNoLen);

        /* Ĭ�ϴŵ���Ϣ�еȺź���λΪ��Ч�� */
        memcpy(ptApp->szExpireDate, ptApp->szTrack3+tCard.iCardSite3+tCard.iCardNoLen+1, 4);

        /* ������ID */
        strcpy(ptApp->szOutBankId, tCard.szBankId);

        /* ���������� */
        strcpy(ptApp->szOutBankName, tCard.szBankName);

        /* ������ */
        strcpy(ptApp->szOutCardName, tCard.szCardName);

        /* ������ */
        ptApp->cOutCardType = tCard.szCardType[0];

        /* ������ */
        ptApp->iOutCardLevel = tCard.iCardLevel;

        /* ������ */
        ptApp->iOutCardBelong = iCardBelong;

        return SUCC;
    }

    /* �Ǽ�δʶ�𿨺� */
    _InsertUnknowCard(ptApp->szTrack2, ptApp->szTrack3);

    return FAIL;
}

/****************************************************************
** ��    �ܣ��Ǽ�δʶ��
** ���������
**        szTrack2                  ���ŵ�����
**        szTrack3                  ���ŵ�����
** ���������
**        ��
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/30
** ����˵����
**
** �޸���־��
****************************************************************/
static int _InsertUnknowCard(char *szTrack2, char *szTrack3)
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szHostTrack2[40+1];
        char    szHostTrack3[107+1];
        char    szDate[8+1];
    EXEC SQL END DECLARE SECTION;

    memset(szHostTrack2, 0, sizeof(szHostTrack2));
    memset(szHostTrack3, 0, sizeof(szHostTrack3));
    memset(szDate, 0, sizeof(szDate));

    strcpy(szHostTrack2, szTrack2);
    strcpy(szHostTrack3, szTrack3);
    GetSysDate(szDate);

    BeginTran();

    EXEC SQL
        INSERT INTO unknown_card (track2, track3, s_date, flag)
        VALUES (:szHostTrack2, :szHostTrack3, :szDate, '00');
    if(SQLCODE)
    {
        WriteLog(ERROR, "����δʶ�𿨱�ʧ��(������ͻ����ɺ���)!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

        RollbackTran();

        return FAIL;
    }

    CommitTran();

    return SUCC;
}

/****************************************************************
** ��    �ܣ����ݿ��Ż�ȡת�뿨�Ŀ��š������͡������е���Ϣ
** ���������
**        ptApp->szAccount2         ת�뿨��
** ���������
**        ptApp->szInBankId         ת�뿨������ID
**        ptApp->szInBankName       ת�뿨����������
**        ptApp->cInCardType        ת�뿨������
**        ptApp->iInCardBelong      ת�뿨����
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/29
** ����˵����
**
** �޸���־��
****************************************************************/
int GetAcctType(T_App *ptApp)
{
    T_CARDS     tCard;
    int         iCardBelong;

    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return FAIL;
    }

    if(_GetCard(ptApp->szAccount2, CARD_PAN, ptApp->szAcqBankId, &tCard, &iCardBelong) != SUCC)
    {
        WriteLog(ERROR, "��ȡת�뿨��Ϣʧ��!");

        return FAIL;
    }

    strcpy(ptApp->szInBankId, tCard.szBankId);
    strcpy(ptApp->szInBankName, tCard.szBankName);
    ptApp->cInCardType = tCard.szCardType[0];
    ptApp->iInCardBelong = iCardBelong;

    return SUCC;
}

/****************************************************************
** ��    �ܣ����ݿ��Ŵӹ����ڴ��в�ѯ����Ϣ
** ���������
**        szCardNo                  ����
**        iType                     ���뿨������ 1:���� 2:���ŵ� 3:���ŵ�
**        szBankID                  �����к�
** ���������
**        ptCard                    ����Ϣ
**        piCardBelong              ������
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/29
** ����˵����
**
** �޸���־��
****************************************************************/
static int _GetCard(char *szCardNo, int iType, char *szBankID, T_CARDS *ptCard, int *piCardBelong)
{
    int             i, j;
    int             iCardSite;
    int             iCardNoLen;
    T_CARDS         *ptCardShm;
    T_LOCALCARDS    *ptLocalCard;

    for(i=0;i<gpShmEpay->iCardNum;i++)
    {
        ptCardShm = gpShmEpay->tCards + i;
        
        switch(iType)
        {
            case CARD_PAN:
                iCardSite = 0;
                break;
            case CARD_TRACK2:
                iCardSite = ptCardShm->iCardSite2;
                break;
            case CARD_TRACK3:
                iCardSite = ptCardShm->iCardSite3;
                break;
            default:
                WriteLog(ERROR, "��������δ����iType:[%d]", iType);
                return FAIL;
        }

        if(memcmp(szCardNo+iCardSite, ptCardShm->szCardId, strlen(ptCardShm->szCardId)) == 0)
        {
            /* �жϿ��ų��� */
            for(j=iCardSite;j<strlen(szCardNo);j++)
            {
                if(szCardNo[j] == '=' || szCardNo[j] == 'D')
                {
                    break;
                }
            }
            iCardNoLen = j - iCardSite;

            if(ptCardShm->iCardNoLen != iCardNoLen)
            {
                continue;
            }

            memcpy(ptCard, ptCardShm, sizeof(T_CARDS));

            /* �жϿ����� */
            if(strcmp(szBankID, ptCard->szBankId) != 0)
            {
                *piCardBelong = OTHER_BANK;
            }
            else
            {
                /* ��鱾�ؿ��� */
                for(j=0;j<gpShmEpay->iLocalCardNum;j++)
                {
                    ptLocalCard = gpShmEpay->tLocalCards + j;

                    if(ptLocalCard->iCardNoLen == strlen(szCardNo) &&
                       memcmp(szCardNo, ptLocalCard->szCardId, strlen(ptLocalCard->szCardId)) == 0)
                    {
                        *piCardBelong = LOCAL_BANK_LOCAL_CITY;

                        return SUCC;
                    }
                }

                *piCardBelong = LOCAL_BANK_OTHER_CITY;
            }

            return SUCC;
        }
    }

    return FAIL;
}

/****************************************************************
** ��    �ܣ����ý���ͨѶ״̬�������ڴ�
** ���������
**        szIP                      ����IP
**        iPort                     ����˿ں�
**        lPid                      ������̺�
** ���������
**        ��   
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/28
** ����˵����
**
** �޸���־��
****************************************************************/
int SetAccessPid(char *szIP, int iPort, long lPid)
{
    int         i;
    int         iIPLen;
    T_ACCESS    *ptAccess;

    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return FAIL;
    }

    /* �ź������� */
    PSem(SEM_ACCESS_ID, 1);

    for(i=0;i<MAX_ACCESS_NUM;i++)
	{
	    ptAccess = gpShmEpay->tAccess + i;

		if(strlen(ptAccess->szIp) == 0)
		{
		    iIPLen = strlen(szIP)>sizeof(ptAccess->szIp)?sizeof(ptAccess->szIp):strlen(szIP);
		    memcpy(ptAccess->szIp, szIP, iIPLen);
			ptAccess->lPort = iPort;
			ptAccess->lPid = lPid;

			break;
		}
	}

    /* �ź������� */
    VSem(SEM_ACCESS_ID, 1);

	if(i == MAX_ACCESS_NUM)
	{
        WriteLog(ERROR, "IP:[%s] PORT:[%d]������̸�������!MAX_ACCESS_NUM:[%d]",
                 szIP, iPort, MAX_ACCESS_NUM);

		return FAIL;
	}

    return SUCC;
}

/****************************************************************
** ��    �ܣ�����IP���˿�ͳ�Ʒ��ؽ���PID������ոü�¼
** ���������
**        szIP                      ����IP
**        iPort                     ����˿ں�
** ���������
**        ��   
** �� �� ֵ��
**        >0                        ����PID
**        0                         δ�ҵ���������
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/29
** ����˵����
**
** �޸���־��
****************************************************************/
int GetAccessPid(char *szIP, int iPort)
{
    int         i;
    long        lPid;
    T_ACCESS    *ptAccess;

    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return FAIL;
    }

    for(i=0;i<MAX_ACCESS_NUM;i++)
	{
	    ptAccess = gpShmEpay->tAccess + i;

        if(strcmp(ptAccess->szIp, szIP) == 0 && ptAccess->lPort == iPort)
		{
		    lPid = ptAccess->lPid;
		    
		    memset(ptAccess->szIp, 0, sizeof(ptAccess->szIp));
		    ptAccess->lPort = 0;
		    ptAccess->lPid = 0;
		    
		    return lPid;
		}
	}

	return 0;
}

/****************************************************************
** ��    �ܣ�����IP���˿�ͳ�ƽ���ͨѶ���̸���
** ���������
**        szIP                      ����IP
**        iPort                     ����˿ں�
** ���������
**        ��   
** �� �� ֵ��
**        >0                        ���̸���
**        0                         δ�ҵ�ƥ�����
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/29
** ����˵����
**
** �޸���־��
****************************************************************/
int GetAccessLinkNum(char *szIP, int iPort)
{
    int         i;
    int         iCount;
    T_ACCESS    *ptAccess;

    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return FAIL;
    }

    iCount = 0;

    for(i=0;i<MAX_ACCESS_NUM;i++)
	{
	    ptAccess = gpShmEpay->tAccess + i;

        if(strcmp(ptAccess->szIp, szIP) == 0 && ptAccess->lPort == iPort)
		{
		    iCount++;
		}
	}

	return iCount;
}

/****************************************************************
** ��    �ܣ�ɾ�������ڴ��н���ͨѶ����״̬
** ���������
**        lPid                      ������̺�
** ���������
**        ��   
** �� �� ֵ��
**        SUCC                      ɾ���ɹ�
**        FAIL                      ɾ��ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/28
** ����˵����
**
** �޸���־��
****************************************************************/
int DelAccessPid(long lPid)
{
    int         i;
    int         iIPLen;
    T_ACCESS    *ptAccess;

    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return FAIL;
    }

    /* �ź������� */
    PSem(SEM_ACCESS_ID, 1);

    for(i=0;i<MAX_ACCESS_NUM;i++)
	{
	    ptAccess = gpShmEpay->tAccess + i;

		if(ptAccess->lPid == lPid)
		{
		    memset(ptAccess->szIp, 0, sizeof(ptAccess->szIp));
		    ptAccess->lPort = 0;
			ptAccess->lPid = 0;
		}
	}

    /* �ź������� */
    VSem(SEM_ACCESS_ID, 1);

    return;
}
	
/****************************************************************
** ��    �ܣ����ú�̨ͨѶ״̬�������ڴ�
** ���������
**        lMsgType                  ��̨ͨѶ������Ϣ����
**        iLinkNo                   ��������·���
**        cClitNet                  �ͻ���״̬
**        cServNet                  �����״̬
** ���������
**        ��   
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/28
** ����˵����
**
** �޸���־��
****************************************************************/
int SetHost(long lMsgType, int iLinkNo, char cClitNet, char cServNet)
{
    int     i;
    T_HOST  *ptHost;

    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return FAIL;
    }

    /* �ź������� */
    PSem(SEM_HOST_ID, 1);

    for(i=0;i<MAX_HOST_NUM;i++)
	{
	    ptHost = gpShmEpay->tHost + i;

		if(ptHost->lMsgType == 0)
		{
		    ptHost->lMsgType = lMsgType;
		    ptHost->iLinkNo = iLinkNo;
		    ptHost->cClitNet = cClitNet;
		    ptHost->cServNet = cServNet;

			break;
		}
	}

    /* �ź������� */
    VSem(SEM_HOST_ID, 1);

	if(i == MAX_HOST_NUM)
	{
        WriteLog(ERROR, "lMsgType:[%d] ��̨ͨѶ��������!MAX_HOST_NUM:[%d]",
                 lMsgType, MAX_HOST_NUM);

		return FAIL;
	}

    return SUCC;
}

/****************************************************************
** ��    �ܣ�����̨ͨѶ��·״̬
** ���������
**        lMsgType                  ��̨ͨѶ��Ӧ��Ϣ������Ϣ����
** ���������
**        ��
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/28
** ����˵����
**
** �޸���־��
****************************************************************/
int ChkHostStatus(long lMsgType)
{
    int     i;
    T_HOST  *ptHost;

    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return FAIL;
    }

    for(i=0;i<MAX_HOST_NUM;i++)
	{
	    ptHost = gpShmEpay->tHost + i;

		if(ptHost->lMsgType == lMsgType)
		{
            if(ptHost->cClitNet == 'Y' && ptHost->cServNet == 'Y')
            {
                return SUCC;
            }
		}
	}

    return FAIL;
}

/****************************************************************
** ��    �ܣ�ɾ����̨ͨѶ״̬
** ���������
**        lMsgType                  ��̨ͨѶ������Ϣ����
**        iLinkNo                   ��������·���
** ���������
**        ��   
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/28
** ����˵����
**
** �޸���־��
****************************************************************/
int DelHost(long lMsgType, int iLinkNo)
{
    int     i;
    T_HOST  *ptHost;

    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return FAIL;
    }

    /* �ź������� */
    PSem(SEM_HOST_ID, 1);

    for(i=0;i<MAX_HOST_NUM;i++)
	{
	    ptHost = gpShmEpay->tHost + i;

		if(ptHost->lMsgType == lMsgType && ptHost->iLinkNo == iLinkNo)
		{
		    ptHost->lMsgType = 0;
		    ptHost->iLinkNo = 0;
		    ptHost->cClitNet = 'N';
		    ptHost->cServNet = 'N';
		}
	}

    /* �ź������� */
    VSem(SEM_HOST_ID, 1);

    return;
}

/****************************************************************
** ��    �ܣ���ȡ��������������
** ���������
**        iMaxAliveTime             �������ռ��ʱ��
**                                  (��ǰʱ������������ʱ��Ĳ���ڸò���������������Ա����·���)
** ���������
**        ��   
** �� �� ֵ��
**        >=0                       ����ֵ
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/28
** ����˵����
**
** �޸���־��
****************************************************************/
int GetTransDataIndex(int iMaxAliveTime)
{
    int     i;
    T_TDI   *ptTDI;
    int     iIndex;
    long    lTime;

    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return FAIL;
    }

    iIndex = gpShmEpay->iCurTdi;

    ptTDI = gpShmEpay->tTdi + iIndex;

    time(&lTime);

    /* �ź������� */
    PSem(SEM_TDI_ID, 1);

    for(i=0;i<MAX_TRANS_DATA_INDEX;i++)
    {  
        if(ptTDI->lLastVisitTime == 0 || (lTime - ptTDI->lLastVisitTime) > iMaxAliveTime)
        {
            gpShmEpay->iCurTdi = iIndex+1==MAX_TRANS_DATA_INDEX?0:iIndex+1;

            ptTDI->lLastVisitTime = lTime;
            
            /* �ź������� */
            VSem(SEM_TDI_ID, 1);

            return iIndex;
        }

        iIndex++;

        /* �����������ֵʱ����0���¿�ʼ */
        if(iIndex == MAX_TRANS_DATA_INDEX)
        {
            iIndex = 0;
        }

        ptTDI = gpShmEpay->tTdi + iIndex;
    }

    /* �ź������� */
    VSem(SEM_TDI_ID, 1);

    WriteLog(ERROR, "����������ʹ�ã��޿��������ɹ�����!");

    return FAIL;
}

/****************************************************************
** ��    �ܣ����ݽ����������������÷���ʱ��
** ���������
**        iTransDataIndex           ������������
** ���������
**        ��   
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/12/11
** ����˵����
**
** �޸���־��
****************************************************************/
int SetTdiTime(int iTransDataIdx)
{
    T_TDI   *ptTDI;
    long    lTime;
    
    if(iTransDataIdx < 0 || iTransDataIdx >= MAX_TRANS_DATA_INDEX)
    {
        WriteLog(ERROR, "������������ֵ����!iTransDataIdx:[%d] MAX_TRANS_DATA_INDEX:[%d]",
                 iTransDataIdx, MAX_TRANS_DATA_INDEX);

        return FAIL;
    }

    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return FAIL;
    }

    ptTDI = gpShmEpay->tTdi + iTransDataIdx;

    time(&lTime);

    /* �ź������� */
    PSem(SEM_TDI_ID, 1);

    ptTDI->lLastVisitTime = lTime;

    /* �ź������� */
    VSem(SEM_TDI_ID, 1);

    return SUCC;
}

/****************************************************************
** ��    �ܣ��ͷŽ�������������
** ���������
**        iTransDataIndex           ������������
** ���������
**        ��   
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/12/11
** ����˵����
**
** �޸���־��
****************************************************************/
int FreeTdi(int iTransDataIdx)
{
    T_TDI   *ptTDI;

    if(iTransDataIdx < 0 || iTransDataIdx >= MAX_TRANS_DATA_INDEX)
    {
        WriteLog(ERROR, "������������ֵ����!iTransDataIdx:[%d] MAX_TRANS_DATA_INDEX:[%d]",
                 iTransDataIdx, MAX_TRANS_DATA_INDEX);

        return FAIL;
    }

    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return FAIL;
    }

    ptTDI = gpShmEpay->tTdi + iTransDataIdx;

    /* �ź������� */
    PSem(SEM_TDI_ID, 1);

    ptTDI->lLastVisitTime = 0;

    /* �ź������� */
    VSem(SEM_TDI_ID, 1);

    return SUCC;
}

/****************************************************************
** ��    �ܣ���ӡ�����ڴ�����(����ʹ��)
** ���������
**        iDebug                    ��������
**                                  0:��������
**                                  1:����Cards
**                                  2:���ؿ���LocalCards
**                                  3:����Access
**                                  4:��̨Host
**                                  5:������������TDI
**
** ���������
**        ��   
** �� �� ֵ��
**        SUCC                      �ɹ�
**        FAIL                      ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2012/11/29
** ����˵����
**
** �޸���־��
****************************************************************/
int DebugEpayShm(int iDebug)
{
    int             i;
    T_CARDS         *ptCards;
    T_LOCALCARDS    *ptLocalCards;
    T_ACCESS        *ptAccess;
    T_HOST          *ptHost;
    T_TDI           *ptTdi;

    /* ��ȡ�����ڴ� */
    if(GetEpayShm() != SUCC)
    {
        WriteLog(ERROR, "��ȡEPAY�����ڴ�ʧ��!");

        return FAIL;
    }

    /* ���� */
    if(iDebug == 0 || iDebug == 1)
    {
        printf("Cards:\n");
        printf("iCardNum:[%d]\n", gpShmEpay->iCardNum);
        for(i=0;i<MAX_CARD_NUM;i++)
        {
            ptCards = gpShmEpay->tCards + i;
    
            if(strlen(ptCards->szCardId) > 0)
            {
                printf("Card[%d].szBankName:[%s]\n", i, ptCards->szBankName);
                printf("Card[%d].szBankId:[%s]\n", i, ptCards->szBankId);
                printf("Card[%d].szCardName:[%s]\n", i, ptCards->szCardName);
                printf("Card[%d].szCardId:[%s]\n", i, ptCards->szCardId);
                printf("Card[%d].iCardNoLen:[%d]\n", i, ptCards->iCardNoLen);
                printf("Card[%d].iCardSite2:[%d]\n", i, ptCards->iCardSite2);
                printf("Card[%d].iExpSite2:[%d]\n", i, ptCards->iExpSite2);
                printf("Card[%d].iPanSite3:[%d]\n", i, ptCards->iPanSite3);
                printf("Card[%d].iCardSite3:[%d]\n", i, ptCards->iCardSite3);
                printf("Card[%d].iExpSite3:[%d]\n", i, ptCards->iExpSite3);
                printf("Card[%d].szCardType:[%s]\n", i, ptCards->szCardType);
                printf("Card[%d].iCardLevel:[%d]\n", i, ptCards->iCardLevel);
            }
        }
        printf("\n");
    }

    /* ���ؿ��� */
    if(iDebug == 0 || iDebug == 2)
    {
        printf("LocalCards:\n");
        printf("iLocalCardNum:[%d]\n", gpShmEpay->iLocalCardNum);
        for(i=0;i<MAX_CARD_NUM;i++)
        {
            ptLocalCards = gpShmEpay->tLocalCards + i;
    
            if(strlen(ptLocalCards->szCardId) > 0)
            {
                printf("LocalCard[%d].szCardId:[%s]\n", i, ptLocalCards->szCardId);
                printf("LocalCard[%d].szCardName:[%s]\n", i, ptLocalCards->szCardName);
                printf("LocalCard[%d].iCardNoLen:[%d]\n", i, ptLocalCards->iCardNoLen);
                printf("LocalCard[%d].szCardType:[%s]\n", i, ptLocalCards->szCardType);
            }
        }
        printf("\n");
    }

    if(iDebug == 0 || iDebug == 3)
    {
        printf("Access:\n");
        for(i=0;i<MAX_ACCESS_NUM;i++)
        {  
            ptAccess = gpShmEpay->tAccess + i;
    
            if(strlen(ptAccess->szIp) > 0)
            {
                printf("Access[%d].szIp:[%s]\n", i, ptAccess->szIp);
                printf("Access[%d].lPort:[%d]\n", i, ptAccess->lPort);
                printf("Access[%d].lPid:[%d]\n", i, ptAccess->lPid);
            }
        }
        printf("\n");
    }

    if(iDebug == 0 || iDebug == 4)
    {
        printf("Host:\n");
        for(i=0;i<MAX_HOST_NUM;i++)
        {  
            ptHost = gpShmEpay->tHost + i;
    
            if(ptHost->lMsgType > 0)
            {
                printf("Host[%d].lMsgType:[%d]\n", i, ptHost->lMsgType);
                printf("Host[%d].iLinkNo:[%d]\n", i, ptHost->iLinkNo);
                printf("Host[%d].cClitNet:[%c]\n", i, ptHost->cClitNet);
                printf("Host[%d].cServNet:[%c]\n", i, ptHost->cServNet);
            }
        }
        printf("\n");
    }

    if(iDebug == 0 || iDebug == 5)
    {
        printf("TransDataIndex:\n");
        printf("iCurTdi:[%d]\n", gpShmEpay->iCurTdi);
        for(i=0;i<MAX_TRANS_DATA_INDEX;i++)
        {  
            ptTdi = gpShmEpay->tTdi + i;
    
            if(ptTdi->lLastVisitTime > 0)
            {
                printf("ptTdi[%d].lLastVisitTime:[%ld]\n", i, ptTdi->lLastVisitTime);
            }
        }
        printf("\n");
    }

    return;
}
