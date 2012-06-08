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
has 'public_release'    => ( is => 'ro', isa => 'Maybe[Str]');
has 'short_name'        => ( is => 'ro', isa => 'Str');
has 'creation_details'  => ( is => 'ro', isa => 'ArrayRef');
has 'starting_version'  => ( is => 'ro', isa => 'Str', default => "0.1");

has '_repository_management' => ( is => 'ro', lazy => 1, builder => '_build__repository_management');

sub _build__repository_management
{
    my($self) = @_;
    ReferenceTrack::Repository::Management->new(database_settings => $self->database_settings);
}

sub run
{
  my($self) = @_;

  if((defined $self->add_repository) && @{$self->add_repository} > 1) 
  {  
    $self->_add_existing_repository();
  }

  if(defined($self->public_release))
  {
     $self->_make_publically_released();
  }

  if((defined($self->creation_details) )&& @{$self->creation_details} ==3)
  {
    $self->_create_reference_repository();
  }
  
  1;
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
    repository_search_results => $repository_search
  )->flag_all_as_publically_released();
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;