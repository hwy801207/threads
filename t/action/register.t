use strict;
use warnings;

use Test::More;
use TestLib;
use TestDB;
use TestRequest;

use HTTP::Request::Common;
use Threads::DB::User;
use Threads::DB::Confirmation;
use Threads::Action::Register;

subtest 'returns nothing on GET' => sub {
    my $action = _build_action();

    ok !defined $action->run;
};

subtest 'set template var errors' => sub {
    my $action = _build_action(req => POST('/' => {}));

    $action->run;

    my $env = $action->env;

    ok $env->{'tu.displayer.vars'}->{errors};
};

subtest 'set template error when invalid email' => sub {
    my $action =
      _build_action(req => POST('/' => {email => 'foo', password => 'bar'}));

    $action->run;

    my $env = $action->env;

    is $env->{'tu.displayer.vars'}->{errors}->{email}, 'Invalid email';
};

subtest 'set template error when email exists' => sub {
    TestDB->setup;

    TestDB->create('User');

    my $action =
      _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'bar'}));

    $action->run;

    my $env = $action->env;

    is $env->{'tu.displayer.vars'}->{errors}->{email}, 'User exists';
};

subtest 'create user with correct params' => sub {
    TestDB->setup;

    my $action = _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'bar'}),
        'tu.displayer.vars' => {lang => 'ru'}
    );

    $action->run;

    my $user = Threads::DB::User->find(first => 1);

    ok $user;
    is $user->status,     'new';
    is $user->email,      'foo@bar.com';
    isnt $user->password, 'bar';
    like $user->created,  qr/^\d+$/;
};

subtest 'create user with name from email' => sub {
    TestDB->setup;

    my $action = _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'bar'}),
        'tu.displayer.vars' => {lang => 'ru'}
    );

    $action->run;

    my $user = Threads::DB::User->find(first => 1);

    is $user->name, 'foo';
};

subtest 'create user with empty name when exists' => sub {
    TestDB->setup;

    TestDB->create('User', email => 'foo2@bar.com', name => 'foo');

    my $action = _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'bar'}),
        'tu.displayer.vars' => {lang => 'ru'}
    );

    $action->run;

    my $user =
      Threads::DB::User->find(first => 1, where => [email => 'foo@bar.com']);

    is $user->name, '';
};

subtest 'create confirmation token with correct params' => sub {
    TestDB->setup;

    my $action =
      _build_action(
        req => POST('/' => {email => 'foo@bar.com', password => 'bar'}));

    $action->run;

    my $confirmation = Threads::DB::Confirmation->find(first => 1);

    ok $confirmation;
    is $confirmation->user_id,
      Threads::DB::User->find(first => 1)->id;
    isnt $confirmation->token, '';
    is $confirmation->type, 'register';
};

subtest 'sends email' => sub {
    TestDB->setup;

    my $mailer = _mock_mailer();

    my $action = _build_action(
        req    => POST('/' => {email => 'foo@bar.com', password => 'bar'}),
        mailer => $mailer
    );

    $action->run;

    my ($template, %params) = $action->mocked_call_args('render');
    is $template, 'email/confirmation_required';
    is $params{vars}{email},   'foo@bar.com';
    like $params{vars}{token}, qr/^[a-f0-9]+$/;

    my (%mail) = $mailer->mocked_call_args('send');
    is_deeply \%mail,
      {
        headers =>
          [To => 'foo@bar.com', Subject => 'Registration confirmation'],
        body => ''
      };
};

sub _mock_mailer {
    my $mailer = Test::MonkeyMock->new;
    $mailer->mock(send => sub { });

    return $mailer;
}

sub _build_action {
    my (%params) = @_;

    my $env    = $params{env}    || TestRequest->to_env(%params);
    my $mailer = $params{mailer} || _mock_mailer();

    my $action = Threads::Action::Register->new(env => $env);
    $action = Test::MonkeyMock->new($action);
    $action->mock(render => sub { '' });
    $action->mock(mailer => sub { $mailer });

    return $action;
}

done_testing;
