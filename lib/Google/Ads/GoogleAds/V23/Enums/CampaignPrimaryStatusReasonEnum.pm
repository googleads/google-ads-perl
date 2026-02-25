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

package Google::Ads::GoogleAds::V23::Enums::CampaignPrimaryStatusReasonEnum;

use strict;
use warnings;

use Const::Exporter enums => [
  UNSPECIFIED                             => "UNSPECIFIED",
  UNKNOWN                                 => "UNKNOWN",
  CAMPAIGN_REMOVED                        => "CAMPAIGN_REMOVED",
  CAMPAIGN_PAUSED                         => "CAMPAIGN_PAUSED",
  CAMPAIGN_PENDING                        => "CAMPAIGN_PENDING",
  CAMPAIGN_ENDED                          => "CAMPAIGN_ENDED",
  CAMPAIGN_DRAFT                          => "CAMPAIGN_DRAFT",
  BIDDING_STRATEGY_MISCONFIGURED          => "BIDDING_STRATEGY_MISCONFIGURED",
  BIDDING_STRATEGY_LIMITED                => "BIDDING_STRATEGY_LIMITED",
  BIDDING_STRATEGY_LEARNING               => "BIDDING_STRATEGY_LEARNING",
  BIDDING_STRATEGY_CONSTRAINED            => "BIDDING_STRATEGY_CONSTRAINED",
  BUDGET_CONSTRAINED                      => "BUDGET_CONSTRAINED",
  BUDGET_MISCONFIGURED                    => "BUDGET_MISCONFIGURED",
  SEARCH_VOLUME_LIMITED                   => "SEARCH_VOLUME_LIMITED",
  AD_GROUPS_PAUSED                        => "AD_GROUPS_PAUSED",
  NO_AD_GROUPS                            => "NO_AD_GROUPS",
  KEYWORDS_PAUSED                         => "KEYWORDS_PAUSED",
  NO_KEYWORDS                             => "NO_KEYWORDS",
  AD_GROUP_ADS_PAUSED                     => "AD_GROUP_ADS_PAUSED",
  NO_AD_GROUP_ADS                         => "NO_AD_GROUP_ADS",
  HAS_ADS_LIMITED_BY_POLICY               => "HAS_ADS_LIMITED_BY_POLICY",
  HAS_ADS_DISAPPROVED                     => "HAS_ADS_DISAPPROVED",
  MOST_ADS_UNDER_REVIEW                   => "MOST_ADS_UNDER_REVIEW",
  MISSING_LEAD_FORM_EXTENSION             => "MISSING_LEAD_FORM_EXTENSION",
  MISSING_CALL_EXTENSION                  => "MISSING_CALL_EXTENSION",
  LEAD_FORM_EXTENSION_UNDER_REVIEW        => "LEAD_FORM_EXTENSION_UNDER_REVIEW",
  LEAD_FORM_EXTENSION_DISAPPROVED         => "LEAD_FORM_EXTENSION_DISAPPROVED",
  CALL_EXTENSION_UNDER_REVIEW             => "CALL_EXTENSION_UNDER_REVIEW",
  CALL_EXTENSION_DISAPPROVED              => "CALL_EXTENSION_DISAPPROVED",
  NO_MOBILE_APPLICATION_AD_GROUP_CRITERIA =>
    "NO_MOBILE_APPLICATION_AD_GROUP_CRITERIA",
  CAMPAIGN_GROUP_PAUSED                  => "CAMPAIGN_GROUP_PAUSED",
  CAMPAIGN_GROUP_ALL_GROUP_BUDGETS_ENDED =>
    "CAMPAIGN_GROUP_ALL_GROUP_BUDGETS_ENDED",
  APP_NOT_RELEASED                   => "APP_NOT_RELEASED",
  APP_PARTIALLY_RELEASED             => "APP_PARTIALLY_RELEASED",
  HAS_ASSET_GROUPS_DISAPPROVED       => "HAS_ASSET_GROUPS_DISAPPROVED",
  HAS_ASSET_GROUPS_LIMITED_BY_POLICY => "HAS_ASSET_GROUPS_LIMITED_BY_POLICY",
  MOST_ASSET_GROUPS_UNDER_REVIEW     => "MOST_ASSET_GROUPS_UNDER_REVIEW",
  NO_ASSET_GROUPS                    => "NO_ASSET_GROUPS",
  ASSET_GROUPS_PAUSED                => "ASSET_GROUPS_PAUSED",
  MISSING_LOCATION_TARGETING         => "MISSING_LOCATION_TARGETING",
  CAMPAIGN_NOT_BOOKED                => "CAMPAIGN_NOT_BOOKED",
  BOOKING_HOLD_EXPIRING              => "BOOKING_HOLD_EXPIRING",
  BOOKING_HOLD_EXPIRED               => "BOOKING_HOLD_EXPIRED",
  BOOKING_CANCELLED                  => "BOOKING_CANCELLED"
];

1;
