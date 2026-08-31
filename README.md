# LeftistHeap

Raku package that implements the [Leftist Heap](https://en.wikipedia.org/wiki/Leftist_tree) data structure.

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

say $heap.top;                # 1
say $heap.lookup(HeapNode.new(value => 9)); # True
say $heap.delete-top-element; # 1
say $heap.elems;              # 3
```
```
# 1
# True
# 1
# 3
```

Values can also be supplied during construction. Larger inputs are divided
and recursively merged:

```raku
my @values = 7, 2, 9, 1;
my $heap = LeftistHeap.new(@values);
```
```
# LeftistHeap(size => 4, depth => 3, top => 1)
```

A comparator can return an `Order`, a negative/zero/positive number, or a
`Bool` indicating that the first argument has higher priority:

```raku
my $max-heap = LeftistHeap.new(
    comparator => { $^a > $^b },
);
```
```
# LeftistHeap(size => 0, depth => 0, top => Nil)
```

The comparator's result convention is normalized once during construction
(or lazily on the first comparison for an initially empty heap).

----

## Methods

- `insert` and `merge` mutate and return the receiving heap. 
- `merge` leaves its argument usable, and `clone` returns an independent copy. 
- `top` and `delete-top-element` return `Nil` for an empty heap.
- `lookup(HeapNode)` uses the comparator to search for a matching value and returns a `Bool`.
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
```
# elements: 32768
# insert:   2.199 s
# delete:   3.773 s
# combined: 5.972 s
# 1st heap creation time: 1.668155, elems: 65536
# 2nd heap creation time: 1.674280, elems: 65536
# merge: 0.000181 s
# elements after merge: 131072
```
