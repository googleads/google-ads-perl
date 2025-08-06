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
# Unit tests for the Google::Ads::GoogleAds::Utils::FieldMasks module.

use strict;
use warnings;

use lib qw(lib t/utils);
use TestUtils qw(read_file_content);
use Google::Ads::GoogleAds::V21::Resources::Campaign;
use Google::Ads::GoogleAds::V21::Resources::NetworkSettings;
use Google::Ads::GoogleAds::V21::Resources::Ad;
use Google::Ads::GoogleAds::V21::Common::TextAdInfo;

use JSON::XS;
use Test::More qw(no_plan);

# Tests use Google::Ads::GoogleAds::Utils::FieldMasks.
use_ok("Google::Ads::GoogleAds::Utils::FieldMasks");

# Tests the field_mask() method : Campaign - previous values change.
my $original_campaign = Google::Ads::GoogleAds::V21::Resources::Campaign->new({
  name => "test name",
  id   => 1234
});
my $modified_campaign = Google::Ads::GoogleAds::V21::Resources::Campaign->new({
  name => "test string",
  id   => 5678
});
my $field_mask = field_mask($original_campaign, $modified_campaign);
ok(eq_set($field_mask->{paths}, ["name", "id"]),
  "Test field_mask() : Campaign - previous values change [name, id].");

# Tests the field_mask() method : Campaign - from null values.
$original_campaign = Google::Ads::GoogleAds::V21::Resources::Campaign->new();
$modified_campaign = Google::Ads::GoogleAds::V21::Resources::Campaign->new({
  name => "test string",
  id   => 5678
});
$field_mask = field_mask($original_campaign, $modified_campaign);
ok(eq_set($field_mask->{paths}, ["name", "id"]),
  "Test field_mask() : Campaign - from null values [name, id].");

# Tests the field_mask() method : Campaign - set to null value.
$original_campaign = Google::Ads::GoogleAds::V21::Resources::Campaign->new({
  name => "test name",
});
$modified_campaign = Google::Ads::GoogleAds::V21::Resources::Campaign->new({
  name => undef
});
$field_mask = field_mask($original_campaign, $modified_campaign);
ok(eq_set($field_mask->{paths}, ["name"]),
  "Test field_mask() : Campaign - set to null value [name].");

# Tests the field_mask() method : Campaign - no change.
$original_campaign = Google::Ads::GoogleAds::V21::Resources::Campaign->new({
  name => "test name",
});
$modified_campaign = Google::Ads::GoogleAds::V21::Resources::Campaign->new({
  name => "test name"
});
$field_mask = field_mask($original_campaign, $modified_campaign);
ok(eq_set($field_mask->{paths}, []),
  "Test field_mask() : Campaign - no change [].");

# Tests the field_mask() method : Ad - repeated field addition.
my $original_ad = Google::Ads::GoogleAds::V21::Resources::Ad->new({
  finalUrls => ["url 1"],
});
my $modified_ad = Google::Ads::GoogleAds::V21::Resources::Ad->new({
    finalUrls => ["url 1", "url 2"]});
$field_mask = field_mask($original_ad, $modified_ad);
ok(eq_set($field_mask->{paths}, ["final_urls"]),
  "Test field_mask() : Ad - repeated field addition [final_urls].");

# Tests the field_mask() method : Ad - repeated field removal.
$original_ad = Google::Ads::GoogleAds::V21::Resources::Ad->new({
  finalUrls => ["url 1", "url 2"],
});
$modified_ad = Google::Ads::GoogleAds::V21::Resources::Ad->new({
    finalUrls => ["url 1"]});
$field_mask = field_mask($original_ad, $modified_ad);
ok(eq_set($field_mask->{paths}, ["final_urls"]),
  "Test field_mask() : Ad - repeated field removal [final_urls].");

# Tests the field_mask() method : Ad - nested field change.
$original_ad = Google::Ads::GoogleAds::V21::Resources::Ad->new({
    textAd => Google::Ads::GoogleAds::V21::Common::TextAdInfo->new({
        headline => "headline"
      })});
