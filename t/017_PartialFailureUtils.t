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
# Unit tests for the Google::Ads::GoogleAds::Utils::PartialFailureUtils module.

use strict;
use warnings;

use lib qw(lib t/utils);
use TestUtils qw(read_file_content);

use JSON::XS;
use Test::More (tests => 20);

# Tests use Google::Ads::GoogleAds::Utils::PartialFailureUtils.
use_ok("Google::Ads::GoogleAds::Utils::PartialFailureUtils");

# Tests the is_partial_failure_result() method.
ok(is_partial_failure_result({}),
  "Test is_partial_failure_result(): empty hash.");
ok(is_partial_failure_result(undef),
  "Test is_partial_failure_result(): undef.");
ok(
  !is_partial_failure_result({
      resourceName => "customers/1234/adGroups/5678"
    }
  ),
  "Test is_partial_failure_result(): hash with 'resourceName' value."
);

# Reads the sample partial failure response from "partial_failure_response.json".
my $json_text = read_file_content("testdata", "partial_failure_response.json");
my $partial_failure_response = decode_json($json_text);

# Tests the get_google_ads_failure() method.
my $google_ads_failure = get_google_ads_failure(
  $partial_failure_response->{partialFailureError}{details}[0]);
ok(
  $google_ads_failure->isa(
    "Google::Ads::GoogleAds::V21::Errors::GoogleAdsFailure"),
  "Test get_google_ads_failure(): class type."
);
is($google_ads_failure->{errors}[0]{errorCode}{requestError},
  "BAD_RESOURCE_ID", "Test get_google_ads_failure(): error code 1.");
is($google_ads_failure->{errors}[1]{errorCode}{adGroupError},
  "DUPLICATE_ADGROUP_NAME", "Test get_google_ads_failure(): error code 2.");

# Tests the get_google_ads_errors() method.
my $partial_failure_error = $partial_failure_response->{partialFailureError};
my $google_ads_errors_1   = get_google_ads_errors(1, $partial_failure_error);
is(ref $google_ads_errors_1,
  "ARRAY", "Test get_google_ads_errors(): return type is ARRAY.");
is(scalar @$google_ads_errors_1,
  1, "Test get_google_ads_errors(): operation 1 - number of elements.");
ok(
  $google_ads_errors_1->[0]
    ->isa("Google::Ads::GoogleAds::V21::Errors::GoogleAdsError"),
  "Test get_google_ads_errors(): operation 1 - element type."
);
is($google_ads_errors_1->[0]{errorCode}{requestError},
  "BAD_RESOURCE_ID", "Test get_google_ads_errors(): operation 1 - error code.");
is(
  $google_ads_errors_1->[0]{message},
  "'{campaign_id}' part of the resource name is invalid.",
  "Test get_google_ads_errors(): operation 1 - message."
);
is(
  $google_ads_errors_1->[0]{location}{fieldPathElements}[0]{fieldName},
  "operations",
  "Test get_google_ads_errors(): operation 1 - field path -> field name."
);
is($google_ads_errors_1->[0]{location}{fieldPathElements}[0]{index},
  1, "Test get_google_ads_errors(): operation 1 - field path -> index.");

my $google_ads_errors_2 = get_google_ads_errors(2, $partial_failure_error);
is(scalar @$google_ads_errors_2,
  1, "Test get_google_ads_errors(): operation 2 - number or elements.");
ok(
  $google_ads_errors_2->[0]
    ->isa("Google::Ads::GoogleAds::V21::Errors::GoogleAdsError"),
  "Test get_google_ads_errors(): operation 2 - element type."
);
is($google_ads_errors_2->[0]{errorCode}{adGroupError},
  "DUPLICATE_ADGROUP_NAME",
  "Test get_google_ads_errors(): operation 2 - error code.");
is(
  $google_ads_errors_2->[0]{message},
  "AdGroup with the same name already exists for the campaign.",
  "Test get_google_ads_errors(): operation 2 - message."
);
is(
  $google_ads_errors_2->[0]{location}{fieldPathElements}[0]{fieldName},
  "operations",
  "Test get_google_ads_errors(): operation 2 - field path -> field name."
);
is($google_ads_errors_2->[0]{location}{fieldPathElements}[0]{index},
  2, "Test get_google_ads_errors(): operation 2 - field path -> index.");

