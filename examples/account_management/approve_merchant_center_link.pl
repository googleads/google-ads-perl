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
# Demonstrates how to approve a Merchant Center link request.
#
# Prerequisite: You need to have access to a Merchant Center account. You can find
# instructions to create a Merchant Center account here:
# https://support.google.com/merchants/answer/188924.
#
# To run this example, you must use the Merchant Center UI or the Content API for
# Shopping to send a link request between your Merchant Center and Google Ads accounts.
# See https://support.google.com/merchants/answer/6159060 for details.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V11::Resources::MerchantCenterLink;
use Google::Ads::GoogleAds::V11::Enums::MerchantCenterLinkStatusEnum
  qw(ENABLED PENDING);
use
  Google::Ads::GoogleAds::V11::Services::MerchantCenterLinkService::MerchantCenterLinkOperation;

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
my $customer_id                = "INSERT_CUSTOMER_ID_HERE";
my $merchant_center_account_id = "INSERT_MERCHANT_CENTER_ACCOUNT_ID_HERE";

sub approve_merchant_center_link {
  my ($api_client, $customer_id, $merchant_center_account_id) = @_;

  # [START approve_merchant_center_link]
  # List all Merchant Center links of the specified customer ID.
  my $merchant_center_link_service = $api_client->MerchantCenterLinkService();
  my $response =
    $merchant_center_link_service->list({customerId => $customer_id});
  printf
    "%d Merchant Center link(s) found with the following details:\n",
    scalar @{$response->{merchantCenterLinks}};
  # [END approve_merchant_center_link]

  # [START approve_merchant_center_link_2]
  foreach my $merchant_center_link (@{$response->{merchantCenterLinks}}) {
    # [START approve_merchant_center_link_1]
    printf
      "Link '%s' has status '%s'.\n",
      $merchant_center_link->{resourceName},
      $merchant_center_link->{status};
    # [END approve_merchant_center_link_1]

    # Approve a pending link request for a Google Ads account with the specified
    # customer ID from a Merchant Center account with the specified Merchant
    # Center account ID.
    if ( $merchant_center_link->{id} == $merchant_center_account_id
      && $merchant_center_link->{status} eq PENDING)
    {
      # Update the status of Merchant Center link to 'ENABLED' to approve the link.
      update_merchant_center_link_status(
        $merchant_center_link_service, $customer_id,
        $merchant_center_link,         ENABLED
      );
      # There is only one MerchantCenterLink object for a given Google Ads account
      # and Merchant Center account, so we can break early.
      last;
    }
  }
  # [END approve_merchant_center_link_2]
  return 1;
}

# Updates the status of a Merchant Center link with a specified Merchant Center
# link status.
sub update_merchant_center_link_status {
  my ($merchant_center_link_service, $customer_id,
    $merchant_center_link, $new_merchant_center_link_status)
    = @_;

  # Create an updated MerchantCenterLink object derived from the original, but
  # with the specified status.
  my $merchant_center_link_to_update =
    Google::Ads::GoogleAds::V11::Resources::MerchantCenterLink->new({
      resourceName => $merchant_center_link->{resourceName},
      status       => $new_merchant_center_link_status
    });

  # Construct an operation that will update the Merchant Center link, using the
  # FieldMasks utility to derive the update mask. This mask tells the Google Ads
  # API which attributes of the Merchant Center link you want to change.
  my $merchant_center_link_operation =
    Google::Ads::GoogleAds::V11::Services::MerchantCenterLinkService::MerchantCenterLinkOperation
    ->new({
      update     => $merchant_center_link_to_update,
      updateMask => all_set_fields_of($merchant_center_link_to_update)});

  # Issue a mutate request to update the Merchant Center link and prints some
  # information.
  my $response = $merchant_center_link_service->mutate({
    customerId => $customer_id,
    operation  => $merchant_center_link_operation
  });

  printf "Approved a Merchant Center Link with resource name '%s' " .
    "to the Google Ads account '%s'.\n",
    $response->{result}{resourceName}, $customer_id;
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
  "customer_id=s"                => \$customer_id,
  "merchant_center_account_id=i" => \$merchant_center_account_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $merchant_center_account_id);

# Call the example.
approve_merchant_center_link($api_client, $customer_id =~ s/-//gr,
  $merchant_center_account_id);

=pod

=head1 NAME

approve_merchant_center_link

=head1 DESCRIPTION

Demonstrates how to approve a Merchant Center link request.

Prerequisite: You need to have access to a Merchant Center account. You can find
instructions to create a Merchant Center account here:
https://support.google.com/merchants/answer/188924.

To run this example, you must use the Merchant Center UI or the Content API for
Shopping to send a link request between your Merchant Center and Google Ads accounts.
See https://support.google.com/merchants/answer/6159060 for details.

=head1 SYNOPSIS

approve_merchant_center_link.pl [options]

    -help                           Show the help message.
    -customer_id                    The Google Ads customer ID.
    -merchant_center_account_id     The Merchant Center account ID.

=cut
