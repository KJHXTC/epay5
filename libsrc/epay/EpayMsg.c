/******************************************************************
** Copyright(C)2012 - 2015���������豸���޹�˾
** ��Ҫ���ݣ�epay���ļ�,��Ҫ������Ϣ����
** �� �� �ˣ�������
** �������ڣ�2012/11/8
** $Revision: 1.5 $
** $Log: EpayMsg.c,v $
** Revision 1.5  2013/06/28 08:35:16  fengw
**
** 1����Ӵ�����ɾ��ʱ��¼TRACE��־�����ֹ���ʱ���ڸ���ȷ�����⡣
**
** Revision 1.4  2012/11/29 08:04:19  chenrb
** �޶�������ʾ��Ϣ,�Է�ӳʵ�����
**
** Revision 1.3  2012/11/29 02:28:52  gaomx
** *** empty log message ***
**
** Revision 1.2  2012/11/29 02:23:56  gaomx
** *** empty log message ***
**
** Revision 1.1  2012/11/28 01:38:17  gaomx
** add by gaomx
**
** Revision 1.6  2012/11/28 01:20:59  gaomx
** �޸���Ϣ���е��ļ�Ϊ����·��
**
** Revision 1.5  2012/11/27 07:02:39  gaomx
** *** empty log message ***
**
** Revision 1.4  2012/11/27 06:13:47  epay5
**
** dosתunix��ʽ
**
** Revision 1.3  2012/11/27 05:21:47  epay5
** modified by gaomx
**
*******************************************************************/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <setjmp.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <sys/sem.h>
#include <sys/shm.h>
#include <unistd.h>
#include "errno.h"
#include "../../incl/user.h"
#include "../../incl/app.h"
#include "EpayMsg.h"

int	giGetMsgFlag = 0;

static	jmp_buf		env1, env_hsm;
static	void	TimeoutProcess1( int nouse );
static	void	TimeoutProcHsm( int nouse );

/*****************************************************************
** ��    ��:�����µ���Ϣ���л��߻�ȡ���е���Ϣ����
** �������:
           ��
** �������:
           ��
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by gaomx 20121119�淶�������Ű��޶�
**
****************************************************************/
int	GetEpayMsgId( )
{
	char szPath[80];
	
	sprintf( szPath, "%s%s", getenv("WORKDIR"),MSGFILE );
	giProcToPresent = GetMsgQue( szPath, PROC_TO_PRESENT_QUEUE );
	if ( giProcToPresent < 0 )
    {
        return ( FAIL );
    }
    giPresentToProc = GetMsgQue( szPath, PRESENT_TO_PROC_QUEUE );
	if ( giPresentToProc < 0 )
    {
        return ( FAIL );
    }
    giProcToAccess = GetMsgQue( szPath, PROC_TO_ACCESS_QUEUE );
	if ( giProcToAccess < 0 )
    {
        return ( FAIL );
    }
    giAccessToProc = GetMsgQue( szPath, ACCESS_TO_PORC_QUEUE );
	if ( giAccessToProc < 0 )
    {
        return ( FAIL );
    }
    giToHsm = GetMsgQue(szPath, TO_HSM_QUEUE);
	if ( giToHsm < 0 )
    {
        return ( FAIL );
    }
    giFromHsm = GetMsgQue(szPath, FROM_HSM_QUEUE);
	if ( giFromHsm < 0 )
    {
        return ( FAIL );
    }

	giGetMsgFlag = 1;

	return( SUCC );
}


