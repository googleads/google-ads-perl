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

package Google::Ads::GoogleAds::V23::Enums::BiddingStrategySystemStatusEnum;

use strict;
use warnings;

use Const::Exporter enums => [
  UNSPECIFIED                        => "UNSPECIFIED",
  UNKNOWN                            => "UNKNOWN",
  ENABLED                            => "ENABLED",
  LEARNING_NEW                       => "LEARNING_NEW",
  LEARNING_SETTING_CHANGE            => "LEARNING_SETTING_CHANGE",
  LEARNING_BUDGET_CHANGE             => "LEARNING_BUDGET_CHANGE",
  LEARNING_COMPOSITION_CHANGE        => "LEARNING_COMPOSITION_CHANGE",
  LEARNING_CONVERSION_TYPE_CHANGE    => "LEARNING_CONVERSION_TYPE_CHANGE",
  LEARNING_CONVERSION_SETTING_CHANGE => "LEARNING_CONVERSION_SETTING_CHANGE",
  LIMITED_BY_CPC_BID_CEILING         => "LIMITED_BY_CPC_BID_CEILING",
  LIMITED_BY_CPC_BID_FLOOR           => "LIMITED_BY_CPC_BID_FLOOR",
  LIMITED_BY_DATA                    => "LIMITED_BY_DATA",
  LIMITED_BY_BUDGET                  => "LIMITED_BY_BUDGET",
  LIMITED_BY_LOW_PRIORITY_SPEND      => "LIMITED_BY_LOW_PRIORITY_SPEND",
  LIMITED_BY_LOW_QUALITY             => "LIMITED_BY_LOW_QUALITY",
  LIMITED_BY_INVENTORY               => "LIMITED_BY_INVENTORY",
  MISCONFIGURED_ZERO_ELIGIBILITY     => "MISCONFIGURED_ZERO_ELIGIBILITY",
  MISCONFIGURED_CONVERSION_TYPES     => "MISCONFIGURED_CONVERSION_TYPES",
  MISCONFIGURED_CONVERSION_SETTINGS  => "MISCONFIGURED_CONVERSION_SETTINGS",
  MISCONFIGURED_SHARED_BUDGET        => "MISCONFIGURED_SHARED_BUDGET",
  MISCONFIGURED_STRATEGY_TYPE        => "MISCONFIGURED_STRATEGY_TYPE",
  PAUSED                             => "PAUSED",
  UNAVAILABLE                        => "UNAVAILABLE",
  MULTIPLE_LEARNING                  => "MULTIPLE_LEARNING",
  MULTIPLE_LIMITED                   => "MULTIPLE_LIMITED",
  MULTIPLE_MISCONFIGURED             => "MULTIPLE_MISCONFIGURED",
  MULTIPLE                           => "MULTIPLE"
];

1;
