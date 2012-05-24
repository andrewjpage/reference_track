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
use ReferenceTrack::Repository::Management;
use ReferenceTrack::Repository::Search;
use ReferenceTrack::Repository::PublicRelease;

my ($ENVIRONMENT, @repository_details, $public_release_repository);

GetOptions ('environment|e=s'    => \$ENVIRONMENT,
            'a|add=s{2}'         => \@repository_details,
            'p|public_release=s'   => \$public_release_repository,
            
);

(@repository_details > 1) or die <<USAGE;
Usage: $0 [options]
Query the reference tracking system

reference_track_management.pl --add "My repo name" git://example.com/example.git
reference_track_management.pl --public_release "My repo name"

 Options:
     -a|add     A name for your repository (can be anything), and the location of the repository.
USAGE
;

$ENVIRONMENT ||= 'production';

my $repository_management = ReferenceTrack::Repository::Management->new(environment => $ENVIRONMENT);
if(@repository_details > 1) 
{  
  $repository_management->add($repository_details[0], $repository_details[1]);
}

if(defined($public_release_repository))
{
  my $repository_search = ReferenceTrack::Repository::Search->new(
    environment     => $ENVIRONMENT,
    query           => $public_release_repository,
    );
  ReferenceTrack::Repository::PublicRelease->new(
    repository_search_results => $repository_search
  )->flag_all_as_publically_released();
}
