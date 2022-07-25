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

package Google::Ads::GoogleAds::V11::Services::GoogleAdsService::GoogleAdsRow;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    accessibleBiddingStrategy      => $args->{accessibleBiddingStrategy},
    accountBudget                  => $args->{accountBudget},
    accountBudgetProposal          => $args->{accountBudgetProposal},
    accountLink                    => $args->{accountLink},
    adGroup                        => $args->{adGroup},
    adGroupAd                      => $args->{adGroupAd},
    adGroupAdAssetCombinationView  => $args->{adGroupAdAssetCombinationView},
    adGroupAdAssetView             => $args->{adGroupAdAssetView},
    adGroupAdLabel                 => $args->{adGroupAdLabel},
    adGroupAsset                   => $args->{adGroupAsset},
    adGroupAudienceView            => $args->{adGroupAudienceView},
    adGroupBidModifier             => $args->{adGroupBidModifier},
    adGroupCriterion               => $args->{adGroupCriterion},
    adGroupCriterionCustomizer     => $args->{adGroupCriterionCustomizer},
    adGroupCriterionLabel          => $args->{adGroupCriterionLabel},
    adGroupCriterionSimulation     => $args->{adGroupCriterionSimulation},
    adGroupCustomizer              => $args->{adGroupCustomizer},
    adGroupExtensionSetting        => $args->{adGroupExtensionSetting},
    adGroupFeed                    => $args->{adGroupFeed},
    adGroupLabel                   => $args->{adGroupLabel},
    adGroupSimulation              => $args->{adGroupSimulation},
    adParameter                    => $args->{adParameter},
    adScheduleView                 => $args->{adScheduleView},
    ageRangeView                   => $args->{ageRangeView},
    asset                          => $args->{asset},
    assetFieldTypeView             => $args->{assetFieldTypeView},
    assetGroup                     => $args->{assetGroup},
    assetGroupAsset                => $args->{assetGroupAsset},
    assetGroupListingGroupFilter   => $args->{assetGroupListingGroupFilter},
    assetGroupProductGroupView     => $args->{assetGroupProductGroupView},
    assetGroupSignal               => $args->{assetGroupSignal},
    assetSet                       => $args->{assetSet},
    assetSetAsset                  => $args->{assetSetAsset},
    audience                       => $args->{audience},
    batchJob                       => $args->{batchJob},
    biddingDataExclusion           => $args->{biddingDataExclusion},
    biddingSeasonalityAdjustment   => $args->{biddingSeasonalityAdjustment},
    biddingStrategy                => $args->{biddingStrategy},
    biddingStrategySimulation      => $args->{biddingStrategySimulation},
    billingSetup                   => $args->{billingSetup},
    callView                       => $args->{callView},
    campaign                       => $args->{campaign},
    campaignAsset                  => $args->{campaignAsset},
    campaignAssetSet               => $args->{campaignAssetSet},
    campaignAudienceView           => $args->{campaignAudienceView},
    campaignBidModifier            => $args->{campaignBidModifier},
    campaignBudget                 => $args->{campaignBudget},
    campaignConversionGoal         => $args->{campaignConversionGoal},
    campaignCriterion              => $args->{campaignCriterion},
    campaignCriterionSimulation    => $args->{campaignCriterionSimulation},
    campaignCustomizer             => $args->{campaignCustomizer},
    campaignDraft                  => $args->{campaignDraft},
    campaignExperiment             => $args->{campaignExperiment},
    campaignExtensionSetting       => $args->{campaignExtensionSetting},
    campaignFeed                   => $args->{campaignFeed},
    campaignGroup                  => $args->{campaignGroup},
    campaignLabel                  => $args->{campaignLabel},
    campaignSharedSet              => $args->{campaignSharedSet},
    campaignSimulation             => $args->{campaignSimulation},
    carrierConstant                => $args->{carrierConstant},
    changeEvent                    => $args->{changeEvent},
    changeStatus                   => $args->{changeStatus},
    clickView                      => $args->{clickView},
    combinedAudience               => $args->{combinedAudience},
    conversionAction               => $args->{conversionAction},
    conversionCustomVariable       => $args->{conversionCustomVariable},
    conversionGoalCampaignConfig   => $args->{conversionGoalCampaignConfig},
    conversionValueRule            => $args->{conversionValueRule},
    conversionValueRuleSet         => $args->{conversionValueRuleSet},
    currencyConstant               => $args->{currencyConstant},
    customAudience                 => $args->{customAudience},
    customConversionGoal           => $args->{customConversionGoal},
    customInterest                 => $args->{customInterest},
    customer                       => $args->{customer},
    customerAsset                  => $args->{customerAsset},
    customerClient                 => $args->{customerClient},
    customerClientLink             => $args->{customerClientLink},
    customerConversionGoal         => $args->{customerConversionGoal},
    customerCustomizer             => $args->{customerCustomizer},
    customerExtensionSetting       => $args->{customerExtensionSetting},
    customerFeed                   => $args->{customerFeed},
    customerLabel                  => $args->{customerLabel},
    customerManagerLink            => $args->{customerManagerLink},
    customerNegativeCriterion      => $args->{customerNegativeCriterion},
    customerUserAccess             => $args->{customerUserAccess},
    customerUserAccessInvitation   => $args->{customerUserAccessInvitation},
    customizerAttribute            => $args->{customizerAttribute},
    detailPlacementView            => $args->{detailPlacementView},
    detailedDemographic            => $args->{detailedDemographic},
    displayKeywordView             => $args->{displayKeywordView},
    distanceView                   => $args->{distanceView},
    domainCategory                 => $args->{domainCategory},
    dynamicSearchAdsSearchTermView => $args->{dynamicSearchAdsSearchTermView},
    expandedLandingPageView        => $args->{expandedLandingPageView},
    experiment                     => $args->{experiment},
    experimentArm                  => $args->{experimentArm},
    extensionFeedItem              => $args->{extensionFeedItem},
    feed                           => $args->{feed},
    feedItem                       => $args->{feedItem},
    feedItemSet                    => $args->{feedItemSet},
    feedItemSetLink                => $args->{feedItemSetLink},
    feedItemTarget                 => $args->{feedItemTarget},
    feedMapping                    => $args->{feedMapping},
    feedPlaceholderView            => $args->{feedPlaceholderView},
    genderView                     => $args->{genderView},
    geoTargetConstant              => $args->{geoTargetConstant},
    geographicView                 => $args->{geographicView},
    groupPlacementView             => $args->{groupPlacementView},
    hotelGroupView                 => $args->{hotelGroupView},
    hotelPerformanceView           => $args->{hotelPerformanceView},
    hotelReconciliation            => $args->{hotelReconciliation},
    incomeRangeView                => $args->{incomeRangeView},
    keywordPlan                    => $args->{keywordPlan},
    keywordPlanAdGroup             => $args->{keywordPlanAdGroup},
    keywordPlanAdGroupKeyword      => $args->{keywordPlanAdGroupKeyword},
    keywordPlanCampaign            => $args->{keywordPlanCampaign},
    keywordPlanCampaignKeyword     => $args->{keywordPlanCampaignKeyword},
    keywordThemeConstant           => $args->{keywordThemeConstant},
    keywordView                    => $args->{keywordView},
    label                          => $args->{label},
    landingPageView                => $args->{landingPageView},
    languageConstant               => $args->{languageConstant},
    leadFormSubmissionData         => $args->{leadFormSubmissionData},
    lifeEvent                      => $args->{lifeEvent},
    locationView                   => $args->{locationView},
    managedPlacementView           => $args->{managedPlacementView},
    mediaFile                      => $args->{mediaFile},
    metrics                        => $args->{metrics},
    mobileAppCategoryConstant      => $args->{mobileAppCategoryConstant},
    mobileDeviceConstant           => $args->{mobileDeviceConstant},
    offlineUserDataJob             => $args->{offlineUserDataJob},
    operatingSystemVersionConstant => $args->{operatingSystemVersionConstant},
    paidOrganicSearchTermView      => $args->{paidOrganicSearchTermView},
    parentalStatusView             => $args->{parentalStatusView},
    productBiddingCategoryConstant => $args->{productBiddingCategoryConstant},
    productGroupView               => $args->{productGroupView},
    recommendation                 => $args->{recommendation},
    remarketingAction              => $args->{remarketingAction},
    searchTermView                 => $args->{searchTermView},
    segments                       => $args->{segments},
    sharedCriterion                => $args->{sharedCriterion},
    sharedSet                      => $args->{sharedSet},
    shoppingPerformanceView        => $args->{shoppingPerformanceView},
    smartCampaignSearchTermView    => $args->{smartCampaignSearchTermView},
    smartCampaignSetting           => $args->{smartCampaignSetting},
    thirdPartyAppAnalyticsLink     => $args->{thirdPartyAppAnalyticsLink},
    topicConstant                  => $args->{topicConstant},
    topicView                      => $args->{topicView},
    userInterest                   => $args->{userInterest},
    userList                       => $args->{userList},
    userLocationView               => $args->{userLocationView},
    video                          => $args->{video},
    webpageView                    => $args->{webpageView}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;