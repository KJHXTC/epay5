/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�TLV���ݸ�ʽ����
 *  �� �� �ˣ�fengwei
 *  �������ڣ�2012-9-24
 * ----------------------------------------------------------------
 * $Revision: 1.8 $
 * $Log: Tlv.c,v $
 * Revision 1.8  2012/12/21 05:40:31  wukj
 * *** empty log message ***
 *
 * Revision 1.7  2012/12/20 06:08:21  chenrb
 * ����DebugTLV�����д������BcdToAsc������
 *
 * Revision 1.6  2012/12/17 07:16:53  fengw
 *
 * 1���޸�DebugTLV��������TLV����ֱ�����뵽TRACE��־��
 *
 * Revision 1.5  2012/12/14 09:17:55  fengw
 *
 * 1���޸�GetValueByTag��������ֵ��
 * 2���޸�PackTLV����ע�͡�
 *
 * Revision 1.4  2012/12/13 05:06:45  fengw
 *
 * 1�������淶����
 *
 * Revision 1.3  2012/11/27 06:51:08  linqil
 * ��������pub.h �޸�return���
 *
 * Revision 1.2  2012/11/20 05:39:22  chenjr
 * modi interface (str_ASCTOBCD��str_BCDTOASC-->AscToBcd BcdToAsc)
 *
 * Revision 1.1  2012/11/20 03:27:37  chenjr
 * init
 *
 * ----------------------------------------------------------------
 */

#include <string.h>
#include <stdio.h>

#include "Tlv.h"
#include "pub.h"
#include "user.h"

/* ----------------------------------------------------------------
 * ��    �ܣ�����Tagռ���ֽ���
 * ���������szTag     Tag��ǩ
 *           iTagType  Tag(��ǩ)����;
 *                     0 ��ͨ����,һ��Tagռ��һ���ֽ�
 *                     1 ��׼����,��Tag��ǩ�ĵ�һ���ֽ�(�ֽڰ�������������
 *                       ����ߵ�Ϊ��һ���ֽڣ�bit˳�������෴)��bit1-bit5
 *                       Ϊ"11111",��˵��Tag���Ȳ�ֹһ���ֽ�,�����м��ֽ�
 *                       �ο���һ�ֽڵ�bit8,���bit8Ϊ1,�ٿ���һ�ֽڵ�bit8
 *                       ֱ����һ�ֽڵ�bit8Ϊ0ֹ����Tag�����һ���ֽ�.
 * ���������
 * �� �� ֵ��>0 Tag����(��λ�ֽ�)��0 ����ʧ��
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
static int _calc_tag_len(char* szTag, int iTagType)
{
    int iTagLen;
    int i;

    switch (iTagType)
    {
        case TAG_NORMAL:
            /* Tag���ȹ̶�Ϊһ�ֽ� */
            iTagLen = 1;
            break;
        case TAG_STANDARD:
            /* ��һ���ֽ�bit5-bit1Ϊ11111ʱ��Tag���Ȳ�����һ���ֽ� */
            if ((szTag[0] & 0x1F) == 0x1F)
            {
                /* �����ֽ�bit8Ϊ1,��ʾ��������һ���ֽ�,Ϊ0��ʾ���һ���ֽ� */
                for (i=1; i<MAX_TAG_LEN;i++)
                {
                    if ((szTag[i] & 0x80) != 0x80)
                    {
                        break;
                    }
                }

                iTagLen = 1 + i;
            }
            /* ����Tag����Ϊһ�ֽ� */
            else
            {
                iTagLen = 1;
            }
            break;
        default:
            iTagLen = 0;
            break;
    }

    return iTagLen;
}

