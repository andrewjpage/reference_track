=head1 NAME

Log - Wrapper around Git log command

=head1 SYNOPSIS

use ReferenceTrack::Repository::Git::Log;

=cut

package ReferenceTrack::Repository::Git::Log;
use Moose;
use ReferenceTrack::Repository::Git::Instance;
#use String::Util 'trim';

has 'reference_location' => ( is => 'ro', isa => 'Str', required => 1 );     # git reference (can be url).
has 'since'  => ( is => 'ro', isa => 'Str', default => 'yesterday' );     # how long back should the logs go? default is the last 24 hours
has 'author' => ( is => 'ro', isa => 'Str', required => 0 );     # needed if searching for commits made by a specific author
has '_temp_repository' => ( is => 'rw', isa => 'ReferenceTrack::Repository::Git::Instance', lazy => 1, builder => '_build__temp_repository'); # work repo


sub _build__temp_repository
{
    my($self) = @_;
    return ReferenceTrack::Repository::Git::Instance->new( location => $self->reference_location );
}


=head2 METHOD

  Arg [1]    : 
  Example    : my $logger = ReferenceTrack::Repository::Git::Log->new(
  									reference_location => $repository_row->location,
  									since => '2.weeks', 	
  			   );
  			   my $authors = $logger->get_commit_authors();
  Description: Returns the names and email addresses of the authors who made commits in the time period specified (default: last 24 hours)
  Returntype : Hashref

=cut

sub get_commit_authors
{
	my ($self) = @_;
	my @commits = $self->_temp_repository->git_instance->run('log' => '--pretty=format:"%an | %ae"', '--since='.$self->since);
	# Put the names and email addresses into a hash
	my %emails_and_names;
	for my $commit (@commits){
		$commit =~ s/^"//g; #Trim leading and trailing quotes
		$commit =~ s/"$//g;
		my @components = split(/\|/, $commit);
		if(@components != 2) { 
			next;
		}
		my $email = $self->_trim($components[1]);
		my $name = $self->_trim($components[0]);
		if(!exists $emails_and_names{$email}){
			$emails_and_names{$email} = $name;
		}
	}
	return \%emails_and_names;


}

sub _trim 
{
	my ($self, $word) = @_;
	$word =~ s/^\s+//; #remove leading spaces
	$word =~ s/\s+$//; #remove trailing spaces
	return $word;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;