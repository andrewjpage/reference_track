package AnnotationTrack::Repository::Exceptions;

use Exception::Class (
    AnnotationTrack::Repository::Exceptions::NameExists  => { description => 'The name already exists in the database' },
);  

1;
