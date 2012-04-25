#!/usr/bin/env perl

=head1 NAME

annotation_track_management.pl

=head1 SYNOPSIS

annotation_track_management.pl [-e (staging|production) ] --add "My repo name" git://example.com/example.git

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
use AnnotationTrack::Repository::Management;

my ($ENVIRONMENT, @repository_details);

GetOptions ('environment|e=s'    => \$ENVIRONMENT,
            'a|add=s{2}'         => \@repository_details
);

(@repository_details > 1) or die <<USAGE;
Usage: $0 [options]
Query the annotation tracking system

annotation_track_management.pl --add "My repo name" git://example.com/example.git

 Options:
     -a|add     A name for your repository (can be anything), and the location of the repository.
USAGE
;

$ENVIRONMENT ||= 'production';

my $repository_management = AnnotationTrack::Repository::Management->new(environment => $ENVIRONMENT);
if(@repository_details > 1) 
{  
  $repository_management->add($repository_details[0], $repository_details[1]);
}
