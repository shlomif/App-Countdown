#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 9;

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

    # TEST
    is ($obj->_calc_delay('5h'), 5*60*60, "_calc_delay(5h) == 5*60*60 (5 hours)");

    # TEST
    is ($obj->_calc_delay('1.5m'), 60+30, "_calc_delay(1.5m) == 60*1.5 (fractional minutes)");

    # TEST
    is ($obj->_calc_delay('1.5h'), 3600 + 1800, "_calc_delay(1.5h) == 3600*1.5 (fractional hours)");

    # TEST
    is ($obj->_calc_delay('0.5m'), 30, "_calc_delay(0.5m) == 30 (leading zero)");
}