/*****************************************************************
** ��    ��:������Ϣ����
** �������:
           ��
** �������:
           ��
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by gaomx 20121119�淶�������Ű��޶�
**
****************************************************************/
int CreateEpayMsg ( )
{
	char szPath[80];	
	
	WriteLog(TRACE, "����EPAY��Ϣ���п�ʼ");
    
    sprintf( szPath, "%s%s", getenv("WORKDIR"),MSGFILE );
	if(CreateMsgQue(szPath, ACCESS_TO_PORC_QUEUE) <0 )
    {
		WriteLog(ERROR,"creat msg ACCESS_TO_PORC_QUEUE err!");
		return FAIL;
	}	
	
	if(CreateMsgQue(szPath, PROC_TO_ACCESS_QUEUE) <0 )
    {
		WriteLog(ERROR,"creat msg PROC_TO_ACCESS_QUEUE err!");
		return FAIL;
	}	

	if(CreateMsgQue(szPath, PRESENT_TO_PROC_QUEUE) <0 )
    {
		WriteLog(ERROR,"creat msg PRESENT_TO_PROC_QUEUE err!");
		return FAIL;
	}	

	if(CreateMsgQue(szPath, PROC_TO_PRESENT_QUEUE) <0 )
    {
		WriteLog(ERROR,"creat msg PROC_TO_PRESENT_QUEUE err!");
		return FAIL;
	}	
	
	if(CreateMsgQue(szPath, TO_HSM_QUEUE) <0 )
    {
		WriteLog(ERROR,"creat msg TO_HSM_QUEUE err!");
		return FAIL;
	}	

	if(CreateMsgQue(szPath, FROM_HSM_QUEUE) <0 )
    {
		WriteLog(ERROR,"creat msg FROM_HSM_QUEUE err!");
		return FAIL;
	}

	WriteLog(TRACE, "����EPAY��Ϣ���гɹ�");

	return ( SUCC );
}

/*****************************************************************
** ��    ��:ɾ����Ϣ����
** �������:
           ��
** �������:
           ��
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by gaomx 20121119�淶�������Ű��޶�
**
****************************************************************/
int RmEpayMsg ()
{
	int iFlag , iRet ;
	
    iRet = FAIL;
	iFlag = SUCC;

    WriteLog(TRACE, "ɾ��EPAY��Ϣ���п�ʼ");
		
	/* ��ȡ���е���Ϣ���� */
	iRet = GetEpayMsgId();
	if ( iRet != SUCC )
	{
		return iRet;	
	}
	
	if( RmMsgQue( giAccessToProc ) != SUCC )
	{
		WriteLog( ERROR, "rm msg ACCESS_TO_PORC_QUEUE fail" );
		iFlag = FAIL;
	}

	if( RmMsgQue( giProcToAccess ) != SUCC )
	{
		WriteLog( ERROR, "rm msg PROC_TO_ACCESS_QUEUE fail" );
		iFlag = FAIL;
	}
	
	if( RmMsgQue( giProcToPresent ) != SUCC )
	{
		WriteLog( ERROR, "rm msg PRESENT_TO_PROC_QUEUE fail" );
		iFlag = FAIL;
	}
	
	if( RmMsgQue( giPresentToProc ) != SUCC )
	{
		WriteLog( ERROR, "rm msg PRESENT_TO_PROC_QUEUE fail" );
		iFlag = FAIL;
	}
	
	if( RmMsgQue( giToHsm ) != SUCC )
	{
		WriteLog( ERROR, "rm msg TO_HSM_QUEUE fail" );
		iFlag = FAIL;
	}
	
	if( RmMsgQue( giFromHsm ) != SUCC )
	{
		WriteLog( ERROR, "rm msg FROM_HSM_QUEUE fail" );
		iFlag = FAIL;
	}

    WriteLog(TRACE, "ɾ��EPAY��Ϣ���гɹ�");

	return iFlag;
}

/*****************************************************************
** ��    ��:����Ϣ�����з�����Ϣ
** �������:
           msgid		��Ϣ���еı�ʶ��
 *		lMsgType	��Ϣ������
 *		pszSendData	��������
** �������:
           ��
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by gaomx 20121119�淶�������Ű��޶�
**
****************************************************************/
int SendMessage(iMsgId, lMsgType, pszSendData)
int	iMsgId;
long 	lMsgType;
char	*pszSendData;
{
	int	iRet;
	T_MessageStru tMsgStru;
	struct msqid_ds msInfo;

	tMsgStru.lMsgType = lMsgType;
	memcpy(tMsgStru.szMsgText, pszSendData, MAX_MSG_SIZE);

	iRet = msgsnd(iMsgId, &tMsgStru, MAX_MSG_SIZE, ~IPC_NOWAIT);
	if( iRet == FAIL )
	{
		WriteLog(ERROR, "send msg error[%d-%s] MsgType[%ld] qnum[%ld]", errno,strerror(errno), tMsgStru.lMsgType, msInfo.msg_qnum);
		return( FAIL );
	}

	return( SUCC );
}


