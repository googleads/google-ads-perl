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

package Google::Ads::GoogleAds::V10::Services::CampaignExperimentService;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseService);

sub create {
  my $self          = shift;
  my $request_body  = shift;
  my $http_method   = 'POST';
  my $request_path  = 'v10/customers/{+customerId}/campaignExperiments:create';
  my $response_type = 'Google::Ads::GoogleAds::LongRunning::Operation';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub end {
  my $self          = shift;
  my $request_body  = shift;
  my $http_method   = 'POST';
  my $request_path  = 'v10/{+campaignExperiment}:end';
  my $response_type = '';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub graduate {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path = 'v10/{+campaignExperiment}:graduate';
  my $response_type =
'Google::Ads::GoogleAds::V10::Services::CampaignExperimentService::GraduateCampaignExperimentResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub list_async_errors {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'GET';
  my $request_path = 'v10/{+resourceName}:listAsyncErrors';
  my $response_type =
'Google::Ads::GoogleAds::V10::Services::CampaignExperimentService::ListCampaignExperimentAsyncErrorsResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub mutate {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path = 'v10/customers/{+customerId}/campaignExperiments:mutate';
  my $response_type =
'Google::Ads::GoogleAds::V10::Services::CampaignExperimentService::MutateCampaignExperimentsResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub promote {
  my $self          = shift;
  my $request_body  = shift;
  my $http_method   = 'POST';
  my $request_path  = 'v10/{+campaignExperiment}:promote';
  my $response_type = 'Google::Ads::GoogleAds::LongRunning::Operation';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

1;
