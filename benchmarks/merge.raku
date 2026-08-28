#!/usr/bin/env raku
use v6.d;

use LeftistHeap;

my Int $size = (@*ARGS[0] // 2 ** 16).Int;

my $started = now;
my $left  = LeftistHeap.new((^$size).roll($size));
my $elapsed = now - $started;
say "1st heap creation time: {$elapsed.fmt('%.6f')}, elems: {$left.elems}";

$started = now;
my $right = LeftistHeap.new((^$size).roll($size));
$elapsed = now - $started;
say "2nd heap creation time: {$elapsed.fmt('%.6f')}, elems: {$left.elems}";

$started = now;
$left.merge($right);
$elapsed = now - $started;

say 'merge: %.6f s'.sprintf($elapsed);
say "elements after merge: {$left.elems}";
