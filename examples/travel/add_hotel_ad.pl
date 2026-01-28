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
# This example creates a hotel campaign, a hotel ad group and hotel ad
# group ad.
#
# Prerequisite: You need to have access to the Hotel Ads Center, which can be
# granted during integration with Google Hotels. The integration instructions
# can be found at:
# https://support.google.com/hotelprices/answer/6101897

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V23::Resources::Campaign;
use Google::Ads::GoogleAds::V23::Resources::HotelSettingInfo;
use Google::Ads::GoogleAds::V23::Resources::NetworkSettings;
use Google::Ads::GoogleAds::V23::Resources::AdGroup;
use Google::Ads::GoogleAds::V23::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V23::Resources::Ad;
use Google::Ads::GoogleAds::V23::Common::PercentCpc;
use Google::Ads::GoogleAds::V23::Common::HotelAdInfo;
use Google::Ads::GoogleAds::V23::Enums::BudgetDeliveryMethodEnum   qw(STANDARD);
use Google::Ads::GoogleAds::V23::Enums::AdvertisingChannelTypeEnum qw(HOTEL);
use Google::Ads::GoogleAds::V23::Enums::AdGroupTypeEnum qw(HOTEL_ADS);
use Google::Ads::GoogleAds::V23::Enums::CampaignStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::AdGroupStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::AdGroupAdStatusEnum;
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

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";
# Specify your Hotels Ads Center account ID below. You can see how to find the
# account ID in the Hotel Ads Center at:
# https://support.google.com/hotelprices/answer/6399770.
# This ID is the same account ID that you use in API requests to the Travel
# Partner APIs at:
# https://developers.google.com/hotels/hotel-ads/api-reference/.
my $hotel_center_account_id = "INSERT_HOTEL_CENTER_ACCOUNT_ID_HERE";
# Specify maximum bid limit that can be set when creating a campaign using the
# Percent CPC bidding strategy.
my $cpc_bid_ceiling_micro_amount = 20000000;

sub add_hotel_ad {
  my ($api_client, $customer_id, $hotel_center_account_id,
    $cpc_bid_ceiling_micro_amount)
    = @_;

  # Create a budget to be used by the campaign that will be created below.
  my $budget_resource_name = add_campaign_budget($api_client, $customer_id);

  # Create a hotel campaign.
  my $campaign_resource_name =
    add_hotel_campaign($api_client, $customer_id,
    $budget_resource_name, $hotel_center_account_id,
    $cpc_bid_ceiling_micro_amount);

  # Create a hotel ad group.
  my $ad_group_resource_name =
    add_hotel_ad_group($api_client, $customer_id, $campaign_resource_name);

  # Create a hotel ad group ad.
  add_hotel_ad_group_ad($api_client, $customer_id, $ad_group_resource_name);

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

# Creates a new hotel campaign in the specified client account.
# [START add_hotel_ad]
sub add_hotel_campaign {
  my ($api_client, $customer_id, $budget_resource_name,
    $hotel_center_account_id, $cpc_bid_ceiling_micro_amount)
    = @_;

  # [START add_hotel_ad_1]
  # Create a hotel campaign.
  my $campaign = Google::Ads::GoogleAds::V23::Resources::Campaign->new({
      name => "Interplanetary Cruise Campaign #" . uniqid(),
      # Configure settings related to hotel campaigns including advertising
      # channel type and hotel setting info.
      advertisingChannelType => HOTEL,
      hotelSetting           =>
        Google::Ads::GoogleAds::V23::Resources::HotelSettingInfo->new({
          hotelCenterId => $hotel_center_account_id
        }
        ),
      # Recommendation: Set the campaign to PAUSED when creating it to prevent
      # the ads from immediately serving. Set to ENABLED once you've added
      # targeting and the ads are ready to serve.
      status => Google::Ads::GoogleAds::V23::Enums::CampaignStatusEnum::PAUSED,
      # Set the bidding strategy to PercentCpc. Only Manual CPC and Percent CPC
      # can be used for hotel campaigns.
      percentCpc => Google::Ads::GoogleAds::V23::Common::PercentCpc->new(
        {cpcBidCeilingMicros => $cpc_bid_ceiling_micro_amount}
      ),
      # Declare whether or not this campaign serves political ads targeting the EU.
      # Valid values are CONTAINS_EU_POLITICAL_ADVERTISING and
      # DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING.
      containsEuPoliticalAdvertising =>
        DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING,
      # Set the budget.
      campaignBudget => $budget_resource_name,
      # Configure the campaign network options. Only Google Search is allowed for
      # hotel campaigns.
      networkSettings =>
        Google::Ads::GoogleAds::V23::Resources::NetworkSettings->new({
          targetGoogleSearch => "true"
        })});
  # [END add_hotel_ad_1]

  # Create a campaign operation.
  my $campaign_operation =
    Google::Ads::GoogleAds::V23::Services::CampaignService::CampaignOperation->
    new({create => $campaign});

  # Add the campaign.
  my $campaign_resource_name = $api_client->CampaignService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_operation]})->{results}[0]{resourceName};

  printf "Added a hotel campaign with resource name: '%s'.\n",
    $campaign_resource_name;

  return $campaign_resource_name;
}
# [END add_hotel_ad]

