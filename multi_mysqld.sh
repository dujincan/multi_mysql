#!/bin/bash
########################################################
# Author: jason du
# Mail: jincan.du@outlook.com
# Created Time: Thu 03 Jan 2019 03:37:46 PM CST
# Last modified: Thu 03 Jan 2019 03:37:46 PM CST
########################################################
. /etc/init.d/functions

dir=/application/mysql   


function start() {
    for n in {1..4}
    do  
        if [ -d $dir$n ]
        then
            cd $dir$n
            bin/mysqld_safe \
                --defaults-file=$dir$n/data/my.cnf \
                --basedir=$dir$n --datadir=$dir$n/data  \
                --pid-file=$dir$n/data/mysqld$n.pid \
                --log-error=$dir$n/data/mysqld$n.err \
                --socket=$dir$n/data/mysqld$n.sock \
                --user=mysql &>/dev/null  &
            if [ $? -eq 0 ]
            then
                sleep 2
                action "mysql$n startup" /bin/true 
            else
                sleep 2
                action "mysql$n startup fail" /bin/false
                exit 1
            fi
        else
            action "mysql$n not install" /bin/false 
        fi
    done
}


function stop() {
    for n in {1..4}
    do 
        if [ -s $dir$n/data/mysqld$n.pid ]
        then
            if (kill -0 `cat $dir$n/data/mysqld$n.pid`)
            then
                kill `cat $dir$n/data/mysqld$n.pid`
                if [ $? -eq 0 ]
                then
                    sleep 2
                    action "mysql$n stop" /bin/true
                else
                    sleep 2
                    action "mysql$n stop fail" /bin/false
                    exit 1
                fi
            else
                sleep 2
                action "mysql$n not running" /bin/false 
            fi
        fi
    done
}


case $1 in
    start)
        start
        retval=$?
        ;;
    stop)
        stop
        retval=$?
        ;;
    restart)
        stop
        sleep 2
        start
        retval=$?
        ;;
    *)
        echo "Usage:$0 {start|stop|restart}"
esac
exit $retval
