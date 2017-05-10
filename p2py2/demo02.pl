#!/usr/bin/perl -w

# using code from echonl.1.pl, devowel.pl

foreach $i (1..$#ARGV) {
    print "$ARGV[$i]\n";
}

while ($line = <>) {
    chomp ($line);
    $line =~ s/[aeiou]/aaa/g;
    print "$line\n";
}