#!/usr/bin/perl -w
#!/usr/local/bin/perl -w
package Ingres::Utility::Netutil;

use strict;
use English '-no_match_vars';
use Expect::Simple;
use Data::Dump qw(dump);


sub Netutil {
	my $class = shift;
	my $this = {};
	$class = ref($class) || $class;
	bless $this, $class;
	if (! defined($ENV{'II_SYSTEM'})) {
		die $class . ": Ingres environment variable II_SYSTEM not set";
	}
	my $netutil_file = $ENV{'II_SYSTEM'} . '/ingres/bin/netutil';
	
	if (! -x $netutil_file) {
		die $class . ": Ingres utility cannot be executed: $netutil_file";
	}
	$this->{NETUTIL_CMD} = $netutil_file;
	$this->{IINAMU_XPCT} = new Expect::Simple {
				Cmd => $netutil_file,
				Prompt => [ -re => '\s+' ],
				DisconnectCmd => '',
				Verbose => 0,
				Debug => 0,
				Timeout => 10
        } or die $this . ": Module Expect::Simple cannot be instanciated.";
	return $this;
}

sub show {
	my $this = shift;
	my $server_type = uc (@_ ? shift : 'INGRES');
	#print $this . ": NETUTIL_CMD = $cmd";
	my $obj = $this->{IINAMU_XPCT};
	$obj->send( 'SHOW ' . $server_type );
	my $before = $obj->before;
	while ($before =~ /\ \ /) {
		$before =~ s/\ \ /\ /g;
	}
	my @antes = split(/\r\n/,$before);
	print "\@antes: " . join(":",@antes);
	my %servers = ();
	my $line_server_type;
	my $name;
	my $server_id;
	my $foo;
FE:	foreach my $line (@antes) {
		if ($line eq ('SHOW ' . $server_type)) {
			next FE;
		}
		($line_server_type, $name, $server_id, $foo) = split(/\ /, $line);
		if ($line_server_type eq $server_type) {
			%servers = (%servers, $server_id => $name);
		}
	}
	#my $dump = Data::Dump->dump(%servers);
	print "\n\%servers:" . (join(":",keys %servers)) . "\n";
	print 'before: ' . $obj->before . "\n";
	print 'after: ' . $obj->after . "\n";
	print 'match_str: ' . $obj->match_str, "\n";
	print 'match_idx: ' . $obj->match_idx, "\n";
	#print 'error_expect: ' . $obj->error_expect . "\n";
	#print 'error: ' . $obj->error . "\n";

	my   $expect_object = $obj->expect_handle;
	return %servers;
	
}
sub stop {
	my $this = shift;
	my $server_id = uc (@_ ? shift : '');
	#print $this . ": NETUTIL_CMD = $cmd";
	my $obj = $this->{NETUTIL_XPCT};
	$obj->send( "STOP $server_id");
	my $before = $obj->before;
	while ($before =~ /\ \ /) {
		$before =~ s/\ \ /\ /g;
	}
	my @antes = split(/\r\n/,$before);
	print "\@antes: " . join(":",@antes);
	my   $expect_object = $obj->expect_handle;
	return;
	
}
1; # formal return
