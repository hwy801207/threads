% $helpers->assets->require('/js/quick-reply.js');

<div class="grid-100">

    <h1><%= loc('Subscriptions') %></h1>

    % my @subscriptions = $helpers->subscription->find;

    % if (@subscriptions) {
        <p>
        <form class="form-inline quick-delete-subscriptions" method="POST" action="<%= $helpers->url->delete_subscriptions %>">
        <button><%= loc('delete subscriptions') %></button>
        </form>
        </p>
    % }

    % foreach my $subscription (@subscriptions) {
    %    my $thread = $subscription->{thread};
    %== $helpers->displayer->render('include/thread', thread => $thread, view => 1, no_content => 1);
    % }

</div>
