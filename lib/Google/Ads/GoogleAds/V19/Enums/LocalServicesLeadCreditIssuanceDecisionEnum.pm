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

package Google::Ads::GoogleAds::V19::Enums::LocalServicesLeadCreditIssuanceDecisionEnum;

use strict;
use warnings;

use Const::Exporter enums => [
  UNSPECIFIED                   => "UNSPECIFIED",
  UNKNOWN                       => "UNKNOWN",
  SUCCESS_NOT_REACHED_THRESHOLD => "SUCCESS_NOT_REACHED_THRESHOLD",
  SUCCESS_REACHED_THRESHOLD     => "SUCCESS_REACHED_THRESHOLD",
  FAIL_OVER_THRESHOLD           => "FAIL_OVER_THRESHOLD",
  FAIL_NOT_ELIGIBLE             => "FAIL_NOT_ELIGIBLE"
];

1;
