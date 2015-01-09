package Toks::LimitChecker;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub check {
    my $self = shift;
    my ($limits, $db) = @_;

    return 0 unless $limits && ref $limits eq 'HASH';

    foreach my $time (keys %$limits) {
        my $limit = $limits->{$time};

        my $count =
          $db->table->count(where => [created => {'>=' => time - $time}]);

        if ($count >= $limit) {
            return 1;
        }
    }

    return 0;
}

1;
