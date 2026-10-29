# Copyright 2026, Google LLC
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

package Google::Ads::GoogleAds::V26::Enums::BudgetNetworkIneligibleReasonEnum;

use strict;
use warnings;

use Const::Exporter enums => [
  UNSPECIFIED                    => "UNSPECIFIED",
  UNKNOWN                        => "UNKNOWN",
  UNSUPPORTED_BIDDING_STRATEGY   => "UNSUPPORTED_BIDDING_STRATEGY",
  MIXED_CAMPAIGN_TYPES           => "MIXED_CAMPAIGN_TYPES",
  HAS_ENABLED_TRIALS             => "HAS_ENABLED_TRIALS",
  UNSUPPORTED_BUDGET_PERIOD      => "UNSUPPORTED_BUDGET_PERIOD",
  MIXED_BIDDING_STRATEGIES       => "MIXED_BIDDING_STRATEGIES",
  INSUFFICIENT_ELIGIBLE_CHANNELS => "INSUFFICIENT_ELIGIBLE_CHANNELS"
];

1;
