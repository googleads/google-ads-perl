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
# This example adds an Local campaign.
#
# Prerequisite: To create a Local campaign, you need to define the store locations
# you want to promote by linking your Google My Business account or selecting
# affiliate locations. More information about Local campaigns can be found at:
# https://support.google.com/google-ads/answer/9118422.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::MediaUtils;
use Google::Ads::GoogleAds::V5::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V5::Resources::Campaign;
use Google::Ads::GoogleAds::V5::Resources::LocalCampaignSetting;
use Google::Ads::GoogleAds::V5::Resources::OptimizationGoalSetting;
use Google::Ads::GoogleAds::V5::Resources::AdGroup;
use Google::Ads::GoogleAds::V5::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V5::Resources::Ad;
use Google::Ads::GoogleAds::V5::Resources::Asset;
use Google::Ads::GoogleAds::V5::Common::MaximizeConversionValue;
use Google::Ads::GoogleAds::V5::Common::LocalAdInfo;
use Google::Ads::GoogleAds::V5::Common::AdTextAsset;
use Google::Ads::GoogleAds::V5::Common::AdImageAsset;
use Google::Ads::GoogleAds::V5::Common::AdVideoAsset;
use Google::Ads::GoogleAds::V5::Common::ImageAsset;
use Google::Ads::GoogleAds::V5::Common::YoutubeVideoAsset;
use Google::Ads::GoogleAds::V5::Enums::BudgetDeliveryMethodEnum qw(STANDARD);
use Google::Ads::GoogleAds::V5::Enums::CampaignStatusEnum qw(PAUSED);
use Google::Ads::GoogleAds::V5::Enums::AdvertisingChannelTypeEnum qw(LOCAL);
use Google::Ads::GoogleAds::V5::Enums::AdvertisingChannelSubTypeEnum
  qw(LOCAL_CAMPAIGN);
use Google::Ads::GoogleAds::V5::Enums::LocationSourceTypeEnum
  qw(GOOGLE_MY_BUSINESS);
use Google::Ads::GoogleAds::V5::Enums::OptimizationGoalTypeEnum
  qw(CALL_CLICKS DRIVING_DIRECTIONS);
use Google::Ads::GoogleAds::V5::Enums::AdGroupStatusEnum;
use Google::Ads::GoogleAds::V5::Enums::AdGroupAdStatusEnum;
use Google::Ads::GoogleAds::V5::Enums::AssetTypeEnum qw(IMAGE YOUTUBE_VIDEO);
use
  Google::Ads::GoogleAds::V5::Services::CampaignBudgetService::CampaignBudgetOperation;
use Google::Ads::GoogleAds::V5::Services::CampaignService::CampaignOperation;
use Google::Ads::GoogleAds::V5::Services::AdGroupService::AdGroupOperation;
use Google::Ads::GoogleAds::V5::Services::AdGroupAdService::AdGroupAdOperation;
use Google::Ads::GoogleAds::V5::Services::AssetService::AssetOperation;
use Google::Ads::GoogleAds::V5::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
use Data::Uniqid qw(uniqid);

use constant MARKETING_IMAGE_URL => "https://goo.gl/3b9Wfh";
use constant LOGO_IMAGE_URL      => "https://goo.gl/mtt54n";
use constant YOUTUBE_VIDEO_ID    => "t1fDo0VyeEo";

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub add_local_campaign {
  my ($api_client, $customer_id) = @_;

  # Create the budget for the campaign.
  my $budget_resource_name = create_campaign_budget($api_client, $customer_id);

  # Create the campaign.
  my $campaign_resource_name =
    create_campaign($api_client, $customer_id, $budget_resource_name);

  # Create an ad group.
  my $ad_group_resource_name =
    create_ad_group($api_client, $customer_id, $campaign_resource_name);

  # Create a Local ad.
  create_local_ad($api_client, $customer_id, $ad_group_resource_name);

  return 1;
}

# Creates a campaign budget.
sub create_campaign_budget {
  my ($api_client, $customer_id) = @_;

  # Create a campaign budget.
  my $campaign_budget =
    Google::Ads::GoogleAds::V5::Resources::CampaignBudget->new({
      name           => "Interplanetary Cruise Budget #" . uniqid(),
      amountMicros   => 50000000,
      deliveryMethod => STANDARD,
      # A Local campaign cannot use a shared campaign budget.
      explicitlyShared => "false"
    });

  # Create a campaign budget operation.
  my $campaign_budget_operation =
    Google::Ads::GoogleAds::V5::Services::CampaignBudgetService::CampaignBudgetOperation
    ->new({
      create => $campaign_budget
    });

  # Issue a mutate request to add the campaign budget.
  my $campaign_budget_response = $api_client->CampaignBudgetService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_budget_operation]});

  my $campaign_budget_resource_name =
    $campaign_budget_response->{results}[0]{resourceName};
  printf "Created campaign budget with resource name: '%s'.\n",
    $campaign_budget_resource_name;

  return $campaign_budget_resource_name;
}

