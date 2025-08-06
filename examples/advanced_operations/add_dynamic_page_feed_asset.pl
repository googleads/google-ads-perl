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
# Adds a page feed with URLs for a Dynamic Search Ads campaign.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Resources::Asset;
use Google::Ads::GoogleAds::V21::Resources::AssetSet;
use Google::Ads::GoogleAds::V21::Resources::AssetSetAsset;
use Google::Ads::GoogleAds::V21::Resources::CampaignAssetSet;
use Google::Ads::GoogleAds::V21::Resources::AdGroupCriterion;
use Google::Ads::GoogleAds::V21::Common::PageFeedAsset;
use Google::Ads::GoogleAds::V21::Common::WebpageConditionInfo;
use Google::Ads::GoogleAds::V21::Common::WebpageInfo;
use Google::Ads::GoogleAds::V21::Enums::AssetSetTypeEnum qw(PAGE_FEED);
use Google::Ads::GoogleAds::V21::Enums::WebpageConditionOperandEnum
  qw(CUSTOM_LABEL);
use Google::Ads::GoogleAds::V21::Services::AssetService::AssetOperation;
use Google::Ads::GoogleAds::V21::Services::AssetSetService::AssetSetOperation;
use
  Google::Ads::GoogleAds::V21::Services::AssetSetAssetService::AssetSetAssetOperation;
use
  Google::Ads::GoogleAds::V21::Services::CampaignAssetSetService::CampaignAssetSetOperation;
use
  Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

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
my $campaign_id = "INSERT_CAMPAIGN_ID_HERE";
my $ad_group_id = "INSERT_AD_GROUP_ID_HERE";

sub add_dynamic_page_feed_asset {
  my ($api_client, $customer_id, $campaign_id, $ad_group_id) = @_;

  # The label for the DSA page URLs.
  my $dsa_page_url_label = "discounts";

  # Create the Assets.
  my $asset_resource_names =
    create_assets($api_client, $customer_id, $dsa_page_url_label);

  # Create an AssetSet - this is a collection of assets that can be associated
  # with a campaign.
  # Note: do not confuse this with an AssetGroup. An AssetGroup replaces AdGroups
  # in some types of campaigns.
  my $asset_set_resource_name = create_asset_set($api_client, $customer_id);

  # Add the Assets to the AssetSet.
  add_assets_to_asset_set($api_client, $customer_id, $asset_resource_names,
    $asset_set_resource_name);

  # Link the AssetSet to the Campaign.
  link_asset_set_to_campaign($api_client, $customer_id, $campaign_id,
    $asset_set_resource_name);

  # Optional: Target web pages matching the feed's label in the ad group.
  add_dsa_target($api_client, $customer_id, $ad_group_id, $dsa_page_url_label);

  printf "Dynamic page feed setup is complete for campaign with ID %d.\n",
    $campaign_id;

  return 1;
}

# Creates Assets to be used in a DSA page feed.
sub create_assets {
  my ($api_client, $customer_id, $dsa_page_url_label) = @_;

  # [START add_asset]
  my $urls = [
    "http://www.example.com/discounts/rental-cars",
    "http://www.example.com/discounts/hotel-deals",
    "http://www.example.com/discounts/flight-deals"
  ];

  # Create one operation per URL.
  my $asset_operations = [];
  foreach my $url (@$urls) {
    my $page_feed_asset =
      Google::Ads::GoogleAds::V21::Common::PageFeedAsset->new({
        # Set the URL of the page to include.
        pageUrl => $url,
        # Recommended: add labels to the asset. These labels can be used later in
        # ad group targeting to restrict the set of pages that can serve.
        labels => [$dsa_page_url_label]});
    my $asset = Google::Ads::GoogleAds::V21::Resources::Asset->new({
      pageFeedAsset => $page_feed_asset
    });

    push @$asset_operations,
      Google::Ads::GoogleAds::V21::Services::AssetService::AssetOperation->new({
        create => $asset
      });
  }

  # Add the assets.
  my $response = $api_client->AssetService()->mutate({
    customerId => $customer_id,
    operations => $asset_operations
  });

  # Print some information about the response.
  my $resource_names = [];
  foreach my $result (@{$response->{results}}) {
    push @$resource_names, $result->{resourceName};
    printf "Created asset with resource name '%s'.\n", $result->{resourceName};
  }
  return $resource_names;
  # [END add_asset]
}

# Creates an AssetSet.
sub create_asset_set {
  my ($api_client, $customer_id) = @_;

  # [START add_asset_set]
  # Create an AssetSet which will be used to link the dynamic page feed assets to
  # a campaign.
  my $asset_set = Google::Ads::GoogleAds::V21::Resources::AssetSet->new({
    name => "My dynamic page feed #" . uniqid(),
    type => PAGE_FEED
  });

  # Create an operation to add the AssetSet.
  my $operation =
    Google::Ads::GoogleAds::V21::Services::AssetSetService::AssetSetOperation->
    new({
      create => $asset_set
    });

  # Send the mutate request.
  my $response = $api_client->AssetSetService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});

  # Print some information about the response.
  my $resource_name = $response->{results}[0]{resourceName};
  printf "Created asset set with resource name '%s'.\n", $resource_name;
  return $resource_name;
  # [END add_asset_set]
}

