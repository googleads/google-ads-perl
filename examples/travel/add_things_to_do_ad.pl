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
# This example creates a Things to do campaign, an ad group and a Things to
# do ad.
#
# Prerequisite: You need to have access to the Things to do Center.
# The integration instructions can be found at:
# https://support.google.com/google-ads/answer/13387362

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V23::Resources::Campaign;
use Google::Ads::GoogleAds::V23::Resources::NetworkSettings;
use Google::Ads::GoogleAds::V23::Resources::AdGroup;
use Google::Ads::GoogleAds::V23::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V23::Resources::Ad;
use Google::Ads::GoogleAds::V23::Resources::TravelCampaignSettings;
use Google::Ads::GoogleAds::V23::Common::MaximizeConversionValue;
use Google::Ads::GoogleAds::V23::Common::TravelAdInfo;
use Google::Ads::GoogleAds::V23::Enums::BudgetDeliveryMethodEnum qw(STANDARD);
use Google::Ads::GoogleAds::V23::Enums::CampaignStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::AdGroupTypeEnum qw(TRAVEL_ADS);
use Google::Ads::GoogleAds::V23::Enums::AdGroupStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::AdGroupAdStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::AdvertisingChannelTypeEnum qw(TRAVEL);
use Google::Ads::GoogleAds::V23::Enums::AdvertisingChannelSubTypeEnum
  qw(TRAVEL_ACTIVITIES);
use Google::Ads::GoogleAds::V23::Enums::EuPoliticalAdvertisingStatusEnum
  qw(DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING);
use
  Google::Ads::GoogleAds::V23::Services::CampaignBudgetService::CampaignBudgetOperation;
use Google::Ads::GoogleAds::V23::Services::CampaignService::CampaignOperation;
use Google::Ads::GoogleAds::V23::Services::AdGroupService::AdGroupOperation;
use Google::Ads::GoogleAds::V23::Services::AdGroupAdService::AdGroupAdOperation;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);

sub add_things_to_do_ad {
  my ($api_client, $customer_id, $things_to_do_center_account_id) = @_;

  # Create a budget to be used by the campaign that will be created below.
  my $budget_resource_name = add_campaign_budget($api_client, $customer_id);

  # Create a Things to do campaign.
  my $campaign_resource_name =
    add_things_to_do_campaign($api_client, $customer_id,
    $budget_resource_name, $things_to_do_center_account_id);

  # Create an ad group.
  my $ad_group_resource_name =
    add_ad_group($api_client, $customer_id, $campaign_resource_name);

  # Create an ad group ad.
  add_ad_group_ad($api_client, $customer_id, $ad_group_resource_name);

  return 1;
}

# Creates a new campaign budget in the specified client account.
sub add_campaign_budget {
  my ($api_client, $customer_id) = @_;

  # Create a campaign budget.
  my $campaign_budget =
    Google::Ads::GoogleAds::V23::Resources::CampaignBudget->new({
      name           => "Interplanetary Cruise Budget #" . uniqid(),
      deliveryMethod => STANDARD,
      # Set the amount of budget.
      amountMicros => 5000000,
      # Make the budget explicitly shared.
      explicitlyShared => "true"
    });

  # Create a campaign budget operation.
  my $campaign_budget_operation =
    Google::Ads::GoogleAds::V23::Services::CampaignBudgetService::CampaignBudgetOperation
    ->new({create => $campaign_budget});

  # Add the campaign budget.
  my $campaign_budget_resource_name =
    $api_client->CampaignBudgetService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_budget_operation]})->{results}[0]{resourceName};

  printf "Added a budget with resource name: '%s'.\n",
    $campaign_budget_resource_name;

  return $campaign_budget_resource_name;
}