/*****************************************************************
** ��    �ܣ�����TLV��Tagֵ
** ���������
**		szTag		Tag
**		iTagType	Tag���ͣ�˵���ο�_calc_tag_len��������˵��
** ���������
**		szTagBuf	���TagֵBuf
** �� �� ֵ�� 
**		>0		Tagռ���ֽ���
**		0		����ʧ��
** ��    �ߣ�
**		fengwei
** ��    �ڣ�
**		2012/09/24
** ����˵����
**		����tlv�⺯���ڲ����ã��ⲿ������
** �޸���־��
****************************************************************/
static int _set_tag(char* szTag, int iTagType, char* szTagBuf)
{
	int iTagLen;

	iTagLen = _calc_tag_len(szTag, iTagType);

	if(iTagLen > 0 && iTagLen <= MAX_TAG_LEN)
	{
		memcpy(szTagBuf, szTag, iTagLen);
	}

	return iTagLen;
}

/*****************************************************************
** ��    �ܣ���TLV��ʽ�����л�ȡTagֵ
** ���������
**		szBuf		TLV��ʽ����
**		iTagType	Tag���ͣ�˵���ο�_calc_tag_len��������˵��
** ���������
**		szTagBuf	���TagֵBuf
** �� �� ֵ�� 
**		>0		Tagռ���ֽ���
**		0		��ȡʧ��
** ��    �ߣ�
**		fengwei
** ��    �ڣ�
**		2012/09/24
** ����˵����
**		����tlv�⺯���ڲ����ã��ⲿ������
** �޸���־��
****************************************************************/
static int _get_tag(char* szBuf, int iTagType, char* szTagBuf)
{
	int iTagLen;

	iTagLen = _calc_tag_len(szBuf, iTagType);

	if(iTagLen > 0 && iTagLen <= MAX_TAG_LEN)
	{
		memcpy(szTagBuf, szBuf, iTagLen);
	}

	return iTagLen;
}

/*****************************************************************
 * ��    �ܣ�����TLV��Lenֵ
 * ���������iLen		Lenֵ
 *           iLenType	Len����
 *                      0����ͨ���ͣ�Lenֵռ��һ���ֽ�(HEX��ʽ)��
 *                         ȡֵ��Χ0-255
 *                      1����׼���ͣ���Len����ߵ�bitλֵΪ0ʱ��
 *                         Lenֵռ��һ���ֽڣ�bit7-bit1�����ȣ�ȡֵ
 *                         ��ΧΪ0-127����Len����ߵ�bitλֵΪ1ʱ��
 *                         Lenֵռ��2-3���ֽڣ�bit7-bit1����Lenֵռ���ֽ�
 *                         �������磬�������ֽ�Ϊ10000010����ʾL�ֶγ���
 *                         �ֽ��⣬���滹�������ֽڡ�������ֽڵ�ʮ��
 *                         ��ȡֵ��ʾ����ȡֵ�ĳ��ȡ�
 *                         ��ע�������������ͣ�����Ҫ��tlv.h���������Ͷ�
 *                         �弰���Ӻ�����switch��caseѡ��
 * ���������szLenBuf	���LenֵBuf
 * �� �� ֵ�� >0		Lenռ���ֽ���
 *            0		����ʧ��
 * ��    �ߣ�fengwei
 * ��    �ڣ�2012/09/24
 * ����˵��������tlv�⺯���ڲ����ã��ⲿ������
 * �޸���־��
 ***************************************************************/
static int _set_len(int iLen, int iLenType, char* szLenBuf)
{
	char szTmpBuf[MAX_LEN_LEN+1];
	int iLenLen;

	iLenLen = 0;

	memset(szTmpBuf, 0, sizeof(szTmpBuf));

	switch(iLenType)
	{
		case LEN_NORMAL:
			if(iLen >= 0 && iLen <= 255)
			{
				szTmpBuf[0] = iLen;
				iLenLen = 1;
			}
			break;
		case LEN_STANDARD:
			if(iLen <= 127)
			{
				szTmpBuf[0] = iLen;
				iLenLen = 1;
			}
			else if(iLen <= 256)
			{
				szTmpBuf[0] = 0x81;
				szTmpBuf[1] = iLen;
				iLenLen = 2;
			}
			else
			{
				szTmpBuf[0] = 0x82;
				szTmpBuf[1] = iLen / 256;
				szTmpBuf[2] = iLen % 256;
				iLenLen = 3;
			}
			break;
		default:
			iLenLen = 0;
			break;
	}

	if (iLenLen > 0 && iLenLen <= MAX_LEN_LEN)
	{
		memcpy(szLenBuf, szTmpBuf, iLenLen);
	}

	return iLenLen;
}

