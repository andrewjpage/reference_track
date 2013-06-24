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

my ($database, @repository_details, $public_release_repository,@creation_details,$starting_version, $public_version, $short_name, $major_release,$minor_release,$upload_to_ftp_site);

GetOptions ('database|d=s'    => \$database,
            'a|add=s{2}'         => \@repository_details,
            'p|public_release=s'   => \$public_release_repository,
            'c|create=s{3}'        => \@creation_details,
            's|starting_version=s' => \$starting_version,
            'v|public_version=s'   => \$public_version,
            'n|short_name=s'       => \$short_name,
            'm|major_release=s'    => \$major_release,
            'd|minor_release=s'    => \$minor_release,
            'u|upload_to_ftp_site:s' => \$upload_to_ftp_site
            
);

((@repository_details == 2) || defined $upload_to_ftp_site || ($public_release_repository && $public_version) || $major_release || $minor_release || (@creation_details == 3 && $short_name))or die <<USAGE;
Usage: $0 [options]
Query the reference tracking system

reference_track_management.pl --add "My repo name" git://example.com/example.git
reference_track_management.pl --create Plasmodium falciparum 3D7 --short_name PF3D7
reference_track_management.pl --create Plasmodium falciparum 3D7 --starting_version 0.3 --short_name PF3D7

reference_track_management.pl --public_release "3D7" --public_version 4.0
reference_track_management.pl --major_release "3D7"
reference_track_management.pl --minor_release "3D7"

reference_track_management.pl --upload_to_ftp_site ""
reference_track_management.pl --upload_to_ftp_site "3D7"

 Options:
     -a|add     A name for your repository (can be anything), and the location of the repository.
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

$starting_version ||= "1.1"; #We now adopt an internal versioning system of X.Y where X is the version of the reference, and Y is the version of the annotation. We always start with 1.1

if(defined($public_release_repository))
{
  ReferenceTrack::Controller->new(
      database_settings => \%database_settings,
      public_release    => $public_release_repository,
      public_version	=> $public_version,
    )->run();
}
elsif(defined($major_release))
{
  ReferenceTrack::Controller->new(
      database_settings => \%database_settings,
      major_release     => $major_release,
    )->run();
}
elsif(defined($minor_release))
{
  ReferenceTrack::Controller->new(
      database_settings => \%database_settings,
      minor_release     => $minor_release,
    )->run();
}
elsif(defined($upload_to_ftp_site))
{
  ReferenceTrack::Controller->new(
      database_settings  => \%database_settings,
      upload_to_ftp_site => $upload_to_ftp_site,
    )->run();
}
else
{
   ReferenceTrack::Controller->new(
       database_settings => \%database_settings,
       add_repository    => \@repository_details,
       creation_details  => \@creation_details,
       starting_version  => $starting_version,
       short_name        => $short_name
     )->run();
}
