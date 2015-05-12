#!/usr/bin/perl
#
# This script parses a Cassandra log file and performs analysis along the way.
#
# Author Erick Ramirez, 2014 Oct 25
#

#---import modules
use Getopt::Long;

#---declare variables
my $input_f;	# log file to parse
my $debug;	# verbosity flag
my %entries;    # hash of log entries
my %threads;    # hash of threads
my %classes;    # hash of classes
my %levels;     # hash of log levels
my @unhandled;  # entries which did not get processed

#---get script arguments
GetOptions ("file=s" => \$input_f,
            "verbose" => \$debug)
or die ("ERROR - Unable to parse script arguments\n");

if ($debug) { print "DEBUG >>> Summarising log file [$input_f]\n"; }



#---FUNCTION: printLogLevels()
# Print count of log levels
sub printLogLevels() {
    if ($debug) { print "DEBUG >>> printLogLevels() --- printing count of log levels...\n"; }

    # iterate through hash of log levels
#    foreach $level (sort keys %levels) {
#        printf "  Level [$level] : %7s entries\n", $levels{$level};
    foreach $level (sort { $levels{$b}<=>$levels{$a} } keys %levels) {
        printf "  %7s --- $level \n", $levels{$level};
    }
} # end = sub printLogLevels()



#-----FUNCTION: printLogThreads()
# Print hash of threads
sub printLogThreads() {
    if ($debug) { print "DEBUG >>> printLogThreads() --- printing count of thread names...\n"; }

    # iterate through hash
    foreach $thread (sort { $threads{$b}<=>$threads{$a} } keys %threads) {
        printf "  %7s --- $thread \n", $threads{$thread};
    }
} # end = sub printLogThreads()


#-----FUNCTION: printLogClasses()
# Print hash of classes
sub printLogClasses() {
    if ($debug) { print "DEBUG >>> printLogClassses() --- printing count of classes...\n"; }

    # iterate through hash
    foreach $class (sort { $classes{$b}<=>$classes{$a} } keys %classes) {
        printf "  %7s --- $class \n", $classes{$class};
    }
} # end = sub printEntries()

#-----FUNCTION: printEntries()
# Print hash of summarised entries
sub printEntries() {
    if ($debug) { print "DEBUG >>> printEntries() --- printing count of summarised entries...\n"; }

    # iterate through hash of message entries
    foreach $entry (sort { $entries{$b}<=>$entries{$a} } keys %entries) {
        printf "  %7s --- $entry \n", $entries{$entry};
    }
} # end = sub printEntries()



# open the log for reading
open(IN,$input_f) or die("ERROR - Usage: summarise_log_cass.pl -f <system_log>\n");

#---declare variables
my @tokens;                                 # split line into tokens
my $log_level;                              # first token is the log level
my $has_hostname = "FALSE";

printf "\n===== Summarising log file [$input_f] =====\n\n";

# parse the log file
foreach $line (<IN>) {
    chomp($line);                           # remove newline

    # check if the entry has a hostname in it
    if ( $line =~ /[a-z]\/[0-9]*\./ ) { $has_hostname = "TRUE"; }

    # de-personalise numbers, UUIDs, etc
    $line =~ s/^\s+|\s+$//g;                # remove leading and trailing spaces
    $line =~ s/[a-f0-9]*-[a-f0-9]*-[a-f0-9]*-[a-f0-9]*-[a-f0-9]*/UUID/; # mask UUID
    $line =~ s/[0-9][0-9]*/#/g;             # replace numbers with a hash
    $line =~ s/-#/#/g;                      # replace "negative" hash

    @tokens = split(/ /, $line);         # split line into tokens
    $log_level = shift @tokens;          # first token is the log level

    # remove hostnames
    if ( $has_hostname = "TRUE" ) {
        my $idx = 0;
        foreach $token ( @tokens ) {
            # check if token is a hostname
            if ( $token =~ /[a-z].*\/#\./ ) {
                # remove everything before the slash
                $token =~ s/[a-z].*\//\//;

                # replace token at index
                $tokens[$idx] = $token;
            }
            $idx++;
        }
    }

    # skip tokens not in full caps
    if ( not $log_level =~ /^[A-Z][A-Z]+/ ) { next; }

    # increment count of log level
    if ( exists( $levels{$log_level} ) ) { $levels{$log_level}++; }
    else { $levels{$log_level} = 1; }

#    if ($debug) { print "DEBUG >>> Level [$log_level] = $levels{$log_level}\n" };

    # get thread name
    my $thread_name = shift @tokens;

    # keep getting next token until one ends in square bracket
    while ( not $thread_name =~ /\]$/ ) { $thread_name = $thread_name . " " . shift @tokens; }

    # summarise thread name by removing index
    $thread_name =~ s/:#//;

    # increment count of thread names
    if ( exists( $threads{$thread_name} ) ) { $threads{$thread_name}++; }
    else { $threads{$thread_name} = 1; }

    ### TEMPORARY
    # temporarily discard the date and time
    shift @tokens;
    shift @tokens;

    # get classfile and increment count
    my $classfile = shift @tokens;
    if ( exists( $classes{$classfile} ) ) { $classes{$classfile}++; }
    else { $classes{$classfile} = 1; }

    # discard classfile line number
    shift @tokens;
    shift @tokens;

    $line = join(' ', @tokens);
