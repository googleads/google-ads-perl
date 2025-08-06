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

package Google::Ads::GoogleAds::V21::Resources::CampaignCriterion;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    adSchedule             => $args->{adSchedule},
    ageRange               => $args->{ageRange},
    bidModifier            => $args->{bidModifier},
    brandList              => $args->{brandList},
    campaign               => $args->{campaign},
    carrier                => $args->{carrier},
    combinedAudience       => $args->{combinedAudience},
    contentLabel           => $args->{contentLabel},
    criterionId            => $args->{criterionId},
    customAffinity         => $args->{customAffinity},
    customAudience         => $args->{customAudience},
    device                 => $args->{device},
    displayName            => $args->{displayName},
    extendedDemographic    => $args->{extendedDemographic},
    gender                 => $args->{gender},
    incomeRange            => $args->{incomeRange},
    ipBlock                => $args->{ipBlock},
    keyword                => $args->{keyword},
    keywordTheme           => $args->{keywordTheme},
    language               => $args->{language},
    lifeEvent              => $args->{lifeEvent},
    listingScope           => $args->{listingScope},
    localServiceId         => $args->{localServiceId},
    location               => $args->{location},
    locationGroup          => $args->{locationGroup},
    mobileAppCategory      => $args->{mobileAppCategory},
    mobileApplication      => $args->{mobileApplication},
    mobileDevice           => $args->{mobileDevice},
    negative               => $args->{negative},
    operatingSystemVersion => $args->{operatingSystemVersion},
    parentalStatus         => $args->{parentalStatus},
    placement              => $args->{placement},
    proximity              => $args->{proximity},
    resourceName           => $args->{resourceName},
    status                 => $args->{status},
    topic                  => $args->{topic},
    type                   => $args->{type},
    userInterest           => $args->{userInterest},
    userList               => $args->{userList},
    videoLineup            => $args->{videoLineup},
    webpage                => $args->{webpage},
    webpageList            => $args->{webpageList},
    youtubeChannel         => $args->{youtubeChannel},
    youtubeVideo           => $args->{youtubeVideo}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
