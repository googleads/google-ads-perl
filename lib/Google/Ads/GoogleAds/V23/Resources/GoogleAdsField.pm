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

package Google::Ads::GoogleAds::V23::Resources::GoogleAdsField;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    attributeResources => $args->{attributeResources},
    category           => $args->{category},
    dataType           => $args->{dataType},
    enumValues         => $args->{enumValues},
    filterable         => $args->{filterable},
    isRepeated         => $args->{isRepeated},
    metrics            => $args->{metrics},
    name               => $args->{name},
    resourceName       => $args->{resourceName},
    segments           => $args->{segments},
    selectable         => $args->{selectable},
    selectableWith     => $args->{selectableWith},
    sortable           => $args->{sortable},
    typeUrl            => $args->{typeUrl}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
