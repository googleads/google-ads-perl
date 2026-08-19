# Copyright 2026, Google LLC
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

package Google::Ads::GoogleAds::V25::Common::Metrics;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    absoluteBrandLift               => $args->{absoluteBrandLift},
    absoluteBrandLiftP90LowerBound  => $args->{absoluteBrandLiftP90LowerBound},
    absoluteBrandLiftP90UpperBound  => $args->{absoluteBrandLiftP90UpperBound},
    absoluteBrandLiftPValue         => $args->{absoluteBrandLiftPValue},
    absoluteTopImpressionPercentage => $args->{absoluteTopImpressionPercentage},
    activeViewAudibilityInvalidGivtMeasurableImpressionsRate =>
      $args->{activeViewAudibilityInvalidGivtMeasurableImpressionsRate},
    activeViewAudibilityInvalidMeasurableImpressionsRate =>
      $args->{activeViewAudibilityInvalidMeasurableImpressionsRate},
    activeViewAudibilityMeasurableImpressions =>
      $args->{activeViewAudibilityMeasurableImpressions},
    activeViewAudibilityMeasurableImpressionsRate =>
      $args->{activeViewAudibilityMeasurableImpressionsRate},
    activeViewAudibleImpressions     => $args->{activeViewAudibleImpressions},
    activeViewAudibleImpressionsRate =>
      $args->{activeViewAudibleImpressionsRate},
    activeViewAudibleQuartileP100Rate =>
      $args->{activeViewAudibleQuartileP100Rate},
    activeViewAudibleQuartileP25Rate =>
      $args->{activeViewAudibleQuartileP25Rate},
    activeViewAudibleQuartileP50Rate =>
      $args->{activeViewAudibleQuartileP50Rate},
    activeViewAudibleQuartileP75Rate =>
      $args->{activeViewAudibleQuartileP75Rate},
    activeViewAudibleThirtySecondsImpressions =>
      $args->{activeViewAudibleThirtySecondsImpressions},
    activeViewAudibleThirtySecondsImpressionsRate =>
      $args->{activeViewAudibleThirtySecondsImpressionsRate},
    activeViewAudibleTwoSecondsImpressions =>
      $args->{activeViewAudibleTwoSecondsImpressions},
    activeViewAudibleTwoSecondsImpressionsRate =>
      $args->{activeViewAudibleTwoSecondsImpressionsRate},
    activeViewCpm                   => $args->{activeViewCpm},
    activeViewCtr                   => $args->{activeViewCtr},
    activeViewImpressions           => $args->{activeViewImpressions},
    activeViewMeasurability         => $args->{activeViewMeasurability},
    activeViewMeasurableCostMicros  => $args->{activeViewMeasurableCostMicros},
    activeViewMeasurableImpressions => $args->{activeViewMeasurableImpressions},
    activeViewViewability           => $args->{activeViewViewability},
    allAverageCartSize              => $args->{allAverageCartSize},
    allAverageOrderValueMicros      => $args->{allAverageOrderValueMicros},
    allConversions                  => $args->{allConversions},
    allConversionsByConversionDate  => $args->{allConversionsByConversionDate},
    allConversionsFromClickToCall   => $args->{allConversionsFromClickToCall},
    allConversionsFromDirections    => $args->{allConversionsFromDirections},
    allConversionsFromInteractionsRate =>
      $args->{allConversionsFromInteractionsRate},
    allConversionsFromInteractionsValuePerInteraction =>
      $args->{allConversionsFromInteractionsValuePerInteraction},
    allConversionsFromLocationAssetClickToCall =>
      $args->{allConversionsFromLocationAssetClickToCall},
    allConversionsFromLocationAssetDirections =>
      $args->{allConversionsFromLocationAssetDirections},
    allConversionsFromLocationAssetMenu =>
      $args->{allConversionsFromLocationAssetMenu},
    allConversionsFromLocationAssetOrder =>
      $args->{allConversionsFromLocationAssetOrder},
    allConversionsFromLocationAssetOtherEngagement =>
      $args->{allConversionsFromLocationAssetOtherEngagement},
    allConversionsFromLocationAssetStoreVisits =>
      $args->{allConversionsFromLocationAssetStoreVisits},
    allConversionsFromLocationAssetWebsite =>
      $args->{allConversionsFromLocationAssetWebsite},
    allConversionsFromMenu            => $args->{allConversionsFromMenu},
    allConversionsFromOrder           => $args->{allConversionsFromOrder},
    allConversionsFromOtherEngagement =>
      $args->{allConversionsFromOtherEngagement},
    allConversionsFromStoreVisit   => $args->{allConversionsFromStoreVisit},
    allConversionsFromStoreWebsite => $args->{allConversionsFromStoreWebsite},
    allConversionsValue            => $args->{allConversionsValue},
    allConversionsValueByConversionDate =>
      $args->{allConversionsValueByConversionDate},
    allConversionsValuePerCost        => $args->{allConversionsValuePerCost},
    allCostOfGoodsSoldMicros          => $args->{allCostOfGoodsSoldMicros},
    allCrossSellCostOfGoodsSoldMicros =>
      $args->{allCrossSellCostOfGoodsSoldMicros},
    allCrossSellGrossProfitMicros => $args->{allCrossSellGrossProfitMicros},
    allCrossSellRevenueMicros     => $args->{allCrossSellRevenueMicros},
    allCrossSellUnitsSold         => $args->{allCrossSellUnitsSold},
    allGrossProfitMargin          => $args->{allGrossProfitMargin},
    allGrossProfitMicros          => $args->{allGrossProfitMicros},
    allLeadCostOfGoodsSoldMicros  => $args->{allLeadCostOfGoodsSoldMicros},
    allLeadGrossProfitMicros      => $args->{allLeadGrossProfitMicros},
    allLeadRevenueMicros          => $args->{allLeadRevenueMicros},
    allLeadUnitsSold              => $args->{allLeadUnitsSold},
    allNewCustomerLifetimeValue   => $args->{allNewCustomerLifetimeValue},
    allOrders                     => $args->{allOrders},
    allRevenueMicros              => $args->{allRevenueMicros},
    allUnitsSold                  => $args->{allUnitsSold},
    allValueAdjustment            => $args->{allValueAdjustment},
    assetPinnedAsDescriptionPositionOneCount =>
      $args->{assetPinnedAsDescriptionPositionOneCount},
    assetPinnedAsDescriptionPositionTwoCount =>
      $args->{assetPinnedAsDescriptionPositionTwoCount},
    assetPinnedAsHeadlinePositionOneCount =>
      $args->{assetPinnedAsHeadlinePositionOneCount},
    assetPinnedAsHeadlinePositionThreeCount =>
      $args->{assetPinnedAsHeadlinePositionThreeCount},
    assetPinnedAsHeadlinePositionTwoCount =>
      $args->{assetPinnedAsHeadlinePositionTwoCount},
    assetPinnedTotalCount => $args->{assetPinnedTotalCount},
    auctionInsightSearchAbsoluteTopImpressionPercentage =>
      $args->{auctionInsightSearchAbsoluteTopImpressionPercentage},
    auctionInsightSearchImpressionShare =>
      $args->{auctionInsightSearchImpressionShare},
    auctionInsightSearchOutrankingShare =>
      $args->{auctionInsightSearchOutrankingShare},
    auctionInsightSearchOverlapRate => $args->{auctionInsightSearchOverlapRate},
    auctionInsightSearchPositionAboveRate =>
      $args->{auctionInsightSearchPositionAboveRate},
    auctionInsightSearchTopImpressionPercentage =>
      $args->{auctionInsightSearchTopImpressionPercentage},
    averageCartSize                   => $args->{averageCartSize},
    averageCost                       => $args->{averageCost},
    averageCpc                        => $args->{averageCpc},
    averageCpe                        => $args->{averageCpe},
    averageCpm                        => $args->{averageCpm},
    averageImpressionFrequencyPerUser =>
      $args->{averageImpressionFrequencyPerUser},
    averageOrderValueMicros             => $args->{averageOrderValueMicros},
    averagePageViews                    => $args->{averagePageViews},
    averageTargetCpaMicros              => $args->{averageTargetCpaMicros},
    averageTargetRoas                   => $args->{averageTargetRoas},
    averageTimeOnSite                   => $args->{averageTimeOnSite},
    averageVideoWatchTimeDurationMillis =>
      $args->{averageVideoWatchTimeDurationMillis},
    benchmarkAverageMaxCpc            => $args->{benchmarkAverageMaxCpc},
    benchmarkCtr                      => $args->{benchmarkCtr},
    biddableAppInstallConversions     => $args->{biddableAppInstallConversions},
    biddableAppPostInstallConversions =>
      $args->{biddableAppPostInstallConversions},
    biddableCohortAppPostInstallConversions =>
      $args->{biddableCohortAppPostInstallConversions},
    biddableIndirectInstallFirstInAppConversionMicros =>
      $args->{biddableIndirectInstallFirstInAppConversionMicros},
    bounceRate                            => $args->{bounceRate},
    brandLiftBaselinePositiveResponseRate =>
      $args->{brandLiftBaselinePositiveResponseRate},
    brandLiftBaselinePositiveResponseRateP90LowerBound =>
      $args->{brandLiftBaselinePositiveResponseRateP90LowerBound},
    brandLiftBaselinePositiveResponseRateP90UpperBound =>
      $args->{brandLiftBaselinePositiveResponseRateP90UpperBound},
    brandLiftExposedPositiveResponderFractionalCookies =>
      $args->{brandLiftExposedPositiveResponderFractionalCookies},
    brandLiftExposedPositiveResponderFractionalCookiesP90LowerBound =>
      $args->{brandLiftExposedPositiveResponderFractionalCookiesP90LowerBound},
    brandLiftExposedPositiveResponderFractionalCookiesP90UpperBound =>
      $args->{brandLiftExposedPositiveResponderFractionalCookiesP90UpperBound},
    brandLiftExposedPositiveResponseRate =>
      $args->{brandLiftExposedPositiveResponseRate},
    brandLiftExposedPositiveResponseRateP90LowerBound =>
      $args->{brandLiftExposedPositiveResponseRateP90LowerBound},
    brandLiftExposedPositiveResponseRateP90UpperBound =>
      $args->{brandLiftExposedPositiveResponseRateP90UpperBound},
    brandLiftResponsesExposed    => $args->{brandLiftResponsesExposed},
    brandLiftResponsesSuppressed => $args->{brandLiftResponsesSuppressed},
    brandLiftSuppressedPositiveResponderFractionalCookies =>
      $args->{brandLiftSuppressedPositiveResponderFractionalCookies},
    brandLiftSuppressedPositiveResponderFractionalCookiesP90LowerBound =>
      $args->
      {brandLiftSuppressedPositiveResponderFractionalCookiesP90LowerBound},
    brandLiftSuppressedPositiveResponderFractionalCookiesP90UpperBound =>
      $args->
      {brandLiftSuppressedPositiveResponderFractionalCookiesP90UpperBound},
    brandLiftTotalResponses          => $args->{brandLiftTotalResponses},
    clicks                           => $args->{clicks},
    clicksMarginOfError              => $args->{clicksMarginOfError},
    clicksPValue                     => $args->{clicksPValue},
    clicksPointEstimate              => $args->{clicksPointEstimate},
    clicksUniqueQueryClusters        => $args->{clicksUniqueQueryClusters},
    combinedClicks                   => $args->{combinedClicks},
    combinedClicksPerQuery           => $args->{combinedClicksPerQuery},
    combinedQueries                  => $args->{combinedQueries},
    contentBudgetLostImpressionShare =>
      $args->{contentBudgetLostImpressionShare},
    contentImpressionShare         => $args->{contentImpressionShare},
    contentRankLostImpressionShare => $args->{contentRankLostImpressionShare},
    controlClicks                  => $args->{controlClicks},
    controlConversionValue         => $args->{controlConversionValue},
    controlConversionValuePerCost  => $args->{controlConversionValuePerCost},
    controlConversions             => $args->{controlConversions},
    controlCostMicros              => $args->{controlCostMicros},
    controlCostPerConversion       => $args->{controlCostPerConversion},
    controlImpressions             => $args->{controlImpressions},
    conversionLastConversionDate   => $args->{conversionLastConversionDate},
    conversionLastReceivedRequestDateTime =>
      $args->{conversionLastReceivedRequestDateTime},
    conversionLiftBaselineConversionValue =>
      $args->{conversionLiftBaselineConversionValue},
    conversionLiftBaselineConversions =>
      $args->{conversionLiftBaselineConversions},
    conversionLiftExposedConversionValue =>
      $args->{conversionLiftExposedConversionValue},
    conversionLiftExposedConversions =>
      $args->{conversionLiftExposedConversions},
    conversionValueChangePointEstimate =>
      $args->{conversionValueChangePointEstimate},
    conversionValueMarginOfError => $args->{conversionValueMarginOfError},
    conversionValuePValue        => $args->{conversionValuePValue},
    conversionValuePerCostChangePointEstimate =>
      $args->{conversionValuePerCostChangePointEstimate},
    conversionValuePerCostMarginOfError =>
      $args->{conversionValuePerCostMarginOfError},
    conversionValuePerCostPValue => $args->{conversionValuePerCostPValue},
    conversions                  => $args->{conversions},
    conversionsAbsoluteChangeMarginOfError =>
      $args->{conversionsAbsoluteChangeMarginOfError},
    conversionsAbsoluteChangePValue => $args->{conversionsAbsoluteChangePValue},
    conversionsAbsoluteChangePointEstimate =>
      $args->{conversionsAbsoluteChangePointEstimate},
    conversionsByConversionDate     => $args->{conversionsByConversionDate},
    conversionsFromInteractionsRate => $args->{conversionsFromInteractionsRate},
    conversionsFromInteractionsValuePerInteraction =>
      $args->{conversionsFromInteractionsValuePerInteraction},
    conversionsUniqueQueryClusters   => $args->{conversionsUniqueQueryClusters},
    conversionsValue                 => $args->{conversionsValue},
    conversionsValueByConversionDate =>
      $args->{conversionsValueByConversionDate},
    conversionsValuePerCost => $args->{conversionsValuePerCost},
    costConvertedCurrencyPerPlatformComparableConversion =>
      $args->{costConvertedCurrencyPerPlatformComparableConversion},
    costMicros                    => $args->{costMicros},
    costMicrosChangePointEstimate => $args->{costMicrosChangePointEstimate},
    costMicrosMarginOfError       => $args->{costMicrosMarginOfError},
    costMicrosPValue              => $args->{costMicrosPValue},
    costOfGoodsSoldMicros         => $args->{costOfGoodsSoldMicros},
    costPerAllConversions         => $args->{costPerAllConversions},
    costPerConversion             => $args->{costPerConversion},
    costPerConversionChangePointEstimate =>
      $args->{costPerConversionChangePointEstimate},
    costPerConversionMarginOfError => $args->{costPerConversionMarginOfError},
    costPerConversionPValue        => $args->{costPerConversionPValue},
    costPerCurrentModelAttributedConversion =>
      $args->{costPerCurrentModelAttributedConversion},
    costPerIncrementalConversion => $args->{costPerIncrementalConversion},
    costPerIncrementalConversionP90LowerBound =>
      $args->{costPerIncrementalConversionP90LowerBound},
    costPerIncrementalConversionP90UpperBound =>
      $args->{costPerIncrementalConversionP90UpperBound},
    costPerIncrementalConversionWinnerScore =>
      $args->{costPerIncrementalConversionWinnerScore},
    costPerLiftedCookie              => $args->{costPerLiftedCookie},
    costPerLiftedCookieP90LowerBound =>
      $args->{costPerLiftedCookieP90LowerBound},
    costPerLiftedCookieP90UpperBound =>
      $args->{costPerLiftedCookieP90UpperBound},
    costPerPlatformComparableConversion =>
      $args->{costPerPlatformComparableConversion},
    coviewedImpressions                    => $args->{coviewedImpressions},
    crossDeviceConversions                 => $args->{crossDeviceConversions},
    crossDeviceConversionsByConversionDate =>
      $args->{crossDeviceConversionsByConversionDate},
    crossDeviceConversionsValue => $args->{crossDeviceConversionsValue},
    crossDeviceConversionsValueByConversionDate =>
      $args->{crossDeviceConversionsValueByConversionDate},
    crossDeviceConversionsValueMicros =>
      $args->{crossDeviceConversionsValueMicros},
    crossSellCostOfGoodsSoldMicros => $args->{crossSellCostOfGoodsSoldMicros},
    crossSellGrossProfitMicros     => $args->{crossSellGrossProfitMicros},
    crossSellRevenueMicros         => $args->{crossSellRevenueMicros},
    crossSellUnitsSold             => $args->{crossSellUnitsSold},
    ctr                            => $args->{ctr},
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
    eligibleImpressionsFromLocationAssetStoreReach =>
      $args->{eligibleImpressionsFromLocationAssetStoreReach},
    engagementRate                       => $args->{engagementRate},
    engagements                          => $args->{engagements},
    fractionalLiftedCookies              => $args->{fractionalLiftedCookies},
    fractionalLiftedCookiesP90LowerBound =>
      $args->{fractionalLiftedCookiesP90LowerBound},
    fractionalLiftedCookiesP90UpperBound =>
      $args->{fractionalLiftedCookiesP90UpperBound},
    generalInvalidClickRate        => $args->{generalInvalidClickRate},
    generalInvalidClicks           => $args->{generalInvalidClicks},
    gmailForwards                  => $args->{gmailForwards},
    gmailSaves                     => $args->{gmailSaves},
    gmailSecondaryClicks           => $args->{gmailSecondaryClicks},
    grossProfitMargin              => $args->{grossProfitMargin},
    grossProfitMicros              => $args->{grossProfitMicros},
    headroomBrandLift              => $args->{headroomBrandLift},
    headroomBrandLiftP90LowerBound => $args->{headroomBrandLiftP90LowerBound},
    headroomBrandLiftP90UpperBound => $args->{headroomBrandLiftP90UpperBound},
    historicalCreativeQualityScore => $args->{historicalCreativeQualityScore},
    historicalLandingPageQualityScore =>
      $args->{historicalLandingPageQualityScore},
    historicalQualityScore         => $args->{historicalQualityScore},
    historicalSearchPredictedCtr   => $args->{historicalSearchPredictedCtr},
    hotelAverageLeadValueMicros    => $args->{hotelAverageLeadValueMicros},
    hotelCommissionRateMicros      => $args->{hotelCommissionRateMicros},
    hotelEligibleImpressions       => $args->{hotelEligibleImpressions},
    hotelExpectedCommissionCost    => $args->{hotelExpectedCommissionCost},
    hotelPriceDifferencePercentage => $args->{hotelPriceDifferencePercentage},
    impressions                    => $args->{impressions},
    impressionsFromStoreReach      => $args->{impressionsFromStoreReach},
    impressionsMarginOfError       => $args->{impressionsMarginOfError},
    impressionsPValue              => $args->{impressionsPValue},
    impressionsPointEstimate       => $args->{impressionsPointEstimate},
    impressionsUniqueQueryClusters => $args->{impressionsUniqueQueryClusters},
    incrementalConversionValue     => $args->{incrementalConversionValue},
    incrementalConversionValueP90LowerBound =>
      $args->{incrementalConversionValueP90LowerBound},
    incrementalConversionValueP90UpperBound =>
      $args->{incrementalConversionValueP90UpperBound},
    incrementalConversionValuePValue =>
      $args->{incrementalConversionValuePValue},
    incrementalConversionValuePerCost =>
      $args->{incrementalConversionValuePerCost},
    incrementalConversionValuePerCostP90LowerBound =>
      $args->{incrementalConversionValuePerCostP90LowerBound},
    incrementalConversionValuePerCostP90UpperBound =>
      $args->{incrementalConversionValuePerCostP90UpperBound},
    incrementalConversionValuePerCostWinnerScore =>
      $args->{incrementalConversionValuePerCostWinnerScore},
    incrementalConversionValueWinnerScore =>
      $args->{incrementalConversionValueWinnerScore},
    incrementalConversions              => $args->{incrementalConversions},
    incrementalConversionsP90LowerBound =>
      $args->{incrementalConversionsP90LowerBound},
    incrementalConversionsP90UpperBound =>
      $args->{incrementalConversionsP90UpperBound},
    incrementalConversionsPValue      => $args->{incrementalConversionsPValue},
    incrementalConversionsWinnerScore =>
      $args->{incrementalConversionsWinnerScore},
    interactionEventTypes          => $args->{interactionEventTypes},
    interactionRate                => $args->{interactionRate},
    interactions                   => $args->{interactions},
    invalidClickRate               => $args->{invalidClickRate},
    invalidClicks                  => $args->{invalidClicks},
    leadCostOfGoodsSoldMicros      => $args->{leadCostOfGoodsSoldMicros},
    leadGrossProfitMicros          => $args->{leadGrossProfitMicros},
    leadRevenueMicros              => $args->{leadRevenueMicros},
    leadUnitsSold                  => $args->{leadUnitsSold},
    linkedEntitiesCount            => $args->{linkedEntitiesCount},
    linkedSampleEntities           => $args->{linkedSampleEntities},
    messageChatRate                => $args->{messageChatRate},
    messageChats                   => $args->{messageChats},
    messageImpressions             => $args->{messageImpressions},
    mobileFriendlyClicksPercentage => $args->{mobileFriendlyClicksPercentage},
    newCustomerLifetimeValue       => $args->{newCustomerLifetimeValue},
    optimizationScoreUplift        => $args->{optimizationScoreUplift},
    optimizationScoreUrl           => $args->{optimizationScoreUrl},
    orders                         => $args->{orders},
    organicClicks                  => $args->{organicClicks},
    organicClicksPerQuery          => $args->{organicClicksPerQuery},
    organicImpressions             => $args->{organicImpressions},
    organicImpressionsPerQuery     => $args->{organicImpressionsPerQuery},
    organicQueries                 => $args->{organicQueries},
    originalConversionValue        => $args->{originalConversionValue},
    percentNewVisitors             => $args->{percentNewVisitors},
    phoneCalls                     => $args->{phoneCalls},
    phoneImpressions               => $args->{phoneImpressions},
    phoneThroughRate               => $args->{phoneThroughRate},
    platformComparableConversions  => $args->{platformComparableConversions},
    platformComparableConversionsByConversionDate =>
      $args->{platformComparableConversionsByConversionDate},
    platformComparableConversionsFromInteractionsRate =>
      $args->{platformComparableConversionsFromInteractionsRate},
    platformComparableConversionsFromInteractionsValuePerInteraction =>
      $args->{platformComparableConversionsFromInteractionsValuePerInteraction},
    platformComparableConversionsValue =>
      $args->{platformComparableConversionsValue},
    platformComparableConversionsValueByConversionDate =>
      $args->{platformComparableConversionsValueByConversionDate},
    platformComparableConversionsValuePerCost =>
      $args->{platformComparableConversionsValuePerCost},
    primaryImpressions             => $args->{primaryImpressions},
    publisherOrganicClicks         => $args->{publisherOrganicClicks},
    publisherPurchasedClicks       => $args->{publisherPurchasedClicks},
    publisherUnknownClicks         => $args->{publisherUnknownClicks},
    relativeBrandLift              => $args->{relativeBrandLift},
    relativeBrandLiftP90LowerBound => $args->{relativeBrandLiftP90LowerBound},
    relativeBrandLiftP90UpperBound => $args->{relativeBrandLiftP90UpperBound},
    relativeConversionLift         => $args->{relativeConversionLift},
    relativeConversionLiftP90LowerBound =>
      $args->{relativeConversionLiftP90LowerBound},
    relativeConversionLiftP90UpperBound =>
      $args->{relativeConversionLiftP90UpperBound},
    relativeConversionValueLift => $args->{relativeConversionValueLift},
    relativeConversionValueLiftP90LowerBound =>
      $args->{relativeConversionValueLiftP90LowerBound},
    relativeConversionValueLiftP90UpperBound =>
      $args->{relativeConversionValueLiftP90UpperBound},
    relativeCtr                      => $args->{relativeCtr},
    resultsConversionsPurchase       => $args->{resultsConversionsPurchase},
    revenueMicros                    => $args->{revenueMicros},
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
    searchTopImpressionShare    => $args->{searchTopImpressionShare},
    searchVolume                => $args->{searchVolume},
    skAdNetworkInstalls         => $args->{skAdNetworkInstalls},
    skAdNetworkTotalConversions => $args->{skAdNetworkTotalConversions},
    speedScore                  => $args->{speedScore},
    storeVisitsLastClickModelAttributedConversions =>
      $args->{storeVisitsLastClickModelAttributedConversions},
    svr                     => $args->{svr},
    topImpressionPercentage => $args->{topImpressionPercentage},
    trueviewAverageCpv      => $args->{trueviewAverageCpv},
    uniqueUsers             => $args->{uniqueUsers},
    uniqueUsersFivePlus     => $args->{uniqueUsersFivePlus},
    uniqueUsersFourPlus     => $args->{uniqueUsersFourPlus},
    uniqueUsersTenPlus      => $args->{uniqueUsersTenPlus},
    uniqueUsersThreePlus    => $args->{uniqueUsersThreePlus},
    uniqueUsersTwoPlus      => $args->{uniqueUsersTwoPlus},
    unitsSold               => $args->{unitsSold},
    validAcceleratedMobilePagesClicksPercentage =>
      $args->{validAcceleratedMobilePagesClicksPercentage},
    valueAdjustment                        => $args->{valueAdjustment},
    valuePerAllConversions                 => $args->{valuePerAllConversions},
    valuePerAllConversionsByConversionDate =>
      $args->{valuePerAllConversionsByConversionDate},
    valuePerConversion                  => $args->{valuePerConversion},
    valuePerConversionsByConversionDate =>
      $args->{valuePerConversionsByConversionDate},
    valuePerCurrentModelAttributedConversion =>
      $args->{valuePerCurrentModelAttributedConversion},
    valuePerPlatformComparableConversion =>
      $args->{valuePerPlatformComparableConversion},
    valuePerPlatformComparableConversionsByConversionDate =>
      $args->{valuePerPlatformComparableConversionsByConversionDate},
    videoQuartileP100Rate         => $args->{videoQuartileP100Rate},
    videoQuartileP25Rate          => $args->{videoQuartileP25Rate},
    videoQuartileP50Rate          => $args->{videoQuartileP50Rate},
    videoQuartileP75Rate          => $args->{videoQuartileP75Rate},
    videoTrueviewViewRate         => $args->{videoTrueviewViewRate},
    videoTrueviewViewRateInFeed   => $args->{videoTrueviewViewRateInFeed},
    videoTrueviewViewRateInStream => $args->{videoTrueviewViewRateInStream},
    videoTrueviewViewRateShorts   => $args->{videoTrueviewViewRateShorts},
    videoTrueviewViews            => $args->{videoTrueviewViews},
    videoWatchTimeDurationMillis  => $args->{videoWatchTimeDurationMillis},
    viewThroughConversions        => $args->{viewThroughConversions},
    viewThroughConversionsFromLocationAssetClickToCall =>
      $args->{viewThroughConversionsFromLocationAssetClickToCall},
    viewThroughConversionsFromLocationAssetDirections =>
      $args->{viewThroughConversionsFromLocationAssetDirections},
    viewThroughConversionsFromLocationAssetMenu =>
      $args->{viewThroughConversionsFromLocationAssetMenu},
    viewThroughConversionsFromLocationAssetOrder =>
      $args->{viewThroughConversionsFromLocationAssetOrder},
    viewThroughConversionsFromLocationAssetOtherEngagement =>
      $args->{viewThroughConversionsFromLocationAssetOtherEngagement},
    viewThroughConversionsFromLocationAssetStoreVisits =>
      $args->{viewThroughConversionsFromLocationAssetStoreVisits},
    viewThroughConversionsFromLocationAssetWebsite =>
      $args->{viewThroughConversionsFromLocationAssetWebsite},
    youtubeComments => $args->{youtubeComments},
    youtubeLikes    => $args->{youtubeLikes},
    youtubeShares   => $args->{youtubeShares}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
