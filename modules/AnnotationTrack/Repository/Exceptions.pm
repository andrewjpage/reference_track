package AnnotationTrack::Repository::Exceptions;

use Exception::Class (
    AnnotationTrack::Repository::Exceptions::NameExists  => { description => 'The name already exists in the database' },
);  
no Moose;
__PACKAGE__->meta->make_immutable;
1;
