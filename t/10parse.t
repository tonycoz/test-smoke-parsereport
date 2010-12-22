#!perl -w
use strict;
use Test::More tests => 27;

use Test::Smoke::ParseReport;

{
  my $report = Test::Smoke::ParseReport->parse_file("t/data/86206.msg");
  ok($report, "got a report");
  ok(!$report->error, "should have succeeded")
    or note $report->error;
  is($report->subject, "Smoke [5.13.5] v5.13.5-183-ge2941eb FAIL(F) linux 2.6.26-2-amd64 [debian] (x86_64/4 cpu)", "check subject");
  is($report->status, "FAIL(F)", "check status");
  is($report->os, "linux 2.6.26-2-amd64 [debian]", "check os");
  is($report->cpu, "x86_64", "check cpu");
  is($report->cores, 1, "check cores (default)");
  is($report->cpu_count, 4, "check cpu_count");
  is($report->from, "tony\@develop-help.com", "check status");
  is($report->from_email, "tony\@develop-help.com", "check from_email");
  is($report->from_masked, "tony # develop-help.com", "check from_masked");
  is($report->logurl, undef, "check logurl");
  is($report->sha, "e2941eb00290cb2fcd0e0ca3f614f82202be65f7", "check sha");
  is($report->host, "mars", "check host");
  is($report->cpu_full, "Intel(R) Core(TM)2 Quad CPU Q6600 @ 2.40GHz (GenuineIntel 1596MHz) (x86_64/4 cpu)", "check cpu_full");
  is($report->cc, "cc", "check cc");
  is($report->cc_version, "4.3.2", "check cc_version");
  is($report->common, "", "check common");

  my @patches = $report->patches;
  is(@patches, 2, "2 patches listed");
  is($patches[0], "uncommitted-changes", "first patch");
  is($patches[1], "SMOKEe2941eb00290cb2fcd0e0ca3f614f82202be65f7", "second patch");

  my @failures = $report->failures;
  is(@failures, 12, "12 failing configs");

  my $first = $failures[0];
  is($first->cfg, "[stdio]", "check fail cfg");
  my @errors = $first->errors;
  ok(@errors, "first has errors");
  my $error = $errors[0];
  is($error->script, "../t/op/gv.t", "check name");
  is($error->result, "FAILED", "check result");
  like(($error->error)[0], qr/Non-zero exit status: 22/, "check message");
}
