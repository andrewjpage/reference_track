#!/usr/bin/env perl
package ReferenceTrack::Bin::NightlyBuilder;
# ABSTRACT: Run a set of procedures on all the repositories (validate to start with)
# PODNAME: nightly_builder
=head1 SYNOPSIS


   
=cut

BEGIN { unshift( @INC, '../lib' ) }
use lib "/software/pathogen/internal/prod/lib";
use Moose;
use Getopt::Long;
use Cwd;
use Cwd 'abs_path';
use File::Path qw(make_path);

use ReferenceTrack::Repository::Validate::GFFValidator;
use ReferenceTrack::Repositories;
use ReferenceTrack::Database;


my ($database, $query, $clone);

GetOptions ('database|d=s'    => \$database,
            'directory|l=s'   => \$query,
            'h|help'          => \$help,            
);

if($help) die <<USAGE;
Usage: nightly_builder [options]
	
		-d|database        	   <name of repositories meta data database (required)>
		-l|directory	   	   <a temporary directory in which to work. Default to current working directory>
        -h|help      		   <this message>

USAGE

# database settings
my %database_settings;
$database_settings{database} = $database ;
$database_settings{host} = $ENV{VRTRACK_HOST} || 'mcs6';
$database_settings{port} = $ENV{VRTRACK_PORT} || 3347;
$database_settings{ro_user} = $ENV{VRTRACK_RO_USER}  || 'pathpipe_ro';
$database_settings{rw_user} =  $ENV{VRTRACK_RW_USER} || 'pathpipe_rw';
$database_settings{password} = $ENV{VRTRACK_PASSWORD};

my $database = ReferenceTrack::Database->new(
  database_settings     => \%databasesettings
);

my $repository = ReferenceTrack::Repositories->new(
  _dbh     => $database->ro_dbh;
  );
  
# Get a list of all the organism names. 
# For each, clone the repository and validate the data.
# Send validation reports to relevant users.
# At the end, delete all the cloned repositories

my $organism_names = $repository->find_all_names();
foreach my $name (@$organism_names){

	print $name, "\n";

}


