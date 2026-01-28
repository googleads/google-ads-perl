#!/usr/bin/perl -w
#
# Copyright 2023, Google LLC
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
# This example shows how to create a Performance Max for travel goals campaign. It also uses
# TravelAssetSuggestionService to fetch suggested assets for creating an asset group. In case
# there are not enough assets for the asset group (required by Performance Max), this example will
# create more assets to fulfill the requirements.
#
# For more information about Performance Max campaigns, see
# https://developers.google.com/google-ads/api/docs/performance-max/overview.
#
# Prerequisites:
# - You must have at least one conversion action in the account. For more about conversion actions,
# see https://developers.google.com/google-ads/api/docs/conversions/overview#conversion_actions.
#
# Notes:
# - This example uses the default customer conversion goals. For an example of setting
#   campaign-specific conversion goals, see shopping_ads/add_performance_max_retail_campaign.pl.
# - To learn how to create asset group signals, see
#   advanced_operations/add_performance_max_campaign.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::MediaUtils;
use Google::Ads::GoogleAds::V23::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V23::Resources::Campaign;
use Google::Ads::GoogleAds::V23::Resources::Asset;
use Google::Ads::GoogleAds::V23::Resources::AssetGroup;
use Google::Ads::GoogleAds::V23::Resources::AssetGroupAsset;
use Google::Ads::GoogleAds::V23::Resources::AssetSet;
use Google::Ads::GoogleAds::V23::Resources::AssetSetAsset;
use Google::Ads::GoogleAds::V23::Common::CallToActionAsset;
use Google::Ads::GoogleAds::V23::Common::MaximizeConversionValue;
use Google::Ads::GoogleAds::V23::Common::TextAsset;
use Google::Ads::GoogleAds::V23::Common::HotelPropertyAsset;
use Google::Ads::GoogleAds::V23::Common::ImageAsset;
use Google::Ads::GoogleAds::V23::Enums::BudgetDeliveryMethodEnum qw(STANDARD);
use Google::Ads::GoogleAds::V23::Enums::CampaignStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::AdvertisingChannelTypeEnum
  qw(PERFORMANCE_MAX);
use Google::Ads::GoogleAds::V23::Enums::AssetGroupStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::AssetFieldTypeEnum
  qw(HEADLINE DESCRIPTION LONG_HEADLINE BUSINESS_NAME LOGO MARKETING_IMAGE SQUARE_MARKETING_IMAGE HOTEL_PROPERTY CALL_TO_ACTION_SELECTION);
use Google::Ads::GoogleAds::V23::Enums::HotelAssetSuggestionStatusEnum
  qw(SUCCESS);
use Google::Ads::GoogleAds::V23::Enums::EuPoliticalAdvertisingStatusEnum
  qw(DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING);
use Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation;
use
  Google::Ads::GoogleAds::V23::Services::CampaignBudgetService::CampaignBudgetOperation;
use Google::Ads::GoogleAds::V23::Services::CampaignService::CampaignOperation;
use Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation;
use
  Google::Ads::GoogleAds::V23::Services::AssetGroupService::AssetGroupOperation;
use
  Google::Ads::GoogleAds::V23::Services::AssetGroupAssetService::AssetGroupAssetOperation;
use Google::Ads::GoogleAds::V23::Services::AssetSetService::AssetSetOperation;
use
  Google::Ads::GoogleAds::V23::Services::AssetSetAssetService::AssetSetAssetOperation;
use Google::Ads::GoogleAds::V23::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);

# Minimum requirements of assets required in a Performance Max asset group.
# See https://developers.google.com/google-ads/api/docs/performance-max/assets for details.
my $min_required_text_asset_counts = {
  HEADLINE      => 3,
  LONG_HEADLINE => 1,
  DESCRIPTION   => 2,
  BUSINESS_NAME => 1,
};

my $min_required_image_asset_counts = {
  MARKETING_IMAGE        => 1,
  SQUARE_MARKETING_IMAGE => 1,
  LOGO                   => 1,
};

