module Coroutines;

my @coroutines;

my class Coro::still_going {};
my class Coro::done        {};

my $*MAINLINE = True;

sub async(&coroutine) is export {
    @coroutines.push($(gather {
        my $*MAINLINE = False;
        &coroutine();
        take Coro::done;
    }));
}

sub pass is export {
    if $*MAINLINE {
        sched;
    } else {
        yield;
    }
}

sub yield is export {
    take Coro::still_going;
}

sub sched is export {
    return unless +@coroutines;
    my $r = @coroutines.shift;
    my $result = $r.shift;
    if $result ~~ Coro::still_going {
        @coroutines.push($r);
    }
}
