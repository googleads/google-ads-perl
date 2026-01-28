#!/usr/bin/perl -w
#
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
#
# This example imports offline conversion values for specific clicks to your account.
# To get Google Click ID for a click, use the "click_view" resource:
# https://developers.google.com/google-ads/api/fields/latest/click_view.
# To set up a conversion action, run the add_conversion_action.pl example.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Common::Consent;
use
  Google::Ads::GoogleAds::V23::Services::ConversionUploadService::ClickConversion;
use
  Google::Ads::GoogleAds::V23::Services::ConversionUploadService::CustomVariable;
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
#  Set exactly one of gclid, gbraid, or wbraid.
my $gclid                = "INSERT_GCLID_HERE";
my $gbraid               = undef;
my $wbraid               = undef;
my $conversion_date_time = "INSERT_CONVERSION_DATE_TIME_HERE";
my $conversion_value     = "INSERT_CONVERSION_VALUE_HERE";
# Optional: Specify the conversion custom variable ID and value you want to
# associate with the click conversion upload.
my $conversion_custom_variable_id    = undef;
my $conversion_custom_variable_value = undef;
# Optional: Specify the unique order ID for the click conversion.
my $order_id = undef;
# Optional: Specify the ad user data consent for the click.
my $ad_user_data_consent = undef;

# [START upload_offline_conversion]
sub upload_offline_conversion {
  my (
    $api_client,                    $customer_id,
    $conversion_action_id,          $gclid,
    $gbraid,                        $wbraid,
    $conversion_date_time,          $conversion_value,
    $conversion_custom_variable_id, $conversion_custom_variable_value,
    $order_id,                      $ad_user_data_consent
  ) = @_;

  # Verify that exactly one of gclid, gbraid, and wbraid is specified, as required.
  # See https://developers.google.com/google-ads/api/docs/conversions/upload-clicks for details.
  my $number_of_ids_specified = grep { defined $_ } ($gclid, $gbraid, $wbraid);
  if ($number_of_ids_specified != 1) {
    die sprintf "Exactly 1 of gclid, gbraid, or wbraid is required, " .
      "but %d ID values were provided.\n",
      $number_of_ids_specified;
  }

  # Create a click conversion by specifying currency as USD.
  my $click_conversion =
    Google::Ads::GoogleAds::V23::Services::ConversionUploadService::ClickConversion
    ->new({
      conversionAction =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::conversion_action(
        $customer_id, $conversion_action_id
        ),
      conversionDateTime => $conversion_date_time,
      conversionValue    => $conversion_value,
      currencyCode       => "USD"
    });

  # Set the single specified ID field.
  if (defined $gclid) {
    $click_conversion->{gclid} = $gclid;
  } elsif (defined $gbraid) {
    $click_conversion->{gbraid} = $gbraid;
  } else {
    $click_conversion->{wbraid} = $wbraid;
  }

  if ($conversion_custom_variable_id && $conversion_custom_variable_value) {
    $click_conversion->{customVariables} = [
      Google::Ads::GoogleAds::V23::Services::ConversionUploadService::CustomVariable
        ->new({
          conversionCustomVariable =>
            Google::Ads::GoogleAds::V23::Utils::ResourceNames::conversion_custom_variable(
            $customer_id, $conversion_custom_variable_id
            ),
          value => $conversion_custom_variable_value
        })];
  }

  if (defined $order_id) {
    # Set the order ID (unique transaction ID), if provided.
    $click_conversion->{orderId} = $order_id;
  }

  # Set the consent information, if provided.
  if ($ad_user_data_consent) {
    # Specify whether user consent was obtained for the data you are uploading.
    # See https://www.google.com/about/company/user-consent-policy for details.
    $click_conversion->{consent} =
      Google::Ads::GoogleAds::V23::Common::Consent->new({
        adUserData => $ad_user_data_consent
      });
  }

  # Issue a request to upload the click conversion. Partial failure should
  # always be set to true.
  #
  # NOTE: This request contains a single conversion as a demonstration.
  # However, if you have multiple conversions to upload, it's best to
  # upload multiple conversions per request instead of sending a separate
  # request per conversion. See the following for per-request limits:
  # https://developers.google.com/google-ads/api/docs/best-practices/quotas#conversion_upload_service
  my $upload_click_conversions_response =
    $api_client->ConversionUploadService()->upload_click_conversions({
      customerId     => $customer_id,
      conversions    => [$click_conversion],
      partialFailure => "true"
    });

  # Print any partial errors returned.
  if ($upload_click_conversions_response->{partialFailureError}) {
    printf "Partial error encountered: '%s'.\n",
      $upload_click_conversions_response->{partialFailureError}{message};
  }

  # Print the result if valid.
  my $uploaded_click_conversion =
    $upload_click_conversions_response->{results}[0];
  if (%$uploaded_click_conversion) {
    printf
      "Uploaded conversion that occurred at '%s' from Google Click ID '%s' " .
      "to the conversion action with resource name '%s'.\n",
      $uploaded_click_conversion->{conversionDateTime},
      $uploaded_click_conversion->{gclid},
      $uploaded_click_conversion->{conversionAction};
  }

  return 1;
}
# [END upload_offline_conversion]

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
  "customer_id=s"                      => \$customer_id,
  "conversion_action_id=i"             => \$conversion_action_id,
  "gclid=s"                            => \$gclid,
  "gbraid=s"                           => \$gbraid,
  "wbraid=s"                           => \$wbraid,
  "conversion_date_time=s"             => \$conversion_date_time,
  "conversion_value=f"                 => \$conversion_value,
  "conversion_custom_variable_id=s"    => \$conversion_custom_variable_id,
  "conversion_custom_variable_value=s" => \$conversion_custom_variable_value,
  "order_id=s"                         => \$order_id,
  "ad_user_data_consent=s"             => \$ad_user_data_consent
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params(
  $customer_id,          $conversion_action_id,
  $conversion_date_time, $conversion_value
  );

