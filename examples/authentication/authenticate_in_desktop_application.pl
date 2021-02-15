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
# This example will create an OAuth2 refresh token for the Google Ads API using
# the Desktop application flow.
#
# This example is meant to be run from the command line and requires user input.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

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

sub authenticate_in_desktop_application {
  my ($api_client, $client_id, $client_secret, $additional_scopes) = @_;

  my $auth_handler = $api_client->get_oauth2_handler();

  $auth_handler->set_client_id($client_id);
  $auth_handler->set_client_secret($client_secret);
  $auth_handler->set_additional_scopes($additional_scopes)
    if check_params($additional_scopes);

  # Open a browser and point it to the authorization URL, authorize the access
  # and then enter the generated authorization code.
  print
    "\nPaste this url in your browser:\n",
    $auth_handler->get_authorization_url(), "\n\n";

  # Wait for the authorization code.
  print "Type the authorization code you received here: ";

  my $code = <STDIN>;
  $code = trim($code);

  # Request the access token using the authorization code, so it can be used
  # to access the API.
  if (my $error = $auth_handler->issue_access_token($code)) {
    die($error);
  }

  # After the access token and refresh token are generated, you should store the
  # refresh token and reuse it for future calls, by either changing your
  # googleads.properties file or setting in the authorization handler as follows:
  #
  # $api_client->get_oauth2_handler()->set_client_id($client_id);
  # $api_client->get_oauth2_handler()->set_client_secret($client_secret);
  # $api_client->get_oauth2_handler()->set_refresh_token($refresh_token);
  printf
    "\nReplace the following keys and values in your googleads.properties " .
    "configuration file:\n\n" .
    "clientId=%s\n" . "clientSecret=%s\n" . "refreshToken=%s\n\n",
    $client_id, $client_secret,
    $auth_handler->get_refresh_token();

  return 1;
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
authenticate_in_desktop_application($api_client, $client_id, $client_secret,
  $additional_scopes);

=pod

=head1 NAME

authenticate_in_desktop_application

=head1 DESCRIPTION

This example will create an OAuth2 refresh token for the Google Ads API using the
Desktop application flow.

=head1 SYNOPSIS

authenticate_in_desktop_application.pl [options]

    -help                       Show the help message.
    -client_id                  The OAuth2 client id.
    -client_secret              The OAuth2 client secret
    -additional_scopes          [optional] Additional OAuth2 scopes seperated by comma.

=cut
