#!/usr/bin/perl -w

# using code as is from prime0.pl, tetrahedral.pl

$count = 0;
$i = 2;
while ($i < 100) {
    $k = $i / 2;
    $j = 2;
    while ($j <= $k) {
        $k = $i % $j;
        if ($k == 0) {
            $count = $count - 1;
            last;
        }
        $k = $i / 2;
        $j = $j + 1;
    }
    $count = $count + 1;
    $i = $i + 1;
}
print "$count\n";


$n = 1;
while ($n <= 10) {
    $total = 0;
    $j = 1;
    while ($j <= $n) {
        $i = 1;
        while ($i <= $j) {
            $total = $total + $i;
            $i = $i + 1;
        }
        $j = $j + 1;
    }
    print "$total\n";
    $n = $n + 1;
}