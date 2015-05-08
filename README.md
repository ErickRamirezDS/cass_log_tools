## Description
Simple scripts for working with Apache Cassandra logs.

## Overview

These are scripts I created to make it simpler to read/summarise/parse the `system.log`.

They were intended to be overly simple for readability and for portability, i.e. they can just run on any machine that can run Bourne shell or Perl without having to download additional modules or plugins.

## Scripts

#### `compaction_rate.sh`

Extracts the compaction throughput from a Cassandra `system.log`.

Use this script to get a feel for the compaction in MB/s.

Usage: `compaction_rate.sh <system_log> [min_data_size_bytes]`

Sample output:

```
$ compaction_rate.sh system.log 20000000
  Throughput: 16.228230MB/s. | Data size: 38798031 (37 MB) | SSTables count: 2
  Throughput: 15.939397MB/s. | Data size: 41834507 (39 MB) | SSTables count: 2
  Throughput: 15.885001MB/s. | Data size: 45639407 (43 MB) | SSTables count: 2
```

#### `count_entries_per_hour.sh`

Counts the occurrences of a string for each hour in the Cassandra `system.log`.

Use this script to work out whether load has increased during a particular period.

Useful query strings:
- "ParNew" - shows distribution of GC pauses
- "Compacted" - shows distribution of compaction activity
- "flush of Memtable" - shows flushing activity, indicates traffic
- "ConcurrentMarkSweep" - indicates GC pressure
- "Started hinted handoff" - indicates existence of unresponsive nodes

Sample output:

```
$ count_entries_per_hour.sh ParNew system.log
2015-04-28 12:00 - 8
2015-04-28 16:00 - 108
2015-04-28 20:00 - 202
```

#### `display_large_rows.sh`

Displays entries in Cassandra logs relating to compaction of large rows.

Useful for showing rows larger than a given size, e.g. 100MB.

Usage: `display_large_rows.sh <system_log> [min_row_size_bytes]`

Sample output:

```
$ display_large_rows.sh system.log 1000000000
INFO [CompactionExecutor:73] 2015-01-14 19:11:45,959 CompactionController.java (line 192) Compacting large row myKS/myCF:8e6fb0b72937 (1407625692 bytes) incrementally | 1342 MB
INFO [CompactionExecutor:73] 2015-01-14 19:13:09,901 CompactionController.java (line 192) Compacting large row myKS/myCF:2eec906de37b (1410187132 bytes) incrementally | 1344 MB
INFO [CompactionExecutor:73] 2015-01-14 19:14:34,765 CompactionController.java (line 192) Compacting large row myKS/myCF:ce49043461ce (2871138316 bytes) incrementally | 2738 MB
```

#### `initial_log_assess.sh`

A script I use to do a quick assessment of a Cassandra node. It highlights restarts, GC activity, dropped mutations, large rows, errors, etc.

Usage: `initial_log_assess.sh system.log`

#### `rename_node_dirs.sh`

The directory names for nodes in the OpsCenter Diagnostic tarball are quite long so I wrote this script to simplify them to just the IP address of the nodes.

Usage: `cd <diagnostic_dir>/nodes && rename_node_dirs.sh`

Sample output:

```
$ rename_node_dirs.sh 
Renaming [opsc-2015-04-29-11-54-21-UTC-172.31.3.100] to [172.31.3.100]... OK
Renaming [opsc-2015-04-29-11-54-21-UTC-172.31.36.54] to [172.31.36.54]... OK
Renaming [opsc-2015-04-29-11-54-21-UTC-172.31.43.125] to [172.31.43.125]... OK
```

#### `summarise_log_cass.pl`

Summarises a Cassandra log file into line counts by message type, thread names, classes and de-personalised messages.

Usage: `summarise_log_cass.pl -f system.log`

Sample output:

```
===== Summarising log file [system_678571075.log] =====

===== Count of message entries by log level =====
    15708 --- INFO 
      311 --- WARN 

===== Count of message entries by thread =====
     9871 --- [ScheduledTasks] 
     1512 --- [FlushWriter] 
     1263 --- [MemoryMeter] 
     1068 --- [RequestResponseStage] 
      814 --- [CompactionExecutor] 
      305 --- [HANDSHAKE#.#.#.#/#.#.#.#] 
      279 --- [WRITE-/#.#.#.#] 
      228 --- [main] 
      219 --- [HintedHandoff] 
...

===== Count of message entries by class =====
     9239 --- StatusLogger.java 
     2775 --- Memtable.java 
     1233 --- Gossiper.java 
      808 --- ColumnFamilyStore.java 
      593 --- CompactionTask.java 
      305 --- OutboundTcpConnection.java 
      280 --- SSLFactory.java 
      202 --- HintedHandOffManager.java 
      118 --- GCInspector.java 
...

===== Count of message entries =====
     9239 --- INFO [ScheduledTasks] StatusLogger.java ... 
     1234 --- INFO [MemoryMeter] Memtable.java CFS(Keyspace='...') liveRatio is #.# (just-counted was #.#).  calculation took #ms for # cells 
     1067 --- INFO [RequestResponseStage] Gossiper.java InetAddress /#.#.#.# is now UP 
      756 --- INFO [FlushWriter] Memtable.java Writing Memtable-<table>@#(#/# serialized/live bytes, # ops) 
      743 --- INFO [FlushWriter] Memtable.java Completed flushing <db_file> (# bytes) for commitlog position ReplayPosition(segmentId=#, position=#) 
      500 --- INFO [ScheduledTasks] ColumnFamilyStore.java Enqueuing flush of Memtable-<table> 
      298 --- INFO [CompactionExecutor] CompactionTask.java Compacting [SSTableReader(path=<sstable_files>), ...] 
      295 --- INFO [CompactionExecutor] CompactionTask.java Compacted # to [<sstable_files>]... 
      279 --- INFO [HANDSHAKE#.#.#.#/#.#.#.#] OutboundTcpConnection.java Handshaking version with #.#.#.#/#.#.#.# 
      279 --- WARN [WRITE-/#.#.#.#] SSLFactory.java Filtering out TLS_RSA_WITH_AES_#_CBC_SHA,TLS_DHE_RSA_WITH_AES_#_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_#_CBC_SHA as it isnt supported by the socket 
      155 --- INFO [GossipTasks] Gossiper.java InetAddress /#.#.#.# is now DOWN 
      106 --- INFO [ScheduledTasks] GCInspector.java GC for ConcurrentMarkSweep: # ms for # collections, # used; max is # 
      100 --- INFO [HintedHandoff] HintedHandOffManager.java Started hinted handoff for host: UUID with IP: /#.#.#.#
...
```
