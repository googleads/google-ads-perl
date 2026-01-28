#!/usr/bin/perl -w
#
# Copyright 2021, Google LLC
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
# Enhances a web conversion by uploading a ConversionAdjustment containing
# a hashed user identifier and an order ID.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Common::UserIdentifier;
use Google::Ads::GoogleAds::V23::Common::OfflineUserAddressInfo;
use Google::Ads::GoogleAds::V23::Enums::ConversionAdjustmentTypeEnum
  qw(ENHANCEMENT);
use Google::Ads::GoogleAds::V23::Enums::UserIdentifierSourceEnum
  qw(FIRST_PARTY);
use
  Google::Ads::GoogleAds::V23::Services::ConversionAdjustmentUploadService::ConversionAdjustment;
use
  Google::Ads::GoogleAds::V23::Services::ConversionAdjustmentUploadService::GclidDateTimePair;
use Google::Ads::GoogleAds::V23::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd         qw(abs_path);
use Digest::SHA qw(sha256_hex);

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
my $order_id             = "INSERT_ORDER_ID_HERE";
# Optional: Specify the conversion date/time and user agent.
my $conversion_date_time = undef;
my $user_agent           = undef;

sub upload_enhanced_conversions_for_web {
  my (
    $api_client, $customer_id,          $conversion_action_id,
    $order_id,   $conversion_date_time, $user_agent
  ) = @_;

  # [START add_user_identifiers]
  # Construct the enhancement adjustment.
  my $enhancement =
    Google::Ads::GoogleAds::V23::Services::ConversionAdjustmentUploadService::ConversionAdjustment
    ->new({
      adjustmentType => ENHANCEMENT
    });

  # Extract user email, phone, and address info from the raw data,
  # normalize and hash it, then wrap it in UserIdentifier objects.
  # Create a separate UserIdentifier object for each.
  # The data in this example is hardcoded, but in your application
  # you might read the raw data from an input file.
  #
  # IMPORTANT: Since the identifier attribute of UserIdentifier
  # (https://developers.google.com/google-ads/api/reference/rpc/latest/UserIdentifier)
  # is a oneof
  # (https://protobuf.dev/programming-guides/proto3/#oneof-features), you must set
  # only ONE of hashed_email, hashed_phone_number, mobile_id, third_party_user_id,
  # or address-info. Setting more than one of these attributes on the same UserIdentifier
  # will clear all the other members of the oneof. For example, the following code is
  # INCORRECT and will result in a UserIdentifier with ONLY a hashed_phone_number:
  #
  # my $incorrect_user_identifier = Google::Ads::GoogleAds::V23::Common::UserIdentifier->new({
  #   hashedEmail => '...',
  #   hashedPhoneNumber => '...',
  # });
  my $raw_record = {
    # Email address that includes a period (.) before the Gmail domain.
    email => 'alex.2@example.com',
    # Address that includes all four required elements: first name, last
    # name, country code, and postal code.
    firstName   => 'Alex',
    lastName    => 'Quinn',
    countryCode => 'US',
    postalCode  => '94045',
    # Phone number to be converted to E.164 format, with a leading '+' as
    # required.
    phone => '+1 800 5550102',
    # This example lets you input conversion details as arguments,
    # but in reality you might store this data alongside other user data,
    # so we include it in this sample user record.
    orderId            => $order_id,
    conversionActionId => $conversion_action_id,
    conversionDateTime => $conversion_date_time,
    currencyCode       => "USD",
    userAgent          => $user_agent,
  };
  my $user_identifiers = [];

  # Create a user identifier using the hashed email address, using the normalize
  # and hash method specifically for email addresses.
  my $hashed_email = normalize_and_hash_email_address($raw_record->{email});
  push(
    @$user_identifiers,
    Google::Ads::GoogleAds::V23::Common::UserIdentifier->new({
        hashedEmail => $hashed_email,
        # Optional: Specify the user identifier source.
        userIdentifierSource => FIRST_PARTY
      }));

  # Check if the record has a phone number, and if so, add a UserIdentifier for it.
  if (defined $raw_record->{phone}) {
    # Add the hashed phone number identifier to the list of UserIdentifiers.
    push(
      @$user_identifiers,
      Google::Ads::GoogleAds::V23::Common::UserIdentifier->new({
          hashedPhoneNumber => normalize_and_hash($raw_record->{phone}, 1)}));
  }

  # Confirm the record has all the required mailing address elements, and if so, add
  # a UserIdentifier for the mailing address.
  if (defined $raw_record->{firstName}) {
    my $required_keys = ["lastName", "countryCode", "postalCode"];
    my $missing_keys  = [];

    foreach my $key (@$required_keys) {
      if (!defined $raw_record->{$key}) {
        push(@$missing_keys, $key);
      }
    }

    if (@$missing_keys) {
      print
        "Skipping addition of mailing address information because the following"
        . "keys are missing: "
        . join(",", @$missing_keys);
    } else {
      push(
        @$user_identifiers,
        Google::Ads::GoogleAds::V23::Common::UserIdentifier->new({
            addressInfo =>
              Google::Ads::GoogleAds::V23::Common::OfflineUserAddressInfo->new({
                # First and last name must be normalized and hashed.
                hashedFirstName => normalize_and_hash($raw_record->{firstName}),
                hashedLastName  => normalize_and_hash($raw_record->{lastName}),
                # Country code and zip code are sent in plain text.
                countryCode => $raw_record->{countryCode},
                postalCode  => $raw_record->{postalCode},
              })}));
    }
  }

  # Add the user identifiers to the enhancement adjustment.
  $enhancement->{userIdentifiers} = $user_identifiers;
  # [END add_user_identifiers]

  # [START add_conversion_details]
  # Set the conversion action.
  $enhancement->{conversionAction} =
    Google::Ads::GoogleAds::V23::Utils::ResourceNames::conversion_action(
    $customer_id, $raw_record->{conversionActionId});

  # Set the order ID. Enhancements MUST use order ID instead of GCLID date/time pair.
  $enhancement->{orderId} = $raw_record->{orderId};

  # Set the conversion date and time if provided. Providing this value is optional
  # but recommended.
  if (defined $raw_record->{conversionDateTime}) {
    $enhancement->{gclidDateTimePair} =
      Google::Ads::GoogleAds::V23::Services::ConversionAdjustmentUploadService::GclidDateTimePair
      ->new({
        conversionDateTime => $raw_record->{conversionDateTime}});
  }

  # Set the user agent if provided. This should match the user agent of the
  # request that sent the original conversion so the conversion and its enhancement
  # are either both attributed as same-device or both attributed as cross-device.
  if (defined $raw_record->{userAgent}) {
    $enhancement->{userAgent} = $raw_record->{userAgent};
  }
  # [END add_conversion_details]

  # [START upload_enhancement]
  # Upload the enhancement adjustment. Partial failure should always be set to true.
  #
  # NOTE: This request contains a single adjustment as a demonstration.
  # However, if you have multiple adjustments to upload, it's best to
  # upload multiple adjustments per request instead of sending a separate
  # request per adjustment. See the following for per-request limits:
  # https://developers.google.com/google-ads/api/docs/best-practices/quotas#conversion_adjustment_upload_service
  my $response =
    $api_client->ConversionAdjustmentUploadService()
    ->upload_conversion_adjustments({
      customerId            => $customer_id,
      conversionAdjustments => [$enhancement],
      # Enable partial failure (must be true).
      partialFailure => "true"
    });
  # [END upload_enhancement]

  # Print any partial errors returned.
  # To review the overall health of your recent uploads, see:
  # https://developers.google.com/google-ads/api/docs/conversions/upload-summaries
  if ($response->{partialFailureError}) {
    printf "Partial error encountered: '%s'.\n",
      $response->{partialFailureError}{message};
  } else {
    # Print the result.
    my $result = $response->{results}[0];
    printf "Uploaded conversion adjustment of '%s' for order ID '%s'.\n",
      $result->{conversionAction}, $result->{orderId};
  }

  return 1;
}

