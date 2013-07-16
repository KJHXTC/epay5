
/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision: 1.3 $
 * $Log: ChgAmount.c,v $
 * Revision 1.3  2013/02/21 06:30:04  fengw
 *
 * 1���޸ĶԽǷ�λ�Ĵ�������2λС����ʽ��
 *
 * Revision 1.2  2012/12/21 05:44:01  chenrb
 * *** empty log message ***
 *
 * Revision 1.1  2012/12/11 02:11:00  fengw
 *
 * 1��ChgAmout.c����ΪChgAmount.c��
 *
 * Revision 1.5  2012/12/04 06:21:35  chenjr
 * ����淶��
 *
 * Revision 1.4  2012/11/27 03:20:01  linqil
 * *** empty log message ***
 *
 * Revision 1.3  2012/11/27 02:52:15  yezt
 * *** empty log message ***
 *
 * Revision 1.2  2012/11/27 02:45:19  linqil
 * ��������pub.h �޸�return
 *
 * Revision 1.1  2012/11/20 03:27:37  chenjr
 * init
 *
 * ----------------------------------------------------------------
 */


#include <stdio.h>
#include <string.h>
#include "pub.h"

extern char *DelAllSpace(char *szStr);

/* ----------------------------------------------------------------
 * ��    �ܣ�������" 1234.56 "(��������)����ַ���ת��Ϊ"000000123456"
 * ���������szSrc    ����ָ��������ִ�(���Ժ�������)
 *           iOutLen  ָ��ת������������(����ǰ��0)
 *           iPreFlag ָ���Ա�ת����ǰ��"-/+"�Ƿ�ת����"D/C",
 *                    =0�����ԣ�������
 *                    ��0, "-"ת��"D", "+"ת��"C"
 * ���������szDest   ������ָ��������ִ�(����ǰ��0)
 * �� �� ֵ��-1 ת��ʧ��;  0 ת���ɹ�
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int ChgAmtDotToZero(char *szSrc, int iOutLen, int iPreFlag, char *szDest)
{
    char acDot[100], acZero[100], *pD;
    int iDotLen, iLOffset, iRealLen;

    if (szSrc == NULL || iOutLen < 0 || iOutLen > 100 || szDest == NULL)
    {
        return FAIL;
    }

    memset(acDot, 0, sizeof(acDot));
    memset(acZero, '\0', sizeof(acZero));

    /* ȥ���������пո� */
    strcpy(acDot, szSrc);
    DelAllSpace(acDot);
    iDotLen = strlen(acDot); 

    /* �������ƫ�Ƴ���, Ҫ����ƫ�Ƽ�λ */
    iLOffset = 0;
    pD = strchr(acDot, '.');
    if (iDotLen > 0)
    {
        iLOffset = (pD == NULL ? 2 : (strlen(pD) > 3 ? 0 : 3-strlen(pD)));
    }
    
    /* �������������ݵĳ��� */
    iRealLen = iDotLen + iLOffset;
    if (iOutLen > iRealLen)
    {
        iRealLen = iOutLen;
    }
    else
    {
        /* �����ʵ���Ȱ����㳤�Ȼ���ų��ȣ�����Ҫ��ȥ */
        if (pD != NULL)
        {
            iRealLen--;
        }

        if (iDotLen > 0 && (acDot[0] == '-' || acDot[0] == '+'))
        {
            iRealLen--;
        }
    }

    if (iPreFlag != 0)
    {
        iRealLen++;
    }

    memset(acZero, '0', iRealLen);
    iRealLen -= iLOffset;

    /* ����λ */
    if (iPreFlag != 0 && iDotLen > 0)
    {
        if (acDot[0] == '-')
        {
            acZero[0] = 'D';
        }
        else
        {
            acZero[0] = 'C';
        }
    //    iRealLen++;
    }

    iDotLen--;
    iRealLen--;
    while (iDotLen >= 0)
    {
        if (acDot[iDotLen] == '.' || acDot[iDotLen] == '-' ||
            acDot[iDotLen] == '+')
        {
            iDotLen--;
            continue;
        } 

        acZero[iRealLen] = acDot[iDotLen];
        iDotLen--;
        iRealLen--;
    }

    strcpy(szDest, acZero);
    return strlen(acZero);
}


/* ----------------------------------------------------------------
 * ��    �ܣ�������"000000123456"����ַ���ת���� "1234.56"(ʵ�ʳ�)
**           ������"C000000123456"����ַ���ת����"1234.56"(ʵ�ʳ�)
**           ������"D000000123456"����ַ���ת����"-1234.56"(ʵ�ʳ�)
 * ���������szSrc    ��C/D���Ͻ��淶�Ľ�����ַ���
 *           iOutLen  ת�������ִ���Ҫ������ȣ�λ������ǰ���ո�),
 *                    ʵ�ʽ��ȴ��ڸ�ֵ��ʵ�ʳ������
 * ���������szDest   ����ָ��������ִ�
 * �� �� ֵ��ת��������ִ�ʵ�ʳ���
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int ChgAmtZeroToDot(char *szSrc, int iOutLen, char *szDest)
{
    int i, j, iOffset, isHeadZero, iSymbLen, iContLen;
    char szTmp[512], szBuf[512], szSymb[2];

    if (szSrc == NULL || iOutLen < 0 || szDest == NULL)
    {
        return FAIL;
    }


    memset(szTmp, 0, sizeof(szTmp));
    memset(szBuf, 0, sizeof(szBuf));
    memset(szSymb, 0, sizeof(szSymb));

    /* ȡ����λ */
    i = 0;
    if (*(szSrc+i) == 'D' || *(szSrc+i) == 'd')
    {
        szSymb[0] = '-'; 
        i++; 
    }
    else if (*(szSrc+i) == 'C' || *(szSrc+i) == 'c')
    {
        i++;
    }
    
    /* ���洮ǰ0֮�����Ч���� */
    j = 0;
    isHeadZero = 1;
    while (*(szSrc+i) != '\0')
    {
        if (isHeadZero && *(szSrc+i) == '0')
        {
            i++;
            continue;
        } 

        isHeadZero = 0;
        szTmp[j] = *(szSrc+i);
        i++; j++;
    }

    /* �Ա������ʱ��������λ */
    switch (strlen(szTmp))
    {
    case 0:
        sprintf(szBuf, "0.00");
        break;

    case 1:
        sprintf(szBuf, "0.0%1.1s", szTmp);
        break;
 
    case 2:
        if (szTmp[1] != '0')
            sprintf(szBuf, "0.%2.2s", szTmp);
        else
            sprintf(szBuf, "0.%1.1s", szTmp);
        break;

    default:
        strncpy(szBuf, szTmp, strlen(szTmp) - 2);

        strcat(szBuf, ".");
        strncpy(szBuf + strlen(szBuf), szTmp + strlen(szTmp) - 2, 2);
            
        break;
    }

    iOffset = 0;
    memset(szDest, ' ', iOutLen);

    iSymbLen = strlen(szSymb);
    iContLen = strlen(szBuf);

    if (iOutLen > (iContLen + iSymbLen))
    {
        iOffset = iOutLen - iContLen - iSymbLen;
    }

    sprintf(szDest + iOffset, "%s%s", szSymb, szBuf);
    return (iOffset > 0 ? iOutLen : iContLen + iSymbLen);
}


