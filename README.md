# LeftistHeap

Raku package with Leftist Heap data structure implementation.

`LeftistHeap` is a mutable, mergeable priority queue. It is a min-heap by
default and accepts a comparator for other orderings or user-defined objects.

```raku
use LeftistHeap;

my $heap = LeftistHeap.new;
$heap.insert($_) for 7, 2, 9, 1;

say $heap.lookup;             # 1
say $heap.delete-top-element; # 1
say $heap.elems;              # 3
```

A comparator can return an `Order`, a negative/zero/positive number, or a
`Bool` indicating that the first argument has higher priority:

```raku
my $max-heap = LeftistHeap.new(
    comparator => -> $a, $b { $a > $b },
);
```

`insert` and `merge` mutate and return the receiving heap. `merge` leaves its
argument usable. `lookup` and `delete-top-element` return `Nil` for an empty
heap. `depth` is the maximum number of nodes on a root-to-leaf path.

Run the tests with `prove6 -l t`. Benchmark scripts accept an optional element
count:

```console
raku benchmarks/insert-delete.raku 100000
raku benchmarks/merge.raku 100000
```