# Adds the Assets to an AssetSet by creating an AssetSetAsset link.
sub add_assets_to_asset_set {
  my ($api_client, $customer_id, $asset_resource_names,
    $asset_set_resource_name)
    = @_;

  # [START add_asset_set_asset]
  my $operations = [];
  foreach my $asset_resource_name (@$asset_resource_names) {
    my $asset_set_asset =
      Google::Ads::GoogleAds::V21::Resources::AssetSetAsset->new({
        asset    => $asset_resource_name,
        assetSet => $asset_set_resource_name
      });

    # Create an operation to add the link.
    my $operation =
      Google::Ads::GoogleAds::V21::Services::AssetSetAssetService::AssetSetAssetOperation
      ->new({
        create => $asset_set_asset
      });
    push @$operations, $operation;
  }

  # Send the mutate request.
  my $response = $api_client->AssetSetAssetService()->mutate({
    customerId => $customer_id,
    operations => $operations
  });

  # Print some information about the response.
  my $resource_name = $response->{results}[0]{resourceName};
  printf "Created AssetSetAsset link with resource name '%s'.\n",
    $resource_name;
  # [END add_asset_set_asset]
}

# Links an AssetSet to a Campaign by creating a CampaignAssetSet.
sub link_asset_set_to_campaign {
  my ($api_client, $customer_id, $campaign_id, $asset_set_resource_name) = @_;

  # [START add_campaign_asset_set]
  # Create a CampaignAssetSet representing the link between an AssetSet and a Campaign.
  my $campaign_asset_set =
    Google::Ads::GoogleAds::V21::Resources::CampaignAssetSet->new({
      campaign => Google::Ads::GoogleAds::V21::Utils::ResourceNames::campaign(
        $customer_id, $campaign_id
      ),
      assetSet => $asset_set_resource_name
    });

  # Create an operation to add the CampaignAssetSet.
  my $operation =
    Google::Ads::GoogleAds::V21::Services::CampaignAssetSetService::CampaignAssetSetOperation
    ->new({
      create => $campaign_asset_set
    });

  # Issue the mutate request.
  my $response = $api_client->CampaignAssetSetService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});

  # Print some information about the response.
  my $resource_name = $response->{results}[0]{resourceName};
  printf "Created a CampaignAssetSet with resource name '%s'.\n",
    $resource_name;
  # [END add_campaign_asset_set]
}

# Creates an ad group criterion targeting the DSA label.
sub add_dsa_target {
  my ($api_client, $customer_id, $ad_group_id, $dsa_page_url_label) = @_;

  # [START add_dsa_target]
  my $ad_group_resource_name =
    Google::Ads::GoogleAds::V21::Utils::ResourceNames::ad_group($customer_id,
    $ad_group_id);

  # Create the webpage condition info that targets an advertiser's webpages based
  # on the custom label specified by the $dsa_page_url_label (e.g. "discounts").
  my $webpage_condition_info =
    Google::Ads::GoogleAds::V21::Common::WebpageConditionInfo->new({
      operand  => CUSTOM_LABEL,
      argument => $dsa_page_url_label
    });

  # Create the webpage info, or criterion for targeting webpages of an advertiser's website.
  my $webpage_info = Google::Ads::GoogleAds::V21::Common::WebpageInfo->new({
      criterionName => "Test Criterion",
      conditions    => [$webpage_condition_info]});

  # Create the ad group criterion.
  my $ad_group_criterion =
    Google::Ads::GoogleAds::V21::Resources::AdGroupCriterion->new({
      adGroup      => $ad_group_resource_name,
      webpage      => $webpage_info,
      cpcBidMicros => 1_500_000
    });

  # Create the operation.
  my $operation =
    Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation
    ->new({
      create => $ad_group_criterion
    });

  # Add the ad group criterion.
  my $response = $api_client->AdGroupCriterionService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});

  # Display the results.
  printf "Created ad group criterion with resource name '%s'.\n",
    $response->{results}[0]{resourceName};
  # [END add_dsa_target]
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
  "campaign_id=i" => \$campaign_id,
  "ad_group_id=i" => \$ad_group_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $campaign_id, $ad_group_id);

# Call the example.
add_dynamic_page_feed_asset($api_client, $customer_id =~ s/-//gr,
  $campaign_id, $ad_group_id);

=pod

=head1 NAME

add_dynamic_page_feed_asset

=head1 DESCRIPTION

Adds a page feed with URLs for a Dynamic Search Ads campaign.

=head1 SYNOPSIS

add_dynamic_page_feed_asset.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.
    -ad_group_id                The ad group ID.

=cut
