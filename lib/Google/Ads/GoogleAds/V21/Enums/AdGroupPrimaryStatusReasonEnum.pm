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

package Google::Ads::GoogleAds::V21::Enums::AdGroupPrimaryStatusReasonEnum;

use strict;
use warnings;

use Const::Exporter enums => [
  UNSPECIFIED                         => "UNSPECIFIED",
  UNKNOWN                             => "UNKNOWN",
  CAMPAIGN_REMOVED                    => "CAMPAIGN_REMOVED",
  CAMPAIGN_PAUSED                     => "CAMPAIGN_PAUSED",
  CAMPAIGN_PENDING                    => "CAMPAIGN_PENDING",
  CAMPAIGN_ENDED                      => "CAMPAIGN_ENDED",
  AD_GROUP_PAUSED                     => "AD_GROUP_PAUSED",
  AD_GROUP_REMOVED                    => "AD_GROUP_REMOVED",
  AD_GROUP_INCOMPLETE                 => "AD_GROUP_INCOMPLETE",
  KEYWORDS_PAUSED                     => "KEYWORDS_PAUSED",
  NO_KEYWORDS                         => "NO_KEYWORDS",
  AD_GROUP_ADS_PAUSED                 => "AD_GROUP_ADS_PAUSED",
  NO_AD_GROUP_ADS                     => "NO_AD_GROUP_ADS",
  HAS_ADS_DISAPPROVED                 => "HAS_ADS_DISAPPROVED",
  HAS_ADS_LIMITED_BY_POLICY           => "HAS_ADS_LIMITED_BY_POLICY",
  MOST_ADS_UNDER_REVIEW               => "MOST_ADS_UNDER_REVIEW",
  CAMPAIGN_DRAFT                      => "CAMPAIGN_DRAFT",
  AD_GROUP_PAUSED_DUE_TO_LOW_ACTIVITY => "AD_GROUP_PAUSED_DUE_TO_LOW_ACTIVITY"
];

1;
