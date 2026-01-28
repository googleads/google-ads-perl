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

package Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    adGroupAdLabelOperation             => $args->{adGroupAdLabelOperation},
    adGroupAdOperation                  => $args->{adGroupAdOperation},
    adGroupAssetOperation               => $args->{adGroupAssetOperation},
    adGroupBidModifierOperation         => $args->{adGroupBidModifierOperation},
    adGroupCriterionCustomizerOperation =>
      $args->{adGroupCriterionCustomizerOperation},
    adGroupCriterionLabelOperation => $args->{adGroupCriterionLabelOperation},
    adGroupCriterionOperation      => $args->{adGroupCriterionOperation},
    adGroupCustomizerOperation     => $args->{adGroupCustomizerOperation},
    adGroupLabelOperation          => $args->{adGroupLabelOperation},
    adGroupOperation               => $args->{adGroupOperation},
    adOperation                    => $args->{adOperation},
    adParameterOperation           => $args->{adParameterOperation},
    assetGroupAssetOperation       => $args->{assetGroupAssetOperation},
    assetGroupListingGroupFilterOperation =>
      $args->{assetGroupListingGroupFilterOperation},
    assetGroupOperation           => $args->{assetGroupOperation},
    assetGroupSignalOperation     => $args->{assetGroupSignalOperation},
    assetOperation                => $args->{assetOperation},
    assetSetAssetOperation        => $args->{assetSetAssetOperation},
    assetSetOperation             => $args->{assetSetOperation},
    audienceOperation             => $args->{audienceOperation},
    biddingDataExclusionOperation => $args->{biddingDataExclusionOperation},
    biddingSeasonalityAdjustmentOperation =>
      $args->{biddingSeasonalityAdjustmentOperation},
    biddingStrategyOperation        => $args->{biddingStrategyOperation},
    campaignAssetOperation          => $args->{campaignAssetOperation},
    campaignAssetSetOperation       => $args->{campaignAssetSetOperation},
    campaignBidModifierOperation    => $args->{campaignBidModifierOperation},
    campaignBudgetOperation         => $args->{campaignBudgetOperation},
    campaignConversionGoalOperation => $args->{campaignConversionGoalOperation},
    campaignCriterionOperation      => $args->{campaignCriterionOperation},
    campaignCustomizerOperation     => $args->{campaignCustomizerOperation},
    campaignDraftOperation          => $args->{campaignDraftOperation},
    campaignGroupOperation          => $args->{campaignGroupOperation},
    campaignLabelOperation          => $args->{campaignLabelOperation},
    campaignOperation               => $args->{campaignOperation},
    campaignSharedSetOperation      => $args->{campaignSharedSetOperation},
    conversionActionOperation       => $args->{conversionActionOperation},
    conversionCustomVariableOperation =>
      $args->{conversionCustomVariableOperation},
    conversionGoalCampaignConfigOperation =>
      $args->{conversionGoalCampaignConfigOperation},
    conversionValueRuleOperation    => $args->{conversionValueRuleOperation},
    conversionValueRuleSetOperation => $args->{conversionValueRuleSetOperation},
    customConversionGoalOperation   => $args->{customConversionGoalOperation},
    customerAssetOperation          => $args->{customerAssetOperation},
    customerConversionGoalOperation => $args->{customerConversionGoalOperation},
    customerCustomizerOperation     => $args->{customerCustomizerOperation},
    customerLabelOperation          => $args->{customerLabelOperation},
    customerNegativeCriterionOperation =>
      $args->{customerNegativeCriterionOperation},
    customerOperation                  => $args->{customerOperation},
    customizerAttributeOperation       => $args->{customizerAttributeOperation},
    experimentArmOperation             => $args->{experimentArmOperation},
    experimentOperation                => $args->{experimentOperation},
    keywordPlanAdGroupKeywordOperation =>
      $args->{keywordPlanAdGroupKeywordOperation},
    keywordPlanAdGroupOperation         => $args->{keywordPlanAdGroupOperation},
    keywordPlanCampaignKeywordOperation =>
      $args->{keywordPlanCampaignKeywordOperation},
    keywordPlanCampaignOperation => $args->{keywordPlanCampaignOperation},
    keywordPlanOperation         => $args->{keywordPlanOperation},
    labelOperation               => $args->{labelOperation},
    recommendationSubscriptionOperation =>
      $args->{recommendationSubscriptionOperation},
    remarketingActionOperation    => $args->{remarketingActionOperation},
    sharedCriterionOperation      => $args->{sharedCriterionOperation},
    sharedSetOperation            => $args->{sharedSetOperation},
    smartCampaignSettingOperation => $args->{smartCampaignSettingOperation},
    userListOperation             => $args->{userListOperation}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