/*****************************************************************
** ��    ��:����Ϣ�����ж�ȡ��Ϣ
** �������:
        lMsgType	��Ϣ������
 *		timeout		0�����޵ȴ�������Ϣ
 *				>0����ʱʱ��
** �������:
            pszReadData	�յ�������
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by gaomx 20121119�淶�������Ű��޶�
**
****************************************************************/
int 	ReceiveMessage(iMsgId, lMsgType, iTimeOut, pszReadData)
int	iMsgId;
long 	lMsgType;
int 	iTimeOut;
char	*pszReadData;
{
	int	iRet;
	T_MessageStru tMsgStru;

	if( iTimeOut != 0 )
    {
		signal(SIGALRM, TimeoutProcess1);
	
		if( sigsetjmp(env1,1) != 0 )
		{
			WriteLog( TRACE, "read msg timeout!" );
			return( TIMEOUT );
		}
	
		alarm(iTimeOut);
	}

	iRet = msgrcv(iMsgId, (char *)&tMsgStru, MAX_MSG_SIZE, lMsgType, 0);
	if( iRet == FAIL )
    {
		alarm(0);
		WriteLog(ERROR, "read msg error msgid=%d lMsgType=%ld error=[%d-%s]", iMsgId, lMsgType, errno,strerror(errno));
		return( FAIL );
	}
	alarm(0);

	memcpy(pszReadData, tMsgStru.szMsgText, MAX_MSG_SIZE);

	return( SUCC );
}

/*****************************************************************
** ��    ��:����Ϣ�����з�����Ϣ
** �������:
        msgid		��Ϣ���еı�ʶ��
 *		lMsgType	��Ϣ������
 *		pszSendData	�������ݣ���СΪHSMSIZE
** �������:
            ��
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by gaomx 20121119�淶�������Ű��޶�
**
****************************************************************/
int SendHsmMessage(iMsgId, lMsgType, pszSendData)
int	iMsgId;
long 	lMsgType;
char	*pszSendData;
{
	int	iRet;
	T_HsmStru tMsgStru;
	struct msqid_ds msInfo;

	tMsgStru.lMsgType = lMsgType;
	memcpy(tMsgStru.szMsgText, pszSendData, HSMSIZE);

	iRet = msgsnd(iMsgId, &tMsgStru, HSMSIZE, ~IPC_NOWAIT);
	if( iRet == FAIL )
	{
		WriteLog(ERROR, "send msg error[%d-%s] MsgType[%ld] qnum[%ld]", errno,strerror(errno), tMsgStru.lMsgType, msInfo.msg_qnum);
		return( FAIL );
	}

	return( SUCC );
}

/*****************************************************************
** ��    ��:����Ϣ�����ж�ȡ��Ϣ
** �������:
        lMsgType	��Ϣ������
 *		timeout		0�����޵ȴ�������Ϣ
 *				>0����ʱʱ��
** �������:
            pszReadData	�յ�������
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:robin
** ��    ��:2009/08/25
** ����˵��:
** �޸���־:mod by gaomx 20121119�淶�������Ű��޶�
**
****************************************************************/
int 	ReceiveHsmMessage(iMsgId, lMsgType, iTimeOut, pszReadData)
int	iMsgId;
long 	lMsgType;
int 	iTimeOut;
char	*pszReadData;
{
	int	iRet;
	T_HsmStru tMsgStru;

	if( iTimeOut != 0 )
	{
	    signal(SIGALRM, TimeoutProcHsm);
	
		if( sigsetjmp(env_hsm, 1) != 0 )
		{
			return( TIMEOUT );
		}

		alarm(iTimeOut);
	}

	iRet = msgrcv(iMsgId, (char *)&tMsgStru, HSMSIZE, lMsgType, 0);
	if( iRet == FAIL )
	{
		alarm(0);
		WriteLog(ERROR, "read msg error msgid=%d lMsgType=%ld error=[%d-%s]", iMsgId, lMsgType, errno,strerror(errno));
		return( FAIL );
	}

	alarm(0);

	memcpy(pszReadData, tMsgStru.szMsgText, HSMSIZE);

	return( SUCC );
}

