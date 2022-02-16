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
# This example lists basic information about an advertising account.
# For instance, the name, currency, time zone etc.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

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

sub get_account_information {
  my ($api_client, $customer_id) = @_;

  # Construct a query to retrieve the customer.
  my $query =
    "SELECT customer.id, customer.descriptive_name, customer.currency_code, " .
    "customer.time_zone, customer.tracking_url_template, " .
    "customer.auto_tagging_enabled FROM customer " .
    # Limit to 1 to clarify that selecting from the customer resource
    # will always return only one row, which will be for the customer
    # ID specified in the request.
    "LIMIT 1";

  # Execute the query and get the Customer object from the single row of the response.
  my $search_response = $api_client->GoogleAdsService()->search({
    customerId => $customer_id,
    query      => $query
  });
  my $google_ads_row = $search_response->{results}[0];
  my $customer       = $google_ads_row->{customer};

  # Print account information.
  printf "Customer with ID %d, descriptive name '%s', currency code '%s', " .
    "timezone '%s', tracking URL template '%s' " .
    "and auto tagging enabled '%s' was retrieved.\n",
    $customer->{id}, $customer->{descriptiveName}, $customer->{currencyCode},
    $customer->{timeZone},
    $customer->{trackingUrlTemplate} ? $customer->{trackingUrlTemplate} : "",
    to_boolean($customer->{autoTaggingEnabled});

  return 1;
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
GetOptions("customer_id=s" => \$customer_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
get_account_information($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

get_account_information

=head1 DESCRIPTION

This example lists basic information about an advertising account. For instance,
the name, currency, time zone etc.

=head1 SYNOPSIS

get_account_information.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
