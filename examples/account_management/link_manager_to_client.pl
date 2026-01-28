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
# This example demonstrates how to link an existing Google Ads manager customer
# account to an existing Google Ads client customer account.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V23::Resources::CustomerClientLink;
use Google::Ads::GoogleAds::V23::Resources::CustomerManagerLink;
use Google::Ads::GoogleAds::V23::Enums::ManagerLinkStatusEnum
  qw(PENDING ACTIVE);
use
  Google::Ads::GoogleAds::V23::Services::CustomerClientLinkService::CustomerClientLinkOperation;
use
  Google::Ads::GoogleAds::V23::Services::CustomerManagerLinkService::CustomerManagerLinkOperation;
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
my $manager_customer_id = "INSERT_MANAGER_CUSTOMER_ID_HERE";
my $customer_id         = "INSERT_CUSTOMER_ID_HERE";

# This example assumes that the same credentials will work for both customers,
# but that may not be the case. If you need to use different credentials
# for each customer, then you may either update the client configuration or
# instantiate two clients, one for each set of credentials. Always make sure
# to update the configuration before fetching any services you need to use.
# [START link_manager_to_client]
sub link_manager_to_client {
  my ($api_client, $manager_customer_id, $api_client_customer_id) = @_;

  # Step 1: Extend an invitation to the client customer while authenticating
  # as the manager.
  $api_client->set_login_customer_id($manager_customer_id);

  # Create a customer client link.
  my $api_client_link =
    Google::Ads::GoogleAds::V23::Resources::CustomerClientLink->new({
      clientCustomer =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::customer(
        $api_client_customer_id),
      status => PENDING
    });

  # Create a customer client link operation.
  my $api_client_link_operation =
    Google::Ads::GoogleAds::V23::Services::CustomerClientLinkService::CustomerClientLinkOperation
    ->new({
      create => $api_client_link
    });

  # Add the customer client link to extend an invitation to the client customer.
  my $api_client_link_response =
    $api_client->CustomerClientLinkService()->mutate({
      customerId => $manager_customer_id,
      operation  => $api_client_link_operation
    });

  my $api_client_link_resource_name =
    $api_client_link_response->{result}{resourceName};

  printf "Extended an invitation from the manager customer %d to the " .
    "client customer %d with the customer client link resource name: '%s'.\n",
    $manager_customer_id, $api_client_customer_id,
    $api_client_link_resource_name;

  # Step 2: Get the 'manager_link_id' of the client link we just created,
  # to construct the resource name of the manager link from the client side.
  my $search_query =
    "SELECT customer_client_link.manager_link_id FROM customer_client_link " .
"WHERE customer_client_link.resource_name = '$api_client_link_resource_name'";

  my $search_response = $api_client->GoogleAdsService()->search({
    customerId => $manager_customer_id,
    query      => $search_query
  });

  my $manager_link_id =
    $search_response->{results}[0]{customerClientLink}{managerLinkId};

  my $manager_link_resource_name =
    Google::Ads::GoogleAds::V23::Utils::ResourceNames::customer_manager_link(
    $api_client_customer_id, $manager_customer_id, $manager_link_id);

  # Step 3: Accept the manager customer's link invitation while authenticating
  # as the client.
  $api_client->set_login_customer_id($api_client_customer_id);

  # Create a customer manager link.
  my $manager_link =
    Google::Ads::GoogleAds::V23::Resources::CustomerManagerLink->new({
      resourceName => $manager_link_resource_name,
      status       => ACTIVE
    });

  # Create a customer manager link operation.
  my $manager_link_operation =
    Google::Ads::GoogleAds::V23::Services::CustomerManagerLinkService::CustomerManagerLinkOperation
    ->new({
      update     => $manager_link,
      updateMask => all_set_fields_of($manager_link)});

  # Update the customer manager link to accept the invitation.
  my $manager_link_response =
    $api_client->CustomerManagerLinkService()->mutate({
      customerId => $api_client_customer_id,
      operations => [$manager_link_operation]});

  printf "The client customer %d accepted the invitation with " .
    "the customer manager link resource name: '%s'.\n",
    $api_client_customer_id,
    $manager_link_response->{results}[0]{resourceName};

  return 1;
}
# [END link_manager_to_client]

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
  "manager_customer_id=s" => \$manager_customer_id,
  "customer_id=s"         => \$customer_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($manager_customer_id, $customer_id);

# Call the example.
link_manager_to_client(
  $api_client,
  $manager_customer_id =~ s/-//gr,
  $customer_id         =~ s/-//gr
);

=pod

=head1 NAME

link_manager_to_client

=head1 DESCRIPTION

This example demonstrates how to link an existing Google Ads manager customer
account to an existing Google Ads client customer account.

=head1 SYNOPSIS

link_manager_to_client.pl [options]

    -help                       Show the help message.
    -manager_customer_id        The Google Ads manager customer ID.
    -customer_id                The Google Ads customer ID.

=cut
