=head1 NAME

Clone - wrapper around cloning a git database

=head1 SYNOPSIS

use ReferenceTrack::Repository::Clone;
my $repository_clone = ReferenceTrack::Repository::Clone->new(
    repository_search_results => $repository_search
    );
$repository_clone->clone();
=cut

package ReferenceTrack::Repository::Clone;
use Moose;
use ReferenceTrack::Repository::Search;
use Git::Repository;

has 'repository_search_results' => ( is => 'ro', isa => 'ReferenceTrack::Repository::Search',  required   => 1 );
has '_repositories'             => ( is => 'ro', isa => 'Maybe[ArrayRef]', lazy => 1, builder => '_build__repositories');

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
     Git::Repository->run( clone => $repository_location );
   }
}
no Moose;
__PACKAGE__->meta->make_immutable;
1;