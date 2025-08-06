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

package Google::Ads::GoogleAds::V21::Resources::AccountSummary;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::BaseEntity);

use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

sub new {
  my ($class, $args) = @_;
  my $self = {
    billingCorrectionSubtotalAmountMicros =>
      $args->{billingCorrectionSubtotalAmountMicros},
    billingCorrectionTaxAmountMicros =>
      $args->{billingCorrectionTaxAmountMicros},
    billingCorrectionTotalAmountMicros =>
      $args->{billingCorrectionTotalAmountMicros},
    couponAdjustmentSubtotalAmountMicros =>
      $args->{couponAdjustmentSubtotalAmountMicros},
    couponAdjustmentTaxAmountMicros => $args->{couponAdjustmentTaxAmountMicros},
    couponAdjustmentTotalAmountMicros =>
      $args->{couponAdjustmentTotalAmountMicros},
    customer                                   => $args->{customer},
    excessCreditAdjustmentSubtotalAmountMicros =>
      $args->{excessCreditAdjustmentSubtotalAmountMicros},
    excessCreditAdjustmentTaxAmountMicros =>
      $args->{excessCreditAdjustmentTaxAmountMicros},
    excessCreditAdjustmentTotalAmountMicros =>
      $args->{excessCreditAdjustmentTotalAmountMicros},
    exportChargeSubtotalAmountMicros =>
      $args->{exportChargeSubtotalAmountMicros},
    exportChargeTaxAmountMicros   => $args->{exportChargeTaxAmountMicros},
    exportChargeTotalAmountMicros => $args->{exportChargeTotalAmountMicros},
    regulatoryCostsSubtotalAmountMicros =>
      $args->{regulatoryCostsSubtotalAmountMicros},
    regulatoryCostsTaxAmountMicros   => $args->{regulatoryCostsTaxAmountMicros},
    regulatoryCostsTotalAmountMicros =>
      $args->{regulatoryCostsTotalAmountMicros},
    subtotalAmountMicros => $args->{subtotalAmountMicros},
    taxAmountMicros      => $args->{taxAmountMicros},
    totalAmountMicros    => $args->{totalAmountMicros}};

  # Delete the unassigned fields in this object for a more concise JSON payload
  remove_unassigned_fields($self, $args);

  bless $self, $class;
  return $self;
}

1;
