#!/usr/bin/perl -w
#
# Copyright 2021, Google LLC
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
# This code example adds an image extension to a campaign. To create a campaign,
# run add_campaigns.pl. To create an image asset, run upload_image_asset.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V10::Resources::CampaignExtensionSetting;
use Google::Ads::GoogleAds::V10::Resources::ExtensionFeedItem;
use Google::Ads::GoogleAds::V10::Common::ImageFeedItem;
use Google::Ads::GoogleAds::V10::Enums::ExtensionTypeEnum qw(IMAGE);
use
  Google::Ads::GoogleAds::V10::Services::CampaignExtensionSettingService::CampaignExtensionSettingOperation;
use
  Google::Ads::GoogleAds::V10::Services::ExtensionFeedItemService::ExtensionFeedItemOperation;
use Google::Ads::GoogleAds::V10::Utils::ResourceNames;

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
my $customer_id    = "INSERT_CUSTOMER_ID_HERE";
my $campaign_id    = "INSERT_CAMPAIGN_ID_HERE";
my $image_asset_id = "INSERT_IMAGE_ASSET_ID_HERE";

sub add_image_extension {
  my ($api_client, $customer_id, $campaign_id, $image_asset_id) = @_;

  # Create an image extension.
  my $image_extension_resource_name =
    create_image_extension($api_client, $customer_id, $image_asset_id);

  my $campaign_resource_name =
    Google::Ads::GoogleAds::V10::Utils::ResourceNames::campaign($customer_id,
    $campaign_id);

  # Create a campaign extension setting.
  my $campaign_extension_setting =
    Google::Ads::GoogleAds::V10::Resources::CampaignExtensionSetting->new({
      campaign           => $campaign_resource_name,
      extensionType      => IMAGE,
      extensionFeedItems => [$image_extension_resource_name]});

  # Create a campaign extension setting operation.
  my $campaign_extension_setting_operation =
    Google::Ads::GoogleAds::V10::Services::CampaignExtensionSettingService::CampaignExtensionSettingOperation
    ->new({
      create => $campaign_extension_setting
    });

  # Add the campaign extension setting and print the resulting resource name.
  my $campaign_extension_settings_response =
    $api_client->CampaignExtensionSettingService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_extension_setting_operation]});

  printf "Created campaign extension setting with resource name '%s'.\n",
    $campaign_extension_settings_response->{results}[0]{resourceName};

  return 1;
}

# Creates an image extension and returns the resource name of the newly created
# image extension.
sub create_image_extension {
  my ($api_client, $customer_id, $image_asset_id) = @_;

  # Create the image feed item using the provided image.
  my $image_feed_item = Google::Ads::GoogleAds::V10::Common::ImageFeedItem->new(
    {
      imageAsset => Google::Ads::GoogleAds::V10::Utils::ResourceNames::asset(
        $customer_id, $image_asset_id
      )});

  # Create an extension feed item from the image feed item.
  my $extension_feed_item =
    Google::Ads::GoogleAds::V10::Resources::ExtensionFeedItem->new({
      imageFeedItem => $image_feed_item
    });

  # Create an extension feed item operation.
  my $extension_feed_item_operation =
    Google::Ads::GoogleAds::V10::Services::ExtensionFeedItemService::ExtensionFeedItemOperation
    ->new({
      create => $extension_feed_item
    });

  # Add the extension feed item, then display and return the newly created
  # feed item's resource name.
  my $extension_feed_items_response =
    $api_client->ExtensionFeedItemService()->mutate({
      customerId => $customer_id,
      operations => [$extension_feed_item_operation]});

  my $extension_feed_item_resource_name =
    $extension_feed_items_response->{results}[0]{resourceName};
  printf "Created an image extension with resource name '%s'.\n",
    $extension_feed_item_resource_name;

  return $extension_feed_item_resource_name;
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
  "customer_id=s"    => \$customer_id,
  "campaign_id=i"    => \$campaign_id,
  "image_asset_id=i" => \$image_asset_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $campaign_id, $image_asset_id);

# Call the example.
add_image_extension($api_client, $customer_id =~ s/-//gr,
  $campaign_id, $image_asset_id);

=pod

=head1 NAME

add_image_extension

=head1 DESCRIPTION

This code example adds an image extension to a campaign. To create a campaign,
run add_campaigns.pl. To create an image asset, run upload_image_asset.pl.

=head1 SYNOPSIS

add_image_extension.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.
    -image_asset_id             The image asset ID.

=cut
