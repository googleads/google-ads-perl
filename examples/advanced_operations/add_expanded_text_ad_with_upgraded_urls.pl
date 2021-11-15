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
# This example adds an expanded text ad that uses advanced features of upgraded
# URLs.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V9::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V9::Resources::Ad;
use Google::Ads::GoogleAds::V9::Common::ExpandedTextAdInfo;
use Google::Ads::GoogleAds::V9::Common::CustomParameter;
use Google::Ads::GoogleAds::V9::Enums::AdGroupAdStatusEnum qw(PAUSED);
use Google::Ads::GoogleAds::V9::Services::AdGroupAdService::AdGroupAdOperation;
use Google::Ads::GoogleAds::V9::Utils::ResourceNames;

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
my $ad_group_id = "INSERT_AD_GROUP_ID_HERE";

sub add_expanded_text_ad_with_upgraded_urls {
  my ($api_client, $customer_id, $ad_group_id) = @_;

  # Create an expanded text ad info.
  my $expanded_text_ad_info =
    Google::Ads::GoogleAds::V9::Common::ExpandedTextAdInfo->new({
      description   => "Low-gravity fun for everyone!",
      headlinePart1 => "Luxury Cruise to Mars",
      headlinePart2 => "Visit the Red Planet in style.",
    });

  # Create an ad group ad.
  my $ad_group_ad = Google::Ads::GoogleAds::V9::Resources::AdGroupAd->new({
      adGroup => Google::Ads::GoogleAds::V9::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      ),
      status => PAUSED,
      ad     => Google::Ads::GoogleAds::V9::Resources::Ad->new({
          # Set the expanded text ad info on an ad.
          expandedTextAd => $expanded_text_ad_info,
          # Specify a list of final URLs. This field cannot be set if URL field is set. This
          # may be specified at ad, criterion and feed item levels.
          finalUrls => [
            "http://www.example.com/cruise/space/",
            "http://www.example.com/locations/mars/"
          ],
          # Specify a tracking URL for 3rd party tracking provider. You may specify one at
          # customer, campaign, ad group, ad, criterion or feed item levels.
          trackingUrlTemplate => "http://tracker.example.com/?" .
            "season={_season}&promocode={_promocode}&u={lpurl}",
          # Since your tracking URL has two custom parameters, provide their values too. This can
          # be provided at campaign, ad group, ad, criterion or feed item levels.
          urlCustomParameters => [
            Google::Ads::GoogleAds::V9::Common::CustomParameter->new({
                key   => "season",
                value => "christmas"
              }
            ),
            Google::Ads::GoogleAds::V9::Common::CustomParameter->new({
                key   => "promocode",
                value => "NY123"
              })
          ],
          # Specify a list of final mobile URLs. This field cannot be set if URL field
          # is set, or finalUrls is unset. This may be specified at ad, criterion and
          # feed item levels.
          # finalMobileUrls => [
          #   "http://mobile.example.com/cruise/space/",
          #   "http://mobile.example.com/locations/mars/"
          # ]
        })});

  # Create an ad group ad operation.
  my $ad_group_ad_operation =
    Google::Ads::GoogleAds::V9::Services::AdGroupAdService::AdGroupAdOperation
    ->new({create => $ad_group_ad});

  # Add the ad group ad.
  my $ad_group_ads_response = $api_client->AdGroupAdService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_ad_operation]});

  printf "Created expanded text ad '%s'.\n",
    $ad_group_ads_response->{results}[0]{resourceName};

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
GetOptions("customer_id=s" => \$customer_id, "ad_group_id=i" => \$ad_group_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $ad_group_id);

# Call the example.
add_expanded_text_ad_with_upgraded_urls($api_client, $customer_id =~ s/-//gr,
  $ad_group_id);

=pod

=head1 NAME

add_expanded_text_ad_with_upgraded_urls

=head1 DESCRIPTION

This example adds an expanded text ad that uses advanced features of upgraded URLs.

=head1 SYNOPSIS

add_expanded_text_ad_with_upgraded_urls.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                The ad group ID.

=cut
