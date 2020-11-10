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
# This example adds a responsive search ad to a given ad group. To get ad groups,
# run get_ad_groups.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V6::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V6::Resources::Ad;
use Google::Ads::GoogleAds::V6::Common::AdTextAsset;
use Google::Ads::GoogleAds::V6::Common::ResponsiveSearchAdInfo;
use Google::Ads::GoogleAds::V6::Enums::ServedAssetFieldTypeEnum qw(HEADLINE_1);
use Google::Ads::GoogleAds::V6::Enums::AdGroupAdStatusEnum qw(PAUSED);
use Google::Ads::GoogleAds::V6::Services::AdGroupAdService::AdGroupAdOperation;
use Google::Ads::GoogleAds::V6::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
use Data::Uniqid qw(uniqid);

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

sub add_responsive_search_ad {
  my ($api_client, $customer_id, $ad_group_id) = @_;

  # Set a pinning to always choose this asset for HEADLINE_1. Pinning is optional;
  # if no pinning is set, then headlines and descriptions will be rotated and the
  # ones that perform best will be used more often.
  my $pinned_headline = Google::Ads::GoogleAds::V6::Common::AdTextAsset->new({
    text        => "Cruise to Mars #" . uniqid(),
    pinnedField => HEADLINE_1
  });

  # Create a responsive search ad info.
  my $responsive_search_ad_info =
    Google::Ads::GoogleAds::V6::Common::ResponsiveSearchAdInfo->new({
      headlines => [
        $pinned_headline,
        create_ad_text_asset("Best Space Cruise Line"),
        create_ad_text_asset("Experience the Stars")
      ],
      descriptions => [
        create_ad_text_asset("Buy your tickets now"),
        create_ad_text_asset("Visit the Red Planet")
      ],
      path1 => "all-inclusive",
      path2 => "deals"
    });

  # Create an ad group ad.
  my $ad_group_ad = Google::Ads::GoogleAds::V6::Resources::AdGroupAd->new({
      adGroup => Google::Ads::GoogleAds::V6::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      ),
      status => PAUSED,
      ad     => Google::Ads::GoogleAds::V6::Resources::Ad->new({
          responsiveSearchAd => $responsive_search_ad_info,
          finalUrls          => "http://www.example.com"
        })});

  # Create an ad group ad operation.
  my $ad_group_ad_operation =
    Google::Ads::GoogleAds::V6::Services::AdGroupAdService::AdGroupAdOperation
    ->new({create => $ad_group_ad});

  # Add the ad group ad.
  my $ad_group_ad_response = $api_client->AdGroupAdService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_ad_operation]});

  printf "Created responsive search ad '%s'.\n",
    $ad_group_ad_response->{results}[0]{resourceName};

  return 1;
}

# Creates an ad text asset from a given string.
sub create_ad_text_asset {
  my $text = shift;
  return Google::Ads::GoogleAds::V6::Common::AdTextAsset->new({
    text => $text
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
  "customer_id=s" => \$customer_id,
  "ad_group_id=i" => \$ad_group_id,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $ad_group_id);

# Call the example.
add_responsive_search_ad($api_client, $customer_id =~ s/-//gr, $ad_group_id);

=pod

=head1 NAME

add_responsive_search_ad

=head1 DESCRIPTION

This example adds a responsive search ad to a given ad group. To get ad groups,
run get_ad_groups.pl.

=head1 SYNOPSIS

add_responsive_search_ad.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                The ad group ID.

=cut
