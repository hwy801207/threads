<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta http-equiv="x-ua-compatible" content="ie=edge" />
<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1" />
<title><%= loc('Send Wikipedia featured article to kindle') %> | Toks</title>
<!--[if lt IE 9]>
  <script src="/unsemantic/js/html5.js"></script>
<![endif]-->
<link rel="stylesheet" href="/unsemantic/css/reset.css" />
<!--[if (gt IE 8) | (IEMobile)]><!-->
  <link rel="stylesheet" href="/unsemantic/css/unsemantic-grid-responsive.css" />
<!--<![endif]-->
<!--[if (lt IE 9) & (!IEMobile)]>
  <link rel="stylesheet" href="/unsemantic/css/ie.css" />
<![endif]-->
<link rel="stylesheet" href="/css/styles.css" />
</head>
<body>
    <div id="wrapper">
        <div class="grid-container">
            <div class="grid-10">
                &nbsp;
            </div>
            <div class="grid-80 mobile-grid-100">
            <div id="header" class="grid-100 mobile-grid-100">
                <a href="<%= $helpers->url->index %>">Toks</a> |
                % if (var('user')) {
                <a href="<%= $helpers->url->settings %>"><%= loc('Settings') %></a> |
                <a href="<%= $helpers->url->change_password %>"><%= loc('Change password') %></a> |
                <a href="<%= $helpers->url->logout %>"><%= loc('Logout') %></a>
                % } else {
                <a href="<%= $helpers->url->register %>"><%= loc('Sign up') %></a> | <a href="<%= $helpers->url->login %>"><%= loc('Login') %></a>
                % }
                <hr />
            </div>
            %== $content;
        </div>
            <div class="grid-10">
            </div>
        </div>
        <div id="push"></div>
    </div>
    <div id="footer">
        <div class="grid-container">
            <div class="grid-100 mobile-grid-100">
                <div>
                % if ($lang eq 'en') {
                    English
                % } else {
                    <a href="/en">English</a>
                % }
                |
                % if ($lang eq 'ru') {
                    Русский
                % } else {
                    <a href="/ru">Русский</a>
                % }
                |
                % if ($lang eq 'uk') {
                    Українська
                % } else {
                    <a href="/uk">Українська</a>
                % }
                </div>

                <%= loc('Written by') %> <a href="http://twitter.com/vtivti">@vti</a>, <%= loc('powered by') %> <a href="http://perl.org">Perl</a>
            </div>
        </div>
    </div>
    <script src="/unsemantic/js/jquery.js"></script>
</body>
</html>