/*****************************************************************
** ��    �ܣ���TLV��ʽ�����л�ȡLenֵ
** ���������
**		szBuf		TLV��ʽ����
**		iLenType	Len���ͣ�˵���ο�_set_len��������˵��
** ���������
**		iLen		Lenֵ
** �� �� ֵ�� 
**		>0		Lenռ���ֽ���
**		0		��ȡʧ��
** ��    �ߣ�
**		fengwei
** ��    �ڣ�
**		2012/09/24
** ����˵����
**		����tlv�⺯���ڲ����ã��ⲿ������
** �޸���־��
****************************************************************/
static int _get_len(char* szBuf, int iLenType, int* iLen)
{
	int iLenLen;
	char szTmpBuf[MAX_LEN_LEN+1];

	memset(szTmpBuf, 0, sizeof(szTmpBuf));

	switch(iLenType)
	{
		case LEN_NORMAL:
			*iLen = szBuf[0];
			iLenLen = 1;
			break;
		case LEN_STANDARD:
			if ((szBuf[0] & 0x80) == 0x80)
			{
				iLenLen = (szBuf[0] & 0x7F);
				
				if(iLenLen == 1)
				{
					*iLen = szBuf[1];
					iLenLen++;;
				}
				else if(iLenLen == 2)
				{
					*iLen = szBuf[1] * 256 + szBuf[2];
					iLenLen++;
				}
			}
			else
			{
				*iLen = szBuf[0];
				iLenLen = 1;
			}
			break;
		default:
			iLenLen = 0;
			break;
	}

	return iLenLen;	
}

/*****************************************************************
** ��    �ܣ�����TLV��Valueֵ
** ���������
**		szValue		Valueֵ
**		iLen		Value����
**		iValueType	Value����
**				0����ͨ���ͣ�����ԭ����������������
**				1��BCD��ѹ��(�Ҷ���)��������BCD��ѹ��������Ϊ����ʱ����0����
**				2��BCD��ѹ��(�����)��������BCD��ѹ��������Ϊ����ʱ���Ҳ�0����
** ���������
**		szValueBuf	��ʽ����Valueֵ
** �� �� ֵ�� 
**		>0		Lenռ���ֽ���
**		0		��ȡʧ��
** ��    �ߣ�
**		fengwei
** ��    �ڣ�
**		2012/09/24
** ����˵����
**		����tlv�⺯���ڲ����ã��ⲿ������
** �޸���־��
****************************************************************/
static int _set_value(char* szValue, int iLen, int iValueType, char* szValueBuf)
{
	char szTmpBuf[MAX_VALUE_LEN+1];
	int iValueLen;

	memset(szTmpBuf, 0, sizeof(szTmpBuf));

	switch(iValueType)
	{
		case VALUE_NORMAL:
			memcpy(szTmpBuf, szValue, iLen);
			iValueLen = iLen;
			break;
		case VALUE_BCD_RIGHT:
			AscToBcd(szValue, iLen, 1, szTmpBuf);	
			if(iLen%2 == 0 )
			{
				iValueLen = iLen/2;
			}
			else
			{
				iValueLen = iLen/2 + 1;
			}
			break;
		case VALUE_BCD_LEFT:
			AscToBcd(szValue, iLen, 0, szTmpBuf);	
			if(iLen%2 == 0 )
			{
				iValueLen = iLen/2;
			}
			else
			{
				iValueLen = iLen/2 + 1;
			}
			break;
		default:
			iValueLen = -1;
			break;
	}

	if (iValueLen > 0 && iValueLen <= MAX_VALUE_LEN)
	{
		memcpy(szValueBuf, szTmpBuf, iValueLen);
	}

	return iValueLen;
}

