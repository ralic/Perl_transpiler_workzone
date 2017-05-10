#!/usr/bin/perl -w

# from line_count1.pl

$line = "";
$line_count = 0;
while ($line = <STDIN>) {
    $line_count++;
	if ($line_count == 5) {
		last;
	}
}

