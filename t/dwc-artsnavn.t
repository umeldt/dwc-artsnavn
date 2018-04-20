use strict;
use warnings;
use utf8;

use DwC;

use Test::More tests => 8;
BEGIN { use_ok('DwC::Plugin::Artsnavn') };

my $dwc = DwC->new({ scientificName => "Rubus idaeus", kingdom => "Plantae" });
DwC::Plugin::Artsnavn->clean($dwc);
ok($$dwc{family} eq "Rosaceae");

$dwc = DwC->new({ genus => "Felis" });
DwC::Plugin::Artsnavn->clean($dwc);
ok($$dwc{order} eq "Carnivora");
ok($$dwc{class} eq "Mammalia");
ok($$dwc{phylum} eq "Chordata");
ok($$dwc{kingdom} eq "Animalia");

$dwc = DwC->new({ scientificName => "Oenanthe", kingdom => "Plantae" });
DwC::Plugin::Artsnavn->clean($dwc);
ok($$dwc{family} eq "Apiaceae");

$dwc = DwC->new({ scientificName => "Oenanthe", kingdom => "Animalia" });
DwC::Plugin::Artsnavn->clean($dwc);
ok($$dwc{family} eq "Turdidae");

