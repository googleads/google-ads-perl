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

package Google::Ads::GoogleAds::V23::Resources::ShoppingProduct;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    adGroup               => $args->{adGroup},
    availability          => $args->{availability},
    brand                 => $args->{brand},
    campaign              => $args->{campaign},
    categoryLevel1        => $args->{categoryLevel1},
    categoryLevel2        => $args->{categoryLevel2},
    categoryLevel3        => $args->{categoryLevel3},
    categoryLevel4        => $args->{categoryLevel4},
    categoryLevel5        => $args->{categoryLevel5},
    channel               => $args->{channel},
    channelExclusivity    => $args->{channelExclusivity},
    condition             => $args->{condition},
    currencyCode          => $args->{currencyCode},
    customAttribute0      => $args->{customAttribute0},
    customAttribute1      => $args->{customAttribute1},
    customAttribute2      => $args->{customAttribute2},
    customAttribute3      => $args->{customAttribute3},
    customAttribute4      => $args->{customAttribute4},
    effectiveMaxCpcMicros => $args->{effectiveMaxCpcMicros},
    feedLabel             => $args->{feedLabel},
    issues                => $args->{issues},
    itemId                => $args->{itemId},
    languageCode          => $args->{languageCode},
    merchantCenterId      => $args->{merchantCenterId},
    multiClientAccountId  => $args->{multiClientAccountId},
    priceMicros           => $args->{priceMicros},
    productImageUri       => $args->{productImageUri},
    productTypeLevel1     => $args->{productTypeLevel1},
    productTypeLevel2     => $args->{productTypeLevel2},
    productTypeLevel3     => $args->{productTypeLevel3},
    productTypeLevel4     => $args->{productTypeLevel4},
    productTypeLevel5     => $args->{productTypeLevel5},
    resourceName          => $args->{resourceName},
    status                => $args->{status},
    targetCountries       => $args->{targetCountries},
    title                 => $args->{title}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
