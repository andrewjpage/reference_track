#!/usr/bin/env perl

=head1 NAME

reference_track.pl

=head1 SYNOPSIS

reference_track.pl -q repo_name

=head1 DESCRIPTION

This script allows you to create a clone of a repository, perform a git commit or a git pull.

=head1 CONTACT

path-help@sanger.ac.uk

=head1 METHODS

=cut
package ReferenceTrack;

BEGIN { unshift(@INC, './modules') }
use Moose;
use Getopt::Long;
use ReferenceTrack::Repository::Search;
use ReferenceTrack::Repository::Clone;

my ($database, $query, $clone, $add, $message, $major, $update, $help);

GetOptions ('database|d=s'    => \$database, # Only exposed to developers for testing
            'query|q=s'       => \$query,
            'clone|c'         => \$clone,
            'add|a'			  => \$add,
            'message|m=s'	      => \$message,
            'major'			  => \$major,
            'update|u'		  => \$update,
            'help|h'		  => \$help,
);


(($query && $clone) || ($add && $message) || !$help) or die <<USAGE;
Usage: $0 [options]

Clone, commit to or update a repository

 Options:
     -q  	The name of the repository to look up. It performs a wildcard search '%repo_name%'
     -c  	Take a copy of the repository and put it in the current directory
     -a  	Add my changes to the system. You must also enter a short message about the changes using the -m option
     -m  	Short description about the changes made to the file
     -major	Can be used with the -a option to indicate a major change
     -u		Update my files with any changes other people may have made to it
     -h		Help

USAGE
;

$database ||= 'pathogen_reference_track_test';
my %database_settings;
$database_settings{database} = $database ;
$database_settings{host} = $ENV{VRTRACK_HOST} || 'mcs6';
$database_settings{port} = $ENV{VRTRACK_PORT} || 3347;
$database_settings{ro_user} = $ENV{VRTRACK_RO_USER}  || 'pathpipe_ro';
$database_settings{rw_user} =  $ENV{VRTRACK_RW_USER} || 'pathpipe_rw';
$database_settings{password} = $ENV{VRTRACK_PASSWORD};

# Clone the repository (and copy over the git hook file)
if($clone)
{
	my $repository_search = ReferenceTrack::Repository::Search->new(
  		database_settings => \%database_settings,
  		query             => $query,
  	);
	$repository_search->print_report();

  	ReferenceTrack::Repository::Clone->new(
    	repository_search_results => $repository_search
  	)->clone();  
}

# Run the git add and git commit commands
if($add)
{
	my $git_add_output = `git add .`;
	if($major){
		$message = 'MAJOR:'.$message;
	}
	my $git_commit_output = `git commit -m "$message"`;
	# Parse git commit message (check...is this the message that needs to be parsed?)
	if($git_commit_output =~ m/error/g){
		print "There appears to be an error with adding your changes. Please contact path-help\@sanger.ac.uk with 
		       the error message. \n";
	
	}
	my $git_push = `git push origin master`;
}

# Run git fetch and git pull 
if($update)
{
	my $git_fetch = `git fetch --all`;
	my $git_pull = `git pull origin master`;
	# Parse error messages ?
}