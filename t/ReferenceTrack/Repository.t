#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use DBICx::TestDatabase;
    use ReferenceTrack::Schema;
    use_ok('ReferenceTrack::Repository');
}

# setup test databases with seed data
my $dbh = DBICx::TestDatabase->new('ReferenceTrack::Schema');
$dbh->resultset('Repositories')->create({ name => "existing repo", location => 'some_location.git'   });

# add a repo and look it up
ok my $repository_to_create  = ReferenceTrack::Repository->new(_dbh => $dbh, name => "test repo", location => 'yet_another_repo.git'), 'initialise a repo to create';
is 0, $repository_to_create->name_exists, 'name shouldnt exist already';
ok $repository_to_create->create(), 'create a repo';
ok my $found_repository = $dbh->resultset('Repositories')->search({ name => 'test repo' }), 'lookup the row just inserted';
is 'test repo', $found_repository->first->name, 'got back the correct name'; 

# try to add a name that already exists
ok my $preexisting_repo  = ReferenceTrack::Repository->new(_dbh => $dbh, name => "existing repo", location => 'different_location.git'), 'initialise a repo which has a name that already exists';
is 1, $preexisting_repo->name_exists, 'check if name exists in database already';
throws_ok {$preexisting_repo->create()} qr/not unique/, 'repo name already exists';

done_testing();

