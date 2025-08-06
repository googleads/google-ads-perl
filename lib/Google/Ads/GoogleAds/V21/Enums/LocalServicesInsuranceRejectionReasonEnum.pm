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

package Google::Ads::GoogleAds::V21::Enums::LocalServicesInsuranceRejectionReasonEnum;

use strict;
use warnings;

use Const::Exporter enums => [
  UNSPECIFIED                     => "UNSPECIFIED",
  UNKNOWN                         => "UNKNOWN",
  BUSINESS_NAME_MISMATCH          => "BUSINESS_NAME_MISMATCH",
  INSURANCE_AMOUNT_INSUFFICIENT   => "INSURANCE_AMOUNT_INSUFFICIENT",
  EXPIRED                         => "EXPIRED",
  NO_SIGNATURE                    => "NO_SIGNATURE",
  NO_POLICY_NUMBER                => "NO_POLICY_NUMBER",
  NO_COMMERCIAL_GENERAL_LIABILITY => "NO_COMMERCIAL_GENERAL_LIABILITY",
  EDITABLE_FORMAT                 => "EDITABLE_FORMAT",
  CATEGORY_MISMATCH               => "CATEGORY_MISMATCH",
  MISSING_EXPIRATION_DATE         => "MISSING_EXPIRATION_DATE",
  POOR_QUALITY                    => "POOR_QUALITY",
  POTENTIALLY_EDITED              => "POTENTIALLY_EDITED",
  WRONG_DOCUMENT_TYPE             => "WRONG_DOCUMENT_TYPE",
  NON_FINAL                       => "NON_FINAL",
  OTHER                           => "OTHER"
];

1;
