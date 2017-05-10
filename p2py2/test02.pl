#!/usr/bin/perl -w

#if, elsif, else with end of loop character '}' not on the same line as the start of the next loop 

if ($a < 0) {
    print "negative\n";
}
elsif ($a == 0) {
    print "zero\n";
}
elsif ($a < 10) {
    print "small\n";
}
else {
    print "large\n";
}
