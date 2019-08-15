# Copyright 2019, Google LLC
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

package Google::Ads::GoogleAds::V2::Services::CampaignExperimentService;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseService);

sub create {
  my $self          = shift;
  my $request_body  = shift;
  my $http_method   = 'POST';
  my $response_type = '';
  my $request_path  = 'v2/customers/{+customerId}/campaignExperiments:create';

  return $self->SUPER::call($http_method, $request_path, undef, $request_body,
    $response_type);
}

sub end {
  my $self          = shift;
  my $path_params   = shift;
  my $request_body  = shift;
  my $http_method   = 'POST';
  my $response_type = '';
  my $request_path  = 'v2/{+campaignExperiment}:end';

  return $self->SUPER::call($http_method, $request_path, $path_params,
    $request_body, $response_type);
}

sub get {
  my $self        = shift;
  my $path_params = shift;
  my $http_method = 'GET';
  my $response_type =
    'Google::Ads::GoogleAds::V2::Resources::CampaignExperiment';
  my $request_path = 'v2/{+resourceName}';

  return $self->SUPER::call($http_method, $request_path, $path_params, undef,
    $response_type);
}

sub graduate {
  my $self         = shift;
  my $path_params  = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $response_type =
'Google::Ads::GoogleAds::V2::Services::CampaignExperimentService::GraduateCampaignExperimentResponse';
  my $request_path = 'v2/{+campaignExperiment}:graduate';

  return $self->SUPER::call($http_method, $request_path, $path_params,
    $request_body, $response_type);
}

sub list_async_errors {
  my $self        = shift;
  my $path_params = shift;
  my $http_method = 'GET';
  my $response_type =
'Google::Ads::GoogleAds::V2::Services::CampaignExperimentService::ListCampaignExperimentAsyncErrorsResponse';
  my $request_path = 'v2/{+resourceName}:listAsyncErrors';

  return $self->SUPER::call($http_method, $request_path, $path_params, undef,
    $response_type);
}

sub mutate {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $response_type =
'Google::Ads::GoogleAds::V2::Services::CampaignExperimentService::MutateCampaignExperimentsResponse';
  my $request_path = 'v2/customers/{+customerId}/campaignExperiments:mutate';

  return $self->SUPER::call($http_method, $request_path, undef, $request_body,
    $response_type);
}

sub promote {
  my $self          = shift;
  my $path_params   = shift;
  my $request_body  = shift;
  my $http_method   = 'POST';
  my $response_type = '';
  my $request_path  = 'v2/{+campaignExperiment}:promote';

  return $self->SUPER::call($http_method, $request_path, $path_params,
    $request_body, $response_type);
}

1;
