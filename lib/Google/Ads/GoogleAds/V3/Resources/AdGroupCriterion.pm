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

package Google::Ads::GoogleAds::V3::Resources::AdGroupCriterion;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    adGroup                      => $args->{adGroup},
    ageRange                     => $args->{ageRange},
    appPaymentModel              => $args->{appPaymentModel},
    approvalStatus               => $args->{approvalStatus},
    bidModifier                  => $args->{bidModifier},
    cpcBidMicros                 => $args->{cpcBidMicros},
    cpmBidMicros                 => $args->{cpmBidMicros},
    cpvBidMicros                 => $args->{cpvBidMicros},
    criterionId                  => $args->{criterionId},
    customAffinity               => $args->{customAffinity},
    customIntent                 => $args->{customIntent},
    effectiveCpcBidMicros        => $args->{effectiveCpcBidMicros},
    effectiveCpcBidSource        => $args->{effectiveCpcBidSource},
    effectiveCpmBidMicros        => $args->{effectiveCpmBidMicros},
    effectiveCpmBidSource        => $args->{effectiveCpmBidSource},
    effectiveCpvBidMicros        => $args->{effectiveCpvBidMicros},
    effectiveCpvBidSource        => $args->{effectiveCpvBidSource},
    effectivePercentCpcBidMicros => $args->{effectivePercentCpcBidMicros},
    effectivePercentCpcBidSource => $args->{effectivePercentCpcBidSource},
    finalMobileUrls              => $args->{finalMobileUrls},
    finalUrlSuffix               => $args->{finalUrlSuffix},
    finalUrls                    => $args->{finalUrls},
    gender                       => $args->{gender},
    incomeRange                  => $args->{incomeRange},
    keyword                      => $args->{keyword},
    listingGroup                 => $args->{listingGroup},
    mobileAppCategory            => $args->{mobileAppCategory},
    mobileApplication            => $args->{mobileApplication},
    negative                     => $args->{negative},
    parentalStatus               => $args->{parentalStatus},
    percentCpcBidMicros          => $args->{percentCpcBidMicros},
    placement                    => $args->{placement},
    positionEstimates            => $args->{positionEstimates},
    qualityInfo                  => $args->{qualityInfo},
    resourceName                 => $args->{resourceName},
    status                       => $args->{status},
    systemServingStatus          => $args->{systemServingStatus},
    topic                        => $args->{topic},
    trackingUrlTemplate          => $args->{trackingUrlTemplate},
    type                         => $args->{type},
    urlCustomParameters          => $args->{urlCustomParameters},
    userInterest                 => $args->{userInterest},
    userList                     => $args->{userList},
    webpage                      => $args->{webpage},
    youtubeChannel               => $args->{youtubeChannel},
    youtubeVideo                 => $args->{youtubeVideo}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
