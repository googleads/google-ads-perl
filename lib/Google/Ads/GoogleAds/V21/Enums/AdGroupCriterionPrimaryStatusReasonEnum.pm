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

package Google::Ads::GoogleAds::V21::Enums::AdGroupCriterionPrimaryStatusReasonEnum;

use strict;
use warnings;

use Const::Exporter enums => [
  UNSPECIFIED                       => "UNSPECIFIED",
  UNKNOWN                           => "UNKNOWN",
  CAMPAIGN_PENDING                  => "CAMPAIGN_PENDING",
  CAMPAIGN_CRITERION_NEGATIVE       => "CAMPAIGN_CRITERION_NEGATIVE",
  CAMPAIGN_PAUSED                   => "CAMPAIGN_PAUSED",
  CAMPAIGN_REMOVED                  => "CAMPAIGN_REMOVED",
  CAMPAIGN_ENDED                    => "CAMPAIGN_ENDED",
  AD_GROUP_PAUSED                   => "AD_GROUP_PAUSED",
  AD_GROUP_REMOVED                  => "AD_GROUP_REMOVED",
  AD_GROUP_CRITERION_DISAPPROVED    => "AD_GROUP_CRITERION_DISAPPROVED",
  AD_GROUP_CRITERION_RARELY_SERVED  => "AD_GROUP_CRITERION_RARELY_SERVED",
  AD_GROUP_CRITERION_LOW_QUALITY    => "AD_GROUP_CRITERION_LOW_QUALITY",
  AD_GROUP_CRITERION_UNDER_REVIEW   => "AD_GROUP_CRITERION_UNDER_REVIEW",
  AD_GROUP_CRITERION_PENDING_REVIEW => "AD_GROUP_CRITERION_PENDING_REVIEW",
  AD_GROUP_CRITERION_BELOW_FIRST_PAGE_BID =>
    "AD_GROUP_CRITERION_BELOW_FIRST_PAGE_BID",
  AD_GROUP_CRITERION_NEGATIVE   => "AD_GROUP_CRITERION_NEGATIVE",
  AD_GROUP_CRITERION_RESTRICTED => "AD_GROUP_CRITERION_RESTRICTED",
  AD_GROUP_CRITERION_PAUSED     => "AD_GROUP_CRITERION_PAUSED",
  AD_GROUP_CRITERION_PAUSED_DUE_TO_LOW_ACTIVITY =>
    "AD_GROUP_CRITERION_PAUSED_DUE_TO_LOW_ACTIVITY",
  AD_GROUP_CRITERION_REMOVED => "AD_GROUP_CRITERION_REMOVED"
];

1;
