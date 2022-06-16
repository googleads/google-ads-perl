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

package Google::Ads::GoogleAds::V11::Services::FeedItemTargetService;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseService);

sub mutate {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path = 'v11/customers/{+customerId}/feedItemTargets:mutate';
  my $response_type =
'Google::Ads::GoogleAds::V11::Services::FeedItemTargetService::MutateFeedItemTargetsResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

1;
