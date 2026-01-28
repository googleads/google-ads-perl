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

package Google::Ads::GoogleAds::V23::Enums::AttributionModelEnum;

use strict;
use warnings;

use Const::Exporter enums => [
  UNSPECIFIED                           => "UNSPECIFIED",
  UNKNOWN                               => "UNKNOWN",
  EXTERNAL                              => "EXTERNAL",
  GOOGLE_ADS_LAST_CLICK                 => "GOOGLE_ADS_LAST_CLICK",
  GOOGLE_SEARCH_ATTRIBUTION_FIRST_CLICK =>
    "GOOGLE_SEARCH_ATTRIBUTION_FIRST_CLICK",
  GOOGLE_SEARCH_ATTRIBUTION_LINEAR     => "GOOGLE_SEARCH_ATTRIBUTION_LINEAR",
  GOOGLE_SEARCH_ATTRIBUTION_TIME_DECAY =>
    "GOOGLE_SEARCH_ATTRIBUTION_TIME_DECAY",
  GOOGLE_SEARCH_ATTRIBUTION_POSITION_BASED =>
    "GOOGLE_SEARCH_ATTRIBUTION_POSITION_BASED",
  GOOGLE_SEARCH_ATTRIBUTION_DATA_DRIVEN =>
    "GOOGLE_SEARCH_ATTRIBUTION_DATA_DRIVEN"
];

1;
