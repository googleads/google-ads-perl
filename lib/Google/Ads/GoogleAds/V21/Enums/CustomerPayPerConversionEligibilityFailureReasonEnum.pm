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

package Google::Ads::GoogleAds::V21::Enums::CustomerPayPerConversionEligibilityFailureReasonEnum;

use strict;
use warnings;

use Const::Exporter enums => [
  UNSPECIFIED                     => "UNSPECIFIED",
  UNKNOWN                         => "UNKNOWN",
  NOT_ENOUGH_CONVERSIONS          => "NOT_ENOUGH_CONVERSIONS",
  CONVERSION_LAG_TOO_HIGH         => "CONVERSION_LAG_TOO_HIGH",
  HAS_CAMPAIGN_WITH_SHARED_BUDGET => "HAS_CAMPAIGN_WITH_SHARED_BUDGET",
  HAS_UPLOAD_CLICKS_CONVERSION    => "HAS_UPLOAD_CLICKS_CONVERSION",
  AVERAGE_DAILY_SPEND_TOO_HIGH    => "AVERAGE_DAILY_SPEND_TOO_HIGH",
  ANALYSIS_NOT_COMPLETE           => "ANALYSIS_NOT_COMPLETE",
  OTHER                           => "OTHER"
];

1;
