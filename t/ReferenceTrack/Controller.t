#!/usr/bin/env perl
use strict;
use warnings;
use Test::MockObject;
use Test::MockModule;
use Test::Exception;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use_ok('ReferenceTrack::Controller');
    use ReferenceTrack::Repository::Management;
    use ReferenceTrack::Repository::Search;
    use ReferenceTrack::Repository::PublicRelease;
    
    my $fake_repo_management = Test::MockObject->new();
    $fake_repo_management->fake_module( 'ReferenceTrack::Repository::Management', test => sub{1} );
    $fake_repo_management->fake_new( 'ReferenceTrack::Repository::Management' );
    $fake_repo_management->mock('create', sub{ 1 });
    $fake_repo_management->mock('add', sub{ 1 });
    
    my $fake_repo_search = Test::MockObject->new();
    $fake_repo_search->fake_module( 'ReferenceTrack::Repository::Search', test => sub{1} );

    my $fake_repo_public_release = Test::MockObject->new();
    $fake_repo_public_release->fake_module( 'ReferenceTrack::Repository::PublicRelease', test => sub{1} );
    $fake_repo_public_release->fake_new( 'ReferenceTrack::Repository::PublicRelease' );
    $fake_repo_public_release->mock('flag_all_as_publically_released', sub{ 1 });
   
}
ok( ReferenceTrack::Controller->new()->run(), "Initialise controller with no parameters");

ok( ReferenceTrack::Controller->new(
      environment      => 'test',
      add_repository   => ['abc','efg'],
      public_release   => 'repo',
      creation_details => ['genus', 'species','subspecies'],
      starting_version => 123
    )->run(), "Initialise controller with all parameters");

done_testing();
