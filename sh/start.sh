#!/bin/sh

#��ȡ���ݿ��û�������
DBUSER=epay5
DBPWD=epay5
DBSERVICES=orcl

ORCL_CONN=$DBUSER/$DBPWD@$DBSERVICES

EPAY_USER=`whoami`

#�ж�ƽ̨�Ƿ��Ѿ�����
epayadm

if [ $? -eq 0 ]
then
    echo "ƽ̨�Ѿ����������ȹر�!"

    exit
fi

#����IPC
epayadm 0
if [ $? -ne 0 ]
then
    echo "����ƽ̨ʧ��!"

    exit
fi

#������ģ�����

#��ѯ��Ҫ����ģ��������ơ�����
TMP_FILE=.epay_module.tmp
sqlplus -S /nolog <<! 1>/dev/null
	conn $ORCL_CONN;
	set echo off feedback off heading off pagesize 0 linesize 1000 numwidth 12 termout off trimout on trimspool on;
	set colsep ' ';
	spool $TMP_FILE;
	SELECT module_name,para1,para2,para3,para4,para5,para6,msg_type FROM module WHERE run = 1 ORDER BY module_id;
	spool off;
	exit;
!

while read STR_CMD
do
    MODULE_NAME=`echo $STR_CMD | awk '{print $1}'` 

    echo "����"$MODULE_NAME"ģ��!"

    $STR_CMD

    if [ $? -ne 0 ]
    then
        echo "**********ģ��"$MODULE_NAME"����ʧ��!**********"
    else
        echo "ģ��"$MODULE_NAME"�����ɹ�!"
    fi

	sleep 1
done < $TMP_FILE

rm -f $TMP_FILE

echo "����ƽ̨�ɹ�!"
