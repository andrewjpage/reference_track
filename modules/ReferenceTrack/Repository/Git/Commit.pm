=head1 COMMIT

Commit - wrapper for committing data to the repository

=head1 SYNOPSYS

use ReferenceTrack::Repository::Git::Commit;
my $repository->commit();

Should:
1. If it's the initial commit, update file names to more suitable names
2. If it's not the initial commit, check the differences. If they are just in the annotation, increment
    Y where X.Y is the version. If they are in the sequence, increment X where X.Y is the version
3. Validate the data?

=cut

package ReferenceTrack::Repository::Git::Commit;

use Moose;
use Git::Repository;
use ReferenceTrack::Repository::Git::Instance;
use ReferenceTrack::Repository::Types;
use File::Path qw(make_path remove_tree);


# input
has 'repository'         => ( is => 'ro', isa => 'ReferenceTrack::Schema::Result::Repositories', required => 1);
has 'location'           => ( is => 'ro', isa => 'Str', required => 1);
has 'version'			 => ( is => 'ro', isa => 'Str', required => 1); #branch name
has 'message'			 => ( is => 'ro', isa => 'Str', required => 1); #commit message. The very first commit will have "initial" 
has 'verbose' 			 => ( is => 'ro', isa => 'Bool', required => 0, default => 0 ); # verbose flag


sub _add_and_commit
{
    my($self) = @_;
	my $git_instance_obj  = ReferenceTrack::Repository::Git::Instance->new(location => $self->location); 
  	my $git_instance = $git_instance_obj->git_instance;
  	$git_instance->run(add => '.');
  	$git_instance->run(commit => '-m "$self->message"');
	# Determine if the files need re-naming, and also if the differences are minor/major
 	$git_instance->run(push => origin => $self->version);
  	$git_instance->run(push => origin => 'master');
}
no Moose;
__PACKAGE__->meta->make_immutable;
1;
