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
# This example adds a Smart Display campaign, an ad group and a responsive display
# ad. More information about Smart Display campaigns can be found at
# https://support.google.com/google-ads/answer/7020281.
#
# IMPORTANT: The AssetService requires you to reuse what you've uploaded previously.
# Therefore, you cannot create an image asset with the exactly same bytes. In
# case you want to run this example more than once, note down the created assets'
# IDs and specify them as command-line arguments for marketing and square marketing
# images.
#
# Alternatively, you can modify the image URLs' constants directly to use other
# images.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::MediaUtils;
use Google::Ads::GoogleAds::V4::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V4::Resources::Campaign;
use Google::Ads::GoogleAds::V4::Resources::AdGroup;
use Google::Ads::GoogleAds::V4::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V4::Resources::Ad;
use Google::Ads::GoogleAds::V4::Resources::Asset;
use Google::Ads::GoogleAds::V4::Common::TargetCpa;
use Google::Ads::GoogleAds::V4::Common::ResponsiveDisplayAdInfo;
use Google::Ads::GoogleAds::V4::Common::AdTextAsset;
use Google::Ads::GoogleAds::V4::Common::AdImageAsset;
use Google::Ads::GoogleAds::V4::Common::ImageAsset;
use Google::Ads::GoogleAds::V4::Enums::BudgetDeliveryMethodEnum qw(STANDARD);
use Google::Ads::GoogleAds::V4::Enums::AdvertisingChannelTypeEnum qw(DISPLAY);
use Google::Ads::GoogleAds::V4::Enums::AdvertisingChannelSubTypeEnum
  qw(DISPLAY_SMART_CAMPAIGN);
use Google::Ads::GoogleAds::V4::Enums::AdGroupStatusEnum;
use Google::Ads::GoogleAds::V4::Enums::AdGroupAdStatusEnum;
use Google::Ads::GoogleAds::V4::Enums::AssetTypeEnum qw(IMAGE);
use
  Google::Ads::GoogleAds::V4::Services::CampaignBudgetService::CampaignBudgetOperation;
use Google::Ads::GoogleAds::V4::Services::CampaignService::CampaignOperation;
use Google::Ads::GoogleAds::V4::Services::AdGroupService::AdGroupOperation;
use Google::Ads::GoogleAds::V4::Services::AdGroupAdService::AdGroupAdOperation;
use Google::Ads::GoogleAds::V4::Services::AssetService::AssetOperation;
use Google::Ads::GoogleAds::V4::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
use Data::Uniqid qw(uniqid);
use POSIX qw(strftime);

# They can be used to create an image asset for your customer account only once.
use constant MARKETING_IMAGE_URL        => "https://goo.gl/3b9Wfh";
use constant SQUARE_MARKETING_IMAGE_URL => "https://goo.gl/mtt54n";

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";
# Optional: Specify the marketing image asset ID and square marketing image asset
# ID below to be used to create a responsive display ad. If none is specified,
# this example will create a new image assets.
my $marketing_image_asset_id        = undef;
my $square_marketing_image_asset_id = undef;

sub add_smart_display_ad {
  my ($api_client, $customer_id, $marketing_image_asset_id,
    $square_marketing_image_asset_id)
    = @_;

  my $budget_resource_name = create_campaign_budget($api_client, $customer_id);

  my $campaign_resource_name =
    create_smart_display_campaign($api_client, $customer_id,
    $budget_resource_name);

  my $ad_group_resource_name =
    create_ad_group($api_client, $customer_id, $campaign_resource_name);

  create_responsive_display_ad($api_client, $customer_id,
    $ad_group_resource_name, $marketing_image_asset_id,
    $square_marketing_image_asset_id);

  return 1;
}

# Creates a campaign budget.
sub create_campaign_budget {
  my ($api_client, $customer_id) = @_;

  # Create a campaign budget.
  my $campaign_budget =
    Google::Ads::GoogleAds::V4::Resources::CampaignBudget->new({
      name           => "Interplanetary Cruise Budget #" . uniqid(),
      deliveryMethod => STANDARD,
      amountMicros   => 5000000
    });

  # Create a campaign budget operation.
  my $campaign_budget_operation =
    Google::Ads::GoogleAds::V4::Services::CampaignBudgetService::CampaignBudgetOperation
    ->new({
      create => $campaign_budget
    });

  # Issue a mutate request to add the campaign budget.
  my $campaign_budget_response = $api_client->CampaignBudgetService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_budget_operation]});

  # Print out some information about the created campaign budget.
  my $campaign_budget_resource_name =
    $campaign_budget_response->{results}[0]{resourceName};
  printf "Added budget named '%s'.\n", $campaign_budget_resource_name;

  return $campaign_budget_resource_name;
}

