=head1 NAME

Versions - Generates a version number and checks that the input version is valid

=head1 SYNOPSIS

use ReferenceTrack::Repository::Git::Versions;
my $repository = ReferenceTrack::Repository::Versions->new(
  repository => $repository_row
  );
$repository->versions();

=cut

package ReferenceTrack::Repository::Git::Versions;
use Moose;
use Git::Repository;
use File::Temp;

has 'repository'         => ( is => 'ro', isa => 'ReferenceTrack::Repository', required => 1);
has '_branches'          => ( is => 'ro', isa => 'ArrayRef',                   lazy => 1, builder => '_build__branches');
has '_working_directory' => ( is => 'ro', isa => 'Str',                        default => sub { File::Temp->newdir() });
has '_git_instance'      => ( is => 'ro', isa => 'Str',                        lazy => 1, builder => '_build__git_instance');

sub versions
{
   my($self) = @_;
}

sub _build__branches
{
  my($self) = @_;
  # parse results
  $self->_git_instance->(branch => '-a');
}

sub _build__git_instance
{
  my($self) = @_;
  Git::Repository->run( clone => $self->repository->location, $self->_working_directory );
  Git::Repository->new( work_tree => $self->_working_directory );
}

# given a git repository, retrieve a list of all branch names


no Moose;
__PACKAGE__->meta->make_immutable;
1;