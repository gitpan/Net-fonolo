#
# Net::fonolo - PERL OO interface to the fonolo developer API (http://consumer.fonolo.com)
#
# Copyright (c) 2011, FonCloud, Inc.
# All rights reserved.
#
# This software is licensed under a BSD style license; see COPYING for details.
#
# Written by Mike Pultz (mike@mikepultz.com)
#
package Net::fonolo;
$VERSION = "1.4";

use warnings;
use strict;
require HTTP::Headers;
use JSON::RPC::Client;

sub new
{
	my $_class = shift;

	my %_conf = @_;
	my %values = ();

	#
	# Fonolo API RPC Host
	#
	if (defined($_conf{rpcurl}))
	{
		$values{rpcurl} = $_conf{rpcurl};
	} else
	{
		$values{rpcurl} = "https://json-rpc.live.fonolo.com";
	}

	#
	# Custom HTTP user agent
	#
	if (defined($_conf{useragent}))
	{
		$values{useragent} = $_conf{useragent};
	} else
	{
		$values{useragent} = "Net::fonolo/$Net::fonolo::VERSION";
	}

	#
	# set a developer key if it's provided
	#
	if (defined($_conf{key}))
	{
		if ($_conf{key} =~ /^[a-zA-Z0-9]{32}$/)
		{
			$values{key} = $_conf{key};
		}
	}

	#
	# set auth info if it's provided
	#
	if ( (defined($_conf{username})) && (defined($_conf{password})) )
	{
		$values{username} = $_conf{username};
		$values{password} = $_conf{password};
	}

	#
	# create the JSON::RPC::Client object
	#
	$values{client} = new JSON::RPC::Client;

	return bless {%values}, $_class;
}

#
# set a developer key
#
sub set_key
{
	my ($_self, $_key) = @_;

	if (defined($_key))
	{
		if ($_key =~ /^[a-zA-Z0-9]{32}$/)
		{
			$_self->{key} = $_key;
		}
	}
}

#
# set a username/password for authentication
#
sub set_auth
{
	my ($_self, $_username, $_password) = @_;

	if ( (defined($_username)) && (defined($_password)) )
	{
		$_self->{username} = $_username;
		$_self->{password} = $_password;
	}
}

#
# send a auth request
#
sub _send_request
{
	my ($_self, $_obj) = @_;

	#
	# set the developer key header
	#
	$_self->{client}->ua()->default_headers()->header('X-Fonolo-Auth' => $_self->{key});

	#
	# set the username/password headers
	#
	$_self->{client}->ua()->default_headers()->header('X-Fonolo-Username' => $_self->{username});
	$_self->{client}->ua()->default_headers()->header('X-Fonolo-Password' => $_self->{password});
	
	#
	# set the useragent header
	#
	$_self->{client}->ua()->agent($_self->{useragent});

	#
	# execute the request
	#
	my $res = $_self->{client}->call($_self->{rpcurl}, $_obj);

	if (defined($res->{content}->{result}))
	{
		return $res->{content}->{result};
	} else
	{
		return undef;
	}
}

#
# deprecated (renamed) functions
#
sub lookup_company
{
	return company_details(@_);
}
sub list_companies
{
	return company_list(@_);
}
sub search_companies
{
	return company_search(@_);
}

#
# API functions
#
sub get_error
{
        my ($_self) = @_;

        my $obj = {
                method => 'garbage'
        };

        my $res = _send_request($_self, $obj);

        return _send_request($_self, $obj);
}

sub get_version
{
	my ($_self) = @_;

	my $obj = {
		method => 'system.describe'
	};

	if (!defined($_self->{key}))
	{
		$_self->{key} = '000000000000000000000000000000';
	}

	my $res = _send_request($_self, $obj);

	if ($_self->{key} eq '000000000000000000000000000000')
	{
		delete($_self->{key});
	}

	if (defined($res->{version}))
	{
		return $res->{version};
	} else
	{
		return undef;
	}
}
sub check_member
{
	my ($_self) = @_;

	my $obj = {
		method => 'check_member',
		params => [$_self->{username}, $_self->{password}]
	};

	return _send_request($_self, $obj);
}
sub check_member_number
{
	my ($_self, $_number) = @_;

	my $obj = {
		method => 'check_member',
		params => [$_self->{username}, $_self->{password}, $_number]
	};

	return _send_request($_self, $obj);
}
sub company_search
{
	my ($_self, $_search) = @_;

	my $obj = {
		method => 'company_search',
		params => [$_search]
	};

	return _send_request($_self, $obj);
}
sub company_list
{
	my ($_self, $_limit, $_page, $_date_since) = @_;

	my $obj = {
		method => 'company_list',
		params => [$_limit, $_page, $_date_since]
	};

	return _send_request($_self, $obj);
}
sub company_details
{
	my ($_self, $_company) = @_;

	my $obj = {
		method => 'company_details',
		params => [$_company]
	};

	return _send_request($_self, $obj);
}
sub call_start
{
	my ($_self, $_company, $_number) = @_;

	my $obj = {
		method => 'call_start',
		params => [$_company, $_number]
	};

	return _send_request($_self, $obj);
}
sub call_cancel
{
	my ($_self, $_call_id) = @_;

	my $obj = {
		method => 'call_cancel',
		params => [$_call_id]
	};

	return _send_request($_self, $obj);
}
sub call_status
{
	my ($_self, $_call_id) = @_;

	my $obj = {
		method => 'call_status',
		params => [$_call_id]
	};

	return _send_request($_self, $obj);
}

