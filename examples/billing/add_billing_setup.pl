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
# This example creates a billing setup for a customer. A billing setup is a link
# between a payments account and a customer. The new billing setup can either reuse
# an existing payments account, or create a new payments account with a given
# payments profile.
#
# Billing setups are applicable for clients on monthly invoicing only. See here
# for details about applying for monthly invoicing:
# https://support.google.com/google-ads/answer/2375377.
#
# In the case of consolidated billing, a payments account is linked to the manager
# account and is linked to a customer account via a billing setup.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::BillingSetup;
use Google::Ads::GoogleAds::V23::Resources::PaymentsAccountInfo;
use
  Google::Ads::GoogleAds::V23::Services::BillingSetupService::BillingSetupOperation;
use Google::Ads::GoogleAds::V23::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);
use Date::Parse;
use POSIX qw(strftime);

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";
# Either a payments account ID or a payments profile ID must be provided for the
# example to run successfully. If both are provided, only the payments account ID
# will be used. See:
# https://developers.google.com/google-ads/api/docs/billing/billing-setups#creating_new_billing_setups
#
# Provide an existing payments account ID to link to the new billing setup. Must
# be formatted as "1234-5678-9012-3456".
my $payments_account_id = undef;
# Alternatively, provide a payments profile ID which will be linked to a new payments
# account and the new billing setup. Must be formatted as "1234-5678-9012".
my $payments_profile_id = undef;

sub add_billing_setup {
  my ($api_client, $customer_id, $payments_account_id, $payments_profile_id) =
    @_;

  # Construct a new billing setup.
  my $billing_setup = create_billing_setup($customer_id, $payments_account_id,
    $payments_profile_id);
  set_billing_setup_date_times($api_client, $customer_id, $billing_setup);

  my $billing_setup_operation =
    Google::Ads::GoogleAds::V23::Services::BillingSetupService::BillingSetupOperation
    ->new({
      create => $billing_setup
    });

  # Issue a mutate request to add the billing setup.
  my $billing_setup_response = $api_client->BillingSetupService()->mutate({
    customerId => $customer_id,
    operation  => $billing_setup_operation
  });

  printf
    "Added new billing setup with resource name '%s'.\n",
    $billing_setup_response->{result}{resourceName};

  return 1;
}

# Creates and returns a new billing setup instance with complete payment details.
# One of the payments account ID or payments profile ID must be provided.
sub create_billing_setup {
  my ($customer_id, $payments_account_id, $payments_profile_id) = @_;

  my $billing_setup =
    Google::Ads::GoogleAds::V23::Resources::BillingSetup->new();

  # Set the appropriate payments account field.
  if (defined $payments_account_id) {
    # If a payments account ID has been provided, set the resource name.
    # You can list available payments accounts via the PaymentsAccountService's
    # list method.
    $billing_setup->{paymentsAccount} =
      Google::Ads::GoogleAds::V23::Utils::ResourceNames::payments_account(
      $customer_id, $payments_account_id);
  } elsif (defined $payments_profile_id) {
    # Otherwise, create a new payments account by setting the payments account
    # info. See https://support.google.com/google-ads/answer/7268503 for more
    # information about payments profiles.
    $billing_setup->{paymentsAccountInfo} =
      Google::Ads::GoogleAds::V23::Resources::PaymentsAccountInfo->new({
        paymentsAccountName => "Payments Account #" . uniqid(),
        paymentsProfileId   => $payments_profile_id
      });
  } else {
    die "No payments account ID or payments profile ID is provided.\n";
  }

  return $billing_setup;
}

# Sets the starting and ending date times for the new billing setup. Queries the
# customer's account to see if there are any approved billing setups. If there are
# any, the new billing setup starting date time is set to one day after the last.
# If not, the billing setup is set to start immediately. The ending date is set
# to one day after the starting date time.
sub set_billing_setup_date_times {
  my ($api_client, $customer_id, $billing_setup) = @_;

  # The query to search existing approved billing setups in the end date time
  # descending order.
  # See get_billing_setup.pl for a more detailed example of how to retrieve
  # billing setups.
  my $search_query =
    "SELECT billing_setup.end_date_time " .
    "FROM billing_setup " .
    "WHERE billing_setup.status = 'APPROVED' " .
    "ORDER BY billing_setup.end_date_time DESC";

  # Issue a search request.
  my $search_response = $api_client->GoogleAdsService()->search({
    customerId => $customer_id,
    query      => $search_query
  });
  my $google_ads_row = $search_response->{results}[0];

  my $start_date = undef;
  if (defined $google_ads_row) {
    # Retrieve the ending date time of the last billing setup.
    my $last_ending_date_time_string =
      $google_ads_row->{billingSetup}{endDateTime};

    if (not $last_ending_date_time_string) {
      # A null ending date time indicates that the current billing setup is set
      # to run indefinitely. Billing setups cannot overlap, so die with error
      # in this case.
      die
        "Cannot set starting and ending date times for the new billing setup; "
        . "the latest existing billing setup is set to run indefinitely.\n";
    }

    # Set the new billing setup to start one day after the ending date time.
    $start_date = str2time($last_ending_date_time_string) + 60 * 60 * 24;
  } else {
    # Otherwise, the only acceptable start date time is today.
    $start_date = time;
  }

  $billing_setup->{startDateTime} =
    strftime("%Y-%m-%d", localtime($start_date));
  # Set the new billing setup to end one day after the starting date time.
  $billing_setup->{endDateTime} =
    strftime("%Y-%m-%d", localtime($start_date + 60 * 60 * 24));
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
  "customer_id=s"         => \$customer_id,
  "payments_account_id=s" => \$payments_account_id,
  "payments_profile_id=s" => \$payments_profile_id,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
add_billing_setup(
  $api_client,          $customer_id =~ s/-//gr,
  $payments_account_id, $payments_profile_id
);

=pod

=head1 NAME

add_billing_setup

=head1 DESCRIPTION

This example creates a billing setup for a customer. A billing setup is a link
between a payments account and a customer. The new billing setup can either reuse
an existing payments account, or create a new payments account with a given
payments profile.

Billing setups are applicable for clients on monthly invoicing only. See here
for details about applying for monthly invoicing:
https://support.google.com/google-ads/answer/2375377.

In the case of consolidated billing, a payments account is linked to the manager
account and is linked to a customer account via a billing setup.

=head1 SYNOPSIS

add_billing_setup.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -payments_account_id        [optional] The payments account ID to attach to the new billing setup.
                                Must be formatted as "1234-5678-9012-3456"
    -payments_profile_id        [optional] The payments profile ID to attach to a new payments account
                                and to the new billing setup. Must be formatted as "1234-5678-9012"

=cut
