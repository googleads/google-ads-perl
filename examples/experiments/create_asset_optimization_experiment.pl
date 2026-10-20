#!/usr/bin/perl -w
#
# Copyright 2026, Google LLC
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
# This example creates an OPTIMIZE_ASSETS experiment.
#
# Asset optimization experiments are used to test different asset combinations
# within Performance Max campaigns.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::MediaUtils;
use Google::Ads::GoogleAds::V26::Common::ImageAsset;
use Google::Ads::GoogleAds::V26::Common::OptimizeAssetsExperimentInfo;
use Google::Ads::GoogleAds::V26::Common::TextAsset;
use Google::Ads::GoogleAds::V26::Enums::AssetFieldTypeEnum
  qw(HEADLINE MARKETING_IMAGE);
use Google::Ads::GoogleAds::V26::Enums::AssetTypeEnum qw(IMAGE);
use Google::Ads::GoogleAds::V26::Enums::ExperimentTypeEnum
  qw(OPTIMIZE_ASSETS);
use Google::Ads::GoogleAds::V26::Enums::OptimizeAssetsExperimentSubtypeEnum
  qw(COMPARE_ASSETS);
use Google::Ads::GoogleAds::V26::Resources::Asset;
use Google::Ads::GoogleAds::V26::Resources::AssetGroupAsset;
use Google::Ads::GoogleAds::V26::Resources::AssetGroupAssetInfo;
use Google::Ads::GoogleAds::V26::Resources::AssetGroupInfo;
use Google::Ads::GoogleAds::V26::Resources::Experiment;
use Google::Ads::GoogleAds::V26::Resources::ExperimentArm;
use
  Google::Ads::GoogleAds::V26::Services::AssetGroupAssetService::AssetGroupAssetOperation;
use Google::Ads::GoogleAds::V26::Services::AssetService::AssetOperation;
use
  Google::Ads::GoogleAds::V26::Services::ExperimentArmService::ExperimentArmOperation;
use
  Google::Ads::GoogleAds::V26::Services::ExperimentService::ExperimentOperation;
use Google::Ads::GoogleAds::V26::Services::GoogleAdsService::MutateOperation;
use Google::Ads::GoogleAds::V26::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);

# Temporary IDs for resources created in the same mutate request.
use constant ASSET_1_TEMP_ID    => -1;
use constant EXPERIMENT_TEMP_ID => -2;
use constant ASSET_2_TEMP_ID    => -3;

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id    = "INSERT_CUSTOMER_ID_HERE";
my $asset_group_id = "INSERT_ASSET_GROUP_ID_HERE";