# Call the example.
upload_offline_conversion(
  $api_client,                    $customer_id =~ s/-//gr,
  $conversion_action_id,          $gclid,
  $gbraid,                        $wbraid,
  $conversion_date_time,          $conversion_value,
  $conversion_custom_variable_id, $conversion_custom_variable_value,
  $order_id,                      $ad_user_data_consent
);

=pod

=head1 NAME

upload_offline_conversion

=head1 DESCRIPTION

This example imports offline conversion values for specific clicks to your account.
To get Google Click ID for a click, use the "click_view" resource:
https://developers.google.com/google-ads/api/fields/latest/click_view.
To set up a conversion action, run the add_conversion_action.pl example.

=head1 SYNOPSIS

upload_offline_conversion.pl [options]

    -help                               Show the help message.
    -customer_id                        The Google Ads customer ID.
    -conversion_action_id               The ID of the conversion action to upload to.
    -gclid                              [optional] The GCLID for the conversion. If setting this value, do not
                                        set -gbraid or -wbraid.
    -gbraid                             [optional] The GBRAID for the iOS app conversion. If setting this value,
                                        do not set -gclid or -wbraid.
    -wbraid                             [optional] The WBRAID for the iOS web conversion. If setting this value,
                                        do not set -gclid or -gbraid.
    -conversion_date_time               The date and time of the conversion (should be after the click time).
                                        The format is "yyyy-mm-dd hh:mm:ss+|-hh:mm", e.g. "2019-01-01 12:32:45-08:00".
    -conversion_value                   The value of the conversion.
    -conversion_custom_variable_id      [optional] The ID of the conversion custom variable to associate with the upload.
    -conversion_custom_variable_value   [optional] The value of the conversion custom variable to associate with the upload.
    -order_id                           [optional] The unique ID (transaction ID) of the conversion.
    -ad_user_data_consent               [optional] The ad user data consent for the click.
    
=cut
