package Threads::Helper::Form;

use strict;
use warnings;

use parent 'Tu::Helper';

use List::Util qw(first);
use Encode ();

sub errors {
    my $self = shift;

    return ''
      unless my $errors = $self->{env}->{'tu.displayer.vars'}->{errors};
    return '' unless %$errors;

    my $message = 'There were some errors';

    return <<"";
        <div style="height:1em">&nbsp;</div>
        <div class="error">
            $message
        </div>

}

sub input {
    my $self = shift;
    my ($name, %params) = @_;

    my $type     = delete $params{type}     || 'text';
    my $label    = delete $params{label}    || '';
    my $help     = delete $params{help}    || '';
    my $required = delete $params{required} || 0;
    my $default  = delete $params{default}  || '';

    my %attrs;
    foreach my $param (keys %params) {
        $attrs{$param} = $params{$param};
    }

    $label = $self->_build_label($label, $required);

    my $value;
    if ($type eq 'checkbox') {
        my $value = $self->param($name);
        $value = $default unless $self->param('submit');
        $attrs{checked} = 'checked' if defined $value && length($value);
    }
    else {
        $value = $self->_get_value($name, $default);
        $attrs{value} = $value if defined $value && $value ne '';
    }

    my $help_tag = $self->_build_help($help);
    my $error = $self->_build_error($name);

    my $attrs = join ' ', map { qq/$_="$attrs{$_}"/ } sort keys %attrs;
    $attrs = ' ' . $attrs if $attrs;

    return <<"";
<div class="form-input">
    $label<input type="$type" name="$name"$attrs />$help_tag$error
</div>

}

sub password { shift->input(shift, type => 'password', @_) }
sub checkbox { shift->input(shift, type => 'checkbox', @_) }

sub textarea {
    my $self = shift;
    my ($name, %params) = @_;

    my $label    = delete $params{label}    || '';
    my $required = delete $params{required} || 0;
    my $default  = delete $params{default}  || '';

    my %attrs;
    foreach my $param (keys %params) {
        $attrs{$param} = $params{$param};
    }

    $label = $self->_build_label($label, $required);

    my $value = $self->_get_value($name, $default);

    my $error = $self->_build_error($name);

    my $attrs = join ' ', map { qq/$_="$attrs{$_}"/ } sort keys %attrs;
    $attrs = ' ' . $attrs if $attrs;

    return <<"";
<div class="form-input">
    $label<textarea name="$name"$attrs>$value</textarea>$error
</div>

}

sub select {
    my $self = shift;
    my ($name, %params) = @_;

    my $label       = delete $params{label}    || '';
    my $required    = delete $params{required} || 0;
    my $options     = delete $params{options}  || [];
    my $default     = delete $params{default}  || '';
    my $is_multiple = delete $params{multiple} || 0;

    my %attrs;
    foreach my $param (keys %params) {
        $attrs{$param} = $params{$param};
    }

    $label = $self->_build_label($label, $required);

    my $value =
        $is_multiple
      ? $self->_get_values($name, $default)
      : $self->_get_value($name, $default);

    my $error = $self->_build_error($name);

    my $attrs = join ' ', map { qq/$_="$attrs{$_}"/ } sort keys %attrs;
    $attrs = ' ' . $attrs if $attrs;

    my @options;
    while (my ($k, $v) = splice @$options, 0, 2) {
        $k = $self->_html_escape($k);
        $v = $self->_html_escape($v);

        my $selected = '';
        if (
            $is_multiple && ref $value eq 'ARRAY'
            ? (first { $k eq $_ } @$value)
            : ($value eq $k)
          )
        {
            $selected = q{ selected="selected"};
        }

        push @options, qq{        <option value="$k"$selected>$v</option>};
    }

    my $options_str = join "\n", @options;

    my $multiple = '';
    if ($is_multiple) {
        $multiple = ' multiple';
    }

    return <<"";
<div class="form-input">
    $label<select name="$name"$multiple>
$options_str
    </select>$error
</div>

}

sub _build_error {
    my $self = shift;
    my ($name) = @_;

    if (my $error = $self->{env}->{'tu.displayer.vars'}->{errors}->{$name}) {
        return qq{\n    <div class="error">$error</div>};
    }

    return '';
}

sub _build_help {
    my $self = shift;
    my ($help) = @_;

    return '' unless $help;

    return sprintf qq{\n    <div class="form-help">%s</div>}, $help;
}

sub _build_label {
    my $self = shift;
    my ($label, $required) = @_;

    my $required_text = '';
    if ($required) {
        $required_text = '*';
    }

    $label = q{<label>} . $label . $required_text . q{</label><br />} . "\n    "
      if $label;

    return $label;
}

sub _get_value {
    my $self = shift;
    my ($name, $default) = @_;

    my $value = $self->param($name);
    $value = $default unless defined $value;
    $value = ''       unless defined $value;

    return $self->_html_escape($value);
}

sub _get_values {
    my $self = shift;
    my ($name, $default) = @_;

    $default = ''         unless defined $default;
    $default = [$default] unless ref $default eq 'ARRAY';

    my $values = $self->param_multi($name) || [];
    $values = [
        grep { defined $_ && $_ ne '' }
        map { defined $_ ? Encode::decode('UTF-8', $_) : '' } @$values
    ];
    @$values = @$default unless $values && @$values;

    $values = [map {$self->_html_escape($_)} @$values];

    return $values;
}

sub _html_escape {
    my $self = shift;
    my ($input) = @_;

    for ($input) {
        s/&/&amp;/g;
        s/</&lt;/g;
        s/>/&gt;/g;
        s/"/&quot;/g;
    }

    return $input;
}

1;
