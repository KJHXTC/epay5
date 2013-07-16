
/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ��ַ���������ӿں���
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision: 1.4 $
 * $Log: String.c,v $
 * Revision 1.4  2012/12/20 06:01:14  wukj
 * ɾ��GetField����,��GetStrData�����滻
 *
 * Revision 1.3  2012/12/04 07:26:35  chenjr
 * ����淶��
 *
 * Revision 1.2  2012/11/27 06:44:55  linqil
 * ��������pub.h���޸�return���
 *
 * Revision 1.1  2012/11/20 03:27:37  chenjr
 * init
 *
 * ----------------------------------------------------------------
 */


#include <string.h>
#include "pub.h"

/* ----------------------------------------------------------------
 * ��    �ܣ�ɾ���ַ����׵����пո�
 * ���������szStr  ��ɾ���ո�ǰ���ַ���
 * ���������szStr  ɾ����ǰ���пո����ַ���
 * �� �� ֵ��szStr  ɾ����ǰ���пո����ַ���
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
char *DelHeadSpace(char *szStr)
{
    char szBuf[1024];
    int  i = 0;

    if (szStr == NULL)
    {
        return NULL;
    }
 
    memset(szBuf, 0, sizeof(szBuf));
    strcpy(szBuf, szStr);

    while (szBuf[i] == ' ')
    {
        i++;
    }

    strcpy(szStr, szBuf + i);
    return szStr;
}

/* ----------------------------------------------------------------
 * ��    �ܣ�ɾ���ַ���ĩ�����пո�
 * ���������szStr  ��ɾ���ո�ǰ���ַ���
 * ���������szStr  ɾ����ĩ���пո����ַ���
 * �� �� ֵ��szStr  ɾ����ĩ���пո����ַ���
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
char *DelTailSpace(char *szStr)
{
    int  l;

    if (szStr == NULL)
    {
        return NULL;
    }

    l = strlen(szStr) - 1;
    while (l >= 0 && szStr[l] == ' ')
    {
        l--;
    }

    l++;
    szStr[l] = '\0';
    return szStr;
}

/* ----------------------------------------------------------------
 * ��    �ܣ�ɾ���ַ����е����пո�
 * ���������szStr  ��ɾ���ո�ǰ���ַ���
 * ���������szStr  ɾ�����пո����ַ���
 * �� �� ֵ��szStr  ɾ�����пո����ַ���
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
char *DelAllSpace(char *szStr)
{
    char szBuf[1024], *pStr;
    int i = 0;

    if (szStr == NULL)
    {
        return NULL;
    }

    pStr = szBuf;
    while (*(szStr+i) != '\0')
    {
        if (*(szStr+i) != ' ')
        {
            *pStr++ = *(szStr+i); 
        }
        i++;
    }

    *pStr='\0';
    strcpy(szStr, szBuf);
    return(szStr);
}


/* ----------------------------------------------------------------
 * ��    �ܣ�ת���ַ�������Сд�ַ�Ϊ��д
 * ���������szStr  ת��ǰ�ַ���
 * ���������szStr  ת�����ַ���
 * �� �� ֵ��szStr  ת�����ַ���
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
char *ToUpper(char *szStr)
{
    int i = 0;

    if (szStr == NULL)
    {
        return NULL;
    }

    while (*(szStr+i) != '\0')
    {
        if (*(szStr+i) >= 'a' && *(szStr+i) <= 'z')
        {
            *(szStr+i) -= ('a' - 'A');
        }
        i++;
    }
    
    return szStr;
}

/* ----------------------------------------------------------------
 * ��    �ܣ�ת���ַ������д�д�ַ�ΪСд
 * ���������szStr  ת��ǰ�ַ���
 * ���������szStr  ת�����ַ���
 * �� �� ֵ��szStr  ת�����ַ���
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
char *ToLower(char *szStr)
{
    int i = 0;

    if (szStr == NULL)
    {
        return NULL;
    }

    while (*(szStr+i) != '\0')
    {
        if (*(szStr+i) >= 'A' && *(szStr+i) <= 'Z')
        {
            *(szStr+i) += ('a' - 'A');
        }
        i++;
    }
    
    return szStr;

}

/* ----------------------------------------------------------------
 * ��    �ܣ��ж��ַ����Ƿ���ȫ�������
 * ���������szStr  ��У�鴮
 * ���������
 * �� �� ֵ��0  ȫ���֣�  -1  ��ȫ����
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int IsNumber(char *szStr)
{
    int i = 0;

    if (szStr == NULL)
    {
        return FAIL;
    }

    while ( *(szStr+i) != '\0')
    {
        if (*(szStr+i) < '0' || *(szStr+i) > '9')
        {
            return FAIL;
        }
        i++;
    }

    return SUCC;
}


/***********************************************************************
 *      �� �� ��:int    GetStrData(
 *                      char * pszInBuf
                        ,int iPosition
			,char *szDelimiter
 *                      ,char * pszOutData)
 *      ��ڲ���: 
 *                pszInBuf:���봮
 *                iPosition:ȡ��λ��
 *		  pszDelimiter:�ָ���,֧��1������ֽ���Ϊ�ָ���
 *      ���ز���: ��������>=0��ʾ�ɹ�
 *                pszOutData:�����
 *
 *      ����ȫ�ֱ���:
 *      �޸�ȫ�ֱ���:
 *      �� �� ��:
 *      �� �� ��:
 *      ��������:
 *      ��������: ��ȡ��pszDelimiter�ָ��������е�ĳ������
 ***********************************************************************/
int GetStrData(char *szInBuf,int iPosition,char *szDelimiter,char *szOutData)
{
	int i,j,k;
	j=0;
	k=0;
	while(k<iPosition)
	{
		if(szInBuf[j]=='\0')return(-1);
		else if(memcmp(szInBuf+j,szDelimiter,strlen(szDelimiter)) == 0 )
		{
			k++;
			j += strlen(szDelimiter);
			continue;
		}
		j++;
	}
	i=0;
	while(memcmp(szInBuf+j+i,szDelimiter,strlen(szDelimiter)) != 0)
	{
		if(szInBuf[j+i]=='\0')break;
		szOutData[i]=szInBuf[j+i];
		i++;
	}
	szOutData[i]='\0';
	return(i);
}
