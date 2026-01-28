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
# This example creates an account budget proposal using the 'CREATE' operation.
# To get account budget proposals, run get_account_budget_proposals.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::AccountBudgetProposal;
use Google::Ads::GoogleAds::V23::Enums::AccountBudgetProposalTypeEnum
  qw(CREATE);
use Google::Ads::GoogleAds::V23::Enums::TimeTypeEnum qw(NOW FOREVER);
use
  Google::Ads::GoogleAds::V23::Services::AccountBudgetProposalService::AccountBudgetProposalOperation;
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
my $customer_id      = "INSERT_CUSTOMER_ID_HERE";
my $billing_setup_id = "INSERT_BILLING_SETUP_ID_HERE";

# [START add_account_budget_proposal]
sub add_account_budget_proposal {
  my ($api_client, $customer_id, $billing_setup_id) = @_;

  # Create an account budget proposal.
  my $account_budget_proposal =
    Google::Ads::GoogleAds::V23::Resources::AccountBudgetProposal->new({
      billingSetup =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::billing_setup(
        $customer_id, $billing_setup_id
        ),
      proposalType => CREATE,
      proposedName => "Account Budget (example)",
      # Specify that the account budget starts immediately.
      proposedStartTimeType => NOW,
      # Alternatively you can specify a specific start time. Refer to the
      # AccountBudgetProposal class for allowed formats.
      #
      # proposedStartDateTime => "2020-01-02 03:04:05",

      # Specify that the account budget runs forever.
      proposedEndDateTime => FOREVER,
      # Alternatively you can specify a specific end time. Allowed formats are as below.
      # proposedEndDateTime => "2021-02-03 04:05:06",

      # Optional: set notes for the budget. These are free text and do not effect budget
      # delivery.
      # proposedNotes => "Received prepayment of $0.01",

      # Optional: set PO number for record keeping. This value is at the user's
      # discretion, and has no effect on Google Billing & Payments.
      # proposedPurchaseOrderNumber => "PO number 12345",

      # Set the spending limit to 0.01, measured in the Google Ads account currency.
      proposedSpendingLimitMicros => 10000
    });

  # Create an account budget proposal operation.
  my $account_budget_proposal_operation =
    Google::Ads::GoogleAds::V23::Services::AccountBudgetProposalService::AccountBudgetProposalOperation
    ->new({
      create => $account_budget_proposal
    });

  # Add the account budget proposal.
  my $account_budget_proposal_response =
    $api_client->AccountBudgetProposalService()->mutate({
      customerId => $customer_id,
      operation  => $account_budget_proposal_operation
    });

  printf "Created account budget proposal '%s'.\n",
    $account_budget_proposal_response->{result}{resourceName};

  return 1;
}
# [END add_account_budget_proposal]

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
  "customer_id=s"      => \$customer_id,
  "billing_setup_id=i" => \$billing_setup_id,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $billing_setup_id);

# Call the example.
add_account_budget_proposal($api_client, $customer_id =~ s/-//gr,
  $billing_setup_id);

=pod

=head1 NAME

add_account_budget_proposal

=head1 DESCRIPTION

This example creates an account budget proposal using the 'CREATE' operation. To get
account budget proposals, run get_account_budget_proposals.pl.

=head1 SYNOPSIS

add_account_budget_proposal.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -billing_setup_id           The billing setup ID.

=cut
