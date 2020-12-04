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
# This example uses Customer Match to create a new user list (a.k.a. audience)
# and adds users to it.
#
# Note: It may take up to several hours for the list to be populated with users.
# Email addresses must be associated with a Google account. For privacy purposes,
# the user list size will show as zero until the list has at least 1,000 users.
# After that, the size will be rounded to the two most significant digits.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use Google::Ads::GoogleAds::V6::Resources::UserList;
use Google::Ads::GoogleAds::V6::Resources::OfflineUserDataJob;
use Google::Ads::GoogleAds::V6::Common::CrmBasedUserListInfo;
use Google::Ads::GoogleAds::V6::Common::CustomerMatchUserListMetadata;
use Google::Ads::GoogleAds::V6::Common::UserData;
use Google::Ads::GoogleAds::V6::Common::UserIdentifier;
use Google::Ads::GoogleAds::V6::Common::OfflineUserAddressInfo;
use Google::Ads::GoogleAds::V6::Enums::CustomerMatchUploadKeyTypeEnum
  qw(CONTACT_INFO);
use Google::Ads::GoogleAds::V6::Enums::OfflineUserDataJobTypeEnum
  qw(CUSTOMER_MATCH_USER_LIST);
use Google::Ads::GoogleAds::V6::Services::UserListService::UserListOperation;
use
  Google::Ads::GoogleAds::V6::Services::OfflineUserDataJobService::OfflineUserDataJobOperation;
use
  Google::Ads::GoogleAds::V6::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
use Data::Uniqid qw(uniqid);
use Digest::SHA qw(sha256_hex);

use constant POLL_FREQUENCY_SECONDS => 1;
use constant POLL_TIMEOUT_SECONDS   => 60;

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub add_customer_match_user_list {
  my ($api_client, $customer_id) = @_;

  my $user_list_resource_name =
    create_customer_match_user_list($api_client, $customer_id);
  add_users_to_customer_match_user_list($api_client, $customer_id,
    $user_list_resource_name);
  print_customer_match_user_list_info($api_client, $customer_id,
    $user_list_resource_name);

  return 1;
}

# Creates a Customer Match user list.
sub create_customer_match_user_list {
  my ($api_client, $customer_id) = @_;

  # Create the user list.
  my $user_list = Google::Ads::GoogleAds::V6::Resources::UserList->new({
      name => "Customer Match list #" . uniqid(),
      description =>
        "A list of customers that originated from email and physical addresses",
      # Customer Match user lists can use a membership life span of 10000 to
      # indicate unlimited; otherwise normal values apply.
      # Set the membership life span to 30 days.
      membershipLifeSpan => 30,
      crmBasedUserList =>
        Google::Ads::GoogleAds::V6::Common::CrmBasedUserListInfo->new({
          uploadKeyType => CONTACT_INFO
        })});

  # Create the user list operation.
  my $user_list_operation =
    Google::Ads::GoogleAds::V6::Services::UserListService::UserListOperation->
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

# Creates and executes an asynchronous job to add users to the Customer Match
# user list.
# [START add_customer_match_user_list]
sub add_users_to_customer_match_user_list {
  my ($api_client, $customer_id, $user_list_resource_name) = @_;

  my $offline_user_data_job_service = $api_client->OfflineUserDataJobService();

  # Create a new offline user data job.
  my $offline_user_data_job =
    Google::Ads::GoogleAds::V6::Resources::OfflineUserDataJob->new({
      type => CUSTOMER_MATCH_USER_LIST,
      customerMatchUserListMetadata =>
        Google::Ads::GoogleAds::V6::Common::CustomerMatchUserListMetadata->new({
          userList => $user_list_resource_name
        })});

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

  # Issue a request to add the operations to the offline user data job.
  my $response = $offline_user_data_job_service->add_operations({
      resourceName         => $offline_user_data_job_resource_name,
      enablePartialFailure => "true",
      operations           => build_offline_user_data_job_operations()});

  # Print the status message if any partial failure error is returned.
  # Note: The details of each partial failure error are not printed here, you can
  # refer to the example handle_partial_failure.pl to learn more.
  if ($response->{partialFailureError}) {
    # Extract the partial failure from the response status.
    my $partial_failure = $response->{partialFailureError}{details}[0];
    printf
      "%d partial failure error(s) occurred: %s.\n",
      scalar @{$partial_failure->{errors}},
      $response->{partialFailureError}{message};
  }
  print "The operations are added to the offline user data job.\n";

  # Issue an asynchronous request to run the offline user data job for executing
  # all added operations.
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
}
# [END add_customer_match_user_list]

# Builds and returns offline user data job operations to add one user identified
# by an email address and one user identified based on a physical address.
sub build_offline_user_data_job_operations() {
  # Create a first user data based on an email address.
  my $user_data_with_email_address =
    Google::Ads::GoogleAds::V6::Common::UserData->new({
      userIdentifiers => [
        Google::Ads::GoogleAds::V6::Common::UserIdentifier->new({
            # Hash normalized email addresses based on SHA-256 hashing algorithm.
            hashedEmail => normalize_and_hash('customer@example.com')})]});

  # Create a second user data based on a physical address.
  my $user_data_with_physical_address =
    Google::Ads::GoogleAds::V6::Common::UserData->new({
      userIdentifiers => [
        Google::Ads::GoogleAds::V6::Common::UserIdentifier->new({
            addressInfo =>
              Google::Ads::GoogleAds::V6::Common::OfflineUserAddressInfo->new({
                # First and last name must be normalized and hashed.
                hashedFirstName => normalize_and_hash("John"),
                hashedLastName  => normalize_and_hash("Doe"),
                # Country code and zip code are sent in plain text.
                countryCode => "US",
                postalCode  => "10011"
              })})]});

  # Create the operations to add the two users.
  my $operations = [
    Google::Ads::GoogleAds::V6::Services::OfflineUserDataJobService::OfflineUserDataJobOperation
      ->new({
        create => $user_data_with_email_address
      }
      ),
    Google::Ads::GoogleAds::V6::Services::OfflineUserDataJobService::OfflineUserDataJobOperation
      ->new({
        create => $user_data_with_physical_address
      })];

  return $operations;
}

# Prints information about the Customer Match user list.
sub print_customer_match_user_list_info {
  my ($api_client, $customer_id, $user_list_resource_name) = @_;

  # Create a query that retrieves the user list.
  my $search_query =
    "SELECT user_list.size_for_display, user_list.size_for_search " .
    "FROM user_list " .
    "WHERE user_list.resource_name = '$user_list_resource_name'";

  # Create a search Google Ads stream request that will retrieve the user list.
  my $search_stream_request =
    Google::Ads::GoogleAds::V6::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
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
GetOptions("customer_id=s" => \$customer_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
add_customer_match_user_list($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

add_customer_match_user_list

=head1 DESCRIPTION

This example uses Customer Match to create a new user list (a.k.a. audience) and
adds users to it.

Note: It may take up to several hours for the list to be populated with users.
Email addresses must be associated with a Google account. For privacy purposes,
the user list size will show as zero until the list has at least 1,000 users.
After that, the size will be rounded to the two most significant digits.

=head1 SYNOPSIS

add_customer_match_user_list.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
