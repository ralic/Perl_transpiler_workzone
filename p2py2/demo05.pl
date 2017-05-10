#!/usr/bin/perl -w

# using code from echo.2.pl, echonl.0.pl, five.pl

print join('|', @ARGV), "555" , "\n";

foreach $arg (@ARGV) {
    print "$arg\n";
	foreach $i (0..4) {
    		print "$i\n"
	}

}

