/******************************************************************
** Copyright(C)2006 - 2008���������豸���޹�˾
** ��Ҫ����:�����ͼ��ܻ�������ת��
           
** �����б�:
** �� �� ��:Robin 
** ��������:2009/08/29


$Revision: 1.10 $
$Log: errcode.c,v $
Revision 1.10  2012/12/05 06:32:14  wukj
*** empty log message ***

Revision 1.9  2012/12/03 03:24:46  wukj
int����ǰ׺�޸�Ϊi

Revision 1.8  2012/11/29 07:51:43  wukj
�޸���־����,�޸�ascbcdת������

Revision 1.7  2012/11/29 01:57:55  wukj
��־�����޸�

Revision 1.6  2012/11/21 04:13:38  wukj
�޸�hsmincl.h Ϊhsm.h

Revision 1.5  2012/11/21 03:20:31  wukj
1:���ܻ����������޸� 2: ȫ�ֱ�������hsmincl.h


*******************************************************************/

#include "hsm.h"

/*****************************************************************
** ��    ��:ת��SJL05���ܻ���һλ������Ϊƽ̨������ 
** �������:
           uszHsmErrCode    ���ܻ����ص�һλ������
** �������:
           szRetCode       �Ѿ��������λ������
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int DispSjl05ErrorMsg( unsigned char *uszHsmErrCode, char *szRetCode)
{
    char    szMsg[100], szStr[100];

    strcpy( szMsg, "���ܻ����� " );

    switch ( uszHsmErrCode[0] )
    {

    case 0x00:
        strcpy(szRetCode, TRANS_SUCC);
        return SUCC;
    case 0x01:
        strcat( szMsg, "�ޱ�������Կ" );
        break;
    case 0x02:
        strcat( szMsg, "����������Կ" );
        break;
    case 0x05:
        strcat( szMsg, "���ն�����Կ" );
        break;
    case 0x2E:
        strcat( szMsg, "��Ч��MAC����" );
        break;
    case 0x32:
        strcat( szMsg, "��Ч����Կ����" );
        break;
    case 0x0A:
        strcat( szMsg, "�Ƿ�����" );
        break;
    case 0x0C:
        strcat( szMsg, "�Ƿ���������Կ����" );
        break;
    case 0x10:
        strcat( szMsg, "��Ч���㷨ģʽ" );
        break;
    case 0x19:
        strcat( szMsg, "��żУ�����" );
        break;
    case 0x20:
        strcat( szMsg, "�Ƿ��ĸ�����Ϣ" );
        break;
    case 0x2C:
        strcat( szMsg, "�Ƿ���������Կ" );
        break;
    case 0x59:
        strcat( szMsg, "��������ݳ��ȴ���" );
        break;
    case 0x5D:
        strcat( szMsg, "���볤�ȴ�" );
        break;
    case 0x61:
        strcat( szMsg, "��Ϣ̫��" );
        break;
    case 0x62:
        strcat( szMsg, "��Ϣ̫��" );
        break;
    case 0xb2:
        strcat( szMsg, "��Ϣ���ʹ���" );
        break;
    case 0xb3:
        strcat( szMsg, "��Ϣ���մ���" );
        break;
    case 0xb4:
        strcat( szMsg, "������Ϣ���ȴ���" );
        break;
    default:
        sprintf( szStr, "hsm system error %02x", uszHsmErrCode[0]&0xFF );
        strcat( szMsg, szStr );
        break;
    }
    WriteLog( ERROR, szMsg );
    strcpy( szRetCode, ERR_SYSTEM_ERROR );

    return FAIL;
}

/*****************************************************************
** ��    ��:ת������ר�ü��ܻ���һλ������Ϊƽ̨������ 
** �������:
           uszHsmErrCode    ���ܻ����ص�һλ������
** �������:
           szRetCode       �Ѿ��������λ������
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int DispUphsmErrorMsg( unsigned char *uszHsmErrCode, char *szRetCode )
{
    int iErr;
    char    szMsg[100], szTmpStr[100];

    uszHsmErrCode[2] = 0;

    iErr = atol( uszHsmErrCode );

    sprintf( szMsg, "���ܻ�����%02ld��", iErr );
    switch ( iErr )
    {

    case 0: 
        strcat( szMsg, "hsm����ɹ�" );
        break;
    case 1:
        strcat( szMsg, "hsm������Կ" );
        break;
    case 2:
        strcat( szMsg, "hsm�޹�����Կ1" );
        break;
    case 3:
        strcat( szMsg, "hsm�޹�����Կ2" );
        break;
    case 4:
        strcat( szMsg, "hsm������Կ1��żУ���" );
        break;
    case 5:
        strcat( szMsg, "hsm������Կ2��żУ���" );
        break;
    case 6:
        strcat( szMsg, "hsm���ϵ�����Կ" );
        break;
    case 10:
        strcat( szMsg, "hsm�����" );
        break;
    case 11:
        strcat( szMsg, "hsm�����������Ȩ״̬" );
        break;
    case 12:
        strcat( szMsg, "hsmû�в�IC��(�Ӵ��пڽ�����Կ����ʱҪ��A��)" );
        break;
    case 13:
        strcat( szMsg, "hsmдIC����" );
        break;
    case 14:
        strcat( szMsg, "hsm��IC����" );
        break;
    case 15:
        strcat( szMsg, "hsmIC��������" );
        break;
    case 16:
        strcat( szMsg, "hsm��ӡ��û׼����" );
        break;
    case 17:
        strcat( szMsg, "hsmIC��δ��ʽ��" );
        break;
    case 18:
        strcat( szMsg, "hsm��ӡ��ʽû����" );
        break;
    case 20:
        strcat( szMsg, "hsmMACУ���" );
        break;
    case 21:
        strcat( szMsg, "hsmMAC��־ָʾ���" );
        break;
    case 22:
        strcat( szMsg, "hsm��Կ������ʹ��ģʽ����" );
        break;
    case 23:
        strcat( szMsg, "hsmMACģʽָʾ���" );
        break;
    case 24:
        strcat( szMsg, "hsm���ݳ���ָʾ���" );
        break;
    case 26:
        strcat( szMsg, "hsm����ģʽָʾ���" );
        break;
    case 27:
        strcat( szMsg, "hsm�ӽ��ܱ�־��" );
        break;
    case 28:
        strcat( szMsg, "hsmPIN��ʽ��" );
        break;
    case 29:
        strcat( szMsg, "hsmPIN��鳤�ȴ���ʵ��PIN����" );
        break;
    case 31:
        strcat( szMsg, "hsm������Կ1��־��" );
        break;
    case 32:
        strcat( szMsg, "hsm������Կ2��־��" );
        break;
    case 33:
        strcat( szMsg, "hsm������Կ������" );
        break;
    case 34:
        strcat( szMsg, "hsm��Կ��ɢ������" );
        break;
    case 35:
        strcat( szMsg, "hsmPIN�ο�ֵУ���" );
        break;
    case 36:
        strcat( szMsg, "hsm���ʺŲο�ֵУ���" );
        break;
    case 37:
        strcat( szMsg, "hsmPINУ���" );
        break;
    case 38:
        strcat( szMsg, "hsmPIN���ȴ�[С��4���ߴ���12]" );
        break;
    case 39:
        strcat( szMsg, "hsmCVN��־��" );
        break;
    case 40:
        strcat( szMsg, "hsmDES�㷨ģ�����" );
        break;
    case 41:
        strcat( szMsg, "hsmSSF33�㷨ģ�����" );
        break;
    case 60:
        strcat( szMsg, "hsm�޴�����" );
        break;
    case 61:
        strcat( szMsg, "hsm��Ϣ̫��" );
        break;
    case 62:
        strcat( szMsg, "hsm��Ϣ̫��" );
        break;
    case 63:
        strcat( szMsg, "hsm��Ϣ���ֵ��" );
        break;
    case 76:
        strcat( szMsg, "hsm����������Ч" );
        break;
    case 77:
        strcat( szMsg, "hsm�Ƿ��ַ�" );
        break;
    case 78:
        strcat( szMsg, "hsm�ļ�β" );
        break;
    case 79:
        strcat( szMsg, "hsm�ͻ�IP��ַ�﷨��" );
        break;
    default:
        sprintf( szTmpStr, "hsm error %ld", iErr );
        strcat( szMsg, szTmpStr );
        break;
    }
    if( iErr != 0 )
    {
        WriteLog( ERROR, szMsg );
        strcpy( szRetCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    strcpy( szRetCode, TRANS_SUCC );

    return SUCC;
}

/*****************************************************************
** ��    ��:ת��SJL06E���ܻ���һλ������Ϊƽ̨������ 
** �������:
           uszHsmErrCode    ���ܻ����ص�һλ������
** �������:
           szRetCode       �Ѿ��������λ������
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int DispSjl06eErrorMsg( unsigned char *uszHsmErrCode, char *szRetCode )
{
    int iErr;
    char    szMsg[100], szTmpStr[100];

    uszHsmErrCode[2] = 0;

    iErr = atol( uszHsmErrCode );

    sprintf( szMsg, "���ܻ�����%02ld��", iErr );
    switch ( iErr )
    {

    case 0: 
        strcat( szMsg, "hsm����ɹ�" );
        break;
    case 1:
        strcat( szMsg, "hsm������Կ��żУ����󾯸�" );
        break;
    case 2:
        strcat( szMsg, "hsm��Կ���ȴ���" );
        break;
    case 4:
        strcat( szMsg, "hsm��Ч��Կ���ʹ���" );
        break;
    case 5:
        strcat( szMsg, "hsm��Ч��Կ���ȱ�ʶ" );
        break;
    case 10:
        strcat( szMsg, "hsmԴ��Կ��żУ���" );
        break;
    case 11:
        strcat( szMsg, "hsmĿ����Կ��żУ���" );
        break;
    case 12:
        strcat( szMsg, "hsm�û��洢�����������Ч" );
        break;
    case 13:
        strcat( szMsg, "hsm����Կ��żУ���" );
        break;
    case 14:
        strcat( szMsg, "hsmLMK�� 02-03 �����µ� PINʧЧ" );
        break;
    case 15:
        strcat( szMsg, "hsm��Ч����������" );
        break;
    case 16:
        strcat( szMsg, "hsm����̨���ӡ��û��׼���û���û�����Ӻ�" );
        break;
    case 17:
        strcat( szMsg, "hsmHSM ������Ȩ״̬�����߲������ PIN���" );
        break;
    case 18:
        strcat( szMsg, "hsmû��װ���ĵ���ʽ����" );
        break;
    case 19:
        strcat( szMsg, "hsmָ���� Diebold ����Ч" );
        break;
    case 20:
        strcat( szMsg, "hsmPIN��û�а�����Чֵ" );
        break;
    case 21:
        strcat( szMsg, "hsm��Ч������ֵ" );
        break;
    case 22:
        strcat( szMsg, "hsm��Ч���˺�" );
        break;
    case 23:
        strcat( szMsg, "hsm��Ч�� PIN���ʽ����" );
        break;
    case 24:
        strcat( szMsg, "hsmPIN����С�� 4 �����12" );
        break;
    case 25:
        strcat( szMsg, "hsmʮ���Ʊ����" );
        break;
    case 26:
        strcat( szMsg, "hsm��Ч����Կ����" );
        break;
    case 27:
        strcat( szMsg, "hsm��ƥ�����Կ����" );
        break;
    case 28:
        strcat( szMsg, "hsm��Ч����Կ����" );
        break;
    case 29:
        strcat( szMsg, "hsm��Կ��������ֹ" );
        break;
    case 30:
        strcat( szMsg, "hsm�ο�����Ч" );
        break;
    case 31:
        strcat( szMsg, "hsmû���㹻������������ṩ��������" );
        break;
    case 33:
        strcat( szMsg, "hsmLMK��Կת���洢�����ƻ�" );
        break;
    case 40:
        strcat( szMsg, "hsm��Ч�Ĺ̼�У���" );
        break;
    case 41:
        strcat( szMsg, "hsm�ڲ���Ӳ��/�����" );
        break;
    case 42:
        strcat( szMsg, "hsmDES����" );
        break;
    case 47:
        strcat( szMsg, "hsmDSP ���󣻱��������Ա" );
        break;
    case 49:
        strcat( szMsg, "hsm˽Կ���󣻱��������Ա" );
        break;
    case 60:
        strcat( szMsg, "hsm�޴�����" );
        break;
    case 74:
        strcat( szMsg, "hsm��ЧժҪ��Ϣ�﷨" );
        break;
    case 75:
        strcat( szMsg, "hsm��Ч��Կ/˽Կ��" );
        break;
    case 76:
        strcat( szMsg, "hsm��Կ���ȴ���" );
        break;
    case 77:
        strcat( szMsg, "hsm�������ݿ����" );
        break;
    case 78:
        strcat( szMsg, "hsm˽Կ���ȴ���" );
        break;
    case 79:
        strcat( szMsg, "hsm��ϣ�㷨�����ʶ����" );
        break;
    case 80:
        strcat( szMsg, "hsm���ݳ��ȴ���" );
        break;
    case 81:
        strcat( szMsg, "hsm��ϣ�㷨�����ʶ����" );
        break;
    case 90:
        strcat( szMsg, "hsmHSM ���յ�������Ϣ�е�������żУ���" );
        break;
    case 91:
        strcat( szMsg, "hsm��������У���" );
        break;
    case 92:
        strcat( szMsg, "hsm����ֵ������/�����򣩲�����Ч��Χ��" );
        break;
    default:
        sprintf( szTmpStr, "hsm error %ld", iErr );
        strcat( szMsg, szTmpStr );
        break;
    }
    if( iErr != 0 )
    {
        WriteLog( ERROR, szMsg );
        strcpy( szRetCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    strcpy( szRetCode, TRANS_SUCC );

    return SUCC;
}

/*****************************************************************
** ��    ��:ת��SJL06E���ܻ���һλ������Ϊƽ̨������ 
** �������:
           uszHsmErrCode    ���ܻ����ص�һλ������
** �������:
           szRetCode       �Ѿ��������λ������
** �� �� ֵ:
           �ɹ� - SUCC
           ʧ�� - FAIL
** ��    ��:Robin     
** ��    ��:2009/08/25 
** ����˵��:
** �޸���־:mod by wukj 20121031�淶�������Ű��޶�
**          
****************************************************************/
int DispSjl06eRacalErrorMsg( unsigned char *uszHsmErrCode, char *szRetCode )
{
    int iErr;
    char    szMsg[100], szTmpStr[100];

    uszHsmErrCode[2] = 0;

    iErr = atol( uszHsmErrCode );

    sprintf( szMsg, "���ܻ�����%02ld��", iErr );
    switch ( iErr )
    {

    case 0: 
        strcat( szMsg, "hsm����ɹ�" );
        break;
    case 1:
        strcat( szMsg, "hsm������Կ��żУ����󾯸�" );
        break;
    case 2:
        strcat( szMsg, "hsm��Կ���ȴ���" );
        break;
    case 4:
        strcat( szMsg, "hsm��Ч��Կ���ʹ���" );
        break;
    case 5:
        strcat( szMsg, "hsm��Ч��Կ���ȱ�ʶ" );
        break;
    case 10:
        strcat( szMsg, "hsmԴ��Կ��żУ���" );
        break;
    case 11:
        strcat( szMsg, "hsmĿ����Կ��żУ���" );
        break;
    case 12:
        strcat( szMsg, "hsm�û��洢�����������Ч" );
        break;
    case 13:
        strcat( szMsg, "hsm����Կ��żУ���" );
        break;
    case 14:
        strcat( szMsg, "hsmLMK�� 02-03 �����µ� PINʧЧ" );
        break;
    case 15:
        strcat( szMsg, "hsm��Ч����������" );
        break;
    case 16:
        strcat( szMsg, "hsm����̨���ӡ��û��׼���û���û�����Ӻ�" );
        break;
    case 17:
        strcat( szMsg, "hsmHSM ������Ȩ״̬�����߲������ PIN���" );
        break;
    case 18:
        strcat( szMsg, "hsmû��װ���ĵ���ʽ����" );
        break;
    case 19:
        strcat( szMsg, "hsmָ���� Diebold ����Ч" );
        break;
    case 20:
        strcat( szMsg, "hsmPIN��û�а�����Чֵ" );
        break;
    case 21:
        strcat( szMsg, "hsm��Ч������ֵ" );
        break;
    case 22:
        strcat( szMsg, "hsm��Ч���˺�" );
        break;
    case 23:
        strcat( szMsg, "hsm��Ч�� PIN���ʽ����" );
        break;
    case 24:
        strcat( szMsg, "hsmPIN����С�� 4 �����12" );
        break;
    case 25:
        strcat( szMsg, "hsmʮ���Ʊ����" );
        break;
    case 26:
        strcat( szMsg, "hsm��Ч����Կ����" );
        break;
    case 27:
        strcat( szMsg, "hsm��ƥ�����Կ����" );
        break;
    case 28:
        strcat( szMsg, "hsm��Ч����Կ����" );
        break;
    case 29:
        strcat( szMsg, "hsm��Կ��������ֹ" );
        break;
    case 30:
        strcat( szMsg, "hsm�ο�����Ч" );
        break;
    case 31:
        strcat( szMsg, "hsmû���㹻������������ṩ��������" );
        break;
    case 33:
        strcat( szMsg, "hsmLMK��Կת���洢�����ƻ�" );
        break;
    case 40:
        strcat( szMsg, "hsm��Ч�Ĺ̼�У���" );
        break;
    case 41:
        strcat( szMsg, "hsm�ڲ���Ӳ��/�����" );
        break;
    case 42:
        strcat( szMsg, "hsmDES����" );
        break;
    case 47:
        strcat( szMsg, "hsmDSP ���󣻱��������Ա" );
        break;
    case 49:
        strcat( szMsg, "hsm˽Կ���󣻱��������Ա" );
        break;
    case 60:
        strcat( szMsg, "hsm�޴�����" );
        break;
    case 74:
        strcat( szMsg, "hsm��ЧժҪ��Ϣ�﷨" );
        break;
    case 75:
        strcat( szMsg, "hsm��Ч��Կ/˽Կ��" );
        break;
    case 76:
        strcat( szMsg, "hsm��Կ���ȴ���" );
        break;
    case 77:
        strcat( szMsg, "hsm�������ݿ����" );
        break;
    case 78:
        strcat( szMsg, "hsm˽Կ���ȴ���" );
        break;
    case 79:
        strcat( szMsg, "hsm��ϣ�㷨�����ʶ����" );
        break;
    case 80:
        strcat( szMsg, "hsm���ݳ��ȴ���" );
        break;
    case 81:
        strcat( szMsg, "hsm��ϣ�㷨�����ʶ����" );
        break;
    case 90:
        strcat( szMsg, "hsmHSM ���յ�������Ϣ�е�������żУ���" );
        break;
    case 91:
        strcat( szMsg, "hsm��������У���" );
        break;
    case 92:
        strcat( szMsg, "hsm����ֵ������/�����򣩲�����Ч��Χ��" );
        break;
    default:
        sprintf( szTmpStr, "hsm error %ld", iErr );
        strcat( szMsg, szTmpStr );
        break;
    }
    if( iErr != 0 )
    {
        WriteLog( ERROR, szMsg );
        strcpy( szRetCode, ERR_SYSTEM_ERROR );
        return FAIL;
    }

    strcpy( szRetCode, TRANS_SUCC );

    return SUCC;
}
