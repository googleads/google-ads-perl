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

package Google::Ads::GoogleAds::V23::Services::BenchmarksService::RateMetrics;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    activeViewViewability   => $args->{activeViewViewability},
    averageActiveViewCpm    => $args->{averageActiveViewCpm},
    averageCpc              => $args->{averageCpc},
    averageCpe              => $args->{averageCpe},
    averageCpi              => $args->{averageCpi},
    averageCpm              => $args->{averageCpm},
    clickThroughRate        => $args->{clickThroughRate},
    engagementRate          => $args->{engagementRate},
    interactionRate         => $args->{interactionRate},
    trueviewAverageCpv      => $args->{trueviewAverageCpv},
    trueviewViewRate        => $args->{trueviewViewRate},
    videoCompletionP100Rate => $args->{videoCompletionP100Rate},
    videoCompletionP25Rate  => $args->{videoCompletionP25Rate},
    videoCompletionP50Rate  => $args->{videoCompletionP50Rate},
    videoCompletionP75Rate  => $args->{videoCompletionP75Rate}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
