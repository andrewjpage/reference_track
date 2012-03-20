#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use DBICx::TestDatabase;
    use AnnotationTrack::Schema;
    use_ok('AnnotationTrack::Repositories');
}

# seed data
my $dbh = DBICx::TestDatabase->new('AnnotationTrack::Schema');
$dbh->resultset('Repositories')->create({ name => "something totally different",  location => 'abc.git'   });
$dbh->resultset('Repositories')->create({ name => "existing repo", location => 'some_location.git'   });
$dbh->resultset('Repositories')->create({ name => "another repo",  location => 'some_location.git'   });

ok my $repository = AnnotationTrack::Repositories->new( _dbh     => $dbh), 'initialise repositories';
is 'some_location.git' , $repository->find_by_name('repo')->location, 'return a single row';

is 2, @{$repository->find_all_by_name('repo')}, 'get all matching rows';
is 'some_location.git', $repository->find_all_by_name('repo')->[0]->location,'check that the rows are actually returned for first element';
is 'some_location.git', $repository->find_all_by_name('repo')->[1]->location,'check that the rows are actually returned for last element';

done_testing();

