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

package Google::Ads::GoogleAds::V19::Resources::OfflineConversionError;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    collectionSizeError             => $args->{collectionSizeError},
    conversionAdjustmentUploadError => $args->{conversionAdjustmentUploadError},
    conversionUploadError           => $args->{conversionUploadError},
    dateError                       => $args->{dateError},
    distinctError                   => $args->{distinctError},
    fieldError                      => $args->{fieldError},
    mutateError                     => $args->{mutateError},
    notAllowlistedError             => $args->{notAllowlistedError},
    stringFormatError               => $args->{stringFormatError},
    stringLengthError               => $args->{stringLengthError}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
