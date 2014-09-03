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
use File::Slurp;

my ($database, $query, $clone, $add, $message, $major, $update, $list, $help);

GetOptions ('database|d=s'    => \$database, # Only exposed to developers for testing
            'query|q=s'       => \$query,
            'clone|c'         => \$clone,
            'add|a'	      => \$add,
            'message|m=s'     => \$message,
            'major'	      => \$major,
            'update|u'	      => \$update,
            'list|l'	      => \$list,
            'help|h'	      => \$help,
);

# Some validation of user arguments
if ($help || ((!$clone and !$add and !$update and !$list))) {
	_print_usage_and_die();
}


$database ||= 'pathogen_reference_track';
my %database_settings;
my $connection_details = read_file('/software/pathogen/config/reftrack_connection_details');
%database_settings = %{ eval($connection_details) };
$database_settings{database} = $database ;

# Clone the repository (and copy over the git hook file)
if($clone)
{
	if(not defined($query)) {
		print "No query (repository name) specified to copy. \n";
		_print_usage_and_die();
	}

	my $repository_search = ReferenceTrack::Repository::Search->new(
  		database_settings => \%database_settings,
  		query             => $query,
  	);
	$repository_search->print_report();

  	ReferenceTrack::Repository::Clone->new(
    	repository_search_results => $repository_search
  	)->clone();  
}

# Run the git add/rm and git commit commands
if($add)
{

	if(not defined($message)){
                print "No message (-m) specified to describe the changes made. \n";
		_print_usage_and_die();
        }

	# Add any new or modified files, remove deleted files
	`git add -u`; # Does not add new files, so we have to do the git add below
	`git add .`;
	
	if($major){
		$message = 'MAJOR:'.$message;
	}

	# Run git commit
	`git commit -m "$message"`;
	#TODO: Parse the commit message and display a user friendly message to the user 
	
	# Git push
	`git push origin master`;
}

# Run git fetch and git pull 
if($update)
{
	my $git_fetch = `git fetch --all`;
	my $git_pull = `git pull origin master`;
	# TODO: Parse error messages
}

# List all available repositories
if($list){
	my $reference_database = ReferenceTrack::Database->new(
  		database_settings     => \%database_settings,
	);

	my $repository = ReferenceTrack::Repositories->new(
  		_dbh     => $reference_database->ro_dbh,
	);
	
	my $organism_names = $repository->find_all_names();
  	print "Available repositories: \n";
  	print join ("\n", sort(@$organism_names));
  	print "\n";
}

sub _print_usage_and_die {

die <<USAGE; 
Usage: $0 [options]

Clone, commit to or update a repository, or list all available repositories

 Options:
     -q  	The name of the repository to look up. It performs a wildcard search '%repo_name%'
     -c  	Take a copy of the repository and put it in the current directory
     -a  	Add my changes to the system. You must also enter a short message about the changes using the -m option
     -m  	Short description about the changes made to the file
     -major	Can be used with the -a option to indicate a major change
     -u		Update my files with any changes other people may have made to it
     -l		List all available repositories
     -h		Help

USAGE
;

}
