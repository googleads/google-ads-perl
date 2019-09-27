# Copyright 2019, Google LLC
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

package Google::Ads::GoogleAds::V2::Common::Segments;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    adNetworkType                   => $args->{adNetworkType},
    clickType                       => $args->{clickType},
    conversionAction                => $args->{conversionAction},
    conversionActionCategory        => $args->{conversionActionCategory},
    conversionActionName            => $args->{conversionActionName},
    conversionAdjustment            => $args->{conversionAdjustment},
    conversionAttributionEventType  => $args->{conversionAttributionEventType},
    conversionLagBucket             => $args->{conversionLagBucket},
    conversionOrAdjustmentLagBucket => $args->{conversionOrAdjustmentLagBucket},
    date                            => $args->{date},
    dayOfWeek                       => $args->{dayOfWeek},
    device                          => $args->{device},
    externalConversionSource        => $args->{externalConversionSource},
    geoTargetAirport                => $args->{geoTargetAirport},
    geoTargetCanton                 => $args->{geoTargetCanton},
    geoTargetCity                   => $args->{geoTargetCity},
    geoTargetCountry                => $args->{geoTargetCountry},
    geoTargetCounty                 => $args->{geoTargetCounty},
    geoTargetDistrict               => $args->{geoTargetDistrict},
    geoTargetMetro                  => $args->{geoTargetMetro},
    geoTargetMostSpecificLocation   => $args->{geoTargetMostSpecificLocation},
    geoTargetPostalCode             => $args->{geoTargetPostalCode},
    geoTargetProvince               => $args->{geoTargetProvince},
    geoTargetRegion                 => $args->{geoTargetRegion},
    geoTargetState                  => $args->{geoTargetState},
    hotelBookingWindowDays          => $args->{hotelBookingWindowDays},
    hotelCenterId                   => $args->{hotelCenterId},
    hotelCheckInDate                => $args->{hotelCheckInDate},
    hotelCheckInDayOfWeek           => $args->{hotelCheckInDayOfWeek},
    hotelCity                       => $args->{hotelCity},
    hotelClass                      => $args->{hotelClass},
    hotelCountry                    => $args->{hotelCountry},
    hotelDateSelectionType          => $args->{hotelDateSelectionType},
    hotelLengthOfStay               => $args->{hotelLengthOfStay},
    hotelPriceBucket                => $args->{hotelPriceBucket},
    hotelRateRuleId                 => $args->{hotelRateRuleId},
    hotelRateType                   => $args->{hotelRateType},
    hotelState                      => $args->{hotelState},
    hour                            => $args->{hour},
    interactionOnThisExtension      => $args->{interactionOnThisExtension},
    keyword                         => $args->{keyword},
    month                           => $args->{month},
    monthOfYear                     => $args->{monthOfYear},
    partnerHotelId                  => $args->{partnerHotelId},
    placeholderType                 => $args->{placeholderType},
    productAggregatorId             => $args->{productAggregatorId},
    productBiddingCategoryLevel1    => $args->{productBiddingCategoryLevel1},
    productBiddingCategoryLevel2    => $args->{productBiddingCategoryLevel2},
    productBiddingCategoryLevel3    => $args->{productBiddingCategoryLevel3},
    productBiddingCategoryLevel4    => $args->{productBiddingCategoryLevel4},
    productBiddingCategoryLevel5    => $args->{productBiddingCategoryLevel5},
    productBrand                    => $args->{productBrand},
    productChannel                  => $args->{productChannel},
    productChannelExclusivity       => $args->{productChannelExclusivity},
    productCondition                => $args->{productCondition},
    productCountry                  => $args->{productCountry},
    productCustomAttribute0         => $args->{productCustomAttribute0},
    productCustomAttribute1         => $args->{productCustomAttribute1},
    productCustomAttribute2         => $args->{productCustomAttribute2},
    productCustomAttribute3         => $args->{productCustomAttribute3},
    productCustomAttribute4         => $args->{productCustomAttribute4},
    productItemId                   => $args->{productItemId},
    productLanguage                 => $args->{productLanguage},
    productMerchantId               => $args->{productMerchantId},
    productStoreId                  => $args->{productStoreId},
    productTitle                    => $args->{productTitle},
    productTypeL1                   => $args->{productTypeL1},
    productTypeL2                   => $args->{productTypeL2},
    productTypeL3                   => $args->{productTypeL3},
    productTypeL4                   => $args->{productTypeL4},
    productTypeL5                   => $args->{productTypeL5},
    quarter                         => $args->{quarter},
    searchEngineResultsPageType     => $args->{searchEngineResultsPageType},
    searchTermMatchType             => $args->{searchTermMatchType},
    slot                            => $args->{slot},
    webpage                         => $args->{webpage},
    week                            => $args->{week},
    year                            => $args->{year}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