# Creates a Smart Display campaign.
sub create_smart_display_campaign {
  my ($api_client, $customer_id, $campaign_budget_resource_name) = @_;

  my $campaign = Google::Ads::GoogleAds::V4::Resources::Campaign->new({
      name => "Smart Display Campaign #" . uniqid(),
      # Smart Display campaign requires the advertising_channel_type as 'DISPLAY'.
      advertisingChannelType => DISPLAY,
      # Smart Display campaign requires the advertising_channel_sub_type as
      # 'DISPLAY_SMART_CAMPAIGN'.
      advertisingChannelSubType => DISPLAY_SMART_CAMPAIGN,
      # Smart Display campaign requires the TargetCpa bidding strategy.
      targetCpa => Google::Ads::GoogleAds::V4::Common::TargetCpa->new({
          targetCpaMicros => 5000000
        }
      ),
      campaignBudget => $campaign_budget_resource_name,
      # Optional: Set the start and end dates for the campaign, beginning one day
      # from now and ending a month from now.
      startDate => strftime("%Y%m%d", localtime(time + 60 * 60 * 24)),
      endDate   => strftime("%Y%m%d", localtime(time + 60 * 60 * 24 * 30)),
    });

  # Create a campaign operation.
  my $campaign_operation =
    Google::Ads::GoogleAds::V4::Services::CampaignService::CampaignOperation->
    new({
      create => $campaign
    });

  # Issue a mutate request to add the campaign.
  my $campaign_response = $api_client->CampaignService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_operation]});

  # Print out some information about the added campaign.
  my $campaign_resource_name =
    $campaign_response->{results}[0]{resourceName};
  printf "Added a Smart Display campaign named '%s'.\n",
    $campaign_resource_name;

  return $campaign_resource_name;
}

# Creates an ad group.
sub create_ad_group {
  my ($api_client, $customer_id, $campaign_resource_name) = @_;

  # Construct an ad group and set its type.
  my $ad_group = Google::Ads::GoogleAds::V4::Resources::AdGroup->new({
    name     => "Earth to Mars Cruises #" . uniqid(),
    campaign => $campaign_resource_name,
    status   => Google::Ads::GoogleAds::V4::Enums::AdGroupStatusEnum::PAUSED
  });

  # Create an ad group operation.
  my $ad_group_operation =
    Google::Ads::GoogleAds::V4::Services::AdGroupService::AdGroupOperation->new(
    {
      create => $ad_group
    });

  # Issue a mutate request to add the ad group.
  my $ad_group_response = $api_client->AdGroupService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_operation]});

  # Print out some information about the added ad group.
  my $ad_group_resource_name =
    $ad_group_response->{results}[0]{resourceName};
  printf "Added ad group named '%s'.\n", $ad_group_resource_name;

  return $ad_group_resource_name;
}

