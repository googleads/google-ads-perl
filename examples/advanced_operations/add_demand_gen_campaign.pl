#!/usr/bin/perl -w
#
# Copyright 2025, Google LLC
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
# This example shows how to create a Demand Gen campaign with a video ad.
#
# For more information about Demand Gen campaigns, see:
# https://developers.google.com/google-ads/api/docs/demand-gen/overview.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::MediaUtils;
use Google::Ads::GoogleAds::V23::Resources::Ad;
use Google::Ads::GoogleAds::V23::Resources::AdGroup;
use Google::Ads::GoogleAds::V23::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V23::Resources::Asset;
use Google::Ads::GoogleAds::V23::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V23::Resources::Campaign;
use Google::Ads::GoogleAds::V23::Resources::DemandGenAdGroupSettings;
use Google::Ads::GoogleAds::V23::Resources::DemandGenChannelControls;
use Google::Ads::GoogleAds::V23::Resources::DemandGenSelectedChannels;
use Google::Ads::GoogleAds::V23::Resources::NetworkSettings;
use Google::Ads::GoogleAds::V23::Common::AdImageAsset;
use Google::Ads::GoogleAds::V23::Common::AdTextAsset;
use Google::Ads::GoogleAds::V23::Common::AdVideoAsset;
use Google::Ads::GoogleAds::V23::Common::DemandGenVideoResponsiveAdInfo;
use Google::Ads::GoogleAds::V23::Common::ImageAsset;
use Google::Ads::GoogleAds::V23::Common::YoutubeVideoAsset;
use Google::Ads::GoogleAds::V23::Common::TargetCpa;
use Google::Ads::GoogleAds::V23::Enums::AdGroupStatusEnum qw(ENABLED);
use Google::Ads::GoogleAds::V23::Enums::AdvertisingChannelTypeEnum
  qw(DEMAND_GEN);
use Google::Ads::GoogleAds::V23::Enums::BudgetDeliveryMethodEnum   qw(STANDARD);
use Google::Ads::GoogleAds::V23::Enums::AdvertisingChannelTypeEnum qw(SEARCH);
use Google::Ads::GoogleAds::V23::Enums::CampaignStatusEnum         qw(PAUSED);
use Google::Ads::GoogleAds::V23::Enums::EuPoliticalAdvertisingStatusEnum
  qw(DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING);
use Google::Ads::GoogleAds::V23::Services::AdGroupService::AdGroupOperation;
use Google::Ads::GoogleAds::V23::Services::AdGroupAdService::AdGroupAdOperation;
use Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation;
use
  Google::Ads::GoogleAds::V23::Services::CampaignBudgetService::CampaignBudgetOperation;
use Google::Ads::GoogleAds::V23::Services::CampaignService::CampaignOperation;
use Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation;
use Google::Ads::GoogleAds::V23::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);

# Temporary IDs for resources.
use constant BUDGET_TEMPORARY_ID      => -1;
use constant CAMPAIGN_TEMPORARY_ID    => -2;
use constant AD_GROUP_TEMPORARY_ID    => -3;
use constant VIDEO_ASSET_TEMPORARY_ID => -4;
use constant LOGO_ASSET_TEMPORARY_ID  => -5;

# URLs for assets.
use constant DEFAULT_LOGO_IMAGE_URL => "https://gaagl.page.link/bjYi";
use constant DEFAULT_FINAL_URL      => "http://example.com/demand_gen";

sub add_demand_gen_campaign {
  my ($api_client, $customer_id, $video_id) = @_;

  my $budget_resource_name =
    Google::Ads::GoogleAds::V23::Utils::ResourceNames::campaign_budget(
    $customer_id, BUDGET_TEMPORARY_ID);
  my $campaign_resource_name =
    Google::Ads::GoogleAds::V23::Utils::ResourceNames::campaign($customer_id,
    CAMPAIGN_TEMPORARY_ID);
  my $ad_group_resource_name =
    Google::Ads::GoogleAds::V23::Utils::ResourceNames::ad_group($customer_id,
    AD_GROUP_TEMPORARY_ID);
  my $video_asset_resource_name =
    Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset($customer_id,
    VIDEO_ASSET_TEMPORARY_ID);
  my $logo_resource_name =
    Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset($customer_id,
    LOGO_ASSET_TEMPORARY_ID);

  # [START add_demand_gen_campaign_1]
  # The below methods create and return MutateOperations that we later provide to
  # the GoogleAdsService.Mutate method in order to create the entities in a single
  # request. Since the entities for a Demand Gen campaign are closely tied to one-another
  # it's considered a best practice to create them in a single Mutate request; the
  # entities will either all complete successfully or fail entirely, leaving no
  # orphaned entities. See:
  #  https://developers.google.com/google-ads/api/docs/mutating/overview
  my $campaign_budget_operation =
    create_campaign_budget_operation($budget_resource_name);
  my $campaign_operation =
    create_demand_gen_campaign_operation($campaign_resource_name,
    $budget_resource_name);
  my $ad_group_operation =
    create_ad_group_operation($ad_group_resource_name, $campaign_resource_name);
  my $asset_operations =
    create_asset_operations($video_asset_resource_name, $video_id,
    $logo_resource_name);
  my $demand_gen_ad_operation =
    create_demand_gen_ad_operation($ad_group_resource_name,
    $video_asset_resource_name, $logo_resource_name);

  # Send the operations in a single mutate request.
  my $response = $api_client->GoogleAdsService()->mutate({
      customerId       => $customer_id,
      mutateOperations => [(
          $campaign_budget_operation, $campaign_operation,
          $ad_group_operation,        @$asset_operations,
          $demand_gen_ad_operation
        )]});
  # [END add_demand_gen_campaign_1]

  foreach my $response (@{$response->{mutateOperationResponses}}) {
    my $result_type = [keys %$response]->[0];

    printf "Created a(n) %s with '%s'.\n",
      ucfirst $result_type =~ s/Result$//r,
      $response->{$result_type}{resourceName};
  }

  return 1;
}

