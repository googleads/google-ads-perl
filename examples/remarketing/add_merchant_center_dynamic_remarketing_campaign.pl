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
# This example creates a shopping campaign associated with an existing Merchant
# Center account, along with a related ad group and dynamic display ad, and
# targets a user list for remarketing purposes.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::MediaUtils;
use Google::Ads::GoogleAds::V23::Resources::Campaign;
use Google::Ads::GoogleAds::V23::Resources::ShoppingSetting;
use Google::Ads::GoogleAds::V23::Resources::AdGroup;
use Google::Ads::GoogleAds::V23::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V23::Resources::Ad;
use Google::Ads::GoogleAds::V23::Resources::Asset;
use Google::Ads::GoogleAds::V23::Resources::AdGroupCriterion;
use Google::Ads::GoogleAds::V23::Common::ManualCpc;
use Google::Ads::GoogleAds::V23::Common::ResponsiveDisplayAdInfo;
use Google::Ads::GoogleAds::V23::Common::AdImageAsset;
use Google::Ads::GoogleAds::V23::Common::AdTextAsset;
use Google::Ads::GoogleAds::V23::Common::ImageAsset;
use Google::Ads::GoogleAds::V23::Common::UserListInfo;
use Google::Ads::GoogleAds::V23::Enums::AdvertisingChannelTypeEnum qw(DISPLAY);
use Google::Ads::GoogleAds::V23::Enums::CampaignStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::AdGroupStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::DisplayAdFormatSettingEnum
  qw(NON_NATIVE);
use Google::Ads::GoogleAds::V23::Enums::AssetTypeEnum qw(IMAGE);
use Google::Ads::GoogleAds::V23::Enums::EuPoliticalAdvertisingStatusEnum
  qw(DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING);
use Google::Ads::GoogleAds::V23::Services::CampaignService::CampaignOperation;
use Google::Ads::GoogleAds::V23::Services::AdGroupService::AdGroupOperation;
use Google::Ads::GoogleAds::V23::Services::AdGroupAdService::AdGroupAdOperation;
use Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation;
use
  Google::Ads::GoogleAds::V23::Services::AdGroupCriterionService::AdGroupCriterionOperation;
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
my $customer_id                = "INSERT_CUSTOMER_ID_HERE";
my $merchant_center_account_id = "INSERT_MERCHANT_CENTER_ACCOUNT_ID_HERE";
my $campaign_budget_id         = "INSERT_CAMPAIGN_BUDGET_ID_HERE";
my $user_list_id               = "INSERT_USER_LIST_ID_HERE";

sub add_merchant_center_dynamic_remarketing_campaign {
  my ($api_client, $customer_id, $merchant_center_account_id,
    $campaign_budget_id, $user_list_id)
    = @_;

  # Create a shopping campaign associated with a given Merchant Center account.
  my $campaign_resource_name =
    create_campaign($api_client, $customer_id, $merchant_center_account_id,
    $campaign_budget_id);

  # Create an ad group for the campaign.
  my $ad_group_resource_name =
    create_ad_group($api_client, $customer_id, $campaign_resource_name);

  # Create a dynamic display ad in the ad group.
  create_ad($api_client, $customer_id, $ad_group_resource_name);

  # Target a specific user list for remarketing.
  attach_user_list($api_client, $customer_id, $ad_group_resource_name,
    $user_list_id);

  return 1;
}

# Creates a campaign linked to a Merchant Center product feed.
# [START add_merchant_center_dynamic_remarketing_campaign_2]
sub create_campaign {
  my ($api_client, $customer_id, $merchant_center_account_id,
    $campaign_budget_id)
    = @_;

  # Configure the settings for the shopping campaign.
  my $shopping_settings =
    Google::Ads::GoogleAds::V23::Resources::ShoppingSetting->new({
      campaignPriority => 0,
      merchantId       => $merchant_center_account_id,
      enableLocal      => "true"
    });

  # Create the campaign.
  my $campaign = Google::Ads::GoogleAds::V23::Resources::Campaign->new({
      name => "Shopping campaign #" . uniqid(),
      # Dynamic remarketing campaigns are only available on the Google Display Network.
      advertisingChannelType => DISPLAY,
      status => Google::Ads::GoogleAds::V23::Enums::CampaignStatusEnum::PAUSED,
      campaignBudget =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::campaign_budget(
        $customer_id, $campaign_budget_id
        ),
      manualCpc => Google::Ads::GoogleAds::V23::Common::ManualCpc->new(),
      # This connects the campaign to the Merchant Center account.
      shoppingSetting => $shopping_settings,
      # Declare whether or not this campaign serves political ads targeting the EU.
      # Valid values are CONTAINS_EU_POLITICAL_ADVERTISING and
      # DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING.
      containsEuPoliticalAdvertising =>
        DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING
    });

  # Create a campaign operation.
  my $campaign_operation =
    Google::Ads::GoogleAds::V23::Services::CampaignService::CampaignOperation->
    new({create => $campaign});

  # Issue a mutate request to add the campaign.
  my $campaigns_response = $api_client->CampaignService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_operation]});

  my $campaign_resource_name = $campaigns_response->{results}[0]{resourceName};
  printf "Created campaign with resource name '%s'.\n", $campaign_resource_name;

  return $campaign_resource_name;
}
# [END add_merchant_center_dynamic_remarketing_campaign_2]

