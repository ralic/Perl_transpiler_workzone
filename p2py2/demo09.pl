#!/usr/bin/perl -w

# different versions of if,elsif,else

$a = 0;
$b = 1;

if ($a || $b) 
{
	print $a, $b;
	if ($a && $b) {
		print "yes";
	} elsif (! ($a))
	{
		print "";
	} else
	{
		print "no";
		if (! ($a)) {
			#test
		}
	}
	
}
