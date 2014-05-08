#!/usr/bin/perl
use warnings;
use strict;

use lib '/home/hpriest/Scripts/Library';
use hdpTools;

my $dir =$ARGV[0];
my $odir=$ARGV[1];
die "usage: perl $0 <directory containing.fastq files> <output dir>\n\n" unless $#ARGV==1;

opendir(DIR,$dir) || die "cannot open directory $dir!\n$!\nexiting...\n";
my @files = grep {m/fastq$/} readdir(DIR);
unless(defined($files[0])){
	seekdir(DIR,0);
	@files=grep {m/fq$/} readdir (DIR);
}
close DIR;
my $command="/nfs4shares/bioinfosw/installs_current/cutadapt-1.1/bin/cutadapt -e 0.1 -n 5 -O 10 --match-read-wildcards -b  GATCGGAAGAGCTCGTATGCCGTCTTCTGCTTG -b ACACTCTTTCCCTACACGACGCTCTTCCGATCT -b AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT -b CAAGCAGAAGACGGCATACGAGCTCTTCCGATCT -b GATCGGAAGAGCACACGTCTGAACTCCAGTCAC -b ATCTCGTATGCCGTCTTCTGCTTG -b AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGA -b CAAGCAGAAGACGGCATACGAGAT -b GATCGGAAGAGCACACGTCTGAACTCCAGTCACCGATGTATCTCGTATGC -b AGATCGGAAGAGCACACGTCTGAACTCCAGTCACC";

foreach my $file (@files){
	my $path=$dir."/".$file;
	my $out=$file;
	if($out=~m/fastq/){
		$out=~s/fastq/cutadapt\.fastq/;
	}elsif($out=~m/fq$/){
		$out=~s/fq/cutadapt\.fastq/;
	}
	$out=$odir."/".$out;
	my $cmd=$command." $path -o $out";
	print $cmd."\n";
}
