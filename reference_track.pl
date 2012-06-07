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

my ($ENVIRONMENT, $query);

GetOptions ('environment|e=s'    => \$ENVIRONMENT,
            'query|q=s'          => \$query
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

$ENVIRONMENT ||= 'production';

my $repository_search = ReferenceTrack::Repository::Search->new(
  environment     => $ENVIRONMENT,
  query           => $query,
  );
$repository_search->print_report();

if($clone)
{
  ReferenceTrack::Repository::Clone->new(
    repository_search_results => $repository_search
  )->clone();
}
