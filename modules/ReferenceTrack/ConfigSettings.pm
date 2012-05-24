=head1 NAME

ConfigSettings.pm   - Return configuration settings

=head1 SYNOPSIS

use ReferenceTrack::ConfigSettings;
my %config_settings = %{ReferenceTrack::ConfigSettings->new(environment => 'test')->settings()};

=cut

package ReferenceTrack::ConfigSettings;

use Moose;
use File::Slurp;
use YAML::XS;

has 'environment' => (is => 'rw', isa => 'Str', default => 'test');
has 'filename' => ( is => 'rw', isa => 'Str', default => 'config.yml' );
has 'settings' => ( is => 'rw', isa => 'HashRef', lazy => 1, builder => '_build_settings' );


sub _build_settings 
{
  my $self = shift;
  my %config_settings = %{ Load( scalar read_file("config/".$self->environment."/".$self->filename.""))};

  return \%config_settings;
} 
no Moose;
__PACKAGE__->meta->make_immutable;
1;
