#!/usr/bin/env perl
package ReferenceTrack::Bin::NightlyBuilder;
# ABSTRACT: Run a set of procedures on all the repositories (validate to start with)
# PODNAME: nightly_builder
=head1 SYNOPSIS

   
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

chdir( $directory ); # Change to desired directory

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
	chdir( $directory ); # Change to desired directory
	# Clone 
	my $repository_search = ReferenceTrack::Repository::Search->new(
  		database_settings => \%database_settings,
  		query             => $name,
  	);
  	ReferenceTrack::Repository::Clone->new(
    	repository_search_results => $repository_search
  	)->clone();

	# Hacky so please re-write!
	$name =~ s/ /_/g;
	
	chdir($name);
	#Get the GFF files
	opendir my $dir, $directory.'/'.$name or die "Cannot open directory: $name $!";
	my @files = readdir $dir;
	closedir $dir;
	foreach my $file (@files){
		
		if($file !~ /gff3/){
			next;
		}
		print "Got $file \n";
		
		my $prefix = $file."_".localtime();
		my $validator = ReferenceTrack::Repository::Validate::GFFValidator->new(
                     file       	=> $directory."/".$name."/".$file,  
	prefix	 	 		=> $prefix,
	config	 	  		=> '/nfs/users/nfs_n/nds/Git_projects/gff3_validator/validate_gff3_nds_sqlite.cfg',
	output_directory	        => $directory,
	validator_exec		        => '/nfs/users/nfs_n/nds/Git_projects/gff3_validator/validate_gff3.pl',
	)->run();

	}
  	
}


