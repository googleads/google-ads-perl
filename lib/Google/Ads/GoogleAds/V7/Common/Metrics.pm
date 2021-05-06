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

package Google::Ads::GoogleAds::V7::Common::Metrics;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    absoluteTopImpressionPercentage => $args->{absoluteTopImpressionPercentage},
    activeViewCpm                   => $args->{activeViewCpm},
    activeViewCtr                   => $args->{activeViewCtr},
    activeViewImpressions           => $args->{activeViewImpressions},
    activeViewMeasurability         => $args->{activeViewMeasurability},
    activeViewMeasurableCostMicros  => $args->{activeViewMeasurableCostMicros},
    activeViewMeasurableImpressions => $args->{activeViewMeasurableImpressions},
    activeViewViewability           => $args->{activeViewViewability},
    allConversions                  => $args->{allConversions},
    allConversionsByConversionDate  => $args->{allConversionsByConversionDate},
    allConversionsFromClickToCall   => $args->{allConversionsFromClickToCall},
    allConversionsFromDirections    => $args->{allConversionsFromDirections},
    allConversionsFromInteractionsRate =>
      $args->{allConversionsFromInteractionsRate},
    allConversionsFromInteractionsValuePerInteraction =>
      $args->{allConversionsFromInteractionsValuePerInteraction},
    allConversionsFromMenu            => $args->{allConversionsFromMenu},
    allConversionsFromOrder           => $args->{allConversionsFromOrder},
    allConversionsFromOtherEngagement =>
      $args->{allConversionsFromOtherEngagement},
    allConversionsFromStoreVisit   => $args->{allConversionsFromStoreVisit},
    allConversionsFromStoreWebsite => $args->{allConversionsFromStoreWebsite},
    allConversionsValue            => $args->{allConversionsValue},
    allConversionsValueByConversionDate =>
      $args->{allConversionsValueByConversionDate},
    allConversionsValuePerCost       => $args->{allConversionsValuePerCost},
    averageCost                      => $args->{averageCost},
    averageCpc                       => $args->{averageCpc},
    averageCpe                       => $args->{averageCpe},
    averageCpm                       => $args->{averageCpm},
    averageCpv                       => $args->{averageCpv},
    averagePageViews                 => $args->{averagePageViews},
    averageTimeOnSite                => $args->{averageTimeOnSite},
    benchmarkAverageMaxCpc           => $args->{benchmarkAverageMaxCpc},
    benchmarkCtr                     => $args->{benchmarkCtr},
    bounceRate                       => $args->{bounceRate},
    clicks                           => $args->{clicks},
    combinedClicks                   => $args->{combinedClicks},
    combinedClicksPerQuery           => $args->{combinedClicksPerQuery},
    combinedQueries                  => $args->{combinedQueries},
    contentBudgetLostImpressionShare =>
      $args->{contentBudgetLostImpressionShare},
    contentImpressionShare         => $args->{contentImpressionShare},
    contentRankLostImpressionShare => $args->{contentRankLostImpressionShare},
    conversionLastConversionDate   => $args->{conversionLastConversionDate},
    conversionLastReceivedRequestDateTime =>
      $args->{conversionLastReceivedRequestDateTime},
    conversions                     => $args->{conversions},
    conversionsByConversionDate     => $args->{conversionsByConversionDate},
    conversionsFromInteractionsRate => $args->{conversionsFromInteractionsRate},
    conversionsFromInteractionsValuePerInteraction =>
      $args->{conversionsFromInteractionsValuePerInteraction},
    conversionsValue                 => $args->{conversionsValue},
    conversionsValueByConversionDate =>
      $args->{conversionsValueByConversionDate},
    conversionsValuePerCost                 => $args->{conversionsValuePerCost},
    costMicros                              => $args->{costMicros},
    costPerAllConversions                   => $args->{costPerAllConversions},
    costPerConversion                       => $args->{costPerConversion},
    costPerCurrentModelAttributedConversion =>
      $args->{costPerCurrentModelAttributedConversion},
    crossDeviceConversions            => $args->{crossDeviceConversions},
    ctr                               => $args->{ctr},
    currentModelAttributedConversions =>
      $args->{currentModelAttributedConversions},
    currentModelAttributedConversionsFromInteractionsRate =>
      $args->{currentModelAttributedConversionsFromInteractionsRate},
    currentModelAttributedConversionsFromInteractionsValuePerInteraction =>
      $args->
      {currentModelAttributedConversionsFromInteractionsValuePerInteraction},
    currentModelAttributedConversionsValue =>
      $args->{currentModelAttributedConversionsValue},
    currentModelAttributedConversionsValuePerCost =>
      $args->{currentModelAttributedConversionsValuePerCost},
    engagementRate                 => $args->{engagementRate},
    engagements                    => $args->{engagements},
    gmailForwards                  => $args->{gmailForwards},
    gmailSaves                     => $args->{gmailSaves},
    gmailSecondaryClicks           => $args->{gmailSecondaryClicks},
    historicalCreativeQualityScore => $args->{historicalCreativeQualityScore},
    historicalLandingPageQualityScore =>
      $args->{historicalLandingPageQualityScore},
    historicalQualityScore           => $args->{historicalQualityScore},
    historicalSearchPredictedCtr     => $args->{historicalSearchPredictedCtr},
    hotelAverageLeadValueMicros      => $args->{hotelAverageLeadValueMicros},
    hotelEligibleImpressions         => $args->{hotelEligibleImpressions},
    hotelPriceDifferencePercentage   => $args->{hotelPriceDifferencePercentage},
    impressions                      => $args->{impressions},
    impressionsFromStoreReach        => $args->{impressionsFromStoreReach},
    interactionEventTypes            => $args->{interactionEventTypes},
    interactionRate                  => $args->{interactionRate},
    interactions                     => $args->{interactions},
    invalidClickRate                 => $args->{invalidClickRate},
    invalidClicks                    => $args->{invalidClicks},
    messageChatRate                  => $args->{messageChatRate},
    messageChats                     => $args->{messageChats},
    messageImpressions               => $args->{messageImpressions},
    mobileFriendlyClicksPercentage   => $args->{mobileFriendlyClicksPercentage},
    organicClicks                    => $args->{organicClicks},
    organicClicksPerQuery            => $args->{organicClicksPerQuery},
    organicImpressions               => $args->{organicImpressions},
    organicImpressionsPerQuery       => $args->{organicImpressionsPerQuery},
    organicQueries                   => $args->{organicQueries},
    percentNewVisitors               => $args->{percentNewVisitors},
    phoneCalls                       => $args->{phoneCalls},
    phoneImpressions                 => $args->{phoneImpressions},
    phoneThroughRate                 => $args->{phoneThroughRate},
    relativeCtr                      => $args->{relativeCtr},
    searchAbsoluteTopImpressionShare =>
      $args->{searchAbsoluteTopImpressionShare},
    searchBudgetLostAbsoluteTopImpressionShare =>
      $args->{searchBudgetLostAbsoluteTopImpressionShare},
    searchBudgetLostImpressionShare => $args->{searchBudgetLostImpressionShare},
    searchBudgetLostTopImpressionShare =>
      $args->{searchBudgetLostTopImpressionShare},
    searchClickShare                => $args->{searchClickShare},
    searchExactMatchImpressionShare => $args->{searchExactMatchImpressionShare},
    searchImpressionShare           => $args->{searchImpressionShare},
    searchRankLostAbsoluteTopImpressionShare =>
      $args->{searchRankLostAbsoluteTopImpressionShare},
    searchRankLostImpressionShare    => $args->{searchRankLostImpressionShare},
    searchRankLostTopImpressionShare =>
      $args->{searchRankLostTopImpressionShare},
    searchTopImpressionShare => $args->{searchTopImpressionShare},
    skAdNetworkConversions   => $args->{skAdNetworkConversions},
    speedScore               => $args->{speedScore},
    topImpressionPercentage  => $args->{topImpressionPercentage},
    validAcceleratedMobilePagesClicksPercentage =>
      $args->{validAcceleratedMobilePagesClicksPercentage},
    valuePerAllConversions                 => $args->{valuePerAllConversions},
    valuePerAllConversionsByConversionDate =>
      $args->{valuePerAllConversionsByConversionDate},
    valuePerConversion                  => $args->{valuePerConversion},
    valuePerConversionsByConversionDate =>
      $args->{valuePerConversionsByConversionDate},
    valuePerCurrentModelAttributedConversion =>
      $args->{valuePerCurrentModelAttributedConversion},
    videoQuartileP100Rate  => $args->{videoQuartileP100Rate},
    videoQuartileP25Rate   => $args->{videoQuartileP25Rate},
    videoQuartileP50Rate   => $args->{videoQuartileP50Rate},
    videoQuartileP75Rate   => $args->{videoQuartileP75Rate},
    videoViewRate          => $args->{videoViewRate},
    videoViews             => $args->{videoViews},
    viewThroughConversions => $args->{viewThroughConversions}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
