=head1 NAME

PublicRelease - flag a repository as publically released

=head1 SYNOPSIS

use ReferenceTrack::Repository::PublicRelease;
my $repository_clone = ReferenceTrack::Repository::PublicRelease->new(
    repository_search_results => $repository_search
    );
$repository_clone->flag_all_as_publically_released();
=cut

package ReferenceTrack::Repository::PublicRelease;
use Moose;
use File::Temp;
use ReferenceTrack::Repository::Search;
use ReferenceTrack::Repository::Git::Versions;
use ReferenceTrack::Repository::Version;
use ReferenceTrack::Repository::Git::Remote;
with 'ReferenceTrack::Repository::FTP';

has 'repository_search_results' => ( is => 'ro', isa => 'ReferenceTrack::Repository::Search',  required   => 1 );
has 'public_version'	=> ( is => 'ro', isa => 'Str');


=head2 flag_all_as_publically_released

  Arg [1]    : 
  Example    :
  Description: Marks the latest version of a repository as publically released (i.e. adds a record in table)
  Returntype : 

=cut

sub flag_all_as_publically_released
{
  my ($self)= @_; 
  return unless(defined($self->repository_search_results->_repository_query_results));
  
  for my $repository_row (@{$self->repository_search_results->_repository_query_results})
  {
    my $repository = ReferenceTrack::Repository::Git::Versions->new(repository => $repository_row);
    $repository_row->version_visibility->update_or_create(
        {
          version => $repository->latest_version(),
          visible_on_ftp_site => 1,
          public_version => $self->public_version,
        }
      );
  }
  
  return 1;
}

=head2 flag_all_with_new_version

  Arg [1]    : 
  Example    :
  Description: Calculate the next version for a given repository, update the database and create a version branch
  Returntype : 

=cut

sub _flag_all_with_new_version
{
  my ($self, $next_version_method)= @_; 
  return unless(defined($self->repository_search_results->_repository_query_results));
  
  for my $repository_row (@{$self->repository_search_results->_repository_query_results})
  {
    my $repository = ReferenceTrack::Repository::Git::Versions->new(repository => $repository_row);
    my $next_version = ReferenceTrack::Repository::Version->new(version_number => $repository->latest_version())->$next_version_method();
    $repository_row->version_visibility->update_or_create(
        {
          version => $next_version,
          visible_on_ftp_site => 0,
        }
      );
    # create a version branch on the head of the remote repository
    my $remote_repository = ReferenceTrack::Repository::Git::Remote->new( starting_version => $next_version, location => $repository_row->location);
    $remote_repository->create_version_branch();
  }

  return 1;
}

=head2 flag_all_with_specified_version

  Arg [1]    : Version number
  Example    :
  Description: Update a repository in the database with a specified version (rather than calculating the next version in the method).
  			   Useful when you have the next version calculated already in a previous step.
  Returntype : 

=cut

sub _flag_all_with_specified_version
{
  my ($self, $version)= @_; 
  return unless( defined($self->repository_search_results->_repository_query_results));
  
  for my $repository_row (@{$self->repository_search_results->_repository_query_results})
  {
    $repository_row->version_visibility->update_or_create(
        {
          version => $version,
          visible_on_ftp_site => 0,
        }
      );
  }

  return 1;
}


=head2 flag_all_as_major_release

  Arg [1]    : 
  Example    :
  Description: Do a major update to version number
  Returntype : 
  
=cut

sub flag_all_as_major_release
{
  my ($self)= @_; 
  return $self->_flag_all_with_new_version('next_major_version');
}

=head2 flag_all_as_major_release

  Arg [1]    : 
  Example    :
  Description: Do a minor update to version number
  Returntype : 
  
=cut
sub flag_all_as_minor_release
{
  my ($self)= @_; 
  return $self->_flag_all_with_new_version('next_version');
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
