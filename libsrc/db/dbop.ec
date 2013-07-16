/* ----------------------------------------------------------------
 *  Copyright(C)2006 - 2013 ���������豸���޹�˾
 *  ��Ҫ���ݣ����ݿ�����ӿ�
 *  �� �� �ˣ�
 *  �������ڣ�
 * ----------------------------------------------------------------
 * $Revision: 1.14 $
 * $Log: dbop.ec,v $
 * Revision 1.14  2012/12/06 02:31:54  yezt
 * �����޸�ע��
 *
 * Revision 1.13  2012/12/06 01:58:17  yezt
 *
 * ʹ���û�������epay5���û����жϣ���ͬ���ݿⶼ����ʹ��
 *
 * Revision 1.12  2012/12/03 08:04:58  yezt
 * ����ChkDBLink����
 *
 * Revision 1.11  2012/12/03 07:46:04  yezt
 *
 * ����.h�ļ����룬�޸�����״̬���麯��
 *
 * Revision 1.10  2012/12/03 05:34:39  yezt
 *
 * �޸����ݿ�����״̬��֤����
 *
 * Revision 1.9  2012/11/30 05:45:44  yezt
 * �޸�WriteETLogΪWriteLog
 *
 * Revision 1.8  2012/11/29 06:12:49  yezt
 *
 * �������ݿ�����״̬�жϺ���
 *
 * Revision 1.7  2012/11/29 06:06:41  linqil
 * *** empty log message ***
 *
 * Revision 1.6  2012/11/28 08:33:53  linqil
 * ȥ����user.h������
 *
 * Revision 1.5  2012/11/28 05:48:38  linqil
 * �޸���־����
 *
 * Revision 1.4  2012/11/26 05:11:54  yezt
 * *** empty log message ***
 *
 * Revision 1.3  2012/11/21 06:01:39  chenjr
 * �޸�ϵͳ����ƴд��(fprintf)
 *
 * Revision 1.2  2012/11/20 07:26:48  chenjr
 * format conv
 *
 * Revision 1.1  2012/11/20 07:25:03  chenjr
 * init
 *
 * ----------------------------------------------------------------
 */

#define _DB_EXTERN_

#include <stdio.h>
#include <stdlib.h>
#include "libpub.h"
#include "db.h"

#ifdef DB_ORACLE
    EXEC SQL INCLUDE SQLCA;
#endif

#ifdef DB_INFORMIX
    $include sqlca;
#endif

/* ���¼���ɸ�����Ŀ��������޸� */
#define CONFPATH   "Setup.ini"       /*�����ļ��� */
#define SECTION    "SECTION_DB"      /*���ݿ������½���(��Ӧ�������ļ�)*/
#define DBUSER     "DB_USER"         /*�û����Ʊ�ǩ��(��Ӧ�������ļ�)*/
#define DBPWD      "DB_PWD"          /*�û������ǩ��(��Ӧ�������ļ�) */
#define DBSERVICE  "DB_SERVICES"     /*���ݿ�����ǩ��(��Ӧ�������ļ�)*/

#define SUCC       0
#define FAIL       -1

EXEC SQL BEGIN DECLARE SECTION;
    char  gszPwd[200];     /* �û��� */
    char  gszUsr[200];     /* ���� */
    char  gszSrv[300];     /* ���ݿ��� */
EXEC SQL END DECLARE SECTION;

#define GET_DBCONF(tag, val) \
        do    \
        { \
            if (-1 == ReadConfig(CONFPATH, SECTION, tag, val)) \
            { \
                WriteLog(ERROR, "�����ݿ������ļ�����"); \
                return FAIL; \
            } \
        }while (0) 


