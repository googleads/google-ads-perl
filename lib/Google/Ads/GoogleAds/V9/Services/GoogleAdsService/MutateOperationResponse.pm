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

package Google::Ads::GoogleAds::V9::Services::GoogleAdsService::MutateOperationResponse;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    adGroupAdLabelResult             => $args->{adGroupAdLabelResult},
    adGroupAdResult                  => $args->{adGroupAdResult},
    adGroupAssetResult               => $args->{adGroupAssetResult},
    adGroupBidModifierResult         => $args->{adGroupBidModifierResult},
    adGroupCriterionCustomizerResult =>
      $args->{adGroupCriterionCustomizerResult},
    adGroupCriterionLabelResult   => $args->{adGroupCriterionLabelResult},
    adGroupCriterionResult        => $args->{adGroupCriterionResult},
    adGroupCustomizerResult       => $args->{adGroupCustomizerResult},
    adGroupExtensionSettingResult => $args->{adGroupExtensionSettingResult},
    adGroupFeedResult             => $args->{adGroupFeedResult},
    adGroupLabelResult            => $args->{adGroupLabelResult},
    adGroupResult                 => $args->{adGroupResult},
    adParameterResult             => $args->{adParameterResult},
    adResult                      => $args->{adResult},
    assetGroupAssetResult         => $args->{assetGroupAssetResult},
    assetGroupListingGroupFilterResult =>
      $args->{assetGroupListingGroupFilterResult},
    assetGroupResult                   => $args->{assetGroupResult},
    assetResult                        => $args->{assetResult},
    assetSetAssetResult                => $args->{assetSetAssetResult},
    assetSetResult                     => $args->{assetSetResult},
    biddingDataExclusionResult         => $args->{biddingDataExclusionResult},
    biddingSeasonalityAdjustmentResult =>
      $args->{biddingSeasonalityAdjustmentResult},
    biddingStrategyResult          => $args->{biddingStrategyResult},
    campaignAssetResult            => $args->{campaignAssetResult},
    campaignAssetSetResult         => $args->{campaignAssetSetResult},
    campaignBidModifierResult      => $args->{campaignBidModifierResult},
    campaignBudgetResult           => $args->{campaignBudgetResult},
    campaignConversionGoalResult   => $args->{campaignConversionGoalResult},
    campaignCriterionResult        => $args->{campaignCriterionResult},
    campaignCustomizerResult       => $args->{campaignCustomizerResult},
    campaignDraftResult            => $args->{campaignDraftResult},
    campaignExperimentResult       => $args->{campaignExperimentResult},
    campaignExtensionSettingResult => $args->{campaignExtensionSettingResult},
    campaignFeedResult             => $args->{campaignFeedResult},
    campaignLabelResult            => $args->{campaignLabelResult},
    campaignResult                 => $args->{campaignResult},
    campaignSharedSetResult        => $args->{campaignSharedSetResult},
    conversionActionResult         => $args->{conversionActionResult},
    conversionCustomVariableResult => $args->{conversionCustomVariableResult},
    conversionGoalCampaignConfigResult =>
      $args->{conversionGoalCampaignConfigResult},
    conversionValueRuleResult       => $args->{conversionValueRuleResult},
    conversionValueRuleSetResult    => $args->{conversionValueRuleSetResult},
    customConversionGoalResult      => $args->{customConversionGoalResult},
    customerAssetResult             => $args->{customerAssetResult},
    customerConversionGoalResult    => $args->{customerConversionGoalResult},
    customerCustomizerResult        => $args->{customerCustomizerResult},
    customerExtensionSettingResult  => $args->{customerExtensionSettingResult},
    customerFeedResult              => $args->{customerFeedResult},
    customerLabelResult             => $args->{customerLabelResult},
    customerNegativeCriterionResult => $args->{customerNegativeCriterionResult},
    customerResult                  => $args->{customerResult},
    customizerAttributeResult       => $args->{customizerAttributeResult},
    extensionFeedItemResult         => $args->{extensionFeedItemResult},
    feedItemResult                  => $args->{feedItemResult},
    feedItemSetLinkResult           => $args->{feedItemSetLinkResult},
    feedItemSetResult               => $args->{feedItemSetResult},
    feedItemTargetResult            => $args->{feedItemTargetResult},
    feedMappingResult               => $args->{feedMappingResult},
    feedResult                      => $args->{feedResult},
    keywordPlanAdGroupKeywordResult => $args->{keywordPlanAdGroupKeywordResult},
    keywordPlanAdGroupResult        => $args->{keywordPlanAdGroupResult},
    keywordPlanCampaignKeywordResult =>
      $args->{keywordPlanCampaignKeywordResult},
    keywordPlanCampaignResult  => $args->{keywordPlanCampaignResult},
    keywordPlanResult          => $args->{keywordPlanResult},
    labelResult                => $args->{labelResult},
    mediaFileResult            => $args->{mediaFileResult},
    remarketingActionResult    => $args->{remarketingActionResult},
    sharedCriterionResult      => $args->{sharedCriterionResult},
    sharedSetResult            => $args->{sharedSetResult},
    smartCampaignSettingResult => $args->{smartCampaignSettingResult},
    userListResult             => $args->{userListResult}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