# Create a mutate operation that creates a new campaign budget.
# A temporary ID will be assigned to this campaign budget so that it can be
# referenced by other objects being created in the same mutate request.
sub create_campaign_budget_operation {
  my ($budget_resource_name) = @_;

  my $campaign_budget_operation =
    Google::Ads::GoogleAds::V23::Services::CampaignBudgetService::CampaignBudgetOperation
    ->new({
      create => Google::Ads::GoogleAds::V23::Resources::CampaignBudget->new({
          name           => "Demand Gen campaign budget #" . uniqid(),
          deliveryMethod => STANDARD,
          # The budget period already defaults to DAILY.
          amountMicros => 500000,
          # A Demand Gen campaign cannot use a shared campaign budget.
          explicitlyShared => "false",
          # Set a temporary ID in the budget's resource name so it can be referenced
          # by the campaign in later steps.
          resourceName => $budget_resource_name
        })});

  # Create a campaign budget operation.
  return
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({campaignBudgetOperation => $campaign_budget_operation});

}

# Create a mutate operation that creates a new campaign.
# A temporary ID will be assigned to this campaign so that it can be
# referenced by other objects being created in the same mutate request.
# [START add_demand_gen_campaign_2]
sub create_demand_gen_campaign_operation {
  my ($campaign_resource_name, $budget_resource_name) = @_;

  my $campaign_operation =
    Google::Ads::GoogleAds::V23::Services::CampaignService::CampaignOperation->
    new({
      create => Google::Ads::GoogleAds::V23::Resources::Campaign->new({
          name => "Demand Gen #" . uniqid(),
          # Advertising channel type must be DEMAND_GEN.
          advertisingChannelType => DEMAND_GEN,
          # Set the campaign to PAUSED.
          status => PAUSED,
          # Use the Target CPA bidding strategy.
          targetCpa => Google::Ads::GoogleAds::V23::Common::TargetCpa->new({
              targetCpaMicros => 1000000,
            }
          ),
          # Assign the resource name with a temporary ID.
          resourceName => $campaign_resource_name,
          # Set the budget using the given budget resource name.
          campaignBudget => $budget_resource_name,
          # Declare whether or not this campaign serves political ads targeting the EU
          # Valid values are CONTAINS_EU_POLITICAL_ADVERTISING and
          # DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING
          containsEuPoliticalAdvertising =>
            DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING,
        })});

  # Create a campaign operation.
  return
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({campaignOperation => $campaign_operation});
}
# [END add_demand_gen_campaign_2]

# Create a mutate operation that creates a new ad group.
# [START add_demand_gen_campaign_3]
sub create_ad_group_operation {
  my ($ad_group_resource_name, $campaign_resource_name) = @_;

  my $ad_group_operation =
    Google::Ads::GoogleAds::V23::Services::AdGroupService::AdGroupOperation->
    new({
      create => Google::Ads::GoogleAds::V23::Resources::AdGroup->new({
          name     => "Earth to Mars Cruises #" . uniqid(),
          status   => ENABLED,
          campaign => $campaign_resource_name,
          # [START add_demand_gen_campaign_5]
          # Select the specific channels for the ad group.
          # For more information on Demand Gen channel controls, see:
          # https://developers.google.com/google-ads/api/docs/demand-gen/channel-controls
          demandGenAdGroupSettings =>
            Google::Ads::GoogleAds::V23::Resources::DemandGenAdGroupSettings->
            new({
              channelControls =>
                Google::Ads::GoogleAds::V23::Resources::DemandGenChannelControls
                ->new({
                  selectedChannels =>
                    Google::Ads::GoogleAds::V23::Resources::DemandGenSelectedChannels
                    ->new({
                      gmail           => "false",
                      discover        => "false",
                      display         => "false",
                      youtubeInFeed   => "true",
                      youtubeInStream => "true",
                      youtubeShorts   => "true",
                    }
                    ),
                }
                ),
            }
            ),
          # [END add_demand_gen_campaign_5]
          resourceName => $ad_group_resource_name,
        })});

  return
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({
      adGroupOperation => $ad_group_operation
    });
}
# [END add_demand_gen_campaign_3]

