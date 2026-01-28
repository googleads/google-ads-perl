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
# Gets the account hierarchy of the specified manager customer ID and login customer
# ID. If you don't specify them, the example will instead print the hierarchies
# of all accessible customer accounts for your authenticated Google account.
#
# Note that if the list of accessible customers for your authenticated Google
# account includes accounts within the same hierarchy, this example will retrieve
# and print the overlapping portions of the hierarchy for each accessible customer.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use
  Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;

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
#
# Optional: You may pass the manager customer ID on the command line or specify
# it here. If neither are set, a null value will be passed to run the example,
# and the example will print the hierarchies of all accessible customer IDs.
my $manager_customer_id = undef;
# Optional: You may pass the login customer ID on the command line or specify it
# here if and only if the manager customer ID is set. If the login customer ID
# is set neither on the command line nor below, a null value will be passed to
# run the example, and the example will use each accessible customer ID as the
# login customer ID.
my $login_customer_id = undef;

# Stores the mapping from the root customer IDs (the ones that will be used as a
# start point for printing each hierarchy) to their `CustomerClient` objects.
my $root_customer_clients = {};

sub get_account_hierarchy {
  my ($api_client, $manager_customer_id, $login_customer_id) = @_;

  my $root_customer_ids = [];
  if (not $manager_customer_id) {
    # Get the account hierarchies for all accessible customers.
    $root_customer_ids = get_accessible_customers($api_client);
  } else {
    # Only get the hierarchy for the provided manager customer ID if provided.
    push @$root_customer_ids, $manager_customer_id;
  }

  my $all_hierarchies       = {};
  my $accounts_with_no_info = [];
  # Construct a map of account hierarchies.
  foreach my $root_customer_id (@$root_customer_ids) {
    my $customer_client_to_hierarchy =
      create_customer_client_to_hierarchy($login_customer_id,
      $root_customer_id);
    if (not $customer_client_to_hierarchy) {
      push @$accounts_with_no_info, $root_customer_id;
    } else {
      $all_hierarchies = {%$all_hierarchies, %$customer_client_to_hierarchy};
    }
  }

  # Print the IDs of any accounts that did not produce hierarchy information.
  if (scalar @$accounts_with_no_info > 0) {
    print "Unable to retrieve information for the following accounts " .
      "which are likely either test accounts or accounts with setup issues. " .
      "Please check the logs for details:\n";

    foreach my $account_id (@$accounts_with_no_info) {
      print "$account_id\n";
    }
    print "\n";
  }

  # Print the hierarchy information for all accounts for which there is hierarchy
  # information available.
  foreach my $root_customer_id (keys %$all_hierarchies) {
    printf "The hierarchy of customer ID %d is printed below:\n",
      $root_customer_id;
    print_account_hierarchy($root_customer_clients->{$root_customer_id},
      $all_hierarchies->{$root_customer_id}, 0);
    print "\n";
  }

  return 1;
}

# Retrieves a list of accessible customers with the provided set up credentials.
sub get_accessible_customers {
  my $api_client = shift;

  my $accessible_customer_ids = [];
  # Issue a request for listing all customers accessible by this authenticated
  # Google account.
  my $list_accessible_customers_response =
    $api_client->CustomerService()->list_accessible_customers();

  print "No manager customer ID is specified. The example will print the " .
    "hierarchies of all accessible customer IDs:\n";

  foreach my $customer_resource_name (
    @{$list_accessible_customers_response->{resourceNames}})
  {
    my $customer_id = $1 if $customer_resource_name =~ /(\d+)$/;
    print "$customer_id\n";
    push @$accessible_customer_ids, $customer_id;
  }

  return $accessible_customer_ids;
}

