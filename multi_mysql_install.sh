#!/bin/bash
########################################################
# Author: jason du
# Mail: jincan.du@outlook.com
# Created Time: Thu 03 Jan 2019 01:58:19 PM CST
# Last modified: Thu 03 Jan 2019 01:58:19 PM CST
# Description: Deploy multiple mysql
########################################################
. /etc/init.d/functions

tools=/server/tools
apps=/application 
url=https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-5.6/mysql-5.6.42-linux-glibc2.12-x86_64.tar.gz
version=mysql-5.6.42-linux-glibc2.12-x86_64          
conf=/root/multi_mysql/multi_mysql/my.cnf
passwd=123456
mysqlhome=/application/mysql

# create folder                           
  
[ -d ${tools}    ] || mkdir -p ${tools}     
[ -d ${apps}   ] || mkdir -p ${apps}        
  
# create user                             
  

if (id mysql &>/dev/null)     
then
    echo "mysql already exists."
else
    groupadd mysql                        
    useradd -r -g mysql -s /bin/false mysql          
fi
  
# init mysql                              
  
wget -P ${tools}/ ${url} &>/dev/null    
if [ $? -eq 0   ]                           
then      
    tar xf ${tools}/${version}.tar.gz -C ${tools}/             
    for n in {1..4}                       
    do    
        cp -r ${tools}/${version} ${apps}/${version}_${n}     
        ln -s ${apps}/${version}_$n $apps/mysql${n}  
        chown -R mysql.mysql ${mysqlhome}${n}/data 
        cd ${mysqlhome}${n}
        scripts/mysql_install_db \
            --datadir=${mysqlhome}${n}/data \
            --basedir=${mysqlhome}${n} \
            --user=mysql &>/tmp/mysql${n}_init.log 
        if [ $? -eq 0   ]                   
        then 
            cp -f ${conf} ${mysqlhome}$n/data/
            sed -i "s#3306#330${n}#g" ${mysqlhome}${n}/data/my.cnf
            cd ${mysqlhome}${n}
            /bin/sh bin/mysqld_safe \
                --defaults-file=${mysqlhome}${n}/data/my.cnf \
                --basedir=${mysqlhome}${n} \
                --datadir=${mysqlhome}${n}/data \
                --pid-file=${mysqlhome}${n}/data/mysqld${n}.pid \
                --log-error=${mysqlhome}${n}/data/mysqld${n}.err \
                --socket=${mysqlhome}${n}/data/mysqld${n}.sock \
                --user=mysql &>/tmp/mysqld${n}_start.log &
            sleep 2
            if [ $? -eq 0 ]
            then
                ${mysqlhome}${n}/bin/mysqladmin -u root -S ${mysqlhome}${n}/data/mysqld${n}.sock password ""${passwd}"" &>/dev/null 
                if [ $? -eq 0 ]
                then
                    echo "mysql${n}:${passwd}" >>/tmp/passwd.log
                    action "mysql${n} startup successful, passwd in /tmp/passwd.log" /bin/true
                else
                    action "mysql${n} add passwd fail" /bin/false
                    exit $?
                fi
            else
                action "mysql${n} startup fail, please check /tmp/mysqld${n}_start.log" /bin/false 
                exit $?
            fi
        else
            action "mysql${n} init  fail, please check /tmp/mysql${n}_init.log" /bin/false
            exit $?                       
        fi
    done

else      
    action "Download mysql fail" /bin/false 
    exit $?
fi
