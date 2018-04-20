use 5.024004;
use ExtUtils::MakeMaker;
use File::ShareDir::Install;

install_share dist => 'share';

WriteMakefile(
  NAME              => 'DwC::Plugin::Artsnavn',
  VERSION_FROM      => 'lib/DwC/Plugin/Artsnavn.pm',
  PREREQ_PM         => { DwC => 0.01, 'DBD::SQLite' => 1.58 },
  ABSTRACT_FROM     => 'lib/DwC/Plugin/Artsnavn.pm',
  AUTHOR            => 'umeldt',
  LICENSE           => 'perl',
);

package MY;
use File::ShareDir::Install 'postamble';