/*****************************************************************
** ��    �ܣ���TLV��ʽ�����л�ȡValueֵ
** ���������
**		szBuf		TLV��ʽ����
**		iLen		Valueֵռ���ֽ���
**		iValueType	Value���ͣ�˵���ο�_set_value��������˵��
** ���������
**		szValueBuf	���ValueֵBuf
** �� �� ֵ�� 
**		>0		Value����
**		-1		��ȡʧ��
** ��    �ߣ�
**		fengwei
** ��    �ڣ�
**		2012/09/24
** ����˵����
**		����tlv�⺯���ڲ����ã��ⲿ������
** �޸���־��
****************************************************************/
int _get_value(char* szBuf, int iLen, int iValueType, char* szValueBuf)
{
	int iValueLen;

	switch(iValueType)
	{
		case VALUE_NORMAL:
			memcpy(szValueBuf, szBuf, iLen);
			iValueLen = iLen;
			break;
		case VALUE_BCD_RIGHT:
			BcdToAsc(szBuf, iLen, 1, szValueBuf);	
			if(iLen%2 == 0)
			{
				iValueLen = iLen/2;
			}
			else
			{
				iValueLen = iLen/2 + 1;
			}
			break;
		case VALUE_BCD_LEFT:
			BcdToAsc(szBuf, iLen, 0, szValueBuf);	
			if(iLen%2 == 0)
			{
				iValueLen = iLen/2;
			}
			else
			{
				iValueLen = iLen/2 + 1;
			}
			break;
		default:
			iValueLen = -1;
			break;
	}

	return iValueLen;
}

/* ----------------------------------------------------------------
 * ��    �ܣ�TLV���ó�ʼ��������Tag��Len��Value��ʽ����
 * ���������pTLV            TLV��ʽ����
 *           iTagType        Tag���ͣ�˵���ο�_calc_tag_len��������˵��
 *           iLenType        Len���ͣ�˵���ο�_set_len��������˵��
 *           iValueType      Value���ͣ�˵���ο�_set_value��������˵��
 * ���������
 * �� �� ֵ��
 * ��    �ߣ�fengwei
 * ��    �ڣ�2012-9-24
 * ����˵����InitTLV(pTLV, TAG_NORMAL, LEN_NORMAL, VALUE_NORMAL)
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 *           2012-11-14  ryan.chan   ������ʽ��
 * ----------------------------------------------------------------
 */
void InitTLV(T_TLVStru *pTLV, int iTagType, int iLenType, int iValueType)
{
    int i;

    for(i=0; i<MAX_TLV_NUM; i++)
    {
        memset(&(pTLV->tTLVData[i]), 0, sizeof(T_TLVData));
    }

    pTLV->iTagType = iTagType;
    pTLV->iLenType = iLenType;
    pTLV->iValueType = iValueType;

    return;
}

/* ----------------------------------------------------------------
 * ��    �ܣ����TLV��ʽ����
 * ���������pTLV            TLV��ʽ����
 *           szTag           ��ǩ
 *           iLen            ���ݳ���
 *           szValueBuf      ����
 * ���������
 * �� �� ֵ��0  �ɹ���    -1 ʧ��
 * ��    �ߣ�fengwei
 * ��    �ڣ�2012-9-24
 * ����˵����SetTLV(pTLV, "\x01", 4, "1234")
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 *           2012-11-14  ryan.chan   ������ʽ��
 * ----------------------------------------------------------------
 */
int SetTLV(T_TLVStru *pTLV, char *szTag, int iLen, char* szValue)
{
    int i, iTagLen;
    T_TLVData *pData;

    for (i = 0; i < MAX_TLV_NUM; i++)
    {
        pData = pTLV->tTLVData + i;

        if (pData->iFlag == DATA_NULL)
        {
            iTagLen = _calc_tag_len(szTag, pTLV->iTagType);
            if (iTagLen > 0)
            {
                memcpy(pData->szTag, szTag, iTagLen);
            }
            else
            {
                WriteLog(ERROR, "set tlv Tag error");
                return FAIL;
            }

            pData->iLen = iLen;

            if (iLen > 0)
            {
                memcpy(pData->szValue, szValue, 
                       iLen>MAX_VALUE_LEN?MAX_VALUE_LEN:iLen);
            }
            pData->iFlag = DATA_NOTNULL;

            return SUCC;
        }
    }

    return FAIL;
}

