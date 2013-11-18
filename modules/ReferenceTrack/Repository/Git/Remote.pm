=head1 NAME

Remote - create a remote repository

=head1 SYNOPSIS

use ReferenceTrack::Repository::Git::Remote;
my $repo = ReferenceTrack::Repository::Git::Remote->new(
  root  => '/path/to/repos',
  name => 'test.git'
  );
$repo->create();
=cut

package ReferenceTrack::Repository::Git::Remote;
use Moose;
use ReferenceTrack::Repository::Types;
use ReferenceTrack::Repository::Git::Instance;
use File::Path qw(make_path remove_tree);
 
# input variables
has 'root'      => (is => 'rw', isa => 'Str');
has 'name'      => (is => 'rw', isa => 'Str');
has 'location'  => (is => 'rw', isa => 'Str', required => 1);
has 'starting_version'  => (is => 'rw', isa => 'Str', default => "1.1"); #Version comprises of X.Y where X if the version of the reference, and Y is the version of the annotation. For anything new, we start with 1.1

# internal variables
has 'full_path' => (is => 'rw', isa => 'Str', lazy => 1, builder => '_build_full_path');

sub _build_full_path
{
  my($self) = @_;
  join('/',($self->root, $self->name));
}

sub create
{
  my($self) = @_;
  make_path($self->full_path, {mode => 0771 });
  system("git init --bare --shared ". $self->full_path);
  $self->create_version_branch;
  1;
}

sub create_version_branch
{
  my($self) = @_;
  my $git_instance_obj  = ReferenceTrack::Repository::Git::Instance->new(location => $self->location); 
  my $git_instance = $git_instance_obj->git_instance;
  system("touch ".$git_instance_obj->working_directory."/README" );
  $git_instance->run(add => '.');
  $git_instance->run(commit => '-m "initial"');
  $git_instance->run(branch => $self->starting_version);
  $git_instance->run(push => origin => $self->starting_version);
  $git_instance->run(push => origin => 'master');
  
}

sub _destroy_repository
{
  my($self) = @_;
  remove_tree($self->full_path, {verbose => 1});
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;