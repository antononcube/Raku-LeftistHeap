
use LeftistHeap;

my Int $size = (@*ARGS[0] // 2 ** 16).Int;
my @values = (^$size).roll($size);

my $heap = LeftistHeap.new;
my $time = now;
for @values {
    $heap.push: $_;
}
$time = now - $time;

printf "Push value onto heap (n = %d): %0.2fms\n", $size, $time * 1000;
