=head1 NAME

Repository - Represents a repository data

=head1 SYNOPSIS

use AnnotationTrack::Repository;
my $repository = AnnotationTrack::Repository->new(
  _dbh     => $dbh,
  name     => "repo name",
  location => "some_location.git"
  );
$repository->create();
  
=cut

package AnnotationTrack::Repository;
use Moose;
use AnnotationTrack::Schema;

has '_dbh'        => ( is => 'rw', required   => 1 );
has 'name'        => ( is => 'rw', isa => 'Str', required   => 1 );
has 'location'    => ( is => 'rw', isa => 'Str', required   => 1 );

sub create
{
  my ($self) = @_;
  $self->_dbh->resultset('Repositories')->create({  name => $self->name, location => $self->location });
}

1;