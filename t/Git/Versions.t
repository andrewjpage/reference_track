#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Temp;
use Test::MockObject;
use Cwd;

my $tmpdirectory = File::Temp->newdir(CLEANUP => 1)."/test_git.git";
my $fake_repository;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use_ok('ReferenceTrack::Repository::Git::Versions');
    
    $fake_repository = Test::MockObject->new();
    $fake_repository->fake_module( 'ReferenceTrack::Schema::Result::Repositories', test => sub{1} );
    $fake_repository->fake_new( 'ReferenceTrack::Schema::Result::Repositories' );
    $fake_repository->mock('location', sub{ 'file:////'.$tmpdirectory });
    $fake_repository->set_isa('ReferenceTrack::Schema::Result::Repositories');
}

initialise_git_repository($tmpdirectory );

ok(my $repository = ReferenceTrack::Repository::Git::Versions->new(repository => $fake_repository), 'initialise looking up repository');
isnt($repository->_working_directory,$tmpdirectory,'working directory is different to remote ');
my $expected_versions = ["0.1","0.2","0.3"];
is_deeply($repository->versions(), $expected_versions,'branch names match');

is($repository->latest_version, '0.3', 'get latest version');

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