#!/usr/bin/env perl

my %names = ('Entomophthoromycotina' => 'Zoopagomycota',
	      'Chytridiomycota' => 'Chytridiomycota',
	      'Blastocladiomycota' => 'Blastocladiomycota',
	      'Kickxellomycotina' => 'Zoopagomycota',
		'Mortirellomycotina' => 'Mucoromycota',
		'Mucoromycotina'       => 'Mucoromycota');
use strict;
my (%seen,%skip);
if ( -f "ignore_samples.txt" ) {
    open(my $in => "ignore_samples.txt") || die $!;
    while(<$in>) {
	    next if /^\#/;
	chomp;
	my ($name,$note) = split(/,/,$_);
	$skip{$name}++;
    }
}
opendir(DAT,"data") || die $!;
for my $file (readdir(DAT)) {
	next unless $file =~ /^1978\S+\.csv$/ || $file =~ /^(UFL|UCR)\.csv$/;
	open(my $in => "data/$file") || die $!;
	warn("opening $file");
	my $header = <$in>;
	while( <$in>) { 
		next if /^\s+$/;
		# ideally all skipping is done based on these notes
		# but provide some more context to it
		next if /Contamination|Contaminant|Too low/i;
		chomp;
		my @row = split(/,/,$_);
		my $sp = $row[5];
		$sp =~ s/\s+/_/g;
		next if $skip{$sp};
		next if $seen{$sp}++;
		print join("\t",$sp,$names{$row[4]} || die("cannot find group for $row[4] ($file)"),$row[4]),"\n";
	}
}

