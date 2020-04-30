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
# This example retrieves all account budgets for a Google Ads customer.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use
  Google::Ads::GoogleAds::V3::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;

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
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub get_account_budgets {
  my ($api_client, $customer_id) = @_;

  # Create a query that retrieves the account budgets.
  my $search_query =
    "SELECT account_budget.status, account_budget.billing_setup, " .
    "account_budget.approved_spending_limit_micros, " .
    "account_budget.approved_spending_limit_type, " .
    "account_budget.proposed_spending_limit_micros, " .
    "account_budget.proposed_spending_limit_type, " .
    "account_budget.adjusted_spending_limit_micros, " .
    "account_budget.adjusted_spending_limit_type, " .
    "account_budget.approved_start_date_time, " .
    "account_budget.proposed_start_date_time, " .
    "account_budget.approved_end_date_time, " .
    "account_budget.approved_end_time_type, " .
    "account_budget.proposed_end_date_time, " .
    "account_budget.proposed_end_time_type FROM account_budget";

  # Create a search Google Ads stream request that will retrieve the account
  # budgets.
  my $search_stream_request =
    Google::Ads::GoogleAds::V3::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
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

  # Issue a search request and process the stream response to print the requested
  # field values for the account budget in each row.
  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row = shift;
      my $account_budget = $google_ads_row->{accountBudget};

      printf
        "Found the account budget '%s' with status '%s', billing setup '%s', "
        . "amount served %.2f, total adjustments %.2f,\n"
        . "  approved spending limit '%s' (proposed '%s', adjusted '%s'),\n"
        . "  approved start time '%s' (proposed '%s'),\n"
        . "  approved end time '%s' (proposed '%s').\n",
        $account_budget->{resourceName}, $account_budget->{status},
        $account_budget->{billingSetup} ? $account_budget->{billingSetup}
        : "none",
        $account_budget->{amountServedMicros}
        ? $account_budget->{amountServedMicros} / 1000000.0
        : 0.0,
        $account_budget->{totalAdjustmentsMicros}
        ? $account_budget->{totalAdjustmentsMicros} / 1000000.0
        : 0.0,
        $account_budget->{approvedSpendingLimitMicros} ? sprintf "%.2f",
        $account_budget->{approvedSpendingLimitMicros} / 1000000.0
        : $account_budget->{approvedSpendingLimitType},
        $account_budget->{proposedSpendingLimitMicros} ? sprintf "%.2f",
        $account_budget->{proposedSpendingLimitMicros} / 1000000.0
        : $account_budget->{proposedSpendingLimitType},
        $account_budget->{adjustedSpendingLimitMicros} ? sprintf "%.2f",
        $account_budget->{adjustedSpendingLimitMicros} / 1000000.0
        : $account_budget->{adjustedSpendingLimitType},
        $account_budget->{approvedStartDateTime}
        ? $account_budget->{approvedStartDateTime}
        : "none",
        $account_budget->{proposedStartDateTime}
        ? $account_budget->{proposedStartDateTime}
        : "none",
        $account_budget->{approvedEndDateTime}
        ? $account_budget->{approvedEndDateTime}
        : $account_budget->{approvedEndTimeType},
        $account_budget->{proposedEndDateTime}
        ? $account_budget->{proposedEndDateTime}
        : $account_budget->{proposedEndTimeType};
    });

  return 1;
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new({version => "V3"});

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions("customer_id=s" => \$customer_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
get_account_budgets($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

get_account_budgets

=head1 DESCRIPTION

This example retrieves all account budgets for a Google Ads customer.

=head1 SYNOPSIS

get_account_budgets.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
