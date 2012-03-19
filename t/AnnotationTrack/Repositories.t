#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use DBICx::TestDatabase;
    use AnnotationTrack::Schema;
    use_ok('AnnotationTrack::Repository');
}

# setup test databases with seed data
my $dbh = DBICx::TestDatabase->new('AnnotationTrack::Schema');
$dbh->resultset('Repositories')->create({ name => "existing repo", location => 'some_location.git'   });

# add a repo and look it up
ok my $repository_to_create  = AnnotationTrack::Repository->new(_dbh => $dbh, name => "test", location => 'yet_another_repo.git'), 'initialise a repo to create';
ok $repository_to_create->create(), 'create a repo';
ok my $found_repository = $dbh->resultset('Repositories')->search({ name => 'test' }), 'lookup the row just inserted';
is 'test', $found_repository->first->name, 'got back the correct name'; 

ok my $preexisting_repo  = AnnotationTrack::Repository->new(_dbh => $dbh, name => "existing repo", location => 'different_location.git'), 'initialise a repo which has a name that already exists';
throws_ok {$preexisting_repo->create()} qr/not unique/, 'repo name already exists';


done_testing();

