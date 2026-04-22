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

package Google::Ads::GoogleAds::V24::Services::IncentiveService;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseService);

sub apply_incentive {
  my $self         = shift;
  my $request_body = shift;

  # --- WORKAROUND START ---
  # Extract values for the URL template.
  my $customer_id = $request_body->{customerId};
  my $selected_incentive_id = $request_body->{selectedIncentiveId};

  # Manually build the request path replacing the placeholders.
  my $request_path =
    "v24/customers/$customer_id/incentives/$selected_incentive_id:applyIncentive";

  # Remove the fields from the request body to prevent duplicate setting in the JSON.
  delete $request_body->{customerId};
  delete $request_body->{selectedIncentiveId};
  # --- WORKAROUND END ---

  my $http_method  = 'POST';
  my $response_type =
'Google::Ads::GoogleAds::V24::Services::IncentiveService::ApplyIncentiveResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub fetch_incentive {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'GET';
  my $request_path = 'v24/incentives:fetchIncentive';
  my $response_type =
'Google::Ads::GoogleAds::V24::Services::IncentiveService::FetchIncentiveResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

1;
