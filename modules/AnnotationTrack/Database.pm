=head1 NAME

Database - Handles setting up database connections

=head1 SYNOPSIS

use AnnotationTrack::Database;
my $database = AnnotationTrack::Database->new(
  environment     => 'test'
);
$database->dbh;
=cut

package AnnotationTrack::Database;
use Moose;
use AnnotationTrack::ConfigSettings;

has 'dbh'                => ( is => 'rw',                      lazy_build => 1);
has 'environment'        => ( is => 'rw', isa => 'Str',        default    => 'production');
has 'password_required'  => ( is => 'rw', isa => 'Bool',       default    => 0);

has '_password'          => ( is => 'rw', isa => 'Maybe[Str]', lazy_build => 1);
has '_database_settings' => ( is => 'rw', isa => 'HashRef',    lazy_build => 1);

sub _build__password
{
  my($self) = @_;
  return undef if($self->password_required == 0);
  return $ENV{VRTRACK_PASSWORD} || $self->_database_settings->{annotation_track}{password};
}

sub _build__database_settings
{
  my($self) = @_;
  AnnotationTrack::ConfigSettings->new(environment => $self->environment, filename => 'database.yml')->settings();
}

sub _build_dbh
{
  my($self) = @_;
  my %database_settings = %{$self->_database_settings};
 
  my $dbh = AnnotationTrack::Schema->connect(
    "DBI:mysql:host=$database_settings{annotation_track}{host}:port=$database_settings{annotation_track}{port};database=$database_settings{annotation_track}{database}", 
    $database_settings{annotation_track}{user}, $self->_password, {'RaiseError' => 1, 'PrintError'=>0});
  return $dbh;
}
1;
