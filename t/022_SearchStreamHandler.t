#!/usr/bin/perl -w
#
# Copyright 2020, Google LLC
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
# Unit tests for the Google::Ads::GoogleAds::Utils::SearchStreamHandler module.

use strict;
use warnings;

use lib qw(lib t/utils);
use TestUtils qw(read_file_content get_mock_client_with_auth);
use Google::Ads::GoogleAds::Logging::GoogleAdsLogger;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use Google::Ads::GoogleAds::V21::Services::GoogleAdsService;
use
  Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;

use HTTP::Request::Common;
use JSON::XS;
use Test::More(tests => 19);
use Test::MockObject;

# Tests use Google::Ads::GoogleAds::Utils::SearchStreamHandler.
use_ok("Google::Ads::GoogleAds::Utils::SearchStreamHandler");

# Creates the mock GoogleAdsService.
my $google_ads_service_mock = Test::MockObject->new();
$google_ads_service_mock->mock(
  search_stream => sub {
    my ($self, $request_body, $content_callback) = @_;

    $content_callback->(
      read_file_content("testdata", "stream_search_response.json"), undef
    );
  });

# Creates the SearchGoogleAdsStreamRequest.
my $search_stream_request =
  Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
  ->new({
    customerId => 1234567890,
    query      =>
      "SELECT campaign.id, campaign.name FROM campaign ORDER BY campaign.id"
  });

# Tests SearchStreamHandler initialization.
my $search_stream_handler =
  Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
    service => $google_ads_service_mock,
    request => $search_stream_request
  });
ok(
  $search_stream_handler->isa(
    "Google::Ads::GoogleAds::Utils::SearchStreamHandler"),
  "Test SearchStreamHandler->new()."
);

my $count = 0;
$search_stream_handler->process_contents(
  sub {
    $count += 1;
    my $google_ads_row = shift;
    my $campaign       = $google_ads_row->{campaign};
    is(
      $campaign->{name},
      "Campaign #" . $count,
      "Test SearchStreamHandler->process_contents() : " . $campaign->{name});
  });

is($count, 8, "Test row count in stream response.");

# Tests the exception handling of SearchStreamHandler.

# Creates the mock API client and lwp agent.
my $api_client_mock = get_mock_client_with_auth();
my $lwp_agent_mock  = Test::MockObject->new();
$lwp_agent_mock->mock("timeout");
$lwp_agent_mock->mock("proxy");
$lwp_agent_mock->mock(
  request => sub {
    return HTTP::Response->new(400, "Bad Request", [],
      read_file_content("testdata", "exception_stream_search.json"));
  });

# Creates the GoogleAdsService.
my $google_ads_service =
  Google::Ads::GoogleAds::V21::Services::GoogleAdsService->new({
    api_client  => $api_client_mock,
    __lwp_agent => $lwp_agent_mock
  });

# Creates the SearchGoogleAdsStreamRequest with invalid query.
$search_stream_request =
  Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
  ->new({
    customerId => 1234567890,
    query      =>
"SELECT campaign.id, campaign.fake_field FROM campaign ORDER BY campaign.id"
  });

# Tests SearchStreamHandler initialization.
$search_stream_handler =
  Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
    service => $google_ads_service,
    request => $search_stream_request
  });
ok(
  $search_stream_handler->isa(
    "Google::Ads::GoogleAds::Utils::SearchStreamHandler"),
  "Test SearchStreamHandler->new()."
);

# Deprecates the warning message and disables all logging during exception handling.
local $SIG{__WARN__} = sub { };
Google::Ads::GoogleAds::Logging::GoogleAdsLogger::disable_all_logging();

# Tests the returned the GoogleAdsException object.
my $google_ads_exception =
  $search_stream_handler->process_contents(sub { my $google_ads_row = shift });

ok(
  $google_ads_exception->isa("Google::Ads::GoogleAds::GoogleAdsException"),
  "GoogleAdsException : Is a Google::Ads::GoogleAds::GoogleAdsException."
);

is($google_ads_exception->get_code(),
  400, "GoogleAdsException : Read of exception code.");

is(
  $google_ads_exception->get_message(),
  "Request contains an invalid argument.",
  "GoogleAdsException : Read of exception message."
);

is($google_ads_exception->get_status(),
  "INVALID_ARGUMENT", "GoogleAdsException : Read of exception status.");

# Tests the get_google_ads_failure() method and the returned GoogleAdsFailure object.
my $google_ads_failure = $google_ads_exception->get_google_ads_failure();

ok(
  $google_ads_failure->isa(
    "Google::Ads::GoogleAds::V21::Errors::GoogleAdsFailure"),
"GoogleAdsFailure : Is a Google::Ads::GoogleAds::V21::Errors::GoogleAdsFailure."
);

ok(
  eq_hash(
    $google_ads_failure->{errors}[0]{errorCode},
    {queryError => "UNRECOGNIZED_FIELD"}
  ),
  "GoogleAdsFailure : Read of error code."
);

is(
  $google_ads_failure->{errors}[0]{message},
  "Unrecognized field in the query: 'campaign.fake_field'.",
  "GoogleAdsFailure : Read of error message."
);
