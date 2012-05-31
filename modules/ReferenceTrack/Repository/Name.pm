=head1 NAME

Name - Generates a repository name

=head1 SYNOPSIS

use ReferenceTrack::Repository::Name;
my $repository = ReferenceTrack::Repository::Name->new(
  genus => 'ABC',
  subspecies => 'EFG',
  strain   => 'HIJ'
  );
$repository->repository_name();

=cut

package ReferenceTrack::Repository::Name;
use Moose;
use ReferenceTrack::Repository::Validate::Name;
use ReferenceTrack::Repository::Types;

has 'genus'      => ( is => 'ro', isa => 'ReferenceTrack::Repository::Name::Genus',      required => 1, coerce => 1 );
has 'subspecies' => ( is => 'ro', isa => 'ReferenceTrack::Repository::Name::Subspecies', required => 1, coerce => 1 );
has 'strain'     => ( is => 'ro', isa => 'ReferenceTrack::Repository::Name::Strain',     required => 1, coerce => 1 );
has 'short_name' => ( is => 'ro', isa => 'ReferenceTrack::Repository::Name::ShortName',  required => 1 );


has 'repository_name'     => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_repository_name');
has 'human_readable_name' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_human_readable_name');

sub _build_repository_name
{
  my($self) = @_;
  my $base_repo_name = join("_", ($self->genus, $self->subspecies, $self->strain));
  join('.', ($base_repo_name, 'git'));
}

sub _build_human_readable_name
{
  my($self) = @_;
  join(" ", ($self->genus, $self->subspecies, $self->strain));
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;