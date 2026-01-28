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

use lib qw(lib);

use Test::More(tests => 30);

# Tests use Google::Ads::GoogleAds::V23::Utils::ResourceNames.
use_ok("Google::Ads::GoogleAds::V23::Utils::ResourceNames");

# Tests account_budget_proposal().
my $expected = "customers/1234/accountBudgetProposals/5678";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::account_budget_proposal(
    1234, 5678
  ),
  $expected,
  "account_budget_proposal"
);

# Tests ad_group_ad().
$expected = "customers/1234/adGroupAds/5678~1011";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::ad_group_ad(
    1234, 5678, 1011
  ),
  $expected,
  "ad_group_ad"
);

# Tests ad_group_bid_modifier().
$expected = "customers/1234/adGroupBidModifiers/5678~1011";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::ad_group_bid_modifier(
    1234, 5678, 1011
  ),
  $expected,
  "ad_group_bid_modifier"
);

# Tests ad_group_criterion().
$expected = "customers/1234/adGroupCriteria/5678~1011";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::ad_group_criterion(
    1234, 5678, 1011
  ),
  $expected,
  "ad_group_criterion"
);

# Tests ad_group().
$expected = "customers/1234/adGroups/5678";
is(Google::Ads::GoogleAds::V23::Utils::ResourceNames::ad_group(1234, 5678),
  $expected, "ad_group");

# Tests ad_parameter().
$expected = "customers/1234/adParameters/5678~1011~3";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::ad_parameter(
    1234, 5678, 1011, 3
  ),
  $expected,
  "ad_parameter"
);

# Tests ad_schedule_view().
$expected = "customers/1234/adScheduleViews/5678~1011";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::ad_schedule_view(
    1234, 5678, 1011
  ),
  $expected,
  "ad_schedule_view"
);

# Tests bidding_strategy().
$expected = "customers/1234/biddingStrategies/5678";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::bidding_strategy(
    1234, 5678
  ),
  $expected,
  "bidding_strategy"
);

# Tests billing_setup().
$expected = "customers/1234/billingSetups/5678";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::billing_setup(1234, 5678),
  $expected, "billing_setup"
);

# Tests campaign().
$expected = "customers/1234/campaigns/5678";
is(Google::Ads::GoogleAds::V23::Utils::ResourceNames::campaign(1234, 5678),
  $expected, "campaign");

# Tests campaign_bid_modifier().
$expected = "customers/1234/campaignBidModifiers/5678~1011";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::campaign_bid_modifier(
    1234, 5678, 1011
  ),
  $expected,
  "campaign_bid_modifier"
);

# Tests campaign_budget().
$expected = "customers/1234/campaignBudgets/5678";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::campaign_budget(
    1234, 5678
  ),
  $expected,
  "campaign_budget"
);

# Tests campaign_criterion().
$expected = "customers/1234/campaignCriteria/5678~1011";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::campaign_criterion(
    1234, 5678, 1011
  ),
  $expected,
  "campaign_criterion"
);

# Tests campaign_shared_set().
$expected = "customers/1234/campaignSharedSets/5678~91011";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::campaign_shared_set(
    1234, 5678, 91011
  ),
  $expected,
  "campaign_shared_set"
);

# Tests change_status().
$expected = "customers/1234/changeStatus/5678asd";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::change_status(
    1234, "5678asd"
  ),
  $expected,
  "change_status"
);

# Tests click_view().
$expected = "customers/1234/clickViews/2019_05_22~5678asd";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::click_view(
    1234, "2019_05_22", "5678asd"
  ),
  $expected,
  "click_view"
);

# Tests conversion_action().
$expected = "customers/1234/conversionActions/5678";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::conversion_action(
    1234, 5678
  ),
  $expected,
  "conversion_action"
);

# Tests customer().
$expected = "customers/1234";
is(Google::Ads::GoogleAds::V23::Utils::ResourceNames::customer(1234),
  $expected, "customer");

# Tests geo_target_constant().
$expected = "geoTargetConstants/1234";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::geo_target_constant(1234),
  $expected, "geo_target_constant"
);

# Tests google_ads_field().
$expected = "googleAdsFields/ad_group_criterion.effective_cpm_bid_micros";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::google_ads_field(
    "ad_group_criterion.effective_cpm_bid_micros"),
  $expected,
  "google_ads_field"
);

# Tests keyword_view().
$expected = "customers/1234/keywordViews/5678~1011";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::keyword_view(
    1234, 5678, 1011
  ),
  $expected,
  "keyword_view"
);

# Tests mobile_app_category_constant().
$expected = "mobileAppCategoryConstants/1234";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::mobile_app_category_constant(
    1234),
  $expected,
  "mobile_app_category_constant"
);

# Tests mobile_device_constant().
$expected = "mobileDeviceConstants/1234";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::mobile_device_constant(
    1234),
  $expected,
  "mobile_device_constant"
);

# Tests operating_system_version_constant().
$expected = "operatingSystemVersionConstants/1234";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::operating_system_version_constant(
    1234),
  $expected,
  "operating_system_version_constant"
);

# Tests remarketing_action().
$expected = "customers/1234/remarketingActions/5678";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::remarketing_action(
    1234, 5678
  ),
  $expected,
  "remarketing_action"
);

# Tests search_term_view().
$expected = "customers/1234/searchTermViews/5678~91011~5678asd";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::search_term_view(
    1234, 5678, 91011, "5678asd"
  ),
  $expected,
  "search_term_view"
);

# Tests shared_set().
$expected = "customers/1234/sharedSets/5678";
is(Google::Ads::GoogleAds::V23::Utils::ResourceNames::shared_set(1234, 5678),
  $expected, "shared_set");

# Tests shared_criterion().
$expected = "customers/1234/sharedCriteria/5678~91011";
is(
  Google::Ads::GoogleAds::V23::Utils::ResourceNames::shared_criterion(
    1234, 5678, 91011
  ),
  $expected,
  "shared_criterion"
);

# Tests video().
$expected = "customers/1234/videos/5678asd";
is(Google::Ads::GoogleAds::V23::Utils::ResourceNames::video(1234, "5678asd"),
  $expected, "video");