/*************************************************************
*  ��    ��: 	
*		��������״���㷢�ͽ����������ж���Ϣ�����Ƿ�������
*		�����������ȴ�һ��ʱ���ٷ��͡�
*  �������: 
*		lMsgType		������Ϣ���ͣ�ȡ�Թ������ݽṹ��
*						��lToTransMsgType
*  		lTransDataIdx	��������������
*  �������: 	��
*  ��    �أ�	SUCC	�ɹ�
*				FAIL	ʧ��
*************************************************************/
int SendAccessToProcQue ( lMsgType, lTransDataIdx )
long 	lMsgType;
long lTransDataIdx ;
{	
	char szSendData[MAX_MSG_SIZE+1];

	sprintf(szSendData,"%ld",lTransDataIdx);
	return(SendMessage(giAccessToProc, lMsgType, szSendData));
}

/*************************************************************
*  ��    ��: 	
*		���״���������㷢�ͽ���Ӧ�����ж���Ϣ�����Ƿ�
*		�����������������ȴ�һ��ʱ���ٷ��͡�
*  �������: 
*		lMsgType		������Ϣ���ͣ�ȡ�Թ������ݽṹ�е�
*						lFromTransMsgType(�ڽ���㷢������֮ǰ
*						��ֵ)
*  		lTransDataIdx	��������������
*  �������: 	��
*  ��    �أ�	SUCC	�ɹ�
*				FAIL	ʧ��
*************************************************************/
int SendProcToAccessQue( lMsgType, lTransDataIdx )
long 	lMsgType;
long lTransDataIdx ;
{
	char szSendData[MAX_MSG_SIZE+1];
	
    sprintf(szSendData,"%ld",lTransDataIdx);
	return(SendMessage(giProcToAccess, lMsgType, szSendData));
}



/*************************************************************
*  ��    ��: 	
*		��ȫ����������hsm���ͽ����������ж���Ϣ�����Ƿ�
*		�����������������ȴ�һ��ʱ���ٷ��͡�
*		��$HOME/libepay/hsmcli.c�ļ��и���ȫ���������á�
*  �������: 
*		lMsgType		������Ϣ���ͣ�ȡ�Թ������ݽṹ��
*						��lTransDataIdx
*  		tFace			���͵����ݽṹ
*  �������: 	��
*  ��    �أ�	SUCC	�ɹ�
*				FAIL	ʧ��
*************************************************************/
int SendToHsmQue( lMsgType, tFace )
long 	lMsgType;
T_Interface *tFace;
{
	char szSendData[HSMSIZE+1];

	if( !giGetMsgFlag )
	{
		if( GetEpayMsgId( ) == FAIL )
		{
			WriteLog( ERROR, "gmsg error!" );
			return( FAIL );
		}
		giGetMsgFlag = 1;
	}

	memcpy(szSendData, (char *)tFace, HSMSIZE);
	return(SendHsmMessage(giToHsm, lMsgType, szSendData));
}

/*************************************************************
*  ��    ��: 	
*		hsm���ܷ���ģ����ȫ�������󷽷��ͽ���Ӧ�����ж�
*		��Ϣ�����Ƿ������������������ȴ�һ��ʱ���ٷ��͡�
*  �������: 
*		lMsgType		������Ϣ���ͣ�ȡ��tFace�ṹ��
*						��lSoureMsgType
*  		tFace			���͵����ݽṹ
*  �������: 	��
*  ��    �أ�	SUCC	�ɹ�
*				FAIL	ʧ��
*************************************************************/
int SendFromHsmQue( lMsgType, tFace )
long 	lMsgType;
T_Interface *tFace;
{
	char szSendData[HSMSIZE+1];

	memcpy(szSendData,(char *)tFace, HSMSIZE);
	return(SendHsmMessage(giFromHsm, lMsgType, szSendData));
}

