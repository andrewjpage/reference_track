=head1 NAME

RepositorySearch - Represents a collection of RepositorySearch

=head1 SYNOPSIS

use AnnotationTrack::RepositorySearch;
my $repository_query_report = AnnotationTrack::RepositorySearch->new(
  environment     => 'test',
  query           => 'abc123'
  );
$repository_query_report->print_report();
=cut

package AnnotationTrack::Repository::Search;
use Moose;
use AnnotationTrack::Repository::QueryReport;
use AnnotationTrack::Repositories;
extends 'AnnotationTrack::Repository::Common';

has 'query'                     => ( is => 'rw', isa => 'Str',      required   => 1 );
has '_repository_query_results' => ( is => 'rw', isa => 'ArrayRef', lazy => 1, builder => '_build__repository_query_results' );

sub _build__repository_query_results
{
  my($self)= @_; 
  AnnotationTrack::Repositories->new( _dbh => $self->_ro_dbh)->find_all_by_name($self->query);
}

sub print_report
{
  my($self)= @_; 
  AnnotationTrack::Repository::QueryReport->new(results => $self->_repository_query_results)->print_report();
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;