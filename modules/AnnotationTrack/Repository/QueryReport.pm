=head1 NAME

RepositoryQueryReport - Represents a collection of RepositoryQueryReport

=head1 SYNOPSIS

use AnnotationTrack::RepositoryQueryReport;
my $repository_query_report = AnnotationTrack::RepositoryQueryReport->new(
  results     => [$repository_row1, $repository_row2]
  );
$repository_query_report->print_report();
=cut

package AnnotationTrack::Repository::QueryReport;
use Moose;

has 'results'           => ( is => 'rw', isa => 'Maybe[ArrayRef]');

has '_formatted_report' => ( is => 'rw', lazy => 1, builder => '_build__formatted_report' );

sub _build__formatted_report
{
  my ($self) = @_;
  return unless(defined($self->results));
  my $formatted_report = '';
  for my $repository_row (@{$self->results})
  {
    $formatted_report .= $repository_row->location."\n";
  }
  
  return $formatted_report;
}

sub print_report
{
  my ($self) = @_;
  return unless(defined($self->results));
  print($self->_formatted_report);
}
no Moose;
__PACKAGE__->meta->make_immutable;
1;