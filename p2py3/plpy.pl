#!/usr/bin/perl -w
# Author: 			Diwei Chen
# Date created: 	21/09/2016
# Date modified: 	29/09/2016
# This program is used to translate an input perl script to a python program

use Scalar::Util qw(looks_like_number);

print "#!/usr/local/bin/python3.5 -u\n";

@imports = ();
@lines = ();
%numberMatch = ();
$number_flag = 0;

while (<>) {
	# handle imports
	if ($_ =~ m/<STDIN>|ARGV/) {
		my $flag = 0;
		foreach $cur (@imports) {
			if ($cur eq 'sys') {
				$flag = 1;
				last;
			}
		}
		if ($flag == 0) {
			push(@imports, 'sys');
		}
	}
	if ($_ =~ m/<>/) {
		my $flag = 0;
		foreach $cur (@imports) {
			if ($cur eq 'fileinput') {
				$flag = 1;
				last;
			}
		}
		if ($flag == 0) {
			push(@imports, 'fileinput');
		}
	}
	if ($_ =~ m/=~\s/g) {
		my $flag = 0;
		foreach $cur (@imports) {
			if ($cur eq 're') {
				$flag = 1;
				last;
			}
		}
		if ($flag == 0) {
			push(@imports, 're');
		}
	}
	

	my $localStr = $_;
	chomp $localStr;
	# doesn't handle this line
	if ($localStr =~ m/\/usr\/bin\/perl/) {
		next;
	}

	# match print 
	if ($localStr =~ m/print/) {
		$localStr =~ s/print\s*(".*")/print($1)/;
		# if this contains variable
		
		if ($localStr =~ /\$/) {
			$localStr =~ s/\\n//g;

			# if match a variable pattern: variable name only
			# constains $\d\w_
			# if this contains more than just one variable
			if ($localStr =~ /\$[\d\w_]+/) {
				my $tmpStr = $&;
				# count the number of match
				my @count = $localStr =~ /\$[\d\w_]+/g;
				my $count = scalar @count;
				if ($count == 1) {
					$tmpStr =~ s/\$//g;
					$localStr =~ s/\$[\d\w_]+/%s/;
					$localStr =~ s/\)/ % $tmpStr)/;
				}
				else {
					$localStr =~ s/print\s/print(/;
					$localStr =~ s/;/)/;
				}
			}
			else {
				$localStr =~ s/"//g;
				$localStr =~ s/,\s//;
				
				# contains system variable
				if ($localStr =~ /\$\w+\[\$\w+\]/) {
					$localStr =~ /\[\$\w+\]/;
					my $tmpStr = $&;
					
					$tmpStr =~ s/\[//;
					$tmpStr =~ s/\]//;
					
					$tmpStr = "$tmpStr + 1";
					$localStr =~ s/\[\$\w+\]/[$tmpStr]/;
				}
			}
		}
		else {
			# remove the last newline character
			$localStr =~ s/\\n(\s*)"/$1"/;
			if ($localStr =~ /"Enter.*"/) {
				$localStr =~ s/print/sys\.stdout\.write/;
			}
		}
		# remove empty string
		if ($localStr =~ /\"\"/) {
			$localStr =~ s/,\s\"\"//;
		}
	}

	# match variable
	if ($localStr =~ m/\$/) {
		$localStr =~ s/\$//g;
	}

	# match if
	if ($localStr =~ m/if\s\(/ ) {
		$localStr =~ s/\(//;
		$localStr =~ s/\)\s{/:/;
		$localStr =~ s/\)/:/;
		$localStr =~ s/{//;
		$localStr =~ s/}//;
	}

	# match special format
	if ($localStr =~ /^\s*\{\s*$/) {
		next;
	}


	# match ending bracket
	if ($localStr =~ /}/) {
		if ($localStr =~ /}$/) {
			next;
		}
		else {
			$localStr =~ s/}\s//;
			$localStr =~ s/\s{/:/;
		}
	}


	# match while
	if ($localStr =~ m/while\s\(/) {
		$localStr =~ s/\(//;
		$localStr =~ s/\)\s{/:/;
			if ($localStr =~ m/while.*?<.*>/) {
				$localStr =~ s/<STDIN>/sys\.stdin/;
				$localStr =~ s/while/for/;
				$localStr =~ s/=/in/;
				$localStr =~ s/<>/fileinput\.input\(\)/;
			}
	}

	# match speacil command
	if ($localStr =~ /[Ee]nter.*[Nn]umber/) {
		$number_flag = 1;
	}

	# substitute special characters
	$localStr =~ s/ eq /==/x;
	$localStr =~ s/last;/break/;
	if ($localStr =~ /<STDIN>/) {
		my $tmpStr = $localStr;
		$tmpStr =~ s/\s//g;
		my @tmpStr = split('=', $tmpStr);
		if (looks_like_number($numberMatch{$tmpStr[0]}) or $number_flag == 1) {
			$localStr =~ s/<STDIN>/float(sys\.stdin\.readline\(\)\)/;
		}
	}

	# match special characters
	$localStr =~ s/<STDIN>/sys\.stdin\.readline\(\)/;
	$localStr =~ s/\@ARGV/sys\.argv[1:]/;
	$localStr =~ s/ARGV/sys\.argv/;
	$localStr =~ s/\+\+/ += 1/x;
	$localStr =~ s/\-\-/ -= 1/x;
	$localStr =~ s/elsif/elif/;

	# match chomp
	if ($localStr =~ m/chomp/) {
		$localStr =~ s/chomp\s//;
		$localStr =~ s/;/ = line\.rstrip\(\)/x;
	}

	# match comment character 
	if ($localStr =~ m/\#\s/) {
		# print "$localStr\n";
		push(@lines, "$localStr\n");
		next;
	}

	

	# match join
	if ($localStr =~ m/join\(.*?\)/) {
		my $tmpStr = $&;
		$tmpStr =~ s/join\(//;
		$tmpStr =~ s/\)//;
		my @tmpStr = split(', ', $tmpStr);
		$tmpStr2 = $tmpStr[0] . '.' . "join($tmpStr[1])";
		$localStr =~ s/print(.*)/print($tmpStr2)/;
	}

	# match foreach
	if ($localStr =~ m/foreach/) {
		$localStr =~ s/foreach/for/;
		$localStr =~ s/\(/in /x;
		$localStr =~ s/\)\s{/:/;
	}

	# match range
	if ($localStr =~ m/\d+\.\.\d+/) {
		my $tmpStr = $&;
		my @tmpStr = split('\.\.', $tmpStr);
		$tmpStr[1] = $tmpStr[1] + 1;
		$localStr =~ s/\d+\.\.\d+/range($tmpStr[0], $tmpStr[1])/x
	}

	# match a range pattern with array variable
	if ($localStr =~ m/\d+\.\.\#[\w|\d|\.]+/) {
		my $tmpStr = $&;
		my @tmpStr = split('\.\.', $tmpStr);
		$tmpStr[0] = $tmpStr + 1;
		# if this string contains #
		if ($tmpStr[1] =~ /\#/) {
			$tmpStr[1] =~ s/\#//;
			$tmpStr[1] =~ s/$tmpStr[1]/len\($tmpStr[1]\)/;
		}
		$localStr =~ s/\d+\.\.\#[\w|\d|\.]+/range($tmpStr[1] - $tmpStr[0])/x;
	}

	# match regex
	if ($localStr =~ m/=~\s/) {
		$localStr =~ s/=~/=/;
		# extract the left hand side of =~
		$localStr =~ m/\s+\w+\s/;
		my $tmpStr = $&;
		$tmpStr =~ s/\s//g;
		# extract the first argument of regex
		my $tmpStr1;
		if ($localStr =~ m/s\/.*?\//) {
			$tmpStr1 = $&;
			$tmpStr1 =~ s/s\///;
			$tmpStr1 =~ s/\///;
		}
		# extract the second argument of regex
		my $localStrTmp = $localStr;
		$localStrTmp =~ s/s\/.*?\///;
		my $tmpStr2;
		if ($localStrTmp =~ m/=\s.*g/) {
			$tmpStr2 = $&;
			$tmpStr2 =~ s/=\s//;
			$tmpStr2 =~ s/\/g//;
		}
		$localStr =~ s/\ss\/.*\/g/ re.sub(r'$tmpStr1', '$tmpStr2', $tmpStr)/x;
	}

	# remove the last semicolon
	$localStr =~ s/;$//;
	push(@lines, "$localStr");

	# match assignemnt
	if ($localStr =~ /\s=\s/) {
		my $tmpStr = $localStr;
		$tmpStr =~ s/\s//g;
		my @tmpStr = split('=', $tmpStr);
		if (looks_like_number($tmpStr[1])) {
			$numberMatch{$tmpStr[0]} = $tmpStr[1];
		}
	}
	# match endline character ;
	# if ($_ =~ /;)
	# match newline character
	if ($_ =~ /(.*)(.+?)/s) {
		push(@lines, "\n");
	}
}

# print imports
if (scalar @imports >= 1) {
	print "import ";
	print join(', ', @imports);
	# print @keys;
	print "\n";
}

# print translated contents
print join('', @lines);

