package Threads::Action::ViewThread;

use strict;
use warnings;

use parent 'Tu::Action';

use Digest::MD5 ();
use Time::Piece;
use Threads::DB::Thread;
use Threads::DB::View;

sub run {
    my $self = shift;

    my $thread_id = $self->captures->{id};

    return $self->throw_not_found
      unless my $thread =
      Threads::DB::Thread->new(id => $thread_id)->load(with => 'user');

    my $user = $self->scope->user;

    my $view;

    my $today = gmtime->strftime('%Y-%m-%d');

    if ($user && $user->role eq 'user') {
        $view = Threads::DB::View->find(
            first => 1,
            where => [
                thread_id => $thread_id,
                user_id   => $user->get_column('id'),
                \"strftime('%Y-%m-%d', datetime(created,'unixepoch')) = '$today'"
            ]
        );
    }

    my $hash = Digest::MD5::md5_hex(($self->req->remote_host || '') . ':'
          . ($self->req->header('User-Agent') || ''));

    $view ||= Threads::DB::View->find(
        first => 1,
        where => [
            thread_id => $thread_id,
            hash      => $hash,
            \"strftime('%Y-%m-%d', datetime(created,'unixepoch')) = '$today'"
        ]
    );

    if (!$view) {
        $view = Threads::DB::View->new(
            thread_id => $thread_id,
            ($user && $user->role eq 'user')
            ? (user_id => $user->get_column('id'))
            : (),
            hash => $hash
        )->create;
    }

    $thread->set_column(views_count =>
          Threads::DB::View->table->count(where => [thread_id => $thread_id]));
    $thread->update;

    $self->set_var(thread => $thread->to_hash);

    return;
}

1;