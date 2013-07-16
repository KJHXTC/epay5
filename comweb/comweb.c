/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨web�����������ģ��
** �� �� �ˣ����
** �������ڣ�2012-12-18
**
** $Revision: 1.4 $
** $Log: comweb.c,v $
** Revision 1.4  2012/12/26 08:33:21  fengw
**
** 1������ͨѶԭʼ������־��¼��
**
** Revision 1.3  2012/12/25 07:00:35  fengw
**
** 1���޸�web���׼��ͨѶ�˿ںű�������Ϊ�ַ�����
**
** Revision 1.2  2012/12/21 02:04:03  fengw
**
** 1���޸�Revision��Log��ʽ��
**
*******************************************************************/

#include "comweb.h"

void _proc_exit(int iSigNo)
{
	CloseDB();

	exit(0);
}

int main(int argc, char *argv[])
{
    int     i;
    char    szListenPort[5+1];      /* ���ؼ����˿� */
    int     iServSockFd;            /* �����socket������ */
    int     iClitSockFd;            /* �ͻ���socket������ */
    char    szClitIP[15+1];         /* �ͻ���IP��ַ */
    char    szTmpBuf[64+1];         /* ��ʱ���� */

    /* ��ȡ�������� */
    if(argc != 2)
	{
		printf("parameter too few\n");

		printf("Usage:%s Port\n", argv[0]);

        exit(-1);
	}

    /* ���ؼ����˿� */
    memset(szListenPort, 0, sizeof(szListenPort));
	strcpy(szListenPort, argv[1]);

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

	signal(SIGUSR1, _proc_exit);

    /* Make a back process */
	setpgrp();

    if(GetEpayMsgId() != SUCC)
    {
        exit(-1);
    }

	/* ϵͳ�������ö�ȡ */
    /* ��ȡweb���IP��ַ */
    memset(gszMoniIP, 0 , sizeof(gszMoniIP));
    if(ReadConfig(CONFIG_FILENAME, SECTION_COMMUNICATION, "WEB_IP", gszMoniIP) != SUCC)
    {
        WriteLog(ERROR, "��ȡ�����ļ�[%s]SECTION:[%s] ������:[%s] ʧ��!",
                 CONFIG_FILENAME, SECTION_COMMUNICATION, "WEB_IP");

        exit(-1);
    }

    /* ��ȡweb��ض˿ں� */
    memset(gszMoniPort, 0 , sizeof(gszMoniPort));
    if(ReadConfig(CONFIG_FILENAME, SECTION_COMMUNICATION, "WEB_PORT", gszMoniPort) != SUCC)
    {
        WriteLog(ERROR, "��ȡ�����ļ�[%s]SECTION:[%s] ������:[%s] ʧ��!",
                 CONFIG_FILENAME, SECTION_COMMUNICATION, "WEB_PORT");

        exit(-1);
    }

    /* ��ȡ��������������ʱʱ�� */
    memset(szTmpBuf, 0 , sizeof(szTmpBuf));
    if(ReadConfig(CONFIG_FILENAME, SECTION_PUBLIC, "TIMEOUT_TDI", szTmpBuf) != SUCC)
    {
        WriteLog(ERROR, "��ȡ�����ļ�[%s]SECTION:[%s] ������:[%s] ʧ��!",
                 CONFIG_FILENAME, SECTION_PUBLIC, "TIMEOUT_TDI");

        exit(-1);
    }
    giTdiTimeOut = atoi(szTmpBuf);

    /* �򿪼����˿ڣ�����5��ʧ�ܺ��������� */
    for(i=0;i<5;i++)
    {
        iServSockFd = CreateSrvSocket(szListenPort, "tcp", 5);
        if(iServSockFd > 0)
        {
            break;
        }
        else
        {
            WriteLog(ERROR, "�򿪼����˿�[%s]��[%d]��ʧ��!", szListenPort, i+1);

            sleep(10);
        }
    }

    if(i == 5)
    {
        close(iServSockFd);

        exit(-1);
    }

    WriteLog(TRACE, "comwebģ��pid:[%ld] socket:[%ld]�ȴ��ͻ�������!", getpid(), iServSockFd);

    /* ���պ�̨�����ӣ��ɹ����븸����ͬ�� */
	while(1)
	{
        memset(szClitIP, 0, sizeof(szClitIP));
        iClitSockFd = SrvAccept(iServSockFd, szClitIP);
        if(iClitSockFd < 0)
        {
            WriteLog(ERROR, "comweb�ͻ��˽���ʧ��!");

            continue;
        }

        WriteLog(TRACE, "comweb�ͻ���IP:[%s]���ӽ���!", szClitIP);

		/* ����һ���ӽ��̣����ӽ��̽��н��״��������̼����غ�˿� */
		switch(fork())
		{
		    /* forkʧ�� */
            case -1:
                WriteLog(ERROR, "comwebģ��fork�ӽ���ʧ��!");

                close(iClitSockFd);

                break;
            /* �ӽ��̽��н��״��� */
            case 0:
                /* �ص��̳е�iServSockFd���� */
			    close(iServSockFd);

			    WriteLog(TRACE, "comwebģ���ӽ���pid:[%ld]����!", getpid()); 
			    
			    if(OpenDB() != SUCC)
			    {
			        WriteLog(ERROR, "�����ݿ�ʧ��!"); 

                    close(iClitSockFd);

			        return FAIL;
			    }

			    ChildProcess(iClitSockFd);

			    close(iClitSockFd);

			    CloseDB();

			    exit(0);
			/* �����̼����غ�˿ڣ��ȴ����� */
	    	default: 
                /* �ص�iClitSockFd���� */
			    close(iClitSockFd);

			    break;
		}
	}

	return SUCC;
}

