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
# Uploads an enhanced conversion for leads by uploading a ClickConversion
# with hashed, first-party user-provided data from your website lead forms.
# This includes user identifiers, and optionally a click ID and order ID.
# With this information, Google can tie the conversion to the ad that drove
# the lead.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Common::Consent;
use Google::Ads::GoogleAds::V21::Common::UserIdentifier;
use Google::Ads::GoogleAds::V21::Enums::UserIdentifierSourceEnum
  qw(FIRST_PARTY);
use
  Google::Ads::GoogleAds::V21::Services::ConversionUploadService::ClickConversion;
use
  Google::Ads::GoogleAds::V21::Services::ConversionUploadService::SessionAttributeKeyValuePair;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd         qw(abs_path);
use Digest::SHA qw(sha256_hex);

sub upload_enhanced_conversions_for_leads {
  my (
    $api_client,                 $customer_id,
    $conversion_action_id,       $conversion_date_time,
    $conversion_value,           $order_id,
    $gclid,                      $ad_user_data_consent,
    $session_attributes_encoded, $session_attributes_hash
  ) = @_;

  # [START add_user_identifiers]
  # Create an empty click conversion.
  my $click_conversion =
    Google::Ads::GoogleAds::V21::Services::ConversionUploadService::ClickConversion
    ->new({});

  # Extract user email and phone from the raw data, normalize and hash it,
  # then wrap it in UserIdentifier objects. Create a separate UserIdentifier
  # object for each.
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
  # my $incorrect_user_identifier = Google::Ads::GoogleAds::V21::Common::UserIdentifier->new({
  #   hashedEmail => '...',
  #   hashedPhoneNumber => '...',
  # });
  my $raw_record = {
    # Email address that includes a period (.) before the Gmail domain.
    email => 'alex.2@example.com',
    # Phone number to be converted to E.164 format, with a leading '+' as
    # required.
    phone => '+1 800 5550102',
    # This example lets you input conversion details as arguments,
    # but in reality you might store this data alongside other user data,
    # so we include it in this sample user record.
    orderId            => $order_id,
    gclid              => $gclid,
    conversionActionId => $conversion_action_id,
    conversionDateTime => $conversion_date_time,
    conversionValue    => $conversion_value,
    currencyCode       => "USD",
    adUserDataConsent  => $ad_user_data_consent
  };
  my $user_identifiers = [];

  # Create a user identifier using the hashed email address, using the normalize
  # and hash method specifically for email addresses.
  my $hashed_email = normalize_and_hash_email_address($raw_record->{email});
  push(
    @$user_identifiers,
    Google::Ads::GoogleAds::V21::Common::UserIdentifier->new({
        hashedEmail => $hashed_email,
        # Optional: Specify the user identifier source.
        userIdentifierSource => FIRST_PARTY
      }));

  # Create a user identifier using normalized and hashed phone info.
  my $hashed_phone = normalize_and_hash($raw_record->{phone});
  push(
    @$user_identifiers,
    Google::Ads::GoogleAds::V21::Common::UserIdentifier->new({
        hashedPhone => $hashed_phone,
        # Optional: Specify the user identifier source.
        userIdentifierSource => FIRST_PARTY
      }));

  # Add the user identifiers to the conversion.
  $click_conversion->{userIdentifiers} = $user_identifiers;
  # [END add_user_identifiers]

  # [START add_conversion_details]
  # Add details of the conversion.
  $click_conversion->{conversionAction} =
    Google::Ads::GoogleAds::V21::Utils::ResourceNames::conversion_action(
    $customer_id, $raw_record->{conversionActionId});
  $click_conversion->{conversionDateTime} = $raw_record->{conversionDateTime};
  $click_conversion->{conversionValue}    = $raw_record->{conversionValue};
  $click_conversion->{currencyCode}       = $raw_record->{currencyCode};

  # Set the order ID if provided.
  if (defined $raw_record->{orderId}) {
    $click_conversion->{orderId} = $raw_record->{orderId};
  }

  # Set the Google click ID (gclid) if provided.
  if (defined $raw_record->{gclid}) {
    $click_conversion->{gclid} = $raw_record->{gclid};
  }

  # Set the consent information, if provided.
  if (defined $raw_record->{adUserDataConsent}) {
    $click_conversion->{consent} =
      Google::Ads::GoogleAds::V21::Common::Consent->new({
        adUserData => $raw_record->{adUserDataConsent}});
  }

  # [START add_session_attributes]
  # Set one of the session_attributes_encoded or session_attributes_key_value_pairs
  # fields if either are provided.
  if (defined $session_attributes_encoded) {
    $click_conversion->{sessionAttributesEncoded} = $session_attributes_encoded;
  } elsif (defined $session_attributes_hash) {
    while (my ($key, $value) = each %$session_attributes_hash) {
      my $pair =
        Google::Ads::GoogleAds::V21::Services::ConversionUploadService::SessionAttributeKeyValuePair
        ->new({sessionAttributeKey => $key, sessionAttributeValue => $value});
      push @{$click_conversion->{sessionAttributesKeyValuePairs}{keyValuePairs}
      }, $pair;
    }
  }
  # [END add_session_attributes]
  # [END add_conversion_details]

  # [START upload_conversion]
  # Upload the click conversion. Partial failure should always be set to true.
  #
  # NOTE: This request contains a single conversion as a demonstration.
  # However, if you have multiple conversions to upload, it's best to
  # upload multiple conversions per request instead of sending a separate
  # request per conversion. See the following for per-request limits:
  # https://developers.google.com/google-ads/api/docs/best-practices/quotas#conversion_upload_service
  my $response =
    $api_client->ConversionUploadService()->upload_click_conversions({
      customerId  => $customer_id,
      conversions => [$click_conversion],
      # Enable partial failure (must be true).
      partialFailure => "true"
    });
  # [END upload_conversion]

  # Print any partial errors returned.
  # To review the overall health of your recent uploads, see:
  # https://developers.google.com/google-ads/api/docs/conversions/upload-summaries
  if ($response->{partialFailureError}) {
    printf "Partial error encountered: '%s'.\n",
      $response->{partialFailureError}{message};
  }

  # Print the result.
  my $result = $response->{results}[0];
  # Only print valid results.
  if (defined $result->{conversionDateTime}) {
    printf "Uploaded conversion that occurred at '%s' to '%s'.\n",
      $result->{conversionDateTime},
      $result->{conversionAction};
  }

  return 1;
}

