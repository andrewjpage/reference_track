=head1 GFFValidator

GFFValidator - Wrapper around the GMOD GFF validator, and also includes any extra checks

=head1 SYNOPSIS

use ReferenceTrack::Repository::Validate::GFFValidator;
ReferenceTrack::Repository::Validate::GFFValidator->new(
  )->run();
  
=cut

package ReferenceTrack::Repository::Validate::GFFValidator;
use Moose;

has 'file' 			   => ( is => 'ro', isa => 'Str', required => 1);
has 'prefix'    	   => ( is => 'ro', isa => 'Str', default => 'validation'); #Change to something with date and time
has 'config'    	   => ( is => 'ro', isa => 'Str', required => 1); #Configuration file 
has 'output_directory' => ( is => 'ro', isa => 'Str' , builder => '_build_output_directory'); #Default to current working directory
has 'validator_exec'   => ( is => 'ro', isa => 'Str', required => 1 );
has 'debug'	           => ( is => 'ro', isa => 'Bool', default  => 0);

=head2 run

  Arg [1]    : 
  Example    : 
  Description: Runs the validator
  Returntype : 

=cut

sub run
{

 my($self) = @_;
#perl validate_gff3.pl -gff3_file /my/file.gff3 -out prefix 
#–config myconfigfile.cfg

 chdir( $self->output_directory ); # Change to desired output directory

 my $stdout_of_program = '';
 $stdout_of_program =  "> /dev/null 2>&1"  if($self->debug == 0);

 system(
        join(
            ' ',
            (
                'perl', $self->validator_exec, 
                '-gff3_file', $self->file,
                '-out', $self->prefix,
                '-config', $self->config,
                $stdout_of_program
            )
        )
 );

return $self;

}

sub _build_output_directory{
  my ($self) = @_;
  return getcwd();
}



sub _final_error_report {
	my ($self) = @_;
	my $error_report_name = $self->prefix.'.report';
	return $self->output_directory."/".$error_report_name;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
