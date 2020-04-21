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

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V3::Resources::MerchantCenterLink;
use Google::Ads::GoogleAds::V3::Enums::MerchantCenterLinkStatusEnum
  qw(ENABLED PENDING);
use
  Google::Ads::GoogleAds::V3::Services::MerchantCenterLinkService::MerchantCenterLinkOperation;

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

  # List all Merchant Center links of the specified customer ID.
  my $merchant_center_link_service = $api_client->MerchantCenterLinkService();
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

    # Approve a pending link request for a Google Ads account with the specified
    # customer ID from a Merchant Center account with the specified merchant center account ID.

  }







  # Iterate the results, and filter for links with pending status.
  foreach my $merchant_center_link (@{$response->{merchantCenterLinks}}) {
    if ($merchant_center_link->{status} eq PENDING) {
      # Enable the pending link.
      my $link_to_update =
        Google::Ads::GoogleAds::V3::Resources::MerchantCenterLink->new({
          resourceName => $merchant_center_link->{resourceName},
          status       => ENABLED
        });

      # Create a Merchant Center link operation.
      my $operation =
        Google::Ads::GoogleAds::V3::Services::MerchantCenterLinkService::MerchantCenterLinkOperation
        ->new({
          update     => $link_to_update,
          updateMask => all_set_fields_of($link_to_update)});

      # Issue a mutate request to update the link.
      my $mutate_response = $merchant_center_link_service->mutate({
        customerId => $customer_id,
        operation  => $operation
      });

      printf "Enabled a Merchant Center Link with resource name '%s' " .
        "to Google Ads account : %d.\n",
        $mutate_response->{result}{resourceName}, $customer_id;
    }
  }

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
approve_merchant_center_link($api_client, $customer_id =~ s/-//gr);

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

=head1 SYNOPSIS

approve_merchant_center_link.pl [options]

    -help                           Show the help message.
    -customer_id                    The Google Ads customer ID.
    -merchant_center_account_id     The Merchant Center account ID.

=cut
