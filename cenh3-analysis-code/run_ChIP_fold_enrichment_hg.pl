#/usr/bin/perl

#use strict;
use warnings;
use Data::Dumper;

sub mean {
    my (@data) = @_;
    my $sum;
    foreach (@data) {
        $sum += $_;
    }
    return ( $sum / @data );
}


my @input;
my @IP;
my $inputReadCount = $ARGV[2] / 1000000;
my $IPReadCount = $ARGV[3] / 1000000;

open (INPUT, $ARGV[0]) || die "Unable to open input file: $!\n";
open (IP, $ARGV[1]) || die "Unable to open IP file: $!\n";

while (<INPUT>) {
	my @splitLine = split(/\t/, $_);
	chomp(@splitLine);
#	next if ($splitLine[0] !~ /A01/);
	my $temp="$splitLine[0]\t$splitLine[2]";
#	push(@input, $splitLine[2]);
	push(@input,$temp);
}

while (<IP>) {
	my @splitLine = split(/\t/, $_);
	chomp(@splitLine);
#	next if ($splitLine[0] !~ /A01/);
	my $temp="$splitLine[0]\t$splitLine[2]";
#	push(@IP, $splitLine[2]);
	push(@IP,$temp);
}
print "length input: " . scalar(@input) . "\tlength IP: " . scalar(@IP) . "\n";

open (OUT, ">cenpChip.IP_Input_Ratio.txt") || die "Unable to write output file: $!\n";
my $counter = 0;
my $position = 1;
my @tempRatio;
my $ratio;
for (my $i = 0; $i < @input; $i++) {
	#print "$i\n";
#	my $normalizedInput = $input[$i] / $inputReadCount;
#	my $normalizedIP = $IP[$i] / $IPReadCount;
	my @a=split/\t/,$input[$i];
	my @b=split/\t/,$IP[$i];
	my $normalizedInput = $a[1] / $inputReadCount;
	my $normalizedIP = $b[1] / $IPReadCount;
	if ($normalizedInput != 0) {
		$ratio = $normalizedIP / $normalizedInput;
		push(@tempRatio, $ratio);
	}
	$counter++;
	if ($counter == 10000 && @tempRatio > 0) {
		my $mean = mean(@tempRatio);
		@tempRatio = ();
		print OUT "$a[0]\t$position\t$mean\n";
		#print "$position\t$mean\n";
		$position = $counter + $position;
		$counter = 0;
	}
	elsif ($counter == 10000 && @tempRatio == 0) {
		$position = $counter + $position;
		$counter = 0;
	}
}
