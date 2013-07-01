=head1 NAME

Log - Wrapper around Git log command

=head1 SYNOPSIS

use ReferenceTrack::Repository::Git::Log;

=cut

package ReferenceTrack::Repository::Git::Log;
use Moose;
use ReferenceTrack::Repository::Git::Instance;

has 'reference_location' => ( is => 'ro', isa => 'Str', required => 1 );     # git reference (can be url).
has 'since'  => ( is => 'ro', isa => 'Str', default => 'yesterday' );     # how long back should the logs go? default is the last 24 hours
has 'author' => ( is => 'ro', isa => 'Str', required => 0 );     # needed if searching for commits made by a specific author
has '_temp_repository' => ( is => 'rw', isa => 'ReferenceTrack::Repository::Git::Instance', lazy => 1, builder => '_build__temp_repository'); # work repo


sub _build__temp_repository
{
    my($self) = @_;
    return ReferenceTrack::Repository::Git::Instance->new( location => $self->reference_location );
}


=head2 METHOD

  Arg [1]    : 
  Example    : 
  Description: Returns the names and email addresses of the authors who made commits in the time period specified
  Returntype : Arrayref

=cut

sub get_commit_authors
{
	my ($self) = @_;
	my @commits = $self->_temp_repository->git_instance->run('git log' => '--pretty', 'format:"%an %ae"', '--since', $self->since);
	return \@commits;





}