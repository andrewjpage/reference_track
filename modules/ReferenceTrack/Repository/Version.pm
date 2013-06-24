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
  my $major_version = 0;
  my $minor_version = 0; 

  if($self->version_number =~/^[\d]+\.([\d]+)$/)
  {
    $minor_version = $1;
  }
  if($self->version_number =~/^([\d]+)(\.[\d]+)?$/)
  {
    $major_version = $1;
  }

  return sprintf("%d.%d", $major_version, $minor_version +1);
}

sub next_major_version
{
  my($self) = @_;
  
  return sprintf("%d.%d", int($self->version_number) +1, 1); # New version for the reference, and we say that this annotation is version 1 for this new reference
}

sub version_regex
{
  my($class) = @_;
  return '[\d]+(\.[\d]+)?';
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;