#!/usr/bin/python2.7 -u
import sys, re

## htmldiff uses HTML::Diff to create an HTML file that shows the difference
# between two HTML files, given on the command line.
## Contributed by Maurice Aubrey <maurice@redweek.com>
#
# use strict;
# use HTML::Diff;

sys.argv[1:] == 2 or die "Usage: $0 <file1> <file2>\n";

# my @txt;
for sys.argv[1:]) in sys.argv[1:]:
	open my $fh, $_ or die "unable to read '$_': $not";	# local $/;
	txt.insert(scalar <fh>)

# my $changeStatus = 0;

print qq{<style type="text/css"><not-- ins{color: green} del{color:red}--></style>}
for @{ html_word_diff(@txt) in html_word_diff(@txt) }:
	# my($type, $left, $right) = @$_;
	
	# debug
	#$left = re.sub(r'\n/ /g;', ' /g;', #$left)
	#$right = re.sub(r'\n/ /g;', ' /g;', #$right)
	#print "TYPE:$type\nLEFT: $left\nRIGHT: $right\n\n";
	#next;
	
	if type == 'u':
		print left
	else:
		print "<del>left</del>" if length left
		print "<ins>right</ins>" if length right
		changeStatus = 1 if (length left or length right)

# print "exiting with status: ".$changeStatus."\n";
# exit $changeStatus;
