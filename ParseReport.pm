package Test::Smoke::ParseReport;
use strict;
use MIME::Parser;

our $VERSION = "0.001";

sub _mime_parser {
  my $parser = MIME::Parser->new;
  $parser->output_to_core;

  return $parser;
}

sub _parse_subject {
  my ($self, $subject) = @_;

  chomp $subject;
  $self->{subject} = $subject;
  
  my ($v, $status, $os, $cpu, $cpu_count, $cores) =
    $subject =~
      /^Smoke\s # leader
       \[([0-9.a-zA-Z_\/-]+)\]\s # branch
       \S+\s  # git describe
       (PASS(?:-so-far)?|FAIL\(.+\))\s # summary
       (.*)\s  # OS
       \(
       (.*)\/ # cpu type
       ([0-9]+)\scpu # number of CPUs
       (?:\[([0-9]+)scores\])? # optional number of cores
       \)
       \s*$/x
	 or die "Cannot parse subject\n";
  $self->{status} = $status;
  $self->{os} = $os;
  $self->{cpu} = $cpu;
  $cores ||= 1;
  $self->{cores} = $cores;
  $self->{cpu_count} = $cpu_count * $cores;
}

sub _parse_leader {
  my ($self, $body) = @_;

  # first lines should be an intro
  my ($first, $host_line, $os_line, $cc_line) = @$body;
  my ($sha) = $first =~ /^Automated smoke report for [0-9.]+ patch ([0-9a-f]+) /
    or die "Cannot parse SHA\n";
  $self->{sha} = $sha;

  my ($host, $cpu_full) = $host_line =~ /^([a-z.0-9-]+):\s*(.*)/i
    or die "Cannot parse host line: $host_line\n";
  $self->{host} = $host;
  $self->{cpu_full} = $cpu_full;
  
  my ($cc, $cc_ver) = $cc_line =~ /^\s+using\s+(.*)\s+version\s+(.*)$/
    or die "Cannot parse CC line: $cc_line\n";
  $self->{cc} = $cc;
  $self->{cc_version} = $cc_ver;
}

sub _parse_cfgs {
  my ($self, $body) = @_;

  # look for the start of the result block
  while (@$body && $body->[0] !~ /Configuration \(common\) (.*)/) {
    shift @$body;
  }
  @$body && $body->[0] =~ /Configuration \(common\) (.*)/
    or die "Cannot find result block\n";
  
  $self->{common} = $1 eq "none" ? "" : $1;
  
  shift @$body; # v.... Configuration (common) ...
  shift @$body; # underlined with dashes
  
  my @hcfgs;
  my @results;
  while (@$body && $body->[0] !~ /^\|/) {
    my $line = shift @$body;
    
    my ($results, $cfg) = $line =~ /^((?:\S )+)(.*)$/
      or die "Cannot parse result line $line\n";
    
    push @hcfgs, $cfg;
    push @results, $results;
  }
  $self->{hcfgs} = \@hcfgs;

  # markers for the vertical configs
  my @vcfgs;
  while (@$body && $body->[0] =~ /\S/) {
    my $line = shift @$body;
    my ($cfg) = $line =~ /\+-+ (.*)$/
      or die "Cannot parse vertical cfg line $line\n";

    push @vcfgs, $cfg;
  }
  $self->{vcfgs} = \@vcfgs;

  $self->_skip_blanks($body);
}

sub _parse_patches {
  my ($self, $body) = @_;

  my @patches;
  if (@$body && $body->[0] =~ /^Locally applied patches/) {
    shift @$body;
    while (@$body && $body->[0] =~ /^\s+(\S.*)$/) {
      push @patches, $1;
      shift @$body;
    }

    $self->_skip_blanks($body);
  }
  $self->{patches} = \@patches;
}

sub _parse_harness {
  my ($self, $body) = @_;

  my $harness_only = 0;
  my $harness_opts = '';
  if (@$body
      && $body->[0] =~ /Testsuite was run only with .*HARNESS_OPTIONS=(.*)/) {
    $harness_only = 1;
    $harness_opts = $1;
    
    shift @$body;
  }
  $self->{harness_only} = $harness_only;
  $self->{harness_opts} = $harness_opts;
  $self->_skip_blanks($body);
}

