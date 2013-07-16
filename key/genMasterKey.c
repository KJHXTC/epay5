/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�ϵͳ���������Կ�ϳɹ���
 *  �� �� �ˣ�chenjr
 *  �������ڣ�2012/12/7
 * ----------------------------------------------------------------
 * $Revision: 1.2 $
 * $Log: genMasterKey.c,v $
 * Revision 1.2  2012/12/24 04:34:17  chenjr
 * �����ԿУ��ֵ����
 *
 * Revision 1.1  2012/12/07 06:18:24  chenjr
 * init
 *
 * Revision 1.1  2012/12/07 06:11:21  chenjr
 * init
 *
 * ----------------------------------------------------------------
 */


#include "genMasterKey.h"

int iKeyLen = 0;                /* ��Կ���� */
int iComponent = 0;             /* ��Կ���� */
unsigned char uszaKeyComp[49];  /* ��Կ���� */

/*
 * ��ӡ��Կ����ѡ��˵�
 */
void PrtKEYLTMenu(void)
{
    system("clear");
    printf(MODELTITLE);
    printf(KEYLT_MENU);
}

/*
 * ��ӡ��Կ����ѡ��˵�
 */
void PrtKeyCompMenu(void)
{
    system("clear");
    printf(MODELTITLE);
    printf(KEYLT_LEN, iKeyLen);
    printf(KEYCOM_MENU);
}

/*
 * ��ӡ"������Կ����"��ʾͷ
 */
void PrtComConHead(void)
{
    system("clear");
    printf(COMCON_HEAD, iKeyLen, iComponent);
}

/*
 * ��ӡ��Կ������ʾͷ
 */
void PrtSaveComHead(void)
{
    fflush(NULL);
    system("clear");
    printf(COMCON_HEAD, iKeyLen, iComponent);
}

/* ----------------------------------------------------------------
 * ��    �ܣ�������Կ����(�����������������ֵ)
 * ���������pfun   ָ���庯��
 * ���������
 * �� �� ֵ���˵���Ӧֵ
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/7
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int setKeyArgu(void(*pfun)(void))
{
    int iTmp = 0;

    do{
        pfun();

        printf("\t");
        iTmp = getchar();
        getchar();  /* ���ջس�,���� */

        if (iTmp == 'Q' || iTmp == 'q')
        {
            exit(0);
        }
    }while (iTmp != '1' && iTmp != '2' && iTmp != '3');

    return iTmp - '0';
}

/* ----------------------------------------------------------------
 * ��    �ܣ��ַ���Χ�ж��봦��
 *           �ַ�ֻ����0-9��a-f��A-F,���a-f��ת����A-F
 * ���������piCh   �ַ�ֵ
 * ���������
 * �� �� ֵ��-1  �޷��ַ�   >0 �����ַ�ASCֵ
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/7
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int chkChar(int *piCh)
{
    if ( (*piCh >= '0' && *piCh <= '9') ||
         (*piCh >= 'a' && *piCh <= 'f') ||
         (*piCh >= 'A' && *piCh <= 'F') 
       )
    {
        if ( *piCh >= 97 && *piCh <= 102 )
        {
            *piCh -= ('a'-'A');
        }

        return *piCh;
    }
    else
    {
        return -1;
    }
}

/* ----------------------------------------------------------------
 * ��    �ܣ��ӱ�׼�����ȡһ���ַ�����������ȡ���ַ����д���
 * �����������
 * ���������iVal �������ַ� ���ַ���Χ0-9��A-F)
 * �� �� ֵ��-1  ϵͳ����   >0 �����ַ�ASCֵ
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/7
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int getch(unsigned char *iVal)
{
    struct termios tm, tm_old;
    int fd = 1, c;

    if (tcgetattr(fd, &tm) < 0)
    {
        return -1;
    }

    tm_old = tm;
    cfmakeraw(&tm);

    if (tcsetattr(fd, TCSANOW, &tm) < 0)
    {
        return -1;
    }

    do{
        c = fgetc(stdin);
    }while (chkChar(&c) == -1);

    if (tcsetattr(fd, TCSANOW, &tm_old) < 0)
    {
        return -1;
    }

    *iVal = c;

    return c; 
}

/* ----------------------------------------------------------------
 * ��    �ܣ���ȡ��Կ�������ϳ�
 * ���������iComp   ����ֵ���ڼ������)
 * ���������uszKeyComp  �ϳɺ����Կ����
 * �� �� ֵ����
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/7
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
void setKeyComp(int iComp,  unsigned char *uszKeyComp)
{
    int iredo = 0, inum, iInAgain, i;
    unsigned char usaComp[2][100];
    unsigned char tmp[100];

    do{
        iInAgain = 0;
        memset(usaComp, 0, sizeof(usaComp));

        do{
            fflush(NULL);
            PrtComConHead();
    
            iredo == 0 ?  printf(COMCON_INPUT, iComp + 1)
                       :  printf(COMCON_REIN, iComp + 1);
    
            inum = 0;
            printf(COMCON_INLEN, inum);
            
            /* ������Կ���ȴӱ�׼�����ȡ��Կ���� */
            while (inum < iKeyLen)
            {
                if (getch(&usaComp[iredo][inum]) == -1)
                {
                    exit(0);
                }
    
                inum++;
                inum < 11 ? printf("\b") : printf("\b\b");
                printf("%d", inum);
            }
    
            iredo++;
        }while(iredo < 2);
    
        /* ��������һ�����ж� */
        if (memcmp(usaComp[0], usaComp[1], iKeyLen) != 0)
        {
            printf(COMCON_ICON);
            getchar();
            iredo = 0;
            iInAgain = 1;
        }
    }while (iInAgain);

    /* �ϳɷ��� */
    AscToBcd(usaComp[0], iKeyLen, 0, tmp);
    for (i=0; i< (iKeyLen+1) / 2; i++)
    {
        uszKeyComp[i] ^= tmp[i]; 
    }
}

void getChkVal(unsigned char *uszChk)
{
    DES(uszaKeyComp, CHKVALEELEM, uszChk);
}


/* ������ */
int main(void)
{
    int i, icomp = 0;
    char szKeyText[100], szChkVal[10];
    unsigned char uszChkV[5];

    /* ѡ����Կ����(��������˫����) */
    iKeyLen = setKeyArgu(PrtKEYLTMenu) * 16;

    /* ѡ����Կ������(һ��������������������������) */
    iComponent = setKeyArgu(PrtKeyCompMenu);

    /* ������Կ���ȼ���������ȡ�������ϳ���Կ */
    memset(uszaKeyComp, 0, sizeof(uszaKeyComp));
    while (icomp < iComponent)
    {
        setKeyComp(icomp, uszaKeyComp);
        icomp++;
    }

    memset(szKeyText, 0, sizeof(szKeyText));
    BcdToAsc(uszaKeyComp, iKeyLen, 0, szKeyText);

    /* ������Կ */
    PrtSaveComHead();
    if (SaveMasterKey(szKeyText, iKeyLen) != FAIL)
    {
        getChkVal(uszChkV);
        memset(szChkVal, 0, sizeof(szChkVal));
        BcdToAsc(uszChkV, 8, 0, szChkVal);
        printf(SAVECOM_SUCC, szChkVal);
    }
    else
    {
        printf(SAVECOM_SUCC);
    }
}

