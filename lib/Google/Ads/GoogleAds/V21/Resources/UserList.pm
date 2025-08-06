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

package Google::Ads::GoogleAds::V21::Resources::UserList;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    accessReason          => $args->{accessReason},
    accountUserListStatus => $args->{accountUserListStatus},
    basicUserList         => $args->{basicUserList},
    closingReason         => $args->{closingReason},
    crmBasedUserList      => $args->{crmBasedUserList},
    description           => $args->{description},
    eligibleForDisplay    => $args->{eligibleForDisplay},
    eligibleForSearch     => $args->{eligibleForSearch},
    id                    => $args->{id},
    integrationCode       => $args->{integrationCode},
    logicalUserList       => $args->{logicalUserList},
    lookalikeUserList     => $args->{lookalikeUserList},
    matchRatePercentage   => $args->{matchRatePercentage},
    membershipLifeSpan    => $args->{membershipLifeSpan},
    membershipStatus      => $args->{membershipStatus},
    name                  => $args->{name},
    readOnly              => $args->{readOnly},
    resourceName          => $args->{resourceName},
    ruleBasedUserList     => $args->{ruleBasedUserList},
    similarUserList       => $args->{similarUserList},
    sizeForDisplay        => $args->{sizeForDisplay},
    sizeForSearch         => $args->{sizeForSearch},
    sizeRangeForDisplay   => $args->{sizeRangeForDisplay},
    sizeRangeForSearch    => $args->{sizeRangeForSearch},
    type                  => $args->{type}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