# Creates a new Things to do campaign in the specified client account.
# [START add_things_to_do_ad]
sub add_things_to_do_campaign {
  my ($api_client, $customer_id, $budget_resource_name,
    $things_to_do_center_account_id)
    = @_;

  # [START add_things_to_do_ad_1]
  # Create a campaign.
  my $campaign = Google::Ads::GoogleAds::V23::Resources::Campaign->new({
      name => "Interplanetary Cruise Campaign #" . uniqid(),
      # Configure settings related to Things to do campaigns including
      # advertising channel type, advertising channel sub type and travel
      # campaign settings.
      advertisingChannelType    => TRAVEL,
      advertisingChannelSubType => TRAVEL_ACTIVITIES,
      travelCampaignSettings    =>
        Google::Ads::GoogleAds::V23::Resources::TravelCampaignSettings->new({
          travelAccountId => $things_to_do_center_account_id
        }
        ),
      # Recommendation: Set the campaign to PAUSED when creating it to prevent
      # the ads from immediately serving. Set to ENABLED once you've added
      # targeting and the ads are ready to serve.
      status => Google::Ads::GoogleAds::V23::Enums::CampaignStatusEnum::PAUSED,
      # Set the bidding strategy to MaximizeConversionValue. Only this type can be
      # used for Things to do campaigns.
      maximizeConversionValue =>
        Google::Ads::GoogleAds::V23::Common::MaximizeConversionValue->new(),
      # Set the budget.
      campaignBudget => $budget_resource_name,
      # Declare whether or not this campaign serves political ads targeting the EU.
      # Valid values are CONTAINS_EU_POLITICAL_ADVERTISING and
      # DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING.
      containsEuPoliticalAdvertising =>
        DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING,
      # Configure the campaign network options. Only Google Search is allowed for
      # Things to do campaigns.
      networkSettings =>
        Google::Ads::GoogleAds::V23::Resources::NetworkSettings->new({
          targetGoogleSearch => "true"
        })});
  # [END add_things_to_do_ad_1]

  # Create a campaign operation.
  my $campaign_operation =
    Google::Ads::GoogleAds::V23::Services::CampaignService::CampaignOperation->
    new({create => $campaign});

  # Add the campaign.
  my $campaign_resource_name = $api_client->CampaignService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_operation]})->{results}[0]{resourceName};

  printf "Added a Things to do campaign with resource name: '%s'.\n",
    $campaign_resource_name;

  return $campaign_resource_name;
}
# [END add_things_to_do_ad]

# Creates a new ad group in the specified Things to do campaign.
# [START add_things_to_do_ad_2]
sub add_ad_group {
  my ($api_client, $customer_id, $campaign_resource_name) = @_;

  # Create an ad group.
  my $ad_group = Google::Ads::GoogleAds::V23::Resources::AdGroup->new({
    name => "Earth to Mars Cruise #" . uniqid(),
    # Set the campaign.
    campaign => $campaign_resource_name,
    # Set the ad group type to TRAVEL_ADS.
    # This cannot be set to other types.
    type   => TRAVEL_ADS,
    status => Google::Ads::GoogleAds::V23::Enums::AdGroupStatusEnum::ENABLED
  });

  # Create an ad group operation.
  my $ad_group_operation =
    Google::Ads::GoogleAds::V23::Services::AdGroupService::AdGroupOperation->
    new({create => $ad_group});

  # Add the ad group.
  my $ad_group_resource_name = $api_client->AdGroupService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_operation]})->{results}[0]{resourceName};

  printf "Added an ad group with resource name: '%s'.\n",
    $ad_group_resource_name;

  return $ad_group_resource_name;
}
# [END add_things_to_do_ad_2]

# Creates a new ad group ad in the specified ad group.
# [START add_things_to_do_ad_3]
sub add_ad_group_ad {
  my ($api_client, $customer_id, $ad_group_resource_name) = @_;

  # Create an ad group ad and set a travel ad info.
  my $ad_group_ad = Google::Ads::GoogleAds::V23::Resources::AdGroupAd->new({
      # Set the ad group.
      adGroup => $ad_group_resource_name,
      ad      => Google::Ads::GoogleAds::V23::Resources::Ad->new({
          travelAd => Google::Ads::GoogleAds::V23::Common::TravelAdInfo->new()}
      ),
      # Set the ad group to enabled. Setting this to paused will cause an error
      # for Things to do campaigns. Pausing should happen at either the ad group
      # or campaign level.
      status => Google::Ads::GoogleAds::V23::Enums::AdGroupAdStatusEnum::ENABLED
    });

  # Create an ad group ad operation.
  my $ad_group_ad_operation =
    Google::Ads::GoogleAds::V23::Services::AdGroupAdService::AdGroupAdOperation
    ->new({create => $ad_group_ad});

  # Add the ad group ad.
  my $ad_group_ad_resource_name = $api_client->AdGroupAdService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_ad_operation]})->{results}[0]{resourceName};

  printf "Added an ad group ad with resource name: '%s'.\n",
    $ad_group_ad_resource_name;

  return $ad_group_ad_resource_name;
}
# [END add_things_to_do_ad_3]

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

my $customer_id                    = undef;
my $things_to_do_center_account_id = undef;

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s"                    => \$customer_id,
  "things_to_do_center_account_id=i" => \$things_to_do_center_account_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $things_to_do_center_account_id);

# Call the example.
add_things_to_do_ad(
  $api_client,
  $customer_id =~ s/-//gr,
  $things_to_do_center_account_id
);

=pod

=head1 NAME

add_things_to_do_ad

=head1 DESCRIPTION

This example creates a Things to do campaign, an ad group and a Things to do ad.

Prerequisite: You need to have an access to the Things to Do Center. The integration
instructions can be found at: https://support.google.com/google-ads/answer/13387362.

=head1 SYNOPSIS

add_things_to_do_ad.pl [options]

    -help                           	Show the help message.
    -customer_id                    	The Google Ads customer ID.
    -things_to_do_center_account_id 	The Things to Do Center account ID.

=cut
