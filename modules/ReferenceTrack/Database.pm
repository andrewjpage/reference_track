=head1 NAME

Database - Handles setting up database connections

=head1 SYNOPSIS

use ReferenceTrack::Database;
my $database = ReferenceTrack::Database->new(
  environment     => 'test'
);
$database->dbh;
=cut

package ReferenceTrack::Database;
use Moose;
use ReferenceTrack::ConfigSettings;

has 'ro_dbh'             => ( is => 'rw',                      lazy => 1, builder => '_build_ro_dbh');
has 'rw_dbh'             => ( is => 'rw',                      lazy => 1, builder => '_build_rw_dbh');
has 'environment'        => ( is => 'rw', isa => 'Str',        default    => 'production');
has 'password_required'  => ( is => 'rw', isa => 'Bool',       default    => 0);

has '_password'          => ( is => 'rw', isa => 'Maybe[Str]', lazy => 1, builder => '_build__password');
has '_database_settings' => ( is => 'rw', isa => 'HashRef',    lazy => 1, builder => '_build__database_settings');

sub _build__password
{
  my($self) = @_;
  return undef if($self->password_required == 0);
  return $ENV{VRTRACK_PASSWORD} || $self->_database_settings->{reference_track}{password};
}

sub _build__database_settings
{
  my($self) = @_;
  ReferenceTrack::ConfigSettings->new(environment => $self->environment, filename => 'database.yml')->settings();
}

sub _create_dbh
{
  my($self, $username) = @_;
  my %database_settings = %{$self->_database_settings};
 
  my $dbh = ReferenceTrack::Schema->connect(
    "DBI:mysql:host=$database_settings{reference_track}{host}:port=$database_settings{reference_track}{port};database=$database_settings{reference_track}{database}", 
    $database_settings{reference_track}{$username}, $self->_password, {'RaiseError' => 1, 'PrintError'=>0});
  return $dbh;
}

sub _build_ro_dbh
{
  my($self) = @_;
  return $self->_create_dbh("ro_user");;
}

sub _build_rw_dbh
{
  my($self) = @_;
  return $self->_create_dbh("rw_user");;
}
no Moose;
__PACKAGE__->meta->make_immutable;
1;
