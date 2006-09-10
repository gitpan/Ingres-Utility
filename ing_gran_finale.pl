#!/usr/bin/perl -w
#!/usr/local/bin/perl -w
use Ingres::Iinamu;
use strict;
use English '-no_match_vars';
use Expect::Simple;
use Data::Dump qw(dump);

my $iigcn = Ingres::Iinamu->Iinamu();
my $stdout;
my @svrs;
my $svr_type;
foreach $svr_type ('INGRES', 'COMSVR') {
	$stdout = $iigcn->show($svr_type);
	print "STDOUT ($svr_type): ($stdout)\n";
	while (@svrs = $iigcn->getServer()) {
		print "Data::Dump:" .Data::Dump->dump(@svrs) . "\n";
		print "Server: $svrs[0]\tName: $svrs[1]\tGCF_id: $svrs[2]\n";
	}
}
