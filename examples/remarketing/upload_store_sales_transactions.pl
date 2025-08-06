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
# This example uploads offline data for store sales transactions.
#
# This feature is only available to allowlisted accounts.
# See https://support.google.com/google-ads/answer/7620302 for more details.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";

use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Resources::OfflineUserDataJob;
use Google::Ads::GoogleAds::V21::Common::Consent;
use Google::Ads::GoogleAds::V21::Common::ItemAttribute;
use Google::Ads::GoogleAds::V21::Common::OfflineUserAddressInfo;
use Google::Ads::GoogleAds::V21::Common::StoreSalesMetadata;
use Google::Ads::GoogleAds::V21::Common::StoreSalesThirdPartyMetadata;
use Google::Ads::GoogleAds::V21::Common::TransactionAttribute;
use Google::Ads::GoogleAds::V21::Common::UserData;
use Google::Ads::GoogleAds::V21::Common::UserIdentifier;
use Google::Ads::GoogleAds::V21::Enums::OfflineUserDataJobTypeEnum
  qw(STORE_SALES_UPLOAD_FIRST_PARTY STORE_SALES_UPLOAD_THIRD_PARTY);
use
  Google::Ads::GoogleAds::V21::Services::OfflineUserDataJobService::OfflineUserDataJobOperation;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd         qw(abs_path);
use Digest::SHA qw(sha256_hex);

use constant POLL_FREQUENCY_SECONDS => 1;
use constant POLL_TIMEOUT_SECONDS   => 60;
# If uploading data with custom key and values, specify the value.
use constant CUSTOM_VALUE => "INSERT_CUSTOM_VALUE_HERE";

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

# Optional: Specify the type of user data in the job (first or third party).
# If you have an official store sales partnership with Google, use
# STORE_SALES_UPLOAD_THIRD_PARTY.
# Otherwise, use STORE_SALES_UPLOAD_FIRST_PARTY or omit this parameter.
my $offline_user_data_job_type = STORE_SALES_UPLOAD_FIRST_PARTY;
# Optional: Specify an external ID below to identify the offline user data job.
# If none is specified, this example will create an external ID.
my $external_id = undef;
# Optional: Specify the custom key if uploading data with custom key and values.
my $custom_key = undef;
# Optional: Specify an advertiser upload date time for third party data.
my $advertiser_upload_date_time = undef;
# Optional: Specify a bridge map version ID for third party data.
my $bridge_map_version_id = undef;
# Optional: Specify a partner ID for third party data.
my $partner_id = undef;
# Optional: Specify a unique identifier of a product, either the Merchant Center
# Item ID or Global Trade Item Number (GTIN). Only required if uploading with
# item attributes.
my $item_id = undef;
# Optional: Specify a Merchant Center Account ID. Only required if uploading
# with item attributes.
my $merchant_center_account_id = undef;
# Optional: Specify a two-letter country code of the location associated with the
# feed where your items are uploaded. Only required if uploading with item
# attributes.
my $country_code = undef;
# Optional: Specify a two-letter language code of the language associated with
# the feed where your items are uploaded. Only required if uploading with item
# attributes.
my $language_code = undef;
# Optional: Specify a number of items sold. Only required if uploading with item
# attributes.
my $quantity = 1;
# Optional: Specify the ad personalization consent status.
my $ad_personalization_consent = undef;
# Optional: Specify the ad user data consent status.
my $ad_user_data_consent = undef;

