/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ�
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision: 1.1 $
 * $Log: libpub.h,v $
 * Revision 1.1  2012/12/17 07:18:58  fengw
 *
 * 1���������⡢EPAY����ͷ�ļ�����$WORKDIR/inclĿ¼��
 *
 * Revision 1.13  2012/12/13 05:07:02  fengw
 *
 * 1��Tlv�����淶����
 *
 * Revision 1.12  2012/12/04 07:56:25  chenjr
 * ����淶��
 *
 * Revision 1.11  2012/11/29 07:02:31  zhangwm
 *
 * �����Ƿ��ӡ��־����
 *
 * Revision 1.10  2012/11/29 01:56:41  zhangwm
 *
 * �������ý�����Ϣ������������������������־��ӡʹ��
 *
 * Revision 1.9  2012/11/29 01:11:27  zhangwm
 *
 * �޸�WriteETLogΪWriteLog
 *
 * Revision 1.8  2012/11/28 01:33:20  chenjr
 * ��Ӵ����ӿ�
 *
 * Revision 1.7  2012/11/27 03:36:31  zhangwm
 *
 * �޸�ͷ�ļ�Ϊ�ڲ�ʹ��
 *
 * Revision 1.6  2012/11/27 03:22:56  chenjr
 * ���<sys/msg.h>ͷ�ļ�
 *
 * Revision 1.5  2012/11/26 06:45:35  zhangwm
 *
 *     ��������־��ӡ��ֲ����������
 *
 * Revision 1.4  2012/11/26 03:19:28  chenjr
 * ���8583�½ӿ�
 *
 * Revision 1.3  2012/11/26 02:43:35  chenjr
 * ��ӻ�ȡ��Ϣ������Ϣ�ӿ�
 *
 * Revision 1.2  2012/11/20 07:50:39  chenjr
 * ȥ��ReadConfig�ӿڵ�Ĭ��ֵ�������
 *
 * Revision 1.1  2012/11/20 03:27:37  chenjr
 * init
 *
 * ----------------------------------------------------------------
 */

#ifndef _LIBPUB_H_
#define _LIBPUB_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/msg.h>

#include "Tlv.h"
#include "8583.h"

/* --------------------
 * [ASC-Bcd��ת�ӿ�]
 * --------------------*/
    /*--ASCIIתBCD */
    extern int AscToBcd(unsigned char  *uszAscBuf, int iAscLen,
                        unsigned char   ucType, unsigned char *uszBcdBuf);
    /*--BCDתASCII */
    extern int BcdToAsc(unsigned char  *uszBcdBuf, int iAscLen,
             unsigned char   ucType,    unsigned char *uszAscBuf);


/* --------------------
 * [��־��¼��ӿ�]
 * --------------------*/
    /* д������־�͸�����־ */
    #ifdef LINUX
        void WriteLog( char* szFileInfo, int iLine, int iType, char* szFmt, ...);

    #else
        WriteLog(char* szFileInfo, int iLine, int iType, char* szFmt, va_dcl va_alist );
    #endif

    /* ���ô�����־�д�ӡ�Ľ�����Ϣ */
    int SetEnvTransId(char* pszTransId);

    /* �ж���־�Ƿ���Ҫ��ӡ */
    int IsPrint(int iType);

/* --------------------
 * [ʱ��������ӿ�] 
 * --------------------*/
    /*--ȡϵͳ��ǰ����ʱ�� ��ʽ�Զ���*/
    extern int GetSysDTFmt(const char *szFmt, char *szDTStr);

    /*--ȡϵͳ��ǰ���� ��ʽYYYYMMDD */
    extern int GetSysDate(char *szDateStr);
 
    /*--ȡϵͳ��ǰʱ�� ��ʽHHMMSS */
    extern int GetSysTime(char *szTimeStr);

    /*--ȡϵͳ��ǰ������ǰ(��)���������  ��ʽYYYYMMDD */
    extern int GetDateSinceCur(int iDays, char *szDateStr);

    /*--�������ڸ�ʽ�Ƿ�Ϸ�(�Ϸ���ʽYYYYMMDD, ע��ƽ�����) */
    extern int ChkDateFmt(char *szDateStr);


/* --------------------
 * [�ַ���������ӿ�] 
 * --------------------*/
    extern char *DelHeadSpace(char *szStr);
    extern char *DelTailSpace(char *szStr);
    extern char *DelAllSpace(char *szStr);
    extern char *ToUpper(char *szStr);
    extern char *ToLower(char *szStr);
    extern int  IsNumber(char *szStr);
    extern int  GetField(char *szSrc, int iFieldNo, char cDivider, 
                         char *szDest);

/* --------------------
 * [������ӿ�] 
 * --------------------*/
    /* ����TCP�ͻ��� */
    extern int CreateCliSocket(char *szSrv, char *szSrvPort);
    /* ����TCP/UDP����� */
    extern int CreateSrvSocket(char *szSrvPort, char *szSrvType, 
                               int iQueLen);

    extern int SrvAccept(int iLisSock, char *szCliIp);

    /* ���������� */
    extern int ReadSockFixLen(int iSockFd, int iTimeOut, int iLen, 
                              char *szBuf);

    extern int ReadSockVarLen(int iSockFd, int iTimeOut, char *szBuf);

    extern int WriteSock(int iSockFd, unsigned char *uszBuf, int iLen, 
                         int iTimeOut);

    extern int SendToUdpSrv(char *szIp, char *szPort, char *szBuf, 
                            int iLen);


