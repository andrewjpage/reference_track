package ReferenceTrack::Schema::Result::Repositories;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('latest_repositories');
__PACKAGE__->add_columns(qw/name location/);
__PACKAGE__->add_unique_constraint([ qw/name/ ]);

__PACKAGE__->add_columns(qw/latest/, { is_numeric => 1, default_value => 1 });
__PACKAGE__->add_columns(qw/public_release/, { is_numeric => 1, default_value => 0 });
__PACKAGE__->add_columns(qw/id/,{
                             data_type         => 'integer',
                             size              => 16,
                             is_nullable       => 0,
                             is_auto_increment => 1,
                             default_value     => '',
                           });
__PACKAGE__->set_primary_key('id');

1;
