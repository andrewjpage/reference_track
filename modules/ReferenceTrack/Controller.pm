=head1 NAME

Controller - Represents a collection of Controller

=head1 SYNOPSIS

use ReferenceTrack::Controller;
ReferenceTrack::Controller->new(
    database_settings => \%dbsettings,
    add_repository   => \@repository_details,
    public_release   => $public_release_repository,
    creation_details => \@creation_details,
    starting_version => $starting_version
  )->run();
  
=cut

package ReferenceTrack::Controller;
use Moose;
use ReferenceTrack::Repository::Management;
use ReferenceTrack::Repository::Search;
use ReferenceTrack::Repository::PublicRelease;

has 'database_settings' => ( is => 'ro', isa => 'HashRef', required => 1);
has 'add_repository'    => ( is => 'ro', isa => 'ArrayRef');
has 'public_release'    => ( is => 'rw', isa => 'Str');
has 'public_version'	=> ( is => 'ro', isa => 'Str');
has 'major_release'     => ( is => 'rw', isa => 'Str');
has 'minor_release'     => ( is => 'rw', isa => 'Str');
has 'short_name'        => ( is => 'ro', isa => 'Str');
has 'creation_details'  => ( is => 'ro', isa => 'ArrayRef');
has 'starting_version'  => ( is => 'ro', isa => 'Str', default => "1.1");
has 'upload_to_ftp_site' => ( is => 'rw', isa => 'Str');

has '_repository_management' => ( is => 'ro', lazy => 1, builder => '_build__repository_management');

sub _build__repository_management
{
    my($self) = @_;
    ReferenceTrack::Repository::Management->new(database_settings => $self->database_settings);
}

sub run
{
  my($self) = @_;

  if((defined($self->creation_details) )&& @{$self->creation_details} ==3)
  {
    $self->_create_reference_repository();
  }
  
  if((defined $self->add_repository) && @{$self->add_repository} > 1) 
  {  
    $self->_add_existing_repository();
  }
  
  if(defined($self->minor_release))
  {
    $self->_make_minor_release();
  }

  if(defined($self->major_release))
  {
    $self->_make_major_release();
  }

  if(defined($self->public_release))
  {
     $self->_make_publically_released();
  }
 
  if(defined($self->upload_to_ftp_site))
  {
     $self->_perform_upload_to_ftp_site();
  }
   
  
  1;
}

sub _perform_upload_to_ftp_site
{
  my($self) = @_;
  # search for repositories
  my $repository_search = ReferenceTrack::Repository::Search->new(
    database_settings => $self->database_settings,
    query             => $self->upload_to_ftp_site,
    );
    
  ReferenceTrack::Repository::PublicRelease->new(
      repository_search_results => $repository_search
    )->copy_publically_released_to_ftp_site();
}

sub _add_existing_repository
{
  my($self) = @_;
  $self->_repository_management->add($self->add_repository->[0], $self->add_repository->[1], $self->short_name);
}

sub _create_reference_repository
{
  my($self) = @_;
  $self->_repository_management->create($self->creation_details->[0],$self->creation_details->[1],$self->creation_details->[2] ,$self->starting_version, $self->short_name);
}

sub _make_publically_released
{
  my($self) = @_;
  my $repository_search = ReferenceTrack::Repository::Search->new(
    database_settings => $self->database_settings,
    query             => $self->public_release,
    );
  ReferenceTrack::Repository::PublicRelease->new(
    repository_search_results => $repository_search,
    public_version => $self->public_version,
  )->flag_all_as_publically_released();
}

sub _make_major_release
{
  my($self) = @_;
  my $repository_search = ReferenceTrack::Repository::Search->new(
    database_settings => $self->database_settings,
    query             => $self->major_release,
    );
  ReferenceTrack::Repository::PublicRelease->new(
    repository_search_results => $repository_search
  )->flag_all_as_major_release();
}

sub _make_minor_release
{
  my($self) = @_;
  my $repository_search = ReferenceTrack::Repository::Search->new(
    database_settings => $self->database_settings,
    query             => $self->minor_release,
    );
  ReferenceTrack::Repository::PublicRelease->new(
    repository_search_results => $repository_search
  )->flag_all_as_minor_release();
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;