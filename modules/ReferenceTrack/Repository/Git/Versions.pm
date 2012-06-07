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
use ReferenceTrack::Repository::Version;

# input
has 'repository'         => ( is => 'ro', isa => 'ReferenceTrack::Schema::Result::Repositories', required => 1);

# output
has 'versions'           => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_versions');      

# internal
has '_branches'          => ( is => 'ro', isa => 'ArrayRef',        lazy => 1, builder => '_build__branches');
has '_working_directory' => ( is => 'ro', isa => 'Str',             default => sub { File::Temp->newdir(CLEANUP => 1).""; });
has '_git_instance'      => ( is => 'ro', isa => 'Git::Repository', lazy => 1, builder => '_build__git_instance');      

sub latest_version
{
   my($self) = @_;
   my @sorted_versions = sort( _sort_versions_desc  @{$self->versions});
   if(@sorted_versions > 0)
   {
     return $sorted_versions[0];
   }
   else
   {
     return "0.1";
   }
}

sub _sort_versions_desc
{
    my @a = split(/\./, $a);
    my @b = split(/\./, $b);

    $b[0]<=>$a[0] || $b[1]<=>$a[1];
}

sub _build_versions
{
   my($self) = @_;
   return $self->_filter_branches_to_version_numbers;
}

sub _filter_branches_to_version_numbers
{
  my($self) = @_;
  my @version_numbers;
  my $version_regex = ReferenceTrack::Repository::Version->version_regex();
  for my $branch(@{$self->_branches()})
  {
    if( $branch =~ /($version_regex)/)
    {
      push(@version_numbers,$1);
    }
  }
  return \@version_numbers;
}

sub _build__branches
{
  my($self) = @_;

  my $raw_branches = $self->_git_instance->run(branch => '-a');
  my @branches = split(/\n/,$raw_branches);
  return \@branches;
}

sub _build__git_instance
{
  my($self) = @_;
  Git::Repository->run( clone => $self->repository->location, $self->_working_directory );
  Git::Repository->new( work_tree => $self->_working_directory);
}

# given a git repository, retrieve a list of all branch names


no Moose;
__PACKAGE__->meta->make_immutable;
1;