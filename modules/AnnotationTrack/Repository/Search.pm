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
use AnnotationTrack::Database;
use AnnotationTrack::Repository::QueryReport;
use AnnotationTrack::Repositories;


has 'environment'               => ( is => 'rw', isa => 'Str',      required   => 1 );
has 'query'                     => ( is => 'rw', isa => 'Str',      required   => 1 );
                                
has '_dbh'                      => ( is => 'rw',                    lazy_build   => 1 );
has '_repository_query_results' => ( is => 'rw', isa => 'ArrayRef', lazy_build   => 1 );


sub _build__dbh
{
  my($self)= @_; 
  AnnotationTrack::Database->new( environment => $self->environment)->dbh;
}

sub _build__repository_query_results
{
  my($self)= @_; 
  AnnotationTrack::Repositories->new( _dbh => $self->_dbh)->find_all_by_name($self->query);
}

sub print_report
{
  my($self)= @_; 
  AnnotationTrack::RepositoryQueryReport->new(results => $self->_repository_query_results)->print_report();
}
1;