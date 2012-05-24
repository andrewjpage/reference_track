package ReferenceTrack::Repository::Common;
use Moose;
use ReferenceTrack::Database;

has 'environment' => ( is => 'rw', isa => 'Str',   required   => 1 );                         
has '_ro_dbh'     => ( is => 'rw',                 lazy => 1, builder => '_build__ro_dbh' );
has '_rw_dbh'     => ( is => 'rw',                 lazy => 1, builder => '_build__rw_dbh' );

sub _build__ro_dbh
{
  my($self)= @_; 
  ReferenceTrack::Database->new( environment => $self->environment, password_required => 0)->ro_dbh;
}

sub _build__rw_dbh
{
  my($self)= @_; 
  ReferenceTrack::Database->new( environment => $self->environment)->rw_dbh;
}
no Moose;
__PACKAGE__->meta->make_immutable;
1;