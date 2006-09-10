#!/usr/bin/perl -w
#!/usr/local/bin/perl -w

package Ingres::Utility::IIMonitorSession;

use strict;
use English '-no_match_vars';
use Expect::Simple;
use Data::Dump qw(dump);

sub IIMonitorSession {
	my $class = shift;
	my $this = {};
	$class = ref($class) || $class;
	bless $this, $class;
	
}

getNextSession {
}

1; # formal return