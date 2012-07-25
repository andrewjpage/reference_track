#!/usr/bin/env perl

use strict;
use warnings;
use File::Temp;
use Data::Dumper;
use Test::MockObject;
use Cwd;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use_ok('ReferenceTrack::Repository::Git::Warehouse');
    use_ok('ReferenceTrack::Repository::Git::Remote'); # use new remote object for test
}

# temp reference
my $reference_tmpdirectory_obj = File::Temp->newdir(CLEANUP => 1);
my $reference_dir = $reference_tmpdirectory_obj->dirname();
my $reference_url = 'file:////'.$reference_dir.'/test.git';

my $reference = ReferenceTrack::Repository::Git::Remote->new( root => $reference_dir,
							      name => 'test.git',
							      location => $reference_url);

open(my $copy_stdout, ">&STDOUT"); open(STDOUT, '>/dev/null'); # Redirect STDOUT
open(my $copy_stderr, ">&STDERR"); open(STDERR, '>/dev/null'); # Redirect STDERR
$reference->create(); # Initialize empty shared Git repository
close(STDOUT); open(STDOUT, ">&", $copy_stdout); # Restore STDOUT
close(STDERR); open(STDERR, ">&", $copy_stderr); # Restore STDERR
ok(-e $reference_dir.'/test.git/HEAD','created dummy reference');

# temp warehouse directory
my $warehouse_tmpdirectory_obj = File::Temp->newdir(CLEANUP => 1);
my $warehouse_dir = $warehouse_tmpdirectory_obj->dirname();
my $warehouse_url = $warehouse_dir.'/test_warehouse.git';

my $warehouse = ReferenceTrack::Repository::Git::Warehouse->new( reference_location => $reference_url,
								 warehouse_location => $warehouse_url );

is $warehouse->reference_exists, 1, 'confirm reference exists';
is $warehouse->warehouse_exists, 0, 'confirm warehouse does not exist';

ok $warehouse->clone_to_warehouse,  'clone to warehouse';
is $warehouse->warehouse_exists, 1, 'confirm warehouse exists';

ok $warehouse->backup_to_warehouse, 'backup to warehouse';

done_testing();
