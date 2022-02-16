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

package Google::Ads::GoogleAds::V10::Resources::Ad;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    addedByGoogleAds            => $args->{addedByGoogleAds},
    appAd                       => $args->{appAd},
    appEngagementAd             => $args->{appEngagementAd},
    appPreRegistrationAd        => $args->{appPreRegistrationAd},
    callAd                      => $args->{callAd},
    devicePreference            => $args->{devicePreference},
    displayUploadAd             => $args->{displayUploadAd},
    displayUrl                  => $args->{displayUrl},
    expandedDynamicSearchAd     => $args->{expandedDynamicSearchAd},
    expandedTextAd              => $args->{expandedTextAd},
    finalAppUrls                => $args->{finalAppUrls},
    finalMobileUrls             => $args->{finalMobileUrls},
    finalUrlSuffix              => $args->{finalUrlSuffix},
    finalUrls                   => $args->{finalUrls},
    gmailAd                     => $args->{gmailAd},
    hotelAd                     => $args->{hotelAd},
    id                          => $args->{id},
    imageAd                     => $args->{imageAd},
    legacyAppInstallAd          => $args->{legacyAppInstallAd},
    legacyResponsiveDisplayAd   => $args->{legacyResponsiveDisplayAd},
    localAd                     => $args->{localAd},
    name                        => $args->{name},
    resourceName                => $args->{resourceName},
    responsiveDisplayAd         => $args->{responsiveDisplayAd},
    responsiveSearchAd          => $args->{responsiveSearchAd},
    shoppingComparisonListingAd => $args->{shoppingComparisonListingAd},
    shoppingProductAd           => $args->{shoppingProductAd},
    shoppingSmartAd             => $args->{shoppingSmartAd},
    smartCampaignAd             => $args->{smartCampaignAd},
    systemManagedResourceSource => $args->{systemManagedResourceSource},
    textAd                      => $args->{textAd},
    trackingUrlTemplate         => $args->{trackingUrlTemplate},
    type                        => $args->{type},
    urlCollections              => $args->{urlCollections},
    urlCustomParameters         => $args->{urlCustomParameters},
    videoAd                     => $args->{videoAd},
    videoResponsiveAd           => $args->{videoResponsiveAd}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
