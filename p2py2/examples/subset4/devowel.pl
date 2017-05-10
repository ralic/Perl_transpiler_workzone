#!/usr/bin/perl -w

while ($line = <>) {
    chomp $line;
    $line =~ s/[aeiou]//g;
    print "$line\n";

	$line = $line. "3246";
	$line = $line + ".";
}