sub upload_store_sales_transactions {
  my (
    $api_client,                  $customer_id,
    $offline_user_data_job_type,  $conversion_action_id,
    $external_id,                 $custom_key,
    $advertiser_upload_date_time, $bridge_map_version_id,
    $partner_id,                  $item_id,
    $merchant_center_account_id,  $country_code,
    $language_code,               $quantity,
    $$ad_personalization_consent, $ad_user_data_consent
  ) = @_;

  my $offline_user_data_job_service = $api_client->OfflineUserDataJobService();

  # Create an offline user data job for uploading transactions.
  my $offline_user_data_job_resource_name = create_offline_user_data_job(
    $offline_user_data_job_service, $customer_id,
    $offline_user_data_job_type,    $external_id,
    $custom_key,                    $advertiser_upload_date_time,
    $bridge_map_version_id,         $partner_id
  );

  # Add transactions to the job.
  add_transactions_to_offline_user_data_job(
    $offline_user_data_job_service,       $customer_id,
    $offline_user_data_job_resource_name, $conversion_action_id,
    $custom_key,                          $item_id,
    $merchant_center_account_id,          $country_code,
    $language_code,                       $quantity,
  );

  # Issue an asynchronous request to run the offline user data job.
  my $operation_response = $offline_user_data_job_service->run({
    resourceName => $offline_user_data_job_resource_name
  });
  print "Asynchronous request to execute the added operations started.\n";
  print "Waiting until operation completes.\n";

  # poll_until_done() implements a default back-off policy for retrying. You can
  # tweak the parameters like the poll timeout seconds by passing them to the
  # poll_until_done() method. Visit the OperationService.pm file for more details.
  my $lro = $api_client->OperationService()->poll_until_done({
    name                 => $operation_response->{name},
    pollFrequencySeconds => POLL_FREQUENCY_SECONDS,
    pollTimeoutSeconds   => POLL_TIMEOUT_SECONDS
  });
  if ($lro->{done}) {
    printf "Offline user data job with resource name '%s' has finished.\n",
      $offline_user_data_job_resource_name;
  } else {
    printf
      "Offline user data job with resource name '%s' still pending after %d " .
      "seconds, continuing the execution of the code example anyway.\n",
      $offline_user_data_job_resource_name,
      POLL_TIMEOUT_SECONDS;
  }

  return 1;
}

# Creates an offline user data job for uploading store sales transactions.
# Returns the resource name of the created job.
sub create_offline_user_data_job {
  my (
    $offline_user_data_job_service, $customer_id,
    $offline_user_data_job_type,    $external_id,
    $custom_key,                    $advertiser_upload_date_time,
    $bridge_map_version_id,         $partner_id
  ) = @_;

  # TIP: If you are migrating from the AdWords API, please note that Google Ads
  # API uses the term "fraction" instead of "rate". For example, loyaltyRate in
  # the AdWords API is called loyaltyFraction in the Google Ads API.
  my $store_sales_metadata =
    # Please refer to https://support.google.com/google-ads/answer/7506124 for
    # additional details.
    Google::Ads::GoogleAds::V21::Common::StoreSalesMetadata->new({
      # Set the fraction of your overall sales that you (or the advertiser,
      # in the third party case) can associate with a customer (email, phone
      # number, address, etc.) in your database or loyalty program.
      # For example, set this to 0.7 if you have 100 transactions over 30
      # days, and out of those 100 transactions, you can identify 70 by an
      # email address or phone number.
      loyaltyFraction => 0.7,
      # Set the fraction of sales you're uploading out of the overall sales
      # that you (or the advertiser, in the third party case) can associate
      # with a customer. In most cases, you will set this to 1.0.
      # Continuing the example above for loyalty fraction, a value of 1.0 here
      # indicates that you are uploading all 70 of the transactions that can
      # be identified by an email address or phone number.
      transactionUploadFraction => 1.0
    });

  # Apply the custom key if provided.
  $store_sales_metadata->{customKey} = $custom_key if defined $custom_key;

  if ($offline_user_data_job_type eq STORE_SALES_UPLOAD_THIRD_PARTY) {
    # Create additional metadata required for uploading third party data.
    my $store_sales_third_party_metadata =
      Google::Ads::GoogleAds::V21::Common::StoreSalesThirdPartyMetadata->new({
        # The date/time must be in the format "yyyy-MM-dd hh:mm:ss".
        advertiserUploadDateTime => $advertiser_upload_date_time,

        # Set the fraction of transactions you received from the advertiser
        # that have valid formatting and values. This captures any transactions
        # the advertiser provided to you but which you are unable to upload to
        # Google due to formatting errors or missing data.
        # In most cases, you will set this to 1.0.
        validTransactionFraction => 1.0,
        # Set the fraction of valid transactions (as defined above) you received
        # from the advertiser that you (the third party) have matched to an
        # external user ID on your side.
        # In most cases, you will set this to 1.0.
        partnerMatchFraction => 1.0,

        # Set the fraction of transactions you (the third party) are uploading
        # out of the transactions you received from the advertiser that meet
        # both of the following criteria:
        # 1. Are valid in terms of formatting and values. See valid transaction
        # fraction above.
        # 2. You matched to an external user ID on your side. See partner match
        # fraction above.
        # In most cases, you will set this to 1.0.
        partnerUploadFraction => 1.0,

        # Please speak with your Google representative to get the values to use
        # for the bridge map version and partner IDs.

        # Set the version of partner IDs to be used for uploads.
        bridgeMapVersionId => $bridge_map_version_id,
        # Set the third party partner ID uploading the transactions.
        partnerId => $partner_id,
      });
    $store_sales_metadata->{thirdPartyMetadata} =
      $store_sales_third_party_metadata;
  }

  # Create a new offline user data job.
  my $offline_user_data_job =
    Google::Ads::GoogleAds::V21::Resources::OfflineUserDataJob->new({
      type               => $offline_user_data_job_type,
      storeSalesMetadata => $store_sales_metadata,
      external_id        => $external_id,
    });

  # Issue a request to create the offline user data job.
  my $create_offline_user_data_job_response =
    $offline_user_data_job_service->create({
      customerId => $customer_id,
      job        => $offline_user_data_job
    });
  my $offline_user_data_job_resource_name =
    $create_offline_user_data_job_response->{resourceName};
  printf
    "Created an offline user data job with resource name: '%s'.\n",
    $offline_user_data_job_resource_name;
  return $offline_user_data_job_resource_name;
}

