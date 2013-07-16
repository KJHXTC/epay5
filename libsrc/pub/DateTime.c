
/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�ʱ��������ӿں���
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision: 1.5 $
 * $Log: DateTime.c,v $
 * Revision 1.5  2012/12/04 06:26:21  chenjr
 * ����淶��
 *
 * Revision 1.4  2012/11/27 03:20:01  linqil
 * *** empty log message ***
 *
 * Revision 1.3  2012/11/27 02:47:40  linqil
 * ��������pub.h �޸�return
 *
 * Revision 1.2  2012/11/21 06:06:59  chenjr
 * ��ʽת��
 *
 * Revision 1.1  2012/11/20 03:27:37  chenjr
 * init
 *
 * ----------------------------------------------------------------
 */

#include <time.h>
#include <string.h>
#include <stdio.h>
#include "pub.h"

#define ONEDAYCLOCKS (24 * 60 * 60)
#define MAXSIZE      60

extern int IsNumber(char *szStr);
static struct tm *GetLocalTime(long lSec);
static int IsLeapYear(int iYear);
static int GetMonMaxDay(int iYear, int iMon);

/* ----------------------------------------------------------------
 * ��    �ܣ�ȡϵͳ��ǰʱ������ (��ʽ�Զ���)
 * ���������szFmt     ���ʱ�����ڸ�ʽ 
 * ���������szDTStr   �����ǰϵͳʱ������,��ʽ�Զ���
 * �� �� ֵ��-1   ʧ�ܣ�  0  �ɹ�
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int GetSysDTFmt(const char *szFmt, char *szDTStr)
{
    struct tm *ptTm;

    if (szFmt == NULL || szDTStr == NULL)
    {
        return FAIL;
    }

    ptTm = GetLocalTime(0);
    strftime(szDTStr, MAXSIZE, szFmt, ptTm);

    return SUCC;
}


/* ----------------------------------------------------------------
 * ��    �ܣ�ȡϵͳ��ǰ����(��ʽYYYYMMDD)
 * �����������
 * ���������szDateStr  �����ǰϵͳ����,��ʽΪYYYYMMDD
 * �� �� ֵ��-1   ʧ�ܣ�  0  �ɹ�
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int GetSysDate(char *szDateStr)
{
    struct tm *ptTm;

    if (szDateStr == NULL) 
    {
        return FAIL;
    }

    ptTm = GetLocalTime(0);
    GetSysDTFmt("%Y%m%d", szDateStr);

    return SUCC;
}


/* ----------------------------------------------------------------
 * ��    �ܣ�ȡϵͳ��ǰʱ��(��ʽHHMMSS)
 * �����������
 * ���������szTimeStr  �����ǰϵͳʱ��,��ʽΪHHMMSS
 * �� �� ֵ��-1   ʧ�ܣ�  0  �ɹ�
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int GetSysTime(char *szTimeStr)
{
    struct tm *ptTm;

    if (szTimeStr == NULL) 
    {
        return FAIL;
    }

    ptTm = GetLocalTime(0);
    GetSysDTFmt("%H%M%S", szTimeStr);

    return SUCC;
}


/* ----------------------------------------------------------------
 * ��    �ܣ�ȡϵͳ��ǰ������ǰ(��)���������(��ʽYYYYMMDD)
 * ���������iDays ���뵱ǰ���ڵ�����
 *           ����, ��ʾ��ǰϵͳ��������iDay�������
 *           0   , ��ǰϵͳ����
 *           ����, ��ʾ��ǰϵͳ������ǰiDay�������
 * ���������szDateStr  �����ǰϵͳ����,��ʽΪYYYYMMDD
 * �� �� ֵ��-1   ʧ�ܣ�  0  �ɹ�
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int GetDateSinceCur(int iDays, char *szDateStr)
{
    long      lSec;
    struct tm *ptTm;

    if (szDateStr == NULL)
    {
        return FAIL;
    }

    lSec = iDays * ONEDAYCLOCKS;
    ptTm = GetLocalTime(lSec);
    strftime(szDateStr, MAXSIZE, "%Y%m%d", ptTm);

    return SUCC;
}



/* ----------------------------------------------------------------
 * ��    �ܣ��������ڸ�ʽ�Ƿ�Ϸ�(�Ϸ���ʽYYYYMMDD)
 * ���������szDateStr
 * �����������
 * �� �� ֵ��-1   ��ʽ�Ƿ���  0  ��ʽ�Ϸ�
 * ��    �ߣ�
 * ��    �ڣ�
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int ChkDateFmt(char *szDateStr)
{
    int iYear, iMon, iDay;

    if (szDateStr == NULL)
    {
        return FAIL;
    }

    /* ������8���ֽ� */
    if (strlen(szDateStr) != 8)
    {
        return FAIL;
    }
 
    /* ������ȫ���� */
    if (IsNumber(szDateStr) == -1)
    {
        return FAIL;
    }

    /* ���������Ч��Χ�� */
    iYear = (szDateStr[0] - '0') * 1000 +
            (szDateStr[1] - '0') * 100  +
            (szDateStr[2] - '0') * 10   +
            (szDateStr[3] - '0'); 
    if (iYear < 1900 || iYear > 2500)
    {
        return FAIL;
    }

    /* �±�������Ч��Χ�� */
    iMon = (szDateStr[4] - '0') * 10   +
           (szDateStr[5] - '0'); 
    if (iMon < 1 || iMon >= 13)
    {
        return FAIL;
    }

    /* �ձ�������Ч��Χ��(ע��ƽ������·ݵ������� */
    iDay = (szDateStr[6] - '0') * 10   +
           (szDateStr[7] - '0');

    if (iDay < 1 || iDay >  GetMonMaxDay(iYear, iMon))
    {
        return FAIL;
    }

    return SUCC;
}


/* ��ȡָ���µ�������� */
static int GetMonMaxDay(int iYear, int iMon)
{
    int iDays = 0;
    int mon_maxdayset[]={0,31,28,31,30,31,30,31,31,30,31,30,31};

    iDays = mon_maxdayset[iMon];
    if (!IsLeapYear(iYear) && iMon == 2)
    {
        iDays += 1;
    }

    return iDays;
}



/* �ж�ƽ���� */
static int IsLeapYear(int iYear)
{
    if (iYear <= 0)
    {
        return FAIL;
    }

    if ((iYear % 4 == 0 && iYear % 100 != 0) ||
        iYear % 400 == 0)
    {
        return SUCC;
    }

    return FAIL;
}


/* ����ָ��clock��tm�ṹ */
static struct tm *GetLocalTime(long lSec)
{
    long       lClock;

    time(&lClock);
    lClock += lSec;

    return localtime(&lClock);
}
