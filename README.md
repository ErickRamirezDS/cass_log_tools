# Description
Simple scripts for working with Apache Cassandra logs.

# Overview

These are scripts I created to make it simpler to read/summarise/parse the `system.log`.

They were intended to be overly simple for readability and for portability, i.e. they can just run on any machine that can run Bourne shell or Perl without having to download additional modules or plugins.

# Scripts

### `compaction_rate.sh`

Extracts the compaction throughput from a Cassandra `system.log`.

Use this script to get a feel for the compaction in MB/s.

Usage: `compaction_rate.sh <system_log> [min_size_bytes]`

