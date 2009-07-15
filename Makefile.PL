use inc::Module::Install;

name        'WWW-Cybozu-Office8';
all_from    'lib/WWW/Cybozu/Office8.pm';

requires 'UNIVERSAL::require'			=> 0;
requires 'WWW::Mechanize'				=> 0;
requires 'Web::Scraper'					=> 0;
requires 'Config::Pit'					=> 0;
requires 'URI'							=> 0;
requires 'DateTime'						=> 0;
requires 'DateTime::Format::Natural'	=> 0;

test_requires 'Test::More' => 0;

use_test_base;
auto_include_deps;
WriteAll;

