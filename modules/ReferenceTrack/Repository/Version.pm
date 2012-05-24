=head1 NAME

Version - Generates a version number and checks that the input version is valid

=head1 SYNOPSIS

use ReferenceTrack::Repository::Version;
my $repository = ReferenceTrack::Repository::Version->new(
  version_number => "0.3"
  );
$repository->version_number();

=cut

package ReferenceTrack::Repository::Version;
use Moose;
use ReferenceTrack::Repository::Validate::Version;
use ReferenceTrack::Repository::Types;

has 'version_number' => ( is => 'ro', isa => 'ReferenceTrack::Repository::Version::Number',  required => 1);

sub next_version
{
  my($self) = @_;
  
  if($self->version_number  < 1)
  {
    my $decimal_part = $self->version_number;
    $decimal_part =~ s/0\.//;
    return sprintf("0.%d", $decimal_part +1);
  }
  else
  {
    # whole number
    return sprintf("%d", int($self->version_number) +1);
  }
  
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;