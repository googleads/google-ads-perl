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
# This example creates operations to add members to a user list (a.k.a. audience)
# using an OfflineUserDataJob, and if requested, runs the job.
#
# If a job ID is specified, this examples add operations to that job. Otherwise,
# it creates a new job for the operations.
#
# Your application should create a single job containing all of the operations
# for a user list. This will be far more efficient than creating and running
# multiple jobs that each contain a small set of operations.
#
# Notes:
#
# * This feature is only available to accounts that meet the requirements described
# at https://support.google.com/adspolicy/answer/6299717.
# * It may take up to several hours for the list to be populated with users.
# * Email addresses must be associated with a Google account.
# * For privacy purposes, the user list size will show as zero until the list has
# at least 100 users. After that, the size will be rounded to the two most
# significant digits.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use Google::Ads::GoogleAds::V21::Resources::UserList;
use Google::Ads::GoogleAds::V21::Resources::OfflineUserDataJob;
use Google::Ads::GoogleAds::V21::Common::Consent;
use Google::Ads::GoogleAds::V21::Common::CrmBasedUserListInfo;
use Google::Ads::GoogleAds::V21::Common::CustomerMatchUserListMetadata;
use Google::Ads::GoogleAds::V21::Common::UserData;
use Google::Ads::GoogleAds::V21::Common::UserIdentifier;
use Google::Ads::GoogleAds::V21::Common::OfflineUserAddressInfo;
use Google::Ads::GoogleAds::V21::Enums::CustomerMatchUploadKeyTypeEnum
  qw(CONTACT_INFO);
use Google::Ads::GoogleAds::V21::Enums::OfflineUserDataJobStatusEnum
  qw(SUCCESS FAILED PENDING RUNNING);
use Google::Ads::GoogleAds::V21::Enums::OfflineUserDataJobTypeEnum
  qw(CUSTOMER_MATCH_USER_LIST);
use Google::Ads::GoogleAds::V21::Services::UserListService::UserListOperation;
use
  Google::Ads::GoogleAds::V21::Services::OfflineUserDataJobService::OfflineUserDataJobOperation;
use
  Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);
use Digest::SHA  qw(sha256_hex);

sub add_customer_match_user_list {
  my ($api_client, $customer_id, $run_job, $user_list_id,
    $offline_user_data_job_id, $ad_personalization_consent,
    $ad_user_data_consent)
    = @_;
  my $user_list_resource_name = undef;
  if (!defined $offline_user_data_job_id) {
    if (!defined $user_list_id) {
      # Create a Customer Match user list.
      $user_list_resource_name =
        create_customer_match_user_list($api_client, $customer_id);
    } else {
      # Uses the specified Customer Match user list.
      $user_list_resource_name =
        Google::Ads::GoogleAds::V21::Utils::ResourceNames::user_list(
        $customer_id, $user_list_id);
    }
  }
  add_users_to_customer_match_user_list($api_client, $customer_id, $run_job,
    $user_list_resource_name,    $offline_user_data_job_id,
    $ad_personalization_consent, $ad_user_data_consent);
  print_customer_match_user_list_info($api_client, $customer_id,
    $user_list_resource_name);

  return 1;
}

# Creates a Customer Match user list.
# [START add_customer_match_user_list_3]
sub create_customer_match_user_list {
  my ($api_client, $customer_id) = @_;

  # Create the user list.
  my $user_list = Google::Ads::GoogleAds::V21::Resources::UserList->new({
      name        => "Customer Match list #" . uniqid(),
      description =>
        "A list of customers that originated from email and physical addresses",
      # Membership life span must be between 0 and 540 days inclusive. See:
      # https://developers.google.com/google-ads/api/reference/rpc/latest/UserList#membership_life_span
      # Set the membership life span to 30 days.
      membershipLifeSpan => 30,
      # Set the upload key type to indicate the type of identifier that will be
      # used to add users to the list. This field is immutable and required for
      # a CREATE operation.
      crmBasedUserList =>
        Google::Ads::GoogleAds::V21::Common::CrmBasedUserListInfo->new({
          uploadKeyType => CONTACT_INFO
        })});

  # Create the user list operation.
  my $user_list_operation =
    Google::Ads::GoogleAds::V21::Services::UserListService::UserListOperation->
    new({
      create => $user_list
    });

  # Issue a mutate request to add the user list and print some information.
  my $user_lists_response = $api_client->UserListService()->mutate({
      customerId => $customer_id,
      operations => [$user_list_operation]});
  my $user_list_resource_name =
    $user_lists_response->{results}[0]{resourceName};
  printf "User list with resource name '%s' was created.\n",
    $user_list_resource_name;

  return $user_list_resource_name;
}
# [END add_customer_match_user_list_3]

