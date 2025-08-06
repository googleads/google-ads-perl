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
# This example adds an App campaign.
#
# For guidance regarding App campaigns, see:
# https://developers.google.com/google-ads/api/docs/app-campaigns/overview
#
# To get campaigns, run basic_operations/get_campaigns.pl.
# To upload image assets for this campaign, run misc/upload_image_asset.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V21::Resources::Campaign;
use Google::Ads::GoogleAds::V21::Resources::AppCampaignSetting;
use Google::Ads::GoogleAds::V21::Resources::SelectiveOptimization;
use Google::Ads::GoogleAds::V21::Resources::CampaignCriterion;
use Google::Ads::GoogleAds::V21::Resources::AdGroup;
use Google::Ads::GoogleAds::V21::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V21::Resources::Ad;
use Google::Ads::GoogleAds::V21::Common::TargetCpa;
use Google::Ads::GoogleAds::V21::Common::LocationInfo;
use Google::Ads::GoogleAds::V21::Common::LanguageInfo;
use Google::Ads::GoogleAds::V21::Common::AppAdInfo;
use Google::Ads::GoogleAds::V21::Common::AdImageAsset;
use Google::Ads::GoogleAds::V21::Common::AdTextAsset;
use Google::Ads::GoogleAds::V21::Enums::BudgetDeliveryMethodEnum qw(STANDARD);
use Google::Ads::GoogleAds::V21::Enums::CampaignStatusEnum       qw(PAUSED);
use Google::Ads::GoogleAds::V21::Enums::AdvertisingChannelTypeEnum
  qw(MULTI_CHANNEL);
use Google::Ads::GoogleAds::V21::Enums::AdvertisingChannelSubTypeEnum
  qw(APP_CAMPAIGN);
use Google::Ads::GoogleAds::V21::Enums::AppCampaignAppStoreEnum
  qw(GOOGLE_APP_STORE);
use Google::Ads::GoogleAds::V21::Enums::AppCampaignBiddingStrategyGoalTypeEnum
  qw(OPTIMIZE_INSTALLS_TARGET_INSTALL_COST);
use Google::Ads::GoogleAds::V21::Enums::AdGroupStatusEnum;
use Google::Ads::GoogleAds::V21::Enums::AdGroupAdStatusEnum;
use Google::Ads::GoogleAds::V21::Enums::EuPoliticalAdvertisingStatusEnum
  qw(DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING);
use
  Google::Ads::GoogleAds::V21::Services::CampaignBudgetService::CampaignBudgetOperation;
use Google::Ads::GoogleAds::V21::Services::CampaignService::CampaignOperation;
use
  Google::Ads::GoogleAds::V21::Services::CampaignCriterionService::CampaignCriterionOperation;
use Google::Ads::GoogleAds::V21::Services::AdGroupService::AdGroupOperation;
use Google::Ads::GoogleAds::V21::Services::AdGroupAdService::AdGroupAdOperation;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);
use POSIX        qw(strftime);

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub add_app_campaign {
  my ($api_client, $customer_id) = @_;

  # Create the budget for the campaign.
  my $budget_resource_name = create_campaign_budget($api_client, $customer_id);

  # Create the campaign.
  my $campaign_resource_name =
    create_campaign($api_client, $customer_id, $budget_resource_name);

  # Set campaign targeting.
  set_campaign_targeting_criteria($api_client, $customer_id,
    $campaign_resource_name);

  # Create an ad group.
  my $ad_group_resource_name =
    create_ad_group($api_client, $customer_id, $campaign_resource_name);

  # Create an App ad.
  create_app_ad($api_client, $customer_id, $ad_group_resource_name);

  return 1;
}

# Creates a campaign budget.
sub create_campaign_budget {
  my ($api_client, $customer_id) = @_;

  # Create a campaign budget.
  my $campaign_budget =
    Google::Ads::GoogleAds::V21::Resources::CampaignBudget->new({
      name           => "Interplanetary Cruise Budget #" . uniqid(),
      amountMicros   => 50000000,
      deliveryMethod => STANDARD,
      # An App campaign cannot use a shared campaign budget.
      explicitlyShared => "false"
    });

  # Create a campaign budget operation.
  my $campaign_budget_operation =
    Google::Ads::GoogleAds::V21::Services::CampaignBudgetService::CampaignBudgetOperation
    ->new({
      create => $campaign_budget
    });

  # Issue a mutate request to add the campaign budget.
  my $campaign_budgets_response = $api_client->CampaignBudgetService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_budget_operation]});

  my $campaign_budget_resource_name =
    $campaign_budgets_response->{results}[0]{resourceName};
  printf "Created campaign budget with resource name: '%s'.\n",
    $campaign_budget_resource_name;

  return $campaign_budget_resource_name;
}

