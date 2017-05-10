#!/usr/bin/perl -w

# chomp without brackets
# pop with variable assignment
# indending with multiple loops
# different version of if, elsif, else

chomp $line
$c = pop @b;

$a = 5;

if ($a < 0)
{
    print "negative\n";
} elsif ($a == 0)
{
    print "zero\n";
} elsif ($a < 10) {
    print "small\n";

	if ($number % 2 == 0) {
            print "Even\n";
	} elsif ($number == 5) {
            print "5";
	} else {
	     print "Odd\n";
	}


} else
{
    print "large\n";
}
