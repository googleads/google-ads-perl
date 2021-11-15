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

package Google::Ads::GoogleAds::V9::Resources::Asset;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    bookOnGoogleAsset      => $args->{bookOnGoogleAsset},
    callAsset              => $args->{callAsset},
    callToActionAsset      => $args->{callToActionAsset},
    calloutAsset           => $args->{calloutAsset},
    dynamicEducationAsset  => $args->{dynamicEducationAsset},
    finalMobileUrls        => $args->{finalMobileUrls},
    finalUrlSuffix         => $args->{finalUrlSuffix},
    finalUrls              => $args->{finalUrls},
    hotelCalloutAsset      => $args->{hotelCalloutAsset},
    id                     => $args->{id},
    imageAsset             => $args->{imageAsset},
    leadFormAsset          => $args->{leadFormAsset},
    mediaBundleAsset       => $args->{mediaBundleAsset},
    mobileAppAsset         => $args->{mobileAppAsset},
    name                   => $args->{name},
    pageFeedAsset          => $args->{pageFeedAsset},
    policySummary          => $args->{policySummary},
    priceAsset             => $args->{priceAsset},
    promotionAsset         => $args->{promotionAsset},
    resourceName           => $args->{resourceName},
    sitelinkAsset          => $args->{sitelinkAsset},
    structuredSnippetAsset => $args->{structuredSnippetAsset},
    textAsset              => $args->{textAsset},
    trackingUrlTemplate    => $args->{trackingUrlTemplate},
    type                   => $args->{type},
    urlCustomParameters    => $args->{urlCustomParameters},
    youtubeVideoAsset      => $args->{youtubeVideoAsset}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;