package WWW::Cybozu::Office8::Schedule;

use strict;
use warnings;
use utf8;
use Carp;

use UNIVERSAL::require;
BEGIN { WWW::Cybozu::Office8::Util->use && eval &WWW::Cybozu::Office8::Util::_load_smart_comments; }
use Web::Scraper;

our $VERSION = '0.01_01';

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    %{ $self } = @_;

    return $self;
}

sub retrieve {
    my($self, %param) = @_;

    my $date = _dotize_ymd($param{date});
    ### $date

    my $url = sprintf($self->{base_url}.'?page=ScheduleUserDay&Date=da.%s',
		$date,
	);
    ### $url
    $self->{mech}->get( $url );

	my $scraper = scraper {
		process '//div[@class="eventLink scheduleMarkTitle0"]//a', 'items[]' => sub {
			my $node = shift;
			my $href = $node->attr('href');
			my $time_title = Encode::decode('Shift_JIS', $node->attr('title'));

			my $time;
			my $title;
			if ( $time_title =~/(.*)\x{fffd}(.*)/ ) {
				$time = $1;
				$title = $2;
			}
			my ($start_time, $end_time) = split( /-/, $time );
			my $start_dt = _time2dt($date, $start_time);
			my $end_dt = _time2dt($date, $end_time);

			return {
				title => $title,
				link => $self->{base_path}.$href,
				start_time => $start_dt->strftime("%Y/%m/%d %H:%M"),
				end_time => $end_dt->strftime("%Y/%m/%d %H:%M"),
			};
		};
	};

    my $r = $scraper->scrape($self->{mech}->content);

    return $r;
}

__END__

=head1 NAME

WWW::Cybozu::Office8::Schedule - manipulating Cybozu Office 8 schedule

=head1 SYNOPSIS

    use WWW::Cybozu::Office8;

    my $cb          = WWW::Cybozu::Office8->new;
    my $cb_schedule = $cb->schedule;

    my $schedules = $cb_schedule->retrieve(date => '2009-7-15');

=head1 DESCRIPTION

Perl module for manipulating Cybozu Office 8 Schedule.

=head1 METHODS

=head2 new

    my $cb          = WWW::Cybozu::Office8->new;
    my $cb_schedule = $cb->schedule;

WWW::Cybozu::Office8 ($cb->schedule) invokes this method so you don't have to call this method.

=head2 retrieve

  $ret = $cb_schedule->retrieve( %param );

Retrieve schedules. Returns array ref of schedule hash.

  {
    items => [ $sche_1, $sche_2, ... ],
  }
  
  $sche_X = {
  	link		=> "LINK",
    title		=> "TITLE",
    start_date  => "YYYY-MM-DD HH:MI",
    end_date  	=> "YYYY-MM-DD HH:MI",
  }


%param is as follows.

=over 4

=item date => human readable date/time string

  ex.
  YYYY-MM-DD
  YYYY-M-D
  YY/M/D

=back

=head1 NOTICE

THIS MODULE IS ALPHA STATUS AND DEVELOPER RELEASE.
SO WE MIGHT CHANGE OBJECT INTERFACE.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
