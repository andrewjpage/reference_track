#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use_ok('ReferenceTrack::Repository::Version');
}

ok(ReferenceTrack::Repository::Version->new(version_number => "0.1"  ), 'valid version_number');
ok(ReferenceTrack::Repository::Version->new(version_number => "10"   ), 'valid version_number');
is(ReferenceTrack::Repository::Version->new(version_number => "0.10" )->version_number, "0.10", 'valid version_number with trailing zero');

dies_ok( sub {ReferenceTrack::Repository::Version->new(version_number => "abc"   )}, 'version_number cant have string');
dies_ok( sub {ReferenceTrack::Repository::Version->new(version_number => "0"     )}, 'version_number must be greater than 0 ');
dies_ok( sub {ReferenceTrack::Repository::Version->new(version_number => "-1"    )}, 'version_number cant be negative');
dies_ok( sub {ReferenceTrack::Repository::Version->new(version_number => '_1_abc')}, 'version_number can only contain nubmers');


is(ReferenceTrack::Repository::Version->new(version_number => "10"  )->next_version,"10.1",'next version for minor release');
is(ReferenceTrack::Repository::Version->new(version_number => "10.0")->next_version,"10.1",'next version for minor release');
is(ReferenceTrack::Repository::Version->new(version_number => "0.1" )->next_version,"0.2",'next version for pre release');
is(ReferenceTrack::Repository::Version->new(version_number => "0.9" )->next_version,"0.10",'next version for pre release');


is(ReferenceTrack::Repository::Version->new(version_number => "10"  )->next_major_version,"11.1",'next version for major release');
is(ReferenceTrack::Repository::Version->new(version_number => "10.0")->next_major_version,"11.1",'next version for major release');
is(ReferenceTrack::Repository::Version->new(version_number => "0.1" )->next_major_version,"1.1",'next version for pre release');
is(ReferenceTrack::Repository::Version->new(version_number => "0.9" )->next_major_version,"1.1",'next version for pre release');

done_testing();