# Adds operations to the job for a set of sample transactions.
sub add_transactions_to_offline_user_data_job {
  my (
    $offline_user_data_job_service,       $customer_id,
    $offline_user_data_job_resource_name, $conversion_action_id,
    $custom_key,                          $item_id,
    $merchant_center_account_id,          $country_code,
    $language_code,                       $quantity
  ) = @_;

  # Construct the operation for each transaction.
  my $user_data_job_operations = build_offline_user_data_job_operations(
    $customer_id,                $conversion_action_id,
    $custom_key,                 $item_id,
    $merchant_center_account_id, $country_code,
    $language_code,              $quantity,
    $ad_personalization_consent, $ad_user_data_consent
  );

  # [START enable_warnings_1]
  # Issue a request to add the operations to the offline user data job.
  my $response = $offline_user_data_job_service->add_operations({
    resourceName         => $offline_user_data_job_resource_name,
    enablePartialFailure => "true",
    # Enable warnings (optional).
    enableWarnings => "true",
    operations     => $user_data_job_operations
  });
  # [END enable_warnings_1]

  # Print the status message if any partial failure error is returned.
  # Note: The details of each partial failure error are not printed here, you
  # can refer to the example handle_partial_failure.pl to learn more.
  if ($response->{partialFailureError}) {
    # Extract the partial failure from the response status.
    my $partial_failure = $response->{partialFailureError}{details}[0];
    foreach my $error (@{$partial_failure->{errors}}) {
      printf "Partial failure occurred: '%s'\n", $error->{message};
    }
    printf "Encountered %d partial failure errors while adding %d operations " .
      "to the offline user data job: '%s'. Only the successfully added " .
      "operations will be executed when the job runs.\n",
      scalar @{$partial_failure->{errors}}, scalar @$user_data_job_operations,
      $response->{partialFailureError}{message};
  } else {
    printf "Successfully added %d operations to the offline user data job.\n",
      scalar @$user_data_job_operations;
  }

  # [START enable_warnings_2]
  # Print the number of warnings if any warnings are returned. You can access
  # details of each warning using the same approach you'd use for partial failure
  # errors.
  if ($response->{warning}) {
    # Extract the warnings from the response status.
    my $warnings_failure = $response->{warning}{details}[0];
    printf "Encountered %d warning(s).\n",
      scalar @{$warnings_failure->{errors}};
  }
  # [END enable_warnings_2]
}

