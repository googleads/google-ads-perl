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
# Demonstrates how to reject a Merchant Center link request.
#
# Prerequisite: You need to have access to a Merchant Center account. You can find
# instructions to create a Merchant Center account here:
# https://support.google.com/merchants/answer/188924.
#
# To run this example, you must use the Merchant Center UI or the Content API for
# Shopping to send a link request between your Merchant Center and Google Ads accounts.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use
  Google::Ads::GoogleAds::V14::Services::MerchantCenterLinkService::MerchantCenterLinkOperation;

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

# [START reject_merchant_center_link]
sub reject_merchant_center_link {
  my ($api_client, $customer_id, $merchant_center_account_id) = @_;

  my $merchant_center_link_service = $api_client->MerchantCenterLinkService();

  # Reject a pending link request or unlink an enabled link for a Google Ads
  # account with $customer_id from a Merchant Center account with $merchant_center_account_id.
  my $response =
    $merchant_center_link_service->list({customerId => $customer_id});
  printf
    "%d Merchant Center link(s) found with the following details:\n",
    scalar @{$response->{merchantCenterLinks}};

  foreach my $merchant_center_link (@{$response->{merchantCenterLinks}}) {
    printf
      "Link '%s' has status '%s'.\n",
      $merchant_center_link->{resourceName},
      $merchant_center_link->{status};

    # Check if there is a link for the Merchant Center account we are looking for.
    if ($merchant_center_account_id == $merchant_center_link->{id}) {
      # If the Merchant Center link is pending, reject it by removing the link.
      # If the Merchant Center link is enabled, unlink Merchant Center from Google
      # Ads by removing the link.
      # In both cases, the remove action is the same.
      remove_merchant_center_link($merchant_center_link_service, $customer_id,
        $merchant_center_link);
      # There is only one MerchantCenterLink object for a given Google Ads account
      # and Merchant Center account, so we can break early.
      last;
    }
  }
  return 1;
}
# [END reject_merchant_center_link]

# Removes a Merchant Center link from a Google Ads client customer account.
sub remove_merchant_center_link {
  my ($merchant_center_link_service, $customer_id, $merchant_center_link) = @_;

  # Create a single remove operation, specifying the Merchant Center link resource name.
  my $merchant_center_link_operation =
    Google::Ads::GoogleAds::V14::Services::MerchantCenterLinkService::MerchantCenterLinkOperation
    ->new({
      remove => $merchant_center_link->{resourceName}});

  # Issue a mutate request to remove the link and print the result info.
  my $response = $merchant_center_link_service->mutate({
    customerId => $customer_id,
    operation  => $merchant_center_link_operation
  });
  printf
    "Removed Merchant Center link with resource name: '%s'.\n",
    $response->{result}{resourceName};
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
reject_merchant_center_link($api_client, $customer_id =~ s/-//gr,
  $merchant_center_account_id);

=pod

=head1 NAME

reject_merchant_center_link

=head1 DESCRIPTION

Demonstrates how to reject a Merchant Center link request.

Prerequisite: You need to have access to a Merchant Center account. You can find
instructions to create a Merchant Center account here:
https://support.google.com/merchants/answer/188924.

To run this example, you must use the Merchant Center UI or the Content API for
Shopping to send a link request between your Merchant Center and Google Ads accounts.

=head1 SYNOPSIS

reject_merchant_center_link.pl [options]

    -help                           Show the help message.
    -customer_id                    The Google Ads customer ID.
    -merchant_center_account_id     The Merchant Center account ID.

=cut
