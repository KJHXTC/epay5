/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�8583�������ӿ�
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision: 1.13 $
 * $Log: 8583.c,v $
 * Revision 1.13  2012/12/17 02:27:05  chenrb
 * WriteERLog�޸ĳ�WriteLog
 *
 * Revision 1.12  2012/12/04 02:05:30  chenjr
 * ����淶��
 *
 * Revision 1.11  2012/11/29 02:15:35  linqil
 * �޸�WriteETLogΪWriteLog
 *
 * Revision 1.10  2012/11/28 08:25:44  linqil
 * ȥ������ͷ�ļ�user.h
 *
 * Revision 1.9  2012/11/27 08:21:01  linqil
 * �޸���־����
 *
 * Revision 1.8  2012/11/27 02:53:49  yezt
 * *** empty log message ***
 *
 * Revision 1.7  2012/11/26 08:53:53  yezt
 * *** empty log message ***
 *
 * Revision 1.6  2012/11/26 08:40:13  linqil
 * ���Ӷ�pub.h�����ã�0 -1 �滻ΪSUCC��FAIL
 *
 * Revision 1.5  2012/11/26 08:35:51  linqil
 * ����ͷ�ļ�pub.h����ͷ�ļ�pub.h�����ã��޸�return 0 return -1 Ϊreturn SUCC return FAIL��
 *
 * Revision 1.4  2012/11/26 08:29:37  chenjr
 * ���ע��
 *
 * Revision 1.3  2012/11/26 08:27:53  chenjr
 * ����
 *
 * ----------------------------------------------------------------
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "8583.h"

#include "pub.h"
#include "libpub.h"

/* ASC BCD HEX תDEC */
int Asc2Dec(unsigned char *, int, int *);
int Bcd2Dec(unsigned char *, int, int *);
int Hex2Dec(unsigned char *, int, int *);

/* DEC ת ASC BCD HEX */
int Dec2Asc(unsigned char *, int, int);
int Dec2Bcd(unsigned char *, int, int);
int Dec2Hex(unsigned char *, int, int);


