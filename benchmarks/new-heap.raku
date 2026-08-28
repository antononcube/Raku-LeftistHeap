#!/usr/bin/env raku
use v6.d;

use LeftistHeap;

my Int $size = (@*ARGS[0] // 2 ** 16).Int;
my @values = (^$size).roll($size);

my $started = now;
my $heap = LeftistHeap.new(@values, comparator => &infix:<ge>);
my $ended = now;

say "elements: $size";
say 'new heap creation: %.3f s'.sprintf($ended - $started);
