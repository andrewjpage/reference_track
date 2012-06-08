=head1 NAME

Instance of a git repository (clone to a local directory)

=head1 SYNOPSIS


=cut

package ReferenceTrack::Repository::Git::Instance;
use Moose;
use Git::Repository;
use File::Temp;

# input
has 'location'           => ( is => 'ro', isa => 'Str', required => 1);

has '_working_directory' => ( is => 'ro', isa => 'File::Temp::Dir', default => sub { File::Temp->newdir(CLEANUP => 1); });
has 'git_instance'       => ( is => 'ro', isa => 'Git::Repository', lazy => 1, builder => '_build_git_instance');      

sub working_directory
{
  my($self) = @_;
  $self->_working_directory->dirname();
}


sub _build_git_instance
{
  my($self) = @_;
  Git::Repository->run( clone => $self->location, $self->working_directory );
  Git::Repository->new( work_tree => $self->working_directory);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;