# Creates an App campaign.
sub create_campaign {
  my ($api_client, $customer_id, $budget_resource_name) = @_;

  # Create a campaign.
  my $campaign = Google::Ads::GoogleAds::V21::Resources::Campaign->new({
      name           => "Interplanetary Cruise App #" . uniqid(),
      campaignBudget => $budget_resource_name,
      # Recommendation: Set the campaign to PAUSED when creating it to prevent
      # the ads from immediately serving. Set to ENABLED once you've added
      # targeting and the ads are ready to serve.
      status => PAUSED,
      # All App campaigns have an advertisingChannelType of MULTI_CHANNEL to
      # reflect the fact that ads from these campaigns are eligible to appear
      # on multiple channels.
      advertisingChannelType    => MULTI_CHANNEL,
      advertisingChannelSubType => APP_CAMPAIGN,
      # Set the target CPA to $1 / app install.
      targetCpa => Google::Ads::GoogleAds::V21::Common::TargetCpa->new({
          targetCpaMicros => 1000000
        }
      ),
      # Configure the App campaign setting.
      appCampaignSetting =>
        Google::Ads::GoogleAds::V21::Resources::AppCampaignSetting->new({
          appId                   => "com.google.android.apps.adwords",
          appStore                => GOOGLE_APP_STORE,
          biddingStrategyGoalType => OPTIMIZE_INSTALLS_TARGET_INSTALL_COST
        }
        ),
      # Declare whether or not this campaign serves political ads targeting the EU.
      # Valid values are CONTAINS_EU_POLITICAL_ADVERTISING and
      # DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING.
      containsEuPoliticalAdvertising =>
        DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING,
      # Optional: If you select the OPTIMIZE_IN_APP_CONVERSIONS_TARGET_INSTALL_COST
      # goal type, then also specify your in-app conversion actions so the Google
      # Ads API can focus your campaign on people who are most likely to complete
      # the corresponding in-app actions.
      # selectiveOptimization =>
      #   Google::Ads::GoogleAds::V21::Resources::SelectiveOptimization->new({
      #     conversionActions =>
      #       ["INSERT_CONVERSION_ACTION_RESOURCE_NAME(s)_HERE"]}
      #   ),
      #
      # Optional: Set the start and end dates for the campaign, beginning one day
      # from now and ending a year from now.
      startDate => strftime("%Y%m%d", localtime(time + 60 * 60 * 24)),
      endDate   => strftime("%Y%m%d", localtime(time + 60 * 60 * 24 * 365)),
    });

  # Create a campaign operation.
  my $campaign_operation =
    Google::Ads::GoogleAds::V21::Services::CampaignService::CampaignOperation->
    new({
      create => $campaign
    });

  # Issue a mutate request to add the campaign.
  my $campaigns_response = $api_client->CampaignService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_operation]});

  my $campaign_resource_name =
    $campaigns_response->{results}[0]{resourceName};
  printf "Created App campaign with resource name: '%s'.\n",
    $campaign_resource_name;

  return $campaign_resource_name;
}

# Sets campaign targeting criteria for a given campaign.
sub set_campaign_targeting_criteria {
  my ($api_client, $customer_id, $campaign_resource_name) = @_;

  my $campaign_criterion_operations = [];

  # Create the location campaign criteria.
  # Location ID 21137 is for California, and 2484 is for Mexico.
  # Besides using location ID, you can also search by location names from
  # GeoTargetConstantService.suggest() method and directly apply
  # GeoTargetConstant.resourceName here. An example can be found in
  # targeting/get_geo_target_constants_by_names.pl.
  foreach my $location_id (21137, 2484) {
    my $campaign_criterion =
      Google::Ads::GoogleAds::V21::Resources::CampaignCriterion->new({
        campaign => $campaign_resource_name,
        location => Google::Ads::GoogleAds::V21::Common::LocationInfo->new({
            geoTargetConstant =>
              Google::Ads::GoogleAds::V21::Utils::ResourceNames::geo_target_constant(
              $location_id)})});

    push @$campaign_criterion_operations,
      Google::Ads::GoogleAds::V21::Services::CampaignCriterionService::CampaignCriterionOperation
      ->new({
        create => $campaign_criterion
      });
  }

  # Create the language campaign criteria.
  # Language ID 1000 is for English, and 1003 is for Spanish.
  foreach my $language_id (1000, 1003) {
    my $campaign_criterion =
      Google::Ads::GoogleAds::V21::Resources::CampaignCriterion->new({
        campaign => $campaign_resource_name,
        language => Google::Ads::GoogleAds::V21::Common::LanguageInfo->new({
            languageConstant =>
              Google::Ads::GoogleAds::V21::Utils::ResourceNames::language_constant(
              $language_id)})});

    push @$campaign_criterion_operations,
      Google::Ads::GoogleAds::V21::Services::CampaignCriterionService::CampaignCriterionOperation
      ->new({
        create => $campaign_criterion
      });
  }

  # Issue a mutate request to add the campaign criterion.
  my $campaign_criteria_response =
    $api_client->CampaignCriterionService()->mutate({
      customerId => $customer_id,
      operations => $campaign_criterion_operations
    });

  my $campaign_criterion_results = $campaign_criteria_response->{results};
  printf "Created %d campaign criteria:\n", scalar @$campaign_criterion_results;

  foreach my $campaign_criterion_result (@$campaign_criterion_results) {
    printf "\t%s\n", $campaign_criterion_result->{resourceName};
  }
}