/*************************************************************
*  ��    ��: 	
*		���״������ҵ���ύ�㷢�ͽ����������ж���Ϣ�����Ƿ�
*		�����������������ȴ�һ��ʱ���ٷ��͡�
*  �������: 
*		lMsgType		������Ϣ���ͣ�ȡ�Թ������ݽṹ��
*						��lToHostMsgType
*  		lTransDataIdx	��������������
*  �������: 	��
*  ��    �أ�	SUCC	�ɹ�
*				FAIL	ʧ��
*************************************************************/
int SendProcToPresentQue ( lMsgType ,lTransDataIdx )
long 	lMsgType;
long lTransDataIdx ;
{
	char szSendData[MAX_MSG_SIZE+1];
	
    sprintf(szSendData,"%ld",lTransDataIdx);
	return(SendMessage(giProcToPresent, lMsgType, szSendData));
}

/*************************************************************
*  ��    ��: 	
*		ҵ���ύ�����״���㷢�ͽ���Ӧ�����ж���Ϣ�����Ƿ�
*		�����������������ȴ�һ��ʱ���ٷ��͡�
*  �������: 
*		lMsgType		������Ϣ���ͣ�ȡ�Թ������ݽṹ�е�
*						lFromHostMsgType(�ڽ��״���㷢������֮ǰ
*						��ֵ)
*  		lTransDataIdx	��������������
*  �������: 	��
*  ��    �أ�	SUCC	�ɹ�
*				FAIL	ʧ��
*************************************************************/
int SendPresentToProcQue( lMsgType, lTransDataIdx )
long 	lMsgType;
long lTransDataIdx ;
{
	char szSendData[MAX_MSG_SIZE+1];

	sprintf(szSendData,"%ld",lTransDataIdx);
	return(SendMessage(giPresentToProc, lMsgType, szSendData));
}


/*************************************************************
*  ��    ��: 	
*		�����ӽ��״������ս���Ӧ��
*  �������: 
*		lMsgType		������Ϣ���ͣ����ս��̵Ľ��̺� 
*		lTimeOut		��ʱʱ�䣬0��ʾ���޵ȴ�
*  �������: 	
*  		lTransDataIdx	��������������
*  ��    �أ�	SUCC	�ɹ�
*				FAIL	ʧ��
*************************************************************/
int RecvProcToAccessQue( lMsgType, lTimeOut, lTransDataIdx )
long	lMsgType;
long lTimeOut;
long *lTransDataIdx;
{
	char szReadData[MAX_MSG_SIZE+1];
	int iRet;
	
	iRet = ReceiveMessage(giProcToAccess, lMsgType, lTimeOut, szReadData);
	if( iRet != SUCC )
    {
		return iRet;
    }
	*lTransDataIdx = atol(szReadData);
	
	return( SUCC );
}

/*************************************************************
*  ��    ��: 	
*		���״����ӽ������ս�������
*  �������: 
*		lMsgType		������Ϣ���ͣ�����ģ������ȡ��module��
*						��msg_type�ֶ�
*		lTimeOut		��ʱʱ�䣬0��ʾ���޵ȴ�
*  �������: 	
*  		lTransDataIdx	��������������
*  ��    �أ�	SUCC	�ɹ�
*				FAIL	ʧ��
*************************************************************/
int RecvAccessToProcQue( lMsgType, lTimeOut, lTransDataIdx )
long	lMsgType;
long lTimeOut;
long *lTransDataIdx;
{
	char szReadData[MAX_MSG_SIZE+1];
	int iRet;
	
	iRet = ReceiveMessage(giAccessToProc, lMsgType, lTimeOut, szReadData);
	if( iRet != SUCC )
    {
		return iRet;
    }
	*lTransDataIdx = atol(szReadData);
	
	return( SUCC );
}

/*************************************************************
*  ��    ��: 	
*		���״�����ҵ���ύ����ս���Ӧ��
*  �������: 
*		lMsgType		������Ϣ���ͣ����ս��̵Ľ��̺� 
*		lTimeOut		��ʱʱ�䣬0��ʾ���޵ȴ�
*  �������: 	
*  		lTransDataIdx	��������������
*  ��    �أ�	SUCC	�ɹ�
*				FAIL	ʧ��
*************************************************************/
int RecvPresentToProcQue( lMsgType, lTimeOut, lTransDataIdx )
long	lMsgType;
long lTimeOut;
long *lTransDataIdx;
{
	char szReadData[MAX_MSG_SIZE+1];
	int iRet;
	
	iRet = ReceiveMessage(giPresentToProc, lMsgType, lTimeOut, szReadData);
	if( iRet != SUCC )
	{
	    return iRet;
    }
	*lTransDataIdx = atol(szReadData);
	
	return( SUCC );
}

