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
# Adjusts an existing conversion by supplying user identifiers so Google can
# enhance the conversion value.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V14::Common::UserIdentifier;
use Google::Ads::GoogleAds::V14::Common::OfflineUserAddressInfo;
use Google::Ads::GoogleAds::V14::Enums::ConversionAdjustmentTypeEnum
  qw(ENHANCEMENT);
use Google::Ads::GoogleAds::V14::Enums::UserIdentifierSourceEnum
  qw(FIRST_PARTY);
use
  Google::Ads::GoogleAds::V14::Services::ConversionAdjustmentUploadService::ConversionAdjustment;
use
  Google::Ads::GoogleAds::V14::Services::ConversionAdjustmentUploadService::GclidDateTimePair;
use Google::Ads::GoogleAds::V14::Utils::ResourceNames;

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

# [START upload_conversion_enhancement]
sub upload_conversion_enhancement {
  my (
    $api_client, $customer_id,          $conversion_action_id,
    $order_id,   $conversion_date_time, $user_agent
  ) = @_;

  # [START create_adjustment]
  # Construct the enhancement adjustment.
  my $enhancement =
    Google::Ads::GoogleAds::V14::Services::ConversionAdjustmentUploadService::ConversionAdjustment
    ->new({
      conversionAction =>
        Google::Ads::GoogleAds::V14::Utils::ResourceNames::conversion_action(
        $customer_id, $conversion_action_id
        ),
      adjustmentType => ENHANCEMENT,
      # Enhancements MUST use order ID instead of GCLID date/time pair.
      orderId => $order_id
    });

  # Set the conversion date and time if provided. Providing this value is optional
  # but recommended.
  if (defined $conversion_date_time) {
    $enhancement->{gclidDateTimePair} =
      Google::Ads::GoogleAds::V14::Services::ConversionAdjustmentUploadService::GclidDateTimePair
      ->new({
        conversionDateTime => $conversion_date_time
      });
  }

  # Add user identifiers, hashing where required.

  # Create a user identifier using sample values for the user address.
  my $address_identifier =
    Google::Ads::GoogleAds::V14::Common::UserIdentifier->new({
      addressInfo =>
        Google::Ads::GoogleAds::V14::Common::OfflineUserAddressInfo->new({
          hashedFirstName     => normalize_and_hash("Dana"),
          hashedLastName      => normalize_and_hash("Quinn"),
          hashedStreetAddress => normalize_and_hash("1600 Amphitheatre Pkwy"),
          city                => "Mountain View",
          state               => "CA",
          postalCode          => "94043",
          countryCode         => "US"
        }
        ),
      # Optional: Specify the user identifier source.
      userIdentifierSource => FIRST_PARTY
    });

  # Create a user identifier using the hashed email address.
  my $email_identifier =
    Google::Ads::GoogleAds::V14::Common::UserIdentifier->new({
      userIdentifierSource => FIRST_PARTY,
      # Use the normalize and hash method specifically for email addresses.
      hashedEmail => normalize_and_hash_email_address('dana@example.com')});

  # Add the user identifiers to the enhancement adjustment.
  $enhancement->{userIdentifiers} = [$address_identifier, $email_identifier];

  # Set optional fields where a value was provided.

  if (defined $user_agent) {
    # Set the user agent. This should match the user agent of the request that
    # sent the original conversion so the conversion and its enhancement are
    # either both attributed as same-device or both attributed as cross-device.
    $enhancement->{userAgent} = $user_agent;
  }

  # Upload the enhancement adjustment. Partial failure should always be set to true.
  my $response =
    $api_client->ConversionAdjustmentUploadService()
    ->upload_conversion_adjustments({
      customerId            => $customer_id,
      conversionAdjustments => [$enhancement],
      # Enable partial failure (must be true).
      partialFailure => "true"
    });

  # Print any partial errors returned.
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
# [END upload_conversion_enhancement]

# Normalizes and hashes a string value.
# Private customer data must be hashed during upload, as described at
# https://support.google.com/google-ads/answer/7474263.
# [START normalize_and_hash]
sub normalize_and_hash {
  my $value = shift;

  $value =~ s/^\s+|\s+$//g;
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
  return normalize_and_hash($normalized_email);
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
upload_conversion_enhancement($api_client, $customer_id =~ s/-//gr,
  $conversion_action_id, $order_id, $conversion_date_time, $user_agent);

=pod

=head1 NAME

upload_conversion_enhancement

=head1 DESCRIPTION

Adjusts an existing conversion by supplying user identifiers so Google can
enhance the conversion value.

=head1 SYNOPSIS

upload_conversion_enhancement.pl [options]

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
