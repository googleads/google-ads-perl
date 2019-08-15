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
# Unit tests for the Google::Ads::GoogleAds::OAuth2ApplicationsHandler module.

use strict;
use warnings;

use lib qw(lib t/utils);
use TestUtils qw(get_test_client_no_auth);

use Test::More(tests => 31);
use Test::MockObject;

# Tests use Google::Ads::GoogleAds::OAuth2ApplicationsHandler.
use_ok("Google::Ads::GoogleAds::OAuth2ApplicationsHandler");

my $user_agent_mock = Test::MockObject->new();
$user_agent_mock->mock(env_proxy => sub { });

my $handler = Google::Ads::GoogleAds::OAuth2ApplicationsHandler->new(
  {__user_agent => $user_agent_mock});

my $client = get_test_client_no_auth();
is(
  $client->get_version(),
  Google::Ads::GoogleAds::Constants::DEFAULT_API_VERSION,
  "The default API version."
);

ok(!$handler->is_auth_enabled(), "The auth handler is not enabled yet.");

# Tests auth handler default attributes.
is($handler->get_access_type(), "offline", "Default value of access_type.");
is($handler->get_prompt(),      "consent", "Default value of prompt.");
is($handler->get_redirect_uri(),
  "urn:ietf:wg:oauth:2.0:oob", "Default value of redirect_uri.");
is($handler->get_additional_scopes(),
  undef, "Default value of additional_scope.");
is_deeply(
  $handler->_scope(),
  qw(https://www.googleapis.com/auth/adwords),
  "Default value of scope."
);
is(
  $handler->_formatted_scopes(),
  "https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fadwords",
  "Default value of escaped scope."
);

$handler->initialize(
  $client,
  {
    clientId         => "client-id",
    clientSecret     => "client-secret",
    accessType       => "access-type",
    approvalPrompt   => "approval-prompt",
    accessToken      => "access-token",
    refreshToken     => "refresh-token",
    redirectUri      => "uri",
    additionalScopes => "https://www.googleapis.com/auth/analytics"
  });

$user_agent_mock->mock(
  request => sub {
    my $response = HTTP::Response->new(200, "");
    $response->content(
      "{\n\"scope\":\"https://www.googleapis.com/auth/analytics " .
        "https://www.googleapis.com/auth/adwords\"\n\"expires_in\":" .
        (time + 1000) . "\n}");

    return $response;
  });

# Tests auth handler initialization.
is($handler->get_client_id(),     "client-id",     "Initialize client_id.");
is($handler->get_client_secret(), "client-secret", "Initialize client_secret.");
is($handler->get_access_type(),   "access-type",   "Initialize access_type.");
is($handler->get_prompt(),       "approval-prompt", "Initialize prompt.");
is($handler->get_access_token(), "access-token",    "Initialize access_token.");
is($handler->get_refresh_token(), "refresh-token", "Initialize refresh_token.");
is($handler->get_redirect_uri(),  "uri",           "Initialize redirect_uri.");
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
  $handler->_formatted_scopes(),
  "https%3A%2F%2Fwww.googleapis.com%2F" .
    "auth%2Fanalytics+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fadwords",
  "Initialize escaped auth scopes."
);

ok($handler->get_access_token_expires(),
  "Test token info response with access_token_expires.");

# Tests OAuth2 Flow methods.
is(
  $handler->get_authorization_url("state"),
  "https://accounts.google.com/o/oauth2/v2/auth?response_type=code&client_id="
    . "client-id&redirect_uri=uri&scope=https%3A%2F%2Fwww.googleapis.com%2F"
    . "auth%2Fanalytics+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fadwords"
    . "&access_type=access-type&prompt=approval-prompt&state=state",
  "Test authorization url."
);

$user_agent_mock->mock(
  request => sub {
    my ($self, $request) = @_;

    is(
      $request->content,
      "code=code&client_id=client-id&client_secret=client-secret&redirect_uri="
        . "uri&grant_type=authorization_code",
      "Test token request content."
    );
    is($request->method, "POST", "Test token request HTTP method.");
    is(
      $request->url,
      "https://www.googleapis.com/oauth2/v4/token",
      "Test token request URL."
    );

    my $response = Test::MockObject->new();
    $response->mock(is_success => sub { 0 });
    $response->mock(
      decoded_content => sub { return "{\n\"error\":\"invalid_request\"\n}" });

    return $response;
  });

is(
  $handler->issue_access_token("code"),
  "{\n\"error\":\"invalid_request\"\n}",
  "Test error response when issuing access token."
);

$user_agent_mock->mock(
  request => sub {
    my ($self, $request) = @_;

    is(
      $request->content,
      "code=code&client_id=client-id&client_secret=client-secret&redirect_uri="
        . "uri&grant_type=authorization_code",
      "Test token request content."
    );
    is($request->method, "POST", "Test token request HTTP method.");
    is(
      $request->url,
      "https://www.googleapis.com/oauth2/v4/token",
      "Test token request URL."
    );

    my $response = Test::MockObject->new();
    $response->mock(is_success => sub { 1 });
    $response->mock(
      decoded_content => sub {
        return "{\n\"access_token\":\"123\"\n\"expires_in\":3920\n" .
          "\"refresh_token\":\"345\"\n}";
      });

    return $response;
  });

ok(!$handler->issue_access_token("code"),
  "Test success response when issuing access_token.");
is($handler->get_access_token(),  "123", "Read issued access_token.");
is($handler->get_refresh_token(), "345", "Read issued refresh_token.");
