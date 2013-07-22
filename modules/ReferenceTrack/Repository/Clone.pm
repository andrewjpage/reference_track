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
use File::Copy;
use Cwd;
use Cwd 'abs_path';

has 'repository_search_results' => ( is => 'ro', isa => 'ReferenceTrack::Repository::Search',  required   => 1 );
has '_repositories'             => ( is => 'ro', isa => 'Maybe[ArrayRef]', lazy => 1, builder => '_build__repositories');
has 'hook_file'					=> ( is => 'ro', isa => 'Str', default => '/nfs/users/nfs_n/nds/Git_projects/reference_track/hooks/post-commit');

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
    
     # Also copy over the git hook file to the right directory
     # and make it executable by all
     $repository_location =~ m/.*\/(.*)\.git$/;
     my $directory_name = $1;
     my $path = getcwd()."/".$directory_name."/".".git/hooks/";
     copy($self->hook_file, $path);
     `chmod a+x $path."/post-commit"`;
     
   }
}
no Moose;
__PACKAGE__->meta->make_immutable;
1;