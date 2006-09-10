#!/usr/bin/perl -w
#!/usr/local/bin/perl -w

package Ingres::Utility::IIMonitor;

use strict;
use English '-no_match_vars';
use Expect::Simple;
use Data::Dump qw(dump);


sub IIMonitor {
	my $class = shift;
	my $this = {};
	$class = ref($class) || $class;
	bless $this, $class;
	if (! defined($ENV{'II_SYSTEM'})) {
		die $class . ": Ingres environment variable II_SYSTEM not set";
	}
	my $iimonitor_file = $ENV{'II_SYSTEM'} . '/ingres/bin/iimonitor';
	
	if (! -x $iimonitor_file) {
		die $class . ": Ingres utility cannot be executed: $iimonitor_file";
	}
	$this->{IIMONITOR_CMD} = $iimonitor_file;
	$this->{IINAMU_XPCT} = new Expect::Simple {
				Cmd => $iimonitor_file,
				Prompt => [ -re => 'IIMONITOR>\s+' ],
				DisconnectCmd => 'QUIT',
				Verbose => 0,
				Debug => 0,
				Timeout => 10
        } or die $this . ": Module Expect::Simple cannot be instanciated.";
	return $this;
}

sub showServer {
	my $this = shift;
	my $server_status = uc (@_ ? shift : '');
	if ($server_status) {
		if ($server_status != 'LISTEN') {
			if ($server_status != 'SHUTDOWN') {
				die $this . ": invalid status: $server_status";
			}
		}
	}
	#print $this . ": IIMONITOR_CMD = $cmd";
	my $obj = $this->{IIMONITOR_XPCT};
	$obj->send( 'SHOW SERVER ' . $server_status );
	my $before = $obj->before;
	while ($before =~ /\ \ /) {
		$before =~ s/\ \ /\ /g;
	}
	my @antes = split(/\r\n/,$before);
	return join($RS,@antes);
}

sub setServer {
	my $this = shift;
	my $server_status = uc (shift);
	if (! $server_status) {
		die $this . ': no status given';
	}
	if ($server_status != 'SHUT') {
		if ($server_status != 'CLOSED') {
			if ($server_status != 'OPEN') {
				die $this . ": invalid status: $server_status";
			}
		}
	}
	#print $this . ": IIMONITOR_CMD = $cmd";
	my $obj = $this->{IIMONITOR_XPCT};
	$obj->send( 'SET ' . $server_status );
	my $before = $obj->before;
	while ($before =~ /\ \ /) {
		$before =~ s/\ \ /\ /g;
	}
	my @antes = split(/\r\n/,$before);
	print "\@antes: " . join(":",@antes);
	print 'before: ' . $obj->before . "\n";
	print 'after: ' . $obj->after . "\n";
	print 'match_str: ' . $obj->match_str, "\n";
	print 'match_idx: ' . $obj->match_idx, "\n";
	#print 'error_expect: ' . $obj->error_expect . "\n";
	#print 'error: ' . $obj->error . "\n";

	my   $expect_object = $obj->expect_handle;
	return;
	
}

sub stopServer {
	my $this = shift;
	my $obj = $this->{IIMONITOR_XPCT};
	$obj->send( 'STOP');
	my $before = $obj->before;
	while ($before =~ /\ \ /) {
		$before =~ s/\ \ /\ /g;
	}
	my @antes = split(/\r\n/,$before);
	return;
	
}

1; # formal return
