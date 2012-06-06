#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Temp;

my $tmpdirectory = File::Temp->newdir(CLEANUP => 1)."/abc.git";
initialise_git_repository($tmpdirectory );
my $tmpdirectory2 = File::Temp->newdir(CLEANUP => 1)."/some_location.git";
initialise_git_repository($tmpdirectory2 );
my $tmpdirectory3 = File::Temp->newdir(CLEANUP => 1)."/some_other_location.git";
initialise_git_repository($tmpdirectory3 );

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use DBICx::TestDatabase;
    use ReferenceTrack::Schema;
    use_ok('ReferenceTrack::Repository::PublicRelease');
}

# seed data
my $dbh = DBICx::TestDatabase->new('ReferenceTrack::Schema');
$dbh->resultset('Repositories')->create({ name => "something totally different",  location => 'file:////'.$tmpdirectory, short_name => 'ABC1'   });
$dbh->resultset('Repositories')->create({ name => "existing repo", location => 'file:////'.$tmpdirectory2,short_name => 'ABC2'   });
$dbh->resultset('Repositories')->create({ name => "another repo",  location => 'file:////'.$tmpdirectory3, short_name => 'ABC3'   });


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


sub initialise_git_repository
{
   my($tmpdirectory) = @_;
   my $test_directory = getcwd();
  `git init $tmpdirectory`;
  `cd $tmpdirectory && touch "temp_file"`;
  `cd $tmpdirectory && git add temp_file`;
  `cd $tmpdirectory && git commit -m "init"`;
  `cd $tmpdirectory && git branch 0.1`;
  `cd $tmpdirectory && git branch 0.2`;
  `cd $tmpdirectory && git branch 0.3`;
  `cd $test_directory`;
}
