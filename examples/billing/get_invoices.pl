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
# This code example retrieves the invoices issued last month for a given billing
# setup.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd   qw(abs_path);
use POSIX qw(strftime mktime);

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

sub get_invoices {
  my ($api_client, $customer_id, $billing_setup_id) = @_;

  # Get the date one month before now.
  my @current_month = localtime(time);
  $current_month[4] -= 1;
  my @last_month = localtime(mktime(@current_month));

  # [START get_invoices]
  # Issue the request.
  my $response = $api_client->InvoiceService()->list({
      customerId   => $customer_id,
      billingSetup =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::billing_setup(
        ($customer_id, $billing_setup_id)
        ),
      # The year needs to be 2019 or later.
      issueYear  => strftime("%Y", @last_month),
      issueMonth => uc(strftime("%B", @last_month))});
  # [END get_invoices]

  # [START get_invoices_1]
  # Iterate over all invoices retrieved and print their information.
  foreach my $invoice (@$response) {
    printf "- Found the invoice '%s':\n" .
      "  ID (also known as Invoice Number): '%s'\n" .
      "  Type: %s\n" .
      "  Billing setup ID: '%s'\n" .
      "  Payments account ID (also known as Billing Account Number): '%s'\n" .
      "  Payments profile ID (also known as Billing ID): '%s'\n" .
      "  Issue date (also known as Invoice Date): %s\n" .
      "  Due date: %s\n" .
      "  Currency code: %s\n" .
      "  Service date range (inclusive): from %s to %s\n" .
      "  Adjustments: subtotal '%.2f', tax '%.2f', total '%.2f'\n" .
      "  Regulatory costs: subtotal '%.2f', tax '%.2f', total '%.2f'\n" .
      "  Replaced invoices: '%s'\n" .
      "  Amounts: subtotal '%.2f', tax '%.2f', total '%.2f'\n" .
      "  Corrected invoice: '%s'\n" .
      "  PDF URL: '%s'\n" .
      "  Account budgets:\n",
      $invoice->{resourceName},
      $invoice->{id},
      $invoice->{type},
      $invoice->{billingSetup},
      $invoice->{paymentsAccountId},
      $invoice->{paymentsProfileId},
      $invoice->{issueDate},
      $invoice->{dueDate},
      $invoice->{currencyCode},
      $invoice->{serviceDateRange}{startDate},
      $invoice->{serviceDateRange}{endDate},
      micro_to_base($invoice->{adjustmentsSubtotalAmountMicros}),
      micro_to_base($invoice->{adjustmentsTaxAmountMicros}),
      micro_to_base($invoice->{adjustmentsTotalAmountMicros}),
      micro_to_base($invoice->{regulatoryCostsSubtotalAmountMicros}),
      micro_to_base($invoice->{regulatoryCostsTaxAmountMicros}),
      micro_to_base($invoice->{regulatoryCostsTotalAmountMicros}),
      $invoice->{replacedInvoices}
      ? join(',', @{$invoice->{replacedInvoices}})
      : "none",
      micro_to_base($invoice->{subtotalAmountMicros}),
      micro_to_base($invoice->{taxAmountMicros}),
      micro_to_base($invoice->{totalAmountMicros}),
      $invoice->{correctedInvoice} ? $invoice->{correctedInvoice} : "none",
      $invoice->{pdfUrl};

    foreach my $account_budget_summary (@{$invoice->{accountBudgetSummaries}}) {
      printf "  - Account budget '%s':\n" .
        "      Name (also known as Account Budget): '%s'\n" .
        "      Customer (also known as Account ID): '%s'\n" .
        "      Customer descriptive name (also known as Account): '%s'\n" .
        "      Purchase order number (also known as Purchase Order): '%s'\n" .
        "      Billing activity date range (inclusive): from %s to %s\n" .
        "      Amounts: subtotal '%.2f', tax '%.2f', total '%.2f'\n",
        $account_budget_summary->{accountBudget},
        $account_budget_summary->{accountBudgetName}
        ? $account_budget_summary->{accountBudgetName}
        : "none",
        $account_budget_summary->{customer},
        $account_budget_summary->{customerDescriptiveName}
        ? $account_budget_summary->{customerDescriptiveName}
        : "none",
        $account_budget_summary->{purchaseOrderNumber}
        ? $account_budget_summary->{purchaseOrderNumber}
        : "none",
        $account_budget_summary->{billableActivityDateRange}{startDate},
        $account_budget_summary->{billableActivityDateRange}{endDate},
        $account_budget_summary->{subtotalAmountMicros},
        $account_budget_summary->{taxAmountMicros},
        $account_budget_summary->{totalAmountMicros};
    }
  }
  # [END get_invoices_1]

  return 1;
}

# Converts an amount from the micro unit to the base unit.
sub micro_to_base() {
  my $amount = shift;
  return $amount ? $amount / 1000000.0 : 0.0;
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
  "customer_id=s"      => \$customer_id,
  "billing_setup_id=i" => \$billing_setup_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $billing_setup_id);

# Call the example.
get_invoices($api_client, $customer_id =~ s/-//gr, $billing_setup_id);

=pod

=head1 NAME

get_invoices

=head1 DESCRIPTION

This code example retrieves the invoices issued last month for a given billing setup.

=head1 SYNOPSIS

get_invoices.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -billing_setup_id           The billing setup ID to filter the invoices on.

=cut
