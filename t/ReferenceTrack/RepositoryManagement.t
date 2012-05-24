#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use DBICx::TestDatabase;
    use ReferenceTrack::Schema;
    use_ok('ReferenceTrack::Repository::Management');
}

# setup test databases with seed data
my $dbh = DBICx::TestDatabase->new('ReferenceTrack::Schema');
$dbh->resultset('Repositories')->create({ name => "existing repo", location => 'some_location.git'   });

# add a repo and look it up
ok my $repository_to_create  = ReferenceTrack::Repository::Management->new(environment  => 'staging'), 'initialise a repo to create';
$repository_to_create->_rw_dbh($dbh); # intercept the database handle and use the test database
ok $repository_to_create->add("test repo", "abc.git"), 'create a repo';
ok my $found_repository = $dbh->resultset('Repositories')->search({ name => 'test repo' }), 'lookup the row just inserted';
is 'test repo', $found_repository->first->name, 'got back the correct name'; 

# try to add a name that already exists
ok my $repository_exists  = ReferenceTrack::Repository::Management->new(environment  => 'staging'), 'initialise a repo to create';
$repository_exists->_rw_dbh($dbh); # intercept the database handle and use the test database
throws_ok {$repository_exists->add("test repo", "abc.git")} qr/test repo exists in the database/ , 'create a repo';


done_testing();
