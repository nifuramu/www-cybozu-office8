use Test::More tests => 1+3;

diag( "You must set login account 'cybozu8' with Config::Pit" );

BEGIN {
    use_ok('Config::Pit');
}

my $pit = pit_get("cybozu8", require => {
    userid   => "user ID on Cybozu8",
    password => "password on Cybozu8",
    base_url => "base URL of Cybozu8",
});

for my $attr (qw(userid password base_url)) {
    ok($pit->{$attr}, $attr);
}
