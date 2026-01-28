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
# This example gets geo target constants by given location names.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use
  Google::Ads::GoogleAds::V23::Services::GeoTargetConstantService::LocationNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

# Locale is using ISO 639-1 format. If an invalid locale is given, 'en' will be
# used by default.
my $locale = "en";
# A list of country codes can be referenced here:
# https://developers.google.com/google-ads/api/reference/data/geotargets.
my $country_code = "FR";
# The location names to get suggested geo target constants.
my $location_names = ["Paris", "Quebec", "Spain", "Deutschland"];

# [START get_geo_target_constants_by_names]
sub get_geo_target_constants_by_names {
  my ($api_client, $location_names, $locale, $country_code) = @_;

  my $suggest_response = $api_client->GeoTargetConstantService()->suggest({
      locale        => $locale,
      countryCode   => $country_code,
      locationNames =>
        Google::Ads::GoogleAds::V23::Services::GeoTargetConstantService::LocationNames
        ->new({
          names => $location_names
        })});

  # Iterate over all geo target constant suggestion objects and print the requested
  # field values for each one.
  foreach my $geo_target_constant_suggestion (
    @{$suggest_response->{geoTargetConstantSuggestions}})
  {
    printf "Found '%s' ('%s','%s','%s',%s) in locale '%s' with reach %d" .
      " for the search term '%s'.\n",
      $geo_target_constant_suggestion->{geoTargetConstant}{resourceName},
      $geo_target_constant_suggestion->{geoTargetConstant}{name},
      $geo_target_constant_suggestion->{geoTargetConstant}{countryCode},
      $geo_target_constant_suggestion->{geoTargetConstant}{targetType},
      $geo_target_constant_suggestion->{geoTargetConstant}{status},
      $geo_target_constant_suggestion->{locale},
      $geo_target_constant_suggestion->{reach},
      $geo_target_constant_suggestion->{searchTerm};
  }

  return 1;
}
# [END get_geo_target_constants_by_names]

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Call the example.
get_geo_target_constants_by_names($api_client, $location_names, $locale,
  $country_code);

=pod

=head1 NAME

get_geo_target_constants_by_names

=head1 DESCRIPTION

This example gets geo target constants by given location names.

=head1 SYNOPSIS

get_geo_target_constants_by_names.pl [options]

    -help                       Show the help message.

=cut