/* ----------------------------------------------------------------
 * ��    �ܣ�����Tagֵ��ȡValueֵ
 * ���������pTLV            TLV��ʽ����
 *           szTag           ��ǩ
 *           iBufSize        Buf��С
 * ���������szValueBuf      ����ValueֵBuf
 * �� �� ֵ��>=0 Value���� -1 ʧ��
 * ��    �ߣ�fengwei
 * ��    �ڣ�2012-9-24
 * ����˵����GetValueByTag(pTLV, "\x01", szValueBuf, sizeof(szValueBuf))
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 *           2012-11-14  ryan.chan   ������ʽ��
 * ----------------------------------------------------------------
 */
int GetValueByTag(T_TLVStru *pTLV, char* szTag, char* szValueBuf, int iBufSize)
{
    int i;
    int iTagLen;
    int iValueLen;
    T_TLVData *pData;

    iTagLen = _calc_tag_len(szTag, pTLV->iTagType);
    if (iTagLen <= 0)
    {
        WriteLog(ERROR, "iTagType:[%d] def error", pTLV->iTagType);
        return FAIL;
    }

    for (i = 0; i < MAX_TLV_NUM; i++)
    {
        pData = pTLV->tTLVData + i;

        if (memcmp(pData->szTag, szTag, iTagLen) == 0 
           && pData->iFlag == DATA_NOTNULL)
        {
            iValueLen = pData->iLen > iBufSize ? iBufSize : pData->iLen;

            memcpy(szValueBuf, pData->szValue, iValueLen);

            return iValueLen;
        }
    }

    return FAIL;
}

/* ----------------------------------------------------------------
 * ��    �ܣ���������ֵ��ȡValueֵ
 * ���������pTLV            TLV��ʽ����
 *           iIndex          ����ֵ
 *           iBufSize        Buf��С
 * ���������szValueBuf      ����ValueֵBuf
 * �� �� ֵ��0  �ɹ���    -1 ʧ��
 * ��    �ߣ�fengwei
 * ��    �ڣ�2012-9-24
 * ����˵����GetValueByIdx(pTLV, 1, szValueBuf, sizeof(szValueBuf))
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 *           2012-11-14  ryan.chan   ������ʽ��
 * ----------------------------------------------------------------
 */
int GetValueByIdx(T_TLVStru *pTLV, int iIndex, char* szValueBuf, 
                  int iBufSize)
{
    int iTagLen;
    T_TLVData *pData;

    pData = pTLV->tTLVData + iIndex;

    if (pData->iFlag == DATA_NOTNULL)
    {
        memcpy(szValueBuf, pData->szValue, 
               pData->iLen>iBufSize?iBufSize:pData->iLen);

        return SUCC;
    }

    return FAIL;	
}

/* ----------------------------------------------------------------
 * ��    �ܣ���TLV��ʽ���ݴ�����ַ���
 * ���������pTLV            TLV��ʽ����
 * ���������szBuf           ����ַ���
 * �� �� ֵ��>=0 ����ַ�������  -1 ʧ��
 * ��    �ߣ�fengwei
 * ��    �ڣ�2012-9-24
 * ����˵����PackTLV(pTLV, szBuf)
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 *           2012-11-14  ryan.chan   ������ʽ��
 * ----------------------------------------------------------------
 */