# Creates a Local campaign.
sub create_campaign {
  my ($api_client, $customer_id, $budget_resource_name) = @_;

  # Create a campaign.
  my $campaign = Google::Ads::GoogleAds::V5::Resources::Campaign->new({
      name           => "Interplanetary Cruise Local #" . uniqid(),
      campaignBudget => $budget_resource_name,
      # Recommendation: Set the campaign to PAUSED when creating it to prevent
      # the ads from immediately serving. Set to ENABLED once you've added
      # targeting and the ads are ready to serve.
      status => PAUSED,
      # All Local campaigns have an advertisingChannelType of LOCAL and
      # advertisingChannelSubType of LOCAL_CAMPAIGN.
      advertisingChannelType    => LOCAL,
      advertisingChannelSubType => LOCAL_CAMPAIGN,
      # Bidding strategy must be set directly on the campaign.
      # Setting a portfolio bidding strategy by resource name is not supported.
      # Maximize conversion value is the only strategy supported for Local
      # campaigns. An optional ROAS (Return on Advertising Spend) can be set for
      # MaximizeConversionValue. The ROAS value must be specified as a ratio in the
      # API. It is calculated by dividing "total value" by "total spend".
      # For more information on maximize conversion value, see the support article:
      # http://support.google.com/google-ads/answer/7684216.
      maximizeConversionValue =>
        Google::Ads::GoogleAds::V5::Common::MaximizeConversionValue->new(
        {targetRoas => 3.5}
        ),
      # Configure the Local campaign setting.
      localCampaignSetting =>
        Google::Ads::GoogleAds::V5::Resources::LocalCampaignSetting->new({
          # Use the locations associated with the customer's linked Google
          # My Business account.
          locationSourceType => GOOGLE_MY_BUSINESS
        }
        ),
      # Optimization goal setting is mandatory for Local campaigns. Select driving
      # direction and/or call clicks to optimize for those actions in your campaign.
      optimizationGoalSetting =>
        Google::Ads::GoogleAds::V5::Resources::OptimizationGoalSetting->new({
          optimizationGoalTypes => [CALL_CLICKS, DRIVING_DIRECTIONS]})});

  # Create a campaign operation.
  my $campaign_operation =
    Google::Ads::GoogleAds::V5::Services::CampaignService::CampaignOperation->
    new({
      create => $campaign
    });

  # Issue a mutate request to add the campaign.
  my $campaign_response = $api_client->CampaignService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_operation]});

  my $campaign_resource_name =
    $campaign_response->{results}[0]{resourceName};
  printf "Created Local campaign with resource name: '%s'.\n",
    $campaign_resource_name;

  return $campaign_resource_name;
}

# Creates an ad group for a given campaign.
sub create_ad_group {
  my ($api_client, $customer_id, $campaign_resource_name) = @_;

  # Create an ad group.
  # Note that the ad group type must not be set.
  # Since the advertisingChannelSubType is LOCAL_CAMPAIGN:
  #   1. you cannot override bid settings at the ad group level.
  #   2. you cannot add ad group criteria.
  my $ad_group = Google::Ads::GoogleAds::V5::Resources::AdGroup->new({
    name     => "Earth to Mars Cruises #" . uniqid(),
    status   => Google::Ads::GoogleAds::V5::Enums::AdGroupStatusEnum::ENABLED,
    campaign => $campaign_resource_name
  });

  # Create an ad group operation.
  my $ad_group_operation =
    Google::Ads::GoogleAds::V5::Services::AdGroupService::AdGroupOperation->
    new({create => $ad_group});

  # Issue a mutate request to add the ad group.
  my $ad_group_response = $api_client->AdGroupService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_operation]});

  my $ad_group_resource_name =
    $ad_group_response->{results}[0]{resourceName};
  printf "Created ad group with resource name: '%s'.\n",
    $ad_group_resource_name;

  return $ad_group_resource_name;
}