/* ----------------------------------------------------------------
 * ��    �ܣ����ISO_data�洢�ռ�
 * ���������ptData   ISO�ṹ��ָ��
 * �����������
 * �� �� ֵ����
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/26
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
void ClearBit(ISO_data *ptData)
{
    int i;

    for (i = 0; i < 128; i++)
    {
        ptData ->f[i].bitf = 0;
    }
    ptData->off = 0;
}

/* ----------------------------------------------------------------
 * ��    �ܣ� ��ȡ8583��ָ��������
 * ��������� ptMR    ---- ���Ĺ���
 *            ptData  ---- ISO�ṹ��ִ��
 *            iNO     ---- ���
 * ��������� szDest  ---- ����ַ���
 * �� �� ֵ�� �������ݳ���
 * ��    �ߣ� �½���
 * ��    �ڣ� 2012/12/26
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int GetBit(MsgRule *ptMR, ISO_data *ptData, int iNo, char *szDest)
{
    int iLen;
    unsigned char *pMsg;

    if (iNo == 0)
    {
        memcpy(szDest, ptData->message_id, 4);
        szDest[4] = '\0';
        return 4;
    }

    if (iNo <= 1 || iNo > 128 || ptData->f[iNo - 1].bitf == 0)
    {
        return SUCC;
    }

    iNo--;
    pMsg = (unsigned char*)&(ptData->dbuf[ptData->f[iNo].dbuf_addr]);
    iLen = ptData->f[iNo].len;

    if (ptMR->ptISO[iNo].type & 0x01)
    {
        *szDest++ = *pMsg++;
    }

    if (ptMR->ptISO[iNo].type & 0x07)
    {
        if (ptMR->ptISO[iNo].type & 0x03)
        {
            BcdToAsc(pMsg, iLen, 0, (unsigned char*)szDest);
        }
        else
        {
            BcdToAsc(pMsg, iLen, 1, (unsigned char*)szDest);
        }
    }
    else
    {
        memcpy(szDest, pMsg, iLen);
    }

    szDest[iLen] = '\0';
    return iLen;
}

/* ----------------------------------------------------------------
 * ��    �ܣ���8583��ָ��������
 * ���������ptMR    -----  ���Ĺ���
 *           szSrc   -----  ָ��������
 *           iNo     -----  ���
 *           iLen    -----  �����ݳ���
 * ���������ptData  -----  ISO�ṹָ��
 * �� �� ֵ��0 �ɹ�/-1 ʧ��
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/06
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int SetBit(MsgRule *ptMR, char *szSrc, int iNo, int iLen, ISO_data *ptData)
{
    int i, iSpecLen;   /* ��涨���� */
    unsigned char *pDbuf, szTmp[DBUFSIZE], cTmp;
   
    if (iNo == 0)
    {
        memcpy(ptData->message_id, szSrc, 4);
        ptData->message_id[4] = '\0';
        return SUCC;
    }

    if (iLen == 0 || iNo <= 1 || iNo > 128)
    {
        return FAIL;
    }

    iNo--;

    /* ȷ����ʵֵ(iLen)��涨ֵ(iSpecLen) */
    if (iLen > ptMR->ptISO[iNo].len)
    {
        iLen = ptMR->ptISO[iNo].len;
    }

    iSpecLen = iLen;

    if (ptMR->ptISO[iNo].flag == 0)
    {
        iSpecLen = ptMR->ptISO[iNo].len;
    }

    /* ���洢��� */
    if (iSpecLen + ptData->off > DBUFSIZE)
    {
        return FAIL;
    }

    /* ������ֵ��ʶ */
    ptData->f[iNo].bitf = 1;
    /* ����ֵ���� */
    ptData->f[iNo].len = iSpecLen;
    /* ������ʼ��ַ */
    ptData->f[iNo].dbuf_addr =  ptData->off;
    pDbuf = (unsigned char*)&(ptData->dbuf[ptData->off]);
    /* �ô洢����һ�����±���ʼֵ */
    ptData->off += iSpecLen;

    /* �����ݴ��� */
    if (ptMR->ptISO[iNo].type & 0x01)  
    {
        *(pDbuf++) = *(szSrc++);
        ptData->off += 1;
    }

    i = 0;
    if (ptMR->ptISO[iNo].type & 0x03)
    {
        for (; i < iSpecLen - iLen; i++)
        {
            szTmp[i] = '0';
        }
    }

    memcpy(szTmp + i, szSrc, iLen);
    i += iLen;

    if (ptMR->ptISO[iNo].type & 0x08)
    {
        cTmp = 0;
    }
    else 
    {
        cTmp = ' '; 
    }

    for (; i < iSpecLen; i++)
    {
        szTmp[i] = cTmp;
    }
    
    /* ��ֵ���� */
    if (ptMR->ptISO[iNo].type & 0x07)
    {
        if (ptMR->ptISO[iNo].type & 0x03)
        {
            AscToBcd(szTmp, iSpecLen, 0, pDbuf);
        }
        else
        {
            AscToBcd(szTmp, iSpecLen, 1, pDbuf);
        }
    }
    else
    {
        memcpy(pDbuf, szTmp, iSpecLen);
    }

    return SUCC;
}


