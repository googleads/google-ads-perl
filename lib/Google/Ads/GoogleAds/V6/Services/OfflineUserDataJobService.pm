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

package Google::Ads::GoogleAds::V6::Services::OfflineUserDataJobService;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseService);

sub add_operations {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path = 'v6/{+resourceName}:addOperations';
  my $response_type =
'Google::Ads::GoogleAds::V6::Services::OfflineUserDataJobService::AddOfflineUserDataJobOperationsResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub create {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path = 'v6/customers/{+customerId}/offlineUserDataJobs:create';
  my $response_type =
'Google::Ads::GoogleAds::V6::Services::OfflineUserDataJobService::CreateOfflineUserDataJobResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub get {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'GET';
  my $request_path = 'v6/{+resourceName}';
  my $response_type =
    'Google::Ads::GoogleAds::V6::Resources::OfflineUserDataJob';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub run {
  my $self          = shift;
  my $request_body  = shift;
  my $http_method   = 'POST';
  my $request_path  = 'v6/{+resourceName}:run';
  my $response_type = 'Google::Ads::GoogleAds::LongRunning::Operation';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

1;
