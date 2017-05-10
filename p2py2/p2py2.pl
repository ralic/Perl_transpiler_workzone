#!/usr/bin/perl

#------------------------
# Nathan Orner z3415943
#------------------------

my @lines = ();	#array of converted lines
my @importList = ();	#list of import modules - eg. sys, re
my $line;

my $indentCount = 0;	#number of tab indents across a line is
my $stopIndent = 0;	#on (if, {, else, elsif), delays the tab indent by 1 line
my $tempIndent = 0;

my $temp = 0;
my $argvi = 0;	#flag for if looping around argv

my $initialLine;	#saves the initial line before translation - for testing if it can't translate a line

 #initialising hash for if comparators - eg. if ($a eq 'b'), eq is the comparator
%ifComp = 	("eq", "==",
			"ne", "!=",
			"gt", ">",
			"ge", ">=",
			"lt", "<",
			"le", "<=",
			);
			

			


#open arguments from command line or just read from standard input (if no arguments)
if (@ARGV) {	#loop arguments from command line

	foreach $f (@ARGV) {
		open F, "<$f" or die "Cannot open file: $f\n";
		
		while ($line = <F>) {	
			push(@lines, convert($line));
		}
		
		printLines();
		close F;
	
	}
	
} else {	#read and convert lines from standard input

	while ($line = <>) {	
			push(@lines, convert($line));
	}
	
	printLines();
	
}





sub addImport {	#add 

	my ($import) = @_;
	if (! in ($import)) {	#check if import is not already in @importList
		push(@importList, $import);
	}
	
}

sub addImportsToLines {

	#make room for import line - eg. import sys
	unshift(@lines, "\n");
	$lines[0] = $lines[1];
	$lines[1] = "import ";
	
	foreach $item (@importList) {
		$lines[1] .= $item.", ";
	}
	$lines[1] =~ s/, $//;
	$lines[1] .= "\n";

}


sub in {	#searches for a given import in @importList
	my ($x) = @_;
	my ($found);
	foreach $elem (@importList) {
		if ($x eq $elem) {
			$found = 1;
		}
	}
	return $found;
}


