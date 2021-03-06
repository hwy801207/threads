package Threads::DB::View;

use strict;
use warnings;

use parent 'Threads::DB';

__PACKAGE__->meta(
    table   => 'views',
    columns => [
        qw/
          id
          created
          user_id
          thread_id
          hash
          /
    ],
    primary_key    => 'id',
    auto_increment => 'id',
    generate_columns_methods => 1,
);

1;
