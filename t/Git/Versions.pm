#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Temp;
use Test::MockObject;
 use Cwd;

my $tmpdirectory = File::Temp->newdir(CLEANUP => 0);
my $fake_repository;

BEGIN { unshift(@INC, './modules') }
BEGIN {
  
    
    use Test::Most;
    use_ok('ReferenceTrack::Repository::Git::Versions');
    
    $fake_repository = Test::MockObject->new();
    $fake_repository->fake_module( 'ReferenceTrack::Repository', test => sub{1} );
    $fake_repository->fake_new( 'ReferenceTrack::Repository' );
    $fake_repository->mock('location', sub{ $tmpdirectory });
    $fake_repository->set_isa('ReferenceTrack::Repository');
}

my $test_directory = getcwd();

print $tmpdirectory ,"\n\n";

`git init $tmpdirectory`;
`cd $tmpdirectory && touch "temp_file"`;
`cd $tmpdirectory && git add temp_file`;
`cd $tmpdirectory && git commit -m "init"`;
`cd $tmpdirectory && git branch 0.1`;
`cd $tmpdirectory && git branch 0.2`;
`cd $tmpdirectory && git branch 0.3`;
`cd $test_directory`;

ok(my $repository = ReferenceTrack::Repository::Git::Versions->new(repository => $fake_repository), 'initialise looking up repository');
$repository->versions();

done_testing();
