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

package Google::Ads::GoogleAds::V1::Services::GeographicViewService;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseService);

sub get {
  my $self          = shift;
  my $path_params   = shift;
  my $http_method   = 'GET';
  my $response_type = 'Google::Ads::GoogleAds::V1::Resources::GeographicView';
  my $request_path  = 'v1/{+resourceName}';

  return $self->SUPER::call($http_method, $request_path, $path_params, undef,
    $response_type);
}

1;