/* ----------------------------------------------------------------
 * ��    �ܣ��������ݿ�����
 * �����������
 * �����������
 * �� �� ֵ��SUCC �򿪳ɹ���  FAIL ��ʧ��
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/26
 * ����˵����ϵͳ����ʱ���������ݿ�
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int OpenDB()
{
#ifdef DB_INFORMIX
    sqldetach();

    $database pos;
    if (SQLCODE)
    {
        WriteLog(ERROR, "database fail. SQLCODE[%ld-%.*s]", SQLCODE, SQLERRM.SQLERRML, SQLERRM.SQLERRMC);
        return(FAIL);
    }

    return SUCC;
#endif

#ifdef DB_ORACLE
    memset(gszPwd, 0, sizeof(gszPwd));
    memset(gszUsr, 0, sizeof(gszUsr));
    memset(gszSrv, 0, sizeof(gszSrv));


    /* �������ļ���ȡ���ݿ��û���������� */
    GET_DBCONF(DBUSER,    gszUsr);
    GET_DBCONF(DBPWD,     gszPwd);
    GET_DBCONF(DBSERVICE, gszSrv);

    DelAllSpace(gszUsr);
    DelAllSpace(gszPwd);
    DelAllSpace(gszSrv);

    if (strlen(gszSrv) > 0)
    {
        EXEC SQL
        CONNECT :gszUsr IDENTIFIED BY :gszPwd USING  :gszSrv;
    }
    else
    {
        EXEC SQL
        CONNECT :gszUsr IDENTIFIED BY :gszPwd;
    }

    if (SQLCODE)
    {
        WriteLog(ERROR, "Connect DB As USR[%s]PWD[%s]SRV[%s] Fail. SQLCODE[%ld]",
             gszUsr, gszPwd, gszSrv, SQLCODE);
        return(FAIL);
    }

    return(SUCC); 
#endif

}

/* ----------------------------------------------------------------
 * ��    �ܣ��Ͽ����ݿ�����
 * �����������
 * �����������
 * �� �� ֵ��SUCC  �ɹ���   FAIL  ʧ��
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/26
 * ����˵����ϵͳ�ر�ʱ�򣬶Ͽ����ݿ�
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
void CloseDB()
{
#ifdef DB_INFORMIX
    $close database;
#endif
    
#ifdef DB_ORACEL
    EXEC SQL COMMIT WORK RELEASE;
    if (SQLCODE)
    {
        WriteLog(ERROR, "Close DB As USR[%s] Fail[SQLCODE=%ld]", 
                gszUsr, SQLCODE);
    }
#endif
}

/* ----------------------------------------------------------------
 * ��    �ܣ���ʼһ������
 * �����������
 * �����������
 * �� �� ֵ��SUCC  �ɹ���   FAIL  ʧ��
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/26
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int BeginTran()
{
#ifdef DB_ORACLE
    return SUCC;
#endif

#ifdef DB_INFORMIX
    $begin work;
    if (SQLCODE)
    {
        WriteLog(ERROR, "Failure to begin work[SQLCODE=%d]", SQLCODE);
        return (FAIL);    
    }
    
    return (SUCC);
#endif
}

/* ----------------------------------------------------------------
 * ��    �ܣ��ύһ������
 * �����������
 * �����������
 * �� �� ֵ��SUCC  �ɹ���   FAIL  ʧ��
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/26
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int CommitTran()
{
    EXEC SQL COMMIT WORK;
    if (SQLCODE)
    {
        WriteLog(ERROR, "Failure to commit work[SQLCODE=%d]", SQLCODE);
        return( FAIL );
    }
    return (SUCC);
}

/* ----------------------------------------------------------------
 * ��    �ܣ��ع����ݿ�����
 * �����������
 * �����������
 * �� �� ֵ��SUCC  �ɹ���   FAIL  ʧ��
 * ��    �ߣ��½���
 * ��    �ڣ�2012/12/26
 * ����˵�������ݿ�����\����\ɾ����ʧ��ʱ��ع�
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 * ----------------------------------------------------------------
 */
int RollbackTran()
{
    EXEC SQL ROLLBACK WORK;
    if( SQLCODE)
    {
        WriteLog(ERROR, "Failure to rollback work[SQLCODE=%d]", SQLCODE);
        return (FAIL);    
    }
    return( SUCC );
}

/* ----------------------------------------------------------------
 * ��    �ܣ��ж����ݿ������Ƿ�����
 * �����������
 * �����������
 * �� �� ֵ��SUCC  �������� /  FAIL  �Ͽ�����
 * ��    �ߣ�Ҷ��ͦ
 * ��    �ڣ�2012/11/29
 * ����˵����
 * �޸���־���޸�����    �޸���      �޸����ݼ���
 *           2012/12/06  yezt
 * �޸����ݼ���:ʹ���û�������epay5���û����жϣ���ͬ���ݿⶼ����ʹ��
 * ----------------------------------------------------------------
 */
int ChkDBLink()
{
    EXEC SQL
         SELECT count(*) FROM module;
    if(SQLCODE)
    {
        WriteLog(ERROR, "Disconnect DB[SQLCODE=%d]", SQLCODE);
        return (FAIL);
    }
    return( SUCC );
}