# Normalizes and hashes a string value.
# Private customer data must be hashed during upload, as described at
# https://support.google.com/google-ads/answer/7474263.
# [START normalize_and_hash]
sub normalize_and_hash {
  my $value = shift;

  # Removes leading, trailing, and intermediate spaces.
  $value =~ s/\s+//g;
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

my $customer_id;
my $conversion_action_id;
my $conversion_date_time;
my $conversion_value;
my $order_id;
my $gclid;
my $ad_user_data_consent;
my $session_attributes_encoded;
my $session_attributes_hash;
my $session_attributes_key_value_pairs;

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s"                        => \$customer_id,
  "conversion_action_id=i"               => \$conversion_action_id,
  "conversion_date_time=s"               => \$conversion_date_time,
  "conversion_value=f"                   => \$conversion_value,
  "order_id=s"                           => \$order_id,
  "gclid=s"                              => \$gclid,
  "ad_user_data_consent=s"               => \$ad_user_data_consent,
  "session_attributes_encoded=s"         => \$session_attributes_encoded,
  "session_attributes_key_value_pairs=s" =>
    \$session_attributes_key_value_pairs,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params(
  $customer_id,          $conversion_action_id,
  $conversion_date_time, $conversion_value
  );

if ( defined $session_attributes_encoded
  && defined $session_attributes_key_value_pairs)
{
  die
"session_attributes_encoded and session_attributes_key_value_pairs cannot be passed in at the same time.";
}

# Convert session_attributes_key_value_pairs to a hash.
foreach my $key_value_pair (split ' ', $session_attributes_key_value_pairs) {
  my ($key, $value) = split('=', $key_value_pair);
  $session_attributes_hash->{$key} = $value;
}

# Call the example.
upload_enhanced_conversions_for_leads(
  $api_client,                 $customer_id =~ s/-//gr,
  $conversion_action_id,       $conversion_date_time,
  $conversion_value,           $order_id,
  $gclid,                      $ad_user_data_consent,
  $session_attributes_encoded, $session_attributes_hash
);

=pod

=head1 NAME

upload_enhanced_conversions_for_leads

=head1 DESCRIPTION

Uploads an enhanced conversion for leads by uploading a ClickConversion
with hashed, first-party user-provided data from your website lead forms.

=head1 SYNOPSIS

upload_enhanced_conversions_for_leads.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -conversion_action_id       The conversion action ID associated with this conversion.
    -conversion_date_time       The date time at which the conversion occurred.
                                Must be after the click time, and must include the time zone offset.
                                The format is 'yyyy-mm-dd hh:mm:ss+|-hh:mm', e.g. '2019-01-01 12:32:45-08:00'.
    -conversion_value           The value of the conversion.
    -order_id                   [optional] The unique ID (transaction ID) of the conversion. We recommend including if available.
    -gclid                      [optional] The Google click ID associated with the conversion. We recommend including if available.
	-ad_user_data_consent		[optional] The ad user data consent for the click.
-session_attributes_encoded     [optional]
-session_attributes_key_value_pairs [optional] A space-delimited list of session attribute key value pairs. Each pair should be separated by an equal sign, for example: "gad_campaignid=12345 gad_source=1"

=cut
