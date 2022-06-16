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

package Google::Ads::GoogleAds::V11::Resources::AdGroup;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    adRotationMode                => $args->{adRotationMode},
    audienceSetting               => $args->{audienceSetting},
    baseAdGroup                   => $args->{baseAdGroup},
    campaign                      => $args->{campaign},
    cpcBidMicros                  => $args->{cpcBidMicros},
    cpmBidMicros                  => $args->{cpmBidMicros},
    cpvBidMicros                  => $args->{cpvBidMicros},
    displayCustomBidDimension     => $args->{displayCustomBidDimension},
    effectiveCpcBidMicros         => $args->{effectiveCpcBidMicros},
    effectiveTargetCpaMicros      => $args->{effectiveTargetCpaMicros},
    effectiveTargetCpaSource      => $args->{effectiveTargetCpaSource},
    effectiveTargetRoas           => $args->{effectiveTargetRoas},
    effectiveTargetRoasSource     => $args->{effectiveTargetRoasSource},
    excludedParentAssetFieldTypes => $args->{excludedParentAssetFieldTypes},
    explorerAutoOptimizerSetting  => $args->{explorerAutoOptimizerSetting},
    finalUrlSuffix                => $args->{finalUrlSuffix},
    id                            => $args->{id},
    labels                        => $args->{labels},
    name                          => $args->{name},
    percentCpcBidMicros           => $args->{percentCpcBidMicros},
    resourceName                  => $args->{resourceName},
    status                        => $args->{status},
    targetCpaMicros               => $args->{targetCpaMicros},
    targetCpmMicros               => $args->{targetCpmMicros},
    targetRoas                    => $args->{targetRoas},
    targetingSetting              => $args->{targetingSetting},
    trackingUrlTemplate           => $args->{trackingUrlTemplate},
    type                          => $args->{type},
    urlCustomParameters           => $args->{urlCustomParameters}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
