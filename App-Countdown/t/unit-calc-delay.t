#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 5;

use App::Countdown;

{
    my $obj = App::Countdown->new({argv => [1]});

    # TEST
    is ($obj->_calc_delay('1'), 1, "_calc_delay(1) == 1");

    # TEST
    is ($obj->_calc_delay('60'), 60, "_calc_delay(60) == 60");

    # TEST
    is ($obj->_calc_delay('2m'), 120, "_calc_delay(2m) == 120 (2 minutes)");

    # TEST
    is ($obj->_calc_delay('1m'), 60, "_calc_delay(1m) == 60 (1 minute)");

    # TEST
    is ($obj->_calc_delay('1h'), 60*60, "_calc_delay(1h) == 60*60 (1 hour)");
}

