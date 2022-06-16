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
# This example shows how to create a Performance Max retail campaign.
#
# This will be created for "All products".
#
# For more information about Performance Max retail campaigns, see
# https://developers.google.com/google-ads/api/docs/performance-max/retail.
#
# Prerequisites:
# - You need to have access to a Merchant Center account. You can find
#   instructions to create a Merchant Center account here:
#   https://support.google.com/merchants/answer/188924.
#   This account must be linked to your Google Ads account. The integration
#   instructions can be found at:
#   https://developers.google.com/google-ads/api/docs/shopping-ads/merchant-center.
# - You need your Google Ads account to track conversions. The different ways
#   to track conversions can be found here:
#   https://support.google.com/google-ads/answer/1722054.
# - You must have at least one conversion action in the account. For more about
#   conversion actions, see
#   https://developers.google.com/google-ads/api/docs/conversions/overview#conversion_actions.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::MediaUtils;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V11::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V11::Resources::Campaign;
use Google::Ads::GoogleAds::V11::Resources::ShoppingSetting;
use Google::Ads::GoogleAds::V11::Resources::CampaignCriterion;
use Google::Ads::GoogleAds::V11::Resources::Asset;
use Google::Ads::GoogleAds::V11::Resources::AssetGroup;
use Google::Ads::GoogleAds::V11::Resources::AssetGroupAsset;
use Google::Ads::GoogleAds::V11::Resources::CampaignConversionGoal;
use Google::Ads::GoogleAds::V11::Resources::AssetGroupListingGroupFilter;
use Google::Ads::GoogleAds::V11::Common::MaximizeConversionValue;
use Google::Ads::GoogleAds::V11::Common::LocationInfo;
use Google::Ads::GoogleAds::V11::Common::LanguageInfo;
use Google::Ads::GoogleAds::V11::Common::TextAsset;
use Google::Ads::GoogleAds::V11::Common::ImageAsset;
use Google::Ads::GoogleAds::V11::Enums::BudgetDeliveryMethodEnum qw(STANDARD);
use Google::Ads::GoogleAds::V11::Enums::CampaignStatusEnum;
use Google::Ads::GoogleAds::V11::Enums::AdvertisingChannelTypeEnum
  qw(PERFORMANCE_MAX);
use Google::Ads::GoogleAds::V11::Enums::AssetGroupStatusEnum;
use Google::Ads::GoogleAds::V11::Enums::AssetFieldTypeEnum
  qw(HEADLINE DESCRIPTION LONG_HEADLINE BUSINESS_NAME LOGO MARKETING_IMAGE SQUARE_MARKETING_IMAGE);
use Google::Ads::GoogleAds::V11::Enums::ConversionActionCategoryEnum
  qw(PURCHASE);
use Google::Ads::GoogleAds::V11::Enums::ConversionOriginEnum qw(WEBSITE);
use Google::Ads::GoogleAds::V11::Enums::ListingGroupFilterTypeEnum
  qw(UNIT_INCLUDED);
use Google::Ads::GoogleAds::V11::Enums::ListingGroupFilterVerticalEnum
  qw(SHOPPING);
use Google::Ads::GoogleAds::V11::Services::GoogleAdsService::MutateOperation;
use
  Google::Ads::GoogleAds::V11::Services::CampaignBudgetService::CampaignBudgetOperation;
use Google::Ads::GoogleAds::V11::Services::CampaignService::CampaignOperation;
use
  Google::Ads::GoogleAds::V11::Services::CampaignCriterionService::CampaignCriterionOperation;
use Google::Ads::GoogleAds::V11::Services::AssetService::AssetOperation;
use
  Google::Ads::GoogleAds::V11::Services::AssetGroupService::AssetGroupOperation;
use
  Google::Ads::GoogleAds::V11::Services::AssetGroupAssetService::AssetGroupAssetOperation;
use
  Google::Ads::GoogleAds::V11::Services::CampaignConversionGoalService::CampaignConversionGoalOperation;
use
  Google::Ads::GoogleAds::V11::Services::AssetGroupListingGroupFilterService::AssetGroupListingGroupFilterOperation;