# Creates an ad group for the remarketing campaign.
# [START add_merchant_center_dynamic_remarketing_campaign_1]
sub create_ad_group {
  my ($api_client, $customer_id, $campaign_resource_name) = @_;

  # Create the ad group.
  my $ad_group = Google::Ads::GoogleAds::V23::Resources::AdGroup->new({
    name     => "Dynamic remarketing ad group",
    campaign => $campaign_resource_name,
    status   => Google::Ads::GoogleAds::V23::Enums::AdGroupStatusEnum::ENABLED
  });

  # Create an ad group operation.
  my $ad_group_operation =
    Google::Ads::GoogleAds::V23::Services::AdGroupService::AdGroupOperation->
    new({create => $ad_group});

  # Issue a mutate request to add the ad group.
  my $ad_groups_response = $api_client->AdGroupService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_operation]});

  my $ad_group_resource_name = $ad_groups_response->{results}[0]{resourceName};
  printf "Created ad group with resource name '%s'.\n", $ad_group_resource_name;

  return $ad_group_resource_name;
}
# [END add_merchant_center_dynamic_remarketing_campaign_1]

# Creates the responsive display ad.
# [START add_merchant_center_dynamic_remarketing_campaign]
sub create_ad {
  my ($api_client, $customer_id, $ad_group_resource_name) = @_;

  my $marketing_image_resource_name = upload_asset(
    $api_client, $customer_id,
    "https://gaagl.page.link/Eit5",
    "Marketing Image"
  );

  my $square_marketing_image_resource_name = upload_asset(
    $api_client, $customer_id,
    "https://gaagl.page.link/bjYi",
    "Square Marketing Image"
  );

  # Create the responsive display ad info object.
  my $responsive_display_ad_info =
    Google::Ads::GoogleAds::V23::Common::ResponsiveDisplayAdInfo->new({
      marketingImages => [
        Google::Ads::GoogleAds::V23::Common::AdImageAsset->new({
            asset => $marketing_image_resource_name
          })
      ],
      squareMarketingImages => [
        Google::Ads::GoogleAds::V23::Common::AdImageAsset->new({
            asset => $square_marketing_image_resource_name
          })
      ],
      headlines => [
        Google::Ads::GoogleAds::V23::Common::AdTextAsset->new({
            text => "Travel"
          })
      ],
      longHeadline => Google::Ads::GoogleAds::V23::Common::AdTextAsset->new({
          text => "Travel the World"
        }
      ),
      descriptions => [
        Google::Ads::GoogleAds::V23::Common::AdTextAsset->new({
            text => "Take to the air!"
          })
      ],
      businessName => "Interplanetary Cruises",
      # Optional: Call to action text.
      # Valid texts: https://support.google.com/google-ads/answer/7005917
      callToActionText => "Apply Now",
      # Optional: Set the ad colors.
      mainColor   => "#0000ff",
      accentColor => "#ffff00",
      # Optional: Set to false to strictly render the ad using the colors.
      allowFlexibleColor => "false",
      # Optional: Set the format setting that the ad will be served in.
      formatSetting => NON_NATIVE,
      # Optional: Create a logo image and set it to the ad.
      # logoImages => [
      #   Google::Ads::GoogleAds::V23::Common::AdImageAsset->new({
      #       asset => "INSERT_LOGO_IMAGE_RESOURCE_NAME_HERE"
      #     })
      # ],
      # Optional: Create a square logo image and set it to the ad.
      # squareLogoImages => [
      #   Google::Ads::GoogleAds::V23::Common::AdImageAsset->new({
      #       asset => "INSERT_SQUARE_LOGO_IMAGE_RESOURCE_NAME_HERE"
      #     })
      # ]
    });

  # Create an ad group ad.
  my $ad_group_ad = Google::Ads::GoogleAds::V23::Resources::AdGroupAd->new({
      adGroup => $ad_group_resource_name,
      ad      => Google::Ads::GoogleAds::V23::Resources::Ad->new({
          responsiveDisplayAd => $responsive_display_ad_info,
          finalUrls           => ["http://www.example.com/"]})});

  # Create an ad group ad operation.
  my $ad_group_ad_operation =
    Google::Ads::GoogleAds::V23::Services::AdGroupAdService::AdGroupAdOperation
    ->new({create => $ad_group_ad});

  # Issue a mutate request to add the ad group ad.
  my $ad_group_ads_response = $api_client->AdGroupAdService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_ad_operation]});

  printf "Created ad group ad with resource name '%s'.\n",
    $ad_group_ads_response->{results}[0]{resourceName};
}
# [END add_merchant_center_dynamic_remarketing_campaign]

