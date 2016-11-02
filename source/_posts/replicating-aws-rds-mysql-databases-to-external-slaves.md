---
title:  Replicating AWS RDS MySQL databases to external slaves
date: 2013-07-07
---
**Update:** Using [**an external slave with an RDS master** is now possible as well as **RDS as a slave
with an external master**](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MySQL.Procedural.Importing.html "http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MySQL.Procedural.Importing.html")  

Connecting external MySQL slaves to AWS RDS mysql instances is one of the most wanted features, for example to have migration strategies into and out of RDS or to support strange replication
chains for legacy apps. Listening to binlog updates is also a [**great way to update search indexes or to
invalidate caches**](https://github.com/noplay/python-mysql-replication).  
  
As of now it is possible to access binary logs from outside RDS with [**the release of MySQL
5.6 in RDS**](http://aws.typepad.com/aws/2013/07/mysql-56-support-for-amazon-rds.html). What amazon does not mention is the possibility to connect external slaves to RDS.  
  
Here is the proof of concept (details on how to set up a master/slave setup is not the focus here :-) )  
  
First, we create a new database in RDS somehow like this:

    
    soenke♥kellerautomat:~$ rds-create-db-instance soenketest --backup-retention-period 1 --db-name testing --db-security-groups soenketesting --db-instance-class db.m1.small --engine mysql --engine-version 5.6.12 --master-user-password testing123 --master-username root --allocated-storage 5 --region us-east-1 
    DBINSTANCE  soenketest  db.m1.small  mysql  5  root  creating  1  ****  n  5.6.12  general-public-license
          SECGROUP  soenketesting  active
          PARAMGRP  default.mysql5.6  in-sync
          OPTIONGROUP  default:mysql-5-6  in-sync  
    

So first lets check if binlogs are enabled on the newly created RDS database:

    
    master-mysql> show variables like 'log_bin';
    +---------------+-------+
    | Variable_name | Value |
    +---------------+-------+
    | log_bin       | ON    |
    +---------------+-------+
    1 row in set (0.12 sec)
    
    master-mysql> show master status;
    +----------------------------+----------+--------------+------------------+-------------------+
    | File                       | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
    +----------------------------+----------+--------------+------------------+-------------------+
    | mysql-bin-changelog.000060 |      120 |              |                  |                   |
    +----------------------------+----------+--------------+------------------+-------------------+
    1 row in set (0.12 sec)
    

Great! Lets have another check with the mysqlbinlog tool as stated in the [RDS
docs.](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.Concepts.MySQL.html)

But first we have to create a user on the RDS instance which will be used by the connecting slave.

    
    master-mysql> CREATE USER 'repl'@'%' IDENTIFIED BY 'slavepass';
    Query OK, 0 rows affected (0.13 sec)
    
    master-mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
    Query OK, 0 rows affected (0.12 sec)
    

Now lets have a look at the binlog:

    
    soenke♥kellerautomat:~$ mysqlbinlog -h soenketest.something.us-east-1.rds.amazonaws.com -u repl -pslavepass --read-from-remote-server -t mysql-bin-changelog.000060
    ...
    SET @@session.character_set_client=33,@@session.collation_connection=33,@@session.collation_server=8/*!*/;
    CREATE USER 'repl'@'%' IDENTIFIED BY PASSWORD '*809534247D21AC735802078139D8A854F45C31F3'
    /*!*/;
    # at 582
    #130706 20:12:02 server id 933302652  end_log_pos 705 CRC32 0xc2729566  Query   thread_id=66    exec_time=0     error_code=0
    SET TIMESTAMP=1373134322/*!*/;
    GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%'
    /*!*/;
    DELIMITER ;
    # End of log file
    ROLLBACK /* added by mysqlbinlog */;
    /*!50003 SET COMPLETION_TYPE=@OLD_COMPLETION_TYPE*/;
    /*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=0*/;
    

As we can see, even the grants have been written to the RDS binlog. Great! Now lets try to connect a real slave! Just set up a vanilla mysql server somewhere (local, vagrant, whatever) and assign
a server-id to the slave. RDS uses some (apparently) random server-ids like 1517654908 or 933302652 so I currently don't know how to be sure there are no conflicts with external slaves. Might be
one of the reasons AWS doesn't publish the fact that slave connects actually got possible.  
  
After setting the server-id and optionally a database to replicate:

    
    server-id       =  12345678
    replicate-do-db=soenketesting
    

lets restart the slave DB and try to connect it to the master:

    
    slave-mysql> change master to master_host='soenketest.something.us-east-1.rds.amazonaws.com', master_password='slavepass', master_user='repl', master_log_file='mysql-bin-changelog.000067', master_log_pos=0;
    Query OK, 0 rows affected, 2 warnings (0.07 sec)
    
    slave-mysql> start slave;
    Query OK, 0 rows affected (0.01 sec)
    

And BAM, it's replicating:

    
    slave-mysql> show slave status\G
    *************************** 1. row ***************************
                   Slave_IO_State: Waiting for master to send event
                      Master_Host: soenketest.something.us-east-1.rds.amazonaws.com
                      Master_User: repl
                      Master_Port: 3306
                    Connect_Retry: 60
                  Master_Log_File: mysql-bin-changelog.000068
              Read_Master_Log_Pos: 422
                   Relay_Log_File: mysqld-relay-bin.000004
                    Relay_Log_Pos: 595
            Relay_Master_Log_File: mysql-bin-changelog.000068
                 Slave_IO_Running: Yes
                Slave_SQL_Running: Yes
                  Replicate_Do_DB: soenketesting
              Replicate_Ignore_DB: 
               Replicate_Do_Table: 
           Replicate_Ignore_Table: 
          Replicate_Wild_Do_Table: 
      Replicate_Wild_Ignore_Table: 
                       Last_Errno: 0
                       Last_Error: 
                     Skip_Counter: 0
              Exec_Master_Log_Pos: 422
                  Relay_Log_Space: 826
                  Until_Condition: None
                   Until_Log_File: 
                    Until_Log_Pos: 0
               Master_SSL_Allowed: No
               Master_SSL_CA_File: 
               Master_SSL_CA_Path: 
                  Master_SSL_Cert: 
                Master_SSL_Cipher: 
                   Master_SSL_Key: 
            Seconds_Behind_Master: 0
    Master_SSL_Verify_Server_Cert: No
                    Last_IO_Errno: 0
                    Last_IO_Error: 
                   Last_SQL_Errno: 0
                   Last_SQL_Error: 
      Replicate_Ignore_Server_Ids: 
                 Master_Server_Id: 933302652
                      Master_UUID: ec0eef96-a6e9-11e2-bdf0-0015174ecc8e
                 Master_Info_File: /var/lib/mysql/master.info
                        SQL_Delay: 0
              SQL_Remaining_Delay: NULL
          Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
               Master_Retry_Count: 86400
                      Master_Bind: 
          Last_IO_Error_Timestamp: 
         Last_SQL_Error_Timestamp: 
                   Master_SSL_Crl: 
               Master_SSL_Crlpath: 
               Retrieved_Gtid_Set: 
                Executed_Gtid_Set: 
                    Auto_Position: 0
    1 row in set (0.00 sec)
    

So lets issue some statements on the master:

    
    master-mysql> create database soenketesting;
    Query OK, 1 row affected (0.12 sec)
    master-mysql> use soenketesting
    Database changed
    master-mysql> create table example (id int, data varchar(100));
    Query OK, 0 rows affected (0.19 sec)
    

And it's getting replicated:

    
    slave-mysql> use soenketesting;
    Database changed
    slave-mysql> show create table example\G
    *************************** 1. row ***************************
           Table: example
    Create Table: CREATE TABLE `example` (
      `id` int(11) DEFAULT NULL,
      `data` varchar(100) DEFAULT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=latin1
    1 row in set (0.00 sec)
    

[Kommentar schreiben](#)

Kommentare: _23_ 

* **\#1**

**rb** (_Montag, 08 Juli 2013 04:26_)

Does this mean it is possible to perform MySQL master-master replication with RDS and an external DB(s)?
* **\#2**

[s0enke](http://www.ruempler.eu/) (_Dienstag, 09 Juli 2013 03:05_)

@rb: Probably not - as still you cannot replicate INTO RDS. But there is a possible workaround with tungsten: https://docs.continuent.com/wiki/display/TEDOC/Replicating+from+MySQL+to+Amazon+RDS
* **\#3**

**Ludo** (_Donnerstag, 29 August 2013 22:56_)

nice!
* **\#4**

[Ross](http://www.avantalytics.com) (_Sonntag, 01 September 2013 16:00_)

It would be nice to see the process for creating a slave from an existing rds master as there is no way to force a global write lock on the tables and you'd need to deal with dumps etc.
* **\#5**

**Ludo.helder@gmail.com** (_Montag, 16 September 2013 17:43_)

Question:  
why do you set log\_position=0 on the slave when it's 120 on the master?
* **\#6**

**Anonymous Coward** (_Montag, 23 September 2013 04:03_)

Man. Your background is pretty, but offensive when trying to read your page.
* **\#7**

**victoroloan** (_Mittwoch, 02 Oktober 2013 11:35_)

Hi There,  
  
master-mysql\> GRANT REPLICATION SLAVE ON \*.\* TO 'repl'@'%'  
does not work on me.  
  
ERROR 1045 (28000): Access denied for user 'repl'@'%' (using password: YES)
* **\#8**

**Neal** (_Mittwoch, 02 Oktober 2013 17:43_)

You can now replicate TO and FROM RDS instances with outside MySQL instances:  
  
To import into RDS:  
http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MySQL.Procedural.Importing.NonRDSRepl.html  
  
To export from RDS:  
http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MySQL.Procedural.Exporting.NonRDSRepl.html
* **\#9**

**Vene** (_Mittwoch, 16 Oktober 2013 04:50_)

I am trying to get replication from my Datacenter, via VPN into a Mysql RDS into a VPC, however I am not able to get the RDS instance connected to my master mysql in Datacenter. Security Group is
even allow any connection from this RDS mysql instance to any network, but even in that way, I am not able to make to work. Any advise? Tks
* **\#10**

**Yip** (_Freitag, 25 Oktober 2013 11:24_)

mysql\> GRANT REPLICATION SLAVE ON \*.\* TO 'repl'@'%';  
ERROR 1045 (28000): Access denied for user 'xxxx'@'%' (using password: YES)  
* **\#11**

**Yip** (_Freitag, 25 Oktober 2013 11:44_)

Answer is here, http://understeer.hatenablog.com/entry/2013/07/07/195506  
You can understand from the quoting box, even you don't understand the Japanese.
* **\#12**

**UQPPA** (_Freitag, 22 November 2013 13:23_)

Great and useful entry, thank you!
* **\#13**

**Dimitry** (_Montag, 20 Januar 2014 17:55_)

I tried executing mysqlbinlog from my Raspberry Pi (with mysql 5.5 installed) and I got this error message.  
  
ERROR: Got error reading packet from server: Slave can not handle replication events with the checksum that master is configured to log; the first event 'mysql-bin-changelog.017013' at 4, the last
event read from '/rdsdbdata/log/binlog/mysql-bin-changelog.017013' at 120, the last byte read from '/rdsdbdata/log/binlog/mysql-bin-changelog.017013' at 120\.  
\#700101 0:00:00 server id 96352888 end\_log\_pos 0 Rotate to mysql-bin-changelog.017013 pos: 4  
  
Is it because 5.5 cannot read binlogs of 5.6? Or I just have to change some settings?
* **\#14**

**Dimitry** (_Dienstag, 21 Januar 2014 20:58_)

UPDATE TO PREVIOUS POST:  
I have managed to compile on Raspberry Pi 5.6.15 and it fixes the problem I have described in the previous post.
* **\#15**

**Dimitry** (_Mittwoch, 22 Januar 2014 12:54_)

As to setting server-id, it seems from RDS docs http://dev.mysql.com/doc/refman/5.6/en/replication-howto-slavebaseconfig.html that you can set any id, the only requirement is that it is unique
amongst your slave replication servers.
* **\#16**

**Yip** (_Montag, 03 Februar 2014 09:07_)

Replication frequently broken, due to the huge update and binlog rotated in RDS master.  
  
Last\_IO\_Error: Got fatal error 1236 from master when reading data from binary log: 'Could not find first log file name in binary log index file'  
  
It is no way to modify the max\_binlog\_size.  
rds-modify-db-parameter-group: Malformed input-The parameter max\_binlog\_size cannot be modified.  
  
Any solution ?
* **\#17**

**kiran** (_Donnerstag, 13 März 2014 09:03_)

How to setup replication from existing database to RDS . I am trying to migrate from existing db to RDS . change master to master is not working on RDS. Could you please suggest me .  
  
Thanks in advance
* **\#18**

[Wing Huang](http://www.cloudmd5.com) (_Donnerstag, 27 März 2014 04:45_)

why it is mysql-bin-changelog.000067?
* **\#19**

**Matrix** (_Dienstag, 10 Februar 2015 18:19_)

Can u please write the down the steps for External Mysql Server as "Master" and RDS as "Slave"  
it will be very helpful
* **\#20**

[Dobryak](http://dobryak.org) (_Montag, 16 März 2015 16:27_)

Thanks for the guide.  
It really helped me, but i found one problem: by default, on RDS expire\_logs\_days set to 0, thus bin log expires extremely fast.  
You shall change it manually, by using stored procedure: "call mysql.rds\_set\_configuration('binlog retention hours', 24);"  
Hope this will save someone some time
* **\#21**

**Kapil Singla** (_Donnerstag, 15 Oktober 2015 16:18_)

This write-up is pretty awesome. Worked like charm!  
  
Thanks
* **\#22**

**Sartori** (_Freitag, 24 Juni 2016 22:49_)

Works fine!!! tks!
* **\#23**

**Golden John** (_Mittwoch, 24 August 2016 09:01_)

I'm getting this error when i executed this .  
  
\[root@staging ~\]\# mysqlbinlog -h stauymstest2.chxjaqowxuje.ap-south-1.rds.amazo naws.com -u repl\_aws -pxyz123 --read-from-remote-server -t mysql-bin-changelog.0 00022  
/\*!50530 SET @@SESSION.PSEUDO\_SLAVE\_MODE=1\*/;  
/\*!40019 SET @@session.max\_insert\_delayed\_threads=0\*/;  
/\*!50003 SET @OLD\_COMPLETION\_TYPE=@@COMPLETION\_TYPE,COMPLETION\_TYPE=0\*/;  
DELIMITER /\*!\*/;  
\# at 4  
\#700101 5:30:00 server id 406438850 end\_log\_pos 0 Rotate to mysql-bin-chan gelog.000022 pos: 4  
ERROR: Got error reading packet from server: Slave can not handle replication ev ents with the checksum that master is configured to log; the first event 'mysql- bin-changelog.000022' at 4, the last
event read from '/rdsdbdata/log/binlog/mysq l-bin-changelog.000022' at 120, the last byte read from '/rdsdbdata/log/binlog/m ysql-bin-changelog.000022' at 120\.  
DELIMITER ;  
\# End of log file  
ROLLBACK /\* added by mysqlbinlog \*/;  
/\*!50003 SET COMPLETION\_TYPE=@OLD\_COMPLETION\_TYPE\*/;  
/\*!50530 SET @@SESSION.PSEUDO\_SLAVE\_MODE=0\*/;  
* 
1 Gilt für Lieferungen in folgendes Land: Deutschland. Lieferzeiten für andere Länder und Informationen zur Berechnung des Liefertermins siehe hier: [Liefer- und Zahlungsbedingungen](http://www.ruempler.eu/j/shop/deliveryinfo)  

[Impressum](/about/) | [Datenschutz](/j/privacy) 

[Abmelden ](https://e.jimdo.com/app/cms/logout.php)
|
[Bearbeiten](https://a.jimdo.com/app/auth/signin/jumpcms/?page=1708161293)