% $helpers->assets->require('/autosize/jquery.autosize.min.js');
% $helpers->assets->require('/js/autosize.js');
% $helpers->assets->require('/js/quick-reply.js');
% $helpers->meta->set(title => loc('Create thread'));

<div class="grid-100">

    <h1><%= loc('Create thread') %></h1>

    <form method="POST" id="create-thread">

    <%== $helpers->form->input('title', label => loc('Title')) %>
    <%== $helpers->form->input('tags', label => loc('Tags'), help => loc('Comma separated')) %>
    <%== $helpers->form->textarea('content', label => loc('Content')) %>

    <div class="form-submit">
        <input type="submit" value="<%= loc('Create new thread') %>" />
        %== $helpers->displayer->render('include/markup-help-button');
    </div>

    </form>

    %== $helpers->displayer->render('include/markup-help');

</div>
