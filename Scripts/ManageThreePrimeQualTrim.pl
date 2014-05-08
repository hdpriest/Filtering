#!/usr/bin/perl
use warnings;
use strict;
use threads;
use Thread::Queue;

use lib '/home/hpriest/Scripts/Library';
use hdpTools;

my $inDir=$ARGV[0];
my $outDir=$ARGV[1];
my $threads=$ARGV[2];

die "usage: perl $0 <input directory (must be *.fastq files)> <output directory> <threads>\n\n" unless $inDir && $outDir && $threads;

my $q = Thread::Queue->new();
my $script="/home/dbryant/bin/fastx_toolkit-0.0.13.2/bin/fastq_quality_trimmer";
my $opts="-t 30 -Q 33";

my @files=grep {m/fastq$/} @{hdpTools->LoadDir($inDir)};
unless(defined($files[0])){
	@files=grep {m/fq$/} @{hdpTools->LoadDir($inDir)};
}

foreach my $file (@files){
	my $Ipath=$inDir."/$file";
	my $Opath=$outDir."/$file";
	$Opath=~s/fastq/3pQtrim\.fastq/;
	$Opath=~s/fq/3pQtrim\.fastq/;
	my $command="$script $opts -i $Ipath -o $Opath";
	$q->enqueue($command);
}
for(my $i=0;$i<=$threads;$i++){
	my $thr=threads->create(\&workerThread);
}
while(threads->list()>0){
	my @thr=threads->list();
	$thr[0]->join();
}

sub workerThread {
	while(my $command=$q->dequeue_nb()){
		warn "$command dequeue'd\n";
		`$command`;
	}
	return 1;
}
