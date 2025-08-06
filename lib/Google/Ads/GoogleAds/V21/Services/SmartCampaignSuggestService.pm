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

package Google::Ads::GoogleAds::V21::Services::SmartCampaignSuggestService;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseService);

sub suggest_keyword_themes {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path = 'v21/customers/{+customerId}:suggestKeywordThemes';
  my $response_type =
'Google::Ads::GoogleAds::V21::Services::SmartCampaignSuggestService::SuggestKeywordThemesResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub suggest_smart_campaign_ad {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path = 'v21/customers/{+customerId}:suggestSmartCampaignAd';
  my $response_type =
'Google::Ads::GoogleAds::V21::Services::SmartCampaignSuggestService::SuggestSmartCampaignAdResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

sub suggest_smart_campaign_budget_options {
  my $self         = shift;
  my $request_body = shift;
  my $http_method  = 'POST';
  my $request_path =
    'v21/customers/{+customerId}:suggestSmartCampaignBudgetOptions';
  my $response_type =
'Google::Ads::GoogleAds::V21::Services::SmartCampaignSuggestService::SuggestSmartCampaignBudgetOptionsResponse';

  return $self->SUPER::call($http_method, $request_path, $request_body,
    $response_type);
}

1;