/* ----------------------------------------------------------------
 * ��    �ܣ�8583���
 * ���������ptMR     -----  ���Ĺ���
 *           ptData   -----  ISO�ṹ��ָ��
 * ���������szDest   -----  �����ı��Ĵ�
 * �� �� ֵ��8583�����ĳ���
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/26
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int IsoToStr(MsgRule *ptMR, ISO_data *ptData, unsigned char *szDest)
{
    int iBitNum = 8, iMidLen = 4, i, j, iFieldNo, iFieldLen, iOffset = 0;
    unsigned char *pMsg, cBitMask, cBitMap;
    int (*pfStorLen)(unsigned char *, int, int);

    switch (ptMR->iFieldLenType)
    {
    case FIELDLENTYPE_ASC:
        pfStorLen = Dec2Asc;
        break;

    case FIELDLENTYPE_BCD:
        pfStorLen = Dec2Bcd;
        break;

    default:
        pfStorLen = Dec2Hex;
        break;
    }

    if (ptMR->iMidType == MSGIDTYPE_ASC)
    {
        memcpy(szDest, ptData->message_id, 4);
    }
    else
    {
        AscToBcd((unsigned char*)ptData->message_id, 4, 0, 
                 (unsigned char*)szDest);
        iMidLen = 2;
    }
 
    for (iFieldNo = 64; iFieldNo < 128; iFieldNo++)
    {
        if (ptData->f[iFieldNo].bitf)
        {
            iBitNum = 16;
            break;
        }
    }

    pMsg = szDest + iMidLen + iBitNum;

    for (i=0; i<iBitNum; i++)
    {
        cBitMap = 0;
        cBitMask = 0x80;

        for (j=0; j<8; j++, cBitMask >>= 1)
        {
            iFieldNo = (i << 3) + j;
            if (ptData->f[iFieldNo].bitf == 0)
            {
                continue;
            }
 
            cBitMap |= cBitMask;
            iFieldLen = ptData->f[iFieldNo].len;

            if (ptMR->ptISO[iFieldNo].flag > 0)
            {
                /* ת���򳤶�(DEC)Ϊ��Ӧ�����ƴ���ڴ��� */
                pMsg += (unsigned char)(*pfStorLen)(pMsg,
                                         ptMR->ptISO[iFieldNo].flag,
                                         iFieldLen);
            }
            iOffset = 0;
            if (ptMR->ptISO[iFieldNo].type & 0x01)
            {
                (*pMsg++) = ptData->dbuf[ptData->f[iFieldNo].dbuf_addr + 
                                        iOffset];
                iOffset++;
                iFieldLen++;
            }

            if (ptMR->ptISO[iFieldNo].type & 0x07)
            {
                iFieldLen++;
                iFieldLen >>= 1;
            }

            for (; iOffset < iFieldLen; iOffset++)
            {
                (*pMsg++) = ptData->dbuf[ptData->f[iFieldNo].dbuf_addr +
                                        iOffset];
            }
        } /* for j [bit] */

        szDest[i + iMidLen] = cBitMap;
    }  /* for i [Byte] */

    if (iBitNum == 16)
    {
        szDest[iMidLen] |= 0x80;
    }

    return (pMsg - szDest);
}