1;
__END__

=head1 NAME

Net::fonolo - Perl interface to fonolo (http://consumer.fonolo.com)

=head1 VERSION

This document describes Net::fonolo version 1.4

=head1 SYNOPSIS

#!/usr/bin/perl

use Net::fonolo;

my $fonolo = Net::fonolo->new(

    key         => "< your fonolo developer API key >",
    username    => "< a fonolo member username >",
    password    => "< a fonolo member password >"
);

my $result = $fonolo->search_companies("air canada");

...

=head1 DESCRIPTION

=over

=item new(...)

You must supply a hash containing the configuration for the connection.

Valid configuration items are:

=over                  

=item C<key>

Your fonolo.com API developer key. You can get a developer key by signing up fro the fonolo developer
program from the accounts tab of your fonolo.com account. REQUIRED.


=item C<username>

Username of the account at fonolo.com. This is usually your email address. REQUIRED.

=item C<password>

Password of your account at fonolo. REQUIRED.

=item C<useragent>

OPTIONAL: Sets the User Agent header in the HTTP request. If omitted, this will default to
"Net::fonolo/$Net::fonolo::VERSION"

=back

=item set_key($api_developer_key

Change the fonolo developer API key for sending API requests.

$api_developer_key is the 32 byte API key, listed on the projects page for your application.

=item set_auth($username, $password

Change the username/password for logging into fonolo.com. This is helpful when managing multiple
accounts.

$username is the fonolo.com username (e-mail address) of the client account.

$password is the plain-text password or the client account.

=back

=head2 SYSTEM FUNCTIONS

=over

=item get_version

Return the current fonolo.com RPC server version

=back

=head2 MEMBER FUNCTIONS

=over

=item check_member

Validates the current username/password, set by the new or set_auth methods.

=item check_member_number($phone_number)

Validates that the given phone number belongs to the current username/password, and that it's
active. "Deep Dial" requests can only be made to numbers that are currently configured on the
given fonolo.com account.

$phone_number is the phone number to validated, formatted as XXX-YYY-ZZZZ. This value can also be 
a SIP address in the format: sip:XXX@YYY

=back

=head2 COMPANY FUNCTIONS

=over

=item company_search($search_string)

Perform a search against the fonolo.com database for the given search string.

$search_string can be either a free-form keyword to search, or a company phone number, formated
as XXX-YYY-ZZZZ.

=item company_list

=item company_list($limit)

=item company_list($limit, $page)

=item company_list($limit, $page, $date_since)

Returns a list of all the companies in the fonolo.com database. 

$limit is how many results to return per page; this defaults to 25.

$page is the page number starting with 0; this defaults to 0 (the first page)

$date_since is a date (formatted as YYYY-MM-DD); if this date is included, then only companies
with updates newer than this date are returned in the result set. If it's not included, then
all results are returned.

This is helpful for situations where you want to cache the company list on the application side,
and then get incremental updates each time the application is started.

=item company_details($company_id)

Lookup specific information about the given company id.

$company_id is the 32 byte company id, returned by the company_list or company_search methods.

=back

=head2 DEEP DIAL FUNCTIONS

=over

=item call_start($company_id, $phone_number)

Start a "Deep Dial" request to the given company_id and phone_number. This phone_number must pass
validation through the check_member_number method.

$company_id is the 32 byte company id returned by the company_* functions above.

$phone_number is the phone number to call-back, formatted as XXX-YYY-ZZZZ.

=item call_cancel($call_id)

Cancel a call that was previously started by the call_start method. 

$call_id is the call id returned by the call_start method.

=item call_status($call_id)

Return the current call status of the call referenced by the $call_id. 

$call_id is the call id returned by the call_start method.

=back

=head2 DEPRECATED FUNCTIONS

=over

=item search_companies

see company_search above

=item list_companies

see company_list above

=item lookup_company

see company_details above

=back

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-net-fonolo@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

Mike Pultz <mike@mikepultz.com>

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES          
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR        
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE                       
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING        
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
