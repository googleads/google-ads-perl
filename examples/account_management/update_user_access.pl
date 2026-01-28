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
# This code example updates the access role of a user, given the email address.
# Note: This code example should be run as a user who is an Administrator on the
# Google Ads account with the specified customer ID. See
# https://support.google.com/google-ads/answer/9978556 to learn more about account
# access levels.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V23::Resources::CustomerUserAccess;
use
  Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsRequest;
use
  Google::Ads::GoogleAds::V23::Services::CustomerUserAccessService::CustomerUserAccessOperation;
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
my $customer_id   = "INSERT_CUSTOMER_ID_HERE";
my $email_address = "INSERT_EMAIL_ADDRESS_HERE";
# See Google::Ads::GoogleAds::V23::Enums::AccessRoleEnum for optional values.
my $access_role = "INSERT_ACCESS_ROLE_HERE";

sub update_user_access {
  my ($api_client, $customer_id, $email_address, $access_role) = @_;

  my $user_id = get_user_access($api_client, $customer_id, $email_address);
  if (defined $user_id) {
    modify_user_access($api_client, $customer_id, $user_id, $access_role);
  }

  return 1;
}

# Gets the customer user access given an email address.
sub get_user_access {
  my ($api_client, $customer_id, $email_address) = @_;

  # Create the search query. Use the LIKE query for filtering to ignore the
  # text case for email address when searching for a match.
  my $search_query =
    "SELECT customer_user_access.user_id, customer_user_access.email_address, "
    . "customer_user_access.access_role, customer_user_access.access_creation_date_time "
    . "FROM customer_user_access "
    . "WHERE customer_user_access.email_address LIKE '$email_address'";

  # Create a search Google Ads request that will retrieve the customer user access.
  my $search_request =
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsRequest
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

  if ($iterator->has_next) {
    my $google_ads_row = $iterator->next;
    my $access         = $google_ads_row->{customerUserAccess};

    printf "Customer user access with User ID = %d, Email Address = '%s' " .
      "Access Role = '%s' and Creation Time = %s was found in " .
      "Customer ID: %d.\n",
      $access->{userId}, $access->{emailAddress}, $access->{accessRole},
      $access->{accessCreationDateTime}, $customer_id;
    return $access->{userId};
  } else {
    print "No customer user access with requested email was found.\n";
    return undef;
  }
}

# Modifies the user access role to a specified value.
sub modify_user_access {
  my ($api_client, $customer_id, $user_id, $access_role) = @_;

  # Create the modified user access.
  my $user_access =
    Google::Ads::GoogleAds::V23::Resources::CustomerUserAccess->new({
      resourceName =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::customer_user_access(
        $customer_id, $user_id
        ),
      accessRole => $access_role
    });

  # Create the operation.
  my $user_access_operation =
    Google::Ads::GoogleAds::V23::Services::CustomerUserAccessService::CustomerUserAccessOperation
    ->new({
      update     => $user_access,
      updateMask => all_set_fields_of($user_access)});

  # Update the user access.
  my $user_access_response = $api_client->CustomerUserAccessService()->mutate({
    customerId => $customer_id,
    operation  => $user_access_operation
  });

  printf
    "Successfully modified customer user access with resource name '%s'.\n",
    $user_access_response->{result}{resourceName};
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
  "customer_id=s"   => \$customer_id,
  "email_address=s" => \$email_address,
  "access_role=s"   => \$access_role
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $email_address, $access_role);

# Call the example.
update_user_access($api_client, $customer_id =~ s/-//gr,
  $email_address, $access_role);

=pod

=head1 NAME

update_user_access

=head1 DESCRIPTION

This code example updates the access role of a user, given the email address.
Note: This code example should be run as a user who is an Administrator on the
Google Ads account with the specified customer ID. See
https://support.google.com/google-ads/answer/9978556 to learn more about account
access levels.

=head1 SYNOPSIS

update_user_access.pl [options]

    -help             Show the help message.
    -customer_id      The Google Ads customer ID.
    -email_address    Email address of the user whose access role should be modifled.
    -access_role      The updated user access role, e.g. ADMIN, STANDARD, READ_ONLY
                      and EMAIL_ONLY.

=cut
