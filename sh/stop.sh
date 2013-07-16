#!/bin/sh

#��ȡ���ݿ��û�������
DBUSER=epay5
DBPWD=epay5
DBSERVICES=orcl

ORCL_CONN=$DBUSER/$DBPWD@$DBSERVICES

EPAY_USER=`whoami`

MODULE_SHUTDOWN()
{
    MODULE_NAME=$1
    
    echo "�ر�"$MODULE_NAME"ģ��"

    ps -u $EPAY_USER -o user,pid,ppid,comm | awk '{if($4==proc_name) print "kill -10 "$2}' proc_name=$MODULE_NAME | sh
    
    echo "ģ��"$MODULE_NAME"�رճɹ�!"
}

#�رո�ģ�����

#��ѯ��Ҫ�ر�ģ���������
TMP_FILE=.epay_module.tmp
sqlplus -S /nolog <<! 1>/dev/null
	conn $ORCL_CONN;
	set echo off feedback off heading off pagesize 0 linesize 1000 numwidth 12 termout off trimout on trimspool on;
	set colsep ' ';
	spool $TMP_FILE;
	SELECT module_name,para1,para2,para3,para4,para5,para6 FROM module WHERE run = 1;
	spool off;
	exit;
!

while read STR_CMD
do
    MODULE_NAME=`echo $STR_CMD | awk '{print $1}'` 

    MODULE_SHUTDOWN $MODULE_NAME

	sleep 1
done < $TMP_FILE

rm -f $TMP_FILE

#�ر�IPC
epayadm 1

echo "�ر�ƽ̨�ɹ�!"