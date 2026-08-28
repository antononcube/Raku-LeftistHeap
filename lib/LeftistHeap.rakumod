use v6.d;

=begin pod

=NAME LeftistHeap

=DESCRIPTION

A mergeable priority queue implemented as a leftist heap. The comparator
receives two values and may return either an C<Order> (as C<cmp> does) or a
C<Bool> saying whether its first argument has higher priority.

=end pod

class HeapNode is export {
    has Mu $.value is required;
    has HeapNode $.left;
    has HeapNode $.right;
    has Int $.rank;
    has Int $.elems;
    has Int $.depth;

    submethod TWEAK() {
        $!rank  = 1 + ($!right ?? $!right.rank !! 0);
        $!elems = 1
            + ($!left  ?? $!left.elems  !! 0)
            + ($!right ?? $!right.elems !! 0);
        $!depth = 1 + max(
            $!left  ?? $!left.depth  !! 0,
            $!right ?? $!right.depth !! 0,
        );
    }

    method element() { $!value }
}

class LeftistHeap is export {
    has Callable $.comparator = -> Mu $a, Mu $b { $a cmp $b };
    has HeapNode $.root;

    method !has-priority(Mu $a, Mu $b --> Bool:D) {
        my $result = $!comparator($a, $b);

        return $result if $result ~~ Bool;
        return $result === Less if $result ~~ Order;
        $result < 0
    }

    method !make-node(Mu $value, HeapNode $left, HeapNode $right --> HeapNode:D) {
        my $left-rank  = $left  ?? $left.rank  !! 0;
        my $right-rank = $right ?? $right.rank !! 0;

        ($left-rank >= $right-rank)
            ?? HeapNode.new(:$value, :$left, :$right)
            !! HeapNode.new(:$value, left => $right, right => $left)
    }

    method !merge-nodes(HeapNode $first, HeapNode $second --> HeapNode) {
        return $second unless $first;
        return $first  unless $second;

        my ($top, $rest) = self!has-priority($second.value, $first.value)
            ?? ($second, $first)
            !! ($first, $second);

        self!make-node(
            $top.value,
            $top.left,
            self!merge-nodes($top.right, $rest),
        )
    }

    method insert(Mu $value --> LeftistHeap:D) {
        $!root = self!merge-nodes($!root, HeapNode.new(:$value));
        self
    }

    method lookup() {
        $!root ?? $!root.value !! Nil
    }

    method delete-top-element() {
        return Nil unless $!root;

        my $value = $!root.value;
        $!root = self!merge-nodes($!root.left, $!root.right);
        $value
    }

    method merge(LeftistHeap:D $other --> LeftistHeap:D) {
        $!root = self!merge-nodes($!root, $other.root);
        self
    }

    method is-empty(--> Bool:D) {
        !$!root.defined
    }

    method elems(--> Int:D) {
        $!root ?? $!root.elems !! 0
    }

    method depth(--> Int:D) {
        $!root ?? $!root.depth !! 0
    }
}

