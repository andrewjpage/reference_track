#!/usr/bin/env perl
package ReferenceTrack::Bin::ValidateGFFFile;
# ABSTRACT: Given a GFF file, this script will run the GMOD GFF validator 
# PODNAME: validate_gff_file
=head1 SYNOPSIS

Given a gff file, this script will run the GMOD validator on it
Usage: validate_gff_file [options]
	
		-f|file        		   <gff file>
		-p|prefix	   		   <prefix for output files>
		-c|config	           <a config file with SQLite details. A default file for pathogens exists>
        -o|output_directory	   <directory to place output file. Default current working directory>
        -e|validator_exec	   <path to the validator perl script. Default to pathogen installation>
        -d|debug			   <debug>
        -h|help      		   <this message>
        
Takes a GFF file and runs the GMOD GFF validator. 
# The errors are reported in a file prefix.report in the output directory specified 
validate_gff_file -f myfile.gff3 -p Pf3D7 -c config.cfg -o /path/..

   
=cut

BEGIN { unshift( @INC, '../lib' ) }
use lib "/software/pathogen/internal/prod/lib";
use Moose;
use Getopt::Long;
use Cwd;
use Cwd 'abs_path';
use File::Path qw(make_path);

use ReferenceTrack::Repository::Validate::GFFValidator;

my ( $gff_file, $prefix, $output_directory, $config_file, $validator_exec, $debug, $help );

GetOptions(
		'f|file=s'      		=> \$gff_file,
		'p|prefix=s'      		=> \$prefix,
		'c|config=s'		    => \$config_file,
		'o|output_directory=s'	=> \$output_directory,
		'e|validator_exec=s'	=> \$validator_exec,
    	'd|debug'               => \$debug,
    	'h|help'                => \$help,
);

# A gff file is essential. The rest of the arguments can be set of defaults.
( defined($gff_file) && !$help )
  or die <<USAGE;
Usage: validate_gff_file [options]
	
		-f|file        		   <gff file>
		-p|prefix	   		   <prefix for output files>
		-c|config	           <a config file with SQLite details. A default file for pathogens exists>
        -o|output_directory	   <directory to place output file. Default current working directory>
        -e|validator_exec	   <path to the validator perl script. Default to pathogen installation>
        -d|debug			   <debug>
        -h|help      		   <this message>
        
Takes a GFF file and runs the GMOD GFF validator. 

# The errors are reported in a file prefix.report in the output directory specified 
validate_gff_file -f myfile.gff3 -p Pf3D7 -c config.cfg -o /path/..

USAGE

# Set defaults
$prefix ||= "prefix";
$config_file ||= "/nfs/users/nfs_n/nds/Git_projects/gff3_validator/validate_gff3_nds_sqlite.cfg";
$output_directory ||= getcwd();
$output_directory  = abs_path($output_directory);
make_path($output_directory);
$validator_exec ||= '/nfs/users/nfs_n/nds/Git_projects/gff3_validator/validate_gff3.pl'; 
$debug          ||= 0;

has 'file' 			   => ( is => 'ro', isa => 'Str', required => 1);
has 'prefix'    	   => ( is => 'ro', isa => 'String', default => 'validation'); #Change to something with date and time
has 'config'    	   => ( is => 'ro', isa => 'Str', required => 1); #Configuration file 
has 'output_directory' => ( is => 'ro', isa => 'Str' , builder => '_build_output_directory'); #Default to current working directory
has 'validator_exec'   => ( is => 'ro', isa => 'Str', required => 1 );
has 'debug'	           => ( is => 'ro', isa => 'Bool', default  => 0);


my $validator = ReferenceTrack::Repository::Validate::GFFValidator->new(
    file       	  		=> $gff_file,  
	prefix	 	 		=> $prefix,
	config	 	  		=> $config_file,
    output_directory 	=> $output_directory,
 	validator_exec		=> $validator_exec,
    debug            	=> $debug,
)->run();