use Google::Ads::GoogleAds::V11::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
use Data::Uniqid qw(uniqid);
use POSIX qw(strftime);

# We specify temporary IDs that are specific to a single mutate request.
# Temporary IDs are always negative and unique within one mutate request.
#
# See https://developers.google.com/google-ads/api/docs/mutating/best-practices
# for further details.
#
# These temporary IDs are fixed because they are used in multiple places.
use constant BUDGET_TEMPORARY_ID                   => -1;
use constant PERFORMANCE_MAX_CAMPAIGN_TEMPORARY_ID => -2;
use constant ASSET_GROUP_TEMPORARY_ID              => -3;

# There are also entities that will be created in the same request but do not
# need to be fixed temporary IDs because they are referenced only once.
our $next_temp_id = ASSET_GROUP_TEMPORARY_ID - 1;

use constant PAGE_SIZE => 1000;

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
my $sales_country              = "US";
my $final_url                  = "http://www.example.com";

# [START add_performance_max_retail_campaign]
sub add_performance_max_retail_campaign {
  my ($api_client, $customer_id, $merchant_center_account_id, $sales_country,
    $final_url)
    = @_;

  # [START add_performance_max_retail_campaign_1]
  # This campaign will override the customer conversion goals.
  # Retrieve the current list of customer conversion goals.
  my $customer_conversion_goals =
    get_customer_conversion_goals($api_client, $customer_id);

  # Performance Max campaigns require that repeated assets such as headlines
  # and descriptions be created before the campaign.
  # For the list of required assets for a Performance Max campaign, see
  # https://developers.google.com/google-ads/api/docs/performance-max/assets.
  #
  # Create the headlines.
  my $headline_asset_resource_names =
    create_multiple_text_assets($api_client, $customer_id,
    ["Travel", "Travel Reviews", "Book travel"]);
  # Create the descriptions.
  my $description_asset_resource_names =
    create_multiple_text_assets($api_client, $customer_id,
    ["Take to the air!", "Fly to the sky!"]);

  # It's important to create the below entities in this order because they depend
  # on each other.
  my $operations = [];
  # The below methods create and return MutateOperations that we later provide to
  # the GoogleAdsService->mutate() method in order to create the entities in a
  # single request. Since the entities for a Performance Max campaign are closely
  # tied to one-another, it's considered a best practice to create them in a
  # single mutate request so they all complete successfully or fail entirely,
  # leaving no orphaned entities. See:
  # https://developers.google.com/google-ads/api/docs/mutating/overview.
  push @$operations, create_campaign_budget_operation($customer_id);
  push @$operations,
    create_performance_max_campaign_operation($customer_id,
    $merchant_center_account_id, $sales_country);
  push @$operations, @{create_campaign_criterion_operations($customer_id)};
  push @$operations,
    @{
    create_asset_group_operations(
      $customer_id,                   $final_url,
      $headline_asset_resource_names, $description_asset_resource_names
    )};
  push @$operations,
    @{create_conversion_goal_operations($customer_id,
      $customer_conversion_goals)};

  # Retail Performance Max campaigns require listing groups, which are created
  # via the AssetGroupListingGroupFilter resource.
  push @$operations,
    @{create_asset_group_listing_group_operations($customer_id)};

  # Issue a mutate request to create everything and print its information.
  my $mutate_google_ads_response = $api_client->GoogleAdsService()->mutate({
    customerId       => $customer_id,
    mutateOperations => $operations
  });

  print_response_details($mutate_google_ads_response);
  # [END add_performance_max_retail_campaign_1]

  return 1;
}

