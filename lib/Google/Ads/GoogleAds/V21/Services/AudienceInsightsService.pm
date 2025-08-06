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

package Google::Ads::GoogleAds::V21::Services::AudienceInsightsService;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseService);

sub generate_audience_composition_insights {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path =
    'v21/customers/{+customerId}:generateAudienceCompositionInsights';
  my $response_type =
'Google::Ads::GoogleAds::V21::Services::AudienceInsightsService::GenerateAudienceCompositionInsightsResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub generate_audience_overlap_insights {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path =
    'v21/customers/{+customerId}:generateAudienceOverlapInsights';
  my $response_type =
'Google::Ads::GoogleAds::V21::Services::AudienceInsightsService::GenerateAudienceOverlapInsightsResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub generate_insights_finder_report {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path = 'v21/customers/{+customerId}:generateInsightsFinderReport';
  my $response_type =
'Google::Ads::GoogleAds::V21::Services::AudienceInsightsService::GenerateInsightsFinderReportResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub generate_suggested_targeting_insights {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path =
    'v21/customers/{+customerId}:generateSuggestedTargetingInsights';
  my $response_type =
'Google::Ads::GoogleAds::V21::Services::AudienceInsightsService::GenerateSuggestedTargetingInsightsResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub generate_targeting_suggestion_metrics {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path =
    'v21/customers/{+customerId}:generateTargetingSuggestionMetrics';
  my $response_type =
'Google::Ads::GoogleAds::V21::Services::AudienceInsightsService::GenerateTargetingSuggestionMetricsResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub list_insights_eligible_dates {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path = 'v21/audienceInsights:listInsightsEligibleDates';
  my $response_type =
'Google::Ads::GoogleAds::V21::Services::AudienceInsightsService::ListInsightsEligibleDatesResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub search_audience_insights_attributes {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path =
    'v21/customers/{+customerId}:searchAudienceInsightsAttributes';
  my $response_type =
'Google::Ads::GoogleAds::V21::Services::AudienceInsightsService::ListAudienceInsightsAttributesResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

1;
