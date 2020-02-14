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
# This example gets the account hierarchy of the specified manager account. If
# you don't specify manager customer ID, the example will instead print the
# hierarchies of all accessible customer accounts for your authenticated Google
# account.
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
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use
  Google::Ads::GoogleAds::V2::Services::GoogleAdsService::SearchGoogleAdsRequest;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

use constant PAGE_SIZE => 1000;

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $manager_customer_id = undef;

sub get_account_hierarchy {
  my ($api_client, $manager_customer_id) = @_;

  my $seed_customer_ids = [];
  if ($manager_customer_id) {
    push @$seed_customer_ids, $manager_customer_id;
  } else {
    # Issue a request for listing all accessible customers by this authenticated
    # Google account.
    my $customer_service     = $api_client->CustomerService();
    my $accessible_customers = $customer_service->list_accessible_customers();
    print "No manager customer ID is specified. The example will print the " .
      "hierarchies of all accessible customer IDs:\n";

    foreach
      my $customer_resource_name (@{$accessible_customers->{resourceNames}})
    {
      my $customer_id = $1 if $customer_resource_name =~ /(\d+)$/;
      print $customer_id, "\n";
      push @$seed_customer_ids, $customer_id;
    }
    print "\n";
  }

  my $google_ads_service = $api_client->GoogleAdsService();
  foreach my $seed_customer_id (@$seed_customer_ids) {
    # Create a query that retrieves all child accounts of the manager specified
    # in search calls below.
    my $search_query =
      "SELECT customer_client.client_customer, customer_client.level, " .
      "customer_client.manager, customer_client.descriptive_name, " .
      "customer_client.currency_code, customer_client.time_zone, " .
      "customer_client.id FROM customer_client";

    # Perform a breadth-first search algorithm to build an associative array mapping
    # managers to their child accounts ($customer_ids_to_child_accounts).
    my $unprocessed_customer_ids       = [$seed_customer_id];
    my $customer_ids_to_child_accounts = {};
    my $root_customer_client           = undef;
    while (@$unprocessed_customer_ids > 0) {
      my $customer_id = shift @$unprocessed_customer_ids;
      $customer_ids_to_child_accounts->{$customer_id} ||= [];
      # Issue a search request by specifying page size.
      my $search_request =
        Google::Ads::GoogleAds::V2::Services::GoogleAdsService::SearchGoogleAdsRequest
        ->new({
          customerId => $customer_id,
          query      => $search_query,
          pageSize   => PAGE_SIZE
        });
      my $iterator =
        Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
          service => $google_ads_service,
          request => $search_request
        });

      # Iterate over all rows in all pages to get all customer clients under the
      # specified customer's hierarchy.
      while ($iterator->has_next) {
        my $google_ads_row  = $iterator->next;
        my $customer_client = $google_ads_row->{customerClient};
        # The customer client that has level of 0 is the specified customer.
        if ($customer_client->{level} == 0) {
          # Store the root customer client, which is the first encountered
          # customer client that has level of 0.
          $root_customer_client = $customer_client
            if not $root_customer_client;
          next;
        }

        # For all level-1 (direct child) accounts that are a manager account, the
        # above query will be run against them to create an associative array of
        # managers to their child accounts for printing the hierarchy afterwards.
        push @{$customer_ids_to_child_accounts->{$customer_id}},
          $customer_client;
        if ($customer_client->{manager}) {
          # A customer can be managed by multiple managers, so to prevent visiting
          # the same customer many times, we need to check if it's already in the
          # map.
          my $already_visited =
            exists $customer_ids_to_child_accounts->{$customer_client->{id}};
          if (not $already_visited && $customer_client->{level} == 1) {
            push @$unprocessed_customer_ids, $customer_client->{id};
          }
        }
      }
    }

    printf
      "The hierarchy of customer ID %d is printed below:\n",
      $root_customer_client->{id};
    print_account_hierarchy($root_customer_client,
      $customer_ids_to_child_accounts, 0);
  }
  return 1;
}

# Prints the specified account's hierarchy using recursion.
sub print_account_hierarchy {
  my ($customer_client, $customer_ids_to_child_accounts, $depth) = @_;

  print "Customer ID (Descriptive Name, Currency Code, Time Zone)\n"
    if $depth == 0;

  my $customer_id = $customer_client->{id};
  print "--" x $depth;
  printf
    " %d ('%s', '%s', '%s')\n",
    $customer_id,
    $customer_client->{descriptiveName},
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
my $api_client = Google::Ads::GoogleAds::Client->new({version => "V2"});

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions("manager_customer_id=s" => \$manager_customer_id);

# Call the example.
get_account_hierarchy($api_client,
    $manager_customer_id
  ? $manager_customer_id =~ s/-//gr
  : undef);

=pod

=head1 NAME

get_account_hierarchy

=head1 DESCRIPTION

This example gets the account hierarchy of the specified manager account. If you
don't specify manager customer ID, the example will instead print the hierarchies
of all accessible customer accounts for your authenticated Google account.

Note that if the list of accessible customers for your authenticated Google account
includes accounts within the same hierarchy, this example will retrieve and print
the overlapping portions of the hierarchy for each accessible customer.

=head1 SYNOPSIS

get_account_hierarchy.pl [options]

    -help                        Show the help message.
    -manager_customer_id         [optional] The Google Ads manager customer ID.

=cut
