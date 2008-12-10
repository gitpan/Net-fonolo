use Test::More tests => 2;

BEGIN 
{
	use_ok('Net::fonolo');
}

diag("Testing Net::fonolo $Net::fonolo::VERSION");

my $f = new Net::fonolo();
if (defined($f))
{
        my $ver = $f->get_version();

        ok(defined($ver));
        diag("found server version $ver");
}

1;
