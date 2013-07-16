/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨�Զ�����ģ��
** �� �� �ˣ����
** �������ڣ�2012-11-08
**
** $Revision: 1.7 $
** $Log: autovoid.ec,v $
** Revision 1.7  2013/03/22 05:34:20  fengw
**
** 1������TPDU��ֵ��䣬�����жϳ���������ƽ̨������POS����
**
** Revision 1.6  2012/12/21 01:57:30  fengw
**
** 1���޸�Revision��Log��ʽ��
**
*******************************************************************/

#include "autovoid.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL END DECLARE SECTION;

void _proc_exit(int iSigNo)
{
	CloseDB();

	exit(0);
}

int main(int argc, char *argv[])
{
    int     i;
    char    szTmpBuf[64+1];

	/* ���ɾ������, ʹ�������ն��ѽ� */
	/* ���ն��ѽں�,scanf�Ⱥ������޷�ʹ�� */
	switch(fork())
	{
	    case 0:
            break;
        case -1:
            exit(-1);
        default:
		    exit(0);
	}

    /* �źŴ��� */
	for(i=0;i<32;i++)
	{
        if(i == SIGALRM || i == SIGKILL ||
           i == SIGUSR1 || i == SIGUSR2)
        {
            continue;
        }

		signal(i, SIG_IGN);
	}

    /* ��ȡ���е���Ϣ���� */
    if ( GetEpayMsgId() != SUCC )
    { 
        WriteLog(ERROR, "GetEpayMsgId() Error!");
        exit(-1);
    }    

	signal(SIGUSR1, _proc_exit);

    /* Make a back process */
	setpgrp();

	/* ϵͳ�������ö�ȡ */
    /* ������ʱʱ�� */
    memset(szTmpBuf, 0 , sizeof(szTmpBuf));
    if(ReadConfig(CONFIG_FILENAME, SECTION_AUTOVOID, "TIMEOUT_VOID", szTmpBuf) != SUCC)
    {
        WriteLog(ERROR, "��ȡ�����ļ�[%s]SECTION:[%s] ������:[%s] ʧ��!",
                 CONFIG_FILENAME, SECTION_AUTOVOID, "TIMEOUT_VOID");

        exit(-1);
    }
    giVoidTimeOut = atoi(szTmpBuf);

    /* �������ʱ�� */
    memset(szTmpBuf, 0 , sizeof(szTmpBuf));
    if(ReadConfig(CONFIG_FILENAME, SECTION_AUTOVOID, "AUTO_SLEEP_TIME", szTmpBuf) != SUCC)
    {
        WriteLog(ERROR, "��ȡ�����ļ�[%s]SECTION:[%s] ������:[%s] ʧ��!",
                 CONFIG_FILENAME, SECTION_AUTOVOID, "AUTO_SLEEP_TIME");

        exit(-1);
    }
    giSleepTime = atoi(szTmpBuf);

    /* ��ȡ��������������ʱʱ�� */
    memset(szTmpBuf, 0 , sizeof(szTmpBuf));
    if(ReadConfig(CONFIG_FILENAME, SECTION_PUBLIC, "TIMEOUT_TDI", szTmpBuf) != SUCC)
    {
        WriteLog(ERROR, "��ȡ�����ļ�[%s]SECTION:[%s] ������:[%s] ʧ��!",
                 CONFIG_FILENAME, SECTION_PUBLIC, "TIMEOUT_TDI");

        exit(-1);
    }
    giTdiTimeOut = atoi(szTmpBuf);

    glPid = getpid();

    /*����������˯�߼���*/
    sleep(giSleepTime);

    while(1)
    {
        /* �ж����ݿ��Ƿ�� */
        if(ChkDBLink() != SUCC && OpenDB() != SUCC )
        {
            WriteLog(ERROR, "�����ݿ�ʧ��!");
            
            sleep(giSleepTime);

            continue;
        }

        if(ProcVoid() == FAIL )
        {
            WriteLog(ERROR, "ProcVoid error");
        }

        sleep(giSleepTime);
    }

    CloseDB();

	return SUCC;
}

