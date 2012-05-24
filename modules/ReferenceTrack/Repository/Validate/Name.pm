=head1 NAME

Name - Validates the variables that make up a repository name

=head1 SYNOPSIS

use ReferenceTrack::Repository::Name;
my $repository = ReferenceTrack::Repository::Validate::Name->new(
  genus => 'ABC',
  sub-species => 'EFG',
  strain   => 'HIJ'
  );
  
=cut

package ReferenceTrack::Repository::Validate::Name;
use Moose;


sub is_genus_valid
{
  my($self, $input_string) = @_;
  return 0 if( $input_string =~ /[\W]/ || length($input_string) <= 2 || ucfirst(lc($input_string)) ne $input_string);
  
  return 1;
}
  
sub is_subspecies_valid
{
  my($self, $input_string) = @_;
  return 0 if( $input_string =~ /[\W]/|| length($input_string) <= 2 || lc($input_string) ne $input_string);
  return 1;
}

sub is_strain_valid
{
  my($self, $input_string) = @_;
  return 0 if( $input_string =~ /[\W]/ || length($input_string) <= 1 || lc($input_string) ne $input_string);
  
  return 1;
}



no Moose;
__PACKAGE__->meta->make_immutable;
1;