/*************************************************************
*  ��    ��: 	
*		ҵ���ύ��ӽ��״������ս�������
*  �������: 
*		lMsgType		������Ϣ���ͣ�����ģ������ȡ��module��
*						��msg_type�ֶ�
*		lTimeOut		��ʱʱ�䣬0��ʾ���޵ȴ�
*  �������: 	
*  		lTransDataIdx	��������������
*  ��    �أ�	SUCC	�ɹ�
*				FAIL	ʧ��
*************************************************************/
int RecvProcToPresentQue( lMsgType, lTimeOut, lTransDataIdx  )
long	lMsgType;
long lTimeOut;
long *lTransDataIdx;
{
	char szReadData[MAX_MSG_SIZE+1];
	int iRet;
	
	iRet = ReceiveMessage(giProcToPresent, lMsgType, lTimeOut, szReadData);
	if( iRet != SUCC )
	{
        return iRet;
    }
	*lTransDataIdx = atol(szReadData);
	
	return( SUCC );
}
/*************************************************************
*  ��    ��: 	
*		���״����ӽ������ս�������
*		��$HOME/libepay/hsmcli.c�ļ��и���ȫ���������á�
*  �������: 
*		lMsgType		������Ϣ���ͣ�ȡ��tFace�ṹ
*						��lSourceMsgType�ֶ�
*		lTimeOut		��ʱʱ�䣬0��ʾ���޵ȴ�
*  �������: 	
*  		tFace		�������ݽṹ
*  ��    �أ�	SUCC	�ɹ�
*				FAIL	ʧ��
*************************************************************/
int RecvFromHsmQue( lMsgType, lTimeOut, tFace )
long	lMsgType;
long	lTimeOut;
T_Interface *tFace;
{
	char szReadData[HSMSIZE+1];
	int iRet;

	iRet = ReceiveHsmMessage(giFromHsm, lMsgType, lTimeOut, szReadData);
	if( iRet != SUCC )
	{
    	return iRet;
    }
	memcpy((char *)tFace, szReadData, HSMSIZE);

	return SUCC;
}

/*************************************************************
*  ��    ��: 	
*		���״����ӽ������ս�������
*  �������: 
*		lMsgType		������Ϣ����
*		lTimeOut		��ʱʱ�䣬0��ʾ���޵ȴ�
*  �������: 	
*  		tFace		�������ݽṹ
*  ��    �أ�	SUCC	�ɹ�
*				FAIL	ʧ��
*************************************************************/
int RecvToHsmQue ( lMsgType, lTimeOut, tFace )
long	lMsgType;
long	lTimeOut;
T_Interface *tFace;
{
	char szReadData[HSMSIZE+1];
	int iRet;

	iRet = ReceiveHsmMessage(giToHsm, lMsgType, lTimeOut, szReadData);
	if( iRet != SUCC )
	{
    	return iRet;
    }
	memcpy((char *)tFace, szReadData, HSMSIZE);

	return SUCC;
}


/* �ں�������ת */
static	void	TimeoutProcess1( int nouse )
{
	siglongjmp( env1, 1 );
}

 /* �ں�������ת */
static	void	TimeoutProcHsm( int nouse )
{
	siglongjmp( env_hsm, 1 );
}

/**************************************************************************
 *  ��    ��: �����Ϣ����
 *
 *  �������: iReadType ---  ���б�ʶ
 *      ROUTE MONITOR TO_TRANS FROM_TRANS TO_HOST FROM_HOST
 *      TO_HSM FROM_HSM
 *
 *  �������: 
 *
 *  ��    �أ�0
 *
 *  ��    ��: Robin
 *
 *  ��    ��: 2001/06/23
 *
 *  �� �� ��:
 *
 *  �޸�����:
 *************************************************************************/
