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
$dbh->resultset('Repositories')->create({ name => "existing repo", location => 'some_location.git', short_name => 'ABC'   });

# add a repo and look it up
ok my $repository_to_create  = ReferenceTrack::Repository::Management->new(environment  => 'staging'), 'initialise a repo to create';
$repository_to_create->_rw_dbh($dbh); # intercept the database handle and use the test database
ok $repository_to_create->add("test repo", "abc.git", "EFG"), 'create a repo';
ok my $found_repository = $dbh->resultset('Repositories')->search({ name => 'test repo' }), 'lookup the row just inserted';
is 'test repo', $found_repository->first->name, 'got back the correct name'; 

# try to add a name that already exists
ok my $repository_exists  = ReferenceTrack::Repository::Management->new(environment  => 'staging'), 'initialise a repo to create';
$repository_exists->_rw_dbh($dbh); # intercept the database handle and use the test database
throws_ok {$repository_exists->add("test repo", "abc.git","HIJ")} qr/test repo exists in the database/ , 'create a repo';


ok my $create_repo  = ReferenceTrack::Repository::Management->new(environment  => 'staging'), 'initialise a repo to create';
$create_repo->_rw_dbh($dbh); # intercept the database handle and use the test database
ok(my $repo_row = $create_repo->create("Homo","sapiens", "man",'1.1','MAN'), 'create method');

is($repo_row->name, "Homo sapiens man", 'saved name');
my @x = ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("Homo sapiens man")->version_visibility->all;
is(  $x[0]->visible_on_ftp_site, 0, 'Should not be publically visible initially');
is(  $x[0]->version, '1.1', 'Version should be set to number passed in');

done_testing();
