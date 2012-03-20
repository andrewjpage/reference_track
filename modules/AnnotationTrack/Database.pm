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

has 'dbh'          => ( is => 'rw', lazy_build => 1);
has 'environment'  => ( is => 'rw', isa => 'Str', default => 'production');

sub _build_dbh
{
  my($self) = @_;
  my %database_settings = %{AnnotationTrack::ConfigSettings->new(environment => $self->environment, filename => 'database.yml')->settings()};
  my $database_password = $ENV{VRTRACK_PASSWORD} || $database_settings{annotation_track}{password};
  
  my $dbh = AnnotationTrack::Schema->connect(
    "DBI:mysql:host=$database_settings{annotation_track}{host}:port=$database_settings{annotation_track}{port};database=$database_settings{annotation_track}{database}", 
    $database_settings{annotation_track}{user}, $database_password, {'RaiseError' => 1, 'PrintError'=>0});
  return $dbh;
}
1;
