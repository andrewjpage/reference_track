package ReferenceTrack::Repository::Types;
use Moose;
use Moose::Util::TypeConstraints;

subtype 'ReferenceTrack::Repository::Name::Genus',
  as 'Str',
  where { ReferenceTrack::Repository::Validate::Name->new()->is_genus_valid($_) };
coerce 'ReferenceTrack::Repository::Name::Genus',
  from 'Str',
  via { ucfirst(lc($_)) };

subtype 'ReferenceTrack::Repository::Name::Subspecies',
  as 'Str',
  where { ReferenceTrack::Repository::Validate::Name->new()->is_subspecies_valid($_) };
coerce 'ReferenceTrack::Repository::Name::Subspecies',
  from 'Str',
  via { lc($_) };
  
subtype 'ReferenceTrack::Repository::Name::Strain',
  as 'Str',
  where { ReferenceTrack::Repository::Validate::Name->new()->is_strain_valid($_) };
  
subtype 'ReferenceTrack::Repository::Version::Number',
  as 'Num',
  where { ReferenceTrack::Repository::Validate::Version->new()->is_valid($_) };

subtype 'ReferenceTrack::Repository::Name::ShortName',
  as 'Str',
  where { ReferenceTrack::Repository::Validate::Name->new()->is_short_name_valid($_) };

subtype 'ReferenceTrack::DirectoryName',
  as 'Str',
  where { (-d $_) };

no Moose;
no Moose::Util::TypeConstraints;
__PACKAGE__->meta->make_immutable;
1;
