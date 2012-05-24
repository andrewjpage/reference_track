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

no Moose;
__PACKAGE__->meta->make_immutable;
1;