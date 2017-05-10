#!/usr/bin/perl -w


while ($x < 10) {
	print "$x"
	$x--;
	if ($x == 5) 
	{
		next;
		last;
	} 
}