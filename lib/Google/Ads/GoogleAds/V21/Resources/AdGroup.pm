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

package Google::Ads::GoogleAds::V21::Resources::AdGroup;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    adRotationMode                => $args->{adRotationMode},
    aiMaxAdGroupSetting           => $args->{aiMaxAdGroupSetting},
    audienceSetting               => $args->{audienceSetting},
    baseAdGroup                   => $args->{baseAdGroup},
    campaign                      => $args->{campaign},
    cpcBidMicros                  => $args->{cpcBidMicros},
    cpmBidMicros                  => $args->{cpmBidMicros},
    cpvBidMicros                  => $args->{cpvBidMicros},
    demandGenAdGroupSettings      => $args->{demandGenAdGroupSettings},
    displayCustomBidDimension     => $args->{displayCustomBidDimension},
    effectiveCpcBidMicros         => $args->{effectiveCpcBidMicros},
    effectiveTargetCpaMicros      => $args->{effectiveTargetCpaMicros},
    effectiveTargetCpaSource      => $args->{effectiveTargetCpaSource},
    effectiveTargetRoas           => $args->{effectiveTargetRoas},
    effectiveTargetRoasSource     => $args->{effectiveTargetRoasSource},
    excludeDemographicExpansion   => $args->{excludeDemographicExpansion},
    excludedParentAssetFieldTypes => $args->{excludedParentAssetFieldTypes},
    excludedParentAssetSetTypes   => $args->{excludedParentAssetSetTypes},
    finalUrlSuffix                => $args->{finalUrlSuffix},
    fixedCpmMicros                => $args->{fixedCpmMicros},
    id                            => $args->{id},
    labels                        => $args->{labels},
    name                          => $args->{name},
    optimizedTargetingEnabled     => $args->{optimizedTargetingEnabled},
    percentCpcBidMicros           => $args->{percentCpcBidMicros},
    primaryStatus                 => $args->{primaryStatus},
    primaryStatusReasons          => $args->{primaryStatusReasons},
    resourceName                  => $args->{resourceName},
    status                        => $args->{status},
    targetCpaMicros               => $args->{targetCpaMicros},
    targetCpmMicros               => $args->{targetCpmMicros},
    targetCpvMicros               => $args->{targetCpvMicros},
    targetRoas                    => $args->{targetRoas},
    targetingSetting              => $args->{targetingSetting},
    trackingUrlTemplate           => $args->{trackingUrlTemplate},
    type                          => $args->{type},
    urlCustomParameters           => $args->{urlCustomParameters},
    videoAdGroupSettings          => $args->{videoAdGroupSettings}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
