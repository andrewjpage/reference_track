=head1 NAME

Database - Handles setting up database connections

=head1 SYNOPSIS

use ReferenceTrack::Database;
my $database = ReferenceTrack::Database->new(
  database_settings     => \%databasesettings
);
$database->dbh;
=cut

package ReferenceTrack::Database;
use Moose;

has 'ro_dbh'             => ( is => 'rw',                      lazy => 1, builder => '_build_ro_dbh');
has 'rw_dbh'             => ( is => 'rw',                      lazy => 1, builder => '_build_rw_dbh');
has 'database_settings'           => ( is => 'rw', isa => 'HashRef');

sub _create_dbh
{
  my($self, $username) = @_;
  my $password;
  my %database_settings = %{$self->database_settings};
  if($username eq "rw_user")
  {
    $password = $database_settings{password};
  }
 
  my $dbh = ReferenceTrack::Schema->connect(
    "DBI:mysql:host=$database_settings{host}:port=$database_settings{port};database=$database_settings{database}", 
    $database_settings{$username}, $password, {'RaiseError' => 1, 'PrintError'=>0});
  return $dbh;
}

sub _build_ro_dbh
{
  my($self) = @_;
  return $self->_create_dbh("ro_user");
}

sub _build_rw_dbh
{
  my($self) = @_;
  return $self->_create_dbh("rw_user");
}
no Moose;
__PACKAGE__->meta->make_immutable;
1;