int ChildProcess(int iSockFd)
{
    T_App   tApp;                               /* app�ṹ */
    int     iTransDataIndex;                    /* ������������ */
    char    szLenBuf[2+1];                      /* ���ĳ���Buf */
    int     iRet;                               /* �������ý�� */
    int     iLen;                               /* ���ĳ��� */
    char    szReqBuf[MAX_SOCKET_BUFLEN+1];      /* ������ */

    memset(&tApp, 0, sizeof(T_App));

    /* ���ձ��ĳ��� */
	memset(szLenBuf, 0, sizeof(szLenBuf));

    iRet = ReadSockFixLen(iSockFd, 0, 2, szLenBuf);
    if(iRet != 2)
    {
        WriteLog(ERROR, "����Web���������ĳ���ʧ��!iRet:[%d]", iRet);

        return FAIL;
    }

    iLen = szLenBuf[0] * 256 + szLenBuf[1];

    if(iLen <= 0 && iLen > MAX_SOCKET_BUFLEN)
    {
        WriteLog(ERROR, "Web���������ĳ��ȴ���!iLen:[%d]", iLen);

        return FAIL;
    }

    /* ���ձ��� */
	memset(szReqBuf, 0, sizeof(szReqBuf));

    iRet = ReadSockFixLen(iSockFd, 0, iLen, szReqBuf);
    if(iRet != iLen)
    {
        WriteLog(ERROR, "����Web����������ʧ��!Ԥ�ڽ��ճ���:[%d] ʵ�ʽ��ճ���:[%d]", iLen, iRet);

        return FAIL;
    }

    /* ��¼ԭʼͨѶ��־ */
    WriteHdLog(szReqBuf, iLen, "comweb recv web req");

    /* �����Ĳ�� */
    if(UnpackWebReq(&tApp, szReqBuf, iLen) != SUCC)
    {
        WriteLog(ERROR, "Web���������Ĳ��ʧ��!����:[%d][%s]", iLen, szReqBuf);

        return FAIL;
    }

    /* ��ȡ������������ */
    if((iTransDataIndex = GetTransDataIndex(giTdiTimeOut)) == FAIL)
    {
        strcpy(tApp.szRetCode, ERR_SYSTEM_ERROR);

        return FAIL;
    }

    tApp.lTransDataIdx = iTransDataIndex;
    
    /* ��¼app�ṹ���� */
    WriteAppStru(&tApp, "comweb recv from web");

    ProcWebTrans(&tApp);

    SendWebRsp(&tApp, iSockFd);

    /* ��¼app�ṹ���� */
    WriteAppStru(&tApp, "comweb send to web");

    return SUCC;
}