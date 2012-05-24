=head1 NAME

Repositories - Represents a collection of Repositories

=head1 SYNOPSIS

use AnnotationTrack::Repositories;
my $repository = AnnotationTrack::Repositories->new(
  _dbh     => $dbh
  );
$repository->find_by_name('reponame');
$repository->find_all_by_name('reponame');
  
=cut

package AnnotationTrack::Repositories;
use Moose;
use AnnotationTrack::Schema;
use Scalar::Util;

has '_dbh'                         => ( is => 'rw', required   => 1 );

sub _find_all_by_name_result_set
{
  my ($self,$query) = @_;
  return if Scalar::Util::tainted($query); 
  $self->_dbh->resultset('Repositories')->search({ name => { -like => '%'.$query.'%' } });
}

sub find_all_by_name
{
  my ($self,$query) = @_;
  my @all_results = $self->_find_all_by_name_result_set($query)->all();
  return  \@all_results ;
}

sub find_by_name
{
   my ($self,$query) = @_;
   $self->_find_all_by_name_result_set($query)->first;
}
no Moose;
__PACKAGE__->meta->make_immutable;
1;