sub create_asset_optimization_experiment {
  my ($api_client, $customer_id, $asset_group_id) = @_;

  # Query the asset group to find the associated campaign resource name.
  my $query = sprintf
    "SELECT asset_group.campaign FROM asset_group WHERE asset_group.id = %d",
    $asset_group_id;
  my $search_response = $api_client->GoogleAdsService()->search({
    customerId => $customer_id,
    query      => $query
  });

  my $google_ads_row = $search_response->{results}[0];
  if (not defined $google_ads_row) {
    die sprintf "Asset group with ID %d not found.\n", $asset_group_id;
  }
  my $campaign_resource_name = $google_ads_row->{assetGroup}{campaign};

  # [START create_asset_optimization_experiment_1]
  # 1. Create Assets with temporary resource names.
  # We create a text asset and an image asset to showcase different types.
  my $asset_operation_1 =
    create_text_asset_operation($customer_id, ASSET_1_TEMP_ID, "Fly to Mars!");
  my $asset_operation_2 = create_image_asset_operation(
    $customer_id,                   ASSET_2_TEMP_ID,
    "https://gaagl.page.link/Eit5", "Mars Landscape View"
  );

  # 2. Create an Experiment with a temporary resource name.
  my $experiment_operation =
    Google::Ads::GoogleAds::V26::Services::GoogleAdsService::MutateOperation->
    new({
      experimentOperation =>
        Google::Ads::GoogleAds::V26::Services::ExperimentService::ExperimentOperation
        ->new({
          create => Google::Ads::GoogleAds::V26::Resources::Experiment->new({
              resourceName =>
                Google::Ads::GoogleAds::V26::Utils::ResourceNames::experiment(
                $customer_id, EXPERIMENT_TEMP_ID
                ),
              name => "Interstellar Asset Experiment #" . uniqid(),
              type => OPTIMIZE_ASSETS,
              # Set the optimize assets experiment subtype to COMPARE_ASSETS.
              optimizeAssetsExperiment =>
                Google::Ads::GoogleAds::V26::Common::OptimizeAssetsExperimentInfo
                ->new({
                  optimizeAssetsExperimentSubtype => COMPARE_ASSETS
                })})})});

  # 3. Create two ExperimentArm resources.
  my $treatment_assets = [
    [ASSET_1_TEMP_ID, HEADLINE],
    [ASSET_2_TEMP_ID, MARKETING_IMAGE]
  ];
  my $arm_operations = create_arms_operations(
    $customer_id,            EXPERIMENT_TEMP_ID,
    $campaign_resource_name, $asset_group_id,
    $treatment_assets
  );

  # 4. Create AssetGroupAssets linking the assets to the asset group.
  my $asset_group_asset_operation_1 =
    create_asset_group_asset_operation($customer_id, $asset_group_id,
    ASSET_1_TEMP_ID, HEADLINE);
  my $asset_group_asset_operation_2 =
    create_asset_group_asset_operation($customer_id, $asset_group_id,
    ASSET_2_TEMP_ID, MARKETING_IMAGE);

  # Send all operations in a single Mutate request.
  # The operations must be in this specific order.
  my $mutate_operations = [
    $asset_operation_1,             $asset_operation_2,
    $experiment_operation,          @$arm_operations,
    $asset_group_asset_operation_1, $asset_group_asset_operation_2
  ];

  my $response = $api_client->GoogleAdsService()->mutate({
    customerId       => $customer_id,
    mutateOperations => $mutate_operations
  });
  # [END create_asset_optimization_experiment_1]

  # Print the results.
  my $operation_responses = $response->{mutateOperationResponses};
  printf "Created headline asset: '%s'.\n",
    $operation_responses->[0]{assetResult}{resourceName};
  printf "Created image asset: '%s'.\n",
    $operation_responses->[1]{assetResult}{resourceName};
  printf "Created experiment: '%s'.\n",
    $operation_responses->[2]{experimentResult}{resourceName};
  printf "Created control arm: '%s'.\n",
    $operation_responses->[3]{experimentArmResult}{resourceName};
  printf "Created treatment arm: '%s'.\n",
    $operation_responses->[4]{experimentArmResult}{resourceName};
  printf "Created asset group asset for headline: '%s'.\n",
    $operation_responses->[5]{assetGroupAssetResult}{resourceName};
  printf "Created asset group asset for image: '%s'.\n",
    $operation_responses->[6]{assetGroupAssetResult}{resourceName};

  return 1;
}

# Creates a mutate operation for a text asset.
sub create_text_asset_operation {
  my ($customer_id, $temp_id, $text) = @_;

  return
    Google::Ads::GoogleAds::V26::Services::GoogleAdsService::MutateOperation->
    new({
      assetOperation =>
        Google::Ads::GoogleAds::V26::Services::AssetService::AssetOperation->
        new({
          create => Google::Ads::GoogleAds::V26::Resources::Asset->new({
              resourceName =>
                Google::Ads::GoogleAds::V26::Utils::ResourceNames::asset(
                $customer_id, $temp_id
                ),
              textAsset => Google::Ads::GoogleAds::V26::Common::TextAsset->new({
                  text => $text
                })})})});
}

# Creates a mutate operation for an image asset.
sub create_image_asset_operation {
  my ($customer_id, $temp_id, $url, $name) = @_;

  return
    Google::Ads::GoogleAds::V26::Services::GoogleAdsService::MutateOperation->
    new({
      assetOperation =>
        Google::Ads::GoogleAds::V26::Services::AssetService::AssetOperation->
        new({
          create => Google::Ads::GoogleAds::V26::Resources::Asset->new({
              resourceName =>
                Google::Ads::GoogleAds::V26::Utils::ResourceNames::asset(
                $customer_id, $temp_id
                ),
              name       => $name,
              type       => IMAGE,
              imageAsset =>
                Google::Ads::GoogleAds::V26::Common::ImageAsset->new({
                  data => get_base64_data_from_url($url)})})})});
}

