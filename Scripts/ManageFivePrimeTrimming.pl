#!/usr/bin/perl
use warnings;
use strict;
use threads;
use Thread::Queue;

use lib '/home/hpriest/Scripts/Library';
use hdpTools;

my $inDir=$ARGV[0];
my $outDir=$ARGV[1];
my $length=$ARGV[2];
my $threads=$ARGV[3];

die "usage: perl $0 <input directory (must be *.fastq files)> <output directory> <length of 5\' trim> <threads>\n\n" unless $inDir && $outDir && $length && $threads;

my $q = Thread::Queue->new();
my $script="/home/hpriest/Scripts/SequenceQC/TrimFrontFastq.pl";

my @files=grep {m/fastq$/} @{hdpTools->LoadDir($inDir)};
foreach my $file (@files){
	my $Ipath=$inDir."/$file";
	my $Opath=$outDir."/$file";
	$Opath=~s/fastq/5pTrim\.fastq/;
	my $command="perl $script $Ipath $Opath $length";
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
