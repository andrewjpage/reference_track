#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use DBICx::TestDatabase;
    use ReferenceTrack::Schema;
    use_ok('ReferenceTrack::Repository::PublicRelease');
}

# seed data
my $dbh = DBICx::TestDatabase->new('ReferenceTrack::Schema');
$dbh->resultset('Repositories')->create({ name => "something totally different",  location => 'abc.git'   });
$dbh->resultset('Repositories')->create({ name => "existing repo", location => 'some_location.git'   });
$dbh->resultset('Repositories')->create({ name => "another repo",  location => 'some_other_location.git'   });


ok( my $repository_search = ReferenceTrack::Repository::Search->new(
      environment     => 'test',
      query           => 'something totally different',
  ),'search for the repo');
$repository_search->_ro_dbh($dbh); # intercept the database handle and use the test database

ok( ReferenceTrack::Repository::PublicRelease->new(
      repository_search_results => $repository_search
    )->flag_all_as_publically_released(), 'flag one repository as publically released');


is( ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("something totally different")->public_release, 1, 'repository should be flagged as publically released');
is( ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("existing repo"              )->public_release, 0, 'other repositorys should be uneffected');
is( ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("another repo"               )->public_release, 0, 'other repositorys should be uneffected');

ok( my $repository_search_multiple = ReferenceTrack::Repository::Search->new(
      environment     => 'test',
      query           => 'repo',
  ),'search for multiple repos');
$repository_search_multiple->_ro_dbh($dbh); # intercept the database handle and use the test database

ok( ReferenceTrack::Repository::PublicRelease->new(
      repository_search_results => $repository_search_multiple
    )->flag_all_as_publically_released(), 'flag multiple repositories as publically released');

is( ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("something totally different")->public_release, 1, 'should remain unchanged');
is( ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("existing repo"              )->public_release, 1, 'multiple repos should be publically released');
is( ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("another repo"               )->public_release, 1, 'multiple repos should be publically released');

done_testing();

