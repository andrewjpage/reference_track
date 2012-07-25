=head1 NAME

Warehouse - wrapper for cloning and updating a backup repository.

=head1 SYNOPSYS

use ReferenceTrack::Repository::Git::Warehouse;
my $warehouse_backup = ReferenceTrack::Repository::Warehouse->new(reference_location = $reference, 
                                                                  warehouse_location = $warehouse);
$warehouse_backup->clone_to_warehouse();
$warehouse_backup->backup_to_warehouse();

=cut

package ReferenceTrack::Repository::Git::Warehouse;
use Moose;
use ReferenceTrack::Repository::Git::Instance;

has 'reference_location' => ( is => 'ro', isa => 'Str', required => 1 );     # git reference (can be url).
has 'warehouse_location' => ( is => 'ro', isa => 'Str', required => 1 );     # git warehouse (can't be url if setting-up).
has 'verbose' => ( is => 'ro', isa => 'Bool', required => 0, default => 0 ); # verbose flag
has '_temp_repository' => ( is => 'rw', isa => 'ReferenceTrack::Repository::Git::Instance', lazy => 1, builder => '_build__temp_repository'); # work repo

sub _build__temp_repository
{
    my($self) = @_;
    return ReferenceTrack::Repository::Git::Instance->new( location => $self->reference_location );
}

sub _is_repository_location_exists
{
    my($self, $location) = @_;
    eval { my $remote_list = Git::Repository->run('ls-remote' => $location); };
    return $@ ? 0:1;
}

# Execute Git::Repository::Command for _temp_repository
sub _git_command
{
    my($self, @cmd) = @_;

    my $git_cmd = $self->_temp_repository->git_instance->command(@cmd);
    
    my @git_cmdline = $git_cmd->cmdline();
    my @git_stdout  = $git_cmd->stdout->getlines();
    my @git_stderr  = $git_cmd->stderr->getlines();
    $git_cmd->close;

    print join(' ',@git_cmdline),"\n" if $self->verbose;

    return $git_cmd->exit() ? 0:1;
}

sub reference_exists
{
    my($self) = @_;
    return $self->_is_repository_location_exists($self->reference_location);
}

sub warehouse_exists
{
    my($self) = @_;
    return $self->_is_repository_location_exists($self->warehouse_location);
}

sub list_version_branches
{
    my($self) = @_;
    my @version_branches = ();

    my @all_branches = $self->_temp_repository->git_instance->run('branch' => '-a');

    for my $branch (sort @all_branches)
    {
        $branch =~ s/^\s+//;
        next unless $branch =~ /^remotes\/origin\/[\w,\.]+$/;
        next if $branch =~ /master/; 
        push @version_branches, $branch;
    }

    return @version_branches;
}

sub clone_to_warehouse
{
    my($self) = @_;

    return 0 unless $self->reference_exists;
    return 0 if $self->warehouse_exists;

    $self->_git_command( clone => ('--bare', '--no-hardlinks', $self->reference_location, $self->warehouse_location) );

    return $self->warehouse_exists;
}

sub backup_to_warehouse
{
    my($self) = @_;

    return 0 unless $self->reference_exists;
    return 0 unless $self->warehouse_exists;

    # remote add warehouse
    $self->_git_command(remote => ('add','warehouse',$self->warehouse_location));

    # fetch all
    $self->_git_command(fetch => '--all');

    # update version branches
    for my $version_branch ($self->list_version_branches)
    {
	$self->_git_command(checkout => ('--track', $version_branch));
	$self->_git_command(push => 'warehouse');
    }
    # update master 
    $self->_git_command(checkout => 'master');
    $self->_git_command(push => 'warehouse');

    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
