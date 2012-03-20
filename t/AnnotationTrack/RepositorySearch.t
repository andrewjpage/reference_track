#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use DBICx::TestDatabase;
    use AnnotationTrack::Schema;
    use_ok('AnnotationTrack::Repository::Search');
    use_ok('AnnotationTrack::Repository::QueryReport');
}

# seed data
my $dbh = DBICx::TestDatabase->new('AnnotationTrack::Schema');
$dbh->resultset('Repositories')->create({ name => "something totally different",  location => 'abc.git'   });
$dbh->resultset('Repositories')->create({ name => "existing repo", location => 'some_location.git'   });
$dbh->resultset('Repositories')->create({ name => "another repo",  location => 'some_location.git'   });


ok my $repository_query_report = AnnotationTrack::Repository::Search->new(
  environment     => 'staging',
  query           => 'repo'
  ), 'initialise repo search object';
$repository_query_report->_dbh($dbh); # intercept the database handle and use the test database

is 'some_location.git
some_location.git
', AnnotationTrack::Repository::QueryReport->new(results => $repository_query_report->_repository_query_results)->_formatted_report(), 'formatted report as expected';

done_testing();