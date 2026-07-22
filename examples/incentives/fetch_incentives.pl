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
# This example returns incentives for a given user.
#
# To apply an incentive, use apply_incentive.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use
  Google::Ads::GoogleAds::V25::Services::IncentiveService::FetchIncentiveRequest;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use JSON;

sub fetch_incentives {
  my ($api_client, $email_address, $language_code, $country_code) = @_;

  my $fetch_incentives_request =
    Google::Ads::GoogleAds::V25::Services::IncentiveService::FetchIncentiveRequest
    ->new({
      email        => $email_address,
      languageCode => $language_code,
      countryCode  => $country_code,
      type         => "ACQUISITION"
    });

  # Issue the request.
  my $fetch_incentives_response =
    $api_client->IncentiveService()->fetch_incentive($fetch_incentives_request);

  # Process the response.
  if ( $fetch_incentives_response->{incentiveOffer}
    && $fetch_incentives_response->{incentiveOffer}{cyoIncentives})
  {
    print "Fetched incentive.\n";
    # If the offer type is CHOOSE_YOUR_OWN_INCENTIVE, there will be three
    # incentives in the response. At the time this example was written, all
    # incentive offers are CYO incentive offers.
    my $cyo_incentives =
      $fetch_incentives_response->{incentiveOffer}{cyoIncentives};
    print_incentive_details($cyo_incentives->{lowOffer});
    print_incentive_details($cyo_incentives->{mediumOffer});
    print_incentive_details($cyo_incentives->{highOffer});
  } else {
    print "No incentives found.\n";
  }

  return 1;
}

sub print_incentive_details {
  my ($incentive) = @_;

  return unless defined $incentive;

  printf "Incentive ID: '%s'.\n",        $incentive->{incentiveId};
  printf "Incentive requirement: %s.\n", encode_json($incentive->{requirement});
  printf "Incentive terms and conditions: %s.\n",
    $incentive->{incentiveTermsAndConditionsUrl};
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
my $email_address;
my $language_code = "en";
my $country_code  = "US";

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "email_address=s" => \$email_address,
  "language_code=s" => \$language_code,
  "country_code=s"  => \$country_code
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($email_address);

# Call the example.
fetch_incentives($api_client, $email_address, $language_code, $country_code);

=pod

=head1 NAME

fetch_incentives

=head1 DESCRIPTION

This example returns incentives for a given user. To apply an incentive, use
apply_incentive.pl.

=head1 SYNOPSIS

fetch_incentives.pl [options]

    -help                       Show the help message.
    -email_address              The email of the user to fetch incentives for.
    -language_code              [optional] The language code of the user (e.g. 'en').
    -country_code               [optional] The country code of the user (e.g. 'US').

=cut
