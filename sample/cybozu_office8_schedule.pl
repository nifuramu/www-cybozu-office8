#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Carp;

use open IO => ':locale';
use POSIX qw(strftime);
use YAML;
use FindBin;
use lib ("$FindBin::Bin/../lib");
use WWW::Cybozu::Office8;
use DateTime;
use DateTime::Format::Natural;

my $cb  = WWW::Cybozu::Office8->new;
my $res = $cb->schedule->retrieve();

my $now = DateTime->now( time_zone => 'Asia/Tokyo' );
my $dur = DateTime->now( time_zone => 'Asia/Tokyo' )->add( minutes => -15 );
my $parser = DateTime::Format::Natural->new( time_zone => 'Asia/Tokyo' );
my $feed = {
	link => 'http://cybozu.hq.ecnavi.info/ag.cgi',
	title => 'サイボウズの個人スケジュール',
	entry => [
		map {
			my $start_dt = $parser->parse_datetime( $_->{start_time} );
			my $body = $_->{start_time} . "から" . $_->{end_time} . "まで";
			{
				link => $_->{link},
				title => $_->{title},
				date => $start_dt->iso8601,
				body => $body,
			}
		} grep {
			my $start_dt = $parser->parse_datetime( $_->{start_time} );
			($dur->epoch < $start_dt->epoch) && ($start_dt->epoch > $now->epoch);
		}@{$res->{items}}
	],
};

binmode STDOUT, ":utf8";
print YAML::Dump $feed;

__END__

=head1 SYNOPSIS

PlaggerのCustomFeed::Script用
/PATH/TO/PLAGGER/assets/plugin/CustomFeed-Script
へコピーした後に以下のconfigで利用できます。

  plugins:
    - module: Subscription::Config
      config:
        feed:
          - url: script:/home/t-nozaki/projects/plagger/assets/plugins/CustomFeed-Script/cybozu_office8_schedule.pl

    - module: CustomFeed::Script

=cut
