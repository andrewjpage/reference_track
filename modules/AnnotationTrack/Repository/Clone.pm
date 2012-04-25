=head1 NAME

Clone - wrapper around cloning a git database

=head1 SYNOPSIS

use AnnotationTrack::Repository::Clone;
my $repository_clone = AnnotationTrack::Repository::Clone->new(
    repository_search_results => $repository_search
    );
$repository_clone->clone();
=cut

package AnnotationTrack::Repository::Clone;
use Moose;
use AnnotationTrack::Repositories::Search;
use Git::Repository;

has 'repository_search_results' => ( is => 'ro', isa => 'AnnotationTrack::Repositories::Search',  required   => 1 );
has '_repositories'             => ( is => 'ro', isa => 'Maybe[ArrayRef]', lazy_build => 1);

sub _build__repositories
{
  my ($self)= @_; 
  return unless(defined($self->repository_search_results->_repository_query_results));
  my @repositories ;
  
  for my $repository_row (@{$self->repository_search_results->_repository_query_results})
  {
    push(@repositories,$repository_row->location);
  }
  
  return \@repositories;
}

sub clone
{
   my ($self)= @_; 
   for my $repository_location (@{$self->_repositories})
   {
     Git::Repository->run( clone => $repository_location, '.' );
   }
}

1;