# Creates an ad group for a given campaign.
sub create_ad_group {
  my ($api_client, $customer_id, $campaign_resource_name) = @_;

  # Create an ad group.
  # Note that the ad group type must not be set.
  # Since the advertisingChannelSubType is APP_CAMPAIGN,
  #   1- you cannot override bid settings at the ad group level.
  #   2- you cannot add ad group criteria.
  my $ad_group = Google::Ads::GoogleAds::V21::Resources::AdGroup->new({
    name   => "Earth to Mars Cruises #" . uniqid(),
    status => Google::Ads::GoogleAds::V21::Enums::AdGroupStatusEnum::ENABLED,
    campaign => $campaign_resource_name
  });

  # Create an ad group operation.
  my $ad_group_operation =
    Google::Ads::GoogleAds::V21::Services::AdGroupService::AdGroupOperation->
    new({create => $ad_group});

  # Issue a mutate request to add the ad group.
  my $ad_groups_response = $api_client->AdGroupService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_operation]});

  my $ad_group_resource_name =
    $ad_groups_response->{results}[0]{resourceName};
  printf "Created ad group with resource name: '%s'.\n",
    $ad_group_resource_name;

  return $ad_group_resource_name;
}

# Creates an App ad for a given ad group.
sub create_app_ad {
  my ($api_client, $customer_id, $ad_group_resource_name) = @_;

  # Create an ad group ad.
  my $ad_group_ad = Google::Ads::GoogleAds::V21::Resources::AdGroupAd->new({
      adGroup => $ad_group_resource_name,
      status  =>
        Google::Ads::GoogleAds::V21::Enums::AdGroupAdStatusEnum::ENABLED,
      ad => Google::Ads::GoogleAds::V21::Resources::Ad->new({
          appAd => Google::Ads::GoogleAds::V21::Common::AppAdInfo->new({
              headlines => [
                create_ad_text_asset("A cool puzzle game"),
                create_ad_text_asset("Remove connected blocks")
              ],
              descriptions => [
                create_ad_text_asset("3 difficulty levels"),
                create_ad_text_asset("4 colorful fun skins")
              ],
              # Optional: You can set up to 20 image assets for your campaign.
              # images => [
              #   Google::Ads::GoogleAds::V21::Common::AdImageAsset->new({
              #       asset => "INSERT_IMAGE_ASSET_RESOURCE_NAME_HERE"
              #     })]
            })})});

  # Create an ad group ad operation.
  my $ad_group_ad_operation =
    Google::Ads::GoogleAds::V21::Services::AdGroupAdService::AdGroupAdOperation
    ->new({create => $ad_group_ad});

  # Issue a mutate request to add the ad group ad.
  my $ad_group_ads_response = $api_client->AdGroupAdService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_ad_operation]});

  printf "Created ad group ad with resource name: '%s'.\n",
    $ad_group_ads_response->{results}[0]{resourceName};
}

# Creates an ad text asset.
sub create_ad_text_asset {
  my ($text) = @_;

  return Google::Ads::GoogleAds::V21::Common::AdTextAsset->new({
    text => $text
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

# Parameters passed on the command line will override any parameters set in code.
GetOptions("customer_id=s" => \$customer_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
add_app_campaign($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

add_app_campaign

=head1 DESCRIPTION

This example adds an App campaign.

For guidance regarding App campaigns, see:
https://developers.google.com/google-ads/api/docs/app-campaigns/overview

To get campaigns, run basic_operations/get_campaigns.pl.
To upload image assets for this campaign, run misc/upload_image_asset.pl.

=head1 SYNOPSIS

add_app_campaign.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
