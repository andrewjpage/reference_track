=head1 NAME

Management - A driver class for managment functions

=head1 SYNOPSIS

use ReferenceTrack::Management;
my $repo_management = ReferenceTrack::Management->new(
  database_settings     => \%databasesettings
  );
$repo_management->add("name", "repo");
=cut

package ReferenceTrack::Repository::Management;
use Moose;
use ReferenceTrack::Repository;
use ReferenceTrack::Repository::Exceptions;
use ReferenceTrack::Repository::Name;
use ReferenceTrack::Repository::Version;
use ReferenceTrack::Repository::Git::Remote;
extends 'ReferenceTrack::Repository::Common';

has 'repository_root'  => ( is => 'ro', isa => 'Str', default => '/nfs/pathnfs02/references');


=head2 add

  Arg [1]    : name of repository
  Arg [2]    : location of the reposityr
  Arg [3]	 : the short name of the repository e.g. Pf3D7
  Example    : $repository_management->add($self->add_repository->[0], $self->add_repository->[1], $self->short_name);
  Description: Adds the details of a repository to the database containing meta data
  Returntype : 

=cut

sub add
{
  my($self, $name, $repository_uri, $short_name) = @_;
  my $repository = ReferenceTrack::Repository->new(
    _dbh     => $self->_rw_dbh,
    name     => $name,
    location => $repository_uri,
    short_name =>  $short_name
    );
  ReferenceTrack::Repository::Exceptions::NameExists->throw(error => $name." exists in the database already" ) if( $repository->name_exists );
  $repository->create();
}


=head2 create

  Arg [1]    : genus
  Arg [2]    : subspecies
  Arg [3]	 : strain
  Arg [4]	 : starting version
  Arg [5]	 : short name
  Example    : repository_management->create($self->creation_details->[0],$self->creation_details->[1],$self->creation_details->[2] ,$self->starting_version, $self->short_name);
  Description: create a new repository and add information to the database
  Returntype : 

=cut

sub create
{
  my($self, $genus, $subspecies, $strain, $starting_version, $short_name) = @_;
  
  # create a new repository on disk
 
  my $repository_name_obj = ReferenceTrack::Repository::Name->new(
    genus      => $genus,
    subspecies => $subspecies,
    strain     => $strain,
    short_name => $short_name
   );
  my $full_repository_path = $self->_full_repository_path($genus, $subspecies );
  my $repository_uri = $self->_repository_uri($full_repository_path, $repository_name_obj->repository_name());
  my $created_repository_row = $self->add($repository_name_obj->human_readable_name(), $repository_uri, $repository_name_obj->short_name());

  my $repository_version = ReferenceTrack::Repository::Version->new(version_number => $starting_version)->version_number();
  $created_repository_row->version_visibility->create({
    visible_on_ftp_site => 0, 
    version => $repository_version
    });
    
  ReferenceTrack::Repository::Git::Remote->new(
      root  => $full_repository_path,
      name => $repository_name_obj->repository_name(),
      starting_version => $starting_version,
      location => $repository_uri,
    )->create();

  print("Created reference repository: ".$repository_uri);

  return $created_repository_row;
}

sub _full_repository_path
{
  my($self, $genus, $subspecies) = @_;
  return join('/',($self->repository_root, $genus, $subspecies));
}

sub _repository_uri
{
  my($self,$full_repository_path, $repository_name) = @_;
  return 'file:////'.$full_repository_path.'/'. $repository_name;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;