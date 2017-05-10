#!/usr/bin/perl

// htmldiff uses HTML::Diff to create an HTML file that shows the difference
// between two HTML files, given on the command line.
// Contributed by Maurice Aubrey <mauriceredweek.com>

use HTML::Diff;

ARGV == 2 or die "Usage: "+0+" <file1> <file2>\n";


var txt;
foreach (ARGV) {
  open var fh, _ or die "unable to read '"+_+"': $!";
  local $/;
  push txt, scalar <fh>;
}

var changeStatus = 0;

document.write( qq{<style type="text/css"><!-- ins{color: green} del{color:red}--></style>\n} );
foreach (@{ html_word_diff(txt) }) {
  my(type, left, right) = _;

  // debug
  //left =~ s/\n/ /g;
  //right =~ s/\n/ /g;
  //print "TYPE:"+type+"\nLEFT: "+left+"\nRIGHT: "+right+"\n\n";
  //next;

  if (type eq 'u') {
    document.write( left );
  } else {
    document.write( "<del>"+left+"</del>" if length left );
    document.write( "<ins>"+right+"</ins>" if length right );
    changeStatus = 1 if (length left or length right);
  }
}

// print "exiting with status: ".changeStatus."\n";
exit changeStatus;