# Creates a MutateOperation that creates a new CampaignBudget.
#
# A temporary ID will be assigned to this campaign budget so that it can be
# referenced by other objects being created in the same mutate request.
# [START add_performance_max_retail_campaign_2]
sub create_campaign_budget_operation {
  my ($customer_id) = @_;

  # Create a mutate operation that creates a campaign budget operation.
  return
    Google::Ads::GoogleAds::V11::Services::GoogleAdsService::MutateOperation->
    new({
      campaignBudgetOperation =>
        Google::Ads::GoogleAds::V11::Services::CampaignBudgetService::CampaignBudgetOperation
        ->new({
          create => Google::Ads::GoogleAds::V11::Resources::CampaignBudget->new(
            {
              # Set a temporary ID in the budget's resource name so it can be
              # referenced by the campaign in later steps.
              resourceName =>
                Google::Ads::GoogleAds::V11::Utils::ResourceNames::campaign_budget(
                $customer_id, BUDGET_TEMPORARY_ID
                ),
              name => "Performance Max retail campaign budget #" . uniqid(),
              # The budget period already defaults to DAILY.
              amountMicros   => 50000000,
              deliveryMethod => STANDARD,
              # A Performance Max campaign cannot use a shared campaign budget.
              explicitlyShared => "false",
            })})});
}
# [END add_performance_max_retail_campaign_2]

# Creates a MutateOperation that creates a new Performance Max campaign.
#
# A temporary ID will be assigned to this campaign so that it can be referenced
# by other objects being created in the same mutate request.
# [START add_performance_max_retail_campaign_3]
sub create_performance_max_campaign_operation {
  my ($customer_id, $merchant_center_account_id, $sales_country) = @_;

  # Create a mutate operation that creates a campaign operation.
  return
    Google::Ads::GoogleAds::V11::Services::GoogleAdsService::MutateOperation->
    new({
      campaignOperation =>
        Google::Ads::GoogleAds::V11::Services::CampaignService::CampaignOperation
        ->new({
          create => Google::Ads::GoogleAds::V11::Resources::Campaign->new({
              # Assign the resource name with a temporary ID.
              resourceName =>
                Google::Ads::GoogleAds::V11::Utils::ResourceNames::campaign(
                $customer_id, PERFORMANCE_MAX_CAMPAIGN_TEMPORARY_ID
                ),
              name => "Performance Max retail campaign #'" . uniqid(),
              # Set the budget using the given budget resource name.
              campaignBudget =>
                Google::Ads::GoogleAds::V11::Utils::ResourceNames::campaign_budget(
                $customer_id, BUDGET_TEMPORARY_ID
                ),
              # Set the campaign status as PAUSED. The campaign is the only entity in
              # the mutate request that should have its status set.
              status =>
                Google::Ads::GoogleAds::V11::Enums::CampaignStatusEnum::PAUSED,
              # All Performance Max campaigns have an advertisingChannelType of
              # PERFORMANCE_MAX. The advertisingChannelSubType should not be set.
              advertisingChannelType => PERFORMANCE_MAX,

              # Bidding strategy must be set directly on the campaign.
              # Setting a portfolio bidding strategy by resource name is not supported.
              # Max Conversion and Max Conversion Value are the only strategies
              # supported for Performance Max campaigns.
              # An optional ROAS (Return on Advertising Spend) can be set for
              # maximizeConversionValue. The ROAS value must be specified as a ratio in
              # the API. It is calculated by dividing "total value" by "total spend".
              # For more information on Max Conversion Value, see the support article:
              # http://support.google.com/google-ads/answer/7684216.
              # A targetRoas of 3.5 corresponds to a 350% return on ad spend.
              maximizeConversionValue =>
                Google::Ads::GoogleAds::V11::Common::MaximizeConversionValue->
                new({
                  targetRoas => 3.5
                }
                ),

              # Set the final URL expansion opt out. This flag is specific to
              # Performance Max campaigns. If opted out (true), only the final URLs in
              # the asset group or URLs specified in the advertiser's Google Merchant
              # Center or business data feeds are targeted.
              # If opted in (false), the entire domain will be targeted. For best
              # results, set this value to false to opt in and allow URL expansions. You
              # can optionally add exclusions to limit traffic to parts of your website.
              #
              # For a Retail campaign, we want the final URL to be limited to those
              # explicitly surfaced via GMC.
              urlExpansionOptOut => "true",

              # Set the shopping settings.
              shoppingSetting =>
                Google::Ads::GoogleAds::V11::Resources::ShoppingSetting->new({
                  merchantId   => $merchant_center_account_id,
                  salesCountry => $sales_country
                }
                ),

              # Optional fields.
              startDate => strftime("%Y%m%d", localtime(time + 60 * 60 * 24)),
              endDate   =>
                strftime("%Y%m%d", localtime(time + 60 * 60 * 24 * 365)),
            })})});
}
# [END add_performance_max_retail_campaign_3]

