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
# Unit tests for the Google::Ads::GoogleAds::GoogleAdsException module.

use strict;
use warnings;

use lib qw(lib t/utils);
use TestUtils qw(read_file_content);

use JSON::XS;
use Test::More(tests => 14);

# Tests use Google::Ads::GoogleAds::GoogleAdsException.
use_ok("Google::Ads::GoogleAds::GoogleAdsException");

# Tests GoogleAdsException initialization using the text in "exception_google_ads_failure.json",
# which contains a GoogleAdsFailure object.
my $json_text =
  read_file_content('testdata', 'exception_google_ads_failure.json');

my $response_body = decode_json($json_text);
my $exception = Google::Ads::GoogleAds::GoogleAdsException->new($response_body);

ok(
  $exception->isa("Google::Ads::GoogleAds::GoogleAdsException"),
  "GoogleAdsFailure : Test GoogleAdsException->new()."
);

is($exception->get_code, 400, "GoogleAdsFailure : Read of exception code.");

is(
  $exception->get_message,
  "Request contains an invalid argument.",
  "GoogleAdsFailure : Read of exception message."
);

is($exception->get_status, "INVALID_ARGUMENT",
  "GoogleAdsFailure : Read of exception status.");

# Tests the get_google_ads_failure() method and the returned GoogleAdsFailure object.
my $google_ads_failure = $exception->get_google_ads_failure;

ok(
  $google_ads_failure->isa(
    "Google::Ads::GoogleAds::V23::Errors::GoogleAdsFailure"),
  "GoogleAdsFailure : Get the GoogleAdsFailure object."
);

ok(
  eq_hash(
    $google_ads_failure->{errors}[0]{errorCode},
    {queryError => "UNRECOGNIZED_FIELD"}
  ),
  "GoogleAdsFailure : Read of error code from GoogleAdsFailure."
);

is(
  $google_ads_failure->{errors}[1]{message},
  "There is a problem with the snippet.",
  "GoogleAdsFailure : Read of error message from GoogleAdsFailure."
);

is(
  $google_ads_failure->{errors}[1]{location}{fieldPathElements}[0]{fieldName},
  "snippet",
  "GoogleAdsFailure : Read of error location field path from GoogleAdsFailure."
);

# Tests GoogleAdsException initialization using the text in "exception_bad_request.json",
# which contains a google.rpc.BadRequest object.
$json_text = read_file_content("testdata", "exception_bad_request.json");

$response_body = decode_json($json_text);
$exception = Google::Ads::GoogleAds::GoogleAdsException->new($response_body);

ok($exception->isa("Google::Ads::GoogleAds::GoogleAdsException"),
  "BadRequest : Test GoogleAdsException->new().");

is($exception->get_code, 400, "BadRequest : Read of exception code.");

is(
  $exception->get_message,
  "Invalid value at 'operations[0].update.status' (TYPE_ENUM), \"adsf\"\n" .
    "Invalid JSON payload received. Unknown name \"paths1\" at " .
    "'operations[0].update_mask': Cannot find field.",
  "BadRequest : Read of exception message."
);

is($exception->get_status, "INVALID_ARGUMENT",
  "BadRequest : Read of exception status.");

# Tests the get_google_ads_failure() method and expects an undef response.
$google_ads_failure = $exception->get_google_ads_failure;

is($google_ads_failure, undef, "BadRequest : Get the GoogleAdsFailure object.");
