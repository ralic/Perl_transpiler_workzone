#!/usr/bin/perl -w

#tests the replace section of a regex s/// statement

$apple = abc9;
$apple =~ s/[a-z]*9/5555a/g;	
print $apple, "\n";