# Creates a list of MutateOperations that create new campaign criteria.
# [START add_performance_max_retail_campaign_4]
sub create_campaign_criterion_operations {
  my ($customer_id) = @_;

  my $operations = [];
  # Set the LOCATION campaign criteria.
  # Target all of New York City except Brooklyn.
  # Location IDs are listed here:
  # https://developers.google.com/google-ads/api/reference/data/geotargets
  # and they can also be retrieved using the GeoTargetConstantService as shown
  # here: https://developers.google.com/google-ads/api/docs/targeting/location-targeting.
  #
  # We will add one positive location target for New York City (ID=1023191)
  # and one negative location target for Brooklyn (ID=1022762).
  # First, add the positive (negative = false) for New York City.
  push @$operations,
    Google::Ads::GoogleAds::V11::Services::GoogleAdsService::MutateOperation->
    new({
      campaignCriterionOperation =>
        Google::Ads::GoogleAds::V11::Services::CampaignCriterionService::CampaignCriterionOperation
        ->new({
          create =>
            Google::Ads::GoogleAds::V11::Resources::CampaignCriterion->new({
              campaign =>
                Google::Ads::GoogleAds::V11::Utils::ResourceNames::campaign(
                $customer_id, PERFORMANCE_MAX_CAMPAIGN_TEMPORARY_ID
                ),
              location =>
                Google::Ads::GoogleAds::V11::Common::LocationInfo->new({
                  geoTargetConstant =>
                    Google::Ads::GoogleAds::V11::Utils::ResourceNames::geo_target_constant(
                    1023191)}
                ),
              negative => "false"
            })})});

  # Next add the negative target for Brooklyn.
  push @$operations,
    Google::Ads::GoogleAds::V11::Services::GoogleAdsService::MutateOperation->
    new({
      campaignCriterionOperation =>
        Google::Ads::GoogleAds::V11::Services::CampaignCriterionService::CampaignCriterionOperation
        ->new({
          create =>
            Google::Ads::GoogleAds::V11::Resources::CampaignCriterion->new({
              campaign =>
                Google::Ads::GoogleAds::V11::Utils::ResourceNames::campaign(
                $customer_id, PERFORMANCE_MAX_CAMPAIGN_TEMPORARY_ID
                ),
              location =>
                Google::Ads::GoogleAds::V11::Common::LocationInfo->new({
                  geoTargetConstant =>
                    Google::Ads::GoogleAds::V11::Utils::ResourceNames::geo_target_constant(
                    1022762)}
                ),
              negative => "true"
            })})});

  # Set the LANGUAGE campaign criterion.
  push @$operations,
    Google::Ads::GoogleAds::V11::Services::GoogleAdsService::MutateOperation->
    new({
      campaignCriterionOperation =>
        Google::Ads::GoogleAds::V11::Services::CampaignCriterionService::CampaignCriterionOperation
        ->new({
          create =>
            Google::Ads::GoogleAds::V11::Resources::CampaignCriterion->new({
              campaign =>
                Google::Ads::GoogleAds::V11::Utils::ResourceNames::campaign(
                $customer_id, PERFORMANCE_MAX_CAMPAIGN_TEMPORARY_ID
                ),
              # Set the language.
              # For a list of all language codes, see:
              # https://developers.google.com/google-ads/api/reference/data/codes-formats#expandable-7.
              language =>
                Google::Ads::GoogleAds::V11::Common::LanguageInfo->new({
                  languageConstant =>
                    Google::Ads::GoogleAds::V11::Utils::ResourceNames::language_constant(
                    1000)    # English
                })})})});

  return $operations;
}
# [END add_performance_max_retail_campaign_4]

