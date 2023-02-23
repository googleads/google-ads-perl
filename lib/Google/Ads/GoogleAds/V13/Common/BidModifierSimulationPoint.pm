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

package Google::Ads::GoogleAds::V13::Common::BidModifierSimulationPoint;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    bidModifier                    => $args->{bidModifier},
    biddableConversions            => $args->{biddableConversions},
    biddableConversionsValue       => $args->{biddableConversionsValue},
    clicks                         => $args->{clicks},
    costMicros                     => $args->{costMicros},
    impressions                    => $args->{impressions},
    parentBiddableConversions      => $args->{parentBiddableConversions},
    parentBiddableConversionsValue => $args->{parentBiddableConversionsValue},
    parentClicks                   => $args->{parentClicks},
    parentCostMicros               => $args->{parentCostMicros},
    parentImpressions              => $args->{parentImpressions},
    parentRequiredBudgetMicros     => $args->{parentRequiredBudgetMicros},
    parentTopSlotImpressions       => $args->{parentTopSlotImpressions},
    topSlotImpressions             => $args->{topSlotImpressions}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
