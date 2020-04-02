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
# This example illustrates how to search for language and mobile carrier constants
# by names that are available for targeting.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use
  Google::Ads::GoogleAds::V3::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;

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
# A list of languages can be referenced here:
# https://developers.google.com/adwords/api/docs/appendix/codes-formats#languages.
my $language_name = "English";
# A list of mobile carriers can be referenced here:
# https://developers.google.com/adwords/api/docs/appendix/codes-formats#mobile-carriers.
my $carrier_name = "Vodafone";

sub search_for_targetable_languages_and_carriers {
  my ($api_client, $customer_id, $language_name, $carrier_name) = @_;

  # Create a query that retrieves the targetable language constants by name.
  my $search_query =
    "SELECT language_constant.id, language_constant.code, " .
    "language_constant.name FROM language_constant " .
    "WHERE language_constant.name = '$language_name' " .
    "AND language_constant.targetable  = 'true'";

  # Create a search Google Ads stream request that will retrieve the language
  # constants.
  my $search_stream_request =
    Google::Ads::GoogleAds::V3::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query
    });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $google_ads_service,
      request => $search_stream_request
    });

  # Issue a search request and process the stream response to print the requested
  # field values for the language constant in each row.
  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row = shift;
      printf
        "Language with ID %d, code '%s' and name '%s' was found.\n",
        $google_ads_row->{languageConstant}{id},
        $google_ads_row->{languageConstant}{code},
        $google_ads_row->{languageConstant}{name};
    });

  # Create a query that retrieves the targetable carrier constants by name.
  $search_query =
    "SELECT carrier_constant.id, carrier_constant.name, " .
    "carrier_constant.country_code FROM carrier_constant " .
    "WHERE carrier_constant.name = '$carrier_name'";

  # Create a search Google Ads stream request that will retrieve the carrier
  # constants.
  $search_stream_request =
    Google::Ads::GoogleAds::V3::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query
    });

  $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $google_ads_service,
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
GetOptions(
  "customer_id=s"   => \$customer_id,
  "language_name=s" => \$language_name,
  "carrier_name=s"  => \$carrier_name,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $language_name, $carrier_name);

# Call the example.
search_for_targetable_languages_and_carriers($api_client, $customer_id,
  $language_name, $carrier_name);

=pod

=head1 NAME

search_for_targetable_languages_and_carriers

=head1 DESCRIPTION

This example illustrates how to search for language and mobile carrier constants
by names that are available for targeting.

=head1 SYNOPSIS

search_for_targetable_languages_and_carriers.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -language_name              [optional] The name of the language to search for,
                                e.g. "English", "Spanish", etc.
    -carrier_name               [optional] The name of the mobile carrier to search
                                for, e.g. "Sprint", "Vodafone", etc.

=cut
