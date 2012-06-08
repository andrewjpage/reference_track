=head1 NAME

RepositorySearch - Represents a collection of RepositorySearch

=head1 SYNOPSIS

use ReferenceTrack::RepositorySearch;
my $repository_query_report = ReferenceTrack::RepositorySearch->new(
  database_settings     => \%databasesettings,
  query           => 'abc123'
  );
$repository_query_report->print_report();
=cut

package ReferenceTrack::Repository::Search;
use Moose;
use ReferenceTrack::Repository::QueryReport;
use ReferenceTrack::Repositories;
extends 'ReferenceTrack::Repository::Common';

has 'query'                     => ( is => 'rw', isa => 'Str',      required   => 1 );
has '_repository_query_results' => ( is => 'rw', isa => 'ArrayRef', lazy => 1, builder => '_build__repository_query_results' );

sub _build__repository_query_results
{
  my($self)= @_; 
  ReferenceTrack::Repositories->new( _dbh => $self->_rw_dbh)->find_all_by_name($self->query);
}

sub print_report
{
  my($self)= @_; 
  ReferenceTrack::Repository::QueryReport->new(results => $self->_repository_query_results)->print_report();
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;