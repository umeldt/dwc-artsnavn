use strict;
use warnings;
use utf8;

use 5.024004;

package DwC::Plugin::Artsnavn;

our $VERSION = '0.01';

use TokyoCabinet;
use File::Share ':all';

our %cache;
our @ranks = (
  'genus', 'Slekt',
  'family', 'Familie',
  'order', 'Orden',
  'class', 'Klasse',
  'phylum', 'Phylum'
);

my $path = dist_file('DwC-Plugin-Artsnavn', 'artsnavn.db');
our $db = TokyoCabinet::TDB->new;
if(!$db->open("$path", $db->OREADER)) {
  my $ecode = $db->ecode();
  die("DwC::Plugin::Artsnavn error: " . $db->errmsg($ecode) . "\n");
}

sub description {
  return "Cleans scientific names against Artsnavnebasen";
}

sub clean {
  my ($plugin, $dwc) = @_;

  my ($raw, $name);

  if($$dwc{genus}) {
    $raw = $$dwc{genus};
  } elsif($$dwc{scientificName}) {
    ($raw, $_) = split(/\s/, $$dwc{scientificName}, 2);
  } else {
    $dwc->log("warning", "Missing scientificName", "taxonomy");
    return;
  }
  my $kingdom = $$dwc{kingdom} || $ENV{DWC_KINGDOM} || "All";
  if($cache{"$kingdom-$raw"}) {
    $name = $cache{"$kingdom-$raw"};
  } else {
    for(my $i = 0; $i <= $#ranks && !$name; $i += 2) {
      my $rank = $ranks[$i];
      my $key = $ranks[$i + 1];
      my $q = TokyoCabinet::TDBQRY->new($db);

      if($kingdom && $kingdom ne "All") {
        $q->addcond("Rike", $q->QCSTREQ, $kingdom);
      }
      $q->addcond($key, $q->QCSTREQ, $raw);
      my $results = $q->search();
      if(@{$results} > 0) {
        $name = $db->get($$results[0]);
        $$name{rank} = $rank;
        $cache{"$kingdom-$raw"} = $name;
      }
    }
  }
  return if !$name;
  if(!$name) {
    $dwc->log("warning", "Couldn't find '$raw' in Artsnavnebasen", "taxonomy");
    return;
  }

  if(!$ENV{DWC_HANDSOFF}) {
    my $rank = $$name{rank};

    unless (grep /^$rank$/, ('order', 'class', 'phylum')) {
      $$dwc{genus} = $$name{Slekt};
      $$dwc{family} = $$name{Familie};
    }
    $$dwc{order} = $$name{Orden} unless grep /^$rank$/, ('class', 'phylum');
    $$dwc{class} = $$name{Klasse} unless grep /^$rank$/, ('phylum');
    $$dwc{phylum} = $$name{Rekke};
    $$dwc{kingdom} = $$name{Rike};

    utf8::decode($$dwc{genus});
    utf8::decode($$dwc{family});
    utf8::decode($$dwc{order});
    utf8::decode($$dwc{class});
    utf8::decode($$dwc{phylum});
    utf8::decode($$dwc{kingdom});

    $dwc->log("info",
      "Added higher taxonomic ranks from Artsnavnebasen", "taxonomy");
  }
}

1;
__END__

=head1 NAME

DwC::Plugin::Artsnavn - Cleans scientific names against Artsnavnebasen

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018 by umeldt

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.24.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
