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

package Google::Ads::GoogleAds::V2::Resources::ConversionAction;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    appId                          => $args->{appId},
    attributionModelSettings       => $args->{attributionModelSettings},
    category                       => $args->{category},
    clickThroughLookbackWindowDays => $args->{clickThroughLookbackWindowDays},
    countingType                   => $args->{countingType},
    id                             => $args->{id},
    includeInConversionsMetric     => $args->{includeInConversionsMetric},
    name                           => $args->{name},
    ownerCustomer                  => $args->{ownerCustomer},
    phoneCallDurationSeconds       => $args->{phoneCallDurationSeconds},
    resourceName                   => $args->{resourceName},
    status                         => $args->{status},
    tagSnippets                    => $args->{tagSnippets},
    type                           => $args->{type},
    valueSettings                  => $args->{valueSettings},
    viewThroughLookbackWindowDays  => $args->{viewThroughLookbackWindowDays}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
