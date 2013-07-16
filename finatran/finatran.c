/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨���ڽ��״���ģ��
** �� �� �ˣ����
** �������ڣ�2012-11-08
**
** $Revision: 1.8 $
** $Log: finatran.c,v $
** Revision 1.8  2013/06/07 02:14:40  fengw
**
** 1�������Ƿ��������ж���ش��롣
**
** Revision 1.7  2012/12/25 06:54:43  fengw
**
** 1���޸�web���׼��ͨѶ�˿ںű�������Ϊ�ַ�����
**
** Revision 1.6  2012/12/14 06:32:34  fengw
**
** 1�����ӡ��󶨵绰�����鳤�ȡ��������ȡ��
**
** Revision 1.5  2012/12/07 05:58:04  fengw
**
** 1�����ӻ�ȡ��Ϣ����ID�������á�
**
** Revision 1.4  2012/12/07 02:02:21  fengw
**
** 1������web��ز������ö�ȡ��
**
** Revision 1.3  2012/11/23 09:09:48  fengw
**
** ���ڽ��״���ģ���ʼ�汾
**
** Revision 1.1  2012/11/21 07:20:46  fengw
**
** ���ڽ��״���ģ���ʼ�汾
**
*******************************************************************/

#include "finatran.h"

void _proc_exit(int iSigNo)
{
	CloseDB();

	exit(0);
}

int main(int argc, char *argv[])
{
    int     i;
    int     iMaxCount;          /* ����ģ���������� */
    long    lMsgType;           /* ���״���ģ�������Ϣ���� */
    char    szTmpBuf[64+1];     /* ��ʱ���� */

    /* ��ȡ�������� */
    if(argc != 3)
	{
		printf("parameter too few\n");

		printf("Usage:%s MaxCount MsgType\n", argv[0]);

        exit(-1);
	}

    /* ���ڽ��״���ģ�������̸��� */
	iMaxCount = atoi(argv[1]);

    /* ���ڽ��״���ģ�����������Ϣ���� */
	lMsgType = atoi(argv[2]);

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

    /* �ж��Ƿ������� */
    memset(szTmpBuf, 0 , sizeof(szTmpBuf));
    if(ReadConfig(CONFIG_FILENAME, SECTION_PUBLIC, "CHECK_PHONE", szTmpBuf) != SUCC)
    {
        WriteLog(ERROR, "��ȡ�����ļ�[%s]SECTION:[%s] ������:[%s] ʧ��!",
                 CONFIG_FILENAME, SECTION_PUBLIC, "CHECK_PHONE");

        exit(-1);
    }
    giTeleChkType = atoi(szTmpBuf);

    /* �󶨵绰������λ�� */
    memset(szTmpBuf, 0 , sizeof(szTmpBuf));
    if(ReadConfig(CONFIG_FILENAME, SECTION_PUBLIC, "TELE_NO_LEN", szTmpBuf) != SUCC)
    {
        WriteLog(ERROR, "��ȡ�����ļ�[%s]SECTION:[%s] ������:[%s] ʧ��!",
                 CONFIG_FILENAME, SECTION_PUBLIC, "TELE_NO_LEN");

        exit(-1);
    }
    giTeleChkLen = atoi(szTmpBuf);

	/* fork������� */
    for(i=0;i<iMaxCount;i++)
	{
		switch(fork ())
		{
		    case 0:
			    ProcTrans(lMsgType);
			    break;
		    case -1:
			    exit(-1);
		    default:
			    break;
		}
	}

	return SUCC;
}
