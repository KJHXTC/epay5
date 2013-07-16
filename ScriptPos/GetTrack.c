/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ���ݣ����ո�ƽ̨epay������ ��ȡ�ŵ�����
** �� �� �ˣ�fengwei
** �������ڣ�2013/03/06
**
** $Revision: 1.1 $
** $Log: GetTrack.c,v $
** Revision 1.1  2013/03/11 07:13:19  fengw
**
** 1�����ŵ����ݴ����װΪ�����������Ľ���ʱ���á�
**
*******************************************************************/

#define _EXTERN_

#include "ScriptPos.h"

/****************************************************************
** ��    �ܣ�����POS���ʹŵ�����
** ���������
**        ptApp                     app�ṹָ��
**        szData                    ��������
** ���������
**        ��
** �� �� ֵ��
**        >0                        �ŵ����ݳ���
**        FAIL                      �����ŵ�����ʧ��
** ��    �ߣ�
**        fengwei
** ��    �ڣ�
**        2013/03/06
** ����˵����
**
** �޸���־��
****************************************************************/
int GetTrack(T_App *ptApp, char *szData)
{
    int     iTrackLen;              /* �ŵ����ݳ��� */
    int     iTmp;                   /* ��ʱ���� */
    int     i;                      /* ��ʱ���� */

    iTrackLen = 0;

    /* ���ŵ� */
    iTmp = (uchar)(szData[iTrackLen]);
    if(iTmp > 37)
    {
        WriteLog(ERROR, "���ŵ����ݳ���[%d]�Ƿ�!", iTmp);

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
    }
    iTrackLen += 1;

    if(iTmp != 0)
    {
        BcdToAsc((uchar*)(szData+iTrackLen), iTmp, LEFT_ALIGN, 
                 ptApp->szTrack2);

        iTrackLen += iTmp%2==0?iTmp/2:iTmp/2+1;

        /* �滻�ŵ����ݷָ��� */
        for(i=0;i<iTmp;i++)
        {
            if(ptApp->szTrack2[i] == 'D')
            {
                ptApp->szTrack2[i] = '=';
            }
        }
    }
#ifdef DEBUG
    WriteLog(TRACE, "���ŵ�[%d]:[%s]", iTmp, ptApp->szTrack2);
#endif

    /* ���ŵ� */
    iTmp = (uchar)(szData[iTrackLen]);    
    if(iTmp > 104)
    {
        WriteLog(ERROR, "���ŵ����ݳ���[%d]�Ƿ�!", iTmp);

        strcpy(ptApp->szRetCode, ERR_DATA_FORMAT);

        return FAIL;
    }
    iTrackLen += 1;

    if(iTmp != 0)
    {
        BcdToAsc((uchar*)(szData+iTrackLen), iTmp, LEFT_ALIGN, 
                 ptApp->szTrack3);

        iTrackLen +=  iTmp%2==0?iTmp/2:iTmp/2+1;

        /* �滻�ŵ����ݷָ��� */
        for(i=0;i<iTmp;i++)
        {
            if(ptApp->szTrack3[i] == 'D')
            {
                ptApp->szTrack3[i] = '=';
            }
        }
    }
#ifdef DEBUG
    WriteLog(TRACE, "���ŵ�[%d]:[%s]", iTmp, ptApp->szTrack3);
#endif

    return iTrackLen;
}