/* --------------------
 * [��ȫ��ӿ�]
 * --------------------*/

    /* MD5 */
    extern void GenMD5(char *szSource, char *szDest);

    /* LRC */
    extern unsigned char Lrc(unsigned char *uszStr, int iLen);

    /* BASE64���뼰���� */
    extern int base64_encode(char *szSrc, unsigned int nSize,char *szDest);
    extern int base64_decode(char *szSrc, unsigned int nSize,char *szDest);

    /* ANSIX98�ӽ���(PIN) */
    extern int ANSIX98(unsigned char *uszKey, char *szPan,  char *szPwd,
                       int iPwdLen, int iFlag, unsigned char *uszResult);

    extern int _ANSIX98(unsigned char *uszKey, char *szPan, 
                        unsigned char *uszPwd, int iFlag, 
                        unsigned char *uszResult);

    /* MAC����,����ANSIX99��919������� */
    extern void ANSIX99(unsigned char *uszMacKey, unsigned char *uszBuf, 
                        int iLen, int iAlg, unsigned char *uszMac);

    extern void ANSIX919(unsigned char *uszMacKey, unsigned char *uszBuf, 
                         int iLen, unsigned char *uszMac);

    extern void Mac_Normal(unsigned char *uszMacKey, unsigned char *uszBuf,
                           int iLen, int iAlg, unsigned char *uszMac);

    extern void XOR(unsigned char *uszInData, int iLen,
                    unsigned char *uszOutData );

    /* SINGLE_DES TRIPLE_DES �ӽ��� */
    extern void DES(unsigned char *uszKey,unsigned char *uszSrc,
                    unsigned char *uszDest);
    extern void _DES(unsigned char *uszKey,unsigned char *uszSrc,
                     unsigned char *uszDest);
    extern void TriDES(unsigned char *uszKey ,unsigned char *uszSrc, 
                       unsigned char *uszDest);
    extern void _TriDES(unsigned char *uszKey,unsigned char *uszSrc, 
                        unsigned char *uszDest);


/* --------------------
 * [���׽��0����ʽת��]
 * --------------------*/
    extern int ChgAmtDotToZero(char *szSrc, int iOutLen, int iPreFlag, 
                               char *szDest);
    extern int ChgAmtZeroToDot(char *szSrc, int iOutLen, char *szDest);


/* --------------------
 * [IPC�ӿ�]
 * --------------------*/
    /* ��Ϣ���� */
    extern int CreateMsgQue(char *szFile,  int iId);
    extern int GetMsgQue(char *szFile,  int iId);
    extern int RmMsgQue(int iMsgid);
    extern int GetMsgQueStat(int iMsgid, struct msqid_ds *ptDs);
    extern int SndMsgToMQ(int iMsgid, long lMsgType, char *szSndBuf, 
                          int iSndLen);
    extern int RcvMsgFromMQ(int iMsgid, long lMsgType, int iTimeOut, 
                            char *szRcvBuf);

    /* �����ڴ� */
    extern int CreateShm(char *szFile,  int iId, int iShmSize);
    extern int GetShm(char *szFile,  int iId, int iShmSize);
    extern char *AtShm(int iShmid);
    extern int RmShm(int iShmid);

    /* �ź���*/
    extern int CreateSem(char *szFile,  int iId, int iResource);
    extern int GetSem(char *szFile,  int iId);
    extern int SemOpera(int iSemid, int iResource);
    extern int P(int iSemid, int iResource);
    extern int V(int iSemid, int iResource);
    extern int RmSem(int iSemid);


/* --------------------
 * [�����ļ���ȡ�ӿ�]
 * --------------------*/
    extern int ReadConfig(char *szFilenm, char *szSection, char *szItem,
                          char *szVal);

/* --------------------
 * [8583�ӿ�]
 * --------------------*/
    extern void ClearBit(ISO_data *ptData);
    extern int GetBit(MsgRule *ptMR, ISO_data *ptData, int iNo, 
                      char *szDest);
    extern int SetBit(MsgRule *ptMR, char *szSrc, int iNo, int iLen, 
                      ISO_data *ptData);
    extern int IsoToStr(MsgRule *ptMR, ISO_data *ptData, 
                        unsigned char *szDest);
    extern int StrToIso(MsgRule *ptMR, unsigned char *szSrc, 
                        ISO_data *ptData);
    extern int DebugIso8583(MsgRule *ptMR, ISO_data *ptData, char *szDest);



/* --------------------
 * [TLV�ӿ�]
 * --------------------*/
    /* TLV���ó�ʼ��������Tag��Len��Value��ʽ���� */
    extern void InitTLV(T_TLVStru *pTLV, int iTagType,
                        int iLenType, int iValueType);

    /* ���TLV��ʽ���� */
    extern int SetTLV(T_TLVStru *pTLV, char *szTag,
                      int iLen, char* szValue);

    /* ����Tagֵ��ȡValueֵ */
    extern int GetValueByTag(T_TLVStru *pTLV, char* szTag,
                             char* szValueBuf, int iBufSize);
  
    /* ��TLV��ʽ���ݴ�����ַ��� */
    extern int PackTLV(T_TLVStru *pTLV, char* szBuf);

    /* ���ַ������ΪTLV��ʽ���� */
    extern int UnpackTLV(T_TLVStru *pTLV, char* szBuf, int iBufLen);

    /* ��ӡTLV��������(������) */
    extern char *DebugTLV(T_TLVStru *pTLV, char *szDest);

#endif  /*_LIBPUB_H_ */ 
