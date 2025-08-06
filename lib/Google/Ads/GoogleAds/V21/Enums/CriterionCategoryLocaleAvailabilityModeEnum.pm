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

package Google::Ads::GoogleAds::V21::Enums::CriterionCategoryLocaleAvailabilityModeEnum;

use strict;
use warnings;

use Const::Exporter enums => [
  UNSPECIFIED                => "UNSPECIFIED",
  UNKNOWN                    => "UNKNOWN",
  ALL_LOCALES                => "ALL_LOCALES",
  COUNTRY_AND_ALL_LANGUAGES  => "COUNTRY_AND_ALL_LANGUAGES",
  LANGUAGE_AND_ALL_COUNTRIES => "LANGUAGE_AND_ALL_COUNTRIES",
  COUNTRY_AND_LANGUAGE       => "COUNTRY_AND_LANGUAGE"
];

1;
