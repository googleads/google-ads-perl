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
# Unit tests for the Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator module.

use strict;
use warnings;

use lib qw(lib t/utils);
use TestUtils qw(read_file_content);
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use
  Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsRequest;

use JSON::XS;
use Test::More(tests => 11);
use Test::MockObject;

# Tests use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator.
use_ok("Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator");

# Creates the mock GoogleAdsService.
my $json_text = read_file_content("testdata", "paged_search_response.json");
my $paged_search_response = decode_json($json_text);

my $google_ads_service_mock = Test::MockObject->new();
$google_ads_service_mock->mock(
  "search",
  sub {
    return shift @{$paged_search_response};
  });

# Creates the SearchGoogleAdsRequest.
my $search_request =
  Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsRequest
  ->new({
    customerId => 1234567890,
    query      =>
      "SELECT campaign.id, campaign.name FROM campaign ORDER BY campaign.id",
    pageSize => 3
  });

# Tests SearchGoogleAdsIterator initialization.
my $iterator = Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
  service => $google_ads_service_mock,
  request => $search_request
});
ok($iterator->isa("Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator"),
  "Test SearchGoogleAdsIterator->new().");

my $count = 0;
while ($iterator->has_next) {
  $count += 1;
  my $campaign = $iterator->next->{campaign};
  is(
    $campaign->{name},
    "Campaign #" . $count,
    "Test SearchGoogleAdsIterator->next() : " . $campaign->{name});
}

is($count, 8, "Test iterator times.");