# Creates an Local ad for a given ad group.
sub create_local_ad {
  my ($api_client, $customer_id, $ad_group_resource_name) = @_;

  # Create an ad group ad.
  my $ad_group_ad = Google::Ads::GoogleAds::V5::Resources::AdGroupAd->new({
      adGroup => $ad_group_resource_name,
      status => Google::Ads::GoogleAds::V5::Enums::AdGroupAdStatusEnum::ENABLED,
      ad     => Google::Ads::GoogleAds::V5::Resources::Ad->new({
          finalUrls => ["https://www.example.com"],
          localAd   => Google::Ads::GoogleAds::V5::Common::LocalAdInfo->new({
              headlines => [
                create_ad_text_asset("Best Space Cruise Line"),
                create_ad_text_asset("Experience the Stars")
              ],
              descriptions => [
                create_ad_text_asset("Buy your tickets now"),
                create_ad_text_asset("Visit the Red Planet")
              ],
              callToActions => [create_ad_text_asset("Shop Now")],
              # Set the marketing image and logo image assets.
              marketingImages => [
                Google::Ads::GoogleAds::V5::Common::AdImageAsset->new({
                    asset => create_image_asset(
                      $api_client,         $customer_id,
                      MARKETING_IMAGE_URL, "Marketing Image"
                    )})
              ],
              logoImages => [
                Google::Ads::GoogleAds::V5::Common::AdImageAsset->new({
                    asset => create_image_asset(
                      $api_client,    $customer_id,
                      LOGO_IMAGE_URL, "Square Marketing Image"
                    )})
              ],
              # Set the video assets.
              videos => [
                Google::Ads::GoogleAds::V5::Common::AdVideoAsset->new({
                    asset => create_youtube_video_asset(
                      $api_client,      $customer_id,
                      YOUTUBE_VIDEO_ID, "Local Campaigns"
                    )})]})})}

  );

  # Create an ad group ad operation.
  my $ad_group_ad_operation =
    Google::Ads::GoogleAds::V5::Services::AdGroupAdService::AdGroupAdOperation
    ->new({create => $ad_group_ad});

  # Issue a mutate request to add the ad group ad.
  my $ad_group_ad_response = $api_client->AdGroupAdService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_ad_operation]});

  printf "Created ad group ad with resource name: '%s'.\n",
    $ad_group_ad_response->{results}[0]{resourceName};
}

# Creates an ad text asset.
sub create_ad_text_asset {
  my ($text) = @_;

  return Google::Ads::GoogleAds::V5::Common::AdTextAsset->new({
    text => $text
  });
}

# Creates an image asset.
sub create_image_asset {
  my ($api_client, $customer_id, $image_url, $image_name) = @_;

  # Create an asset.
  my $asset = Google::Ads::GoogleAds::V5::Resources::Asset->new({
      name       => $image_name,
      type       => IMAGE,
      imageAsset => Google::Ads::GoogleAds::V5::Common::ImageAsset->new({
          data => get_base64_data_from_url($image_url)})});

  # Create an asset operation.
  my $asset_operation =
    Google::Ads::GoogleAds::V5::Services::AssetService::AssetOperation->new({
      create => $asset
    });

  # Issue a mutate request to add the asset.
  my $asset_response = $api_client->AssetService()->mutate({
      customerId => $customer_id,
      operations => [$asset_operation]});

  # Print out information about the newly added asset.
  my $asset_resource_name = $asset_response->{results}[0]{resourceName};
  printf "A new image asset has been added with resource name: '%s'.\n",
    $asset_resource_name;

  return $asset_resource_name;
}

# Creates a YouTube video asset.
sub create_youtube_video_asset {
  my ($api_client, $customer_id, $youtube_video_id, $youtube_video_name) = @_;

  # Create an asset.
  my $asset = Google::Ads::GoogleAds::V5::Resources::Asset->new({
      name => $youtube_video_name,
      type => YOUTUBE_VIDEO,
      youtubeVideoAsset =>
        Google::Ads::GoogleAds::V5::Common::YoutubeVideoAsset->new({
          youtubeVideoId => $youtube_video_id
        })});

  # Create an asset operation.
  my $asset_operation =
    Google::Ads::GoogleAds::V5::Services::AssetService::AssetOperation->new({
      create => $asset
    });

  # Issue a mutate request to add the asset.
  my $asset_response = $api_client->AssetService()->mutate({
      customerId => $customer_id,
      operations => [$asset_operation]});

  # Print out information about the newly added asset.
  my $asset_resource_name = $asset_response->{results}[0]{resourceName};
  printf "A new YouTube video asset has been added with resource name: '%s'.\n",
    $asset_resource_name;

  return $asset_resource_name;
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
GetOptions("customer_id=s" => \$customer_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
add_local_campaign($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

add_local_campaign

=head1 DESCRIPTION

This example adds an Local campaign.

Prerequisite: To create a Local campaign, you need to define the store locations
you want to promote by linking your Google My Business account or selecting
affiliate locations. More information about Local campaigns can be found at:
https://support.google.com/google-ads/answer/9118422.

=head1 SYNOPSIS

add_local_campaign.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