# Creates a map between a customer client and each of its managers' mappings.
sub create_customer_client_to_hierarchy() {
  my ($login_customer_id, $root_customer_id) = @_;

  # Create a GoogleAdsClient with the specified login customer ID. Seec
  # https://developers.google.com/google-ads/api/docs/concepts/call-structure#cid
  # for more information.
  my $api_client = Google::Ads::GoogleAds::Client->new({
    login_customer_id => $login_customer_id || $root_customer_id
  });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  # Create a query that retrieves all child accounts of the manager specified in
  # search calls below.
  my $search_query =
    "SELECT customer_client.client_customer, customer_client.level, " .
    "customer_client.manager, customer_client.descriptive_name, " .
    "customer_client.currency_code, customer_client.time_zone, " .
    "customer_client.id " .
    "FROM customer_client WHERE customer_client.level <= 1";

  my $root_customer_client = undef;
  # Add the root customer ID to the list of IDs to be processed.
  my $manager_customer_ids_to_search = [$root_customer_id];

  # Perform a breadth-first search algorithm to build a mapping of managers to
  # their child accounts.
  my $customer_ids_to_child_accounts = {};

  while (scalar @$manager_customer_ids_to_search > 0) {
    my $customer_id_to_search = shift @$manager_customer_ids_to_search;

    $customer_ids_to_child_accounts->{$customer_id_to_search} ||= [];

    my $search_stream_handler =
      Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
        service => $google_ads_service,
        request =>
          Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
          ->new({
            customerId => $customer_id_to_search,
            query      => $search_query,
          })});

    # Iterate over all elements to get all customer clients under the specified
    # customer's hierarchy.
    $search_stream_handler->process_contents(
      sub {
        my $google_ads_row  = shift;
        my $customer_client = $google_ads_row->{customerClient};

        # Get the CustomerClient object for the root customer in the tree.
        if ($customer_client->{id} == $root_customer_id) {
          $root_customer_client = $customer_client;
          $root_customer_clients->{$root_customer_id} = $root_customer_client;
        }

        # The steps below map parent and children accounts. Return here so that
        # manager accounts exclude themselves from the list of their children
        # accounts.
        if ($customer_client->{id} == $customer_id_to_search) {
          return;
        }

        # For all level-1 (direct child) accounts that are manager accounts, the
        # above query will be run against them to create a map of managers to their
        # child accounts for printing the hierarchy afterwards.
        push @{$customer_ids_to_child_accounts->{$customer_id_to_search}},
          $customer_client;

        # Check if the child account is a manager itself so that it can later be
        # processed and added to the map if it hasn't been already.
        if ($customer_client->{manager}) {
          # A customer can be managed by multiple managers, so to prevent visiting
          # the same customer multiple times, we need to check if it's already
          # in the map.
          my $already_visited =
            exists $customer_ids_to_child_accounts->{$customer_client->{id}};
          if (not $already_visited && $customer_client->{level} == 1) {
            push @$manager_customer_ids_to_search, $customer_client->{id};
          }
        }
      });
  }

  return $root_customer_client
    ? {$root_customer_client->{id} => $customer_ids_to_child_accounts}
    : undef;
}

# Prints the specified account's hierarchy using recursion.
sub print_account_hierarchy {
  my ($customer_client, $customer_ids_to_child_accounts, $depth) = @_;

  if ($depth == 0) {
    print "Customer ID (Descriptive Name, Currency Code, Time Zone)\n";
  }

  my $customer_id = $customer_client->{id};
  print "--" x $depth;
  printf
    " %d ('%s', '%s', '%s')\n",
    $customer_id,
    $customer_client->{descriptiveName} || "",
    $customer_client->{currencyCode},
    $customer_client->{timeZone};

  # Recursively call this function for all child accounts of $customer_client.
  if (exists $customer_ids_to_child_accounts->{$customer_id}) {
    foreach
      my $child_account (@{$customer_ids_to_child_accounts->{$customer_id}})
    {
      print_account_hierarchy($child_account, $customer_ids_to_child_accounts,
        $depth + 1);
    }
  }
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
  "manager_customer_id=s" => \$manager_customer_id,
  "login_customer_id=s"   => \$login_customer_id
);

if ($manager_customer_id xor $login_customer_id) {
  die "Both the manager customer ID and login customer ID must be " .
    "provided together, or they must both be null.\n";
}

# Call the example.
get_account_hierarchy(
  $api_client,
  $manager_customer_id ? $manager_customer_id =~ s/-//gr
  : undef,
  $login_customer_id ? $login_customer_id =~ s/-//gr
  : undef
);

=pod

=head1 NAME

get_account_hierarchy

=head1 DESCRIPTION

Gets the account hierarchy of the specified manager customer ID and login customer
ID. If you don't specify them, the example will instead print the hierarchies
of all accessible customer accounts for your authenticated Google account.

Note that if the list of accessible customers for your authenticated Google
account includes accounts within the same hierarchy, this example will retrieve
and print the overlapping portions of the hierarchy for each accessible customer.

=head1 SYNOPSIS

get_account_hierarchy.pl [options]

    -help                       Show the help message.
    -manager_customer_id        [optional] The Google Ads manager customer ID.
    -login_customer_id          [optional] The login customer ID.

=cut