$modified_ad = Google::Ads::GoogleAds::V21::Resources::Ad->new({
    textAd => Google::Ads::GoogleAds::V21::Common::TextAdInfo->new({
        headline => "new headline"
      })});
$field_mask = field_mask($original_ad, $modified_ad);
ok(eq_set($field_mask->{paths}, ["text_ad.headline"]),
  "Test field_mask() : Ad - nested field change [text_ad.headline].");

# Tests the all_set_fields_of() method : Campaign.
$modified_campaign = Google::Ads::GoogleAds::V21::Resources::Campaign->new({
    name            => "Name",
    networkSettings =>
      Google::Ads::GoogleAds::V21::Resources::NetworkSettings->new({
        targetSearchNetwork => "true",
      })});
$field_mask = all_set_fields_of($modified_campaign);
ok(
  eq_set(
    $field_mask->{paths}, ["name", "network_settings.target_search_network"]
  ),
"Test all_set_fields_of() : Campaign - [name, network_settings.target_search_network]."
);

# Tests the field_mask() method : Campaign - nested field for update.
$original_campaign = Google::Ads::GoogleAds::V21::Resources::Campaign->new({
  name => "test name",
});
$modified_campaign = Google::Ads::GoogleAds::V21::Resources::Campaign->new({
    name            => "new name",
    networkSettings =>
      Google::Ads::GoogleAds::V21::Resources::NetworkSettings->new({
        targetSearchNetwork => "true",
      })});
$field_mask = field_mask($original_campaign, $modified_campaign);
ok(
  eq_set(
    $field_mask->{paths}, ["name", "network_settings.target_search_network"]
  ),
  "Test field_mask() : Campaign - nested field for update " .
    " [name, network_settings.target_search_network]."
);

# Tests the field_mask() method: Campaign - non-existing field to undef.
$original_campaign = Google::Ads::GoogleAds::V21::Resources::Campaign->new({
  name => "test name",
});
$modified_campaign = Google::Ads::GoogleAds::V21::Resources::Campaign->new({
  name => "Name",
  id   => undef
});
$field_mask = field_mask($original_campaign, $modified_campaign);
ok(eq_set($field_mask->{paths}, ["name", "id"]),
  "Test field_mask() : Campaign - non-existing field to undef [name, id].");

# Tests the get_field_value() method : Ad.
$modified_ad = Google::Ads::GoogleAds::V21::Resources::Ad->new({
    name      => "test string",
    finalUrls => ["url 1", "url 2"],
    textAd    => Google::Ads::GoogleAds::V21::Common::TextAdInfo->new({
        headline => "new headline"
      })});
is(get_field_value($modified_ad, "name"),
  "test string", "Test get_field_value() : Ad - string field [name].");
ok(
  eq_set(get_field_value($modified_ad, "finalUrls"), ["url 1", "url 2"]),
  "Test get_field_value() : Ad - repeated field [finalUrls]."
);
is(get_field_value($modified_ad, "textAd.headline"),
  "new headline",
  "Test get_field_value() : Ad - nested field [textAd.headline].");
is(get_field_value($modified_ad, "textAd.nonExiting"),
  undef, "Test get_field_value() : Ad - non-existing field.");

# Tests the field_mask() method using the test cases in "field_mask_tests.json".
my $json_text   = read_file_content("testdata", "field_mask_tests.json");
my $json_object = decode_json($json_text);

foreach my $test_case (@{$json_object->{testCases}}) {
  my $description                  = $test_case->{description};
  my $original_resource            = $test_case->{originalResource};
  my $modified_resource            = $test_case->{modifiedResource};
  my @expected_mask                = split(/,/, $test_case->{expectedMask});
  my @expected_all_set_fields_mask = split(/,/, $test_case->{allSetFieldsMask})
    if exists $test_case->{allSetFieldsMask};

  my $field_mask = field_mask($original_resource, $modified_resource);
  if (@expected_all_set_fields_mask) {
    my $all_set_fields_mask = all_set_fields_of($modified_resource);
    ok(eq_set($all_set_fields_mask->{paths}, \@expected_all_set_fields_mask),
      $description);
  }
  ok(eq_set($field_mask->{paths}, \@expected_mask), $description);
}
