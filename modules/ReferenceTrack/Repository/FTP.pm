=head1 NAME

FTP - Moose role which contains all of the functionality to copy the contents of a repository to an FTP site for public viewing

=head1 SYNOPSIS


with 'ReferenceTrack::Repository::FTP';
$public_release_obj->copy_publically_released_to_ftp_site();


=cut

package ReferenceTrack::Repository::FTP;
use Moose::Role;
use File::Copy;
use File::Path qw(make_path);
use File::Find;
use Archive::Tar;
use File::chdir;
use Data::Dumper;


has 'public_directory' => ( is => 'ro', isa => 'Str',  default => '/nfs/disk69/ftp/pub/pathogens/refs' );
has '_file_list' => (
        traits  => ['Array'],
        is      => 'ro',
        isa     => 'ArrayRef[Str]',
        default => sub { [] },
        handles => {
            all_files    => 'elements',
            add_file     => 'push',
            get_file     => 'get',
        },
    );

sub copy_publically_released_to_ftp_site
{
  my ($self)= @_; 
  return unless(defined($self->repository_search_results->_repository_query_results));

  for my $repository_row (@{$self->repository_search_results->_repository_query_results})
  {
    # only select ones which have the publically released flag
    for my $version_row ($repository_row->version_visibility->all)
    {
      next if($version_row->visible_on_ftp_site == 0);
      $self->_create_archive_and_copy_to_ftp($repository_row->name, $repository_row->location, $version_row->version);
    }
  }
  1;
}

sub _create_archive_and_copy_to_ftp
{
  my ($self, $repository_name, $repository_location, $version)= @_; 

  #checkout the respository to a temp directory
  my $git_instance_obj  = ReferenceTrack::Repository::Git::Instance->new(location => $repository_location); 
  my $git_instance = $git_instance_obj->git_instance;
  
  # tar up everything excluding .git directory and call it after the repo name+version
  my $tar = Archive::Tar->new();
  {
    local $CWD = $git_instance_obj->working_directory ;
    $tar->setcwd( $git_instance_obj->working_directory );
    $self->_get_file_list($git_instance_obj->working_directory );
    
    $tar->add_files($self->all_files);
    my $tar_output_temp_dir_obj = File::Temp->newdir(CLEANUP => 1);
    my $tar_file_name = $tar_output_temp_dir_obj->dirname()."/".$self->_tar_file_name($repository_name, $version);
    $tar->write( $tar_file_name, COMPRESS_GZIP );
    my $destination = $self->_ftp_destination($repository_name);
    # TODO - replace with RSYNC module
    `rsync $tar_file_name $destination`;
  }
  1;
}

sub _get_file_list
{
  my($self,$directory) = @_;
  {
    local $CWD = $directory;
    find(
      { 
        wanted => sub {
          _wanted({self => $self});
        },
        preprocess => sub {
          grep { $_ !~ /git/ } @_; 
        }
      },
      '.'
    );
  }
}

sub _wanted {
  my $self = ${$_[0]}{self};
  return unless(defined $File::Find::name);
  $self->add_file($File::Find::name);
}

sub _ftp_destination
{
  my ($self, $repository_name)= @_;
  my @humanised_repo_name = split(/ /,$repository_name);
  my $ftp_destination = $self->public_directory."/".$humanised_repo_name[0]."/";
  make_path($ftp_destination);
  return $ftp_destination;
}

sub _tar_file_name
{
  my ($self, $repository_name, $version)= @_; 
  my $tar_file_name = join("_",($repository_name,"v".$version));
  $tar_file_name = join(".",($tar_file_name,"tgz"));
  $tar_file_name =~ s! !_!g;
  return $tar_file_name;
}

1;