# Creates a list of offline user data job operations for sample transactions.
# Returns a list of operations.
sub build_offline_user_data_job_operations {
  my (
    $customer_id,                $conversion_action_id,
    $custom_key,                 $item_id,
    $merchant_center_account_id, $country_code,
    $language_code,              $quantity,
    $ad_personalization_consent, $ad_user_data_consent
  ) = @_;

  # Create the first transaction for upload based on an email address and state.
  my $user_data_with_email_address =
    Google::Ads::GoogleAds::V21::Common::UserData->new({
      userIdentifiers => [
        Google::Ads::GoogleAds::V21::Common::UserIdentifier->new({
            # Hash normalized email addresses based on SHA-256 hashing algorithm.
            hashedEmail => normalize_and_hash('dana@example.com')}
        ),
        Google::Ads::GoogleAds::V21::Common::UserIdentifier->new({
            addressInfo =>
              Google::Ads::GoogleAds::V21::Common::OfflineUserAddressInfo->new({
                state => "NY"
              })})
      ],
      transactionAttribute =>
        Google::Ads::GoogleAds::V21::Common::TransactionAttribute->new({
          conversionAction =>
            Google::Ads::GoogleAds::V21::Utils::ResourceNames::conversion_action(
            $customer_id, $conversion_action_id
            ),
          currencyCode => "USD",
          # Convert the transaction amount from $200 USD to micros.
          transactionAmountMicros => 200000000,
          # Specify the date and time of the transaction. The format is
          # "YYYY-MM-DD HH:MM:SS[+HH:MM]", where [+HH:MM] is an optional timezone
          # offset from UTC. If the offset is absent, the API will use the
          # account's timezone as default. Examples: "2018-03-05 09:15:00"
          # or "2018-02-01 14:34:30+03:00".
          transactionDateTime => "2020-05-01 23:52:12",
        })});

  # Add consent information if specified.
  if ($ad_personalization_consent or $ad_user_data_consent) {
    # Specify whether user consent was obtained for the data you are uploading.
    # See https://www.google.com/about/company/user-consent-policy for details.
    $user_data_with_email_address->{consent} =
      Google::Ads::GoogleAds::V21::Common::Consent({
        adPersonalization => $ad_personalization_consent,
        adUserData        => $ad_user_data_consent
      });
  }

  # Optional: If uploading data with custom key and values, also assign the
  # custom value.
  if (defined($custom_key)) {
    $user_data_with_email_address->{transactionAttribute}{customValue} =
      CUSTOM_VALUE;
  }

  # Create the second transaction for upload based on a physical address.
  my $user_data_with_physical_address =
    Google::Ads::GoogleAds::V21::Common::UserData->new({
      userIdentifiers => [
        Google::Ads::GoogleAds::V21::Common::UserIdentifier->new({
            addressInfo =>
              Google::Ads::GoogleAds::V21::Common::OfflineUserAddressInfo->new({
                # First and last name must be normalized and hashed.
                hashedFirstName => normalize_and_hash("Dana"),
                hashedLastName  => normalize_and_hash("Quinn"),
                # Country code and zip code are sent in plain text.
                countryCode => "US",
                postalCode  => "10011"
              })})
      ],
      transactionAttribute =>
        Google::Ads::GoogleAds::V21::Common::TransactionAttribute->new({
          conversionAction =>
            Google::Ads::GoogleAds::V21::Utils::ResourceNames::conversion_action(
            $customer_id,
            $conversion_action_id
            ),
          currencyCode => "EUR",
          # Convert the transaction amount from 450 EUR to micros.
          transactionAmountMicros => 450000000,
          # Specify the date and time of the transaction. This date and time
          # will be interpreted by the API using the Google Ads customer's
          # time zone. The date/time must be in the format
          # "yyyy-MM-dd hh:mm:ss".
          transactionDateTime => "2020-05-14 19:07:02",
        })});

  # Optional: If uploading data with item attributes, also assign these values
  # in the transaction attribute.
  if (defined($item_id)) {
    $user_data_with_physical_address->{transactionAttribute}{itemAttribute} =
      Google::Ads::GoogleAds::V21::Common::ItemAttribute->new({
        itemId       => $item_id,
        merchantId   => $merchant_center_account_id,
        countryCode  => $country_code,
        languageCode => $language_code,
        # Quantity field should only be set when at least one of the other item
        # attributes is present.
        quantity => $quantity
      });

  }

  # Create the operations to add the two transactions.
  my $operations = [
    Google::Ads::GoogleAds::V21::Services::OfflineUserDataJobService::OfflineUserDataJobOperation
      ->new({
        create => $user_data_with_email_address
      }
      ),
    Google::Ads::GoogleAds::V21::Services::OfflineUserDataJobService::OfflineUserDataJobOperation
      ->new({
        create => $user_data_with_physical_address
      })];

  return $operations;
}

