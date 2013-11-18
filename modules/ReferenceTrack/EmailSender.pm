=head1 NAME

EmailSender - Manages the construction and sending of emails when there are errors in the annotation files
Can be used if we decide to run the GFF validator on a nightly basis, emailing users if there are errors

=head1 SYNOPSIS


  
=cut

package ReferenceTrack::EmailSender;
use Moose;
use MIME::Lite;


has 'email_from_address' => ( is => 'rw', isa => 'Str', required => 1 );
has 'email_to_address' => ( is => 'rw', isa => 'Str', required => 1 );
has 'email_domain' => ( is => 'rw', isa => 'Str', default => 'sanger.ac.uk' );
has 'user_name'	=> ( is => 'rw', isa => 'Str', required => 1 );
has 'error_file' => ( is => 'rw', isa => 'Str', required => 1);
has 'organism'	 => ( is => 'rw', isa => 'Str', required => 1);
has 'subject' => ( is => 'rw', isa => 'Str', lazy => 1, builder => '_build_email_subject' );
has 'data' => ( is => 'rw', isa => 'Str', lazy => 1, builder => '_build_email_body' );

sub _build_email_subject
{
	my($self) = @_;
	return "Errors in GFF file for ".$self->organism;
}

sub _build_email_body
{
    my($self) = @_;
    my $user_name = $self->user_name;
    my $organism = $self->organism;
    my $error_file = $self->error_file;
 	my $data = <<"DATA";
Dear $user_name,

We have run some validation checks on the GFF file for $organism, and found some errors. The errors are listed in the following file:
$error_file

Please correct these errors and submit the file back into the annotation tracking system.

You are being sent this email because you made some changes to this data in the last 24 hours.

Many thanks,

Pathogen Informatics Team

DATA

	return $data;
}
    

sub send_email
{
	my($self) = @_;
 	my $msg = MIME::Lite->new(
       			From    => $self->email_from_address,
       			To      => $self->email_to_address,
       			Subject => $self->subject, 
       			Data    => $self->data, 
    );
    $msg->send; #('smtp', 'sanger.ac.uk');
    
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