# Creates multiple text assets and returns the list of resource names.
# [START add_performance_max_retail_campaign_5]
sub create_multiple_text_assets {
  my ($api_client, $customer_id, $texts) = @_;

  # Here again we use the GoogleAdService to create multiple text assets in a
  # single request.
  my $operations = [];
  foreach my $text (@$texts) {
    # Create a mutate operation for a text asset.
    push @$operations,
      Google::Ads::GoogleAds::V11::Services::GoogleAdsService::MutateOperation
      ->new({
        assetOperation =>
          Google::Ads::GoogleAds::V11::Services::AssetService::AssetOperation->
          new({
            create => Google::Ads::GoogleAds::V11::Resources::Asset->new({
                textAsset =>
                  Google::Ads::GoogleAds::V11::Common::TextAsset->new({
                    text => $text
                  })})})});
  }

  # Issue a mutate request to add all assets.
  my $mutate_google_ads_response = $api_client->GoogleAdsService()->mutate({
    customerId       => $customer_id,
    mutateOperations => $operations
  });

  my $asset_resource_names = [];
  foreach
    my $response (@{$mutate_google_ads_response->{mutateOperationResponses}})
  {
    push @$asset_resource_names, $response->{assetResult}{resourceName};
  }
  print_response_details($mutate_google_ads_response);

  return $asset_resource_names;
}
# [END add_performance_max_retail_campaign_5]

# Creates a list of MutateOperations that create a new asset group.
#
# A temporary ID will be assigned to this asset group so that it can be referenced
# by other objects being created in the same mutate request.
# [START add_performance_max_retail_campaign_6]
sub create_asset_group_operations {
  my (
    $customer_id, $final_url,
    $headline_asset_resource_names,
    $description_asset_resource_names
  ) = @_;

  my $operations = [];
  # Create a mutate operation that creates an asset group operation.
  push @$operations,
    Google::Ads::GoogleAds::V11::Services::GoogleAdsService::MutateOperation->
    new({
      assetGroupOperation =>
        Google::Ads::GoogleAds::V11::Services::AssetGroupService::AssetGroupOperation
        ->new({
          create => Google::Ads::GoogleAds::V11::Resources::AssetGroup->new({
              resourceName =>
                Google::Ads::GoogleAds::V11::Utils::ResourceNames::asset_group(
                $customer_id, ASSET_GROUP_TEMPORARY_ID
                ),
              name     => "Performance Max retail asset group #" . uniqid(),
              campaign =>
                Google::Ads::GoogleAds::V11::Utils::ResourceNames::campaign(
                $customer_id, PERFORMANCE_MAX_CAMPAIGN_TEMPORARY_ID
                ),
              finalUrls       => [$final_url],
              finalMobileUrls => [$final_url],
              status          =>
                Google::Ads::GoogleAds::V11::Enums::AssetGroupStatusEnum::PAUSED
            })})});

  # For the list of required assets for a Performance Max campaign, see
  # https://developers.google.com/google-ads/api/docs/performance-max/assets.

  # An AssetGroup is linked to an Asset by creating a new AssetGroupAsset
  # and providing:
  # - the resource name of the AssetGroup
  # - the resource name of the Asset
  # - the fieldType of the Asset in this AssetGroup
  #
  # To learn more about AssetGroups, see
  # https://developers.google.com/google-ads/api/docs/performance-max/asset-groups.

  # Link the previously created multiple text assets.

  # Link the headline assets.
  foreach my $resource_name (@$headline_asset_resource_names) {
    push @$operations,
      Google::Ads::GoogleAds::V11::Services::GoogleAdsService::MutateOperation
      ->new({
        assetGroupAssetOperation =>
          Google::Ads::GoogleAds::V11::Services::AssetGroupAssetService::AssetGroupAssetOperation
          ->new({
            create =>
              Google::Ads::GoogleAds::V11::Resources::AssetGroupAsset->new({
                asset      => $resource_name,
                assetGroup =>
                  Google::Ads::GoogleAds::V11::Utils::ResourceNames::asset_group(
                  $customer_id, ASSET_GROUP_TEMPORARY_ID
                  ),
                fieldType => HEADLINE
              })})});
  }

  # Link the description assets.
  foreach my $resource_name (@$description_asset_resource_names) {
    push @$operations,
      Google::Ads::GoogleAds::V11::Services::GoogleAdsService::MutateOperation
      ->new({
        assetGroupAssetOperation =>
          Google::Ads::GoogleAds::V11::Services::AssetGroupAssetService::AssetGroupAssetOperation
          ->new({
            create =>
              Google::Ads::GoogleAds::V11::Resources::AssetGroupAsset->new({
                asset      => $resource_name,
                assetGroup =>
                  Google::Ads::GoogleAds::V11::Utils::ResourceNames::asset_group(
                  $customer_id, ASSET_GROUP_TEMPORARY_ID
                  ),
                fieldType => DESCRIPTION
              })})});
  }

  # Create and link the long headline text asset.
  push @$operations,
    @{create_and_link_text_asset($customer_id, "Travel the World",
      LONG_HEADLINE)};

  # Create and link the business name text asset.
  push @$operations,
    @{
    create_and_link_text_asset($customer_id, "Interplanetary Cruises",
      BUSINESS_NAME)};

  # Create and link the image assets.

  # Create and link the logo asset.
  push @$operations,
    @{
    create_and_link_image_asset($customer_id, "https://gaagl.page.link/bjYi",
      LOGO, "Logo Image")};

  # Create and link the marketing image asset.
  push @$operations,
    @{
    create_and_link_image_asset(
      $customer_id,    "https://gaagl.page.link/Eit5",
      MARKETING_IMAGE, "Marketing Image"
    )};

  # Create and link the square marketing image asset.
  push @$operations,
    @{
    create_and_link_image_asset(
      $customer_id,           "https://gaagl.page.link/bjYi",
      SQUARE_MARKETING_IMAGE, "Square Marketing Image"
    )};

  return $operations;
}
# [END add_performance_max_retail_campaign_6]