# Texts and URLs used to create text and image assets when the TravelAssetSuggestionService
# doesn't return enough assets required for creating an asset group.
my $default_text_assets_info = {
  HEADLINE      => ['Hotel', 'Travel Reviews', 'Book travel'],
  LONG_HEADLINE => ['Travel the World'],
  DESCRIPTION => ['Great deal for your beloved hotel', 'Best rate guaranteed',],
  BUSINESS_NAME => ['Interplanetary Cruises'],
};

my $default_image_assets_info = {
  MARKETING_IMAGE        => ['https://gaagl.page.link/Eit5'],
  SQUARE_MARKETING_IMAGE => ['https://gaagl.page.link/bjYi'],
  LOGO                   => ['https://gaagl.page.link/bjYi'],
};

# We specify temporary IDs that are specific to a single mutate request.
# Temporary IDs are always negative and unique within one mutate request.
#
# See https://developers.google.com/google-ads/api/docs/mutating/best-practices
# for further details.
#
# These temporary IDs are fixed because they are used in multiple places.
use constant ASSET_TEMPORARY_ID       => -1;
use constant BUDGET_TEMPORARY_ID      => -2;
use constant CAMPAIGN_TEMPORARY_ID    => -3;
use constant ASSET_GROUP_TEMPORARY_ID => -4;

# There are also entities that will be created in the same request but do not need to be fixed
# temporary IDs because they are referenced only once.
our $next_temp_id = ASSET_GROUP_TEMPORARY_ID - 1;

sub add_performance_max_for_travel_goals_campaign {
  my ($api_client, $customer_id, $place_id) = @_;

  my $hotel_asset_suggestion =
    get_hotel_asset_suggestion($api_client, $customer_id, $place_id);

  # Performance Max campaigns require that repeated assets such as headlines
  # and descriptions be created before the campaign.
  # For the list of required assets for a Performance Max campaign, see
  # https://developers.google.com/google-ads/api/docs/performance-max/assets.
  #
  # This step is the same for any types of Performance Max campaigns.

  # Create the headlines using the hotel asset suggestion.
  my $headline_asset_resource_names =
    create_multiple_text_assets($api_client, $customer_id, HEADLINE,
    $hotel_asset_suggestion);

  my $description_asset_resource_names =
    create_multiple_text_assets($api_client, $customer_id, DESCRIPTION,
    $hotel_asset_suggestion);

  # Create a hotel property asset set, which will be used later to link with a newly created
  # campaign.
  my $hotel_property_asset_set_resource_name =
    create_hotel_asset_set($api_client, $customer_id);

  # Create a hotel property asset and link it with the previously created hotel property
  # asset set. This asset will also be linked to an asset group in the later steps.
  # In the real-world scenario, you'd need to create many assets for all your hotel
  # properties. We use one hotel property here for simplicity.
  # Both asset and asset set need to be created before creating a campaign, so we cannot
  # bundle them with other mutate operations below.
  my $hotel_property_asset_resource_name =
    create_hotel_asset($api_client, $customer_id, $place_id,
    $hotel_property_asset_set_resource_name);

  # It's important to create the below entities in this order because they depend on
  # each other.
  # The below methods create and return mutate operations that we later provide to the
  # GoogleAdsService.Mutate method in order to create the entities in a single request.
  # Since the entities for a Performance Max campaign are closely tied to one-another, it's
  # considered a best practice to create them in a single Mutate request so they all complete
  # successfully or fail entirely, leaving no orphaned entities. See:
  # https://developers.google.com/google-ads/api/docs/mutating/overview.
  my $operations = [];
  push @$operations, create_campaign_budget_operation($customer_id);
  push @$operations,
    create_campaign_operation($customer_id,
    $hotel_property_asset_set_resource_name);
  push @$operations,
    @{
    create_asset_group_operations(
      $customer_id,                   $hotel_property_asset_resource_name,
      $headline_asset_resource_names, $description_asset_resource_names,
      $hotel_asset_suggestion
    )};

  # Issue a mutate request to create everything and print its information.
  my $mutate_google_ads_response = $api_client->GoogleAdsService()->mutate({
    customerId       => $customer_id,
    mutateOperations => $operations
  });
  printf
"Created the following entities for a campaign budget, a campaign, and an asset group"
    . " for Performance Max for travel goals:\n";
  print_response_details($mutate_google_ads_response);
}

