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
# Uploads a conversion using hashed email address instead of GCLID.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V9::Common::UserIdentifier;
use Google::Ads::GoogleAds::V9::Enums::UserIdentifierSourceEnum qw(FIRST_PARTY);
use
  Google::Ads::GoogleAds::V9::Services::ConversionUploadService::ClickConversion;
use Google::Ads::GoogleAds::V9::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
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
my $email_address        = "INSERT_EMAIL_ADDRESS_HERE";
my $conversion_date_time = "INSERT_CONVERSION_DATE_TIME_HERE";
my $conversion_value     = "INSERT_CONVERSION_VALUE_HERE";
# Optional: Specify the unique order ID for the click conversion.
my $order_id = undef;

# [START upload_conversion_with_identifiers]
sub upload_conversion_with_identifiers {
  my ($api_client, $customer_id,
    $conversion_action_id, $email_address, $conversion_date_time,
    $conversion_value,     $order_id)
    = @_;

  # [START create_conversion]
  # Construct the click conversion.
  my $click_conversion =
    Google::Ads::GoogleAds::V9::Services::ConversionUploadService::ClickConversion
    ->new({
      conversionAction =>
        Google::Ads::GoogleAds::V9::Utils::ResourceNames::conversion_action(
        $customer_id, $conversion_action_id
        ),
      conversionDateTime => $conversion_date_time,
      conversionValue    => $conversion_value,
      currencyCode       => "USD"
    });

  # Set the order ID if provided.
  if (defined $order_id) {
    $click_conversion->{orderId} = $order_id;
  }

  # Create a user identifier using the hashed email address, using the normalize
  # and hash method specifically for email addresses.
  # If using a phone number, use the normalize_and_hash() method instead.
  my $hashed_email    = normalize_and_hash_email_address($email_address);
  my $user_identifier = Google::Ads::GoogleAds::V9::Common::UserIdentifier->new(
    {
      hashedEmail => $hashed_email,
      # Optional: Specify the user identifier source.
      userIdentifierSource => FIRST_PARTY
    });

  # Add the user identifier to the conversion.
  $click_conversion->{userIdentifiers} = [$user_identifier];
  # [END create_conversion]

  # Upload the click conversion. Partial failure should always be set to true.
  my $response =
    $api_client->ConversionUploadService()->upload_click_conversions({
      customerId  => $customer_id,
      conversions => [$click_conversion],
      # Enable partial failure (must be true).
      partialFailure => "true"
    });

  # Print any partial errors returned.
  if ($response->{partialFailureError}) {
    printf "Partial error encountered: '%s'.\n",
      $response->{partialFailureError}{message};
  }

  # Print the result.
  my $result = $response->{results}[0];
  # Only print valid results.
  if (defined $result->{conversionDateTime}) {
    printf "Uploaded conversion that occurred at '%s' " .
      "to '%s'.\n",
      $result->{conversionDateTime},
      $result->{conversionAction};
  }

  return 1;
}
# [END upload_conversion_with_identifiers]

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
  "email_address=s"        => \$email_address,
  "conversion_date_time=s" => \$conversion_date_time,
  "conversion_value=f"     => \$conversion_value,
  "order_id=s"             => \$order_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params(
  $customer_id,          $conversion_action_id, $email_address,
  $conversion_date_time, $conversion_value
  );

# Call the example.
upload_conversion_with_identifiers($api_client, $customer_id =~ s/-//gr,
  $conversion_action_id, $email_address, $conversion_date_time,
  $conversion_value,     $order_id);

=pod

=head1 NAME

upload_conversion_with_identifiers

=head1 DESCRIPTION

Uploads a conversion using hashed email address instead of GCLID.

=head1 SYNOPSIS

upload_conversion_with_identifiers.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -conversion_action_id       The conversion action ID associated with this conversion.
    -email_address              The email address for the conversion.
    -conversion_date_time       The date time at which the conversion occurred.
                                Must be after the click time, and must include the time zone offset.
                                The format is 'yyyy-mm-dd hh:mm:ss+|-hh:mm', e.g. '2019-01-01 12:32:45-08:00'.
    -conversion_value           The value of the conversion.
    -order_id                   [optional] The unique ID (transaction ID) of the conversion.

=cut
