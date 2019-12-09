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
# This example removes a BillingSetup, specified by ID. To get available
# BillingSetups, run get_billing_setup.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::GoogleAdsClient;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use
  Google::Ads::GoogleAds::V2::Services::BillingSetupService::BillingSetupOperation;
use Google::Ads::GoogleAds::V2::Utils::ResourceNames;

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

sub remove_billing_setup {
  my ($api_client, $customer_id, $billing_setup_id) = @_;

  # Create the resource name of a billing setup to remove.
  my $billing_setup_resource_name =
    Google::Ads::GoogleAds::V2::Utils::ResourceNames::billing_setup(
    $customer_id, $billing_setup_id);

  # Create a billing setup operation.
  my $billing_setup_operation =
    Google::Ads::GoogleAds::V2::Services::BillingSetupService::BillingSetupOperation
    ->new({
      remove => $billing_setup_resource_name
    });

  # Remove the billing setup.
  my $billing_setup_response = $api_client->BillingSetupService->mutate({
    customerId => $customer_id,
    operation  => $billing_setup_operation
  });

  printf "Removed billing setup with resource name: '%s'.\n",
    $billing_setup_response->{result}{resourceName};

  return 1;
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client =
  Google::Ads::GoogleAds::GoogleAdsClient->new({version => "V2"});

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
remove_billing_setup($api_client, $customer_id =~ s/-//gr, $billing_setup_id);

=pod

=head1 NAME

remove_billing_setup

=head1 DESCRIPTION

This example removes a BillingSetup, specified by ID. To get available BillingSetups,
run get_billing_setup.pl.

=head1 SYNOPSIS

remove_billing_setup.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -billing_setup_id           The billing setup ID.

=cut