# Creates mutate operations for control and treatment arms.
sub create_arms_operations {
  my ($customer_id, $experiment_temp_id, $campaign_resource_name,
    $asset_group_id, $treatment_assets)
    = @_;

  my $operations = [];

  # Control arm.
  push @$operations,
    Google::Ads::GoogleAds::V26::Services::GoogleAdsService::MutateOperation->
    new({
      experimentArmOperation =>
        Google::Ads::GoogleAds::V26::Services::ExperimentArmService::ExperimentArmOperation
        ->new({
          create => Google::Ads::GoogleAds::V26::Resources::ExperimentArm->new({
              experiment =>
                Google::Ads::GoogleAds::V26::Utils::ResourceNames::experiment(
                $customer_id, $experiment_temp_id
                ),
              name         => "Base Assets (Control)",
              control      => "true",
              trafficSplit => 50,
              campaigns    => [$campaign_resource_name],
              assetGroups  => [
                Google::Ads::GoogleAds::V26::Resources::AssetGroupInfo->new({
                    assetGroup =>
                      Google::Ads::GoogleAds::V26::Utils::ResourceNames::asset_group(
                      $customer_id, $asset_group_id
                      )})]})})});

  # Treatment arm.
  my $asset_group_assets = [];
  foreach my $treatment_asset (@$treatment_assets) {
    my ($asset_temp_id, $field_type) = @$treatment_asset;
    push @$asset_group_assets,
      Google::Ads::GoogleAds::V26::Resources::AssetGroupAssetInfo->new({
        asset => Google::Ads::GoogleAds::V26::Utils::ResourceNames::asset(
          $customer_id, $asset_temp_id
        ),
        fieldType => $field_type
      });
  }

  push @$operations,
    Google::Ads::GoogleAds::V26::Services::GoogleAdsService::MutateOperation->
    new({
      experimentArmOperation =>
        Google::Ads::GoogleAds::V26::Services::ExperimentArmService::ExperimentArmOperation
        ->new({
          create => Google::Ads::GoogleAds::V26::Resources::ExperimentArm->new({
              experiment =>
                Google::Ads::GoogleAds::V26::Utils::ResourceNames::experiment(
                $customer_id, $experiment_temp_id
                ),
              name         => "New Assets (Treatment)",
              control      => "false",
              trafficSplit => 50,
              campaigns    => [$campaign_resource_name],
              assetGroups  => [
                Google::Ads::GoogleAds::V26::Resources::AssetGroupInfo->new({
                    assetGroup =>
                      Google::Ads::GoogleAds::V26::Utils::ResourceNames::asset_group(
                      $customer_id, $asset_group_id
                      ),
                    assetGroupAssets => $asset_group_assets
                  })]})})});

  return $operations;
}

# Creates a mutate operation for an asset group asset.
sub create_asset_group_asset_operation {
  my ($customer_id, $asset_group_id, $asset_temp_id, $field_type) = @_;

  return
    Google::Ads::GoogleAds::V26::Services::GoogleAdsService::MutateOperation->
    new({
      assetGroupAssetOperation =>
        Google::Ads::GoogleAds::V26::Services::AssetGroupAssetService::AssetGroupAssetOperation
        ->new({
          create =>
            Google::Ads::GoogleAds::V26::Resources::AssetGroupAsset->new({
              assetGroup =>
                Google::Ads::GoogleAds::V26::Utils::ResourceNames::asset_group(
                $customer_id, $asset_group_id
                ),
              asset => Google::Ads::GoogleAds::V26::Utils::ResourceNames::asset(
                $customer_id, $asset_temp_id
              ),
              fieldType => $field_type
            })})});
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
  "asset_group_id=i" => \$asset_group_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $asset_group_id);

# Call the example.
create_asset_optimization_experiment($api_client, $customer_id =~ s/-//gr,
  $asset_group_id);

=pod

=head1 NAME

create_asset_optimization_experiment

=head1 DESCRIPTION

This example creates an OPTIMIZE_ASSETS experiment.

Asset optimization experiments are used to test different asset combinations
within Performance Max campaigns.

=head1 SYNOPSIS

create_asset_optimization_experiment.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -asset_group_id             The base asset group ID to run the experiment on.

=cut
