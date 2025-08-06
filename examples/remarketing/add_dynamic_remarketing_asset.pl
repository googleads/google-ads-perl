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
# Adds an asset for use in dynamic remarketing.

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
use Google::Ads::GoogleAds::V21::Common::DynamicEducationAsset;
use Google::Ads::GoogleAds::V21::Enums::AssetSetTypeEnum qw(DYNAMIC_EDUCATION);
use Google::Ads::GoogleAds::V21::Services::AssetService::AssetOperation;
use Google::Ads::GoogleAds::V21::Services::AssetSetService::AssetSetOperation;
use
  Google::Ads::GoogleAds::V21::Services::AssetSetAssetService::AssetSetAssetOperation;
use
  Google::Ads::GoogleAds::V21::Services::CampaignAssetSetService::CampaignAssetSetOperation;
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
# Specify a campaign type which supports dynamic remarketing, such as Display.
my $campaign_id = "INSERT_CAMPAIGN_ID_HERE";

sub add_dynamic_remarketing_asset {
  my ($api_client, $customer_id, $campaign_id) = @_;

  # Create an Asset.
  my $asset_resource_name = create_asset($api_client, $customer_id);

  # Create an AssetSet - this is a collection of assets that can be associated
  # with a campaign.
  # Note: do not confuse this with an AssetGroup. An AssetGroup replaces AdGroups
  # in some types of campaigns.
  my $asset_set_resource_name = create_asset_set($api_client, $customer_id);

  # Add the Asset to the AssetSet.
  add_assets_to_asset_set($api_client, $customer_id, $asset_resource_name,
    $asset_set_resource_name);

  # Finally link the AssetSet to the Campaign.
  link_asset_set_to_campaign($api_client, $customer_id, $campaign_id,
    $asset_set_resource_name);

  return 1;
}

# Creates an Asset to use in dynamic remarketing.
sub create_asset {
  my ($api_client, $customer_id) = @_;

  # [START add_asset]
  # Create a DynamicEducationAsset.
  # See https://support.google.com/google-ads/answer/6053288?#zippy=%2Ceducation
  # for a detailed explanation of the field format.
  my $education_asset =
    Google::Ads::GoogleAds::V21::Common::DynamicEducationAsset->new({
      # Define meta-information about the school and program.
      schoolName         => "The University of Unknown",
      address            => "Building 1, New York, 12345, USA",
      programName        => "BSc. Computer Science",
      subject            => "Computer Science",
      programDescription => "Slinging code for fun and profit!",
      # Set up the program ID which is the ID that should be specified in the
      # tracking pixel.
      programId => "bsc-cs-uofu",
      # Set up the location ID which may additionally be specified in the tracking pixel.
      locationId     => "nyc",
      imageUrl       => "https://gaagl.page.link/Eit5",
      androidAppLink =>
        "android-app://com.example.android/http/example.com/gizmos?1234",
      iosAppLink    => "exampleApp://content/page",
      iosAppStoreId => 123
    });
  my $asset = Google::Ads::GoogleAds::V21::Resources::Asset->new({
      dynamicEducationAsset => $education_asset,
      finalUrls             => ["https://www.example.com"]});

  # Create an operation to add the asset.
  my $operation =
    Google::Ads::GoogleAds::V21::Services::AssetService::AssetOperation->new({
      create => $asset
    });

  # Send the mutate request.
  my $response = $api_client->AssetService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});

  # Print some information about the response.
  my $resource_name = $response->{results}[0]{resourceName};
  printf "Created a dynamic education asset with resource name '%s'.\n",
    $resource_name;
  return $resource_name;
  # [END add_asset]
}

# Creates an AssetSet.
sub create_asset_set {
  my ($api_client, $customer_id) = @_;

  # [START add_asset_set]
  # Create an AssetSet which will be used to link the dynamic remarketing assets
  # to a campaign.
  my $asset_set = Google::Ads::GoogleAds::V21::Resources::AssetSet->new({
    name => "My dynamic remarketing assets #" . uniqid(),
    type => DYNAMIC_EDUCATION
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

# Adds an Asset to an AssetSet by creating an AssetSetAsset link.
sub add_assets_to_asset_set {
  my ($api_client, $customer_id, $asset_resource_name, $asset_set_resource_name)
    = @_;

  # [START add_asset_set_asset]
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

  # Send the mutate request.
  # Note this is the point that the API will enforce uniqueness of the
  # DynamicEducationAsset.programId field. You can have any number of assets
  # with the same programId, however, only one Asset is allowed per AssetSet
  # with the same program ID.
  my $response = $api_client->AssetSetAssetService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});

  # Print some information about the response.
  my $resource_name = $response->{results}[0]{resourceName};
  printf "Created AssetSetAsset link with resource name '%s'.\n",
    $resource_name;
  # [END add_asset_set_asset]
}

# Links an AssetSet to Campaign by creating a CampaignAssetSet.
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

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions("customer_id=s" => \$customer_id, "campaign_id=i" => \$campaign_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $campaign_id);

# Call the example.
add_dynamic_remarketing_asset($api_client, $customer_id =~ s/-//gr,
  $campaign_id);

=pod

=head1 NAME

add_dynamic_remarketing_asset

=head1 DESCRIPTION

Adds an asset for use in dynamic remarketing.

=head1 SYNOPSIS

add_dynamic_remarketing_asset.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                Specify a campaign type which supports dynamic
                                remarketing, such as Display.

=cut
