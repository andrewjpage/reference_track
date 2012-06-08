#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Temp;
use Cwd;


my $tmpdirectory_obj = File::Temp->newdir(CLEANUP => 1);
my $tmpdirectory = $tmpdirectory_obj->dirname();
initialise_git_repository($tmpdirectory );

my $tmpdirectory2_obj = File::Temp->newdir(CLEANUP => 1);
my $tmpdirectory2 = $tmpdirectory2_obj->dirname();
initialise_git_repository($tmpdirectory2 );

my $tmpdirectory3_obj = File::Temp->newdir(CLEANUP => 1);
my $tmpdirectory3 = $tmpdirectory3_obj->dirname();
initialise_git_repository($tmpdirectory3 );

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use DBICx::TestDatabase;
    use ReferenceTrack::Schema;
    use_ok('ReferenceTrack::Repository::PublicRelease');
}

my %database_settings = (host => "localhost", port => 3306);

# seed data
my $dbh = DBICx::TestDatabase->new('ReferenceTrack::Schema');
$dbh->resultset('Repositories')
    ->create({ name => "something totally different",  location => 'file:////'.$tmpdirectory, short_name => 'ABC1'   })
    ->version_visibility
    ->create({
        visible_on_ftp_site => 0, 
        version => 0.1
    });
$dbh->resultset('Repositories')->create({ name => "existing repo", location => 'file:////'.$tmpdirectory2,short_name => 'ABC2'   })
    ->version_visibility
    ->create({
        visible_on_ftp_site => 0, 
        version => 0.1
    });
$dbh->resultset('Repositories')->create({ name => "another repo",  location => 'file:////'.$tmpdirectory3, short_name => 'ABC3'   })
    ->version_visibility
    ->create({
        visible_on_ftp_site => 0, 
        version => 0.1
    });


ok( my $repository_search = ReferenceTrack::Repository::Search->new(
      database_settings => \%database_settings,
      query             => 'something totally different',
  ),'search for the repo');
$repository_search->_ro_dbh($dbh); # intercept the database handle and use the test database

ok( ReferenceTrack::Repository::PublicRelease->new(
      repository_search_results => $repository_search
    )->flag_all_as_publically_released(), 'flag one repository as publically released');

my @x = ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("something totally different")->version_visibility->all;
is( $x[1]->visible_on_ftp_site, 1, 'repository should be flagged as publically released');

@x = ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("existing repo"              )->version_visibility->all;
is( $x[0]->visible_on_ftp_site, 0, 'other repositorys should be uneffected');
@x =ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("another repo"               )->version_visibility->all;
is( $x[0]->visible_on_ftp_site, 0, 'other repositorys should be uneffected');

ok( my $repository_search_multiple = ReferenceTrack::Repository::Search->new(
      database_settings => \%database_settings,
      query           => 'repo',
  ),'search for multiple repos');
$repository_search_multiple->_ro_dbh($dbh); # intercept the database handle and use the test database

ok( ReferenceTrack::Repository::PublicRelease->new(
      repository_search_results => $repository_search_multiple
    )->flag_all_as_publically_released(), 'flag multiple repositories as publically released');


@x = ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("something totally different")->version_visibility->all;
is( $x[1]->visible_on_ftp_site, 1, 'should remain unchanged');

@x = ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("existing repo")->version_visibility->all;
is(  $x[1]->visible_on_ftp_site, 1, 'multiple repos should be publically released');

@x = ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("another repo"    )->version_visibility->all;
is( $x[1]->visible_on_ftp_site, 1, 'multiple repos should be publically released');

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
  chdir($test_directory);
}
