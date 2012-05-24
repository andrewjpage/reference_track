=head1 NAME

Management - A driver class for managment functions

=head1 SYNOPSIS

use ReferenceTrack::Management;
my $repo_management = ReferenceTrack::Management->new(
  environment  => 'test',
  );
$repo_management->add("name", "repo");
=cut

package ReferenceTrack::Repository::Management;
use Moose;
use ReferenceTrack::Repository;
use ReferenceTrack::Repository::Exceptions;
use ReferenceTrack::Repository::Name;
use ReferenceTrack::Repository::Version;
extends 'ReferenceTrack::Repository::Common';

sub add
{
  my($self, $name, $repository_uri) = @_;
  my $repository = ReferenceTrack::Repository->new(
    _dbh     => $self->_rw_dbh,
    name     => $name,
    location => $repository_uri
    );
  ReferenceTrack::Repository::Exceptions::NameExists->throw(error => $name." exists in the database already" ) if( $repository->name_exists );
  $repository->create();
}

sub create
{
  my($self, $genus, $subspecies, $strain, $starting_version) = @_;
  # validate the input parameters
  # check it doesnt exist already
  # create a new repository on disk
  # add to the tracking database
 
  my $repository_name_obj = ReferenceTrack::Repository::Name->new(
    genus      => $genus,
    subspecies => $subspecies,
    strain     => $strain
   );
  $repository_name_obj->repository_name();
 
  # validate the version number passed in
  my $repository_version = ReferenceTrack::Repository::Version->new(version_number => $starting_version)->version_number();

}

no Moose;
__PACKAGE__->meta->make_immutable;
1;