sub convert {	#converts one line of perl into python
	
	
	my ($line) = @_;

	

	#remove white space from start and end of line	
	$line =~ s/^\s+//g;
	$line =~ s/\s+$//g;

	$initialLine = $line;	#saves the initial line before translation - for testing if it can't translate a line


	#first line
	if ($line =~ /^#!\/usr\/bin\/perl[ ]?[-]?[w]?/ && $. == 1) {
		# translate #! line 	
		$line = "#!/usr/bin/python2.7 -u\n";	
		
	}


	#comment - leave unchanged
	#also works for comments that are indented
	if ($line =~ /^\s*#[^!].*/) {
		# Blank & comment lines can be passed unchanged		
		$line .= "\n";
		
	} 

	#blank lines with only spaces - remove spaces
	if ($line =~ /^\s*$/) {
		$line = "\n";
		
	}
	
	
	

	#print
	if ($line =~ /^print.*/) {	
		
		#extract print arguments
		my ($printArgs) = $line;
		$printArgs =~ s/^print[ ]*//;
		
		my (@arguments) = ();
		@arguments = split(', ',$printArgs);			

		$line = "print ";
		
		my ($argCount) = -1;
		foreach $arg (@arguments) {	#loop through arguments
			$argCount = $argCount + 1;
			
			$arg =~ s/\;|\\n//g;		#remove $,;,\n
			
			
			if ($arg =~ /^"[^ ]*[ ]+[ ]*[^ ]*"/) {	#if in quotes & there is a space - eg. "abc def"
				#do nothing
			} elsif ($arg =~ /^"[ ]*\$.*"/) { #no space & has $
				$arg =~ s/"//g;	#remove quotes
			} else { #no space & no $
				#do nothing
			}
			
			
			
			$arg =~ s/\$//g;	#remove $
			
			if ($#arguments == $argCount) {	#if last argument	
				if ($arg =~ /^""$/) {	#if ""
					$line .= "\n";	
				} else {
					$line = $line."$arg"."\n";	
				}
			} else {
				if ($arg =~ /^""$/) {	#if ""
					#do nothing
				} else {
					$line = $line."${arg}, ";
				}
			}

		}
		$line =~ s/, $//;	#remove possible extra , and space at end
		

	}

	
	
	#variable assignment - eg. $a = 7
	if ($line =~ /^\$/) { 	#starts with a $
	
		$line =~ s/\$|;|\\n//g;	#remove $,;,\n
		
		
		#stdin
		my ($varArg) = $line;
		$varArg =~ s/[^ ]*[ ]=[ ]*//;
		if ($varArg =~ /<STDIN>/) {
			addImport("sys");
			$line =~ s/=.*//;
			$line .= "= sys.stdin.readline()";
		}
		
		
		# increment/decrement ++/--
		if ($line =~ /.*[ ]*[\+|\-]{2}/) {
			my ($incVar) = $line;
			$incVar =~ s/[ ]*[\+|\-]{2}[ ]*$//;
			$line =~ s/${incVar}[ ]*[\+\-]//;	#now is either + or -
			
			$line = $incVar." ".$line."= 1";
			
		}

		#.= contatenation
		my ($concatTemp) = $line;
		$concatTemp =~ s/[ ]*=.*//;
		if ($varArg =~ /$concatTemp[ ]*\..*/) {
			my ($concatVar) = $varArg;
			$concatVar =~ s/.*\.[ ]*//;
			$line = $concatTemp." += ".$concatVar;
		}
		
		$line = $line."\n";
		
	}
	
	
	
	
	#regex
	if ($line =~ /[^ ]* \=\~ s\/.*\//) {	#eg. $a =~ s/[]/[]/g;
		my ($tempRegex) = $line;
		$tempRegex =~ s/[^ ]* =~ s\///;	#remove everything up until actual regex	
		my ($regexReplace) = $tempRegex;
		$tempRegex =~ s/\/.*\/g$|\n//g;	#remove everything after regex
		
		$regexReplace =~ s/[^\/]*\///;
		$regexReplace =~ s/\/g$|\n//g;	#extracts the 'replace' of the regex statement
		
		my ($regexVar) = $line;	#eg. $a
		$regexVar =~ s/=.*|\n//g;
		$regexVar =~ s/ $//;
		$line = $regexVar." = re.sub(r'".$tempRegex."', '".$regexReplace."', ".$regexVar.")\n";

		addImport("re"); 
		
	}



	
	#if
	if ($line =~ /^if/) {
		$ifArg = $line;
		$ifArg =~ s/if |\(|\)| \{|\$//g;	#remove if ,(,), {,$
		
		my ($ifComparator);
		my ($compareIf) = $ifArg;
		$compareIf =~ s/[^ ]* //;
		$compareIf =~ s/ [^ ]*$//;	#eg. eq
		
		if (defined $ifComp{$compareIf}) {
			$ifComparator = $ifComp{$compareIf};	#eg. if $compareIf = "eq", $ifComparator = "=="
			$ifArg =~ s/$compareIf/$ifComparator/;
		}
		
		
		$line = "if $ifArg:\n";
		
		$stopIndent = 1;	#beginning of a loop, delay indenting by 1 line
		$indentCount++;

	}
	
	#elsif
	if ($line =~ /^} elsif/) {
	
		$ifArg = $line;
		$ifArg =~ s/} elsif |\(|\)| \{|\$//g;	#remove if ,(,), {,$
		
		my ($ifComparator);
		my ($compareIf) = $ifArg;
		$compareIf =~ s/[^ ]* //;
		$compareIf =~ s/ [^ ]*$//;
		
		if (defined $ifComp{$compareIf}) {
			$ifComparator = $ifComp{$compareIf};
			$ifArg =~ s/$compareIf/$ifComparator/;
		}
		
		
		$line = "elif $ifArg:\n";
		
		$stopIndent = 1;
	
	}
	if ($line =~ /^elsif/) {
	
		$ifArg = $line;
		$ifArg =~ s/elsif |\(|\)| \{|\$//g;	#remove if ,(,), {,$
		
		my ($ifComparator);
		my ($compareIf) = $ifArg;
		$compareIf =~ s/[^ ]* //;
		$compareIf =~ s/ [^ ]*$//;
		
		if (defined $ifComp{$compareIf}) {
			$ifComparator = $ifComp{$compareIf};
			$ifArg =~ s/$compareIf/$ifComparator/;
		}
		
		
		$line = "elif $ifArg:\n";

		$indentCount++;
		$stopIndent = 1;
	
	}

	
	#else
	if ($line =~ /^} else/) {
		
		$line = "else:\n";

		$indentCount--;
		$stopIndent = 1;
	
	}

	if ($line =~ /^else/) {
		
		$line = "else:\n";

		$indentCount++;
		$stopIndent = 1;
	
	}
	

	#while
	if ($line =~ /^while/) {
		$whileArg = $line;
		$whileArg =~ s/while |\(|\)| \{|\$//g;	#remove if ,(,), {,$
		

		#comparison operations
		my ($whileComparator);
		my ($compareWhile) = $whileArg;
		$compareWhile =~ s/[^ ]* //;
		$compareWhile =~ s/ [^ ]*$//;
		
		
		if (defined $ifComp{$compareWhile}) {
			$whileComparator = $ifComp{$compareWhile};
			$whileArg =~ s/$compareWhile/$whileComparator/;
		}


		my ($whileStdin) = $whileArg;
		$whileStdin =~ s/.* = <>//;		#eg. $line = <>;
		my ($whileStdin2) = $whileArg;
		$whileStdin2 =~ s/.* = <STDIN>//;	#eg. $line = <STDIN>;
		

		if ($whileStdin =~ /^$/) {	#if it is now blank
			my ($whileVar) = $whileArg;
			$whileVar =~ s/<>$//;	#extract variable
			$whileVar =~ s/ = $//;
			$line = "for ".$whileVar." in fileinput.input():\n";
			addImport("fileinput"); 
			
		} elsif ($whileStdin2 =~ /^$/) {
			my ($whileVar) = $whileArg;
			$whileVar =~ s/<.*>$//;	
			$whileVar =~ s/ = $//;
			$line = "for ".$whileVar." in sys.stdin:\n";
			addImport("sys"); 
		
		} else {
			$line = "while $whileArg:\n";
	
		}
		
		$stopIndent = 1;	#beginning of a loop
		$indentCount++;
		
	}

	
	
	#end of loop (eg. if, while)
	if ($line =~ /^}/) {
		$line = "";
		$indentCount--;
		$stopIndent = 1;
		
		$tempIndent = $indentCount - 1;	#hold indentCount in temp variable
		$stopIndent = 1 - $stopIndent;	#reset stopIndent
		
		return $line;	#returned due to not wanting indents on a blank line
	}

	if ($line =~ /^{$/) {
		$line = "";
		return $line;
	}
	
	
	#chomp
	if ($line =~ /^chomp.*/) {
		$line =~ s/\$|;|\\n//g;	#remove $,;,\n
		my ($chompArg) = $line;
		$chompArg =~ s/chomp[ ]*[\(]?[ ]*//;
		$chompArg =~ s/[ ]*[\)]?[ ]*//g;
		$line = $chompArg." = ".$chompArg.".rstrip()";
		$line .= "\n";
	}
	
	#last
	if ($line =~ /^last;/) {
		$line = "break\n";
	}

	#next
	if ($line =~ /^next;/) {
		$line = "continue\n";
	}
	
	
	#join
	if ($line =~ /.*join.*/) {
		#$line =~ s/\\n//g;	#remove \n
		my ($joinTemp) = $line;
		$joinTemp =~ s/.*join\(//;
		$joinTemp =~ s/\).*//;
		
		@joinArgs = split(/, /, $joinTemp);
		my ($joinLineTemp) = $joinArgs[0].".join(".$joinArgs[1];
		$joinLineTemp =~ s/\n//g;	#remove \n
		$joinLineTemp .= ")";
		#$line = $joinLineTemp;
		
		
		my ($beforeJoin) = $line;
		$beforeJoin =~ s/join.*//;
		$beforeJoin =~ s/\n//g;	#remove \n
		my ($afterJoin) = $line;
		$afterJoin =~ s/.*\)//;
		#$afterJoin =~ s/\n//g;	#remove \n
		$line = $beforeJoin.$joinLineTemp.$afterJoin;
		
	}

	
	# @argv	
	if ($line =~ /.*\@ARGV.*/) {
		$line =~ s/\@ARGV/sys\.argv\[1\:\]/;
		addImport("sys");
	}
	

	# $#argv	
	if ($line =~ /.*\#ARGV.*/) {
		$line =~ s/\$\#ARGV/len\(sys\.argv\) - 1/;
		addImport("sys");
		$argvi = 1;
		
	}
	
	# $argv[i]	
	if ($line =~ /.*ARGV\[.*\]/) {
		$line =~ s/ARGV/sys\.argv/;
		$line =~ s/\]/ \+ 1\]/;
		addImport("sys");
		
	}
	
	#logical ops
	if ($line =~ /\|\|/) {$line =~ s/\|\|/or/g;}
	if ($line =~ /[^\#]+\![^=]/) {$line =~ s/\!/not/g;}
	if ($line =~ /\&\&/) {$line =~ s/\&\&/and/g;}


	#hash

	#intialise hash
	if ($line =~ /^\%.*[ ]*=[ ]*\(\);/) {	#eg. %array = ();
		$line =~ s/\$|;|\%|\(|\)|\=//g;	#remove $,;,%,(,),=
		$line =~ s/\s+$//g;
		$line =~ s/[ ]{2,}/ /g;
		$line .= " = {}\n";
			
	}
	if ($line =~ /^\%.*[ ]*;/) {	#eg. %array; 
		$line =~ s/\$|;|\%|\(|\)|\=//g;	#remove $,;,%,(,),=
		$line =~ s/\s+$//g;
		$line =~ s/[ ]{2,}/ /g;
		$line .= " = {}\n";
			
	}

	#arrays

	#intialise arrays
	if ($line =~ /^\@.*[ ]*=[ ]*\(\);/) {	#eg. @array = ();
		$line =~ s/\$|;|\@|\(|\)|\=//g;	#remove $,;,@,(,),=
		$line =~ s/\s+$//g;
		$line =~ s/[ ]{2,}/ /g;
		$line .= " = []\n";
			
	}
	if ($line =~ /^\@.*[ ]*;/) {	#eg. @array; 
		$line =~ s/\$|;|\@|\(|\)|\=//g;	#remove $,;,@,(,),=
		$line =~ s/\s+$//g;
		$line =~ s/[ ]{2,}/ /g;
		$line .= " = []\n";
			
	}

	#array functions
	if ($line =~ /pop/) {	#eg.  pop (@array) , pop  @array
		my ($arrayTemp) = $line;
		$arrayTemp =~ s/.*pop[ ]*[\(]?[ ]*@//;
		$arrayTemp =~ s/[ ]*[\)]?[ ]*;//;	#extract array variable
		$line =~ s/pop[ ]*[\(]?[ ]*@.*[ ]*[\)]?[ ]*;/$arrayTemp\.pop\(\)\n/;
		$line =~ s/\$|;//g;	#remove $,;

	}
	if ($line =~ /push/) {	#eg.  push (@array, 5) , push  @array, 5
		my ($arrayTemp) = $line;
		$arrayTemp =~ s/.*push[ ]*[\(]?[ ]*@//;
		$arrayTemp =~ s/[ ]*[\)]?[ ]*;//;	#extract array variable
		my (@pushTemp) = split(/, /, $arrayTemp);
		$line =~ s/push[ ]*[\(]?[ ]*@.*[ ]*[\)]?[ ]*;/$pushTemp[0]\.insert\($pushTemp[1]\)\n/;
		$line =~ s/\$|;//g;	#remove $,;

	}
	if ($line =~ /unshift/) {	#eg.  unshift (@array, 5) , unshift  @array, 5
		my ($arrayTemp) = $line;
		$arrayTemp =~ s/.*unshift[ ]*[\(]?[ ]*@//;
		$arrayTemp =~ s/[ ]*[\)]?[ ]*;//;	#extract array variable
		my (@pushTemp) = split(/, /, $arrayTemp);
		$line =~ s/unshift[ ]*[\(]?[ ]*@.*[ ]*[\)]?[ ]*;/$pushTemp[0]\.insert\(0, $pushTemp[1]\)\n/;
		$line =~ s/\$|;//g;	#remove $,;

	}
	if ($line =~ /shift/) {	#eg.  shift (@array) , shift  @array
		my ($arrayTemp) = $line;
		$arrayTemp =~ s/.*shift[ ]*[\(]?[ ]*@//;
		$arrayTemp =~ s/[ ]*[\)]?[ ]*;//;	#extract array variable
		$line =~ s/shift[ ]*[\(]?[ ]*@.*[ ]*[\)]?[ ]*;/$arrayTemp\.pop\(0\)\n/;
		$line =~ s/\$|;//g;	#remove $,;

	}
	if ($line =~ /reverse/) {	#eg.  pop (@array) , pop  @array
		my ($arrayTemp) = $line;
		$arrayTemp =~ s/.*reverse[ ]*[\(]?[ ]*@//;
		$arrayTemp =~ s/[ ]*[\)]?[ ]*;//;	#extract array variable
		$line =~ s/reverse[ ]*[\(]?[ ]*@.*[ ]*[\)]?[ ]*;/$arrayTemp\.reverse\(\)\n/;
		$line =~ s/\$|;//g;	#remove $,;

	}
	
	


		

	#foreach
	if ($line =~ /^foreach.*/) {
		my ($forRange1);
		my ($forRange2);
		my (@foreachVars) = ();
		$line =~ s/\$|;|\\n//g;	#remove $,;,\n,(,)
		
		my ($foreachArgs) = $line;
		$foreachArgs =~ s/foreach //;
		$foreachArgs =~ s/ [^ ]*$//;
		$foreachArgs =~ s/\(//;
		#return $foreachArgs;
		#my (@foreachVars) = split(' ', $foreachArgs);
		
		$foreachVars[0] = $foreachArgs;
		$foreachVars[0] =~ s/\.\..*$//;
		$foreachVars[0] =~ s/ [^ ]*$//;
		
		
		$foreachVars[1] = $foreachArgs;
		$foreachVars[1] =~ s/^[^ ]* //;
		$foreachVars[1] =~ s/\)$//;
		
		
		
		if ($foreachVars[1] =~ /.*\.\..*/) {
			$forRange1 = substr($foreachVars[1],0,1);
			
			
			$forRange2 = substr($foreachVars[1],3,length($foreachVars[1])-3);
			
			if (! $argvi) {
				$forRange2++;
			}
			$argvi = 0;
			
			$line = "for ".$foreachVars[0]." in xrange(".$forRange1.", ".$forRange2."):\n";
		} else {
			$line = "for ".$foreachVars[0]." in ".$foreachVars[1].":\n";
		
		}
		#$line = $forRange1.$forRange2."\n";
		$stopIndent = 1;	#beginning of a loop
		$indentCount++;
		
	}
	

	
	$line =~ s/[ ]{2,}/ /g;



	#test for untranslated lines
	if (($initialLine eq $line) && ! ($line =~ /^#/) && ! ($line =~ /^$/)) {
		$line = "# ".$line."\n";
	}
	
	#indenting - has to be last block of code for convert
	if ($stopIndent) {
	
		$tempIndent = $indentCount - 1;	#hold indentCount in temp variable
		$stopIndent = 1 - $stopIndent;	#reset stopIndent
		
		while ($tempIndent > 0) {
			$line = "	".$line;
			$tempIndent--;
		}
	} else {
	
		$temp = $indentCount;		#hold indentCount in temp variable due to while loop
		while ($indentCount > 0) {
			$line = "	".$line;
			$indentCount --;
		}
		$indentCount = $temp;		
	}
	
	#$line = "$indentCount "."$stopIndent ".$line;
	
	
	
	return $line;

}



sub printLines {

	if ($#importList != -1) {	#if there are elements in @importList
		addImportsToLines();
	}

	print @lines;
	
	@lines = (); #clear for next use
	@importList = ();

}
