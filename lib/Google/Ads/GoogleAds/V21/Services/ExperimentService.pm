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

package Google::Ads::GoogleAds::V21::Services::ExperimentService;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseService);

sub end_experiment {
  my $self          = shift;
  my $request_body  = shift;
  my $http_method   = 'POST';
  my $request_path  = 'v21/{+experiment}:endExperiment';
  my $response_type = '';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub graduate_experiment {
  my $self          = shift;
  my $request_body  = shift;
  my $http_method   = 'POST';
  my $request_path  = 'v21/{+experiment}:graduateExperiment';
  my $response_type = '';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub list_experiment_async_errors {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'GET';
  my $request_path = 'v21/{+resourceName}:listExperimentAsyncErrors';
  my $response_type =
'Google::Ads::GoogleAds::V21::Services::ExperimentService::ListExperimentAsyncErrorsResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub mutate {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path = 'v21/customers/{+customerId}/experiments:mutate';
  my $response_type =
'Google::Ads::GoogleAds::V21::Services::ExperimentService::MutateExperimentsResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub promote_experiment {
  my $self          = shift;
  my $request_body  = shift;
  my $http_method   = 'POST';
  my $request_path  = 'v21/{+resourceName}:promoteExperiment';
  my $response_type = 'Google::Ads::GoogleAds::LongRunning::Operation';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub schedule_experiment {
  my $self          = shift;
  my $request_body  = shift;
  my $http_method   = 'POST';
  my $request_path  = 'v21/{+resourceName}:scheduleExperiment';
  my $response_type = 'Google::Ads::GoogleAds::LongRunning::Operation';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

1;
