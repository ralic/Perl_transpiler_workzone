#!/usr/bin/perl -w


$x = 'C';
$y = 'F';


$line =~ s/[A-Za-z]*[ ]?/426/g;

if ($line eq '5') {

	while ($x ne 'D') {
		if ($y gt 'A') {
			last;
		} else {
			next;
		}
	}

}