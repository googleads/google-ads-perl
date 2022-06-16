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

package Google::Ads::GoogleAds::V11::Resources::Campaign;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    accessibleBiddingStrategy     => $args->{accessibleBiddingStrategy},
    adServingOptimizationStatus   => $args->{adServingOptimizationStatus},
    advertisingChannelSubType     => $args->{advertisingChannelSubType},
    advertisingChannelType        => $args->{advertisingChannelType},
    appCampaignSetting            => $args->{appCampaignSetting},
    audienceSetting               => $args->{audienceSetting},
    baseCampaign                  => $args->{baseCampaign},
    biddingStrategy               => $args->{biddingStrategy},
    biddingStrategyType           => $args->{biddingStrategyType},
    campaignBudget                => $args->{campaignBudget},
    campaignGroup                 => $args->{campaignGroup},
    commission                    => $args->{commission},
    dynamicSearchAdsSetting       => $args->{dynamicSearchAdsSetting},
    endDate                       => $args->{endDate},
    excludedParentAssetFieldTypes => $args->{excludedParentAssetFieldTypes},
    experimentType                => $args->{experimentType},
    finalUrlSuffix                => $args->{finalUrlSuffix},
    frequencyCaps                 => $args->{frequencyCaps},
    geoTargetTypeSetting          => $args->{geoTargetTypeSetting},
    hotelSetting                  => $args->{hotelSetting},
    id                            => $args->{id},
    labels                        => $args->{labels},
    localCampaignSetting          => $args->{localCampaignSetting},
    localServicesCampaignSettings => $args->{localServicesCampaignSettings},
    manualCpa                     => $args->{manualCpa},
    manualCpc                     => $args->{manualCpc},
    manualCpm                     => $args->{manualCpm},
    manualCpv                     => $args->{manualCpv},
    maximizeConversionValue       => $args->{maximizeConversionValue},
    maximizeConversions           => $args->{maximizeConversions},
    name                          => $args->{name},
    networkSettings               => $args->{networkSettings},
    optimizationGoalSetting       => $args->{optimizationGoalSetting},
    optimizationScore             => $args->{optimizationScore},
    paymentMode                   => $args->{paymentMode},
    percentCpc                    => $args->{percentCpc},
    performanceMaxUpgrade         => $args->{performanceMaxUpgrade},
    realTimeBiddingSetting        => $args->{realTimeBiddingSetting},
    resourceName                  => $args->{resourceName},
    selectiveOptimization         => $args->{selectiveOptimization},
    servingStatus                 => $args->{servingStatus},
    shoppingSetting               => $args->{shoppingSetting},
    startDate                     => $args->{startDate},
    status                        => $args->{status},
    targetCpa                     => $args->{targetCpa},
    targetCpm                     => $args->{targetCpm},
    targetImpressionShare         => $args->{targetImpressionShare},
    targetRoas                    => $args->{targetRoas},
    targetSpend                   => $args->{targetSpend},
    targetingSetting              => $args->{targetingSetting},
    trackingSetting               => $args->{trackingSetting},
    trackingUrlTemplate           => $args->{trackingUrlTemplate},
    urlCustomParameters           => $args->{urlCustomParameters},
    urlExpansionOptOut            => $args->{urlExpansionOptOut},
    vanityPharma                  => $args->{vanityPharma},
    videoBrandSafetySuitability   => $args->{videoBrandSafetySuitability}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
