#!/m1/shared/bin/perl -w
# Given file of MARC records, generate custom citation for each;
# output is to stdout.

use strict;
use lib "/usr/local/bin/voyager/perl";
use MARC::Batch;
use UCLA_Batch; #for UCLA_Batch::safenext to better handle data errors

if ($#ARGV != 0) {
  print "\nUsage: $0 infile\n";
  exit 1;
}

my $infile = $ARGV[0];

my $batch = MARC::Batch->new('USMARC', $infile);

# 20050526 akohler: turn off strict validation - otherwise, all records after error are lost
$batch->strict_off();

while (my $record = UCLA_Batch::safenext($batch)) {
  print_citation($record);
}

exit 0;

##############################
# Print citation in custom format, assembled
# from various parts of the record.
sub print_citation {
  my $record = shift;
  my $citation = '';

  $citation .= get_authors($record);
  $citation .= get_date($record);
  $citation .= get_title($record);
  $citation .= get_imprint($record);
  $citation .= get_permlink($record);
  print "$citation\n";
}

##############################
sub get_authors {
  return 'AUTHORS';
}

##############################
sub get_date {
  return 'DATE';
}

##############################
sub get_title {
  return 'TITLE';
}

##############################
sub get_imprint {
  return 'IMPRINT';
}

##############################
sub get_permlink {
  my $record = shift;
  my $bib_id = $record->field('001')->data();
  return "https://catalog.library.ucla.edu/vwebv/holdingsInfo?bibId=$bib_id";
}
