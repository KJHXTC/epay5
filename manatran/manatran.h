/*
$Revision: 1.9 $
$Log: manatran.h,v $
Revision 1.9  2013/06/14 06:24:14  fengw

1���޸�web���׼�ض˿ڱ�������Ϊ�ַ�����

Revision 1.8  2013/02/21 06:27:46  fengw

1�����Ӿ�̬�˵���غ궨�塣

Revision 1.7  2012/12/27 06:39:14  fengw

1������EpayShm.hͷ�ļ����á�

Revision 1.6  2012/12/18 02:21:06  wukj
*** empty log message ***

Revision 1.5  2012/12/03 03:25:08  wukj
int����ǰ׺�޸�Ϊi

Revision 1.4  2012/11/29 10:09:03  wukj
��־,bcdascת�����޸�

Revision 1.3  2012/11/21 03:28:44  wukj
��ȫ�ֱ�������manatran.h

Revision 1.2  2012/11/16 03:25:05  wukj
����CVS REVSION LOGע��

 *
 *
 */
# include <stdio.h>
# include <stdlib.h>
# include <signal.h>
# include <sys/types.h>
# include <memory.h>
# include <errno.h>
# include "../incl/transtype.h"
//# include "tools.h"
# include "../incl/app.h"
# include "../incl/user.h"
# include "../incl/errcode.h"
# include "../incl/dbtool.h"
# include "../incl/DbStru.h"
#include "EpayShm.h"

#define MAX_STATIC_MENU_COUNT       20              /* ��̬�˵������� */


#define  WORKDIR  "WORKDIR"
#define  FILENAME1 "/log/h_void.log"

#ifdef _MAIN_
char    gszWebIp[25], gszWebPort[5+1], gszRemoteIP[17], gszOwnBankId[12];
int     gnSpec, gnPrintNum, gnDownloadNew, gnTeleLen, gnQueVoidTrace, gnTransPort, gnRecTimeOut;

#endif
