#!/usr/bin/env raku
use v6.d;

use LeftistHeap;

my Int $size = (@*ARGS[0] // 100_000).Int;
my @values = (^$size).pick(*);

my $started = now;
my $heap = LeftistHeap.new;
$heap.insert($_) for @values;
my $inserted = now;
$heap.delete-top-element until $heap.is-empty;
my $deleted = now;

say "elements: $size";
say 'insert:   %.3f s'.sprintf($inserted - $started);
say 'delete:   %.3f s'.sprintf($deleted - $inserted);
say 'combined: %.3f s'.sprintf($deleted - $started);
