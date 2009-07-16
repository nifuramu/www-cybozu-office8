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

my $cb  = WWW::Cybozu::Office8->new;
my $res = $cb->information->retrieve();

my $dt = DateTime->now( time_zone => 'Asia/Tokyo' );
my $feed = {
	link => 'http://cybozu.hq.ecnavi.info/ag.cgi',
	title => 'サイボウズの最新情報',
	entry => [
		map {
			{
				link => $_->{link},
				title => $_->{title},
				date => $dt->iso8601,
			}
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
          - url: script:/home/t-nozaki/projects/plagger/assets/plugins/CustomFeed-Script/cybozu_office8_info.pl

    - module: CustomFeed::Script

=cut