# Creates a responsive display ad, which is a recommended ad type for Smart
# Display campaigns.
sub create_responsive_display_ad {
  my ($api_client, $customer_id, $ad_group_resource_name,
    $marketing_image_asset_id, $square_marketing_image_asset_id)
    = @_;

  # Create a new image asset for marketing image and square marketing image if
  # there are no assets' IDs specified.
  my $marketing_image_asset_resource_name =
    defined $marketing_image_asset_id
    ? Google::Ads::GoogleAds::V4::Utils::ResourceNames::asset($customer_id,
    $marketing_image_asset_id)
    : create_image_asset($api_client, $customer_id, MARKETING_IMAGE_URL,
    "Marketing Image");

  my $square_marketing_image_asset_resource_name =
    defined $square_marketing_image_asset_id
    ? Google::Ads::GoogleAds::V4::Utils::ResourceNames::asset($customer_id,
    $square_marketing_image_asset_id)
    : create_image_asset($api_client, $customer_id, SQUARE_MARKETING_IMAGE_URL,
    "Square Marketing Image");

  # Create a responsive display ad info.
  my $responsive_display_ad_info =
    Google::Ads::GoogleAds::V4::Common::ResponsiveDisplayAdInfo->new({
      # Set some basic required information for the responsive display ad.
      headlines => [
        Google::Ads::GoogleAds::V4::Common::AdTextAsset->new({
            text => "Travel"
          })
      ],
      longHeadline => Google::Ads::GoogleAds::V4::Common::AdTextAsset->new({
          text => "Travel the World"
        }
      ),
      descriptions => [
        Google::Ads::GoogleAds::V4::Common::AdTextAsset->new({
            text => "Take to the air!"
          })
      ],
      businessName => "Google",
      # Set the marketing image and square marketing image to the previously
      # created image assets.
      marketingImages => [
        Google::Ads::GoogleAds::V4::Common::AdImageAsset->new({
            asset => $marketing_image_asset_resource_name
          })
      ],
      squareMarketingImages => [
        Google::Ads::GoogleAds::V4::Common::AdImageAsset->new({
            asset => $square_marketing_image_asset_resource_name
          })
      ],
      # Optional: Set call to action text, price prefix and promotion text.
      callToActionText => "Shop Now",
      pricePrefix      => "as low as",
      promoText        => "Free shipping!"
    });

  # Create an ad group ad with the created responsive display ad info.
  my $ad_group_ad = Google::Ads::GoogleAds::V4::Resources::AdGroupAd->new({
      adGroup => $ad_group_resource_name,
      status  => Google::Ads::GoogleAds::V4::Enums::AdGroupAdStatusEnum::PAUSED,
      ad      => Google::Ads::GoogleAds::V4::Resources::Ad->new({
          finalUrls           => ["https://www.example.com"],
          responsiveDisplayAd => $responsive_display_ad_info
        })});

  # Create an ad group ad operation.
  my $ad_group_ad_operation =
    Google::Ads::GoogleAds::V4::Services::AdGroupAdService::AdGroupAdOperation
    ->new({
      create => $ad_group_ad
    });

  # Issue a mutate request to add the ad group ad.
  my $ad_group_ad_response = $api_client->AdGroupAdService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_ad_operation]});

  # Print out some information about the newly created ad.
  my $ad_group_ad_resource_name =
    $ad_group_ad_response->{results}[0]{resourceName};
  printf "Added ad group ad named '%s'.\n", $ad_group_ad_resource_name;
}

# Creates an image asset to be used for creating ads.
sub create_image_asset {
  my ($api_client, $customer_id, $image_url, $image_name) = @_;

  # Create an asset.
  my $asset = Google::Ads::GoogleAds::V4::Resources::Asset->new({
      name       => $image_name,
      type       => IMAGE,
      imageAsset => Google::Ads::GoogleAds::V4::Common::ImageAsset->new({
          data => get_base64_data_from_url($image_url)})});

  # Create an asset operation.
  my $asset_operation =
    Google::Ads::GoogleAds::V4::Services::AssetService::AssetOperation->new({
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
  "customer_id=s"                  => \$customer_id,
  "marketing_image_asset_id=i"     => \$marketing_image_asset_id,
  "square_marketing_image_asset=i" => \$square_marketing_image_asset_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
add_smart_display_ad($api_client, $customer_id =~ s/-//gr,
  $marketing_image_asset_id, $square_marketing_image_asset_id);

=pod

=head1 NAME

add_smart_display_ad

=head1 DESCRIPTION

This example adds a Smart Display campaign, an ad group and a responsive display
ad. More information about Smart Display campaigns can be found at
https://support.google.com/google-ads/answer/7020281.

IMPORTANT: The AssetService requires you to reuse what you've uploaded previously.
Therefore, you cannot create an image asset with the exactly same bytes. In case
you want to run this example more than once, note down the created assets' IDs
and specify them as command-line arguments for marketing and square marketing
images.

Alternatively, you can modify the image URLs' constants directly to use other images.

=head1 SYNOPSIS

add_smart_display_ad.pl [options]

    -help                                Show the help message.
    -customer_id                         The Google Ads customer ID.
    -marketing_image_asset_id            [optional] The ID of marketing image asset.
    -square_marketing_image_asset_id     [optional] The ID of square marketing image asset.

=cut
