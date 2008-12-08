#!/usr/bin/perl

use Net::fonolo;
use Data::Dumper;

my $fonolo = Net::fonolo->new(

	key		=> "< your fonolo developer API key >",
	username	=> "< a fonolo member username >",
	password	=> "< a fonolo member password >"
);

my $result = $fonolo->search_companies("Air Canada");
	
print Dumper($result);

1;
