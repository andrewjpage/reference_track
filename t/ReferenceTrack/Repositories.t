#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use DBICx::TestDatabase;
    use ReferenceTrack::Schema;
    use_ok('ReferenceTrack::Repositories');
}

# seed data
my $dbh = DBICx::TestDatabase->new('ReferenceTrack::Schema');
$dbh->resultset('Repositories')->create({ name => "something totally different",  location => 'abc.git', short_name => "ABC"   });
$dbh->resultset('Repositories')->create({ name => "existing repo", location => 'some_location.git', short_name => "ABC2"   });
$dbh->resultset('Repositories')->create({ name => "another repo",  location => 'some_location.git', short_name => "ABC3"   });

ok my $repository = ReferenceTrack::Repositories->new( _dbh     => $dbh), 'initialise repositories';
is 'some_location.git' , $repository->find_by_name('repo')->location, 'return a single row';

is 2, @{$repository->find_all_by_name('repo')}, 'get all matching rows';
is 'some_location.git', $repository->find_all_by_name('repo')->[0]->location,'check that the rows are actually returned for first element';
is 'some_location.git', $repository->find_all_by_name('repo')->[1]->location,'check that the rows are actually returned for last element';

my @names_array = ('something totally different', 'existing repo', 'another repo' );
is_deeply (  $repository->find_all_names(), \@names_array, 'Gets all the names of repositories');

done_testing();

