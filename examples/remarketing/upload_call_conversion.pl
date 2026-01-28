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
# This example imports offline call conversion values for calls related to the
# ads in your account.
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
  Google::Ads::GoogleAds::V23::Services::ConversionUploadService::CallConversion;
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
my $caller_id            = "INSERT_CALLER_ID_HERE";
my $call_start_date_time = "INSERT_CALL_START_DATE_TIME_HERE";
my $conversion_date_time = "INSERT_CONVERSION_DATE_TIME_HERE";
my $conversion_value     = "INSERT_CONVERSION_VALUE_HERE";
# Optional: Specify the conversion custom variable ID and value you want to
# associate with the call conversion upload.
my $conversion_custom_variable_id    = undef;
my $conversion_custom_variable_value = undef;
# Optional: Specify the ad user data consent for the call.
my $ad_user_data_consent = undef;

# [START upload_call_conversion]
sub upload_call_conversion {
  my (
    $api_client,                       $customer_id,
    $conversion_action_id,             $caller_id,
    $call_start_date_time,             $conversion_date_time,
    $conversion_value,                 $conversion_custom_variable_id,
    $conversion_custom_variable_value, $ad_user_data_consent
  ) = @_;

  # Create a call conversion by specifying currency as USD.
  my $call_conversion =
    Google::Ads::GoogleAds::V23::Services::ConversionUploadService::CallConversion
    ->new({
      conversionAction =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::conversion_action(
        $customer_id, $conversion_action_id
        ),
      callerId           => $caller_id,
      callStartDateTime  => $call_start_date_time,
      conversionDateTime => $conversion_date_time,
      conversionValue    => $conversion_value,
      currencyCode       => "USD"
    });

  if ($conversion_custom_variable_id && $conversion_custom_variable_value) {
    $call_conversion->{customVariables} = [
      Google::Ads::GoogleAds::V23::Services::ConversionUploadService::CustomVariable
        ->new({
          conversionCustomVariable =>
            Google::Ads::GoogleAds::V23::Utils::ResourceNames::conversion_custom_variable(
            $customer_id, $conversion_custom_variable_id
            ),
          value => $conversion_custom_variable_value
        })];
  }

  # Set the consent information, if provided.
  if ($ad_user_data_consent) {
    # Specify whether user consent was obtained for the data you are uploading.
    # See https://www.google.com/about/company/user-consent-policy for details.
    $call_conversion->{consent} =
      Google::Ads::GoogleAds::V23::Common::Consent->new({
        adUserData => $ad_user_data_consent
      });
  }

  # Issue a request to upload the call conversion.
  # NOTE: This request contains a single conversion as a demonstration.
  # However, if you have multiple conversions to upload, it's best to
  # upload multiple conversions per request instead of sending a separate
  # request per conversion. See the following for per-request limits:
  # https://developers.google.com/google-ads/api/docs/best-practices/quotas#conversion_upload_service
  my $upload_call_conversions_response =
    $api_client->ConversionUploadService()->upload_call_conversions({
      customerId     => $customer_id,
      conversions    => [$call_conversion],
      partialFailure => "true"
    });

  # Print any partial errors returned.
  if ($upload_call_conversions_response->{partialFailureError}) {
    printf "Partial error encountered: '%s'.\n",
      $upload_call_conversions_response->{partialFailureError}{message};
  }

  # Print the result if valid.
  my $uploaded_call_conversion =
    $upload_call_conversions_response->{results}[0];
  if (%$uploaded_call_conversion) {
    printf "Uploaded call conversion that occurred at '%s' " .
      "for caller ID '%s' to the conversion action with resource name '%s'.\n",
      $uploaded_call_conversion->{callStartDateTime},
      $uploaded_call_conversion->{callerId},
      $uploaded_call_conversion->{conversionAction};
  }

  return 1;
}
# [END upload_call_conversion]

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
  "caller_id=s"                        => \$caller_id,
  "call_start_date_time=s"             => \$call_start_date_time,
  "conversion_date_time=s"             => \$conversion_date_time,
  "conversion_value=f"                 => \$conversion_value,
  "conversion_custom_variable_id=s"    => \$conversion_custom_variable_id,
  "conversion_custom_variable_value=s" => \$conversion_custom_variable_value,
  "ad_user_data_consent=s"             => \$ad_user_data_consent
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $conversion_action_id, $caller_id,
  $call_start_date_time, $conversion_date_time, $conversion_value);

# Call the example.
upload_call_conversion(
  $api_client,                       $customer_id =~ s/-//gr,
  $conversion_action_id,             $caller_id,
  $call_start_date_time,             $conversion_date_time,
  $conversion_value,                 $conversion_custom_variable_id,
  $conversion_custom_variable_value, $ad_user_data_consent
);

=pod

=head1 NAME

upload_call_conversion

=head1 DESCRIPTION

This example imports offline call conversion values for calls related to the ads
in your account.
To set up a conversion action, run the add_conversion_action.pl example.

=head1 SYNOPSIS

upload_call_conversion.pl [options]

    -help                               Show the help message.
    -customer_id                        The Google Ads customer ID.
    -conversion_action_id               The ID of the conversion action to upload to.
    -caller_id                          The caller ID from which this call was placed. Caller ID is expected to be
                                        in E.164 format with preceding '+' sign. e.g. "+18005550100".
    -call_start_date_time               The date and time at which the call occurred.
                                        The format is "yyyy-mm-dd hh:mm:ss+|-hh:mm", e.g. "2019-01-01 12:32:45-08:00".
    -conversion_date_time               The date and time of the conversion (should be after the call time).
                                        The format is "yyyy-mm-dd hh:mm:ss+|-hh:mm", e.g. "2019-01-01 12:32:45-08:00".
    -conversion_value                   The value of the conversion.
    -conversion_custom_variable_id      [optional] The ID of the conversion custom variable to associate with the upload.
    -conversion_custom_variable_value   [optional] The value of the conversion custom variable to associate with the upload.
	-ad_user_data_consent				[optional] The ad user data consent.
    
=cut
