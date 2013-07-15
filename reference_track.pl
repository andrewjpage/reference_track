#!/usr/bin/env perl

=head1 NAME

reference_track.pl

=head1 SYNOPSIS

reference_track.pl [-e (staging|production) ] -q repo_name

=head1 DESCRIPTION

This script allows you to query the reference tracking database.

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

my ($database, $query, $clone);

GetOptions ('database|d=s'    => \$database,
            'query|q=s'          => \$query,
            'clone|c'          => \$clone
);

$query or die <<USAGE;
Usage: $0 [options]
Query the reference tracking system

reference_track.pl -c -q repo_name

 Options:
     -q  The name of the repository to look up. It performs a wildcard search '%repo_name%'
     -c  Take a copy of the repository and put it in the current directory

USAGE
;

$database ||= 'pathogen_reference_track';
my %database_settings;
$database_settings{database} = $database ;
$database_settings{host} = $ENV{VRTRACK_HOST} || 'mcs6';
$database_settings{port} = $ENV{VRTRACK_PORT} || 3347;
$database_settings{ro_user} = $ENV{VRTRACK_RO_USER}  || 'pathpipe_ro';
$database_settings{rw_user} =  $ENV{VRTRACK_RW_USER} || 'pathpipe_rw';
$database_settings{password} = $ENV{VRTRACK_PASSWORD};


my $repository_search = ReferenceTrack::Repository::Search->new(
  database_settings => \%database_settings,
  query             => $query,
  );
$repository_search->print_report();

# Clone the repository and copy over the git hook file
if($clone)
{
  ReferenceTrack::Repository::Clone->new(
    repository_search_results => $repository_search
  )->clone();
  
}
