use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::DocsAPI',
  VERSION_FROM => 'lib/Mojolicious/Plugin/DocsAPI.pm',
  AUTHOR       => 'Anton Konovalov <nospam@cpan.org>',
  PREREQ_PM    => {'Mojolicious' => '4.16'},
  test         => {TESTS => 't/*.t'}
);
