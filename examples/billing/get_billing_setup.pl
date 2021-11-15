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
# This sample gets all BillingSetup objects available for the specified customer
# ID.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use
  Google::Ads::GoogleAds::V9::Services::GoogleAdsService::SearchGoogleAdsRequest;

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

# [START get_billing_setup]
sub get_billing_setup {
  my ($api_client, $customer_id) = @_;

  # Create a query that retrieves the billing setups.
  my $search_query =
    "SELECT billing_setup.id, billing_setup.status, " .
    "billing_setup.payments_account, " .
    "billing_setup.payments_account_info.payments_account_id, " .
    "billing_setup.payments_account_info.payments_account_name, " .
    "billing_setup.payments_account_info.payments_profile_id, " .
    "billing_setup.payments_account_info.payments_profile_name, " .
    "billing_setup.payments_account_info.secondary_payments_profile_id " .
    "FROM billing_setup";

  # Create a search Google Ads request that will retrieve the billing setups
  # using pages of the specified page size.
  my $search_request =
    Google::Ads::GoogleAds::V9::Services::GoogleAdsService::SearchGoogleAdsRequest
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
  # the billing setup in each row.
  while ($iterator->has_next) {
    my $google_ads_row = $iterator->next;

    my $billing_setup        = $google_ads_row->{billingSetup};
    my $payment_account_info = $billing_setup->{paymentsAccountInfo};

    if (!$payment_account_info) {
      printf "Found the billing setup with ID %d, status '%s' " .
        "with no payment account info.\n", $billing_setup->{id},
        $billing_setup->{status};
      next;
    }

    printf "Found the billing setup with ID %d, status '%s', " .
      "payments account '%s', " .
      "payments account ID '%s', payments account name '%s', " .
      "payments profile ID '%s', payments profile name '%s', " .
      "secondary payments profile ID '%s'.\n",

      $billing_setup->{id}, $billing_setup->{status},
      $billing_setup->{paymentsAccount},
      $payment_account_info->{paymentsAccountId},
      $payment_account_info->{paymentsAccountName},
      $payment_account_info->{paymentsProfileId},
      $payment_account_info->{paymentsProfileName},
      $payment_account_info->{secondaryPaymentsProfileId}
      ? $payment_account_info->{secondaryPaymentsProfileId}
      : "None";
  }

  return 1;
}
# [END get_billing_setup]

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
get_billing_setup($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

get_billing_setup

=head1 DESCRIPTION

This sample gets all BillingSetup objects available for the specified customer ID.

=head1 SYNOPSIS

get_billing_setup.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