# Return hotel asset suggestion obtained from TravelAssetsSuggestionService.
# [START get_hotel_asset_suggestion]
sub get_hotel_asset_suggestion {
  my ($api_client, $customer_id, $place_id) = @_;

  # Send a request to suggest assets to be created as an asset group for the Performance Max
  # for travel goals campaign.
  my $suggest_travel_assets_response =
    $api_client->TravelAssetSuggestionService()->suggest_travel_assets({
      customerId => $customer_id,
      # Uses 'en-US' as an example. It can be any language specifications in BCP 47 format.
      languageOption => 'en-US',
      # The service accepts several place IDs. We use only one here for demonstration.
      placeIds => [$place_id],
    });

  printf "Fetched a hotel asset suggestion for the place ID '%s'.\n", $place_id;
  return $suggest_travel_assets_response->{hotelAssetSuggestions}[0];
}
# [END get_hotel_asset_suggestion]

# Create multiple text assets and returns the list of resource names. The hotel asset
# suggestion is used to create a text asset first. If the number of created text assets is
# still fewer than the minimum required number of assets of the specified asset field type,
# adds more text assets to fulfill the requirement.
sub create_multiple_text_assets {
  my ($api_client, $customer_id, $asset_field_type, $hotel_asset_suggestion) =
    @_;
  # We use the GoogleAdService to create multiple text assets in a single request.
  # First, add all the text assets of the specified asset field type.
  my $operations = [];

  if ($hotel_asset_suggestion->{status} eq SUCCESS) {
    foreach my $text_asset (@{$hotel_asset_suggestion->{textAssets}}) {
      if ($text_asset->{assetFieldType} ne $asset_field_type) {
        next;
      }
      push @$operations,
        Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation
        ->new({
          assetOperation =>
            Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation
            ->new({
              create => Google::Ads::GoogleAds::V23::Resources::Asset->new({
                  textAsset =>
                    Google::Ads::GoogleAds::V23::Common::TextAsset->new({
                      text => $text_asset->{text}})})})});
    }
  }

  # If the added assets are still less than the minimum required assets for the asset field
  # type, add more text assets using the default texts.
  my $min_count = $min_required_text_asset_counts->{$asset_field_type};
  my $num_operations_added = scalar @$operations;
  for (my $i = 0 ; $i < $min_count - $num_operations_added ; $i++) {
    my $text = $default_text_assets_info->{$asset_field_type}[$i++];
    # Creates a mutate operation for a text asset, using the default text.
    push @$operations,
      Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation
      ->new({
        assetOperation =>
          Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation->
          new({
            create => Google::Ads::GoogleAds::V23::Resources::Asset->new({
                textAsset =>
                  Google::Ads::GoogleAds::V23::Common::TextAsset->new({
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

# Create a hotel property asset set.
# [START create_hotel_asset_set]
sub create_hotel_asset_set {
  my ($api_client, $customer_id) = @_;

  my $asset_set_operation =
    Google::Ads::GoogleAds::V23::Services::AssetSetService::AssetSetOperation->
    new({
      # Creates a hotel property asset set.
      create => Google::Ads::GoogleAds::V23::Resources::AssetSet->new({
          name => 'My Hotel propery asset set #' . uniqid(),
          type => HOTEL_PROPERTY
        })});
  # Issues a mutate request to add a hotel asset set and prints its information.
  my $response = $api_client->AssetSetService()->mutate({
      customerId => $customer_id,
      operations => [$asset_set_operation]});

  my $asset_set_resource_name = $response->{results}[0]{resourceName};
  printf "Created an asset set with resource name: '%s'.\n",
    $asset_set_resource_name;

  return $asset_set_resource_name;
}
# [END create_hotel_asset_set]

# Create a hotel property asset using the specified place ID. The place ID must belong to
# a hotel property. Then, links it to the specified asset set.
#
# See https://developers.google.com/places/web-service/place-id to search for a hotel place ID.
# [START create_hotel_asset]
sub create_hotel_asset {
  my ($api_client, $customer_id, $place_id, $asset_set_resource_name) = @_;

  # We use the GoogleAdService to create an asset and asset set asset in a single request.
  my $operations = [];
  my $asset_resource_name =
    Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset($customer_id,
    ASSET_TEMPORARY_ID);

  # Create a mutate operation for a hotel property asset.
  push @$operations,
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({
      assetOperation =>
        Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation->
        new({
          create => Google::Ads::GoogleAds::V23::Resources::Asset->new({
              resourceName       => $asset_resource_name,
              hotelPropertyAsset =>
                Google::Ads::GoogleAds::V23::Common::HotelPropertyAsset->new({
                  placeId => $place_id
                })})})});

  # Create a mutate operation for an asset set asset.
  push @$operations,
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({
      assetSetAssetOperation =>
        Google::Ads::GoogleAds::V23::Services::AssetSetAssetService::AssetSetAssetOperation
        ->new({
          create => Google::Ads::GoogleAds::V23::Resources::AssetSetAsset->new({
              asset    => $asset_resource_name,
              assetSet => $asset_set_resource_name
            })})});

  # Issue a mutate request to create all entities.
  my $mutate_google_ads_response = $api_client->GoogleAdsService()->mutate({
    customerId       => $customer_id,
    mutateOperations => $operations
  });

  printf "Created the following entities for the hotel asset:\n";
  print_response_details($mutate_google_ads_response);

  # Return the created asset resource name, which will be used later to create an asset
  # group. Other resource names are not used later.
  return $mutate_google_ads_response->{mutateOperationResponses}[0]
    {assetResult}{resourceName};
}
# [END create_hotel_asset]

# Create a mutate operation that creates a new campaign budget.
#
# A temporary ID will be assigned to this campaign budget so that it can be
# referenced by other objects being created in the same mutate request.
sub create_campaign_budget_operation {
  my ($customer_id) = @_;

  return
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({
      campaignBudgetOperation =>
        Google::Ads::GoogleAds::V23::Services::CampaignBudgetService::CampaignBudgetOperation
        ->new({
          create => Google::Ads::GoogleAds::V23::Resources::CampaignBudget->new(
            {
              # Set a temporary ID in the budget's resource name so it can be
              # referenced by the campaign in later steps.
              resourceName =>
                Google::Ads::GoogleAds::V23::Utils::ResourceNames::campaign_budget(
                $customer_id, BUDGET_TEMPORARY_ID
                ),
              name => "Performance Max for travel goals campaign budget #" .
                uniqid(),
              # The budget period already defaults to DAILY.
              amountMicros   => 50000000,
              deliveryMethod => STANDARD,
              # A Performance Max campaign cannot use a shared campaign budget.
              explicitlyShared => "false",
            })})});
}

# Create a mutate operation that creates a new Performance Max campaign. Links the specified
# hotel property asset set to this campaign.
#
# A temporary ID will be assigned to this campaign so that it can be referenced by other
# objects being created in the same mutate request.
# [START create_campaign]
sub create_campaign_operation {
  my ($customer_id, $hotel_property_asset_set_resource_name) = @_;

  # Create a mutate operation that creates a campaign operation.
  return
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({
      campaignOperation =>
        Google::Ads::GoogleAds::V23::Services::CampaignService::CampaignOperation
        ->new({
          create => Google::Ads::GoogleAds::V23::Resources::Campaign->new({
              # Assign the resource name with a temporary ID.
              resourceName =>
                Google::Ads::GoogleAds::V23::Utils::ResourceNames::campaign(
                $customer_id, CAMPAIGN_TEMPORARY_ID
                ),
              name => "Performance Max for travel goals campaign #'" . uniqid(),
              # Set the budget using the given budget resource name.
              campaignBudget =>
                Google::Ads::GoogleAds::V23::Utils::ResourceNames::campaign_budget(
                $customer_id, BUDGET_TEMPORARY_ID
                ),
              # Set the campaign status as PAUSED. The campaign is the only entity in
              # the mutate request that should have its status set.
              status =>
                Google::Ads::GoogleAds::V23::Enums::CampaignStatusEnum::PAUSED,
              # All Performance Max campaigns have an advertisingChannelType of
              # PERFORMANCE_MAX. The advertisingChannelSubType should not be set.
              advertisingChannelType => PERFORMANCE_MAX,

              # To create a Performance Max for travel goals campaign, you need to set
              # `hotelPropertyAssetSet`.
              hotelPropertyAssetSet => $hotel_property_asset_set_resource_name,

              # Declare whether or not this campaign serves political ads targeting the EU.
              # Valid values are CONTAINS_EU_POLITICAL_ADVERTISING and
              # DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING.
              containsEuPoliticalAdvertising =>
                DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING,

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
                Google::Ads::GoogleAds::V23::Common::MaximizeConversionValue->
                new({
                  targetRoas => 3.5
                })})})});
}
# [END create_campaign]

# Create a list of mutate operations that create a new asset group, composed of suggested
# assets. In case the number of suggested assets is not enough for the requirements, it'll
# create more assets to meet the requirement.
#
# For the list of required assets for a Performance Max campaign, see
# https://developers.google.com/google-ads/api/docs/performance-max/assets.
sub create_asset_group_operations {
  my (
    $customer_id,
    $hotel_property_asset_resource_name,
    $headline_asset_resource_names,
    $description_asset_resource_names,
    $hotel_asset_suggestion
  ) = @_;
  my $operations = [];

  # Create a new mutate operation that creates an asset group using suggested information
  # when available.
  my $asset_group_name =
      $hotel_asset_suggestion->{status} eq SUCCESS
    ? $hotel_asset_suggestion->{hotelName}
    : 'Performance Max for travel goals asset group #' . uniqid();
  my $asset_group_final_urls =
    $hotel_asset_suggestion->{status} eq SUCCESS
    ? [$hotel_asset_suggestion->{finalUrl}]
    : ['http://www.example.com'];
  my $asset_group_resource_name =
    Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset_group($customer_id,
    ASSET_GROUP_TEMPORARY_ID);
  push @$operations,
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({
      assetGroupOperation =>
        Google::Ads::GoogleAds::V23::Services::AssetGroupService::AssetGroupOperation
        ->new({
          create => Google::Ads::GoogleAds::V23::Resources::AssetGroup->new({
              resourceName => $asset_group_resource_name,
              name         => $asset_group_name,
              campaign     =>
                Google::Ads::GoogleAds::V23::Utils::ResourceNames::campaign(
                $customer_id, CAMPAIGN_TEMPORARY_ID
                ),
              finalUrls => $asset_group_final_urls,
              status    =>
                Google::Ads::GoogleAds::V23::Enums::AssetGroupStatusEnum::PAUSED
            })})});

  # An asset group is linked to an asset by creating a new asset group asset and providing:
  # -  the resource name of the asset group
  # -  the resource name of the asset
  # -  the field_type of the asset in this asset group
  #
  # To learn more about asset groups, see
  # https://developers.google.com/google-ads/api/docs/performance-max/asset-groups.
  #
  # Headline and description assets were created at the first step of this example. So, we
  # just need to link them with the created asset group.
  #
  # Link the headline assets to the asset group.
  foreach my $resource_name (@$headline_asset_resource_names) {
    push @$operations,
      Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation
      ->new({
        assetGroupAssetOperation =>
          Google::Ads::GoogleAds::V23::Services::AssetGroupAssetService::AssetGroupAssetOperation
          ->new({
            create =>
              Google::Ads::GoogleAds::V23::Resources::AssetGroupAsset->new({
                asset      => $resource_name,
                assetGroup =>
                  Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset_group(
                  $customer_id, ASSET_GROUP_TEMPORARY_ID
                  ),
                fieldType => HEADLINE
              })})});
  }

  # Link the description assets.
  foreach my $resource_name (@$description_asset_resource_names) {
    push @$operations,
      Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation
      ->new({
        assetGroupAssetOperation =>
          Google::Ads::GoogleAds::V23::Services::AssetGroupAssetService::AssetGroupAssetOperation
          ->new({
            create =>
              Google::Ads::GoogleAds::V23::Resources::AssetGroupAsset->new({
                asset      => $resource_name,
                assetGroup =>
                  Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset_group(
                  $customer_id, ASSET_GROUP_TEMPORARY_ID
                  ),
                fieldType => DESCRIPTION
              })})});
  }

  # [START link_hotel_asset]
  # Link the previously created hotel property asset to the asset group. In the real-world
  # scenario, you'd need to do this step several times for each hotel property asset.
  push @$operations,
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({
      assetGroupAssetOperation =>
        Google::Ads::GoogleAds::V23::Services::AssetGroupAssetService::AssetGroupAssetOperation
        ->new({
          create =>
            Google::Ads::GoogleAds::V23::Resources::AssetGroupAsset->new({
              asset      => $hotel_property_asset_resource_name,
              assetGroup => $asset_group_resource_name,
              fieldType  => HOTEL_PROPERTY
            })})});
  # [END link_hotel_asset]

  # Create the rest of required text assets and link them to the asset group.
  push @$operations,
    @{create_text_assets_for_asset_group($customer_id, $hotel_asset_suggestion)
    };

  # Create the image assets and link them to the asset group. Some optional image assets
  # suggested by the TravelAssetSuggestionService might be created too.
  push @$operations,
    @{create_image_assets_for_asset_group($customer_id, $hotel_asset_suggestion)
    };

  if ($hotel_asset_suggestion->{status} eq SUCCESS) {
    # Create a new mutate operation for a suggested call-to-action asset and link it
    # to the asset group.
    push @$operations,
      Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation
      ->new({
        assetOperation =>
          Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation->
          new({
            create => Google::Ads::GoogleAds::V23::Resources::Asset->new({
                resourceName =>
                  Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset(
                  $customer_id, $next_temp_id
                  ),
                name => 'Suggested call-to-action asset #' . uniqid(),
                callToActionAsset =>
                  Google::Ads::GoogleAds::V23::Common::CallToActionAsset->new({
                    callToAction => $hotel_asset_suggestion->{callToAction}})})}
          )});
    push @$operations,
      Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation
      ->new({
        assetGroupAssetOperation =>
          Google::Ads::GoogleAds::V23::Services::AssetGroupAssetService::AssetGroupAssetOperation
          ->new({
            create =>
              Google::Ads::GoogleAds::V23::Resources::AssetGroupAsset->new({
                asset =>
                  Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset(
                  $customer_id, $next_temp_id
                  ),
                assetGroup => $asset_group_resource_name,
                fieldType  => CALL_TO_ACTION_SELECTION
              })})});
    $next_temp_id--;
  }

  return $operations;
}

# Create text assets required for an asset group using the suggested hotel text assets. It adds
# more text assets to fulfill the requirements if the suggested hotel text assets are not enough.
sub create_text_assets_for_asset_group {
  my ($customer_id, $hotel_asset_suggestion) = @_;

  # Create mutate operations for the suggested text assets except for headlines and
  # descriptions, which were created previously.
  my $operations = [];

  # Create a map of asset field type to number of text values.
  my $required_text_asset_counts = {};
  foreach my $field_type (keys %$min_required_text_asset_counts) {
    $required_text_asset_counts->{$field_type} = 0;
  }

  if ($hotel_asset_suggestion->{status} eq SUCCESS) {
    # Add text values of suggested text assets.
    foreach my $hotel_text_asset (@{$hotel_asset_suggestion->{textAssetsList}})
    {
      my $asset_field_type = $hotel_text_asset->{assetFieldType};
      if ($asset_field_type eq HEADLINE or $asset_field_type eq DESCRIPTION) {
        # Headlines and descriptions were already created at the first step of this code example.
        next;
      }
      printf
"A text asset with text '%s' is suggested for the asset field type '%s'.\n",
        $hotel_text_asset->{text}, $asset_field_type;

      push @$operations,
        @{
        create_text_asset_and_asset_group_asset_operations(
          $customer_id, $hotel_text_asset->{text},
          $hotel_text_asset->{assetFieldType})};
      $required_text_asset_counts->{$asset_field_type}++;
    }
  }

  # Add more text values by field type to fulfill the requirements.
  foreach my $asset_field_type (keys %$min_required_text_asset_counts) {
    if ($asset_field_type eq HEADLINE or $asset_field_type eq DESCRIPTION) {
      # Headlines and descriptions were already created at the first step of this code example.
      next;
    }

    my $min_count = $min_required_text_asset_counts->{$asset_field_type};
    for (
      my $i = 0 ;
      $i < $min_count - $required_text_asset_counts->{$asset_field_type} ;
      $i++
      )
    {
      my $text_from_defaults =
        $default_text_assets_info->{$asset_field_type}[$i++];
      printf
"A default text '%s' is used to create a text asset for the asset field type '%s'.\n",
        $text_from_defaults, $asset_field_type;
      push @$operations,
        @{
        create_text_asset_and_asset_group_asset_operations($customer_id,
          $text_from_defaults, $asset_field_type)};

    }
  }

  return $operations;
}

# Create image assets required for an asset group using the suggested hotel image assets. It
# adds more image assets to fulfill the requirements if the suggested hotel image assets are
# not enough.
sub create_image_assets_for_asset_group {
  my ($customer_id, $hotel_asset_suggestion) = @_;

  my $operations = [];
  # Create mutate operations for the suggested image assets.
  # Create a map of asset field type to number of text values.
  my $required_image_asset_counts = {};
  foreach my $field_type (keys %$min_required_image_asset_counts) {
    $required_image_asset_counts->{$field_type} = 0;
  }
  foreach my $hotel_image_asset (@{$hotel_asset_suggestion->{imageAssets}}) {
    printf
"An image asset with url '%s' is suggested for the asset field type '%s'.\n",
      $hotel_image_asset->{uri}, $hotel_image_asset->{assetFieldType};
    push @$operations,
      @{
      create_image_asset_and_asset_group_asset_operations(
        $customer_id,
        $hotel_image_asset->{uri},
        $hotel_image_asset->{assetFieldType},
        'Suggested image asset #' . uniqid())};
    # Keeps track of only required image assets. The service may sometimes suggest optional
    # image assets.
    if (
      exists $required_image_asset_counts->
      {$hotel_image_asset->{assetFieldType}})
    {
      $required_image_asset_counts->{$hotel_image_asset->{assetFieldType}}++;
    }
  }

  # Add more image assets to fulfill the requirements.
  foreach my $asset_field_type (keys %$min_required_image_asset_counts) {
    my $min_count = $min_required_image_asset_counts->{$asset_field_type};
    for (
      my $i = 0 ;
      $i < $min_count - $required_image_asset_counts->{$asset_field_type} ;
      $i++
      )
    {
      my $image_from_defaults =
        $default_image_assets_info->{$asset_field_type}[$i++];
      printf
"A default image URL '%s' is used to create an image asset for the asset field type '%s'.\n",
        $image_from_defaults, $asset_field_type;
      push @$operations,
        @{
        create_image_asset_and_asset_group_asset_operations(
          $customer_id,      $image_from_defaults,
          $asset_field_type, lc $asset_field_type . uniqid())};
    }
  }

  return $operations;
}

# Create a list of mutate operations that create a new linked text asset.
sub create_text_asset_and_asset_group_asset_operations {
  my ($customer_id, $text, $field_type) = @_;

  my $operations = [];
  # Create a new mutate operation that creates a text asset.
  push @$operations,
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({
      assetOperation =>
        Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation->
        new({
          create => Google::Ads::GoogleAds::V23::Resources::Asset->new({
              resourceName =>
                Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset(
                $customer_id, $next_temp_id
                ),
              textAsset => Google::Ads::GoogleAds::V23::Common::TextAsset->new({
                  text => $text
                })})})});

  # Create an asset group asset to link the asset to the asset group.
  push @$operations,
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({
      assetGroupAssetOperation =>
        Google::Ads::GoogleAds::V23::Services::AssetGroupAssetService::AssetGroupAssetOperation
        ->new({
          create =>
            Google::Ads::GoogleAds::V23::Resources::AssetGroupAsset->new({
              asset => Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset(
                $customer_id, $next_temp_id
              ),
              assetGroup =>
                Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset_group(
                $customer_id, ASSET_GROUP_TEMPORARY_ID
                ),
              fieldType => $field_type
            })})});

  $next_temp_id--;

  return $operations;
}

# Create a list of mutate operations that create a new linked image asset.
sub create_image_asset_and_asset_group_asset_operations {
  my ($customer_id, $url, $field_type, $asset_name) = @_;

  my $operations = [];
  # Create a new mutate operation that creates an image asset.
  # Create a new mutate operation that creates a text asset.
  push @$operations,
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({
      assetOperation =>
        Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation->
        new({
          create => Google::Ads::GoogleAds::V23::Resources::Asset->new({
              resourceName =>
                Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset(
                $customer_id, $next_temp_id
                ),
              # Provide a unique friendly name to identify your asset.
              # When there is an existing image asset with the same content but a different
              # name, the new name will be dropped silently.
              name       => $asset_name,
              imageAsset =>
                Google::Ads::GoogleAds::V23::Common::ImageAsset->new({
                  data => get_base64_data_from_url($url)})})})});

  # Create an asset group asset to link the asset to the asset group.
  push @$operations,
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({
      assetGroupAssetOperation =>
        Google::Ads::GoogleAds::V23::Services::AssetGroupAssetService::AssetGroupAssetOperation
        ->new({
          create =>
            Google::Ads::GoogleAds::V23::Resources::AssetGroupAsset->new({
              asset => Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset(
                $customer_id, $next_temp_id
              ),
              assetGroup =>
                Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset_group(
                $customer_id, ASSET_GROUP_TEMPORARY_ID
                ),
              fieldType => $field_type
            })})});

  $next_temp_id--;

  return $operations;
}

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

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

my $customer_id = undef;
my $place_id    = undef;

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s" => \$customer_id,
  "place_id=s"    => \$place_id,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $place_id);

# Call the example.
add_performance_max_for_travel_goals_campaign($api_client,
  $customer_id =~ s/-//gr, $place_id);

=pod

=head1 NAME

add_performance_max_for_travel_goals_campaign

=head1 DESCRIPTION

This example shows how to create a Performance Max for travel goals campaign. It also uses
TravelAssetSuggestionService to fetch suggested assets for creating an asset group. In case
there are not enough assets for the asset group (required by Performance Max), this example will
create more assets to fulfill the requirements.

For more information about Performance Max campaigns, see
https://developers.google.com/google-ads/api/docs/performance-max/overview.

Prerequisites:
- You must have at least one conversion action in the account. For more about conversion actions,
see https://developers.google.com/google-ads/api/docs/conversions/overview#conversion_actions.

Notes:
- This example uses the default customer conversion goals. For an example of setting
  campaign-specific conversion goals, see shopping_ads/add_performance_max_retail_campaign.pl.
- To learn how to create asset group signals, see
  advanced_operations/add_performance_max_campaign.pl.

=head1 SYNOPSIS

add_performance_max_for_travel_goals_campaign.pl [options]

    -help                         Show the help message.
    -customer_id                  The Google Ads customer ID.
    -place_id 					  The place ID of a hotel property. A place ID uniquely identifies a place in the Google Places database. See https://developers.google.com/places/web-service/place-id to learn more.

=cut
