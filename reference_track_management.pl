#!/usr/bin/env perl

=head1 NAME

reference_track_management.pl

=head1 SYNOPSIS

reference_track_management.pl [-e (staging|production) ] --add "My repo name" git://example.com/example.git

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

use ReferenceTrack::Controller;

my ($ENVIRONMENT, @repository_details, $public_release_repository,@creation_details,$starting_version);

GetOptions ('environment|e=s'    => \$ENVIRONMENT,
            'a|add=s{2}'         => \@repository_details,
            'p|public_release=s'   => \$public_release_repository,
            'c|create=s{3}'        => \@creation_details,
            's|starting_version=f' => \$starting_version
            
);

((@repository_details == 2) || $public_release_repository || (@creation_details == 3 ))or die <<USAGE;
Usage: $0 [options]
Query the reference tracking system

reference_track_management.pl --add "My repo name" git://example.com/example.git
reference_track_management.pl --public_release "My repo name"

reference_track_management.pl --create Plasmodium falciparum 3D7 
reference_track_management.pl --create Plasmodium falciparum 3D7 --starting_version 0.3

 Options:
     -a|add     A name for your repository (can be anything), and the location of the repository.
USAGE
;

$ENVIRONMENT ||= 'production';

ReferenceTrack::Controller->new(
    environment      => $ENVIRONMENT,
    add_repository   => \@repository_details,
    public_release   => $public_release_repository,
    creation_details => \@creation_details,
    starting_version => $starting_version
  )->run();
