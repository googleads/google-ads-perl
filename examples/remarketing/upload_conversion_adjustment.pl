#!/usr/bin/perl -w
#
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
#
# This example imports conversion adjustments for conversions that already exist.
# To set up a conversion action, run add_conversion_action.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Enums::ConversionAdjustmentTypeEnum
  qw(RESTATEMENT);
use
  Google::Ads::GoogleAds::V23::Services::ConversionAdjustmentUploadService::ConversionAdjustment;
use
  Google::Ads::GoogleAds::V23::Services::ConversionAdjustmentUploadService::GclidDateTimePair;
use
  Google::Ads::GoogleAds::V23::Services::ConversionAdjustmentUploadService::RestatementValue;
use Google::Ads::GoogleAds::V23::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id          = "INSERT_CUSTOMER_ID_HERE";
my $conversion_action_id = "INSERT_CONVERSION_ACTION_ID_HERE";
# The transaction ID of the conversion to adjust. Required if the conversion
# being adjusted meets the criteria described at
# https://developers.google.com/google-ads/api/docs/conversions/upload-adjustments#requirements.
my $order_id = "INSERT_ORDER_ID_HERE";
# RETRACTION negates a conversion, and RESTATEMENT changes the value of a conversion.
my $adjustment_type      = "INSERT_ADJUSTMENT_TYPE_HERE";
my $adjustment_date_time = "INSERT_ADJUSTMENT_DATE_TIME_HERE";
# Optional: Specify an adjusted value below for adjustment type RESTATEMENT.
# This value will be ignored if you specify RETRACTION as adjustment type.
my $restatement_value = undef;

# [START upload_conversion_adjustment]
sub upload_conversion_adjustment {
  my ($api_client, $customer_id, $conversion_action_id, $order_id,
    $adjustment_type, $adjustment_date_time, $restatement_value)
    = @_;

  # Applies the conversion adjustment to the existing conversion.
  my $conversion_adjustment =
    Google::Ads::GoogleAds::V23::Services::ConversionAdjustmentUploadService::ConversionAdjustment
    ->new({
      conversionAction =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::conversion_action(
        $customer_id, $conversion_action_id
        ),
      adjustmentType => $adjustment_type,
      # Sets the orderId to identify the conversion to adjust.
      orderId => $order_id,
      # As an alternative to setting orderId, you can provide a 'gclid_date_time_pair',
      # but setting 'order_id' instead is strongly recommended.
      # gclidDateTimePair =>
      #  Google::Ads::GoogleAds::V23::Services::ConversionAdjustmentUploadService::GclidDateTimePair
      #  ->new({
      #    gclid              => $gclid,
      #    conversionDateTime => $conversion_date_time
      #  }
      #  ),
      adjustmentDateTime => $adjustment_date_time,
    });

  # Set adjusted value for adjustment type RESTATEMENT.
  $conversion_adjustment->{restatementValue} =
    Google::Ads::GoogleAds::V23::Services::ConversionAdjustmentUploadService::RestatementValue
    ->new({
      adjustedValue => $restatement_value
    }) if defined $restatement_value && $adjustment_type eq RESTATEMENT;

  # Issue a request to upload the conversion adjustment.
  my $upload_conversion_adjustments_response =
    $api_client->ConversionAdjustmentUploadService()
    ->upload_conversion_adjustments({
      customerId            => $customer_id,
      conversionAdjustments => [$conversion_adjustment],
      partialFailure        => "true"
    });

  # Print any partial errors returned.
  if ($upload_conversion_adjustments_response->{partialFailureError}) {
    printf "Partial error encountered: '%s'.\n",
      $upload_conversion_adjustments_response->{partialFailureError}{message};
  }

  # Print the result if valid.
  my $uploaded_conversion_adjustment =
    $upload_conversion_adjustments_response->{results}[0];
  if (%$uploaded_conversion_adjustment) {
    printf "Uploaded conversion adjustment of the conversion action " .
      "with resource name '%s' for order ID '%s'.\n",
      $uploaded_conversion_adjustment->{conversionAction},
      $uploaded_conversion_adjustment->{orderId};
  }

  return 1;
}
# [END upload_conversion_adjustment]

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s"          => \$customer_id,
  "conversion_action_id=i" => \$conversion_action_id,
  "order_id=s"             => \$order_id,
  "adjustment_type=s"      => \$adjustment_type,
  "adjustment_date_time=s" => \$adjustment_date_time,
  "restatement_value=f"    => \$restatement_value
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $conversion_action_id, $order_id,
  $adjustment_type, $adjustment_date_time);

# Call the example.
upload_conversion_adjustment($api_client, $customer_id =~ s/-//gr,
  $conversion_action_id, $order_id,
  $adjustment_type, $adjustment_date_time, $restatement_value);

=pod

=head1 NAME

upload_conversion_adjustment

=head1 DESCRIPTION

This example imports conversion adjustments for conversions that already exist.
To set up a conversion action, run add_conversion_action.pl.

=head1 SYNOPSIS

upload_conversion_adjustment.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -conversion_action_id       The ID of the conversion action to upload to.
    -order_id                   The order ID of the conversion. Strongly recommended instead of using GCLID and conversion date time.
    -adjustment_type            The type of adjustment, e.g. RETRACTION, RESTATEMENT.
    -adjustment_date_time       The date and time of the adjustment.
                                The format is "yyyy-mm-dd hh:mm:ss+|-hh:mm", e.g. "2019-01-01 12:32:45-08:00".
    -restatement_value          [optional] The adjusted value for adjustment type RESTATEMENT.

=cut
