#!/usr/bin/perl -w
#
# Copyright 2021, Google LLC
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
# Unit tests for the Google::Ads::GoogleAds::OAuth2ServiceAccountsHandler.

use strict;
use warnings;

use lib qw(lib t/utils);
use TestUtils qw(get_mock_client_no_auth);

use Test::More(tests => 16);
use Test::MockObject;

# Tests use Google::Ads::GoogleAds::OAuth2ServiceAccountsHandler.
use_ok("Google::Ads::GoogleAds::OAuth2ServiceAccountsHandler");

my $lwp_agent_mock = Test::MockObject->new();
$lwp_agent_mock->mock("proxy");

my $handler = Google::Ads::GoogleAds::OAuth2ServiceAccountsHandler->new(
  {__lwp_agent => $lwp_agent_mock});

my $api_client_mock = get_mock_client_no_auth();
is(
  $api_client_mock->get_version(),
  Google::Ads::GoogleAds::Constants::DEFAULT_API_VERSION,
  "The default API version."
);

ok(!$handler->is_auth_enabled(), "The auth handler is not enabled yet.");

# Tests auth handler default attributes.
is($handler->get_json_key_file_path(),
  undef, "Default value of json_key_file_path.");
is($handler->get_impersonated_email(),
  undef, "Default value of impersonated_email.");
is($handler->get_additional_scopes(),
  undef, "Default value of additional_scopes.");
is_deeply(
  $handler->_scope(),
  qw(https://www.googleapis.com/auth/adwords),
  "Default value of scope."
);
is(
  $handler->__formatted_scopes(),
  "https://www.googleapis.com/auth/adwords",
  "Default value of formatted scopes."
);

# Tests auth handler initialization.
$handler->initialize(
  $api_client_mock,
  {
    jsonKeyFilePath   => "json-key-file-path",
    impersonatedEmail => "impersonated-email",
    accessToken       => "access-token",
    additionalScopes  => "https://www.googleapis.com/auth/analytics"
  });

$lwp_agent_mock->mock(
  request => sub {
    my $response = HTTP::Response->new(200, "");
    $response->content(
      "{\n\"scope\":\"https://www.googleapis.com/auth/analytics " .
        "https://www.googleapis.com/auth/adwords\"\n\"expires_in\":" .
        (time + 1000) . "\n}");
    return $response;
  });

is($handler->get_json_key_file_path(),
  "json-key-file-path", "Initialize json_key_file_path.");
is($handler->get_impersonated_email(),
  "impersonated-email", "Initialize impersonated_email.");
is($handler->get_access_token(), "access-token", "Initialize access_token.");
is(
  $handler->get_additional_scopes(),
  "https://www.googleapis.com/auth/analytics",
  "Initialize additional_scopes."
);
my @current_scope  = $handler->_scope();
my @expected_scope = qw(https://www.googleapis.com/auth/analytics
  https://www.googleapis.com/auth/adwords);
ok(eq_array(\@current_scope, \@expected_scope), "Initialize auth scopes.");
is(
  $handler->__formatted_scopes(),
  "https://www.googleapis.com/auth/analytics," .
    "https://www.googleapis.com/auth/adwords",
  "Initialize formatted auth scopes."
);
ok($handler->is_auth_enabled(), "The auth handler is enabled.");
ok($handler->get_access_token_expires(),
  "Test token info response with access_token_expires.");
