package Threads::Action::ToggleSubscription;

use strict;
use warnings;

use parent 'Threads::Action';

use Threads::DB::User;
use Threads::DB::Reply;
use Threads::DB::Subscription;
use Threads::Action::TranslateMixin 'loc';

sub run {
    my $self = shift;

    my $thread_id = $self->captures->{id};
    return $self->new_json_response(404)
      unless my $thread = Threads::DB::Thread->new(id => $thread_id)->load;

    my $user = $self->scope->user;

    my $subscription = Threads::DB::Subscription->find(
        first => 1,
        where => [
            user_id   => $user->id,
            thread_id => $thread->id
        ]
    );

    my $state;
    if ($subscription) {
        $subscription->delete;

        $state = 0;
    }
    else {
        Threads::DB::Subscription->new(
            user_id   => $user->id,
            thread_id => $thread->id
        )->create;

        $state = 1;
    }

    return $self->new_json_response(200, {state => $state});
}

1;
