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

class LeftistHeap {
    our constant $MINRECSIZE = 5;

    has Callable $.comparator = -> Mu $a, Mu $b { $a cmp $b };
    has HeapNode $.root;

    # Construct a heap with zero or more values
    proto method new(|) {*}
    multi method new(
        ::?CLASS:U:
        *@values,
        :&comparator = -> Mu $a, Mu $b { $a cmp $b }
        --> LeftistHeap:D
    ) {
        my $middle = @values.elems div 2;
        my @left-values = @values.head($middle);
        my @right-values = @values.tail(@values.elems - $middle);

        if @left-values.elems > $MINRECSIZE && @right-values.elems > $MINRECSIZE {
            my $left = self.new(|@left-values, :&comparator);
            my $right = self.new(|@right-values, :&comparator);
            return $left.merge($right);
        }

        my $heap = self.bless(:&comparator);
        $heap.insert($_) for @values;
        $heap
    }

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

    # Insert values into a heap
    method insert(Mu $value --> LeftistHeap:D) {
        $!root = self!merge-nodes($!root, HeapNode.new(:$value));
        self
    }

    proto method push(|) {*}

    multi method push(LeftistHeap:D: *@values is raw --> LeftistHeap:D) {
        self.insert($_) for @values;
        return self;
    }
    multi method push(LeftistHeap:D: Mu $value --> LeftistHeap:D) {
        self.insert($value);
        return self;
    }

    # Just the top element
    method lookup() {
        $!root ?? $!root.value !! Nil
    }

    # Delete/pop top element
    method pop(){ self.delete-top-element }

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

    method traverse(
        &visitor,
        Str:D :$order = 'preorder'
        --> LeftistHeap:D
    ) {
        die "Unknown traversal order '$order'"
            unless $order eq any(<preorder inorder postorder>);

        my @pending;
        @pending.push: [$!root, False] if $!root;

        while @pending {
            my ($node, $visit-now) = @pending.pop.List;

            if $visit-now {
                visitor($node);
                next;
            }

            given $order {
                when 'preorder' {
                    @pending.push: [$node.right, False] if $node.right;
                    @pending.push: [$node.left, False] if $node.left;
                    @pending.push: [$node, True];
                }
                when 'inorder' {
                    @pending.push: [$node.right, False] if $node.right;
                    @pending.push: [$node, True];
                    @pending.push: [$node.left, False] if $node.left;
                }
                when 'postorder' {
                    @pending.push: [$node, True];
                    @pending.push: [$node.right, False] if $node.right;
                    @pending.push: [$node.left, False] if $node.left;
                }
            }
        }

        self
    }

    method values(Str:D :$order = 'preorder' --> Array:D) {
        my @values;
        self.traverse(
            -> HeapNode $node { @values.push($node.value) },
            :$order,
        );
        @values
    }

    method clone(--> LeftistHeap:D) {
        my %copies;

        self.traverse(
            -> HeapNode $node {
                my HeapNode $left = $node.left
                    ?? %copies{$node.left.WHICH}
                    !! HeapNode;
                my HeapNode $right = $node.right
                    ?? %copies{$node.right.WHICH}
                    !! HeapNode;

                %copies{$node.WHICH} = HeapNode.new(
                    value => $node.value,
                    :$left,
                    :$right,
                );
            },
            order => 'postorder',
        );

        my HeapNode $root = $!root
            ?? %copies{$!root.WHICH}
            !! HeapNode;

        self.WHAT.bless(
            comparator => $!comparator,
            :$root,
        )
    }

    method eqv(Mu $other --> Bool:D) {
        return False unless $other ~~ LeftistHeap:D;
        return True if self =:= $other;
        return False unless self.elems == $other.elems;

        my $left = self.clone;
        my $right = $other.clone;

        until $left.is-empty {
            return False unless $left.lookup eqv $right.lookup;
            $left.delete-top-element;
            $right.delete-top-element;
        }

        return True;
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
