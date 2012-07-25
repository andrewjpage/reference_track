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

my $tmpdirectory3_obj = File::Temp->newdir(CLEANUP =>1);
my $tmpdirectory3 = $tmpdirectory3_obj->dirname();
initialise_git_repository($tmpdirectory3 );

my $ftp_temp_dir_obj = File::Temp->newdir(CLEANUP => 1);
my $ftp_temp_dir = $ftp_temp_dir_obj->dirname();
BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use DBICx::TestDatabase;
    use ReferenceTrack::Schema;
    use_ok('ReferenceTrack::Repository::PublicRelease');
}

my %database_settings = (port => 3306);

# seed data
my $dbh = DBICx::TestDatabase->new('ReferenceTrack::Schema');
$dbh->resultset('Repositories')
    ->create({ name => "something totally different",  location => 'file:////'.$tmpdirectory, short_name => 'ABC1'   })
    ->version_visibility
    ->create({
        visible_on_ftp_site => 0, 
        version => 0.3
    });
$dbh->resultset('Repositories')->create({ name => "existing repo", location => 'file:////'.$tmpdirectory2,short_name => 'ABC2'   })
    ->version_visibility
    ->create({
        visible_on_ftp_site => 0, 
        version => 0.2
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
      _ro_dbh           => $dbh,
      _rw_dbh           => $dbh,
  ),'search for the repo');

ok( ReferenceTrack::Repository::PublicRelease->new(
      repository_search_results => $repository_search
    )->flag_all_as_publically_released(), 'flag one repository as publically released');

my @x = ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("something totally different")->version_visibility->all;
is( $x[0]->visible_on_ftp_site, 1, 'repository should be flagged as publically released');
is( $x[0]->version, "0.3", 'should remain unchanged');

@x = ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("existing repo"              )->version_visibility->all;
is( $x[0]->visible_on_ftp_site, 0, 'other repositorys should be uneffected');
@x =ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("another repo"               )->version_visibility->all;
is( $x[0]->visible_on_ftp_site, 0, 'other repositorys should be uneffected');

ok( my $repository_search_multiple = ReferenceTrack::Repository::Search->new(
      database_settings => \%database_settings,
      query           => 'repo',
      _ro_dbh           => $dbh,
      _rw_dbh           => $dbh,
  ),'search for multiple repos');

ok( ReferenceTrack::Repository::PublicRelease->new(
      repository_search_results => $repository_search_multiple
    )->flag_all_as_publically_released(), 'flag multiple repositories as publically released');


@x = ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("something totally different")->version_visibility->all;
is( $x[0]->visible_on_ftp_site, 1, 'should remain unchanged');
is( $x[0]->version, "0.3", 'should remain unchanged');

@x = ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("existing repo")->version_visibility->all;
is( $x[1]->visible_on_ftp_site, 1, 'multiple repos should be publically released');
is( $x[1]->version, "0.3", 'should remain unchanged');

@x = ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("another repo"    )->version_visibility->all;
is( $x[1]->visible_on_ftp_site, 1, 'multiple repos should be publically released');
is( $x[1]->version, "0.3", 'should remain unchanged');


ok( ReferenceTrack::Repository::PublicRelease->new(
      repository_search_results => $repository_search_multiple
    )->flag_all_as_major_release(), 'flag multiple repositories as being the next major release');

@x = ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("something totally different")->version_visibility->all;
is( $x[0]->visible_on_ftp_site, 1, 'Should not change because it didnt match regex');
is( $x[0]->version, "0.3", 'no change in version number');

@x = ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("existing repo")->version_visibility->all;
is( $x[2]->visible_on_ftp_site, 0, 'should intially not be visible');
is( $x[2]->version, "1", 'major increment in version number');

@x = ReferenceTrack::Repositories->new( _dbh => $dbh)->find_by_name("another repo"    )->version_visibility->all;
is( $x[2]->visible_on_ftp_site, 0, 'should intially not be visible');
is( $x[2]->version, "1", 'major increment in version number');


# check the reference names are created
my $public_release_obj = ReferenceTrack::Repository::PublicRelease->new(repository_search_results => $repository_search_multiple, public_directory => $ftp_temp_dir);
is("ABC_EFG_HIJ_v0.0001.tgz",$public_release_obj->_tar_file_name("ABC EFG_HIJ","0.0001"), 'create tar file name with minor version');
is("ABC_EFG_HIJ_v1.tgz",$public_release_obj->_tar_file_name("ABC EFG_HIJ","1"), 'create tar file name major version whole int');
is("ABC_EFG_HIJ_v1.0.tgz",$public_release_obj->_tar_file_name("ABC EFG_HIJ","1.0"), 'create tar file name with major version float');
is("ABC_EFG_HIJ_v1.10.tgz",$public_release_obj->_tar_file_name("ABC EFG_HIJ","1.10"), 'create tar file name with major version float with minor version');

# check the correct ftp directory is created
is($ftp_temp_dir."/ABC/",$public_release_obj->_ftp_destination("ABC EFG_HIJ"),'ftp destination is created');
is($ftp_temp_dir."/ABC/",$public_release_obj->_ftp_destination("ABC EFG HIJ"),'ftp destination is created with multiple space');
is($ftp_temp_dir."/ABC_EFG_HIJ/",$public_release_obj->_ftp_destination("ABC_EFG_HIJ"),'ftp destination is created with no space');

ok($public_release_obj->_create_archive_and_copy_to_ftp("ABC EFG", 'file:////'.$tmpdirectory, "0.1"), 'copy contents of git repo to ftp');
ok((-e $ftp_temp_dir."/ABC/ABC_EFG_v0.1.tgz"), 'created archive and saved it to FTP site');


ok($public_release_obj->copy_publically_released_to_ftp_site(), 'publically release all archives');

done_testing();


sub initialise_git_repository
{
   my($tmpdirectory) = @_;
   my $test_directory = getcwd();
  `git init --bare --shared $tmpdirectory`;
  
   my $tmpdirectory_obj2 = File::Temp->newdir(CLEANUP => 1);
   my $tmpdirectory2 = $tmpdirectory_obj2->dirname();
   `git clone file:////$tmpdirectory $tmpdirectory2`;
   
   my $temp_file = 'temp_file_'.sprintf("%03d",int(rand(1000)));
  `cd $tmpdirectory2 && touch "$temp_file"`;
  `cd $tmpdirectory2 && git add $temp_file`;
  `cd $tmpdirectory2 && git commit -m "init"`;
  `cd $tmpdirectory2 && git branch 0.1`;
  `cd $tmpdirectory2 && git branch 0.2`;
  `cd $tmpdirectory2 && git branch 0.3`;
  `cd $tmpdirectory2 && git push --all origin`;
  chdir($test_directory);
}
