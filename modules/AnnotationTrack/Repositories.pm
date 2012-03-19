=head1 NAME

Repositories - Represents a collection of Repositories

=head1 SYNOPSIS

use AnnotationTrack::Repository;
my $repository = AnnotationTrack::Repository->new(
  _dbh     => $dbh
  );
$repository->find_by_name('reponame');
$repository->find_all_by_name('reponame');
  
=cut

package AnnotationTrack::Repository;
use Moose;
use AnnotationTrack::Schema;

has '_dbh'        => ( is => 'rw', required   => 1 );

sub find_all_by_name
{
  my ($self,$query) = @_;
  $self->_dbh->resultset('Repositories')->search_like({ name => $self-> '%'.$query.'%' });
}

sub find_by_name
{
   my ($self,$query) = @_;
   $self->find_all_by_name($query)->first;
}

1;