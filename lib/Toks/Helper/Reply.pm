package Toks::Helper::Reply;

use strict;
use warnings;

use parent 'Tu::Helper';

use Toks::DB::Reply;

sub find_by_thread {
    my $self = shift;
    my ($thread) = @_;

    my @replies = Toks::DB::Reply->find(
        where    => [thread_id => $thread->{id}],
        order_by => [lft       => 'ASC'],
        with     => [qw/user parent.user/]
    );

    return map { $_->to_hash } @replies;
}

sub count {
    my $self = shift;
    my ($thread) = @_;

    return Toks::DB::Reply->table->count;
}

1;
