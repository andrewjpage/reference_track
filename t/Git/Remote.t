#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Temp;
use Test::MockObject;
use Cwd;


BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use_ok('ReferenceTrack::Repository::Git::Remote');
}

my $tmpdirectory_obj = File::Temp->newdir(CLEANUP => 1);
my $tmpdirectory = $tmpdirectory_obj->dirname();

ok(-d $tmpdirectory, 'Tmp directory exists');
ok(my $repo = ReferenceTrack::Repository::Git::Remote->new(
  root  => $tmpdirectory,
  name => 'test.git',
  location => 'file:////'.$tmpdirectory.'/test.git'
  ),'Initalise remote repository creation object');
ok($repo->create(),'create remote repository');

ok(-e $tmpdirectory.'/test.git/HEAD','remote repository created on disk');
done_testing();