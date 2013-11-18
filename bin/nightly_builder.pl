#!/usr/bin/env perl
package ReferenceTrack::Bin::NightlyBuilder;
# ABSTRACT: Run a set of procedures on all the repositories 
# PODNAME: nightly_builder
=head1 SYNOPSIS

** NOW REDUNDANT AS WE HAVE OUR OWN VALIDATOR THAT IS RUN ON COMMIT (18 Nov 2013)
perl bin/nightly_builder.pl --database=pathogen_reference_track

   
=cut

BEGIN { unshift( @INC, '../lib' ) }
#use lib "/software/pathogen/internal/prod/lib";
use Moose;
use Getopt::Long;
use Cwd;
use Cwd 'abs_path';
use File::Path qw(make_path);


use ReferenceTrack::Repository::Validate::GFFValidator;
use ReferenceTrack::Repositories;
use ReferenceTrack::Database;
use ReferenceTrack::Repository::Search;
use ReferenceTrack::Repository::Clone;
use ReferenceTrack::Repository::Validate::GFFValidator;
use ReferenceTrack::Repository::Git::Instance;
use ReferenceTrack::Repository::Git::Log;
use ReferenceTrack::EmailSender;


my ($database, $directory, $help);

GetOptions ('database|d=s'    => \$database,
            'directory|l=s'   => \$directory,
            'h|help'          => \$help,            
);

( defined($database) && !$help ) or die <<USAGE;
Usage: nightly_builder [options]
	
		-d|database        	   <name of repositories meta data database (required)>
		-l|directory	   	   <a temporary directory in which to work. Default to current working directory>
        -h|help      		   <this message>

USAGE

$directory ||= getcwd();
$directory  = abs_path($directory);
make_path($directory);

chdir( $directory ); # Change to desired directory. MIght eventually just use a temp directory

# database settings
my %database_settings;
$database_settings{database} = $database ;
$database_settings{host} = $ENV{VRTRACK_HOST} || 'mcs6';
$database_settings{port} = $ENV{VRTRACK_PORT} || 3347;
$database_settings{ro_user} = $ENV{VRTRACK_RO_USER}  || 'pathpipe_ro';
$database_settings{rw_user} =  $ENV{VRTRACK_RW_USER} || 'pathpipe_rw';
$database_settings{password} = $ENV{VRTRACK_PASSWORD};


my $reference_database = ReferenceTrack::Database->new(
  database_settings     => \%database_settings,
);

my $repository = ReferenceTrack::Repositories->new(
  _dbh     => $reference_database->ro_dbh,
);
  

  
# Get a list of all the organism names. 
# For each, clone the repository and validate the data.
# Send validation reports to relevant users.
# At the end, delete all the cloned repositories

my $organism_names = $repository->find_all_names();
foreach my $name (@$organism_names){
	print "Working with repository: $name \n";
	chdir( $directory ); # Change to desired directory

	my $repository_search = ReferenceTrack::Repository::Search->new(
  		database_settings => \%database_settings,
  		query             => $name,
  	);
  	

  	for my $repository_row (@{$repository_search->_repository_query_results}) {

  		my $git_instance  = ReferenceTrack::Repository::Git::Instance->new(location => $repository_row->location); 
  		# print "Getting commits \n";
  		my $logger = ReferenceTrack::Repository::Git::Log->new(
  				reference_location => $repository_row->location,
  				since => '2.weeks', 	# Change to suitable time frame
  			);  	
  			
  		my $commits = $logger->get_commit_authors(); #All the users who made changes to this repository 
  		

  		my @files = $git_instance->git_instance->run('ls-files'); #Get all the files in this repository
  		
		foreach my $file (@files){
			print "Found $file \n";
			if($file !~ /gff$/){ #Does not yet handle zipped gff files
				next; 		
			}
			print "Working with $file \n";
			my $file_with_path = $git_instance->_working_directory."/".$file;

			#Generate suitable prefix
			my($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
			my $prefix = join("_", $file, $dayOfMonth, $month+1, $yearOffset+1900); #Changed to be the GFF filename, so that it can accommodate multiple GFF files for an organism
  			$prefix =~ s/\W/_/g;
  			
  			my $validator = ReferenceTrack::Repository::Validate::GFFValidator->new(
                    file   				=> $file_with_path,  
					prefix	 	 		=> $prefix,
					config	 	  		=> '/nfs/users/nfs_n/nds/Git_projects/gff3_validator/validate_gff3_nds_sqlite.cfg',
					output_directory	=> $directory,
					validator_exec		=> '/nfs/users/nfs_n/nds/Git_projects/gff3_validator/validate_gff3.pl',
			)->run();

			# Email if there are errors
			if($validator->final_error_report){
  				foreach my $email_address (keys %$commits){ # If there are no commits in the specified time frame, no emails will be sent. TODO: Should an email be sent to 
    				my $email_sender = ReferenceTrack::EmailSender->new(
      					email_from_address  => 'pathdev@sanger.ac.uk',
      					email_to_address    => $email_address,
      					user_name			=> $$commits{$email_address},
      					error_file			=> $validator->final_error_report,
      					organism			=> $name,
      				);
      				$email_sender->send_email; 
				}
			}
			
			
		}

  		
  	}
}
  	


