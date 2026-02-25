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

package Google::Ads::GoogleAds::V21::Resources::Campaign;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    accessibleBiddingStrategy      => $args->{accessibleBiddingStrategy},
    adServingOptimizationStatus    => $args->{adServingOptimizationStatus},
    advertisingChannelSubType      => $args->{advertisingChannelSubType},
    advertisingChannelType         => $args->{advertisingChannelType},
    aiMaxSetting                   => $args->{aiMaxSetting},
    appCampaignSetting             => $args->{appCampaignSetting},
    assetAutomationSettings        => $args->{assetAutomationSettings},
    audienceSetting                => $args->{audienceSetting},
    baseCampaign                   => $args->{baseCampaign},
    biddingStrategy                => $args->{biddingStrategy},
    biddingStrategySystemStatus    => $args->{biddingStrategySystemStatus},
    biddingStrategyType            => $args->{biddingStrategyType},
    brandGuidelines                => $args->{brandGuidelines},
    brandGuidelinesEnabled         => $args->{brandGuidelinesEnabled},
    campaignBudget                 => $args->{campaignBudget},
    campaignGroup                  => $args->{campaignGroup},
    commission                     => $args->{commission},
    containsEuPoliticalAdvertising => $args->{containsEuPoliticalAdvertising},
    demandGenCampaignSettings      => $args->{demandGenCampaignSettings},
    dynamicSearchAdsSetting        => $args->{dynamicSearchAdsSetting},
    endDate                        => $args->{endDate},
    excludedParentAssetFieldTypes  => $args->{excludedParentAssetFieldTypes},
    excludedParentAssetSetTypes    => $args->{excludedParentAssetSetTypes},
    experimentType                 => $args->{experimentType},
    finalUrlSuffix                 => $args->{finalUrlSuffix},
    fixedCpm                       => $args->{fixedCpm},
    frequencyCaps                  => $args->{frequencyCaps},
    geoTargetTypeSetting           => $args->{geoTargetTypeSetting},
    hotelPropertyAssetSet          => $args->{hotelPropertyAssetSet},
    hotelSetting                   => $args->{hotelSetting},
    id                             => $args->{id},
    keywordMatchType               => $args->{keywordMatchType},
    labels                         => $args->{labels},
    listingType                    => $args->{listingType},
    localCampaignSetting           => $args->{localCampaignSetting},
    localServicesCampaignSettings  => $args->{localServicesCampaignSettings},
    manualCpa                      => $args->{manualCpa},
    manualCpc                      => $args->{manualCpc},
    manualCpm                      => $args->{manualCpm},
    manualCpv                      => $args->{manualCpv},
    maximizeConversionValue        => $args->{maximizeConversionValue},
    maximizeConversions            => $args->{maximizeConversions},
    missingEuPoliticalAdvertisingDeclaration =>
      $args->{missingEuPoliticalAdvertisingDeclaration},
    name                          => $args->{name},
    networkSettings               => $args->{networkSettings},
    optimizationGoalSetting       => $args->{optimizationGoalSetting},
    optimizationScore             => $args->{optimizationScore},
    paymentMode                   => $args->{paymentMode},
    percentCpc                    => $args->{percentCpc},
    performanceMaxUpgrade         => $args->{performanceMaxUpgrade},
    pmaxCampaignSettings          => $args->{pmaxCampaignSettings},
    primaryStatus                 => $args->{primaryStatus},
    primaryStatusReasons          => $args->{primaryStatusReasons},
    realTimeBiddingSetting        => $args->{realTimeBiddingSetting},
    resourceName                  => $args->{resourceName},
    selectiveOptimization         => $args->{selectiveOptimization},
    servingStatus                 => $args->{servingStatus},
    shoppingSetting               => $args->{shoppingSetting},
    startDate                     => $args->{startDate},
    status                        => $args->{status},
    targetCpa                     => $args->{targetCpa},
    targetCpm                     => $args->{targetCpm},
    targetCpv                     => $args->{targetCpv},
    targetImpressionShare         => $args->{targetImpressionShare},
    targetRoas                    => $args->{targetRoas},
    targetSpend                   => $args->{targetSpend},
    targetingSetting              => $args->{targetingSetting},
    thirdPartyIntegrationPartners => $args->{thirdPartyIntegrationPartners},
    trackingSetting               => $args->{trackingSetting},
    trackingUrlTemplate           => $args->{trackingUrlTemplate},
    travelCampaignSettings        => $args->{travelCampaignSettings},
    urlCustomParameters           => $args->{urlCustomParameters},
    urlExpansionOptOut            => $args->{urlExpansionOptOut},
    vanityPharma                  => $args->{vanityPharma},
    videoBrandSafetySuitability   => $args->{videoBrandSafetySuitability},
    videoCampaignSettings         => $args->{videoCampaignSettings}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
