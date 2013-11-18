=head1 NAME

GFF_file - Module to help with file tasks that aren't straight forward using Bio Perl

=head1 SYNOPSIS

my $gff_file = ReferenceTrack::GFF::GFF_file->new(
		file_name => '/nfs/users/nfs_n/nds/Git_projects/reference_track/new_file.gff',
);

$gff_file->add_or_update_version("3.0");

=cut

package ReferenceTrack::GFF::GFF_file;
use Moose;
use Cwd;
use Cwd 'abs_path';


has 'file_name' => ( is => 'ro', isa => 'Str',  required   => 1 );
has 'in_situ' => ( is => 'ro', isa => 'Bool',  default  => 1   ); # If 0, print to std output


sub add_or_update_version
{
	my ($self, $version)= @_; 
	
	# Here, we update the comment (if it exists) with the new version number
	# or add a comment. Alternative ways to do this would have been to use
	# Tie::File or extend Bio Perl. Tie::File would have consumed a lot of memory for large files.
	# Bio Perl would have been ideal except that, at the moment, it does not
    # process/read comment lines. We have chosen this method over extending Bio Perl.
    
    open (my $fh, "<", $self->file_name) or die "Could not open file $self->file_name: $!";
	
	# Essentially we create a temporary file and copy over all the lines (inserting the new comment line)
	# This is not efficient for large files
	my $tmpfh = "";
	my $temp_file = abs_path($self->file_name)."/temp_file.gff";
	if($self->in_situ){
		open ($tmpfh, ">", $temp_file) or die "Could not open file $temp_file: $!";
	}
	
	my $seen_version = "false";
	
	while (my $line = <$fh>){
    
    	 # If there is a version comment already, or if we've reached the feature lines and haven't come across 
     	# a version comment, then lets add one.
     	if ($line =~ /^##internal-version/) {
     		$seen_version = "true";
     		print $tmpfh "##internal-version $version\n"; #Line with new version number
     		next;
     
     	} elsif ($line !~ /^##/ and $seen_version eq "false") {
     		$seen_version = "true";
     		print $tmpfh "##internal-version $version\n"; #Line with new version number
     	} 
     	print $tmpfh $line; #Copy over all the other lines
	}
	
	move($temp_file, $self->file_name);
	unlink($temp_file);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;