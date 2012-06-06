package ReferenceTrack::Schema::Result::VersionVisibility;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('version_visibility');
__PACKAGE__->add_columns(qw/version/);
__PACKAGE__->add_columns(qw/repository_id/, { is_numeric => 1});
__PACKAGE__->add_unique_constraint([ qw/version repository_id/ ]);
__PACKAGE__->add_columns(qw/visible_on_ftp_site/, { is_numeric => 1, default_value => 0 });
__PACKAGE__->add_columns(qw/id/,{
                             data_type         => 'integer',
                             size              => 16,
                             is_nullable       => 0,
                             is_auto_increment => 1,
                             default_value     => '',
                           });
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(repository => 'ReferenceTrack::Schema::Result::Repositories', { 'foreign.id' => 'self.repository_id' });
1;