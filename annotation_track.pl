#!/usr/bin/env perl

=head1 NAME

annotation_track.pl

=head1 SYNOPSIS

annotation_track.pl [-e (staging|production) ] -q repo_name

=head1 DESCRIPTION

This script allows you to query the annotation tracking database.

=head1 CONTACT

path-help@sanger.ac.uk

=head1 METHODS

=cut
package AnnotationTrack;

BEGIN { unshift(@INC, './modules') }
use Moose;
use Getopt::Long;
use AnnotationTrack::Repository::Search;

my ($ENVIRONMENT, $query);

GetOptions ('environment|e=s'    => \$ENVIRONMENT,
            'query|q=s'          => \$query
);

$query or die <<USAGE;
Usage: $0 [options]
Query the annotation tracking system

annotation_track.pl -q repo_name

 Options:
     -q  The name of the repository to look up. It performs a wildcard search '%repo_name%'

USAGE
;

$ENVIRONMENT ||= 'production';

my $repository_query_report = AnnotationTrack::Repository::Search->new(
  environment     => $ENVIRONMENT,
  query           => $query
  );
$repository_query_report->print_report();
