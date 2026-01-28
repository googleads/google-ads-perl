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

package Google::Ads::GoogleAds::V23::Common::Segments;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    activityAccountId               => $args->{activityAccountId},
    activityCity                    => $args->{activityCity},
    activityCountry                 => $args->{activityCountry},
    activityRating                  => $args->{activityRating},
    activityState                   => $args->{activityState},
    adDestinationType               => $args->{adDestinationType},
    adFormatType                    => $args->{adFormatType},
    adGroup                         => $args->{adGroup},
    adNetworkType                   => $args->{adNetworkType},
    adSubNetworkType                => $args->{adSubNetworkType},
    adUsingProductData              => $args->{adUsingProductData},
    adUsingVideo                    => $args->{adUsingVideo},
    adjustedAgeRange                => $args->{adjustedAgeRange},
    adjustedGender                  => $args->{adjustedGender},
    assetGroup                      => $args->{assetGroup},
    assetInteractionTarget          => $args->{assetInteractionTarget},
    auctionInsightDomain            => $args->{auctionInsightDomain},
    budgetCampaignAssociationStatus => $args->{budgetCampaignAssociationStatus},
    campaign                        => $args->{campaign},
    clickType                       => $args->{clickType},
    conversionAction                => $args->{conversionAction},
    conversionActionCategory        => $args->{conversionActionCategory},
    conversionActionName            => $args->{conversionActionName},
    conversionAdjustment            => $args->{conversionAdjustment},
    conversionAttributionEventType  => $args->{conversionAttributionEventType},
    conversionLagBucket             => $args->{conversionLagBucket},
    conversionOrAdjustmentLagBucket => $args->{conversionOrAdjustmentLagBucket},
    conversionValueRulePrimaryDimension =>
      $args->{conversionValueRulePrimaryDimension},
    date                             => $args->{date},
    dayOfWeek                        => $args->{dayOfWeek},
    device                           => $args->{device},
    externalActivityId               => $args->{externalActivityId},
    externalConversionSource         => $args->{externalConversionSource},
    geoTargetAirport                 => $args->{geoTargetAirport},
    geoTargetCanton                  => $args->{geoTargetCanton},
    geoTargetCity                    => $args->{geoTargetCity},
    geoTargetCountry                 => $args->{geoTargetCountry},
    geoTargetCounty                  => $args->{geoTargetCounty},
    geoTargetDistrict                => $args->{geoTargetDistrict},
    geoTargetMetro                   => $args->{geoTargetMetro},
    geoTargetMostSpecificLocation    => $args->{geoTargetMostSpecificLocation},
    geoTargetPostalCode              => $args->{geoTargetPostalCode},
    geoTargetProvince                => $args->{geoTargetProvince},
    geoTargetRegion                  => $args->{geoTargetRegion},
    geoTargetState                   => $args->{geoTargetState},
    hotelBookingWindowDays           => $args->{hotelBookingWindowDays},
    hotelCenterId                    => $args->{hotelCenterId},
    hotelCheckInDate                 => $args->{hotelCheckInDate},
    hotelCheckInDayOfWeek            => $args->{hotelCheckInDayOfWeek},
    hotelCity                        => $args->{hotelCity},
    hotelClass                       => $args->{hotelClass},
    hotelCountry                     => $args->{hotelCountry},
    hotelDateSelectionType           => $args->{hotelDateSelectionType},
    hotelLengthOfStay                => $args->{hotelLengthOfStay},
    hotelPriceBucket                 => $args->{hotelPriceBucket},
    hotelRateRuleId                  => $args->{hotelRateRuleId},
    hotelRateType                    => $args->{hotelRateType},
    hotelState                       => $args->{hotelState},
    hour                             => $args->{hour},
    interactionOnThisExtension       => $args->{interactionOnThisExtension},
    keyword                          => $args->{keyword},
    landingPageSource                => $args->{landingPageSource},
    matchType                        => $args->{matchType},
    month                            => $args->{month},
    monthOfYear                      => $args->{monthOfYear},
    newVersusReturningCustomers      => $args->{newVersusReturningCustomers},
    partnerHotelId                   => $args->{partnerHotelId},
    productAggregatorId              => $args->{productAggregatorId},
    productBrand                     => $args->{productBrand},
    productCategoryLevel1            => $args->{productCategoryLevel1},
    productCategoryLevel2            => $args->{productCategoryLevel2},
    productCategoryLevel3            => $args->{productCategoryLevel3},
    productCategoryLevel4            => $args->{productCategoryLevel4},
    productCategoryLevel5            => $args->{productCategoryLevel5},
    productChannel                   => $args->{productChannel},
    productChannelExclusivity        => $args->{productChannelExclusivity},
    productCondition                 => $args->{productCondition},
    productCountry                   => $args->{productCountry},
    productCustomAttribute0          => $args->{productCustomAttribute0},
    productCustomAttribute1          => $args->{productCustomAttribute1},
    productCustomAttribute2          => $args->{productCustomAttribute2},
    productCustomAttribute3          => $args->{productCustomAttribute3},
    productCustomAttribute4          => $args->{productCustomAttribute4},
    productFeedLabel                 => $args->{productFeedLabel},
    productItemId                    => $args->{productItemId},
    productLanguage                  => $args->{productLanguage},
    productMerchantId                => $args->{productMerchantId},
    productStoreId                   => $args->{productStoreId},
    productTitle                     => $args->{productTitle},
    productTypeL1                    => $args->{productTypeL1},
    productTypeL2                    => $args->{productTypeL2},
    productTypeL3                    => $args->{productTypeL3},
    productTypeL4                    => $args->{productTypeL4},
    productTypeL5                    => $args->{productTypeL5},
    quarter                          => $args->{quarter},
    recommendationType               => $args->{recommendationType},
    searchEngineResultsPageType      => $args->{searchEngineResultsPageType},
    searchSubcategory                => $args->{searchSubcategory},
    searchTerm                       => $args->{searchTerm},
    searchTermMatchSource            => $args->{searchTermMatchSource},
    searchTermMatchType              => $args->{searchTermMatchType},
    searchTermTargetingStatus        => $args->{searchTermTargetingStatus},
    skAdNetworkAdEventType           => $args->{skAdNetworkAdEventType},
    skAdNetworkAttributionCredit     => $args->{skAdNetworkAttributionCredit},
    skAdNetworkCoarseConversionValue =>
      $args->{skAdNetworkCoarseConversionValue},
    skAdNetworkFineConversionValue   => $args->{skAdNetworkFineConversionValue},
    skAdNetworkPostbackSequenceIndex =>
      $args->{skAdNetworkPostbackSequenceIndex},
    skAdNetworkRedistributedFineConversionValue =>
      $args->{skAdNetworkRedistributedFineConversionValue},
    skAdNetworkSourceApp     => $args->{skAdNetworkSourceApp},
    skAdNetworkSourceDomain  => $args->{skAdNetworkSourceDomain},
    skAdNetworkSourceType    => $args->{skAdNetworkSourceType},
    skAdNetworkUserType      => $args->{skAdNetworkUserType},
    skAdNetworkVersion       => $args->{skAdNetworkVersion},
    slot                     => $args->{slot},
    travelDestinationCity    => $args->{travelDestinationCity},
    travelDestinationCountry => $args->{travelDestinationCountry},
    travelDestinationRegion  => $args->{travelDestinationRegion},
    verticalAdsEventParticipantDisplayNames =>
      $args->{verticalAdsEventParticipantDisplayNames},
    verticalAdsHotelClass     => $args->{verticalAdsHotelClass},
    verticalAdsListing        => $args->{verticalAdsListing},
    verticalAdsListingBrand   => $args->{verticalAdsListingBrand},
    verticalAdsListingCity    => $args->{verticalAdsListingCity},
    verticalAdsListingCountry => $args->{verticalAdsListingCountry},
    verticalAdsListingRegion  => $args->{verticalAdsListingRegion},
    verticalAdsPartnerAccount => $args->{verticalAdsPartnerAccount},
    verticalAdsVertical       => $args->{verticalAdsVertical},
    webpage                   => $args->{webpage},
    week                      => $args->{week},
    year                      => $args->{year}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
