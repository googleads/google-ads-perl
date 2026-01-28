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

package Google::Ads::GoogleAds::V23::Enums::AssetOfflineEvaluationErrorReasonsEnum;

use strict;
use warnings;

use Const::Exporter enums => [
  UNSPECIFIED                                => "UNSPECIFIED",
  UNKNOWN                                    => "UNKNOWN",
  PRICE_ASSET_DESCRIPTION_REPEATS_ROW_HEADER =>
    "PRICE_ASSET_DESCRIPTION_REPEATS_ROW_HEADER",
  PRICE_ASSET_REPETITIVE_HEADERS => "PRICE_ASSET_REPETITIVE_HEADERS",
  PRICE_ASSET_HEADER_INCOMPATIBLE_WITH_PRICE_TYPE =>
    "PRICE_ASSET_HEADER_INCOMPATIBLE_WITH_PRICE_TYPE",
  PRICE_ASSET_DESCRIPTION_INCOMPATIBLE_WITH_ITEM_HEADER =>
    "PRICE_ASSET_DESCRIPTION_INCOMPATIBLE_WITH_ITEM_HEADER",
  PRICE_ASSET_DESCRIPTION_HAS_PRICE_QUALIFIER =>
    "PRICE_ASSET_DESCRIPTION_HAS_PRICE_QUALIFIER",
  PRICE_ASSET_UNSUPPORTED_LANGUAGE => "PRICE_ASSET_UNSUPPORTED_LANGUAGE",
  PRICE_ASSET_OTHER_ERROR          => "PRICE_ASSET_OTHER_ERROR"
];

1;