# Creates and executes an asynchronous job to add users to the Customer Match
# user list.
# [START add_customer_match_user_list]
sub add_users_to_customer_match_user_list {
  my ($api_client, $customer_id, $run_job, $user_list_resource_name,
    $offline_user_data_job_id, $ad_personalization_consent,
    $ad_user_data_consent)
    = @_;

  my $offline_user_data_job_service = $api_client->OfflineUserDataJobService();

  my $offline_user_data_job_resource_name = undef;
  if (!defined $offline_user_data_job_id) {
    # Create a new offline user data job.
    my $offline_user_data_job =
      Google::Ads::GoogleAds::V21::Resources::OfflineUserDataJob->new({
        type                          => CUSTOMER_MATCH_USER_LIST,
        customerMatchUserListMetadata =>
          Google::Ads::GoogleAds::V21::Common::CustomerMatchUserListMetadata->
          new({
            userList => $user_list_resource_name
          })});

    # Add consent information to the job if specified.
    if ($ad_personalization_consent or $ad_user_data_consent) {
      my $consent = Google::Ads::GoogleAds::V21::Common::Consent->new({});
      if ($ad_personalization_consent) {
        $consent->{adPersonalization} = $ad_personalization_consent;
      }
      if ($ad_user_data_consent) {
        $consent->{adUserData} = $ad_user_data_consent;
      }
      # Specify whether user consent was obtained for the data you are uploading.
      # See https://www.google.com/about/company/user-consent-policy for details.
      $offline_user_data_job->{customerMatchUserListMetadata}{consent} =
        $consent;
    }

    # Issue a request to create the offline user data job.
    my $create_offline_user_data_job_response =
      $offline_user_data_job_service->create({
        customerId => $customer_id,
        job        => $offline_user_data_job
      });
    $offline_user_data_job_resource_name =
      $create_offline_user_data_job_response->{resourceName};
    printf
      "Created an offline user data job with resource name: '%s'.\n",
      $offline_user_data_job_resource_name;
  } else {
    # Reuse the specified offline user data job.
    $offline_user_data_job_resource_name =
      Google::Ads::GoogleAds::V21::Utils::ResourceNames::offline_user_data_job(
      $customer_id, $offline_user_data_job_id);
  }

  # Issue a request to add the operations to the offline user data job.
  # This example only adds a few operations, so it only sends one AddOfflineUserDataJobOperations
  # request. If your application is adding a large number of operations, split
  # the operations into batches and send multiple AddOfflineUserDataJobOperations
  # requests for the SAME job. See
  # https://developers.google.com/google-ads/api/docs/remarketing/audience-types/customer-match#customer_match_considerations
  # and https://developers.google.com/google-ads/api/docs/best-practices/quotas#user_data
  # for more information on the per-request limits.
  my $user_data_job_operations = build_offline_user_data_job_operations();
  my $response                 = $offline_user_data_job_service->add_operations(
    {
      resourceName         => $offline_user_data_job_resource_name,
      enablePartialFailure => "true",
      operations           => $user_data_job_operations
    });

  # Print the status message if any partial failure error is returned.
  # Note: The details of each partial failure error are not printed here, you can
  # refer to the example handle_partial_failure.pl to learn more.
  if ($response->{partialFailureError}) {
    # Extract the partial failure from the response status.
    my $partial_failure = $response->{partialFailureError}{details}[0];
    printf "Encountered %d partial failure errors while adding %d operations " .
      "to the offline user data job: '%s'. Only the successfully added " .
      "operations will be executed when the job runs.\n",
      scalar @{$partial_failure->{errors}}, scalar @$user_data_job_operations,
      $response->{partialFailureError}{message};
  } else {
    printf "Successfully added %d operations to the offline user data job.\n",
      scalar @$user_data_job_operations;
  }

  if (!defined $run_job) {
    print
"Not running offline user data job $offline_user_data_job_resource_name, as requested.\n";
    return;
  }

  # Issue an asynchronous request to run the offline user data job for executing
  # all added operations.
  my $operation_response = $offline_user_data_job_service->run({
    resourceName => $offline_user_data_job_resource_name
  });

  # Offline user data jobs may take 6 hours or more to complete, so instead of waiting
  # for the job to complete, this example retrieves and displays the job status once.
  # If the job is completed successfully, it prints information about the user list.
  # Otherwise, it prints, the query to use to check the job status again later.
  check_job_status($api_client, $customer_id,
    $offline_user_data_job_resource_name);
}
# [END add_customer_match_user_list]

