#!/usr/bin/perl -w

# test indentation without proper spacing/tabs

$a = -1;

if ($a < 0) {
print "negative\n";
if ($a < 0) {
print "negative\n";
if ($a < 0) {
print "negative\n";
if ($a < 0) {
print "negative\n";
}
}
}			
}


