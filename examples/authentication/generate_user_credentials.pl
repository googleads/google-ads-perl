#!/usr/bin/perl -w
#
# Copyright 2019, Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# This example will create an OAuth2 refresh token for the Google Ads API.
# This works with both web and desktop app OAuth client ID types.
#
# This example will start a basic server that listens for requests at
# http://127.0.0.1:PORT, where PORT defaults to 8080 as below.
#
#
# [IMPORTANT]: For web app client types, you must add http://127.0.0.1 to the
# "Authorize redirect URIs" list in your Google Cloud Console project before
# running this example. Desktop app client types do not require the local
# redirect to be explicitly configured in the console.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);
use Digest::SHA  qw(sha1_hex);

use constant OAUTH2_CALLBACK_BASE_URI => "http://127.0.0.1";
use constant PORT                     => 8080;

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $client_id         = "INSERT_CLIENT_ID_HERE";
my $client_secret     = "INSERT_CLIENT_SECRET_HERE";
my $additional_scopes = "INSERT_ADDITIONAL_SCOPES_HERE";

# Create an anti-forgery state token as described here:
# https://developers.google.com/identity/protocols/OpenIDConnect#createxsrftoken
our $state = sha1_hex(uniqid);

sub generate_user_credentials {
  my ($api_client, $client_id, $client_secret, $additional_scopes) = @_;

  my $auth_handler = $api_client->get_oauth2_handler();

  my $callback_url = sprintf("%s:%d", OAUTH2_CALLBACK_BASE_URI, PORT);

  $auth_handler->set_client_id($client_id);
  $auth_handler->set_client_secret($client_secret);
  $auth_handler->set_redirect_uri($callback_url);
  $auth_handler->set_additional_scopes($additional_scopes)
    if check_params($additional_scopes);

  # Open a browser and point it to the authorization URL, authorize the access.
  print
    "\nPaste this url in your browser:\n",
    $auth_handler->get_authorization_url($state), "\n\n";

  printf "Waiting for authorization and callback to %s ...\n", $callback_url;

  SimpleCallbackServer->new(PORT, $auth_handler)->run;

  return 1;
}

{
  # Simple CGI server that listens for the OAuth2 callback.
  package SimpleCallbackServer;

  use HTTP::Server::Simple::CGI;
  use base qw(HTTP::Server::Simple::CGI);

  sub new {
    my ($class, $port, $auth_handler) = @_;
    my $self = HTTP::Server::Simple::CGI->new($port);

    $self->{auth_handler} = $auth_handler;

    bless $self, $class;
    return $self;
  }

  my %dispatch = ('/' => \&resp_callback);

  sub handle_request {
    my ($self, $cgi) = @_;

    my $path    = $cgi->path_info;
    my $handler = $dispatch{$path};

    if (ref($handler) eq "CODE") {
      print "HTTP/1.0 200 OK\r\n";
      $handler->($self, $cgi);
    } else {
      print "HTTP/1.0 404 Not found\r\n";
      print $cgi->header,
        $cgi->start_html('Not found'),
        $cgi->h1('Not found'),
        $cgi->end_html;
    }
  }

  # The method to handle the callback request after user logs in and accepts
  # the OAuth2 prompt. An authorization code will be returned which can be
  # exchanged for an access token and refresh token.
  sub resp_callback {
    my ($self, $cgi) = @_;
    return if !ref $cgi;

    # Get the authorization code and state parameters from the URL.
    my $code  = $cgi->param('code');
    my $state = $cgi->param('state');

    if (!$code) {
      print "\r\n<b>Failed to retrieve the authorization code.<b>";
    } elsif ($state ne $main::state) {
      # Confirm that the state in the response matches the state token used to
      # generate the authorization URL.
      print
        "\r\n<b>State in the callback does not match the expected value.<b>";
    } else {
      my $auth_handler = $self->{auth_handler};
      $auth_handler->issue_access_token($code);

      # After the access token and refresh token are generated, you should store the
      # refresh token and reuse it for future calls, by either changing your
      # googleads.properties file or setting in the authorization handler as follows:
      #
      # $api_client->get_oauth2_handler()->set_client_id($client_id);
      # $api_client->get_oauth2_handler()->set_client_secret($client_secret);
      # $api_client->get_oauth2_handler()->set_refresh_token($refresh_token);
      print "\r\n<b>Authorization code was successfully retrieved.</b>";
      print "<p><b>Replace the following keys and values in your " .
        "googleads.properties configuration file:</b><p>";
      printf(
        "clientId=%s<br>clientSecret=%s<br>refreshToken=%s<br>",
        $auth_handler->get_client_id,
        $auth_handler->get_client_secret,
        $auth_handler->get_refresh_token
      );

      print STDERR "Press Ctrl+C to quit.\n";
    }
  }
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client with the default API version.
my $api_client = Google::Ads::GoogleAds::Client->new();

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  'client_id=s'         => \$client_id,
  'client_secret=s'     => \$client_secret,
  'additional_scopes=s' => \$additional_scopes
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($client_id, $client_secret);

# Call the example.
generate_user_credentials($api_client, $client_id, $client_secret,
  $additional_scopes);

=pod

=head1 NAME

generate_user_credentials

=head1 DESCRIPTION

This example will create an OAuth2 refresh token for the Google Ads API for either a web
or desktop app OAuth client ID.

For web app client types, you must add B<http://127.0.0.1> to the "Authorize redirect URIs"
list in your L<Google Cloud Console project|https://console.developers.google.com/apis/credentials>
before running this example, where PORT defaults to 8080. Desktop app client types do not
require the local redirect to be explicitly configured in the Cloud console.

=head1 SYNOPSIS

generate_user_credentials.pl [options]

    -help                       Show the help message.
    -client_id                  The OAuth2 client id.
    -client_secret              The OAuth2 client secret
    -additional_scopes          [optional] Additional OAuth2 scopes seperated by comma.

=cut
