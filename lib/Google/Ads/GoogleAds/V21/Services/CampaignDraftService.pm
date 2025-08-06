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

package Google::Ads::GoogleAds::V21::Services::CampaignDraftService;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseService);

sub list_async_errors {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'GET';
  my $request_path = 'v21/{+resourceName}:listAsyncErrors';
  my $response_type =
'Google::Ads::GoogleAds::V21::Services::CampaignDraftService::ListCampaignDraftAsyncErrorsResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub mutate {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path = 'v21/customers/{+customerId}/campaignDrafts:mutate';
  my $response_type =
'Google::Ads::GoogleAds::V21::Services::CampaignDraftService::MutateCampaignDraftsResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub promote {
  my $self          = shift;
  my $request_body  = shift;
  my $http_method   = 'POST';
  my $request_path  = 'v21/{+campaignDraft}:promote';
  my $response_type = 'Google::Ads::GoogleAds::LongRunning::Operation';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

1;
