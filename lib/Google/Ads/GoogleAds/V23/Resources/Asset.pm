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

package Google::Ads::GoogleAds::V23::Resources::Asset;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    appDeepLinkAsset             => $args->{appDeepLinkAsset},
    bookOnGoogleAsset            => $args->{bookOnGoogleAsset},
    businessMessageAsset         => $args->{businessMessageAsset},
    callAsset                    => $args->{callAsset},
    callToActionAsset            => $args->{callToActionAsset},
    calloutAsset                 => $args->{calloutAsset},
    demandGenCarouselCardAsset   => $args->{demandGenCarouselCardAsset},
    dynamicCustomAsset           => $args->{dynamicCustomAsset},
    dynamicEducationAsset        => $args->{dynamicEducationAsset},
    dynamicFlightsAsset          => $args->{dynamicFlightsAsset},
    dynamicHotelsAndRentalsAsset => $args->{dynamicHotelsAndRentalsAsset},
    dynamicJobsAsset             => $args->{dynamicJobsAsset},
    dynamicLocalAsset            => $args->{dynamicLocalAsset},
    dynamicRealEstateAsset       => $args->{dynamicRealEstateAsset},
    dynamicTravelAsset           => $args->{dynamicTravelAsset},
    fieldTypePolicySummaries     => $args->{fieldTypePolicySummaries},
    finalMobileUrls              => $args->{finalMobileUrls},
    finalUrlSuffix               => $args->{finalUrlSuffix},
    finalUrls                    => $args->{finalUrls},
    hotelCalloutAsset            => $args->{hotelCalloutAsset},
    hotelPropertyAsset           => $args->{hotelPropertyAsset},
    id                           => $args->{id},
    imageAsset                   => $args->{imageAsset},
    leadFormAsset                => $args->{leadFormAsset},
    locationAsset                => $args->{locationAsset},
    mediaBundleAsset             => $args->{mediaBundleAsset},
    mobileAppAsset               => $args->{mobileAppAsset},
    name                         => $args->{name},
    orientation                  => $args->{orientation},
    pageFeedAsset                => $args->{pageFeedAsset},
    policySummary                => $args->{policySummary},
    priceAsset                   => $args->{priceAsset},
    promotionAsset               => $args->{promotionAsset},
    resourceName                 => $args->{resourceName},
    sitelinkAsset                => $args->{sitelinkAsset},
    source                       => $args->{source},
    structuredSnippetAsset       => $args->{structuredSnippetAsset},
    textAsset                    => $args->{textAsset},
    trackingUrlTemplate          => $args->{trackingUrlTemplate},
    type                         => $args->{type},
    urlCustomParameters          => $args->{urlCustomParameters},
    youtubeVideoAsset            => $args->{youtubeVideoAsset},
    youtubeVideoListAsset        => $args->{youtubeVideoListAsset}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
