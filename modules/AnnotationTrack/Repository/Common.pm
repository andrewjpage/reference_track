package AnnotationTrack::Repository::Common;
use Moose;
use AnnotationTrack::Database;

has 'environment' => ( is => 'rw', isa => 'Str',   required   => 1 );                         
has '_ro_dbh'     => ( is => 'rw',                 lazy_build => 1 );
has '_rw_dbh'     => ( is => 'rw',                 lazy_build => 1 );

sub _build__ro_dbh
{
  my($self)= @_; 
  AnnotationTrack::Database->new( environment => $self->environment, password_required => 0)->ro_dbh;
}

sub _build__rw_dbh
{
  my($self)= @_; 
  AnnotationTrack::Database->new( environment => $self->environment)->rw_dbh;
}

1;