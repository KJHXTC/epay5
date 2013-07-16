/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨�ն�����Կ����ģ��
** �� �� �ˣ����
** �������ڣ�2012-11-19
**
** $Revision: 1.1 $
** $Log: masterkey.ec,v $
** Revision 1.1  2012/12/07 01:19:47  fengw
**
** 1���ն�����Կ���ɳ����ʼ�汾��
**
*******************************************************************/

#include "masterkey.h"

EXEC SQL BEGIN DECLARE SECTION;
    EXEC SQL INCLUDE SQLCA;
EXEC SQL END DECLARE SECTION;

int main(int argc, char *argv[])
{
    EXEC SQL BEGIN DECLARE SECTION;
        int     iKeyIndex;                      /* ��Կ���� */
        char    szMasterKey[32+1];              /* �ַ����ն˵��ն�����Կ */
        char    szMasterKeyLMK[32+1];           /* LKM���ܺ���ն�����Կ */
        char    szMasterKeyChk[4+1];            /* �ն�����ԿУ��ֵ */
    EXEC SQL END DECLARE SECTION;

    int     i;
    int     iKeyCount;                          /* �����ն�����Կ�� */
    int     iCount;                             /* �ɹ����� */
    char    szKeyData[128+1];                   /* ��Կ���� */

    /* ��ȡ�������� */
    if(argc < 2)
	{
		printf("��������\n");

		printf("ʾ��:%s ��Ҫ������Կ����(0-%d)\n", argv[0], MAX_MASTERKEY_GENERATE);

        exit(-1);
	}

	iKeyCount = atoi(argv[1]);

	/* �����Կ���� */
	if(iKeyCount <=0 || iKeyCount > MAX_MASTERKEY_GENERATE)
	{
		printf("��������\n");

		printf("ʾ��:%s ��Ҫ������Կ����(0-%d)\n", argv[0], MAX_MASTERKEY_GENERATE);

        exit(-1);
	}

    /* �����ݿ� */
    if(OpenDB() != SUCC)
    {
        printf("�����ݿ�ʧ��!");

        exit(-1);
    }

    /* ��ȡ��ǰ��Կ������ */
	EXEC SQL
	    SELECT NVL(MAX(key_index), 0)
	    INTO :iKeyIndex FROM pos_key;
	if(SQLCODE)
	{
	    printf("ȡ��ǰ��Կ������ʧ��!SQLCODE=%d SQLERR=%s\n", SQLCODE, SQLERR);

	    CloseDB();

	    exit(-1);
	}

	iCount = 0;

	for(i=1;i<=iKeyCount;i++)
	{
        /* ��ʼ���� */
        BeginTran();

	    memset(szKeyData, 0, sizeof(szKeyData));
		if(HsmGetMasterKey(szKeyData) != SUCC)
		{
			printf("��ȡ�ն�����Կʧ��!\n");

            break;
		}

        /* �ӵ�ǰ��Կ�����ż�һ��ʼ��������Կ */
        iKeyIndex++;

        memset(szMasterKey, 0, sizeof(szMasterKey));
        memset(szMasterKeyLMK, 0, sizeof(szMasterKeyLMK));
        memset(szMasterKeyChk, 0, sizeof(szMasterKeyChk));

		memcpy(szMasterKeyLMK, szKeyData, 32);
		memcpy(szMasterKey, szKeyData+32, 32);
		memcpy(szMasterKeyChk, szKeyData+64, 4);

		EXEC SQL
		    INSERT INTO pos_key (key_index, master_key, master_key_lmk, master_chk)
		    VALUES(:iKeyIndex, :szMasterKey, :szMasterKeyLMK, :szMasterKeyChk);
		if(SQLCODE)
		{
			printf("�����ն�����Կʧ��!SQLCODE=%d SQLERR=%s\n", SQLCODE, SQLERR);

			RollbackTran();

            break;
		}

		CommitTran();

		iCount++;
	}

	CloseDB();
	
	if(iKeyCount > iCount)
	{
	    printf("�����ն�����Կ���ϣ�������%d���ն�����Կ\n", iCount);
    }
    else
    {
        printf("%d���ն�����Կ�������!\n", iCount);
    }

	exit(0);
}