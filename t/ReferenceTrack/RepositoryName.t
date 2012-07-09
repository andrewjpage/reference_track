#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use_ok('ReferenceTrack::Repository::Name');
}

ok(ReferenceTrack::Repository::Name->new(genus => 'ABC',subspecies => 'EFG',strain   => 'HIJ', short_name => 'ABC'),'valid name');
ok( my $repo = ReferenceTrack::Repository::Name->new(genus => 'AbC',subspecies => 'EFG',strain   => 'HIJ', short_name => 'ABC'),"initialise repo");
is($repo->genus, 'Abc','first letter should be in upper case');
is($repo->repository_name(),'Abc_efg_HIJ.git','valid name generated git repository');
is($repo->human_readable_name(), 'Abc efg HIJ', 'human readable repository name');


dies_ok( sub {ReferenceTrack::Repository::Name->new(genus => 'ABC***',subspecies => 'EFG',strain   => 'HIJ', short_name => 'ABC')},'invalid genus dies');
dies_ok( sub {ReferenceTrack::Repository::Name->new(genus => 'A',subspecies => 'EFG',strain   => 'HIJ', short_name => 'ABC')},'invalid genus dies');
dies_ok( sub {ReferenceTrack::Repository::Name->new(genus => 'ABC',subspecies => 'EFG.---',strain   => 'HIJ', short_name => 'ABC')},'invalid subspecies dies');
dies_ok( sub {ReferenceTrack::Repository::Name->new(genus => 'ABC',subspecies => 'EFG',strain   => ' XXXX', short_name => 'ABC')},'invalid strain dies');
dies_ok( sub {ReferenceTrack::Repository::Name->new(genus => 'ABC',subspecies => 'EFG',strain   => 'X', short_name => 'ABC')},'invalid strain dies too short');
dies_ok( sub {ReferenceTrack::Repository::Name->new(genus => 'ABC',subspecies => 'EFG',strain   => 'XXXXXX', short_name => 'A')},'short name too short');
dies_ok( sub {ReferenceTrack::Repository::Name->new(genus => 'ABC',subspecies => 'EFG',strain   => 'XXXXXX', short_name => 'AAAAAAAAABBBBBBBBB')},'short name too long');
done_testing();