# Adds an image asset to the Google Ads account.
sub upload_asset {
  my ($api_client, $customer_id, $image_url, $asset_name) = @_;

  my $image_data = get_base64_data_from_url($image_url);

  # Create an asset.
  my $asset = Google::Ads::GoogleAds::V23::Resources::Asset->new({
      name       => $asset_name,
      type       => IMAGE,
      imageAsset => Google::Ads::GoogleAds::V23::Common::ImageAsset->new({
          data => $image_data
        })});

  # Create an asset operation.
  my $asset_operation =
    Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation->new({
      create => $asset
    });

  # Issue a mutate request to add the asset.
  my $assets_response = $api_client->AssetService()->mutate({
      customerId => $customer_id,
      operations => [$asset_operation]});

  my $image_asset_resource_name = $assets_response->{results}[0]{resourceName};
  printf "Created image asset with resource name '%s'.\n",
    $image_asset_resource_name;

  return $image_asset_resource_name;
}

# Targets a user list.
# [START add_merchant_center_dynamic_remarketing_campaign_3]
sub attach_user_list {
  my ($api_client, $customer_id, $ad_group_resource_name, $user_list_id) = @_;

  # Create the ad group criterion that targets the user list.
  my $ad_group_criterion =
    Google::Ads::GoogleAds::V23::Resources::AdGroupCriterion->new({
      adGroup  => $ad_group_resource_name,
      userList => Google::Ads::GoogleAds::V23::Common::UserListInfo->new({
          userList =>
            Google::Ads::GoogleAds::V23::Utils::ResourceNames::user_list(
            $customer_id, $user_list_id
            )})});

  # Create an ad group criterion operation.
  my $ad_group_criterion_operation =
    Google::Ads::GoogleAds::V23::Services::AdGroupCriterionService::AdGroupCriterionOperation
    ->new({create => $ad_group_criterion});

  # Issue a mutate request to add the ad group criterion.
  my $ad_group_criteria_response =
    $api_client->AdGroupCriterionService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_criterion_operation]});

  printf "Created ad group criterion with resource name '%s'.\n",
    $ad_group_criteria_response->{results}[0]{resourceName};
}
# [END add_merchant_center_dynamic_remarketing_campaign_3]

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
  "customer_id=s"                => \$customer_id,
  "merchant_center_account_id=i" => \$merchant_center_account_id,
  "campaign_budget_id=i"         => \$campaign_budget_id,
  "user_list_id=i"               => \$user_list_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $merchant_center_account_id,
  $campaign_budget_id, $user_list_id);

# Call the example.
add_merchant_center_dynamic_remarketing_campaign($api_client,
  $customer_id =~ s/-//gr,
  $merchant_center_account_id, $campaign_budget_id, $user_list_id);

=pod

=head1 NAME

add_merchant_center_dynamic_remarketing_campaign

=head1 DESCRIPTION

This example creates a shopping campaign associated with an existing Merchant
Center account, along with a related ad group and dynamic display ad, and
targets a user list for remarketing purposes.

=head1 SYNOPSIS

add_merchant_center_dynamic_remarketing_campaign.pl [options]

    -help                           Show the help message.
    -customer_id                    The Google Ads customer ID.
    -merchant_center_account_id     The Merchant Center account ID.
    -campaign_budget_id             The campaign budget ID.
    -user_list_id                   The user list ID.

=cut
