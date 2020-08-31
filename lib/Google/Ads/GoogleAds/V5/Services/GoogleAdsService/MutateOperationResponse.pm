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

package Google::Ads::GoogleAds::V5::Services::GoogleAdsService::MutateOperationResponse;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    adGroupAdLabelResult            => $args->{adGroupAdLabelResult},
    adGroupAdResult                 => $args->{adGroupAdResult},
    adGroupBidModifierResult        => $args->{adGroupBidModifierResult},
    adGroupCriterionLabelResult     => $args->{adGroupCriterionLabelResult},
    adGroupCriterionResult          => $args->{adGroupCriterionResult},
    adGroupExtensionSettingResult   => $args->{adGroupExtensionSettingResult},
    adGroupFeedResult               => $args->{adGroupFeedResult},
    adGroupLabelResult              => $args->{adGroupLabelResult},
    adGroupResult                   => $args->{adGroupResult},
    adParameterResult               => $args->{adParameterResult},
    adResult                        => $args->{adResult},
    assetResult                     => $args->{assetResult},
    biddingStrategyResult           => $args->{biddingStrategyResult},
    campaignAssetResult             => $args->{campaignAssetResult},
    campaignBidModifierResult       => $args->{campaignBidModifierResult},
    campaignBudgetResult            => $args->{campaignBudgetResult},
    campaignCriterionResult         => $args->{campaignCriterionResult},
    campaignDraftResult             => $args->{campaignDraftResult},
    campaignExperimentResult        => $args->{campaignExperimentResult},
    campaignExtensionSettingResult  => $args->{campaignExtensionSettingResult},
    campaignFeedResult              => $args->{campaignFeedResult},
    campaignLabelResult             => $args->{campaignLabelResult},
    campaignResult                  => $args->{campaignResult},
    campaignSharedSetResult         => $args->{campaignSharedSetResult},
    conversionActionResult          => $args->{conversionActionResult},
    customerExtensionSettingResult  => $args->{customerExtensionSettingResult},
    customerFeedResult              => $args->{customerFeedResult},
    customerLabelResult             => $args->{customerLabelResult},
    customerNegativeCriterionResult => $args->{customerNegativeCriterionResult},
    customerResult                  => $args->{customerResult},
    extensionFeedItemResult         => $args->{extensionFeedItemResult},
    feedItemResult                  => $args->{feedItemResult},
    feedItemTargetResult            => $args->{feedItemTargetResult},
    feedMappingResult               => $args->{feedMappingResult},
    feedResult                      => $args->{feedResult},
    keywordPlanAdGroupKeywordResult => $args->{keywordPlanAdGroupKeywordResult},
    keywordPlanAdGroupResult        => $args->{keywordPlanAdGroupResult},
    keywordPlanCampaignKeywordResult =>
      $args->{keywordPlanCampaignKeywordResult},
    keywordPlanCampaignResult => $args->{keywordPlanCampaignResult},
    keywordPlanResult         => $args->{keywordPlanResult},
    labelResult               => $args->{labelResult},
    mediaFileResult           => $args->{mediaFileResult},
    remarketingActionResult   => $args->{remarketingActionResult},
    sharedCriterionResult     => $args->{sharedCriterionResult},
    sharedSetResult           => $args->{sharedSetResult},
    userListResult            => $args->{userListResult}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
