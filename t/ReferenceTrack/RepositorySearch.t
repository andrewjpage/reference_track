#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use DBICx::TestDatabase;
    use ReferenceTrack::Schema;
    use_ok('ReferenceTrack::Repository::Search');
    use_ok('ReferenceTrack::Repository::QueryReport');
}
my %database_settings = (host => "localhost", port => 3306);
# seed data
my $dbh = DBICx::TestDatabase->new('ReferenceTrack::Schema');
$dbh->resultset('Repositories')->create({ name => "something totally different",  location => 'abc.git', short_name => "ABC"   });
$dbh->resultset('Repositories')->create({ name => "existing repo", location => 'some_location.git', short_name => "EFG"   });
$dbh->resultset('Repositories')->create({ name => "another repo",  location => 'some_location.git', short_name => "HIJ"   });


ok my $repository_query_report = ReferenceTrack::Repository::Search->new(
  database_settings => \%database_settings,
  query           => 'repo',
  _ro_dbh         => $dbh,
  _rw_dbh         => $dbh,
  ), 'initialise repo search object';

is 'some_location.git
some_location.git
', ReferenceTrack::Repository::QueryReport->new(results => $repository_query_report->_repository_query_results)->_formatted_report(), 'formatted report as expected';

done_testing();