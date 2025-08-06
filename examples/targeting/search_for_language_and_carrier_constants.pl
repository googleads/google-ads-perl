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
# This example illustrates how to:
# 1. Search for language constants where the name includes a given string.
# 2. Search for all the available mobile carrier constants with a given country code.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use
  Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;

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
my $customer_id   = "INSERT_CUSTOMER_ID_HERE";
my $language_name = "eng";
# A list of country codes can be referenced here:
# https://developers.google.com/google-ads/api/reference/data/geotargets.
my $carrier_country_code = "US";

sub search_for_language_and_carrier_constants {
  my ($api_client, $customer_id, $language_name, $carrier_country_code) = @_;

  search_for_language_constants($api_client, $customer_id, $language_name);

  search_for_carrier_constants($api_client, $customer_id,
    $carrier_country_code);

  return 1;
}

# Searches for language constants where the name includes a given string.
sub search_for_language_constants {
  my ($api_client, $customer_id, $language_name) = @_;

  # Create a query that retrieves the language constants where the name includes
  # a given string.
  my $search_query =
    "SELECT language_constant.id, language_constant.code, " .
    "language_constant.name, language_constant.targetable " .
    "FROM language_constant " .
    "WHERE language_constant.name LIKE '%$language_name%'";

  # Create a search Google Ads stream request that will retrieve the language
  # constants.
  my $search_stream_request =
    Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query
    });

  my $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $api_client->GoogleAdsService(),
      request => $search_stream_request
    });

  # Issue a search request and process the stream response to print the requested
  # field values for the language constant in each row.
  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row = shift;
      printf "Language with ID %d, code '%s', name '%s' " .
        "and targetable '%s' was found.\n",
        $google_ads_row->{languageConstant}{id},
        $google_ads_row->{languageConstant}{code},
        $google_ads_row->{languageConstant}{name},
        to_boolean($google_ads_row->{languageConstant}{targetable});
    });
}

# Searches for all the available mobile carrier constants with a given country code.
sub search_for_carrier_constants {
  my ($api_client, $customer_id, $carrier_country_code) = @_;

  # Create a query that retrieves the targetable carrier constants by country code.
  my $search_query =
    "SELECT carrier_constant.id, carrier_constant.name, " .
    "carrier_constant.country_code FROM carrier_constant " .
    "WHERE carrier_constant.country_code = '$carrier_country_code'";

  # Create a search Google Ads stream request that will retrieve the carrier
  # constants.
  my $search_stream_request =
    Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query
    });

  my $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $api_client->GoogleAdsService(),
      request => $search_stream_request
    });

  # Issue a search request and process the stream response to print the requested
  # field values for the carrier constant in each row.
  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row = shift;
      printf
        "Carrier with ID %d, name '%s' and country code '%s' was found.\n",
        $google_ads_row->{carrierConstant}{id},
        $google_ads_row->{carrierConstant}{name},
        $google_ads_row->{carrierConstant}{countryCode};
    });
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
  "customer_id=s"          => \$customer_id,
  "language_name=s"        => \$language_name,
  "carrier_country_code=s" => \$carrier_country_code,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $language_name, $carrier_country_code);

# Call the example.
search_for_language_and_carrier_constants($api_client, $customer_id,
  $language_name, $carrier_country_code);

=pod

=head1 NAME

search_for_language_and_carrier_constants

=head1 DESCRIPTION

This example illustrates how to:
1. Search for language constants where the name includes a given string.
2. Search for all the available mobile carrier constants with a given country code.

=head1 SYNOPSIS

search_for_language_and_carrier_constants.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -language_name              [optional] The string included in the language
                                name to search for.
    -carrier_country_code       [optional] The code of the country where the mobile
                                carriers are located, e.g. "US", "ES", etc.

=cut
