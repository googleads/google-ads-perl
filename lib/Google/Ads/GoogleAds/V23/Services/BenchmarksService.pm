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

package Google::Ads::GoogleAds::V23::Services::BenchmarksService;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseService);

sub generate_benchmarks_metrics {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path = 'v23/customers/{+customerId}:generateBenchmarksMetrics';
  my $response_type =
'Google::Ads::GoogleAds::V23::Services::BenchmarksService::GenerateBenchmarksMetricsResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub list_benchmarks_available_dates {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path = 'v23:listBenchmarksAvailableDates';
  my $response_type =
'Google::Ads::GoogleAds::V23::Services::BenchmarksService::ListBenchmarksAvailableDatesResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub list_benchmarks_locations {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path = 'v23:listBenchmarksLocations';
  my $response_type =
'Google::Ads::GoogleAds::V23::Services::BenchmarksService::ListBenchmarksLocationsResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub list_benchmarks_products {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path = 'v23:listBenchmarksProducts';
  my $response_type =
'Google::Ads::GoogleAds::V23::Services::BenchmarksService::ListBenchmarksProductsResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub list_benchmarks_sources {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path = 'v23:listBenchmarksSources';
  my $response_type =
'Google::Ads::GoogleAds::V23::Services::BenchmarksService::ListBenchmarksSourcesResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

1;
