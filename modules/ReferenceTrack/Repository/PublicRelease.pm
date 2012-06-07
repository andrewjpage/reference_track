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
use ReferenceTrack::Repository::Search;
use ReferenceTrack::Repository::Git::Versions;

has 'repository_search_results' => ( is => 'ro', isa => 'ReferenceTrack::Repository::Search',  required   => 1 );

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
        }
      );
  }
  
  return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;