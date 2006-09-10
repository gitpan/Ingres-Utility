#!/usr/bin/perl -w
#!/usr/local/bin/perl -w
package Ingres::Utility::IINamu;

use strict;
use English '-no_match_vars';
use Expect::Simple;
use Data::Dump qw(dump);


sub IINamu {
	my $class = shift;
	my $this = {};
	$class = ref($class) || $class;
	bless $this, $class;
	if (! defined($ENV{'II_SYSTEM'})) {
		die $class . ": Ingres environment variable II_SYSTEM not set";
	}
	my $iigcn_file = $ENV{'II_SYSTEM'} . '/ingres/bin/iinamu';
	
	if (! -x $iigcn_file) {
		die $class . ": Ingres utility cannot be executed: $iigcn_file";
	}
	$this->{IINAMU_CMD} = $iigcn_file;
	$this->{IINAMU_XPCT} = new Expect::Simple {
				Cmd => $iigcn_file,
				Prompt => [ -re => 'IINAMU>\s+' ],
				DisconnectCmd => 'QUIT',
				Verbose => 0,
				Debug => 0,
				Timeout => 10
        } or die $this . ": Module Expect::Simple cannot be instanciated.";
	return $this;
}

sub show {
	my $this = shift;
	my $server_type = uc (@_ ? shift : 'INGRES');
	#print $this . ": IINAMU_CMD = $cmd";
	my $obj = $this->{IINAMU_XPCT};
	my $cmd = 'SHOW ' . $server_type;
	$obj->send($cmd);
	my $before = $obj->before;
	while ($before =~ /\ \ /) {
		$before =~ s/\ \ /\ /g;
	}
	my @antes = split(/\r\n/,$before);
	if ($#antes > 0) {
		if ($antes[0] eq $cmd) {
			shift @antes;
		}
	}
	$this->{IINAMU_STREAM} = join($RS,@antes);
	$this->{IINAMU_SVRTYPE} = $server_type;
	return $this->{IINAMU_STREAM};
}

sub getServer {
	my $this = shift;
	if (! $this->{IINAMU_STREAM}) {
		return ();
	}
	if (! $this->{IINAMU_STREAM_PTR}) {
		$this->{IINAMU_STREAM_PTR} = 0;
	}
	my @antes = split($RS,$this->{IINAMU_STREAM});
	if ($#antes <= $this->{IINAMU_STREAM_PTR}) {
		$this->{IINAMU_STREAM_PTR} = 0;
		return ();
	}
	my $line = $antes[$this->{IINAMU_STREAM_PTR}++];
	return split(/\ /, $line);
}

sub stop {
	my $this = shift;
	my $obj = $this->{IINAMU_XPCT};
	$obj->send( 'STOP');
	my $before = $obj->before;
	while ($before =~ /\ \ /) {
		$before =~ s/\ \ /\ /g;
	}
	my @antes = split(/\r\n/,$before);
	return;
	
}

1; # formal return