# Creates a list of MutateOperations that create a new linked text asset.
# [START add_performance_max_retail_campaign_7]
sub create_and_link_text_asset {
  my ($customer_id, $text, $field_type) = @_;

  my $operations = [];
  # Create a new mutate operation for a text asset.
  push @$operations,
    Google::Ads::GoogleAds::V11::Services::GoogleAdsService::MutateOperation->
    new({
      assetOperation =>
        Google::Ads::GoogleAds::V11::Services::AssetService::AssetOperation->
        new({
          create => Google::Ads::GoogleAds::V11::Resources::Asset->new({
              resourceName =>
                Google::Ads::GoogleAds::V11::Utils::ResourceNames::asset(
                $customer_id, $next_temp_id
                ),
              textAsset => Google::Ads::GoogleAds::V11::Common::TextAsset->new({
                  text => $text
                })})})});

  # Create an asset group asset to link the asset to the asset group.
  push @$operations,
    Google::Ads::GoogleAds::V11::Services::GoogleAdsService::MutateOperation->
    new({
      assetGroupAssetOperation =>
        Google::Ads::GoogleAds::V11::Services::AssetGroupAssetService::AssetGroupAssetOperation
        ->new({
          create =>
            Google::Ads::GoogleAds::V11::Resources::AssetGroupAsset->new({
              asset => Google::Ads::GoogleAds::V11::Utils::ResourceNames::asset(
                $customer_id, $next_temp_id
              ),
              assetGroup =>
                Google::Ads::GoogleAds::V11::Utils::ResourceNames::asset_group(
                $customer_id, ASSET_GROUP_TEMPORARY_ID
                ),
              fieldType => $field_type
            })})});

  $next_temp_id--;
  return $operations;
}
# [END add_performance_max_retail_campaign_7]

