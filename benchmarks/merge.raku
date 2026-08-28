#!/usr/bin/env raku
use v6.d;

use LeftistHeap;

my Int $size = (@*ARGS[0] // 100_000).Int;
my $left  = LeftistHeap.new;
my $right = LeftistHeap.new;
$left.insert($_)  for 0, 2 ...^ $size;
$right.insert($_) for 1, 3 ...^ $size;

my $started = now;
$left.merge($right);
my $elapsed = now - $started;

say "elements after merge: {$left.elems}";
say 'merge: %.6f s'.sprintf($elapsed);
