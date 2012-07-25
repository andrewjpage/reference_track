=head1 NAME

Warehouse - wrapper for cloning and updating a backup repository.

Used together with the repository search.
Creates repositories if not already on disk. 


=head1 SYNOPSYS

use ReferenceTrack::Repository::Search;
use ReferenceTrack::Repository::Warehouse;

# Search with empty query string returns all repositories;
my $repository_search = ReferenceTrack::Repository::Search->new( database_settings => \%database_settings,
								 query             => '' );

my $warehouse_backup = ReferenceTrack::Repository::Warehouse->new( repository_search_results = $repository_search, 
                                                                   warehouse_directory = $my_warehouse_directory );

$warehouse_backup = backup_repositories_to_warehouse;

=cut

package ReferenceTrack::Repository::Warehouse;
use Moose;
use ReferenceTrack::Repository::Git::Warehouse;

has 'repository_search_results' => ( is => 'ro', isa => 'ReferenceTrack::Repository::Search',  required   => 1 );
has 'warehouse_directory'       => ( is => 'ro', isa => 'Str',  required   => 1 );
has 'verbose'                   => ( is => 'ro', isa => 'Bool', required => 0, default => 0 ); # verbose flag
has '_repository_name_location' => ( is => 'ro', isa => 'Maybe[ArrayRef]', lazy => 1, builder => '_build__repository_name_location');

sub _build__repository_name_location
{
    my($self) = @_;
    return unless(defined($self->repository_search_results->_repository_query_results));
    my @repositories;

    print "References:\n" if $self->verbose;
    for my $repository_row (@{$self->repository_search_results->_repository_query_results})
    {
	# set name from database name.
	my $name = $repository_row->name;
	$name =~ s/\W/_/g;
	$name .= '.git';
	push(@repositories,[$name, $repository_row->location]);
	print " - ",$repository_row->name,"\n" if $self->verbose;
    }

    return \@repositories;
}

sub backup_repositories_to_warehouse
{
    my($self) = @_;

    my $start_time = localtime();
    for my $ref_data (@{$self->_repository_name_location})
    {
	my $warehouse_repo = $self->warehouse_directory.'/'.$ref_data->[0];
	my $reference_repo = $ref_data->[1];

	print "Repository: $reference_repo\n" if $self->verbose;

	my $warehouse_back = ReferenceTrack::Repository::Git::Warehouse->new( reference_location => $reference_repo,
									      warehouse_location => $warehouse_repo,
									      verbose            => $self->verbose );

	$warehouse_back->warehouse_exists ? $warehouse_back->backup_to_warehouse : $warehouse_back->clone_to_warehouse ;
    }
    my $end_time = localtime();

    print " Started : $start_time\n Ended   : $end_time\n" if $self->verbose;
    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
