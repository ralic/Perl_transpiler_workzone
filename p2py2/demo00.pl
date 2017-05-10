#!/usr/bin/perl -w

# from size.pl

$a = 5;

if ($a < 0) {
    print "negative\n";
} elsif ($a == 0) {
    print "zero\n";
} elsif ($a < 10) {
    print "small\n";
} else {
    print "large\n";
}

