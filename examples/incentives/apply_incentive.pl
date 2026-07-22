#!/usr/bin/perl -w
#
# Copyright 2026, Google LLC
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
# This example applies an incentive to a user's account.
#
# This example is a no-op if the user already has an accepted incentive.
# If the user attempts to apply a new incentive, the response will simply
# return the existing incentive that has already been applied to the account.
# Use the fetch_incentives.pl example to get the available incentives.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use
  Google::Ads::GoogleAds::V25::Services::IncentiveService::ApplyIncentiveRequest;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);

sub apply_incentive {
  my ($api_client, $customer_id, $incentive_id, $country_code) = @_;

  my $apply_incentive_request =
    Google::Ads::GoogleAds::V25::Services::IncentiveService::ApplyIncentiveRequest
    ->new({
      customerId          => $customer_id,
      selectedIncentiveId => $incentive_id,
      countryCode         => $country_code
    });

  # Issue the request.
  my $apply_incentive_response =
    $api_client->IncentiveService()->apply_incentive($apply_incentive_request);

  # Process the response.
  print "Applied incentive.\n";
  printf "Coupon Code: %s\n",   $apply_incentive_response->{couponCode};
  printf "Creation Time: %s\n", $apply_incentive_response->{creationTime};

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

# Initialize the command line parameters.
my $customer_id;
my $incentive_id;
my $country_code;

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s"  => \$customer_id,
  "incentive_id=i" => \$incentive_id,
  "country_code=s" => \$country_code
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $incentive_id, $country_code);

# Call the example.
apply_incentive($api_client, $customer_id =~ s/-//gr,
  $incentive_id, $country_code);

=pod

=head1 NAME

apply_incentive

=head1 DESCRIPTION

This example applies an incentive to a user's account. This example is a no-op
if the user already has an accepted incentive. If the user attempts to apply a new
incentive, the response will simply return the existing incentive that has already
been applied to the account. Use the fetch_incentives.pl example to get the
available incentives.

=head1 SYNOPSIS

apply_incentive.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -incentive_id               The ID of the incentive to apply.
    -country_code               The country code of the user (e.g. 'US').

=cut
