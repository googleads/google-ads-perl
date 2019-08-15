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
# Unit (not functional) tests for the Google::Ads::GoogleAds::GoogleAdsClient
# module. Functional tests of the various Google Ads API services will be
# performed in a separate test.

use strict;
use warnings;

use lib "lib";
use File::Basename;
use File::Spec;
use Test::More (tests => 17);

# Tests use Google::Ads::GoogleAds::GoogleAdsClient.
use_ok("Google::Ads::GoogleAds::GoogleAdsClient")
  or die "Cannot load 'Google::Ads::GoogleAds::GoogleAdsClient.'";

# Tests client initialization, including reading from properties files.
my $properties_file =
  File::Spec->catdir(dirname($0), qw(testdata googleads_mock.properties));
my $login_customer_id = "login_customer_id_override";

my $api_client = Google::Ads::GoogleAds::GoogleAdsClient->new({
  login_customer_id => $login_customer_id,
  properties_file   => $properties_file
});

is($api_client->get_developer_token(), "dev-token", "Read of developer token.");
is($api_client->get_login_customer_id(),
  $login_customer_id, "Override of login customer ID.");
is(
  $api_client->get_service_address(),
  "https://alternate.googleapis.com:443/",
  "Read of service_address."
);
is(
  $api_client->get_proxy(),
  "http://user:password\@proxy_hostname:8080",
  "Read of proxy."
);

is($api_client->get_oauth_2_handler()->get_client_id(),
  "client_1+user\@domain.com", "Read of client ID.");
is($api_client->get_oauth_2_handler()->get_client_secret(),
  "oauth2-client-secret", "Read of client secret.");
is($api_client->get_oauth_2_handler()->get_refresh_token(),
  "refresh-token", "Read of refresh token.");

# Tests basic get/set methods.
$api_client->set_die_on_faults(1);
is($api_client->get_die_on_faults(), 1, "The get/set of die_on_faults.");

is(
  $api_client->get_version(),
  Google::Ads::GoogleAds::Constants->DEFAULT_API_VERSION,
  "The default API version."
);
$api_client->set_version("V999");
is($api_client->get_version(), "V999", "The get/set of version.");

$api_client->set_service_address(
  Google::Ads::GoogleAds::Constants->DEFAULT_SERVICE_ADDRESS);
is(
  $api_client->get_service_address(),
  Google::Ads::GoogleAds::Constants->DEFAULT_SERVICE_ADDRESS,
  "The get/set of service_address."
);

# Makes sure this client supports all the services for each version.
$api_client->set_version(
  Google::Ads::GoogleAds::Constants->DEFAULT_API_VERSION);
my @services = qw(CampaignBudgetService CampaignService);
can_ok($api_client, @services);

ok(
  Google::Ads::GoogleAds::GoogleAdsClient->new
    && Google::Ads::GoogleAds::GoogleAdsClient->new,
  "Can construct more than one client object."
);

# Tests set auth properties.
my $test_oauth2_refresh_token = "my_oauth2_refresh_token";
$api_client->get_oauth_2_handler()
  ->set_refresh_token($test_oauth2_refresh_token);
is($api_client->get_oauth_2_handler()->get_refresh_token(),
  $test_oauth2_refresh_token, "The get/set of refresh token.");

my $test_oauth2_client_id = "my_oauth2_client_id";
$api_client->get_oauth_2_handler()->set_client_id($test_oauth2_client_id);
is($api_client->get_oauth_2_handler()->get_client_id(),
  $test_oauth2_client_id, "The get/set of client_id.");

my $test_oauth2_client_secret = "my_oauth2_client_secret";
$api_client->get_oauth_2_handler()
  ->set_client_secret($test_oauth2_client_secret);
is($api_client->get_oauth_2_handler()->get_client_secret(),
  $test_oauth2_client_secret, "The get/set of client_secret.");