# Creates a list of MutateOperations that create a new linked image asset.
# [START add_performance_max_retail_campaign_8]
sub create_and_link_image_asset {
  my ($customer_id, $url, $field_type, $asset_name) = @_;

  my $operations = [];
  # Create a new mutate operation for an image asset.
  push @$operations,
    Google::Ads::GoogleAds::V11::Services::GoogleAdsService::MutateOperation->
    new({
      assetOperation =>
        Google::Ads::GoogleAds::V11::Services::AssetService::AssetOperation->
        new({
          create => Google::Ads::GoogleAds::V11::Resources::Asset->new({
              resourceName =>
                Google::Ads::GoogleAds::V11::Utils::ResourceNames::asset(
                $customer_id, $next_temp_id
                ),
              # Provide a unique friendly name to identify your asset.
              # When there is an existing image asset with the same content but a different
              # name, the new name will be dropped silently.
              name       => $asset_name,
              imageAsset =>
                Google::Ads::GoogleAds::V11::Common::ImageAsset->new({
                  data => get_base64_data_from_url($url)})})})});

  # Create an asset group asset to link the asset to the asset group.
  push @$operations,
    Google::Ads::GoogleAds::V11::Services::GoogleAdsService::MutateOperation->
    new({
      assetGroupAssetOperation =>
        Google::Ads::GoogleAds::V11::Services::AssetGroupAssetService::AssetGroupAssetOperation
        ->new({
          create =>
            Google::Ads::GoogleAds::V11::Resources::AssetGroupAsset->new({
              asset => Google::Ads::GoogleAds::V11::Utils::ResourceNames::asset(
                $customer_id, $next_temp_id
              ),
              assetGroup =>
                Google::Ads::GoogleAds::V11::Utils::ResourceNames::asset_group(
                $customer_id, ASSET_GROUP_TEMPORARY_ID
                ),
              fieldType => $field_type
            })})});

  $next_temp_id--;
  return $operations;
}
# [END add_performance_max_retail_campaign_8]

# Retrieves the list of customer conversion goals.
# [START add_performance_max_retail_campaign_9]
sub get_customer_conversion_goals {
  my ($api_client, $customer_id) = @_;

  my $customer_conversion_goals = [];
  # Create a query that retrieves all customer conversion goals.
  my $query =
    "SELECT customer_conversion_goal.category, customer_conversion_goal.origin "
    . "FROM customer_conversion_goal";
  # The number of conversion goals is typically less than 50 so we use
  # GoogleAdsService->search() method instead of search_stream().
  my $search_response = $api_client->GoogleAdsService()->search({
    customerId => $customer_id,
    query      => $query,
    pageSize   => PAGE_SIZE
  });

  # Iterate over the results and build the list of conversion goals.
  foreach my $google_ads_row (@{$search_response->{results}}) {
    push @$customer_conversion_goals,
      {
      category => $google_ads_row->{customerConversionGoal}{category},
      origin   => $google_ads_row->{customerConversionGoal}{origin}};
  }

  return $customer_conversion_goals;
}

# Creates a list of MutateOperations that override customer conversion goals.
sub create_conversion_goal_operations {
  my ($customer_id, $customer_conversion_goals) = @_;

  my $operations = [];
  # To override the customer conversion goals, we will change the biddability of
  # each of the customer conversion goals so that only the desired conversion goal
  # is biddable in this campaign.
  foreach my $customer_conversion_goal (@$customer_conversion_goals) {
    my $campaign_conversion_goal =
      Google::Ads::GoogleAds::V11::Resources::CampaignConversionGoal->new({
        resourceName =>
          Google::Ads::GoogleAds::V11::Utils::ResourceNames::campaign_conversion_goal(
          $customer_id,
          PERFORMANCE_MAX_CAMPAIGN_TEMPORARY_ID,
          $customer_conversion_goal->{category},
          $customer_conversion_goal->{origin})});
    # Change the biddability for the campaign conversion goal.
    # Set biddability to true for the desired (category, origin).
    # Set biddability to false for all other conversion goals.
    # Note:
    #  1- It is assumed that this Conversion Action
    #     (category=PURCHASE, origin=WEBSITE) exists in this account.
    #  2- More than one goal can be biddable if desired. This example
    #     shows only one.
    if ( $customer_conversion_goal->{category} eq PURCHASE
      && $customer_conversion_goal->{origin} eq WEBSITE)
    {
      $campaign_conversion_goal->{biddable} = "true";
    } else {
      $campaign_conversion_goal->{biddable} = "false";
    }

    push @$operations,
      Google::Ads::GoogleAds::V11::Services::GoogleAdsService::MutateOperation
      ->new({
        campaignConversionGoalOperation =>
          Google::Ads::GoogleAds::V11::Services::CampaignConversionGoalService::CampaignConversionGoalOperation
          ->new({
            update => $campaign_conversion_goal,
            # Set the update mask on the operation. Here the update mask will be
            # a list of all the fields that were set on the update object.
            updateMask => all_set_fields_of($campaign_conversion_goal)})});
  }

  return $operations;
}
# [END add_performance_max_retail_campaign_9]