# Create a list of mutate operations that create new assets.
sub create_asset_operations {
  my ($video_asset_resource_name, $video_id, $logo_resource_name) = @_;

  my $operations = [
    create_video_asset_operation(
      $video_asset_resource_name, $video_id, "Video"
    ),
    create_image_asset_operation(
      $logo_resource_name, "https://gaagl.page.link/bjYi",
      "Square Marketing Image"
    )];

  return $operations;
}

# Create a mutate operation that creates a new Demand Gen ad.
# [START add_demand_gen_campaign_4]
sub create_demand_gen_ad_operation {
  my ($ad_group_resource_name, $video_asset_resource_name, $logo_resource_name)
    = @_;

  my $ad_group_ad_operation =
    Google::Ads::GoogleAds::V23::Services::AdGroupAdService::AdGroupAdOperation
    ->new({
      create => Google::Ads::GoogleAds::V23::Resources::AdGroupAd->new({
          # Set the ad group.
          adGroup => $ad_group_resource_name,
          ad      => Google::Ads::GoogleAds::V23::Resources::Ad->new({
              name                       => "Demand gen multi asset ad",
              finalUrls                  => ["http://example.com/demand_gen"],
              demandGenVideoResponsiveAd =>
                Google::Ads::GoogleAds::V23::Common::DemandGenVideoResponsiveAdInfo
                ->new({
                  businessName =>
                    Google::Ads::GoogleAds::V23::Common::AdTextAsset->new({
                      text => "Interplanetary Cruises"
                    }
                    ),
                  videos => [
                    Google::Ads::GoogleAds::V23::Common::AdVideoAsset->new({
                        asset => $video_asset_resource_name
                      })
                  ],
                  logoImages => [
                    Google::Ads::GoogleAds::V23::Common::AdImageAsset->new({
                        asset => $logo_resource_name
                      })
                  ],
                  headlines => [
                    Google::Ads::GoogleAds::V23::Common::AdTextAsset->new({
                        text => "Interplanetary Cruises"
                      })
                  ],
                  longHeadlines => [
                    Google::Ads::GoogleAds::V23::Common::AdTextAsset->new({
                        text => "Travel the World"
                      })
                  ],
                  descriptions => [
                    Google::Ads::GoogleAds::V23::Common::AdTextAsset->new({
                        text => "Book now for an extra discount"
                      })]})})})});

  return
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({
      adGroupAdOperation => $ad_group_ad_operation
    });
}
# [END add_demand_gen_campaign_4]

# Create a mutate operation that creates a new image asset.
sub create_image_asset_operation {
  my ($asset_resource_name, $url, $asset_name) = @_;

  my $image_content = get_base64_data_from_url($url);

  my $asset_operation =
    Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation->new({
      create => Google::Ads::GoogleAds::V23::Resources::Asset->new({
          resourceName => $asset_resource_name,
          imageAsset   => Google::Ads::GoogleAds::V23::Common::ImageAsset->new({
              data => $image_content
            }
          ),
          # Provide a unique friendly name to identify your asset.
          # When there is an existing image asset with the same content
          # but a different name, the new name will be dropped silently.
          name => $asset_name
        }
      ),
    });

  return
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({
      assetOperation => $asset_operation
    });
}

# Create a mutate operation that creates a new video asset.
sub create_video_asset_operation {
  my ($asset_resource_name, $video_id, $asset_name) = @_;

  my $asset_operation =
    Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation->new({
      create => Google::Ads::GoogleAds::V23::Resources::Asset->new({
          resourceName      => $asset_resource_name,
          name              => $asset_name,
          youtubeVideoAsset =>
            Google::Ads::GoogleAds::V23::Common::YoutubeVideoAsset->new({
              youtubeVideoId => $video_id
            })})});

  return
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({
      assetOperation => $asset_operation
    });
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Initialize arguments to pass to the add_demand_gen_campaign method.
my $customer_id;
my $video_id;

# Parameters passed on the command line will override any parameters set in code.
GetOptions("customer_id=s" => \$customer_id, "video_id=s" => \$video_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
add_demand_gen_campaign($api_client, $customer_id =~ s/-//gr, $video_id);

=pod

=head1 NAME

add_demand_gen_campaign

=head1 DESCRIPTION

This example shows how to create a Demand Gen campaign with a video ad.

=head1 SYNOPSIS

add_demand_gen_campaign.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
	-video_id					The YouTube ID of a video to use in an ad.

=cut
