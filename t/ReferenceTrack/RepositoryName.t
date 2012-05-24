#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use_ok('ReferenceTrack::Repository::Name');
}

ok(ReferenceTrack::Repository::Name->new(genus => 'ABC',subspecies => 'EFG',strain   => 'HIJ'),'valid name');
ok( my $repo = ReferenceTrack::Repository::Name->new(genus => 'AbC',subspecies => 'EFG',strain   => 'HIJ'),"initialise repo");
is($repo->genus, 'Abc','first letter should be in upper case');
is($repo->repository_name(),'Abc_efg_hij.git','valid name generated git repository');
is($repo->human_readable_name(), 'Abc efg hij', 'human readable repository name');


dies_ok( sub {ReferenceTrack::Repository::Name->new(genus => 'ABC***',subspecies => 'EFG',strain   => 'HIJ')},'invalid genus dies');
dies_ok( sub {ReferenceTrack::Repository::Name->new(genus => 'ABC',subspecies => 'EFG.---',strain   => 'HIJ')},'invalid subspecies dies');
dies_ok( sub {ReferenceTrack::Repository::Name->new(genus => 'ABC',subspecies => 'EFG',strain   => ' XXXX')},'invalid strain dies');
dies_ok( sub {ReferenceTrack::Repository::Name->new(genus => 'ABC',subspecies => 'EFG',strain   => 'X')},'invalid strain dies too short');


done_testing();

