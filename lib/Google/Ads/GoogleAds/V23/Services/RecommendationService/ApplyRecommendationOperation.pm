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

package Google::Ads::GoogleAds::V23::Services::RecommendationService::ApplyRecommendationOperation;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    callAsset                           => $args->{callAsset},
    callExtension                       => $args->{callExtension},
    calloutAsset                        => $args->{calloutAsset},
    calloutExtension                    => $args->{calloutExtension},
    campaignBudget                      => $args->{campaignBudget},
    forecastingSetTargetCpa             => $args->{forecastingSetTargetCpa},
    forecastingSetTargetRoas            => $args->{forecastingSetTargetRoas},
    keyword                             => $args->{keyword},
    leadFormAsset                       => $args->{leadFormAsset},
    lowerTargetRoas                     => $args->{lowerTargetRoas},
    moveUnusedBudget                    => $args->{moveUnusedBudget},
    raiseTargetCpa                      => $args->{raiseTargetCpa},
    raiseTargetCpaBidTooLow             => $args->{raiseTargetCpaBidTooLow},
    resourceName                        => $args->{resourceName},
    responsiveSearchAd                  => $args->{responsiveSearchAd},
    responsiveSearchAdAsset             => $args->{responsiveSearchAdAsset},
    responsiveSearchAdImproveAdStrength =>
      $args->{responsiveSearchAdImproveAdStrength},
    setTargetCpa         => $args->{setTargetCpa},
    setTargetRoas        => $args->{setTargetRoas},
    sitelinkAsset        => $args->{sitelinkAsset},
    sitelinkExtension    => $args->{sitelinkExtension},
    targetCpaOptIn       => $args->{targetCpaOptIn},
    targetRoasOptIn      => $args->{targetRoasOptIn},
    textAd               => $args->{textAd},
    useBroadMatchKeyword => $args->{useBroadMatchKeyword}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