# Creates a list of MutateOperations that create a new asset group listing group filter.
# [START add_performance_max_retail_campaign_10]
sub create_asset_group_listing_group_operations {
  my ($customer_id) = @_;

  my $operations = [];
  # Create a new listing group filter containing the "default" listing group (All
  # products).
  my $listing_group_filter =
    Google::Ads::GoogleAds::V11::Resources::AssetGroupListingGroupFilter->new({
      assetGroup =>
        Google::Ads::GoogleAds::V11::Utils::ResourceNames::asset_group(
        $customer_id, ASSET_GROUP_TEMPORARY_ID
        ),

      # Since this is the root node, do not set the parentListingGroupFilter.
      # For all other nodes, this would refer to the parent listing group filter
      # resource name.
      # parentListingGroupFilter => "<PARENT FILTER NAME>"

      # The subdivision type means this node has children. This type is used for
      # the root node as well.
      type => UNIT_INCLUDED,

      # Because this is a Performance Max campaign for retail, we need to specify
      # that this is in the shopping vertical.
      vertical => SHOPPING
    });

  push @$operations,
    Google::Ads::GoogleAds::V11::Services::GoogleAdsService::MutateOperation->
    new({
      assetGroupListingGroupFilterOperation =>
        Google::Ads::GoogleAds::V11::Services::AssetGroupListingGroupFilterService::AssetGroupListingGroupFilterOperation
        ->new({
          create => $listing_group_filter
        })});

  return $operations;
}
# [END add_performance_max_retail_campaign_10]

# Prints the details of a MutateGoogleAdsResponse.
# Parses the "response" oneof field name and uses it to extract the new entity's
# name and resource name.
sub print_response_details {
  my ($mutate_google_ads_response) = @_;

  foreach
    my $response (@{$mutate_google_ads_response->{mutateOperationResponses}})
  {
    my $result_type = [keys %$response]->[0];

    printf "Created a(n) %s with '%s'.\n",
      ucfirst $result_type =~ s/Result$//r,
      $response->{$result_type}{resourceName};
  }
}
# [END add_performance_max_retail_campaign]

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
  "sales_country=s"              => \$sales_country,
  "final_url=s"                  => \$final_url
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $merchant_center_account_id, $sales_country,
  $final_url);

# Call the example.
add_performance_max_retail_campaign($api_client, $customer_id =~ s/-//gr,
  $merchant_center_account_id, $sales_country, $final_url);

=pod

=head1 NAME

add_performance_max_retail_campaign

=head1 DESCRIPTION

This example shows how to create a Performance Max retail campaign.

This will be created for "All products".

For more information about Performance Max retail campaigns, see
https://developers.google.com/google-ads/api/docs/performance-max/retail.

Prerequisites:
- You need to have access to a Merchant Center account. You can find
  instructions to create a Merchant Center account here:
  https://support.google.com/merchants/answer/188924.
  This account must be linked to your Google Ads account. The integration
  instructions can be found at:
  https://developers.google.com/google-ads/api/docs/shopping-ads/merchant-center.
- You need your Google Ads account to track conversions. The different ways
  to track conversions can be found here:
  https://support.google.com/google-ads/answer/1722054.
- You must have at least one conversion action in the account. For more about
  conversion actions, see
  https://developers.google.com/google-ads/api/docs/conversions/overview#conversion_actions.

=head1 SYNOPSIS

add_performance_max_retail_campaign.pl [options]

    -help                         Show the help message.
    -customer_id                  The Google Ads customer ID.
    -merchant_center_account_id   The Merchant Center account ID.
    -sales_country                [optional] The sales country of products to include in the campaign.
    -final_url                    [optional] The final URL for the asset group of the campaign.

=cut