# Returns the result of normalizing and then hashing the string using the
# provided digest. Private customer data must be hashed during upload, as
# described at https://support.google.com/google-ads/answer/7506124
sub normalize_and_hash {
  my $value = shift;

  $value =~ s/^\s+|\s+$//g;
  return sha256_hex(lc $value);
}

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
  "customer_id=s"                 => \$customer_id,
  "offline_user_data_job_type=s"  => \$offline_user_data_job_type,
  "conversion_action_id=i"        => \$conversion_action_id,
  "external_id=i"                 => \$external_id,
  "custom_key=s"                  => \$custom_key,
  "advertiser_upload_date_time=s" => \$advertiser_upload_date_time,
  "bridge_map_version_id=i"       => \$bridge_map_version_id,
  "partner_id=i"                  => \$partner_id,
  "item_id=s"                     => \$item_id,
  "merchant_center_account_id=i"  => \$merchant_center_account_id,
  "country_code=s"                => \$country_code,
  "language_code=s"               => \$language_code,
  "quantity=i"                    => \$quantity,
  "ad_personalization_consent=s"  => \$ad_personalization_consent,
  "ad_user_data_consent=s"        => \$ad_user_data_consent
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $conversion_action_id);

# Call the example.
upload_store_sales_transactions(
  $api_client,                  $customer_id =~ s/-//gr,
  $offline_user_data_job_type,  $conversion_action_id,
  $external_id,                 $custom_key,
  $advertiser_upload_date_time, $bridge_map_version_id,
  $partner_id,                  $item_id,
  $merchant_center_account_id,  $country_code,
  $language_code,               $quantity,
  $ad_personalization_consent,  $ad_user_data_consent
);

=pod

=head1 NAME

upload_store_sales_transactions

=head1 DESCRIPTION

This example uploads offline data for store sales transactions.

This feature is only available to allowlisted accounts.
See https://support.google.com/google-ads/answer/7620302 for more details.

=head1 SYNOPSIS

upload_store_sales_transactions.pl [options]

    -help                           Show the help message.
    -customer_id                    The Google Ads customer ID.
    -conversion_action_id           The ID of a store sales conversion action.
    -offline_user_data_job_type     [optional] The type of offline user data in the job (first party or third party).
                                    If you have an official store sales partnership with Google, use STORE_SALES_UPLOAD_THIRD_PARTY.
                                    Otherwise, use STORE_SALES_UPLOAD_FIRST_PARTY.
    -external_id                    [optional] (but recommended) external ID for the offline user data job.
    -custom_key                     [optional] Only required after creating a custom key and custom values in the account. Custom key
                                    and values are used to segment store sales conversions. This measurement can be used to provide
                                    more advanced insights.
    -advertiser_upload_date_time    [optional] Date and time the advertiser uploaded data to the partner. Only required for third party uploads.
                                    The format is "yyyy-mm-dd hh:mm:ss+|-hh:mm", e.g. "2019-01-01 12:32:45-08:00".
    -bridge_map_version_id          [optional] Version of partner IDs to be used for uploads. Only required for third party uploads.
    -partner_id                     [optional] ID of the third party partner. Only required for third party uploads.
    -item_id                        [optional] A unique identifier of a product, either the Merchant Center Item ID or Global Trade Item Number (GTIN).
                                    Only required if uploading with item attributes.
    -merchant_center_account_id     [optional] A Merchant Center Account ID. Only required if uploading with item attributes.
    -country_code                   [optional] A two-letter country code of the location associated with the feed where your items are uploaded.
                                    Only required if uploading with item attributes.
                                    For a list of country codes see: https://developers.google.com/google-ads/api/reference/data/codes-formats#country-codes
    -language_code                  [optional] A two-letter language code of the language associated with the feed where your items are uploaded.
                                    Only required if uploading with item attributes.
                                    For a list of language codes see: https://developers.google.com/google-ads/api/reference/data/codes-formats#languages
    -quantity                       [optional] The number of items sold. Can only be set when at least one other item attribute has been provided.
                                    Only required if uploading with item attributes.
    -ad_personalization_consent		[optional] The ad personalization consent status.
	-ad_user_data_consent			[optional] The ad user data consent status.

=cut
