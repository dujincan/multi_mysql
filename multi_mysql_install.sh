#!/bin/bash
########################################################
# Author: jason du
# Mail: jincan.du@outlook.com
# Created Time: Thu 03 Jan 2019 01:58:19 PM CST
# Last modified: Thu 03 Jan 2019 01:58:19 PM CST
########################################################
. /etc/init.d/functions

tools=/server/tools
apps=/application 
url=https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-5.6/mysql-5.6.42-linux-glibc2.12-x86_64.tar.gz
version=mysql-5.6.42-linux-glibc2.12-x86_64          
conf=/root/multi_mysql/my.cnf

# create folder                           
  
[ -d ${tools}    ] || mkdir -p ${tools}     
[ -d ${apps}   ] || mkdir -p ${apps}        
  
# create user                             
  
grep "mysql" /etc/passwd  &>/dev/null     
  
if [ $? -ne 0   ]                           
then      
    groupadd mysql                        
    useradd -r -g mysql -s /bin/false mysql          
fi
  
# init mysql                              
  
cd ${tools} && wget ${url} &>/dev/null    
echo 1
if [ $? -eq 0   ]                           
then      
    for n in {1..4}                       
    do    
        cd ${tools}                       
        tar xf ${version}.tar.gz              
        cp -r ${version} ${apps}/${version}_${n}     
        ln -s ${apps}/${version}_$n $apps/mysql${n}  
        chown -R mysql.mysql ${apps}/mysql${n}/data 
        cd ${apps}/mysql${n}
        scripts/mysql_install_db \
            --datadir=${apps}/mysql${n}/data \
            --basedir=${apps}/mysql${n} \
            --user=mysql &>/dev/null 
        if [ $? -eq 0   ]                   
        then 
            cp -f ${conf} ${apps}/mysql$n/data/
            sed -i "s#3306#330${n}#g" ${apps}/mysql${n}/data/my.cnf
            action "mysql$n install successful." /bin/true 
        else
            action "mysql$n install fail" /bin/false
            exit 1                        
        fi
    done  
else      
    action "Download mysql fail" /bin/false 
    exit $?
fi