sub _parse_failures {
  my ($self, $body) = @_;

  my @failures;
  # there can be multiple failure blocks
  while (@$body && $body->[0] =~ /^Failures:/) {
    my $header = shift @$body;
    my ($common) = $header =~ /\(common-args\)\s*(.+$)/;
    $common ||= "";
    $common eq "none" and $common = "";

    my @fail_cfgs;
    while (@$body && $body->[0] =~ /^\[([^\[\]]+)\](.*)$/) {
      my @perlio = split m(/), $1;
      my $cc_cfg = $2;

      push @fail_cfgs, "[$_]$cc_cfg" for @perlio;
      shift @$body;
    }

    my @fail_msgs;
    while (@$body && $body->[0] =~ /\S/) {
      my $script = shift @$body;
      my @error;
      while (@$body && $body->[0] =~ /^\s+\S/) {
	push @error, shift @$body;
      }
      push @fail_msgs, Test::Smoke::ParseReport::Test->new($script, @error);
    }

    for my $cfg (@fail_cfgs) {
      push @failures, Test::Smoke::ParseReport::Failure->new($cfg, \@fail_msgs);
    }

    $self->_skip_blanks($body);
  }
  $self->{failures} = \@failures;
}

sub _skip_blanks {
  my ($self, $body) = @_;

  shift @$body while @$body && $body->[0] !~ /\S/;
}

sub _parse {
  my ($self, $entity) = @_;

  my @body = $entity->bodyhandle->as_lines;
  $self->{body} = join '', @body;
  my $head = $entity->head;
  $head->unfold;
  
  my $subject = $entity->get("Subject");
  if (defined $subject) {
    $self->_parse_subject($subject);
  }

  my $from = $entity->get("From");
  if (defined $from) {
    chomp $from;
    $self->{from} = $from;
    
    if ($from =~ /([a-z0-9.-]+\@[a-z0-9-.]+)/i) {
      $self->{from_email} = $1;
      my $masked = $1;
      $masked =~ s/\@/ # /;
      $self->{from_masked} = $masked;
    }
  }
  
  chomp @body;
  
  if ($body[0] =~ /^Smoke logs available at ([a-z]+:.*)$/) {
    $self->{logurl} = $1;
  }
  
  # scan for the start of the report
  # some reports get stuff added at the front, scan for the prologue
  while (@body && $body[0] !~ /^Automated smoke report /) {
    shift @body;
  }
  @body
    or die "No report prologue found in body\n";

  $self->_parse_leader(\@body);

  $self->_parse_cfgs(\@body);

  $self->_parse_patches(\@body);

  $self->_parse_harness(\@body);

  $self->_parse_failures(\@body);

  1;
}

sub parse {
  my ($class, $raw) = @_;

  my $parser = $class->_mime_parser;

  my $self = bless {}, $class;

  local $SIG{__DIE__};
  eval {
    my $entity = $parser->parse_data($raw);
    $self->_parse($entity);
  } or do {
    $self->{error} = $@;
    chomp $self->{error};
  };

  return $self;
}

sub parse_file {
  my ($class, $filename) = @_;

  my $parser = $class->_mime_parser;

  my $self = bless {}, $class;

  local $SIG{__DIE__};
  eval {
    my $entity = $parser->parse_open($filename);
    $self->_parse($entity);
  } or do {
    $self->{error} = $@;
    chomp $self->{error};
  };

  return $self;
}

sub error { $_[0]{error} }

sub subject { $_[0]{subject} }

sub status { $_[0]{status} }

sub os { $_[0]{os} }

sub cpu { $_[0]{cpu} }

sub cores { $_[0]{cores} }

sub cpu_count { $_[0]{cpu_count} }

sub from { $_[0]{from} }

sub from_email { $_[0]{from_email} }

sub from_masked { $_[0]{from_masked} }

sub logurl { $_[0]{logurl} }

sub sha { $_[0]{sha} }

sub host { $_[0]{host} }

sub cpu_full { $_[0]{cpu_full} }

sub cc { $_[0]{cc} }

sub cc_version { $_[0]{cc_version} }

sub common { $_[0]{common} }

sub patches { @{$_[0]{patches}} }

sub harness_only { $_[0]{harness_only} }

sub harness_opts { $_[0]{harness_opts} }

sub failures { @{$_[0]{failures}} }

# sub cc { $_[0]{cc} }

# sub cc { $_[0]{cc} }

package Test::Smoke::ParseReport::Failure;

sub new {
  my ($class, $cfg, $errors) = @_;

  $cfg =~ s/\s+$//;

  return bless [ $cfg, $errors ], $class;
}

sub cfg { $_[0][0] }

sub errors { @{$_[0][1]} }

package Test::Smoke::ParseReport::Test;

sub new {
  my ($class, $script, @error) = @_;

  my ($name, $result) = split /\.\.\.+/, $script;

  return bless [ $name, $result, \@error ], $class;
}

sub script { $_[0][0] }

sub result { $_[0][1] }

sub error { @{$_[0][2]} }

1;
