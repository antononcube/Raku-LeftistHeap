# LeftistHeap

Raku package with Leftist Heap data structure implementation.

----

## Installation

From Zef ecosystem:

```
zef install LeftistHeap
```

From GitHub:

```
zef install [LeftistHeap](https://github.com/antononcube/Raku-LeftistHeap.git)
```

----

## Basic usage

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

Values can also be supplied during construction. Larger inputs are divided
and recursively merged:

```raku
my @values = 7, 2, 9, 1;
my $heap = LeftistHeap.new(@values);
```

A comparator can return an `Order`, a negative/zero/positive number, or a
`Bool` indicating that the first argument has higher priority:

```raku
my $max-heap = LeftistHeap.new(
    comparator => { $^a > $^b },
);
```

----

## Methods

- `insert` and `merge` mutate and return the receiving heap. 
- `merge` leaves its argument usable, and `clone` returns an independent copy. 
- `lookup` and`delete-top-element` return `Nil` for an empty heap. 
- `depth` is the maximum number of nodes on a root-to-leaf path.
- `traverse` visits `HeapNode` objects without recursion. 
  - Its `order` can be "preorder" (the default), "inorder", or "postorder". 
- `values` returns an array of all stored values and accepts the same `order` option. 
- `eqv` compares two heaps by their priority-ordered values without changing either heap.
 
----

## Benchmarks

A few benchmark scripts are placed in the directory ["./benchmarks"](./benchmarks).

Benchmark scripts accept an optional element count:

```shell
raku benchmarks/insert-delete.raku 32768
raku benchmarks/merge.raku 65536
```
