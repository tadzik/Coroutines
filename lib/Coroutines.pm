module Coroutines;

my @coroutines;

my class Coro::still_going {};
my class Coro::done        {};

sub async(&coroutine) is export {
    @coroutines.push($(gather {
        &coroutine();
        take Coro::done;
    }));
}

#= must be called from inside a coroutine
sub yield is export {
    take Coro::still_going;
}

#= should be called from mainline code
sub schedule is export {
    return unless +@coroutines;
    my $r = @coroutines.shift;
    my $result = $r.shift;
    if $result ~~ Coro::still_going {
        @coroutines.push($r);
    }
}
