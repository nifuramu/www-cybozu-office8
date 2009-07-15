package WWW::Cybozu::Office8;

use 5.8.1;

use strict;
use warnings;
use utf8;
use Carp;

use URI;
use WWW::Mechanize;
use Config::Pit;
use UNIVERSAL::require;
BEGIN { WWW::Cybozu::Office8::Util->use && eval &WWW::Cybozu::Office8::Util::_load_smart_comments }
use WWW::Cybozu::Office8::Schedule;
use WWW::Cybozu::Office8::Information;
use Web::Scraper;

our $VERSION = '0.01_01';

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    %{ $self } = @_;

    my $pit = pit_get("cybozu8", require => {
        userid   => "user ID on Cybozu6 (digit)",
        password => "password on Cybozu6",
        base_url => "base URL of Cybozu6 (http://.../ag.cgi)",
    });
    for (keys %$pit) {
        $self->{$_} = $pit->{$_};
    }

    $self->{mech} = WWW::Mechanize->new;

    $self->login;

    return $self;
}

sub userid {
    my $self = shift;
    $self->{userid} = shift if @_;
    return $self->{userid};
}

sub login {
    my($self) = @_;

    ### login: $self->{userid}
    $self->{mech}->get( $self->{base_url} );

    my $form = $self->{mech}->form_name("LoginForm");
    HTML::Form::ListInput->new(type  => "option",
                               name  => "_Account",
                               value => $self->{userid},
                              )->add_to_form($form);

    $self->{mech}->submit_form(form_name => 'LoginForm',
                               fields => { '_Account'      => $self->{userid},
                                           'Password' => $self->{password},
                                       });
    if (my $errmsg = _is_error($self->{mech})) {
        croak $errmsg;
    }

	$self->base_path;
	$self->csrf_ticket;

    return 1;
}

sub base_path {
	my ($self) = @_;

	$self->{base_path} = URI->new_abs( '/', $self->{base_url} )->as_string;

	return 1;
}

sub csrf_ticket {
    my ($self) = @_;

    my $scraper = scraper {
		process '//input[@name="csrf_ticket"]', 'csrf_ticket' => '@value';
	};
    my $r = $scraper->scrape($self->{mech}->content);
	$self->{csrf_ticket} = $r->{csrf_ticket};

	return 1;
}

sub information {
    my($self) = @_;
    return WWW::Cybozu::Office8::Information->new(%$self);
}

sub schedule {
    my($self) = @_;
    return WWW::Cybozu::Office8::Schedule->new(%$self);
}

1;
__END__

=head1 NAME

WWW::Cybozu::Office8 - manipulating Cybozu Office 6

=head1 SYNOPSIS

    use WWW::Cybozu::Office8;

    my $cb = WWW::Cybozu::Office8->new;

    my $schedules = $cb->schedule->retrieve(date => '2009-7-15');
    ...
    my $informations = $cb->information->retrieve();

=head1 DESCRIPTION

Perl module for manipulating Cybozu Office 8.

=head1 METHODS

=head2 new

  $cb = WWW::Cybozu::Office8->new();

constructs a new WWW::Cybozu::Office8 instance.

=head2 login

do login sequence.

=head2 userid

returns user id.

=head2 base_path

return base_path

=head2 csrf_ticket

return csrf_ticket

=head2 information

  $cb_information = $cb->information;

return WWW::Cybozu::Office8::Information instance.
see L<WWW::Cybozu::Office8::Information> for details.

=head2 schedule

  $cb_schedule = $cb->schedule;

return WWW::Cybozu::Office8::Schedule instance.
see L<WWW::Cybozu::Office8::Schedule> for details.

=head1 SEE ALSO

L<WWW::Cybozu::Office8::Information>,
L<WWW::Cybozu::Office8::Schedule>,

=head1 AUTHOR

Tetsunari Nozaki, C<< <nozzzzz@gmail.com> >>

=head1 NOTICE

THIS MODULE IS ALPHA STATUS AND DEVELOPER RELEASE.
SO WE MIGHT CHANGE OBJECT INTERFACE.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