# Normalizes and hashes a string value.
# Private customer data must be hashed during upload, as described at
# https://support.google.com/google-ads/answer/7474263.
# [START normalize_and_hash]
sub normalize_and_hash {
  my $value                    = shift;
  my $trim_intermediate_spaces = shift;

  if ($trim_intermediate_spaces) {
    $value =~ s/\s+//g;
  } else {
    $value =~ s/^\s+|\s+$//g;
  }
  return sha256_hex(lc $value);
}

# Returns the result of normalizing and hashing an email address. For this use
# case, Google Ads requires removal of any '.' characters preceding 'gmail.com'
# or 'googlemail.com'.
sub normalize_and_hash_email_address {
  my $email_address = shift;

  my $normalized_email = lc $email_address;
  my @email_parts      = split('@', $normalized_email);
  if (scalar @email_parts > 1
    && $email_parts[1] =~ /^(gmail|googlemail)\.com\s*/)
  {
    # Remove any '.' characters from the portion of the email address before the
    # domain if the domain is 'gmail.com' or 'googlemail.com'.
    $email_parts[0] =~ s/\.//g;
    $normalized_email = sprintf '%s@%s', $email_parts[0], $email_parts[1];
  }
  return normalize_and_hash($normalized_email, 1);
}
# [END normalize_and_hash]

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
  "conversion_date_time=s" => \$conversion_date_time,
  "user_agent=s"           => \$user_agent
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $conversion_action_id, $order_id);

# Call the example.
upload_enhanced_conversions_for_web($api_client, $customer_id =~ s/-//gr,
  $conversion_action_id, $order_id, $conversion_date_time, $user_agent);

=pod

=head1 NAME

upload_enhanced_conversions_for_web

=head1 DESCRIPTION

Adjusts an existing conversion by supplying user identifiers so Google can
enhance the conversion value.

=head1 SYNOPSIS

upload_enhanced_conversions_for_web.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -conversion_action_id       The conversion action ID associated with this conversion.
    -order_id                   The unique order ID (transaction ID) of the conversion.
    -conversion_date_time       [optional] The date time at which the conversion with the specified order ID
                                occurred. Must be after the click time, and must include the time zone offset.
                                The format is "yyyy-mm-dd hh:mm:ss+|-hh:mm", e.g. "2019-01-01 12:32:45-08:00".
                                Setting this field is optional, but recommended.
    -user_agent                 [optional] The HTTP user agent of the conversion.

=cut
