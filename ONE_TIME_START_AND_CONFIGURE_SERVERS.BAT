echo off
md csrs\csrs1\db csrs\csrs1\log csrs\csrs2\db csrs\csrs2\log csrs\csrs3\db csrs\csrs3\log
echo Created MongoDB folder structure for Config Server Instances


md sh01\sh011\db sh01\sh011\log sh01\sh012\db sh01\sh012\log sh01\sh013\db sh01\sh013\log
echo Created MongoDB folder structure for Shard 01 Server Instances

md sh02\sh021\db sh02\sh021\log sh02\sh022\db sh02\sh022\log sh02\sh023\db sh02\sh023\log
echo Created MongoDB folder structure for Shard 02 Server Instances
md router\log
echo DB path, log path creation comleted
echo on


echo starting Config replicaSet member's
	start mongod -f csrs1.conf
	start mongod -f csrs2.conf
	start mongod -f csrs3.conf

echo starting Shard 01 Replica Set member's.
	start mongod -f sh011.conf
	start mongod -f sh012.conf
	start mongod -f sh013.conf	

echo starting Shard 02 Replica Set member's.
	start mongod -f sh021.conf
	start mongod -f sh022.conf
	start mongod -f sh023.conf

echo wait time for server's to start. before we configure.
timeout 10

echo Configure Coniguration Replica Set.
echo use ip or use machineName, note localhost won't work
	mongosh --port 26001 --eval "rs.initiate()"	
		echo this will start showing it as primary.
		echo add 2 other config server to the replicaset.
	mongosh --port 26001 --eval "rs.add('HP830G5-EliteBook:26002')"
	mongosh --port 26001 --eval "rs.add('HP830G5-EliteBook:26003')"


echo Start mongos:	mongs.conf already pointing to the config replicaSet
echo Change the host name in mongos.conf
	start mongos -f mongos.conf

echo wait time for router to start.
timeout 10

echo Configure shard Replica Set.
	mongosh --port 27011 --eval "rs.initiate()"
	mongosh --port 27011 --eval "rs.add('HP830G5-EliteBook:27012')"
	mongosh --port 27011 --eval "rs.add('HP830G5-EliteBook:27013')"


echo Configure shard Replica Set.
	mongosh --port 27021 --eval "rs.initiate()"
	mongosh --port 27021 --eval "rs.add('HP830G5-EliteBook:27022')"
	mongosh --port 27021 --eval "rs.add('HP830G5-EliteBook:27023')"
 
		
echo Will Add Shard 01 and Shard 02 to the Cluster through router. Manually
	REM mongosh --port 26000 --eval "sh.addShard('sh01/HP830G5-EliteBook:27011')"	
	REM mongosh --port 26000 --eval "sh.addShard('sh02/HP830G5-EliteBook:27021')"
	REM mongosh --port 26000 --eval "sh.status()"

REM echo All done.. MongoDB Clustured env is UP and Running.
pause