# Retrieves, checks, and prints the status of the offline user data job.
# [START add_customer_match_user_list_4]
sub check_job_status {
  my ($api_client, $customer_id, $offline_user_data_job_resource_name) = @_;

  my $search_query =
    "SELECT offline_user_data_job.resource_name, " .
    "offline_user_data_job.id, offline_user_data_job.status, " .
    "offline_user_data_job.type, offline_user_data_job.failure_reason, " .
    "offline_user_data_job.customer_match_user_list_metadata.user_list " .
    "FROM offline_user_data_job " .
    "WHERE offline_user_data_job.resource_name = " .
    "'$offline_user_data_job_resource_name' LIMIT 1";

  my $search_request =
    Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query
    });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $iterator = Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
    service => $google_ads_service,
    request => $search_request
  });

  # The results have exactly one row.
  my $google_ads_row        = $iterator->next;
  my $offline_user_data_job = $google_ads_row->{offlineUserDataJob};
  my $status                = $offline_user_data_job->{status};

  printf
    "Offline user data job ID %d with type %s has status: %s.\n",
    $offline_user_data_job->{id},
    $offline_user_data_job->{type},
    $status;

  if ($status eq SUCCESS) {
    print_customer_match_user_list_info($api_client, $customer_id,
      $offline_user_data_job->{customerMatchUserListMetadata}{userList});
  } elsif ($status eq FAILED) {
    print "Failure reason: $offline_user_data_job->{failureReason}";
  } elsif (grep /$status/, (PENDING, RUNNING)) {
    print
      "To check the status of the job periodically, use the following GAQL " .
      "query with the GoogleAdsService->search() method:\n$search_query\n";
  }

  return 1;
}
# [END add_customer_match_user_list_4]

# Builds and returns offline user data job operations to add one user identified
# by an email address and one user identified based on a physical address.
sub build_offline_user_data_job_operations() {
  # [START add_customer_match_user_list_2]
  # The first user data has an email address and a phone number.
  my $raw_record_1 = {
    email => 'dana@example.com',
    # Phone number to be converted to E.164 format, with a leading '+' as
    # required. This includes whitespace that will be removed later.
    phone => '+1 800 5550101',
  };

  # The second user data has an email address, a mailing address, and a phone
  # number.
  my $raw_record_2 = {
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
  };

  # The third user data only has an email address.
  my $raw_record_3 = {email => 'charlie@example.com',};

  my $raw_records = [$raw_record_1, $raw_record_2, $raw_record_3];

  my $operations = [];
  foreach my $record (@$raw_records) {
    # Check if the record has email, phone, or address information, and adds a
    # SEPARATE UserIdentifier object for each one found. For example, a record
    # with an email address and a phone number will result in a UserData with two
    # UserIdentifiers.
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
    #
    # The separate 'if' statements below demonstrate the correct approach for creating a
    # UserData object for a member with multiple UserIdentifiers.

    my $user_identifiers = [];

    # Check if the record has an email address, and if so, add a UserIdentifier for it.
    if (defined $record->{email}) {
      # Add the hashed email identifier to the list of UserIdentifiers.
      push(
        @$user_identifiers,
        Google::Ads::GoogleAds::V21::Common::UserIdentifier->new({
            hashedEmail => normalize_and_hash($record->{email}, 1)}));
    }

    # Check if the record has a phone number, and if so, add a UserIdentifier for it.
    if (defined $record->{phone}) {
      # Add the hashed phone number identifier to the list of UserIdentifiers.
      push(
        @$user_identifiers,
        Google::Ads::GoogleAds::V21::Common::UserIdentifier->new({
            hashedPhoneNumber => normalize_and_hash($record->{phone}, 1)}));
    }

    # Check if the record has all the required mailing address elements, and if so, add
    # a UserIdentifier for the mailing address.
    if (defined $record->{firstName}) {
      my $required_keys = ["lastName", "countryCode", "postalCode"];
      my $missing_keys  = [];

      foreach my $key (@$required_keys) {
        if (!defined $record->{$key}) {
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
          Google::Ads::GoogleAds::V21::Common::UserIdentifier->new({
              addressInfo =>
                Google::Ads::GoogleAds::V21::Common::OfflineUserAddressInfo->
                new({
                  # First and last name must be normalized and hashed.
                  hashedFirstName => normalize_and_hash($record->{firstName}),
                  hashedLastName  => normalize_and_hash($record->{lastName}),
                  # Country code and zip code are sent in plain text.
                  countryCode => $record->{countryCode},
                  postalCode  => $record->{postalCode},
                })}));
      }
    }

    # If the user_identifiers array is not empty, create a new
    # OfflineUserDataJobOperation and add the UserData to it.
    if (@$user_identifiers) {
      my $user_data = Google::Ads::GoogleAds::V21::Common::UserData->new({
          userIdentifiers => [$user_identifiers]});
      push(
        @$operations,
        Google::Ads::GoogleAds::V21::Services::OfflineUserDataJobService::OfflineUserDataJobOperation
          ->new({
            create => $user_data
          }));
    }
  }
  # [END add_customer_match_user_list_2]
  return $operations;
}

