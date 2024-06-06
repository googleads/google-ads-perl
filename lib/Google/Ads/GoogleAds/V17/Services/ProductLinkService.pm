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

package Google::Ads::GoogleAds::V17::Services::ProductLinkService;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseService);

sub create {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path = 'v17/customers/{+customerId}/productLinks:create';
  my $response_type =
'Google::Ads::GoogleAds::V17::Services::ProductLinkService::CreateProductLinkResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub remove {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path = 'v17/customers/{+customerId}/productLinks:remove';
  my $response_type =
'Google::Ads::GoogleAds::V17::Services::ProductLinkService::RemoveProductLinkResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

1;
