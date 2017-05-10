#!/usr/bin/python2.7 -u

#
# htmldiff uses HTML::Diff to create an HTML file that shows the difference
# between two HTML files, given on the command line.
#
# Contributed by Maurice Aubrey <maurice@redweek.com>
#

#use strict;

#use HTML::Diff;




my txt
#foreach (@ARGV) {

#  open my $fh, $_ or die "unable to read '$_': $!";

#  local $/;

  push txt, scalar <$fh>

#my $changeStatus = 0;


print qq{<style type="text/css"><!-- ins{color: green} del{color:red} -= 1
#foreach (@{ html_word_diff(@txt) }) {

  my($type, $left, $right) = $_

  # debug
  #$left =~ s/\n/ /g;
  #$right =~ s/\n/ /g;
  #print "TYPE:$type\nLEFT: $left\nRIGHT: $right\n\n";
  #next;

if type == 'u':
#    print $left;

else:
#    print "<del>$left</del>" if length $left;

#    print "<ins>$right</ins>" if length $right;

    changeStatus = 1 if (length left or length right)

# print "exiting with status: ".$changeStatus."\n";
#exit $changeStatus;
