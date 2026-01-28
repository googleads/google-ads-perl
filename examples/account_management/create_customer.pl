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
# This example illustrates how to create a new customer under a given manager
# account.
#
# Note: This example must be run using the credentials of a Google Ads manager
# account. By default, the new account will only be accessible via the manager
# account.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::Customer;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $manager_customer_id = "INSERT_MANAGER_CUSTOMER_ID_HERE";

# [START create_customer]
sub create_customer {
  my ($api_client, $manager_customer_id) = @_;

  # Initialize a customer to be created.
  my $customer = Google::Ads::GoogleAds::V23::Resources::Customer->new({
      descriptiveName => "Account created with CustomerService on #" . uniqid(),

      # For a list of valid currency codes and time zones, see this documentation:
      # https://developers.google.com/google-ads/api/reference/data/codes-formats
      currencyCode => "USD",
      timeZone     => "America/New_York",

      # The below values are optional. For more information about URL options, see:
      # https://support.google.com/google-ads/answer/6305348
      trackingUrlTemplate => "{lpurl}?device={device}",
      finalUrlSuffix      =>
        "keyword={keyword}&matchtype={matchtype}&adgroupid={adgroupid}"
  });

  # Create the customer client.
  my $create_customer_client_response =
    $api_client->CustomerService()->create_customer_client({
      customerId     => $manager_customer_id,
      customerClient => $customer
    });

  printf
    "Created a customer with resource name '%s' under the manager account " .
    "with customer ID %d.\n", $create_customer_client_response->{resourceName},
    $manager_customer_id;

  return 1;
}
# [END create_customer]

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions("manager_customer_id=s" => \$manager_customer_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($manager_customer_id);

# Call the example.
create_customer($api_client, $manager_customer_id =~ s/-//gr);

=pod

=head1 NAME

create_customer

=head1 DESCRIPTION

This example illustrates how to create a new customer under a given manager account.

Note: This example must be run using the credentials of a Google Ads manager account.
By default, the new account will only be accessible via the manager account.

=head1 SYNOPSIS

create_customer.pl [options]

    -help                       Show the help message.
    -manager_customer_id        The Google Ads manager customer ID.

=cut
