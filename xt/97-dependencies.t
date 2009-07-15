# -*- mode: cperl; -*-
use Test::Dependencies
    exclude => [qw(Test::Dependencies Test::Base Test::Perl::Critic
                   WWW::Cybozu::Office8::Util
                   WWW::Cybozu::Office8::Timecard
                   WWW::Cybozu::Office8::Todo
                   WWW::Cybozu::Office8::Schedule
                 )],
    style   => 'light';
ok_dependencies();
