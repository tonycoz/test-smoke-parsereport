Newsgroups: perl.daily-build.reports
Path: nntp.perl.org
Xref: nntp.perl.org perl.daily-build.reports:86206
Return-Path: <tony@develop-help.com>
Mailing-List: contact daily-build-reports-help@perl.org; run by ezmlm
Delivered-To: mailing list daily-build-reports@perl.org
Received: (qmail 18019 invoked from network); 27 Sep 2010 02:51:59 -0000
Received: from x1.develooper.com (207.171.7.70)
  by x6.develooper.com with SMTP; 27 Sep 2010 02:51:59 -0000
Received: (qmail 20709 invoked by uid 225); 27 Sep 2010 02:51:59 -0000
Delivered-To: daily-build-reports@perl.org
Received: (qmail 20705 invoked by alias); 27 Sep 2010 02:51:58 -0000
X-Spam-Status: No, hits=0.4 required=8.0
	tests=RDNS_DYNAMIC,SPF_PASS,TO_NO_BRKTS_DYNIP,TVD_RCVD_IP
X-Spam-Check-By: la.mx.develooper.com
Received: from 202-154-105-237.people.net.au (HELO mars.tony.develop-help.com) (202.154.105.237)
    by la.mx.develooper.com (qpsmtpd/0.28) with ESMTP; Sun, 26 Sep 2010 19:51:56 -0700
Received: from localhost.localdomain (localhost [127.0.0.1])
	by mars.tony.develop-help.com (8.14.3/8.14.3/Debian-5+lenny1) with ESMTP id o8R2pbUP007892;
	Mon, 27 Sep 2010 12:51:37 +1000
Message-ID: <201009270251.o8R2pbUP007892@mars.tony.develop-help.com>
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset="UTF8"
X-Mailer: MIME::Lite 3.021 (F2.76; T1.30; A2.03; B3.07_01; Q3.07)
Date: Mon, 27 Sep 2010 12:51:37 +1000
Subject: Smoke [5.13.5] v5.13.5-183-ge2941eb FAIL(F) linux 2.6.26-2-amd64 [debian] (x86_64/4 cpu)
To: daily-build-reports@perl.org
Approved: news@nntp.perl.org
From: tony@develop-help.com

Automated smoke report for 5.13.5 patch e2941eb00290cb2fcd0e0ca3f614f82202be65f7 v5.13.5-183-ge2941eb
mars: Intel(R) Core(TM)2 Quad CPU Q6600 @ 2.40GHz (GenuineIntel 1596MHz) (x86_64/4 cpu)
    on        linux - 2.6.26-2-amd64 [debian]
    using     cc version 4.3.2
    smoketime 2 hours 41 minutes (average 13 minutes 27 seconds)

Summary: FAIL(F)

O = OK  F = Failure(s), extended report at the bottom
X = Failure(s) under TEST but not under harness
? = still running or test results not (yet) available
Build failures during:       - = unknown or N/A
c = Configure, m = make, M = make (after miniperl), t = make test-prep

v5.13.5-183-ge2941eb  Configuration (common) none
----------- ---------------------------------------------------------
F O O F O O 
F O O F O O -Duselongdouble
F O O F O O -Dmad
F O O F O O -Duseithreads
F O O F O O -Duseithreads -Duselongdouble
F O O F O O -Duseithreads -Dmad
| | | | | +- LC_ALL = de_DE.utf8 -DDEBUGGING
| | | | +--- PERLIO = perlio -DDEBUGGING
| | | +----- PERLIO = stdio  -DDEBUGGING
| | +------- LC_ALL = de_DE.utf8
| +--------- PERLIO = perlio
+----------- PERLIO = stdio 

Locally applied patches:
    uncommitted-changes
    SMOKEe2941eb00290cb2fcd0e0ca3f614f82202be65f7

Testsuite was run only with 'harness' and HARNESS_OPTIONS=j4

Failures: (common-args) none
[stdio] 
[stdio] -DDEBUGGING
[stdio] -Duselongdouble
[stdio] -DDEBUGGING -Duselongdouble
[stdio] -Dmad
[stdio] -DDEBUGGING -Dmad
[stdio] -Duseithreads
[stdio] -DDEBUGGING -Duseithreads
[stdio] -Duseithreads -Duselongdouble
[stdio] -DDEBUGGING -Duseithreads -Duselongdouble
[stdio] -Duseithreads -Dmad
[stdio] -DDEBUGGING -Duseithreads -Dmad
../t/op/gv.t................................................FAILED
    Non-zero exit status: 22
    Bad plan.  You planned 219 tests but ran 217.
../ext/IPC-Open3/t/fd.t.....................................FAILED
    1

Passed Todo tests: (common-args) none
[de_DE.utf8] 
[de_DE.utf8] -DDEBUGGING
[de_DE.utf8] -Duselongdouble
[de_DE.utf8] -DDEBUGGING -Duselongdouble
[de_DE.utf8] -Dmad
[de_DE.utf8] -DDEBUGGING -Dmad
[de_DE.utf8] -Duseithreads
[de_DE.utf8] -DDEBUGGING -Duseithreads
[de_DE.utf8] -Duseithreads -Duselongdouble
[de_DE.utf8] -DDEBUGGING -Duseithreads -Duselongdouble
[de_DE.utf8] -Duseithreads -Dmad
[de_DE.utf8] -DDEBUGGING -Duseithreads -Dmad
../ext/XS-APItest/t/caller.t................................PASSED
    22-23

Compiler messages(gcc):
regcomp.c: In function ‘Perl_re_compile’:
regcomp.c:4276: warning: variable ‘exp’ might be clobbered by ‘longjmp’ or ‘vfork’
regcomp.c:4277: warning: variable ‘xend’ might be clobbered by ‘longjmp’ or ‘vfork’
regcomp.c:4292: warning: variable ‘re_debug_flags’ might be clobbered by ‘longjmp’ or ‘vfork’

-- 
Report by Test::Smoke v1.43 build 1271 running on perl 5.10.0
(Reporter v0.035 / Smoker v0.045)

Logs at http://perl.develop-help.com/reports/
Branch: origin/blead
Configuration: default