int PackTLV(T_TLVStru *pTLV, char* szBuf)
{
    int i;
    int iIndex, iLen;
    T_TLVData *pData;

    iIndex = 0;

    for (i=0;i<MAX_TLV_NUM;i++)
    {
        pData = pTLV->tTLVData + i;

        if (pData->iFlag == DATA_NOTNULL)
        {
            iLen = _set_tag(pData->szTag, pTLV->iTagType, szBuf+iIndex);
            if (iLen <= 0)
            {
                WriteLog(ERROR, "pack tlv Tag error");
                return FAIL;
            }
            iIndex += iLen;

            iLen = _set_len(pData->iLen, pTLV->iLenType, szBuf+iIndex);
            if (iLen <= 0)
            {
                WriteLog(ERROR, "pack tlv len error");
                return FAIL;
            }
            iIndex += iLen;

            iLen = _set_value(pData->szValue, pData->iLen, 
                              pTLV->iValueType, szBuf+iIndex);
            if (iLen < 0)
            {
                WriteLog(ERROR, "pack tlv value error");
                return FAIL;
            }
            iIndex += iLen;
        }
    }

    return iIndex;
}


/* ----------------------------------------------------------------
 * ��    �ܣ����ַ������ΪTLV��ʽ����
 * ���������szBuf           �����ַ���
 *           iBufLen         �����ַ�������
 * ���������pTLV            TLV��ʽ����
 * �� �� ֵ��0  �ɹ���    -1 ʧ��
 * ��    �ߣ�fengwei
 * ��    �ڣ�2012-9-24
 * ����˵����UnpackTLV(pTLV, szBuf, iLen)
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int UnpackTLV(T_TLVStru *pTLV, char* szBuf, int iBufLen)
{
    int  i, iIndex, iLen;
    char szTagBuf[MAX_TAG_LEN+1];
    T_TLVData *pData;

    iIndex = 0;
    i = 0;

    while (iIndex < iBufLen)
    {
        pData = pTLV->tTLVData + i;
        
        iLen = _get_tag(szBuf+iIndex, pTLV->iTagType, pData->szTag);
        if (iLen == 0)
        {
            WriteLog(ERROR, "unpack tlv Tag error");
            return FAIL;
        }
        iIndex += iLen;

        iLen = _get_len(szBuf+iIndex, pTLV->iLenType, &(pData->iLen));
        if (iLen == 0)
        {
            WriteLog(ERROR, "unpack tlv len error");
            return FAIL;
        }
        iIndex += iLen;

        iLen = _get_value(szBuf+iIndex, pData->iLen, pTLV->iValueType, 
                          pData->szValue);
        if (iLen < 0)
        {
            WriteLog(ERROR, "unpack tlv value error");
            return FAIL;
        }
        iIndex += iLen;

        pData->iFlag = DATA_NOTNULL;

        i++;
    }

    return SUCC;
}


/* ----------------------------------------------------------------
 * ��    �ܣ�TLV��Debug����
 * ���������pTLV      TLV��ʽ����
 * �����������
 * �� �� ֵ����
 * ��    �ߣ�fengwei
 * ��    �ڣ�2012-9-24
 * ����˵����DebugTLV(pTLV)
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 *
 * ----------------------------------------------------------------
 */
void DebugTLV(T_TLVStru *pTLV)
{
    int i,j;
    int iTagLen;
    T_TLVData *pData;
    char szTagBuf[64+1];
    char szValueBuf[MAX_VALUE_LEN*2+1];

    if (pTLV == NULL)
    {
        return;
    }

    for (i=0; i<MAX_TLV_NUM; i++)
    {
        pData = pTLV->tTLVData + i;

        memset(szTagBuf, 0, sizeof(szTagBuf));
        memset(szValueBuf, 0, sizeof(szValueBuf));

        if (pData->iFlag == DATA_NOTNULL)
        {
            
            iTagLen = _calc_tag_len(pData->szTag, pTLV->iTagType);

            for (j=0;j<iTagLen;j++)
            {
                sprintf(szTagBuf+j*4, "0x%02x", pData->szTag[j]);
            }

            BcdToAsc(pData->szValue, pData->iLen*2, LEFT_ALIGN, szValueBuf);

            WriteLog(TRACE, "TLV:[%d] Tag:[%s] Len:[%d] Value:[%s]", 
                            i, szTagBuf, pData->iLen, szValueBuf);
        } /*if*/
    } /*for*/

    return;
}

