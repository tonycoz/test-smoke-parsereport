#!perl -w
use strict;
use ExtUtils::MakeMaker;

WriteMakefile
  (
   NAME => "Test::Smoke::ParseReport",
   VERSION_FROM => "ParseReport.pm",
   AUTHOR => 'Tony Cook <tonyc@cpan.org>',
   ABSTRACT => "Parse Test::Smoke report emails",
   LICENSE => "perl",
   PREREQ_PM =>
   {
    "MIME::Parser" => "5.427",
   },
  );
