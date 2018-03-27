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
  printf "%s (%s). %s. %s. %s\n\n", get_authors($record), get_date($record), get_title($record), get_imprint($record), get_permlink($record);
}

##############################
# Get all 100/700 $a, trim trailing punctuation.
# De-dup the list: some records seem to have same author in 100 and multiple 700 fields, with different scopes.
sub get_authors {
  my $record = shift;
  my @authors = ();
  my @flds = $record->field('[17]00');
  foreach my $fld (@flds) {
    my $sfd = $fld->subfield('a');  # all 100/700 should have $a
	my $author = format_author($sfd);
	if (! grep(/^$author$/, @authors) ) {
	  push @authors, $author;
	}
  }
  # Once all are individually collected and formatted, iterate over authors to create one string for output.
  # Format as: author1, author2, ... & authorN
  my $authors_as_string = '';
  my $author_count = $#authors;
  for my $pos (0 .. $author_count) {
	# Append the appropriate intermediate punctuation.
	if ($pos > 0) {
	  $authors_as_string .= ', ';
	  if ($pos == $author_count) {
	    $authors_as_string .= '& ';
	  }
	}
	# Finally, append the next author.
    $authors_as_string .= $authors[$pos];
  }

  return $authors_as_string;
}

##############################
# Get 008/07-10 (begin pub date)
sub get_date {
  my $record = shift;
  my $f008 = $record->field('008')->data();
  return substr($f008, 7, 4); # 008/07-10
}

##############################
# Get 245 $a $b, trim trailing punctuation.
# 245 $a should always exist; $b may not.
sub get_title {
  my $record = shift;
  my $title = $record->subfield('245', 'a');
  $title .= ' ' . $record->subfield('245', 'b') if $record->subfield('245', 'b');
  return trim_punctuation($title);
}

##############################
# Get 260/264 $a $b, trim trailing punctuation.
# Take only first $a and first $b.
sub get_imprint {
  my $record = shift;
  # Taking only first $a so trim punctuation as it varies if there's another $a.
  my $imprint = trim_punctuation($record->subfield('26[04]', 'a'));
  $imprint .= ' : ' . $record->subfield('26[04]', 'b') if $record->subfield('26[04]', 'b');
  return trim_punctuation($imprint);
}

##############################
# Get 001, embed in Voyager OPAC permalink.
sub get_permlink {
  my $record = shift;
  my $bib_id = $record->field('001')->data();
  return "https://catalog.library.ucla.edu/vwebv/holdingsInfo?bibId=$bib_id";
}

##############################
# Remove trailing punctuation.
# Then remove any trailing spaces.
sub trim_punctuation {
  my $string = shift;
  $string =~ s/[[:punct:]]$//g;
  #$string =~ s/\s*$//;
  $string =~ s/[[:space:]]$//g;
  return $string;
}

##############################
# Format each author as: Lastname, F. M.
sub format_author {
  my $string = shift;
  my $author = '';
  my @words = split ' ', $string;
  for my $pos (0 .. $#words) {  
    # Keep first term as-is: probably last name, might also be mononym like Cher...
	if ($pos == 0) {
	  $author = trim_punctuation($words[$pos]);
	} else {
	  # Modify all terms beyond first by keeping only first initial, plus period
	  # Append comma only before first added initial.
	  if ($pos == 1) {
	    $author .= ',';
	  }
	  # Append space and initial to author.
	  $author .= ' ' . substr($words[$pos], 0, 1) . '.';
	}
  }
  return $author;
}

