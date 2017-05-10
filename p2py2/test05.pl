#!/usr/bin/perl -w

# tests if loops, logical, comparison operators 

$a = c;
$b = d;

if ($a eq 'c') {
	$g = 1;
	if ($b ne 'e') {
		$h = 1;
		if ($g && $h) {
			print "true\n";
		}
	}
}