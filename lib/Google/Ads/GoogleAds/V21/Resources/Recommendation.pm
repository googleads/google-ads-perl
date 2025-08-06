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

package Google::Ads::GoogleAds::V21::Resources::Recommendation;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    adGroup                           => $args->{adGroup},
    callAssetRecommendation           => $args->{callAssetRecommendation},
    calloutAssetRecommendation        => $args->{calloutAssetRecommendation},
    campaign                          => $args->{campaign},
    campaignBudget                    => $args->{campaignBudget},
    campaignBudgetRecommendation      => $args->{campaignBudgetRecommendation},
    campaigns                         => $args->{campaigns},
    customAudienceOptInRecommendation =>
      $args->{customAudienceOptInRecommendation},
    dismissed                           => $args->{dismissed},
    displayExpansionOptInRecommendation =>
      $args->{displayExpansionOptInRecommendation},
    dynamicImageExtensionOptInRecommendation =>
      $args->{dynamicImageExtensionOptInRecommendation},
    enhancedCpcOptInRecommendation => $args->{enhancedCpcOptInRecommendation},
    forecastingCampaignBudgetRecommendation =>
      $args->{forecastingCampaignBudgetRecommendation},
    forecastingSetTargetCpaRecommendation =>
      $args->{forecastingSetTargetCpaRecommendation},
    forecastingSetTargetRoasRecommendation =>
      $args->{forecastingSetTargetRoasRecommendation},
    impact                                   => $args->{impact},
    improveDemandGenAdStrengthRecommendation =>
      $args->{improveDemandGenAdStrengthRecommendation},
    improveGoogleTagCoverageRecommendation =>
      $args->{improveGoogleTagCoverageRecommendation},
    improvePerformanceMaxAdStrengthRecommendation =>
      $args->{improvePerformanceMaxAdStrengthRecommendation},
    keywordMatchTypeRecommendation => $args->{keywordMatchTypeRecommendation},
    keywordRecommendation          => $args->{keywordRecommendation},
    leadFormAssetRecommendation    => $args->{leadFormAssetRecommendation},
    lowerTargetRoasRecommendation  => $args->{lowerTargetRoasRecommendation},
    marginalRoiCampaignBudgetRecommendation =>
      $args->{marginalRoiCampaignBudgetRecommendation},
    maximizeClicksOptInRecommendation =>
      $args->{maximizeClicksOptInRecommendation},
    maximizeConversionValueOptInRecommendation =>
      $args->{maximizeConversionValueOptInRecommendation},
    maximizeConversionsOptInRecommendation =>
      $args->{maximizeConversionsOptInRecommendation},
    migrateDynamicSearchAdsCampaignToPerformanceMaxRecommendation =>
      $args->{migrateDynamicSearchAdsCampaignToPerformanceMaxRecommendation},
    moveUnusedBudgetRecommendation   => $args->{moveUnusedBudgetRecommendation},
    optimizeAdRotationRecommendation =>
      $args->{optimizeAdRotationRecommendation},
    performanceMaxFinalUrlOptInRecommendation =>
      $args->{performanceMaxFinalUrlOptInRecommendation},
    performanceMaxOptInRecommendation =>
      $args->{performanceMaxOptInRecommendation},
    raiseTargetCpaBidTooLowRecommendation =>
      $args->{raiseTargetCpaBidTooLowRecommendation},
    raiseTargetCpaRecommendation => $args->{raiseTargetCpaRecommendation},
    refreshCustomerMatchListRecommendation =>
      $args->{refreshCustomerMatchListRecommendation},
    resourceName                          => $args->{resourceName},
    responsiveSearchAdAssetRecommendation =>
      $args->{responsiveSearchAdAssetRecommendation},
    responsiveSearchAdImproveAdStrengthRecommendation =>
      $args->{responsiveSearchAdImproveAdStrengthRecommendation},
    responsiveSearchAdRecommendation =>
      $args->{responsiveSearchAdRecommendation},
    searchPartnersOptInRecommendation =>
      $args->{searchPartnersOptInRecommendation},
    setTargetCpaRecommendation        => $args->{setTargetCpaRecommendation},
    setTargetRoasRecommendation       => $args->{setTargetRoasRecommendation},
    shoppingAddAgeGroupRecommendation =>
      $args->{shoppingAddAgeGroupRecommendation},
    shoppingAddColorRecommendation  => $args->{shoppingAddColorRecommendation},
    shoppingAddGenderRecommendation => $args->{shoppingAddGenderRecommendation},
    shoppingAddGtinRecommendation   => $args->{shoppingAddGtinRecommendation},
    shoppingAddMoreIdentifiersRecommendation =>
      $args->{shoppingAddMoreIdentifiersRecommendation},
    shoppingAddProductsToCampaignRecommendation =>
      $args->{shoppingAddProductsToCampaignRecommendation},
    shoppingAddSizeRecommendation => $args->{shoppingAddSizeRecommendation},
    shoppingFixDisapprovedProductsRecommendation =>
      $args->{shoppingFixDisapprovedProductsRecommendation},
    shoppingFixMerchantCenterAccountSuspensionWarningRecommendation =>
      $args->{shoppingFixMerchantCenterAccountSuspensionWarningRecommendation},
    shoppingFixSuspendedMerchantCenterAccountRecommendation =>
      $args->{shoppingFixSuspendedMerchantCenterAccountRecommendation},
    shoppingMigrateRegularShoppingCampaignOffersToPerformanceMaxRecommendation =>
      $args->
      {shoppingMigrateRegularShoppingCampaignOffersToPerformanceMaxRecommendation}
    ,
    shoppingTargetAllOffersRecommendation =>
      $args->{shoppingTargetAllOffersRecommendation},
    sitelinkAssetRecommendation   => $args->{sitelinkAssetRecommendation},
    targetCpaOptInRecommendation  => $args->{targetCpaOptInRecommendation},
    targetRoasOptInRecommendation => $args->{targetRoasOptInRecommendation},
    textAdRecommendation          => $args->{textAdRecommendation},
    type                          => $args->{type},
    upgradeLocalCampaignToPerformanceMaxRecommendation =>
      $args->{upgradeLocalCampaignToPerformanceMaxRecommendation},
    upgradeSmartShoppingCampaignToPerformanceMaxRecommendation =>
      $args->{upgradeSmartShoppingCampaignToPerformanceMaxRecommendation},
    useBroadMatchKeywordRecommendation =>
      $args->{useBroadMatchKeywordRecommendation}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
