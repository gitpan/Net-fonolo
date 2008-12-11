use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME				=> 'Net::fonolo',
	AUTHOR				=> 'Mike Pultz <mike@fonolo.com>',
	VERSION_FROM			=> 'lib/Net/fonolo.pm',
	ABSTRACT_FROM			=> 'lib/Net/fonolo.pm',
	PL_FILES			=> {},
	PREREQ_PM => {
		'JSON::RPC::Client'	=> 0,
		'LWP::UserAgent'	=> 0,
		'HTTP::Headers'		=> 0,
		'Crypt::SSLeay'		=> 0,
	},
	dist				=> { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean				=> { FILES => 'Net-fonolo-*' },
);
