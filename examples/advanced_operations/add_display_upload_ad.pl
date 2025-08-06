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
# This code example adds a display upload ad to a given ad group.
# To get ad groups, run get_ad_groups.pl.
#
# This feature is only available to allowlisted accounts.
# See https://support.google.com/google-ads/answer/1722096 for more details.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::MediaUtils;
use Google::Ads::GoogleAds::V21::Resources::Ad;
use Google::Ads::GoogleAds::V21::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V21::Resources::Asset;
use Google::Ads::GoogleAds::V21::Common::AdMediaBundleAsset;
use Google::Ads::GoogleAds::V21::Common::DisplayUploadAdInfo;
use Google::Ads::GoogleAds::V21::Common::MediaBundleAsset;
use Google::Ads::GoogleAds::V21::Enums::AdGroupAdStatusEnum qw(PAUSED);
use Google::Ads::GoogleAds::V21::Enums::DisplayUploadProductTypeEnum
  qw(HTML5_UPLOAD_AD);
use Google::Ads::GoogleAds::V21::Enums::AssetTypeEnum qw(MEDIA_BUNDLE);
use Google::Ads::GoogleAds::V21::Services::AssetService::AssetOperation;
use Google::Ads::GoogleAds::V21::Services::AdGroupAdService::AdGroupAdOperation;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

# The HTML5 zip file contains all the HTML, CSS, and images needed for the
# HTML5 ad. For help on creating an HTML5 zip file, check out Google Web
# Designer (https://www.google.com/webdesigner/).
use constant BUNDLE_URL => "https://gaagl.page.link/ib87";

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

sub add_display_upload_ad {
  my ($api_client, $customer_id, $ad_group_id) = @_;

  # There are several types of display upload ads. For this example, we will
  # create an HTML5 upload ad, which requires a media bundle.
  # The DisplayUploadProductType field lists the available display upload types:
  # https://developers.google.com/google-ads/api/reference/rpc/latest/DisplayUploadAdInfo

  # Create a new media bundle asset and return the resource name.
  my $ad_asset_resource_name =
    create_media_bundle_asset($api_client, $customer_id);

  # Create a new display upload ad and associate it with the specified ad group.
  create_display_upload_ad_group_ad($api_client, $customer_id, $ad_group_id,
    $ad_asset_resource_name);

  return 1;
}

# Creates a media bundle from the assets in a zip file. The zip file contains the
# HTML5 components.
sub create_media_bundle_asset {
  my ($api_client, $customer_id) = @_;

  # Create an HTML5 zip file media bundle content.
  my $bundle_content = get_base64_data_from_url(BUNDLE_URL);

  # Create an asset.
  my $asset = Google::Ads::GoogleAds::V21::Resources::Asset->new({
      name             => "Ad Media Bundle",
      type             => MEDIA_BUNDLE,
      mediaBundleAsset =>
        Google::Ads::GoogleAds::V21::Common::MediaBundleAsset->new({
          data => $bundle_content
        })});

  # Create an asset operation.
  my $asset_operation =
    Google::Ads::GoogleAds::V21::Services::AssetService::AssetOperation->new({
      create => $asset
    });

  # Issue a mutate request to add the asset.
  my $assets_response = $api_client->AssetService()->mutate({
      customerId => $customer_id,
      operations => [$asset_operation]});

  # Print out information about the newly added asset.
  my $asset_resource_name = $assets_response->{results}[0]{resourceName};
  printf "The media bundle asset has been added with resource name: '%s'.\n",
    $asset_resource_name;

  return $asset_resource_name;
}

# Creates a new HTML5 display upload ad and adds it to the specified ad group.
sub create_display_upload_ad_group_ad {
  my ($api_client, $customer_id, $ad_group_id, $ad_asset_resource_name) = @_;

  # Create a display upload ad info.
  my $display_upload_ad_info =
    Google::Ads::GoogleAds::V21::Common::DisplayUploadAdInfo->new({
      displayUploadProductType => HTML5_UPLOAD_AD,
      mediaBundle              =>
        Google::Ads::GoogleAds::V21::Common::AdMediaBundleAsset->new({
          asset => $ad_asset_resource_name,
        })});

  # Create a display upload ad.
  my $display_upload_ad = Google::Ads::GoogleAds::V21::Resources::Ad->new({
    name      => "Ad for HTML5",
    finalUrls => ["http://example.com/html5"],
    # Exactly one ad data field must be included to specify the ad type. See
    # https://developers.google.com/google-ads/api/reference/rpc/latest/Ad for the
    # full list of available types.
    displayUploadAd => $display_upload_ad_info,
  });

  # Create an ad group ad.
  my $ad_group_ad = Google::Ads::GoogleAds::V21::Resources::AdGroupAd->new({
      ad      => $display_upload_ad,
      status  => PAUSED,
      adGroup => Google::Ads::GoogleAds::V21::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      )});

  # Create an ad group ad operation.
  my $ad_group_ad_operation =
    Google::Ads::GoogleAds::V21::Services::AdGroupAdService::AdGroupAdOperation
    ->new({create => $ad_group_ad});

  # Add the ad group ad.
  my $response = $api_client->AdGroupAdService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_ad_operation]});

  # Display the resulting ad group ad's resource name.
  printf "Created new ad group ad '%s'.\n",
    $response->{results}[0]{resourceName};
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
add_display_upload_ad($api_client, $customer_id =~ s/-//gr, $ad_group_id);

=pod

=head1 NAME

add_display_upload_ad

=head1 DESCRIPTION

This code example adds a display upload ad to a given ad group.
To get ad groups, run get_ad_groups.pl

This feature is only available to allowlisted accounts.
See https://support.google.com/google-ads/answer/1722096 for more details.

=head1 SYNOPSIS

add_display_upload_ad.pl [options]

    -help             Show the help message.
    -customer_id      The Google Ads customer ID.
    -ad_group_id      The ID of the ad group to which the new ad will be added.

=cut
