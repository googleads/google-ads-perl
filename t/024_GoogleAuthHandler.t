#!/usr/bin/perl -w
#
# Copyright 2026, Google LLC and contributors
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
# Unit tests for the Google::Ads::GoogleAds::GoogleAuthHandler.

use strict;
use warnings;

use lib       qw(lib t/utils);
use TestUtils qw(get_mock_client_no_auth);

use Test::More;

# Check for soft dependency
BEGIN {
  my $has_google_auth = eval {
    require Google::Auth;
    Google::Auth->VERSION(0.10);
    1;
  };
  if (!$has_google_auth) {
    plan skip_all => "Google::Auth >= 0.10 required for these tests";
  } else {
    plan tests => 11;
  }
}

use Test::MockObject;

# Mock Google::Auth and the credential object before loading the handler
my $mock_creds = Test::MockObject->new();
$mock_creds->mock("access_token", sub { "mocked_token" });

my $mock_auth = Test::MockObject->new();
$mock_auth->fake_module("Google::Auth", default => sub { $mock_creds });

# Tests use Google::Ads::GoogleAds::GoogleAuthHandler.
use_ok("Google::Ads::GoogleAds::GoogleAuthHandler");

my $handler         = Google::Ads::GoogleAds::GoogleAuthHandler->new();
my $api_client_mock = get_mock_client_no_auth();

ok(!$handler->is_auth_enabled(), "The auth handler is not enabled yet.");

# Initialize without opt-in flag
$handler->initialize($api_client_mock, {});

ok(!$handler->is_auth_enabled(),
  "The auth handler is not enabled without opt-in flag.");

# Initialize with opt-in flag
my $handler_enabled = Google::Ads::GoogleAds::GoogleAuthHandler->new();
$handler_enabled->initialize($api_client_mock, { useApplicationDefaultCredentials => 1 });

ok($handler_enabled->is_auth_enabled(),
  "The auth handler is enabled after initialization with opt-in flag (1).");

# Initialize with opt-in flag as string "true"
my $handler_true = Google::Ads::GoogleAds::GoogleAuthHandler->new();
$handler_true->initialize($api_client_mock, { useApplicationDefaultCredentials => "true" });
ok($handler_true->is_auth_enabled(),
  "The auth handler is enabled after initialization with opt-in flag ('true').");

# Initialize with opt-in flag as string "false"
my $handler_false = Google::Ads::GoogleAds::GoogleAuthHandler->new();
$handler_false->initialize($api_client_mock, { useApplicationDefaultCredentials => "false" });
ok(!$handler_false->is_auth_enabled(),
  "The auth handler is NOT enabled after initialization with opt-in flag ('false').");

# Use the enabled handler for the rest of the tests
$handler = $handler_enabled;

# Test prepare_request
my $http_headers = [];
my $request =
  $handler->prepare_request("GET", "http://example.com", $http_headers, "");

ok($request, "prepare_request returned a request object");
is($request->method(), "GET",                "HTTP method is GET");
is($request->uri(),    "http://example.com", "URL is correct");

# Check headers
my $auth_header = $request->header("Authorization");
is($auth_header, "Bearer mocked_token",
  "Authorization header is set correctly");

# Test failure to get token
$mock_creds->mock("access_token", sub { undef });
my $failed_request;
{
  local $SIG{__WARN__} = sub { };
  $failed_request =
    $handler->prepare_request("GET", "http://example.com", [], "");
}
ok(!$failed_request, "prepare_request returns undef if token fails");
