=head1 NAME

Management - A driver class for managment functions

=head1 SYNOPSIS

use AnnotationTrack::Management;
my $repo_management = AnnotationTrack::Management->new(
  environment  => 'test',
  );
$repo_management->add("name", "repo");
=cut

package AnnotationTrack::Repository::Management;
use Moose;
use AnnotationTrack::Repository;
use AnnotationTrack::Repository::Exceptions;
extends 'AnnotationTrack::Repository::Common';

sub add
{
  my($self, $name, $repository_uri) = @_;
  my $repository = AnnotationTrack::Repository->new(
    _dbh     => $self->_rw_dbh,
    name     => $name,
    location => $repository_uri
    );
  AnnotationTrack::Repository::Exceptions::NameExists->throw(error => $name." exists in the database already" ) if( $repository->name_exists );
  $repository->create();
}


1;