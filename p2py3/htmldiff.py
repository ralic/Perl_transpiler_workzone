#!/usr/local/bin/python3.5 -u
import sys, re

#
# htmldiff uses HTML::Diff to create an HTML file that shows the difference
# between two HTML files, given on the command line.
#
# Contributed by Maurice Aubrey <maurice@redweek.com>
#

use strict
use HTML::Diff

sys.argv[1:] == 2 or die "Usage: 0 <file1> <file2>\n"


my @txt
for in sys.argv[1:]:
  open my fh, _ or die "unable to read '_': !"
  local /
  push @txt, scalar <fh>

my changeStatus = 0

print qq{<style type="text/css"><! -= 1 ins{color: greendel{color:red}--></style>\n}
for in @{ html_word_diff(@txt) }):
  my(type, left, right) = @_

  # debug
  #left = re.sub(r'\n', ' ', =~)
  #right = re.sub(r'\n', ' ', =~)
  #print("TYPE:typeLEFT: leftRIGHT: right"))
  #next

  if type == 'u':
    print %s
  else:
    print("<del>left</del>") if length left)
    print("<ins>right</ins>") if length right)
    changeStatus = 1 if length left or length right:

# print("exiting with status: ".%s."" % changeStatus);
exit changeStatus
