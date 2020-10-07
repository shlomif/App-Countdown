package App::Countdown;

use 5.010;

use strict;
use warnings FATAL => 'all';

use DateTime::Format::Natural ();
use Time::HiRes qw(sleep time);
use POSIX qw();
use IO::Handle;
use Getopt::Long qw(2.36 GetOptionsFromArray);
use Pod::Usage;
use Carp;

=head1 NAME

App::Countdown - wait some specified time while displaying the remaining time.

=head1 SYNOPSIS

    use App::Countdown ();

    App::Countdown->new({ argv => [@ARGV] })->run();

=head1 SUBROUTINES/METHODS

=head2 new

A constructor. Accepts the argv named arguments.

=head2 run

Runs the program.

=cut

sub new
{
    my $class = shift;

    my $self = bless {}, $class;

    $self->_init(@_);

    return $self;
}

sub _delay
{
    my $self = shift;

    if (@_)
    {
        $self->{_delay} = shift;
    }

    return $self->{_delay};
}

sub _end
{
    my $self = shift;

    if (@_)
    {
        $self->{_end} = shift;
    }

    return $self->{_end};
}

my $up_to_60_re = qr/[1-9]|[1-5][0-9]|0[0-9]?/;

sub _get_up_to_60_val
{
    my ($v) = @_;

    ( $v //= '' ) =~ s/\A0*//;

    return ( length($v) ? $v : 0 );
}

sub _calc_delay
{
    my ( $self, $delay_spec ) = @_;

    if ( my ( $n, $qualifier ) =
        $delay_spec =~ /\A((?:[1-9][0-9]*(?:\.\d*)?)|(?:0\.\d+))([mhs]?)\z/ )
    {
        return int(
            $n * (
                  $qualifier eq 'h' ? ( 60 * 60 )
                : $qualifier eq 'm' ? 60
                :                     1
            )
        );
    }
    elsif ( my ( $min, $sec ) =
        $delay_spec =~ /\A([1-9][0-9]*)m($up_to_60_re)s\z/ )
    {
        return $min * 60 + _get_up_to_60_val($sec);
    }
    elsif ( ( ( my $hour ), $min, $sec ) =
        $delay_spec =~
        /\A([1-9][0-9]*)h(?:($up_to_60_re)m)?(?:($up_to_60_re)s)?\z/ )
    {
        return ( ( $hour * 60 + _get_up_to_60_val($min) ) * 60 +
                _get_up_to_60_val($sec) );
    }
    else
    {
        die
"Invalid delay. Must be a positive and possibly fractional number, possibly followed by s, m, or h";
    }
}

sub _init
{
    my ( $self, $args ) = @_;

    my $argv = [ @{ $args->{argv} } ];

    my $help    = 0;
    my $man     = 0;
    my $version = 0;
    my $end_str;
    if (
        !(
            my $ret = GetOptionsFromArray(
                $argv,
                'help|h' => \$help,
                man      => \$man,
                version  => \$version,
                'to=s'   => \$end_str,
            )
        )
        )
    {
        die "GetOptions failed!";
    }

    if ($help)
    {
        pod2usage(1);
    }

    if ($man)
    {
        pod2usage( -verbose => 2 );
    }

    if ($version)
    {
        print "countdown version $App::Countdown::VERSION .\n";
        exit(0);
    }

    if ( defined $end_str )
    {
        my $parser = DateTime::Format::Natural->new(
            prefer_future => 1,
            time_zone     => 'local',
        );
        my $dt = $parser->parse_datetime($end_str);
        if ( not $parser->success )
        {
            die $parser->error;
        }
        $self->_end( $dt->epoch );
    }
    else
    {
        my $delay = shift(@$argv);

        if ( !defined $delay )
        {
            Carp::confess("You should pass a number of seconds.");
        }

        $self->_delay( $self->_calc_delay($delay) );
    }
    return;
}

sub _format
{
    my $delay = shift;
    return sprintf( "%d:%02d:%02d",
        POSIX::floor( $delay / 3600 ),
        POSIX::floor( $delay / 60 ) % 60,
        $delay % 60 );
}

sub _calc_end
{
    my ( $self, $start ) = @_;

    return defined( $self->_end ) ? $self->_end : ( $start + $self->_delay );
}

sub run
{
    my ($self) = @_;

    STDOUT->autoflush(1);

    my $start = time();
    my $end   = $self->_calc_end($start);

    my $delay = $end - $start;

    my $hms_tot = _format($delay);
    my $last_printed;
    while ( ( my $t = time() ) < $end )
    {
        my $new_to_print = POSIX::floor( $end - $t );
        if ( !defined($last_printed) or $new_to_print != $last_printed )
        {
            $last_printed = $new_to_print;
            my $hms = _format($new_to_print);
            print "Remaining $hms / $hms_tot ( $new_to_print/$delay )",
                ' ' x 10, "\r";
        }
        sleep(0.1);
    }

    return;
}

1;

=head1 USAGE

    countdown [number of seconds]
    countdown [minutes]m
    countdown [hours]h
    countdown [seconds]s
    countdown [minutes]m[seconds]s
    countdown [hours]h[minutes]m[seconds]s
    countdown --to "20:30"

=head1 OPTIONS

    --man - displays the man page.
    --help - displays the help.
    --version - displays the version.

=head1 DESCRIPTION

B<countdown> waits for a certain time to pass, in a similar fashion to the
UNIX sleep command, but unlike sleep, it displays the amount of time left to
sleep. I always found it frustrating that I've placed an alarm using
C<sleep $secs ; finish-client> and could not tell how much time left, so I
wrote B<countdown> for that.

=head1 EXAMPLES

    $ countdown 30s # 30 seconds

    $ countdown 1m  # 1 minute

    $ countdown 100 # 100 seconds

    $ countdown 2h  # 2 hours

    $ countdown 2m30s # 2 minutes and 30 seconds.

    $ countdown 1h0m30s # 1 hour, 0 minutes and 30 seconds.

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/>, C<< <shlomif at cpan.org> >> .

=head1 ACKNOWLEDGEMENTS

=over 4

=item * Neil Bowers

Reporting a typo and a problem with the description not fitting on one line.

=back

=cut

1;    # End of App::Countdown
