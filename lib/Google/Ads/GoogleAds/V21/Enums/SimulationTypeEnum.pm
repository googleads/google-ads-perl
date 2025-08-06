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

package Google::Ads::GoogleAds::V21::Enums::SimulationTypeEnum;

use strict;
use warnings;

use Const::Exporter enums => [
  UNSPECIFIED             => "UNSPECIFIED",
  UNKNOWN                 => "UNKNOWN",
  CPC_BID                 => "CPC_BID",
  CPV_BID                 => "CPV_BID",
  TARGET_CPA              => "TARGET_CPA",
  BID_MODIFIER            => "BID_MODIFIER",
  TARGET_ROAS             => "TARGET_ROAS",
  PERCENT_CPC_BID         => "PERCENT_CPC_BID",
  TARGET_IMPRESSION_SHARE => "TARGET_IMPRESSION_SHARE",
  BUDGET                  => "BUDGET"
];

1;
