/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ���ʽ�����ret_desc�����õķ�����Ϣ
** �� �� �ˣ� wukj
** �������ڣ� 20121220
**
** $Revision: 1.5 $
** $Log: FmtRetDesc.ec,v $
** Revision 1.5  2013/06/14 02:25:30  fengw
**
** 1���޸�szAddiAmount�ֶδ�����룬���������жϡ�
**
** Revision 1.4  2012/12/20 07:04:51  wukj
** *** empty log message ***
**
*******************************************************************/
# include <stdlib.h>
# include "tools.h"
# include "app.h"
# include "errcode.h"
# include "transtype.h"
# include "app.h"

typedef struct {
   char    szFieldName[51];        //��Ҫ��ʽ�����ֶ�
   char    szFormatInfo[80];       //��ʽ��Ϣ
   int     iFormatInfoLen;         //��ʽ��Ϣ����
}T_FMT_RET_DESC;

#define DEBUGON

#ifdef DB_ORACLE
EXEC SQL BEGIN DECLARE SECTION;
        EXEC SQL INCLUDE SQLCA;
EXEC SQL EnD DECLARE SECTION;
#endif
/*******************************************************************
 *	��������: ���ݿ�����ö�ָ�����׷�����Ϣ���и�ʽ��;
 *	����ֵ:	SUCC  ��ʽ���ɹ�
 *		FAIL ��ʽ��ʧ��
 *		1	���δ����
 *
 *	wukj 20120216	
*******************************************************************/

FormatRetDesc(ptAppStru,szRetData,iDataLen)
T_App *ptAppStru;
char	*szRetData;
int	*iDataLen;
{
	char	szFormat[201];	//������Ϣ
	int 	i,j;
	int	iRet;
	int	iLen;
	char	szLen[10];
	char	*pcPosition;	
        T_FMT_RET_DESC tFmtRetDesc[11];

	EXEC SQL BEGIN DECLARE SECTION ;
	char	szFieldName[81];
	char	szFieldFormat[150];	
	char	cStatus;	
	int	iTransType;
	EXEC SQL END DECLARE SECTION ;
	
	iTransType = ptAppStru->iTransType;
	memset(szFormat,0x00,sizeof(szFormat));
	//ȡ�ý��׵ķ�����Ϣ��ʽ�����ü�¼
	EXEC SQL SELECT
		NVL(FIELD_NAME,' '),
		NVL(FIELD_FORMAT, ' '),
		NVL(STATUS, ' ')
	INTO 
		:szFieldName,
		:szFieldFormat,
		:cStatus
	FROM RET_DESC
	WHERE	TRANS_TYPE = :iTransType and STATUS = '1';
	if(SQLCODE == 1403)
	{
		//û�����÷�����Ϣ��ʽ,ȡĬ�Ϸ�����Ϣ
//		WriteLog(TRACE,"û�����÷�����Ϣ��ʽ,ȡĬ�Ϸ�����Ϣ");
		return 1;
	}
	else if(SQLCODE != 0)
	{
		WriteLog(ERROR,"ȡ������Ϣ��ʽ�������SQLCODE[%d]",SQLCODE);
		strcpy( ptAppStru->szRetCode, ERR_SYSTEM_ERROR );
		return FAIL;
	}
	else
	{
#ifdef DEBUGON
		// for test
//		strcpy(ptAppStru->szAmount,"00011110000");
		//test end
#endif
		DelTailSpace(szFieldName);
		DelTailSpace(szFieldFormat);
		if(strlen(szFieldName) == 0||strlen(szFieldFormat) == 0)
		{
			//û�����÷�����Ϣ��ʽ,ȡĬ�Ϸ�����Ϣ
			WriteLog(ERROR,"û�����÷�����Ϣ��ʽ,ȡĬ�Ϸ�����Ϣ");
			return 1;
		}
		i = 0;
		//����������õ��ֶ���,��ʽ��Ϣ�ֲ�,��ȡapp�ṹֵ�����ʽ
		while(GetStrData(szFieldName,i,";",tFmtRetDesc[i].szFieldName) > 0)
		{
#ifdef DEBUGON
WriteLog(TRACE,"�ֶ�[%s]",tFmtRetDesc[i].szFieldName);
#endif
			if((iRet = GetStrData(szFieldFormat,i,"%s",tFmtRetDesc[i].szFormatInfo)) <= 0)
			{
				//�޶�Ӧ�ĸ�ʽ
				WriteLog(ERROR,"��[%d]���ֶ�[%s]�޶�Ӧ��ʽ",i,tFmtRetDesc[i].szFieldName);
				break;
			}
			tFmtRetDesc[i].iFormatInfoLen = iRet;
#ifdef DEBUGON
WriteLog(TRACE,"��ʽ����ϢLEN[%d][%s]",tFmtRetDesc[i].iFormatInfoLen,tFmtRetDesc[i].szFormatInfo);
#endif
			//ȡֵ��ʽ��
			iRet = Format(ptAppStru,&tFmtRetDesc[i]);
			if(iRet != 0)
			{
				WriteLog(ERROR,"δ�����ֶλ��ʽ���ֶ�[%s]����",tFmtRetDesc[i].szFieldName);
				return FAIL;
			}
#ifdef DEBUGON
WriteLog(TRACE,"��ʽ������ϢLEN[%d][%s]",tFmtRetDesc[i].iFormatInfoLen,tFmtRetDesc[i].szFormatInfo);
#endif
			i++;
		}
		if(i == 0)
		{
			//�ֶβ��ʧ��
			WriteLog(ERROR,"�ֶβ��ʧ��,ȡĬ�Ϸ�����Ϣ");
			return 1;
		}
		iLen = 0;
		//���ṹ����ƴ�Ӽ��õ�������Ϣ
		memset(szFormat,0x00,sizeof(szFormat));
		for(j = 0;j<i;j++)
		{
			//strcat(szFormat,tFmtRetDesc[j].szFormatInfo);
			memcpy(szFormat+iLen,tFmtRetDesc[j].szFormatInfo,tFmtRetDesc[j].iFormatInfoLen);
			iLen += tFmtRetDesc[j].iFormatInfoLen;
		}
		DelTailSpace(szFormat);
		//�����з�\n
		while((pcPosition = strstr(szFormat,"\\n")) != NULL)
		{
			//��\n�滻Ϊ���з�
			//memcpy(pcPosition," \n",2);
			*pcPosition = '\n';
			*(++pcPosition) =  0;
			while(*(pcPosition+1) != 0)
			{
				*(pcPosition) = *(pcPosition+1);
				pcPosition ++;
			}
			iLen --;
		}
		szFormat[iLen] = 0;
		*iDataLen = iLen;
#ifdef DEBUGON
WriteLog(TRACE,"������ϢLen[%d][%s]",iLen,szFormat);
#endif
		memcpy(szRetData,szFormat,iLen);
		szRetData[iLen] = 0;
		return SUCC;
	}
}

