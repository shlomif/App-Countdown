#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

use App::Countdown;

{
    my $obj = App::Countdown->new({argv => [1]});

    # TEST
    is ($obj->_calc_delay('1'), 1, "_calc_delay(1) == 1");
}