/* ----------------------------------------------------------------
 * ��    �ܣ�8583���
 * ���������ptMR   ----  ���Ĺ���
 *           szSrc  ----  8583���Ĵ�
 * ���������ptData ----  ISO�ṹ��ָ��
 * �� �� ֵ��-1   ʧ��/0 �ɹ�
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/26
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int StrToIso(MsgRule *ptMR, unsigned char *szSrc, ISO_data *ptData)
{
    int iBitNum = 8, iMidLen = 4, i, j, iFieldNo, iFieldLen, iOffset = 0;
    unsigned char *pMsg, cBitMask;
    int (*pfCaclLen)(unsigned char *, int, int *);

    /* ��ʼ�� */
    ClearBit(ptData);

    switch (ptMR->iFieldLenType)
    {
    case FIELDLENTYPE_ASC:
        pfCaclLen = Asc2Dec;
        break;

    case FIELDLENTYPE_BCD:
        pfCaclLen = Bcd2Dec;
        break;

    default:
        pfCaclLen = Hex2Dec;
        break;
    }

    if (ptMR->iMidType == MSGIDTYPE_ASC)
    {
        memcpy(ptData->message_id, szSrc, 4);
    }
    else
    {
        BcdToAsc((unsigned char*)szSrc, 4, 0, 
                 (unsigned char*)ptData->message_id);
        iMidLen = 2;
    }
    ptData->message_id[4] = '\0';

    /* �ж��Ƿ�����չ�� */
    if (szSrc[iMidLen] & 0x80)
    {
        iBitNum = 16;
    }

    /* pMsgָ������ʵ����ʼ�� */
    pMsg = szSrc + iMidLen + iBitNum;

    /* �������Ĵ� */
    for (i = 0; i < iBitNum; i++)
    {
        cBitMask = 0x80;
        for (j = 0; j < 8; j++, cBitMask >>= 1)
        {
            if (i == 0 && cBitMask == 0x80)
            {
                continue;
            }

            if ((szSrc[iMidLen + i] & cBitMask) == 0)
            {
                continue;
            }
    
            iFieldNo = (i << 3) + j;

            /* ȡָ������Ч���� */
            if (ptMR->ptISO[iFieldNo].flag > 0)
            {
                /* ������Ӧ���������Ч���ȼ��� */
                pMsg += (unsigned char)(*pfCaclLen)(pMsg, 
                                         ptMR->ptISO[iFieldNo].flag, 
                                         &iFieldLen);

                if (iFieldLen > ptMR->ptISO[iFieldNo].len)
                {
                    WriteLog(ERROR, "field[%d] too long[Max:%d-Cur%d]",
                          iFieldNo, ptMR->ptISO[iFieldNo].len, iFieldLen);
                    return FAIL;
                }
            }
            else
            {
                iFieldLen = ptMR->ptISO[iFieldNo].len;
            }

            ptData->f[iFieldNo].len       = iFieldLen;
            ptData->f[iFieldNo].dbuf_addr = iOffset;

            /*  Credit or Debit char isn't include in the len */
            if (ptMR->ptISO[iFieldNo].type  & 0x01)
            {
                ptData->dbuf[iOffset++] = *pMsg++;
            }

            /* BCD field Bytes = len / 2 [bit1, bit2]*/
            if (ptMR->ptISO[iFieldNo].type  & 0x07)
            {
                iFieldLen++;
                iFieldLen >>= 1;
            }

            /* ��ֹԽ�� */
            if (iFieldLen + iOffset >= DBUFSIZE)
            {
                WriteLog(ERROR, "the total length is too long[%d]\n",
                           iFieldLen + iOffset);
                return FAIL;
            }

            while (iFieldLen > 0)
            {
                ptData->dbuf[iOffset++] = *pMsg++;
                iFieldLen--;
            }
            ptData->f[iFieldNo].bitf = 1;
        } /* for j (bit)*/
    } /*for i (Byte)*/

    ptData->off = iOffset;
    return SUCC;
} /*StrToIso */


