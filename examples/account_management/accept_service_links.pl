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
# This code example accepts all pending invitations from Google Merchant Center
# accounts to your Google Ads account.

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
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub accept_service_links {
  my ($api_client, $customer_id) = @_;

  # Get the MerchantCenterLinkService.
  my $merchant_center_link_service = $api_client->MerchantCenterLinkService();

  # Retrieve all the existing Merchant Center links.
  my $response =
    $merchant_center_link_service->list({customerId => $customer_id});

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
accept_service_links($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

accept_service_links

=head1 DESCRIPTION

This code example accepts all pending invitations from Google Merchant Center
accounts to your Google Ads account.

=head1 SYNOPSIS

accept_service_links.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
