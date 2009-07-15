package WWW::Cybozu::Office8::Util;

use strict;
use warnings;
use utf8;
use Carp;

use Encode ();
use DateTime;
use DateTime::Format::Natural;
use Exporter qw(import);
our @EXPORT = qw(_dotize_ymd _time2dt _is_error _ja);

our $VERSION = '0.01_1';

sub _load_smart_comments {
    return <<'END_ENABLE';
my $debug_flag = $ENV{SMART_COMMENTS} || $ENV{SMART_COMMENT} || $ENV{SMART_DEBUG} || $ENV{SC};
if ($debug_flag) {
    my @p = map { '#'x$_ } ($debug_flag =~ /([345])\s*/g);
    use UNIVERSAL::require;
    Smart::Comments->use(@p);
}
END_ENABLE
}

# change date string into YYYY.MM.DD
sub _dotize_ymd {
	my ($date) = @_;

	if ($date) {
		my $parser = DateTime::Format::Natural->new( time_zone => 'Asia/Tokyo' );
		my $dt = $parser->parse_datetime( $date );
		if ($parser->success) {
			return $dt->strftime("%Y.%m.%d");
		}
	}

	return DateTime->now( time_zone => 'Asia/Tokyo' )->strftime("%Y.%m.%d");
}

sub _time2dt {
	my ($date, $time) = @_;

	my ($hour, $minute) = split( /:/, $time );
	my $parser = DateTime::Format::Natural->new( time_zone => 'Asia/Tokyo' );
	my $dt = $parser->parse_datetime( $date );
	if (!$parser->success) {
		$dt = DateTime->now( time_zone => 'Asia/Tokyo' );
	}
	$dt->set_hour($hour);
	$dt->set_minute($minute);

	return $dt;
}

sub _is_error {
    my($mech) = @_;
    my $str = Encode::decode('shift_jis', $mech->title);
    return $str =~ /エラー\s*(\d+)/ ? $1 : ();
}

sub _ja {
    my($str) = @_;
    Encode::encode('shift_jis', $str);
}

__END__

=head1 NAME

WWW::Cybozu::Office8::Util - convenience functions

=head1 SYNOPSIS

    use WWW::Cybozu::Office8::Util;

=head1 DESCRIPTION

Convenience functions very DASAI.

=head1 METHODS

=head2 _load_smart_comments

Smart::Comments を実行時にロードするための小細工。

ロードする側では BEGIN ブロックでこの関数を呼ぶ。

  BEGIN {
    WWW::Cybozu::Office8::Util->use
      && eval &WWW::Cybozu::Office8::Util::_load_smart_comments;
  }

で、実行時に以下の環境変数のどれかがセットされていれば Smart::Comments
が有効になる。

  SMART_COMMENTS
  SMART_COMMENT
  SMART_DEBUG
  SC

もし、環境変数の値に 3か4か5が含まれている場合はレベルの指定となる。

  env SC='34' foo.pl

は

  use Smart::Comments '###', '####';

となる。

=head2 _dotize_ymd($date)

文字列を受取り日付っぽければ日付文字列を返す。

そうでなければ当日日付文字列を返す。

=head2 _is_error

Cybozu Office の世界のエラー判定をする。

具体的には、HTMLのtitleに「エラー」という文字列が含まれているかどうかで判定する。

=head2 _ja

Cybozu が受け付ける文字コードに変換する。ダサイ。

=head1 SEE ALSO

L<WWW::Cybozu::Office8>,
L<WWW::Cybozu::Office8::Information>,
L<WWW::Cybozu::Office8::Schedule>,

=head1 NOTICE

THIS MODULE IS ALPHA STATUS AND DEVELOPER RELEASE.
SO WE MIGHT CHANGE OBJECT INTERFACE.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
