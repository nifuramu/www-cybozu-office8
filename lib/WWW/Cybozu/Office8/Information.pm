package WWW::Cybozu::Office8::Information;

use strict;
use warnings;
use utf8;
use Carp;

use UNIVERSAL::require;
BEGIN { WWW::Cybozu::Office8::Util->use && eval &WWW::Cybozu::Office8::Util::_load_smart_comments; }
use Web::Scraper;
use Encode;

our $VERSION = '0.01_01';

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    %{ $self } = @_;

    return $self;
}

sub retrieve {
    my($self, ) = @_;

    my $url = sprintf($self->{base_url}.'?page=AjaxPortletContents&tpid=51&tppos=Middle&csrf_ticket=%s&encoding=%s',
		$self->{csrf_ticket},
		'utf-8',
	);
    $self->{mech}->post($url);
    my $scraper = scraper {
		process '//table[@class="dataList"]//a', 'items[]' => sub {
			my $node = shift;
			my $href = $node->attr('href');
			my $title = Encode::decode("Shift_JIS", $node->as_text);
			return if ($href =~ /MyFolderHistory/);
			return {
				link => $self->{base_path}.$href,
				title => $title,
			};
		};
	};
    my $r = $scraper->scrape($self->{mech}->content);

	return $r;
}

__END__

=head1 NAME

WWW::Cybozu::Office8::Information - convenience functions

=head1 SYNOPSIS

    use WWW::Cybozu::Office8;

    my $cb          	= WWW::Cybozu::Office8->new;
    my $cb_information	= $cb->information;

    my $informations = $cb_information->retrieve();

=head1 DESCRIPTION

Perl module for manipulating Cybozu Office 8 Information.

=head1 METHODS

=head2 new

    my $cb				= WWW::Cybozu::Office8->new;
    my $cb_information	= $cb->information;

WWW::Cybozu::Office8 ($cb->schedule) invokes this method so you don't have to call this method.

=head2 retrieve

  $ret = $cb_schedule->retrieve();

Retrieve schedules. Returns array ref of schedule hash.

  {
    items => [ $info_1, $info_2, ... ],
  }
  
  $info_X = {
  	link		=> "LINK",
    title		=> "TITLE",
  }

=head1 NOTICE

THIS MODULE IS ALPHA STATUS AND DEVELOPER RELEASE.
SO WE MIGHT CHANGE OBJECT INTERFACE.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
