#!/usr/bin/env perl

=head1 NAME

reference_track_backup.pl

=head1 SYNOPSIS

reference_track_backup.pl -d database_name [-w warehouse_directory] [-r repo_name] [-v]

=head1 DESCRIPTION

This script backs-up the repositories in the reference tracking database.

=head1 CONTACT

path-help@sanger.ac.uk

=head1 METHODS

=cut

BEGIN { unshift(@INC, './modules') }
use strict;
use warnings;
use Getopt::Long;
use ReferenceTrack::Repository::Search;
use ReferenceTrack::Repository::Warehouse;

# usage info
my $usage = qq[
Usage: $0
     -database|d        <database name> (Required)
     -warehouse|w       <warehouse directory>
     -reference|r       <reference name>
     -verbose|v         <verbose>
     -h|help            <print this message>

A program for backup of reference repositories from a reference-tracking
database to a warehouse disk.

If the warehouse option is not supplied then the repositories will be 
backed-up to a default location.

All repositories backed-up by default however, the reference option can 
be used to select the reposories to backup:
 reference_track_backup.pl -d my_ref_db -r Staphylococcus_aureus

];

# options
my($database,$reference,$warehouse,$verbose,$help);

GetOptions ( 'database|d=s'  => \$database,  # database name (required)
	     'warehouse|w:s' => \$warehouse, # warehouse directory
	     'reference|r:s' => \$reference, # query term
	     'verbose|v'     => \$verbose,   # verbose flag
	     'help|h'        => \$help );

if($help)
{
    print $usage;
    exit;
}

( $database ) or die("Error: A database name must be supplied\n".$usage);

$warehouse ||= '/warehouse/pathogen_wh03/references'; # default location
-d $warehouse or die("Error: -warehouse must be a directory.\n".$usage); 
-w $warehouse or die("Error: -warehouse must be writable.\n".$usage);

$reference ||= ''; # empty string finds all reference repositories

$verbose = defined $verbose ? 1:0;

# database settings
my %database_settings;
$database_settings{database} = $database ;
$database_settings{host} = $ENV{VRTRACK_HOST} || 'mcs6';
$database_settings{port} = $ENV{VRTRACK_PORT} || 3347;
$database_settings{ro_user} = $ENV{VRTRACK_RO_USER}  || 'pathpipe_ro';
$database_settings{rw_user} =  $ENV{VRTRACK_RW_USER} || 'pathpipe_rw';
$database_settings{password} = $ENV{VRTRACK_PASSWORD};


# repository search
my $repository_search = ReferenceTrack::Repository::Search->new( database_settings => \%database_settings,
								 query             => $reference );

# update references
my $warehouse_backup = ReferenceTrack::Repository::Warehouse->new( repository_search_results => $repository_search,
								   warehouse_directory       => $warehouse,
								   verbose                   => $verbose );
$warehouse_backup->backup_repositories_to_warehouse;

exit;
