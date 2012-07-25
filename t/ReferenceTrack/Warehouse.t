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
    use DBICx::TestDatabase;
    use ReferenceTrack::Schema;
    use ReferenceTrack::Repository::Search;
    use ReferenceTrack::Repository::Git::Remote;
    use_ok('ReferenceTrack::Repository::Warehouse');
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

# temp repository search
my %database_settings = (host => "localhost", port => 3306);
my $dbh = DBICx::TestDatabase->new('ReferenceTrack::Schema');
$dbh->resultset('Repositories')->create({ name => 'dummy reference',  location => $reference_url, short_name => 'DUMMY' });
ok my $repository_search = ReferenceTrack::Repository::Search->new( database_settings => \%database_settings,
								    query             => 'DUMMY',
								    _ro_dbh           => $dbh,
								    _rw_dbh           => $dbh, ), 'made dummy search object';

# temp warehouse directory
my $tmpdirectory_obj = File::Temp->newdir(CLEANUP => 1);
my $warehouse_dir = $tmpdirectory_obj->dirname();

# Backup to warehouse
my $warehouse = ReferenceTrack::Repository::Warehouse->new( repository_search_results => $repository_search,
							    warehouse_directory       => $warehouse_dir );

my @name_location = @{$warehouse->_repository_name_location};
is $name_location[0][0], 'dummy_reference.git', 'dummy reference name found';
is $name_location[0][1], $reference_url,        'dummy reference url found';

ok $warehouse->backup_repositories_to_warehouse, 'backup to warehouse (clone)';  # clone new repo
ok $warehouse->backup_repositories_to_warehouse, 'backup to warehouse (update)'; # backup existing repo

done_testing();