int ProcVoid() 
{
    EXEC SQL BEGIN DECLARE SECTION;
        char    szShopNo[15+1];
        char    szPosNo[15+1];
        char    szPsamNo[16+1];
        char    szPosDate[8+1];
        long    lPosTrace;
        char    szMac[16+1];
    EXEC SQL END DECLARE SECTION;

    int     iTransDataIndex;
    T_App   tApp;

    /* �����α� */
	EXEC SQL
	    DECLARE cur_void CURSOR
	    FOR SELECT shop_no, pos_no, pos_date, psam_no, pos_trace, mac
	    FROM void_ls
	    WHERE recover_flag = 'N' AND
	    (return_code = '00' or return_code = '68' or return_code = '96' or return_code = 'Q9');
	if(SQLCODE)
	{  
        WriteLog(ERROR, "�����α�cur_voidʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

        return FAIL;
    }
    
    /* ���α� */
    EXEC SQL OPEN cur_void;
    if(SQLCODE)
    {
        WriteLog(ERROR, "���α�cur_voidʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

        return FAIL;
    }

    while(1) 
    {
        memset(szShopNo, 0, sizeof(szShopNo));
        memset(szPosNo, 0, sizeof(szPosNo));
        memset(szPsamNo, 0, sizeof(szPsamNo));
        memset(szPosDate, 0, sizeof(szPosDate));
        memset(szMac, 0, sizeof(szMac));

        EXEC SQL
            FETCH cur_void INTO :szShopNo, :szPosNo, :szPosDate, :szPsamNo, lPosTrace, szMac;
        if(SQLCODE == SQL_NO_RECORD) 
        {
            EXEC SQL CLOSE cur_void;

            break;
        }
        else if(SQLCODE) 
        {
            WriteLog(ERROR, "��ȡ�α�cur_voidʧ��!SQLCODE=%d SQLERR=%s", SQLCODE, SQLERR);

            EXEC SQL CLOSE cur_void;

            return FAIL;
        }

        if((iTransDataIndex = GetTransDataIndex(giTdiTimeOut)) == FAIL)
        {
            EXEC SQL CLOSE cur_void;

            return FAIL;
        }

        memset(&tApp, 0, sizeof(T_App));
        tApp.lTransDataIdx = iTransDataIndex;

        tApp.iTransType = AUTO_VOID;
        strcpy(tApp.szTransName, "�����Գ�");
        strcpy(tApp.szPsamNo, szPsamNo);
        strcpy(tApp.szShopNo, szShopNo);
        strcpy(tApp.szPosNo, szPosNo);
        tApp.lOldPosTrace= lPosTrace;
        tApp.lAccessToProcMsgType= 1;
        tApp.lProcToPresentMsgType= 1;
        AscToBcd(szMac, 16, 0, tApp.szMac);

        /* ����tpdu��ַ�������жϳ���������ƽ̨���� */
        memcpy(tApp.szSourceTpdu, "\xFF\xFF", 2);
        memcpy(tApp.szTargetTpdu, "\xFF\xFF", 2);

        /* ���ú��к���ΪȫF�������绰����Ϸ��Լ�� */
        strcpy(tApp.szCallingTel, "FFFFFFFF");
        strcpy(tApp.szCalledTelByTerm, "FFFFFFFF");
        strcpy(tApp.szCalledTelByNac, "FFFFFFFF");

        /* ������Ϣ���� */
        tApp.lProcToAccessMsgType = glPid;

        /* ������Ϣ���� */
        tApp.lAccessToProcMsgType = 1;
        
        /* Ĭ����Ӧ��ΪNN */
        strcpy(tApp.szHostRetCode, "NN");
        
        if(SendVoidReq(&tApp,giVoidTimeOut) != SUCC)
        {
            EXEC SQL CLOSE cur_void;

            return FAIL;
        }

        /* �����ɹ����޸ĳ�����ʶ */
        if(memcmp(tApp.szHostRetCode, "00", 2) == 0)
        {
            BeginTran();

            EXEC SQL
                UPDATE void_ls
                SET recover_flag = 'Y'
                WHERE shop_no = :szShopNo AND pos_no = :szPosNo AND 
                pos_date = :szPosDate AND pos_trace = :lPosTrace;
            if(SQLCODE)
            {
                WriteLog(ERROR, "���³������� ShopNo:[%s] PosNo:[%s] PosDate:[%s] PosTrace:[%ld] ��־ʧ��ʧ��!SQLCODE=%d SQLERR=%s",
                         szShopNo, szPosNo, szPosDate, lPosTrace, SQLCODE, SQLERR);

                RollbackTran();

                continue;
            }

            CommitTran();
        }
    }

    return SUCC;
}
