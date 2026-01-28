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

package Google::Ads::GoogleAds::V23::Enums::LocalServicesBusinessRegistrationCheckRejectionReasonEnum;

use strict;
use warnings;

use Const::Exporter enums => [
  UNSPECIFIED                 => "UNSPECIFIED",
  UNKNOWN                     => "UNKNOWN",
  BUSINESS_NAME_MISMATCH      => "BUSINESS_NAME_MISMATCH",
  BUSINESS_DETAILS_MISMATCH   => "BUSINESS_DETAILS_MISMATCH",
  ID_NOT_FOUND                => "ID_NOT_FOUND",
  POOR_DOCUMENT_IMAGE_QUALITY => "POOR_DOCUMENT_IMAGE_QUALITY",
  DOCUMENT_EXPIRED            => "DOCUMENT_EXPIRED",
  DOCUMENT_INVALID            => "DOCUMENT_INVALID",
  DOCUMENT_TYPE_MISMATCH      => "DOCUMENT_TYPE_MISMATCH",
  DOCUMENT_UNVERIFIABLE       => "DOCUMENT_UNVERIFIABLE",
  OTHER                       => "OTHER"
];

1;
