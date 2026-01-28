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
# Adds sitelinks to a campaign using Assets. To create a campaign, run add_campaigns.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::Asset;
use Google::Ads::GoogleAds::V23::Resources::CampaignAsset;
use Google::Ads::GoogleAds::V23::Common::SitelinkAsset;
use Google::Ads::GoogleAds::V23::Enums::AssetFieldTypeEnum qw(SITELINK);
use Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation;
use
  Google::Ads::GoogleAds::V23::Services::CampaignAssetService::CampaignAssetOperation;
use Google::Ads::GoogleAds::V23::Utils::ResourceNames;

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
my $customer_id = "INSERT_CUSTOMER_ID_HERE";
my $campaign_id = "INSERT_CAMPAIGN_ID_HERE";

sub add_sitelinks_using_assets {
  my ($api_client, $customer_id, $campaign_id) = @_;

  # Create sitelink assets.
  my $sitelink_asset_resource_names =
    create_sitelink_assets($api_client, $customer_id);

  # Associate the sitelinks at the campaign level.
  link_sitelinks_to_campaign($api_client, $sitelink_asset_resource_names,
    $customer_id, $campaign_id);

  return 1;
}

# Creates sitelink assets which can then be added to campaigns.
sub create_sitelink_assets {
  my ($api_client, $customer_id) = @_;

  # Create some sitelink assets.
  my $store_locator_asset =
    Google::Ads::GoogleAds::V23::Common::SitelinkAsset->new({
      description1 => "Get in touch",
      description2 => "Find your local store",
      linkText     => "Store locator"
    });

  my $store_asset = Google::Ads::GoogleAds::V23::Common::SitelinkAsset->new({
    description1 => "Buy some stuff",
    description2 => "It's really good",
    linkText     => "Store"
  });

  my $store_additional_asset =
    Google::Ads::GoogleAds::V23::Common::SitelinkAsset->new({
      description1 => "Even more stuff",
      description2 => "There's never enough",
      linkText     => "Store for more"
    });

  # Wrap the sitelinks in an Asset and set the URLs.
  my $assets = [];
  push @$assets, Google::Ads::GoogleAds::V23::Resources::Asset->new({
      sitelinkAsset => $store_locator_asset,
      finalUrls     => ["http://example.com/contact/store-finder"],
      # Optionally set a different URL for mobile.
      finalMobileUrls => ["http://example.com/mobile/contact/store-finder"]});

  push @$assets, Google::Ads::GoogleAds::V23::Resources::Asset->new({
      sitelinkAsset => $store_asset,
      finalUrls     => ["http://example.com/store"],
      # Optionally set a different URL for mobile.
      finalMobileUrls => ["http://example.com/mobile/store"]});

  push @$assets, Google::Ads::GoogleAds::V23::Resources::Asset->new({
      sitelinkAsset => $store_additional_asset,
      finalUrls     => ["http://example.com/store/more"],
      # Optionally set a different URL for mobile.
      finalMobileUrls => ["http://example.com/mobile/store/more"]});

  # Create the operations to add each asset.
  my $operations = [];
  foreach my $asset (@$assets) {
    push @$operations,
      Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation->new((
        {
          create => $asset
        }));
  }

  # Send the mutate request.
  my $response = $api_client->AssetService()->mutate({
    customerId => $customer_id,
    operations => $operations
  });

  # Print some information about the result.
  my $resource_names = [];
  foreach my $result (@{$response->{results}}) {
    push @$resource_names, $result->{resourceName};
    printf "Created sitelink asset with resource name '%s'.\n",
      $result->{resourceName};
  }

  return $resource_names;
}

# Links the assets to a campaign.
sub link_sitelinks_to_campaign {
  my ($api_client, $sitelink_asset_resource_names, $customer_id, $campaign_id)
    = @_;

  # Create CampaignAssets representing the association between sitelinks and campaign.
  my $operations = [];
  foreach my $sitelink_asset_resource_name (@$sitelink_asset_resource_names) {
    push @$operations,
      # Create a CampaignAssetOperation to create the CampaignAsset.
      Google::Ads::GoogleAds::V23::Services::CampaignAssetService::CampaignAssetOperation
      ->new({
        # Create the CampaignAsset link.
        create => Google::Ads::GoogleAds::V23::Resources::CampaignAsset->new({
            asset    => $sitelink_asset_resource_name,
            campaign =>
              Google::Ads::GoogleAds::V23::Utils::ResourceNames::campaign(
              $customer_id, $campaign_id
              ),
            fieldType => SITELINK
          })});
  }

  # Send the mutate request.
  my $response = $api_client->CampaignAssetService()->mutate({
    customerId => $customer_id,
    operations => $operations
  });

  # Print some information about the result.
  foreach my $result (@{$response->{results}}) {
    printf "Linked sitelink to campaign with resource name '%s'.\n",
      $result->{resourceName};
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

# Parameters passed on the command line will override any parameters set in code.
GetOptions("customer_id=s" => \$customer_id, "campaign_id=i" => \$campaign_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $campaign_id);

# Call the example.
add_sitelinks_using_assets($api_client, $customer_id =~ s/-//gr, $campaign_id);

=pod

=head1 NAME

add_sitelinks_using_assets.pl

=head1 DESCRIPTION

Adds sitelinks to a campaign using Assets. To create a campaign, run add_campaigns.pl.

=head1 SYNOPSIS

add_sitelinks.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.

=cut
