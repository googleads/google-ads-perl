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

package Google::Ads::GoogleAds::V8::Services::GoogleAdsService::MutateOperation;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    adGroupAdLabelOperation          => $args->{adGroupAdLabelOperation},
    adGroupAdOperation               => $args->{adGroupAdOperation},
    adGroupAssetOperation            => $args->{adGroupAssetOperation},
    adGroupBidModifierOperation      => $args->{adGroupBidModifierOperation},
    adGroupCriterionLabelOperation   => $args->{adGroupCriterionLabelOperation},
    adGroupCriterionOperation        => $args->{adGroupCriterionOperation},
    adGroupExtensionSettingOperation =>
      $args->{adGroupExtensionSettingOperation},
    adGroupFeedOperation          => $args->{adGroupFeedOperation},
    adGroupLabelOperation         => $args->{adGroupLabelOperation},
    adGroupOperation              => $args->{adGroupOperation},
    adOperation                   => $args->{adOperation},
    adParameterOperation          => $args->{adParameterOperation},
    assetOperation                => $args->{assetOperation},
    biddingDataExclusionOperation => $args->{biddingDataExclusionOperation},
    biddingSeasonalityAdjustmentOperation =>
      $args->{biddingSeasonalityAdjustmentOperation},
    biddingStrategyOperation          => $args->{biddingStrategyOperation},
    campaignAssetOperation            => $args->{campaignAssetOperation},
    campaignBidModifierOperation      => $args->{campaignBidModifierOperation},
    campaignBudgetOperation           => $args->{campaignBudgetOperation},
    campaignCriterionOperation        => $args->{campaignCriterionOperation},
    campaignDraftOperation            => $args->{campaignDraftOperation},
    campaignExperimentOperation       => $args->{campaignExperimentOperation},
    campaignExtensionSettingOperation =>
      $args->{campaignExtensionSettingOperation},
    campaignFeedOperation             => $args->{campaignFeedOperation},
    campaignLabelOperation            => $args->{campaignLabelOperation},
    campaignOperation                 => $args->{campaignOperation},
    campaignSharedSetOperation        => $args->{campaignSharedSetOperation},
    conversionActionOperation         => $args->{conversionActionOperation},
    conversionCustomVariableOperation =>
      $args->{conversionCustomVariableOperation},
    conversionValueRuleOperation    => $args->{conversionValueRuleOperation},
    conversionValueRuleSetOperation => $args->{conversionValueRuleSetOperation},
    customerAssetOperation          => $args->{customerAssetOperation},
    customerExtensionSettingOperation =>
      $args->{customerExtensionSettingOperation},
    customerFeedOperation              => $args->{customerFeedOperation},
    customerLabelOperation             => $args->{customerLabelOperation},
    customerNegativeCriterionOperation =>
      $args->{customerNegativeCriterionOperation},
    customerOperation                  => $args->{customerOperation},
    extensionFeedItemOperation         => $args->{extensionFeedItemOperation},
    feedItemOperation                  => $args->{feedItemOperation},
    feedItemSetLinkOperation           => $args->{feedItemSetLinkOperation},
    feedItemSetOperation               => $args->{feedItemSetOperation},
    feedItemTargetOperation            => $args->{feedItemTargetOperation},
    feedMappingOperation               => $args->{feedMappingOperation},
    feedOperation                      => $args->{feedOperation},
    keywordPlanAdGroupKeywordOperation =>
      $args->{keywordPlanAdGroupKeywordOperation},
    keywordPlanAdGroupOperation         => $args->{keywordPlanAdGroupOperation},
    keywordPlanCampaignKeywordOperation =>
      $args->{keywordPlanCampaignKeywordOperation},
    keywordPlanCampaignOperation  => $args->{keywordPlanCampaignOperation},
    keywordPlanOperation          => $args->{keywordPlanOperation},
    labelOperation                => $args->{labelOperation},
    mediaFileOperation            => $args->{mediaFileOperation},
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