# Prints information about the Customer Match user list.
sub print_customer_match_user_list_info {
  my ($api_client, $customer_id, $user_list_resource_name) = @_;

  # [START add_customer_match_user_list_5]
  # Create a query that retrieves the user list.
  my $search_query =
    "SELECT user_list.size_for_display, user_list.size_for_search " .
    "FROM user_list " .
    "WHERE user_list.resource_name = '$user_list_resource_name'";

  # Create a search Google Ads stream request that will retrieve the user list.
  my $search_stream_request =
    Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query,
    });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $google_ads_service,
      request => $search_stream_request
    });
  # [END add_customer_match_user_list_5]

  # Issue a search request and process the stream response to print out some
  # information about the user list.
  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row = shift;
      my $user_list      = $google_ads_row->{userList};

      printf "The estimated number of users that the user list '%s' " .
        "has is %d for Display and %d for Search.\n",
        $user_list->{resourceName},
        $user_list->{sizeForDisplay},
        $user_list->{sizeForSearch};
    });

  print
    "Reminder: It may take several hours for the user list to be populated " .
    "with the users so getting zeros for the estimations is expected.\n";
}

# Normalizes and hashes a string value.
sub normalize_and_hash {
  my $value                    = shift;
  my $trim_intermediate_spaces = shift;

  if ($trim_intermediate_spaces) {
    $value =~ s/\s+|\s+$//g;
  } else {
    $value =~ s/^\s+|\s+$//g;
  }
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

my $customer_id                = undef;
my $run_job                    = undef;
my $user_list_id               = undef;
my $offline_user_data_job_id   = undef;
my $ad_personalization_consent = undef;
my $ad_user_data_consent       = undef;

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s"                => \$customer_id,
  "run_job=s"                    => \$run_job,
  "user_list_id=i"               => \$user_list_id,
  "offline_user_data_job_id=i"   => \$offline_user_data_job_id,
  "ad_personalization_consent=s" => \$ad_personalization_consent,
  "ad_user_data_consent=s"       => \$ad_user_data_consent
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
add_customer_match_user_list($api_client, $customer_id =~ s/-//gr,
  $run_job, $user_list_id, $offline_user_data_job_id,
  $ad_personalization_consent, $ad_user_data_consent);

=pod

=head1 NAME

add_customer_match_user_list

=head1 DESCRIPTION

This example uses Customer Match to create a new user list (a.k.a. audience) and
adds users to it.

This feature is only available to allowlisted accounts.
See https://support.google.com/adspolicy/answer/6299717 for more details.

Note: It may take up to several hours for the list to be populated with users.
Email addresses must be associated with a Google account. For privacy purposes,
the user list size will show as zero until the list has at least 100 users.
After that, the size will be rounded to the two most significant digits.

=head1 SYNOPSIS

add_customer_match_user_list.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -run_job			[optional] Run the OfflineUserDataJob after adding operations. Otherwise, only adds operations to the job.
    -user_list_id		[optional] ID of an existing user list. If undef, creates a new user list.
    -offline_user_data_job_id	[optional] ID of an existing OfflineUserDataJob in the PENDING state. If undef, creates a new job.
	-ad_personalization_consent	[optional] Consent status for ad personalization for all members in the job. Only used if offline_user_data_job_id is undef.
	-ad_user_data_consent		[optional] Consent status for ad user data for all members in the job. Only used if offline_user_data_job_id is undef.

=cut
