package ReferenceTrack::Repository::Exceptions;

use Exception::Class (
    ReferenceTrack::Repository::Exceptions::NameExists  => { description => 'The name already exists in the database' },
);  

1;
