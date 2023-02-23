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
# This example gets all account budget proposals. To add an account budget
# proposal, run add_account_budget_proposal.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use
  Google::Ads::GoogleAds::V13::Services::GoogleAdsService::SearchGoogleAdsRequest;

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
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub get_account_budget_proposals {
  my ($api_client, $customer_id) = @_;

  # Create a query that retrieves the account budget proposals.
  my $search_query =
    "SELECT account_budget_proposal.id, " .
    "account_budget_proposal.account_budget, " .
    "account_budget_proposal.billing_setup, " .
    "account_budget_proposal.status, " .
    "account_budget_proposal.proposed_name, " .
    "account_budget_proposal.proposed_notes, " .
    "account_budget_proposal.proposed_purchase_order_number, " .
    "account_budget_proposal.proposal_type, " .
    "account_budget_proposal.approval_date_time, " .
    "account_budget_proposal.creation_date_time " .
    "FROM account_budget_proposal";

  # Create a search Google Ads request that will retrieve the account budget
  # proposals using pages of the specified page size.
  my $search_request =
    Google::Ads::GoogleAds::V13::Services::GoogleAdsService::SearchGoogleAdsRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query,
      pageSize   => PAGE_SIZE
    });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $iterator = Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
    service => $google_ads_service,
    request => $search_request
  });

  # Iterate over all rows in all pages and print the requested field values for
  # the account budget proposal in each row.
  while ($iterator->has_next) {
    my $google_ads_row = $iterator->next;

    my $account_budget_proposal = $google_ads_row->{accountBudgetProposal};

    printf "Found the account budget proposal with ID %d, status '%s', " .
      "account budget '%s', billing setup '%s',\n" .
      "  proposed name '%s', proposed notes '%s',\n" .
      "  proposed PO number '%s', proposal type '%s'\n" .
      "  approval date time '%s', creation date time '%s'.\n",
      $account_budget_proposal->{id}, $account_budget_proposal->{status},
      $account_budget_proposal->{accountBudget},
      $account_budget_proposal->{billingSetup},
      $account_budget_proposal->{proposedName}
      ? $account_budget_proposal->{proposedName}
      : "none",
      $account_budget_proposal->{proposedNotes}
      ? $account_budget_proposal->{proposedNotes}
      : "none",
      $account_budget_proposal->{proposedPurchaseOrderNumber}
      ? $account_budget_proposal->{proposedPurchaseOrderNumber}
      : "none",
      $account_budget_proposal->{proposalType}
      ? $account_budget_proposal->{proposalType}
      : "none",
      $account_budget_proposal->{approvalDateTime},
      $account_budget_proposal->{creationDateTime};
  }

  return 1;
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
get_account_budget_proposals($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

get_account_budget_proposals

=head1 DESCRIPTION

This example gets all account budget proposals. To add an account budget proposal,
run add_account_budget_proposal.pl.

=head1 SYNOPSIS

get_account_budget_proposals.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