#    if ( $log_level =~ /AntiEntropySessions/ && $line =~ /new session: will sync/ ) {
    if ( $line =~ /new session: will sync/ ) {
        # new repair sessions, mask keyspace and CF names
        $line =~ s/ for .*$/ for KS\.\[CFs\]/;
    } elsif ( $line =~ /Enqueuing flush of Memtable/ ) {
        # memtable flushes, mask table names
        $line =~ s/Memtable-.*$/Memtable-<table>/;
    } elsif ( $line =~ /Received merkle tree for/ ) {
        # repair merkle tree
        $line =~ s/for .* from/for <table> from/;
    } elsif ( $line =~ /is fully synced/ ) {
        # repair merkle tree
        $line =~ s/] .* is/] <table> is/;
    } elsif ( $line =~ /Sending completed merkle tree to/ ) {
        # repair merkle tree
        $line =~ s/for .*$/for KS.CF/;
    } elsif ( $line =~ /Will not compact/ ) {
        # cannot compact non-active sstable
        $line =~ s/compact .*:/compact <sstable_file>:/;
    } elsif ( $line =~ /Compacted # sstables to/ ) {
        # sstables compaction
        $line =~ s/sstables to .*$/to [<sstable_files>]\.\.\./;
    } elsif ( $line =~ /Compacting \[SSTableReader/ ) {
        # sstables compaction
        $line =~ s/SSTableReader.*$/SSTableReader(path=<sstable_files>), \.\.\.]/;
    } elsif ( $line =~ /Completed flushing / ) {
        # memtable flushes, mask table names
        $line =~ s/ flushing \/.*\.db/ flushing <db_file>/;
    } elsif ( $line =~ /Writing Memtable-/ ) {
        # memtable flushes, mask table names
        $line =~ s/Memtable-.*@/Memtable-<table>@/;
    } elsif ( $line =~ / UUID\.\// ) {
        $line =~ s/UUID\.//;
#    } elsif ( $line =~ /CFS.Keyspace=/ ) {
#        $line =~ s/='[a-z0-9_#]*'/='\.\.\.'/ig;
    } elsif ( $line =~ /'/ ) {
        $line =~ s/'.*'/'\.\.\.'/g;
    } elsif ( $line =~ /Endpoints .* are consistent for/ ) {
        # repair Differencer.java
        $line =~ s/for .*$/for <table>/;
    } elsif ( $line =~ /requesting merkle trees for/ ) {
        # repair merkle tree
        $line =~ s/for .* \(to/for <table> \(to/;
    } elsif ( $line =~ /Update ColumnFamily '/ ) {
        # MigrationManager.java CF update
        $line =~ s/ColumnFamily .*$/ColumnFamily \.\.\./;
    } elsif ( $line =~ /Batch of prepared statements for/ ) {
        # batch sizes too large
        $line =~ s/\[.*\]/\[\.\.\.\]/;
    } elsif ( $line =~ /Stream context metadata/ ) {
        # mask DB files
        $line =~ s/\/.*\.db/<db_file>/g;
    } elsif ( $line =~ /Starting repair command/ ) {
        # mask keyspace name
        $line =~ s/for keyspace .*$/for keyspace <KS>/;
    } elsif ( $line =~ /out of sync for/ ) {
        # mask keyspace name
        $line =~ s/out of sync for .*$/out of sync for <KS>/;
    } elsif ( $thread_name =~ /ValidationExecutor/ && $line =~ /Opening \// ) {
        $line =~ s/Opening \/.*# /Opening <sstable_file> /;
    } elsif ( $classfile =~ /StatusLogger.java/ ) {
        $line = "...";
    } elsif ( $line =~ /\/.*\.db/ ) {
        # mask DB files
        $line =~ s/\/.*\.db/<db_file>/g;
    } elsif ( $classfile =~ /SecondaryIndexManager.java/ ) {
#printf ">>>> TRIGGERED - SecondaryIndexManager.java ... ";
        # mask index name(s)
        $line =~ s/of .* for/of [<indexes>] for/;
#printf " new line ----- $line\n";
    } elsif ( $line =~ /Index build of/ ) {
        # mask index name(s)
        $line =~ s/of .* complete/of [<indexes>] complete/;
    } elsif ( $line =~ /Updating shards state due to endpoint/ ) {
        # added for Solr nodes, 2014 Dec 22
        $line =~ s/changing state .*/changing state .../;
    }

    $line = "$log_level $thread_name $classfile $line";
#    printf "RESULT ---> $line\n";

    # save summarised line in a hash with a counter
    if ( exists( $entries{$line} ) ) {
        $entries{$line}++;
    } else {
        $entries{$line} = 1;
    }

    # reset hostname flag
    $has_hostname = "FALSE";

} # end = foreach $line
close(IN);

#---print log levels
printf "\n===== Count of message entries by log level =====\n";
printLogLevels();

#---print thread names
printf "\n===== Count of message entries by thread =====\n";
printLogThreads();

#---print classes
printf "\n===== Count of message entries by class =====\n";
printLogClasses();


#---print summarised entries
printf "\n===== Count of message entries =====\n";
printEntries();
