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
# This script creates the API client objects and runs the migration examples.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::AdWords::Client;

# The following parameter(s) should be provided to run the example. You can
# specify these by changing the INSERT_XXX_ID_HERE values below.
my $developer_token = "INSERT_DEVELOPER_TOKEN_HERE";
my $client_id       = "INSERT_OAUTH2_CLIENT_ID_HERE";
my $client_secret   = "INSERT_OAUTH2_REFRESH_TOKEN_HERE";
my $refresh_token   = "INSERT_OAUTH2_REFRESH_TOKEN_HERE";
# Replace the below string with your (client) customer ID as "an integer".
# Although the AdWords API library can handle a client customer ID as a
# string with hyphens included, this variable is also shared with the
# Google Ads API client library, which accepts only customer ID as an integer.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";
# Login Customer ID is a new configuration setting required in Google Ads API.
# This is the customer ID of the authorized customer to use in the request,
# without hyphens (-). If your access to the customer account is through a
# manager account, this parameter is required and must be set to the customer
# ID of the manager account.
# See https://developers.google.com/google-ads/api/docs/concepts/call-structure#login-customer-id
# to learn more about this setting.
my $login_customer_id = "INSERT_LOGIN_CUSTOMER_ID_HERE";

sub run_example {
  my ($developer_token, $client_id, $client_secret, $refresh_token,
    $customer_id, $login_customer_id)
    = @_;

  # Construct a Google Ads client to be used for Google Ads API calls.
  my $google_ads_client = Google::Ads::GoogleAds::Client->new({
    developer_token   => $developer_token,
    login_customer_id => $login_customer_id
  });

  my $oauth_handler = $google_ads_client->get_oauth_2_handler();
  $oauth_handler->set_client_id($client_id);
  $oauth_handler->set_client_secret($client_secret);
  $oauth_handler->set_refresh_token($refresh_token);

  # By default examples are set to die on any server returned fault.
  $google_ads_client->set_die_on_faults(1);

  # Construct an AdWords client to be used for AdWords API calls.
  my $adwords_client = Google::Ads::AdWords::Client->new({
    developer_token => $developer_token,
    client_id       => $customer_id
  });
  $oauth_handler = $adwords_client->get_oauth_2_handler();
  $oauth_handler->set_client_id($client_id);
  $oauth_handler->set_client_secret($client_secret);
  $oauth_handler->set_refresh_token($refresh_token);

  # By default examples are set to die on any server returned fault.
  $adwords_client->set_die_on_faults(1);

  # Log SOAP XML request, response and API errors.
  Google::Ads::AdWords::Logging::enable_all_logging();

  # Uncomment the relevant code example to run it.

  # require "$Bin/campaign_management/create_complete_campaign_adwords_api_only.pl";
  # create_complete_campaign_adwords_api_only($adwords_client);

  # require "$Bin/campaign_management/create_complete_campaign_both_apis_phase_1.pl";
  # create_complete_campaign_both_apis_phase_1($adwords_client, $google_ads_client, $customer_id);

  # require "$Bin/campaign_management/create_complete_campaign_both_apis_phase_2.pl";
  # create_complete_campaign_both_apis_phase_2($adwords_client, $google_ads_client, $customer_id);

  # require "$Bin/campaign_management/create_complete_campaign_both_apis_phase_3.pl";
  # create_complete_campaign_both_apis_phase_3($adwords_client, $google_ads_client, $customer_id);

  # require "$Bin/campaign_management/create_complete_campaign_both_apis_phase_4.pl";
  # create_complete_campaign_both_apis_phase_4($adwords_client, $google_ads_client, $customer_id);

  # require "$Bin/campaign_management/create_complete_campaign_google_ads_api_only.pl";
  # create_complete_campaign_google_ads_api_only($google_ads_client, $customer_id);

  return 1;
}

die "Provide the necessary parameters above to run this example.\n"
  if not check_params($developer_token, $client_id, $client_secret,
  $refresh_token, $customer_id, $login_customer_id);

run_example($developer_token, $client_id, $client_secret, $refresh_token,
  $customer_id, $login_customer_id);

=pod

=head1 NAME

run_example

=head1 DESCRIPTION

This script creates the API client objects and runs the migration examples.

=head1 SYNOPSIS

run_example.pl [options]

    -help                           Show the help message.

=cut