int Format(ptAppStru,tFmtRetDesc)
T_App *ptAppStru;
T_FMT_RET_DESC	*tFmtRetDesc;
{
	char	szFldName[50+1];
	char	szField[80+1];
	int	iFieldLen;
	long int  lAmount;
	char	szTmp[21];

	memset(szField,0x00,sizeof(szField));
	memset(szFldName,0x00,sizeof(szFldName));
	strcpy(szFldName,tFmtRetDesc->szFieldName);	
	DelTailSpace(szFldName);
	ToLower(szFldName);
	if(strcmp(szFldName,"szhostdate") == 0)
	{
		strcpy(szField ,ptAppStru->szHostDate);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"szhosttime")== 0)
	{
		strcpy(szField ,ptAppStru->szHostTime);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"szsourcetpdu") == 0)
	{
		strcpy(szField ,ptAppStru->szSourceTpdu);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"sztargettpdu") == 0)
	{
		strcpy(szField ,ptAppStru->szTargetTpdu);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"szpan") == 0)
	{
		strcpy(szField ,ptAppStru->szPan);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"szproccode") == 0)
	{
		strcpy(szField ,ptAppStru->szProcCode);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"szamount") == 0)
	{
		sprintf(szField ,"%lf",atoll(ptAppStru->szAmount)/100);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"itranstype") == 0)
	{
		sprintf(szField ,"%d",ptAppStru->iTransType);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"ioldtranstype") == 0)
	{
		sprintf(szField ,"%d",ptAppStru->iOldTransType);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"sztransname") == 0)
	{
		strcpy(szField ,ptAppStru->szTransName);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"lpostrace") == 0)
	{
		sprintf(szField ,"%d",ptAppStru->lPosTrace);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"loldpostrace") == 0)
	{
		sprintf(szField ,"%d",ptAppStru->lOldPosTrace);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"szpostime") == 0)
	{
		strcpy(szField ,ptAppStru->szPosTime);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"szposdate") == 0)
	{
		strcpy(szField ,ptAppStru->szPosDate);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"szexpiredate") == 0)
	{
		strcpy(szField ,ptAppStru->szExpireDate);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"szsettledate") == 0)
	{
		strcpy(szField ,ptAppStru->szSettleDate);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"szoutbankid") == 0)
	{
		strcpy(szField ,ptAppStru->szOutBankId);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"szacqbankid") == 0)
	{
		strcpy(szField ,ptAppStru->szAcqBankId);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"szoutbankname") == 0)
	{
		strcpy(szField ,ptAppStru->szOutBankName);
		iFieldLen = strlen(szField);
	}
	
	else if(strcmp(szFldName,"szholdername") == 0)
	{
		strcpy(szField ,ptAppStru->szHolderName);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"szretrirefnum") == 0)
	{
		strcpy(szField ,ptAppStru->szRetriRefNum);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"szauthcode") == 0)
	{
		strcpy(szField ,ptAppStru->szAuthCode);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"szretcode") == 0)
	{
		strcpy(szField ,ptAppStru->szRetCode);
		iFieldLen = strlen(szField);
	}
	else if(strcmp(szFldName,"szretdesc") == 0)
	{
		strcpy(szField ,ptAppStru->szRetDesc);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"szhostretcode") == 0)
	{
		strcpy(szField ,ptAppStru->szHostRetCode);
		iFieldLen = strlen(szField);	
	}
	
	else if(strcmp(szFldName,"szposno") == 0)
	{
		strcpy(szField ,ptAppStru->szPosNo);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"szshopno") == 0)
	{
		strcpy(szField ,ptAppStru->szShopNo);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"szshopname") == 0)
	{
		strcpy(szField ,ptAppStru->szShopName);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"szdeptno") == 0)
	{
		strcpy(szField ,ptAppStru->szDeptNo);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"szoutcardname") == 0)
	{
		strcpy(szField ,ptAppStru->szOutCardName);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"szaccount2") == 0)
	{
		strcpy(szField ,ptAppStru->szAccount2);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"szinbankid") == 0)
	{
		strcpy(szField ,ptAppStru->szInBankId);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"szInBankName") == 0)
	{
		strcpy(szField ,ptAppStru->szInBankName);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"szpasswd") == 0)
	{
		strcpy(szField ,ptAppStru->szPasswd);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"sznewpasswd") == 0)
	{
		strcpy(szField ,ptAppStru->szNewPasswd);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"szaddiamount") == 0)
	{
        if(ptAppStru->szAddiAmount[0] == 'C')
        {
	    	sprintf(szField,"%.2lf",atoll(ptAppStru->szAddiAmount+1)/100.00);
		    iFieldLen = strlen(szField);	
        }
        else
        {
            szField[0] = '-';

	    	sprintf(szField+1,"%.2lf",atoll(ptAppStru->szAddiAmount+1)/100.00);
		    iFieldLen = strlen(szField)+1;	
        }
	}
	else if(strcmp(szFldName,"szshoptype") == 0)
	{
		strcpy(szField ,ptAppStru->szShopType);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"lsystrace") == 0)
	{
		sprintf(szField ,"%ld",ptAppStru->lSysTrace);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"sztranscode") == 0)
	{
		strcpy(szField ,ptAppStru->szTransCode);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"sznexttranscode") == 0)
	{
		strcpy(szField ,ptAppStru->szNextTransCode);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"szpsamno") == 0)
	{
		strcpy(szField ,ptAppStru->szPsamNo);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"szfinancialcode") == 0)
	{
		strcpy(szField ,ptAppStru->szFinancialCode);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"szbusinesscode") == 0)
	{
		strcpy(szField ,ptAppStru->szBusinessCode);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"lrate") == 0)
	{
		sprintf(szField ,"%ld",ptAppStru->lRate);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"szappver") == 0)
	{
		strcpy(szField ,ptAppStru->szAppVer);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"szoperno") == 0)
	{
		strcpy(szField ,ptAppStru->szOperNo);
		iFieldLen = strlen(szField);	
	}
	else if(strcmp(szFldName,"szreserved") == 0)
	{
		memcpy(szField ,ptAppStru->szReserved,ptAppStru->iReservedLen);
		iFieldLen = ptAppStru->iReservedLen;	
	}
	else
	{
		//WriteLog(ERROR,"δ���û����õ��ֶ�������ȷ szFldName[%s]",szFldName);
		return -1;
	}
	DelTailSpace(szField);
	//strcat(tFmtRetDesc->szFormatInfo,szField);
	memcpy(tFmtRetDesc->szFormatInfo+tFmtRetDesc->iFormatInfoLen,szField,iFieldLen);
	tFmtRetDesc->iFormatInfoLen += iFieldLen;
	WriteLog(TRACE,"iFormatInfoLen[%d]",tFmtRetDesc->iFormatInfoLen);
	tFmtRetDesc->szFormatInfo[tFmtRetDesc->iFormatInfoLen] = 0;
	DelTailSpace(tFmtRetDesc->szFormatInfo);
	return 0;
}

