=head1 NAME

Version - Validates the version

=head1 SYNOPSIS

use ReferenceTrack::Repository::Version;
my $repository = ReferenceTrack::Repository::Validate::Version->new(
  genus => 'ABC',
  sub-species => 'EFG',
  strain   => 'HIJ'
  );
  
=cut

package ReferenceTrack::Repository::Validate::Version;
use Moose;
use Scalar::Util qw(looks_like_number);

sub is_valid
{
  my($self, $input_version) = @_;
  return 1 if(looks_like_number($input_version) && $input_version > 0);
  
  return 0;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;