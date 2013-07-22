=head1 GFFValidator

GFFValidator - Wrapper around the GMOD GFF validator, and should also eventually include any extra GFF checks 

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
has 'error_free_line'  => ( is => 'ro', isa => 'Str', default => "NO ERRORS OR WARNINGS HAVE BEEN ISSUED" ); #The line to look for in the error report to indicate that the GFF file was error free
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
 
 #There is also a log file produced which we shall delete
 my $log_file_name = $self->prefix.'.log';
 unlink ($self->output_directory."/".$log_file_name);

 return $self;

}

sub _build_output_directory{
  my ($self) = @_;
  return getcwd();
}


# Only return a value if there are errors in the report. If not, delete the report and return null
sub final_error_report {
	my ($self) = @_;
	my $error_report_name = $self->output_directory."/".$self->prefix.'.report';
	my $no_errors = `grep \"$self->error_free_line\" $error_report_name`;
	if($no_errors){
		unlink ($error_report_name);
		return;
	}
	return $error_report_name;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