int
ClearMessage( int iReadType )
{
 	int iRet, iMsgId, iNum;
    long lMsgType, lTimeOut, lTransDataIdx;
    struct msqid_ds msInfo;
    T_MessageStru tMsgStru;
    T_Interface tHsmFace;
    char  szBuffer[2000], szTitle[512], szTmpBuf[256];

    if( GetEpayMsgId( ) == FAIL )
    {
        WriteLog( ERROR, "gmsg error!" );
        return( FAIL );
    }

    lTimeOut = 0;
    switch ( iReadType )
    {	    
	    case ACCESS_TO_PORC_QUEUE:
	        iMsgId = giAccessToProc;
	        sprintf( szTitle, "ScriptPos/ComWeb/AutoVoid->FinaTran/ManaTran" );
	        break;
	    case PROC_TO_ACCESS_QUEUE:
	        iMsgId = giProcToAccess;
	        sprintf( szTitle, "FinaTran/ManaTran->ScriptPos/ComWeb/AutoVoid" );
	        break;
	    case PROC_TO_PRESENT_QUEUE:
	        iMsgId = giProcToPresent;
	        sprintf( szTitle, "FinaTran->PayGate/ServiceGate" );
	        break;
	    case PRESENT_TO_PROC_QUEUE:
	        iMsgId = giPresentToProc;
	        sprintf( szTitle, "PayGate/ServiceGate->FinaTran" );
	        break;
	    case TO_HSM_QUEUE:
	        iMsgId = giToHsm;
	        sprintf( szTitle, "--->Hsm" );
	        break;
	    case FROM_HSM_QUEUE:
	        iMsgId = giFromHsm;
	        sprintf( szTitle, "Hsm--->" );
	        break;
		default:
		    WriteLog( ERROR, "error read type %ld", iReadType );
		return FAIL;
    }
    iRet = msgctl(iMsgId, IPC_STAT, &msInfo);
    if( iRet == FAIL)
    {
        WriteLog( ERROR, "msgctl fail [%ld-%s]", errno,strerror(errno) );
        return FAIL;
    }
    iNum = msInfo.msg_qnum;
    WriteLog(TRACE, "msg_q[%s] qnum[%ld]", szTitle, iNum );
    sprintf( szTmpBuf, " qnum[%d] ", iNum );
    strcat( szTitle, szTmpBuf );
    lMsgType = 0;
    for( ; iNum > 0; iNum --)
   	{
        if( iReadType == FROM_HSM_QUEUE )
        {
            iRet = RecvFromHsmQue( lMsgType, lTimeOut, &tHsmFace );
            if( iRet != SUCC )
            {
                WriteLog( ERROR, "read from hsm fail" );
                return FAIL;
            }
            WriteHsmStru( &tHsmFace, szTitle );
	    }
	    else if( iReadType == TO_HSM_QUEUE )
	    {
            iRet = RecvToHsmQue( lMsgType, lTimeOut, &tHsmFace );
            if( iRet != SUCC )
            {
                WriteLog( ERROR, "read to hsm fail" );
                return FAIL;
            }
            WriteHsmStru( &tHsmFace, szTitle );
        }
        else
        {
            iRet = msgrcv(iMsgId, (char *)&tMsgStru, MAX_MSG_SIZE, lMsgType, IPC_NOWAIT);
            if( iRet == FAIL )
            {
                WriteLog(ERROR, "read msg error error=[%d-%s]",errno,strerror(errno));
                return FAIL;
            }
            lTransDataIdx = atol(tMsgStru.szMsgText);
            WriteLog( TRACE, "lTransDataIdx = [%ld]" ,lTransDataIdx);
        }
    }
    return SUCC;
}



/**************************************************************************
 *  ��    �ܣ� ���trans->tohost��ĳ�����Ľ���������Ϣ 
 *
 *  �������:  lMsgType		��Ϣ�����ͣ����ǲ��û�������+1��Ϊ��Ϣ����
 *		0��������Ϣ��������ָ����Ϣ
 *
 *  ��    ��:  ��
 *
 *  ��    ��:  Robin
 *
 *  ��    ��:  2007/06/21
 *
 *  �� �� ��:
 *
 *  �޸�����:
 *
 *  ˵    ��: 
 *************************************************************************/
void ClearTransRequ( lMsgType )
long	lMsgType;
{
	char szReadData[MAX_MSG_SIZE+1];
	int iRet, i;

	for( i=0; i<30; i++ )
	{
		iRet = ReceiveMessage(giProcToPresent, lMsgType, 1, szReadData);
		if( iRet != SUCC )
			return;
	}
}


