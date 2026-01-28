#!/usr/bin/perl -w
#
# Copyright 2022, Google LLC
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
# This example updates an responsive search ad. To get responsive search ads, run
# get_responsive_search_ads.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V23::Resources::Ad;
use Google::Ads::GoogleAds::V23::Common::AdTextAsset;
use Google::Ads::GoogleAds::V23::Common::ResponsiveSearchAdInfo;
use Google::Ads::GoogleAds::V23::Enums::ServedAssetFieldTypeEnum qw(HEADLINE_1);
use Google::Ads::GoogleAds::V23::Services::AdService::AdOperation;
use Google::Ads::GoogleAds::V23::Utils::ResourceNames;

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
my $customer_id = "INSERT_CUSTOMER_ID_HERE";
my $ad_id       = "INSERT_AD_ID_HERE";

# [START update_responsive_search_ad]
sub update_responsive_search_ad {
  my ($api_client, $customer_id, $ad_id) = @_;

  # Create an ad with the proper resource name and any other changes.
  my $ad = Google::Ads::GoogleAds::V23::Resources::Ad->new({
      resourceName => Google::Ads::GoogleAds::V23::Utils::ResourceNames::ad(
        $customer_id, $ad_id
      ),
      responsiveSearchAd =>
        Google::Ads::GoogleAds::V23::Common::ResponsiveSearchAdInfo->new({
          # Update some properties of the responsive search ad.
          headlines => [
            Google::Ads::GoogleAds::V23::Common::AdTextAsset->new({
                text        => "Cruise to Pluto #" . uniqid(),
                pinnedField => HEADLINE_1
              }
            ),
            Google::Ads::GoogleAds::V23::Common::AdTextAsset->new({
                text => "Tickets on sale now"
              }
            ),
            Google::Ads::GoogleAds::V23::Common::AdTextAsset->new({
                text => "Buy your ticket now"
              }
            ),

          ],
          descriptions => [
            Google::Ads::GoogleAds::V23::Common::AdTextAsset->new({
                text => "Best space cruise ever."
              }
            ),
            Google::Ads::GoogleAds::V23::Common::AdTextAsset->new({
                text =>
                  "The most wonderful space experience you will ever have."
              }
            ),
          ]}
        ),
      finalUrls       => ["http://www.example.com/"],
      finalMobileUrls => ["http://www.example.com/mobile"]});

  # Create an ad operation for update, using the FieldMasks utility to derive
  # the update mask.
  my $ad_operation =
    Google::Ads::GoogleAds::V23::Services::AdService::AdOperation->new({
      update     => $ad,
      updateMask => all_set_fields_of($ad)});

  # Issue a mutate request to update the ad.
  my $ads_response = $api_client->AdService()->mutate({
      customerId => $customer_id,
      operations => [$ad_operation]});

  printf "Updated ad with resource name: '%s'.\n",
    $ads_response->{results}[0]{resourceName};

  return 1;
}
# [END update_responsive_search_ad]

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
  "ad_id=i"       => \$ad_id,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $ad_id);

# Call the example.
update_responsive_search_ad($api_client, $customer_id =~ s/-//gr, $ad_id);

=pod

=head1 NAME

update_responsive_search_ad

=head1 DESCRIPTION

This example updates an responsive search ad. To get responsive search ads, run
get_responsive_search_ads.pl.

=head1 SYNOPSIS

update_responsive_search_ad.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_id                      The ID of the ad to update.

=cut