/* ----------------------------------------------------------------
 * ��    �ܣ� ��װָ�������ݣ������������ţ����ȣ�bcd�����ݣ�asc�����ݵ�
 * ��������� szSrc    ----- ���Ĵ�
 *            iFieldNo ----- ���
 *            iLen     ----- �򳤶�����
 * ��������� szDest   ----- ƴװ��Ĵ�
 * �� �� ֵ�� ������ݳ���
 * ��    �ߣ� �½���
 * ��    �ڣ� 2012/12/26
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
static int PrtField(unsigned char *szSrc, int iFieldNo, int iLen, char *szDest)
{
    int l, j, k;
    char *pHead;

    pHead = szDest;

    sprintf(szDest, "field[%d] len=[%d]\n%n", 
            iFieldNo == 0 ? 0 : iFieldNo + 1, iLen, &l);

    for (j = 0; j < iLen / 16; j++)
    {
        sprintf(szDest += l, "%04xh:%n", j*16, &l);

        for (k = 0; k < 16; k++)
        {
            sprintf(szDest += l, "%02x %n", szSrc[j*16+k], &l);
        }

        sprintf(szDest += l, "|%n", &l);

        for ( k = 0; k < 16; k ++ )
        {
            if (szSrc[j*16+k] >= 0x30 && szSrc[j*16+k] <= 0x7e )
            {
                sprintf(szDest += l, "%c%n", 
                        (unsigned char)szSrc[j*16+k], &l);
            }
            else
            {
                sprintf(szDest += l, ".%n", &l);
            }
        }

        sprintf(szDest += l, "\n%n", &l);
    }

    if (iLen % 16 != 0 )
    {
        sprintf(szDest += l, "%04xh:%n", j*16, &l);
        for( k = 0; k< iLen % 16; k++ )
        {
            sprintf(szDest += l, "%02x %n", szSrc[j*16+k], &l);
        }

        for (k = 0; k< (48 - (iLen % 16) * 3); k ++)
        {
            sprintf(szDest += l, "%s%n", " ", &l);
        }

        sprintf(szDest += l, "|%n", &l);

        for (k = 0; k < 0 + iLen%16; k ++)
        {
            if (szSrc[j*16+k] >= 0x30 && szSrc[j*16+k] <= 0x7e )
            {
                sprintf(szDest += l, "%c%n", 
                        (unsigned char )szSrc[j*16+k], &l);
            }
            else
            {
                sprintf(szDest += l, ".%n", &l);
            }
        }
        sprintf(szDest += l, "\n%n", &l);
    }

    szDest += l;
    return (szDest - pHead);
}


/* ----------------------------------------------------------------
 * ��    �ܣ����8583����debug��־
 * ���������ptMR    ----- ���Ĺ���
 *           ptData  ----- ISO�ṹ��ָ��
 * ���������szDest  ----- ��־����ַ���ָ��
 * �� �� ֵ��0 �ɹ�
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/26
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int DebugIso8583(MsgRule *ptMR, ISO_data *ptData, char *szDest)
{
    int            i, len;
    unsigned char  *pt, str[500];

    sprintf(szDest, "========================================\n%n", &len);

    AscToBcd((unsigned char*)ptData->message_id, 4, 0, str);

    szDest += len;
    szDest += PrtField(str, 0, 2, szDest);

    for (i = 0; i < 128; i ++)
    {
        if (ptData ->f[i].bitf != 1)
        {
            continue;
        }

        pt = (unsigned char *)&ptData->dbuf[ptData->f[i].dbuf_addr];

        if (ptMR->ptISO[i].type & 0x07 )
        {
            len = ( ptData->f[i].len + 1 )/ 2;
        }
        else
        {
            len = ptData-> f[i].len;
        }

        memcpy( (char *)str, (char *)pt, len );
        str[len] = 0;

        szDest += PrtField(str, i, len, szDest);
    }

    sprintf(szDest, "========================================\n%n", &len);
    sprintf( szDest += len, "\n\n%n", &len );

    return SUCC;
}


/* ----------------------------------------------------------------
 * ��    �ܣ�����Asc�������Ч���� 
 * ���������szSrc    -----  �ַ���ָ��   
 *           iLenType -----  ���ĳ�������
 * ���������iLen     -----  ����ʵ�ʳ��� 
 * �� �� ֵ��������ռ�ֽ���
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/26
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int Asc2Dec(unsigned char *szSrc, int iLenType, int *piLen)
{
    int iOffSet, iVal = 0, i = 0;

    iOffSet = (iLenType == 1 ? 2 : 3);

    while (i < iOffSet)
    {
        iVal = iVal * 10 + ( (*szSrc) - '0');
        szSrc++;
        i++;
    }

    *piLen = iVal;

    return (iOffSet);
}

/* ----------------------------------------------------------------
 * ��    �ܣ�����Hex�������Ч���� 
 * ���������szSrc    -----  �ַ���ָ��   
 *           iLenType -----  ���ĳ�������
 * ���������iLen     -----  ����ʵ�ʳ��� 
 * �� �� ֵ��������ռ�ֽ���
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/26
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int Hex2Dec(unsigned char *szSrc, int iLenType, int *piLen)
{
    int iOffSet, iVal = 0, i = 0;

    iOffSet = (iLenType == 1 ? 1 : 2);

    while (i < iOffSet)
    {
        iVal <<= 8;
        iVal += *(szSrc + i);
        i++;
    }

    *piLen = iVal;
    return (iOffSet);
}


/* ----------------------------------------------------------------
 * ��    �ܣ�����Bcd�������Ч���� 
 * ���������szSrc    -----  �ַ���ָ��   
 *           iLenType -----  ���ĳ�������
 * ���������piLen    -----  ����ʵ�ʳ��� 
 * �� �� ֵ��������ռ�ֽ���
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/26
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int Bcd2Dec(unsigned char *szSrc, int iLenType, int *piLen)
{
    int iOffSet, iVal = 0, i = 0;

    iOffSet = (iLenType == 1 ? 1 : 2);

    while (i < iOffSet)
    {
        iVal = iVal * 100 + (*szSrc) - (*szSrc>>4) * 6;
        szSrc++;
        i++;
    }
    *piLen = iVal;
    return (iOffSet);
}

/* ----------------------------------------------------------------
 * ��    �ܣ�����Ч�򳤶�ת��ΪAsc��
 * ���������iLenType  ----- ���ĳ�������
 *           iLen      ----- ����ʵ�ʳ���
 * ���������szSrc     ----- �ַ���ָ�� (ʵ�ʳ��ȴ洢���ַ�����)
 * �� �� ֵ��������ռ�ֽ���
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/26
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int Dec2Asc(unsigned char *szSrc, int iLenType, int iLen)
{
    int iOffSet;

    if (iLenType == 1)
    {
        iOffSet = 2;
        (*szSrc++) = (unsigned char)(iLen / 10) + '0';
        (*szSrc++) = (unsigned char)(iLen % 10) + '0';
    }
    else
    {
        iOffSet = 3;
        (*szSrc++) = (unsigned char)(iLen / 100) + '0';
        iLen %= 100;
        (*szSrc++) = (unsigned char)(iLen / 10) + '0';
        iLen %= 10;
        (*szSrc++) = (unsigned char)iLen + '0';
    }

    return iOffSet;
}

/* ----------------------------------------------------------------
 * ��    �ܣ�����Ч�򳤶�ת��ΪHex��
 * ���������iLenType  ----- ���ĳ�������
 *           iLen      ----- ����ʵ�ʳ���
 * ���������szSrc     ----- �ַ���ָ�� (ʵ�ʳ��ȴ洢���ַ�����)
 * �� �� ֵ��������ռ�ֽ���
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/26
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int Dec2Hex(unsigned char *szSrc, int iLenType, int iLen)
{
    int iOffSet;

    if (iLenType == 1)
    {
        iOffSet = 1;
        (*szSrc++) = (unsigned char)iLen;
    }
    else
    {
        iOffSet = 2;
        (*szSrc++) = (unsigned char)(iLen / 256);
        (*szSrc++) = (unsigned char)(iLen % 256);
    }

    return iOffSet;
}

/* ----------------------------------------------------------------
 * ��    �ܣ�����Ч�򳤶�ת��Ϊbcd��
 * ���������iLenType  ----- ���ĳ�������
 *           iLen      ----- ����ʵ�ʳ���
 * ���������szSrc     ----- �ַ���ָ�� (ʵ�ʳ��ȴ洢���ַ�����)
 * �� �� ֵ��������ռ�ֽ���
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/26
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int Dec2Bcd(unsigned char *szSrc, int iLenType, int iLen)
{
    int iOffSet;

    if (iLenType == 1)
    {
        iOffSet = 1;
        (*szSrc++) = (unsigned char)((iLen % 10) + (iLen / 10) * 16);
    }
    else
    {
        iOffSet = 2;
        (*szSrc++) = (unsigned char)(iLen / 100);
        (*szSrc++) = (unsigned char)(((iLen % 100) / 10) * 16 + (iLen % 100) % 10);
    }

    return iOffSet;
}
