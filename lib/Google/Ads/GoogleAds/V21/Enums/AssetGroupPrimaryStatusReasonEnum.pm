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

package Google::Ads::GoogleAds::V21::Enums::AssetGroupPrimaryStatusReasonEnum;

use strict;
use warnings;

use Const::Exporter enums => [
  UNSPECIFIED              => "UNSPECIFIED",
  UNKNOWN                  => "UNKNOWN",
  ASSET_GROUP_PAUSED       => "ASSET_GROUP_PAUSED",
  ASSET_GROUP_REMOVED      => "ASSET_GROUP_REMOVED",
  CAMPAIGN_REMOVED         => "CAMPAIGN_REMOVED",
  CAMPAIGN_PAUSED          => "CAMPAIGN_PAUSED",
  CAMPAIGN_PENDING         => "CAMPAIGN_PENDING",
  CAMPAIGN_ENDED           => "CAMPAIGN_ENDED",
  ASSET_GROUP_LIMITED      => "ASSET_GROUP_LIMITED",
  ASSET_GROUP_DISAPPROVED  => "ASSET_GROUP_DISAPPROVED",
  ASSET_GROUP_UNDER_REVIEW => "ASSET_GROUP_UNDER_REVIEW"
];

1;