# Creates a new hotel ad group in the specified campaign.
# [START add_hotel_ad_2]
sub add_hotel_ad_group {
  my ($api_client, $customer_id, $campaign_resource_name) = @_;

  # Create an ad group.
  my $ad_group = Google::Ads::GoogleAds::V23::Resources::AdGroup->new({
    name => "Earth to Mars Cruise #" . uniqid(),
    # Set the campaign.
    campaign => $campaign_resource_name,
    # Set the ad group type to HOTEL_ADS.
    # This cannot be set to other types.
    type         => HOTEL_ADS,
    cpcBidMicros => 1000000,
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

  printf "Added a hotel ad group with resource name: '%s'.\n",
    $ad_group_resource_name;

  return $ad_group_resource_name;
}
# [END add_hotel_ad_2]

# Creates a new hotel ad group ad in the specified ad group.
# [START add_hotel_ad_3]
sub add_hotel_ad_group_ad {
  my ($api_client, $customer_id, $ad_group_resource_name) = @_;

  # Create an ad group ad and set a hotel ad to it.
  my $ad_group_ad = Google::Ads::GoogleAds::V23::Resources::AdGroupAd->new({
      # Set the ad group.
      adGroup => $ad_group_resource_name,
      # Set the ad to a new shopping product ad.
      ad => Google::Ads::GoogleAds::V23::Resources::Ad->new({
          hotelAd => Google::Ads::GoogleAds::V23::Common::HotelAdInfo->new()}
      ),
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

  printf "Added a hotel ad group ad with resource name: '%s'.\n",
    $ad_group_ad_resource_name;

  return $ad_group_ad_resource_name;
}
# [END add_hotel_ad_3]

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
  "customer_id=s"                  => \$customer_id,
  "hotel_center_account_id=i"      => \$hotel_center_account_id,
  "cpc_bid_ceiling_micro_amount=i" => \$cpc_bid_ceiling_micro_amount
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $hotel_center_account_id,
  $cpc_bid_ceiling_micro_amount);

# Call the example.
add_hotel_ad($api_client, $customer_id =~ s/-//gr,
  $hotel_center_account_id, $cpc_bid_ceiling_micro_amount);

=pod

=head1 NAME

add_hotel_ad

=head1 DESCRIPTION

This example creates a hotel campaign, a hotel ad group and hotel ad group ad.

Prerequisite: You need to have access to the Hotel Ads Center, which can be granted
during integration with Google Hotels. The integration instructions can be found at:
https://support.google.com/hotelprices/answer/6101897

=head1 SYNOPSIS

add_hotel_ad.pl [options]

    -help                           Show the help message.
    -customer_id                    The Google Ads customer ID.
    -hotel_center_account_id        The Hotel Ads Center account ID.
    -cpc_bid_ceiling_micro_amount   [optional] The CPC bid ceiling micro amount.

=cut
