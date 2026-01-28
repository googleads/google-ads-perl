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
# This example creates a standard shopping campaign, a shopping product ad group
# and a shopping product ad.
#
# Prerequisite: You need to have access to a Merchant Center account. You can
# find instructions to create a Merchant Center account here:
# https://support.google.com/merchants/answer/188924
# This account must be linked to your Google Ads account.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V23::Resources::Campaign;
use Google::Ads::GoogleAds::V23::Resources::ShoppingSetting;
use Google::Ads::GoogleAds::V23::Resources::AdGroup;
use Google::Ads::GoogleAds::V23::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V23::Resources::Ad;
use Google::Ads::GoogleAds::V23::Resources::AdGroupCriterion;
use Google::Ads::GoogleAds::V23::Common::ManualCpc;
use Google::Ads::GoogleAds::V23::Common::ShoppingProductAdInfo;
use Google::Ads::GoogleAds::V23::Common::ListingGroupInfo;
use Google::Ads::GoogleAds::V23::Enums::BudgetDeliveryMethodEnum   qw(STANDARD);
use Google::Ads::GoogleAds::V23::Enums::AdvertisingChannelTypeEnum qw(SHOPPING);
use Google::Ads::GoogleAds::V23::Enums::AdGroupTypeEnum
  qw(SHOPPING_PRODUCT_ADS);
use Google::Ads::GoogleAds::V23::Enums::CampaignStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::AdGroupStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::AdGroupAdStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::ListingGroupTypeEnum qw(UNIT);
use Google::Ads::GoogleAds::V23::Enums::AdGroupCriterionStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::EuPoliticalAdvertisingStatusEnum
  qw(DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING);
use
  Google::Ads::GoogleAds::V23::Services::CampaignBudgetService::CampaignBudgetOperation;
use Google::Ads::GoogleAds::V23::Services::CampaignService::CampaignOperation;
use Google::Ads::GoogleAds::V23::Services::AdGroupService::AdGroupOperation;
use Google::Ads::GoogleAds::V23::Services::AdGroupAdService::AdGroupAdOperation;
use
  Google::Ads::GoogleAds::V23::Services::AdGroupCriterionService::AdGroupCriterionOperation;

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
my $customer_id                  = "INSERT_CUSTOMER_ID_HERE";
my $merchant_center_account_id   = "INSERT_MERCHANT_CENTER_ACCOUNT_ID_HERE";
my $create_default_listing_group = undef;

sub add_shopping_product_ad {
  my ($api_client, $customer_id, $merchant_center_account_id,
    $create_default_listing_group)
    = @_;

  # Create a budget to be used by the campaign that will be created below.
  my $budget_resource_name = add_campaign_budget($api_client, $customer_id);

  # Create a standard shopping campaign.
  my $campaign_resource_name =
    add_standard_shopping_campaign($api_client, $customer_id,
    $budget_resource_name, $merchant_center_account_id);

  # Create a shopping product ad group.
  my $ad_group_resource_name =
    add_shopping_product_ad_group($api_client, $customer_id,
    $campaign_resource_name);

  # Create a shopping product ad group ad.
  add_shopping_product_ad_group_ad($api_client, $customer_id,
    $ad_group_resource_name);

  if ($create_default_listing_group) {
    # Create an ad group criterion containing a listing group.
    # This will be the listing group tree for 'All products' and will
    # contain a single biddable unit node.
    add_default_shopping_listing_group($api_client, $customer_id,
      $ad_group_resource_name);
  }

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
      amountMicros => 5000000
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

# Creates a new standard shopping campaign in the specified client account.
# [START add_shopping_product_ad_2]
sub add_standard_shopping_campaign {
  my ($api_client, $customer_id, $budget_resource_name,
    $merchant_center_account_id)
    = @_;

  # Create a standard shopping campaign.
  my $campaign = Google::Ads::GoogleAds::V23::Resources::Campaign->new({
      name => "Interplanetary Cruise Campaign #" . uniqid(),
      # Configure settings related to shopping campaigns including advertising
      # channel type and shopping setting.
      advertisingChannelType => SHOPPING,
      shoppingSetting        =>
        Google::Ads::GoogleAds::V23::Resources::ShoppingSetting->new({
          merchantId => $merchant_center_account_id,
          # Set the priority of the campaign. Higher numbers take priority over
          # lower numbers. For standard shopping campaigns, allowed values are
          # between 0 and 2, inclusive.
          campaignPriority => 0,
          # Enable local inventory ads for this campaign.
          enableLocal => "true"
        }
        ),
      # Recommendation: Set the campaign to PAUSED when creating it to prevent
      # the ads from immediately serving. Set to ENABLED once you've added
      # targeting and the ads are ready to serve.
      status => Google::Ads::GoogleAds::V23::Enums::CampaignStatusEnum::PAUSED,
      # Set the bidding strategy to Manual CPC.
      # Recommendation: Use one of the automated bidding strategies for shopping
      # campaigns to help you optimize your advertising spend. More information
      # can be found here: https://support.google.com/google-ads/answer/6309029.
      manualCpc => Google::Ads::GoogleAds::V23::Common::ManualCpc->new(),
      # Set the budget.
      campaignBudget => $budget_resource_name,
      # Declare whether or not this campaign serves political ads targeting the EU.
      # Valid values are CONTAINS_EU_POLITICAL_ADVERTISING and
      # DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING.
      containsEuPoliticalAdvertising =>
        DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING
    });

  # Create a campaign operation.
  my $campaign_operation =
    Google::Ads::GoogleAds::V23::Services::CampaignService::CampaignOperation->
    new({create => $campaign});

  # Add the campaign.
  my $campaign_resource_name = $api_client->CampaignService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_operation]})->{results}[0]{resourceName};

  printf "Added a standard shopping campaign with resource name: '%s'.\n",
    $campaign_resource_name;

  return $campaign_resource_name;
}
# [END add_shopping_product_ad_2]

# Creates a new shopping product ad group in the specified campaign.
# [START add_shopping_product_ad_1]
sub add_shopping_product_ad_group {
  my ($api_client, $customer_id, $campaign_resource_name) = @_;

  # Create an ad group.
  my $ad_group = Google::Ads::GoogleAds::V23::Resources::AdGroup->new({
    name     => "Earth to Mars Cruises #" . uniqid(),
    campaign => $campaign_resource_name,
    # Set the ad group type to SHOPPING_PRODUCT_ADS. This is the only value
    # possible for ad groups that contain shopping product ads.
    type         => SHOPPING_PRODUCT_ADS,
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

  printf "Added a product shopping ad group with resource name: '%s'.\n",
    $ad_group_resource_name;

  return $ad_group_resource_name;
}
# [END add_shopping_product_ad_1]

# Creates a new shopping product ad group ad in the specified ad group.
# [START add_shopping_product_ad]
sub add_shopping_product_ad_group_ad {
  my ($api_client, $customer_id, $ad_group_resource_name) = @_;

  # Create an ad group ad and set a shopping product ad to it.
  my $ad_group_ad = Google::Ads::GoogleAds::V23::Resources::AdGroupAd->new({
      # Set the ad group.
      adGroup => $ad_group_resource_name,
      # Set the ad to a new shopping product ad.
      ad => Google::Ads::GoogleAds::V23::Resources::Ad->new({
          shoppingProductAd =>
            Google::Ads::GoogleAds::V23::Common::ShoppingProductAdInfo->new()}
      ),
      status => Google::Ads::GoogleAds::V23::Enums::AdGroupAdStatusEnum::PAUSED
    });

  # Create an ad group ad operation.
  my $ad_group_ad_operation =
    Google::Ads::GoogleAds::V23::Services::AdGroupAdService::AdGroupAdOperation
    ->new({create => $ad_group_ad});

  # Add the ad group ad.
  my $ad_group_ad_resource_name = $api_client->AdGroupAdService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_ad_operation]})->{results}[0]{resourceName};

  printf "Added a product shopping ad group ad with resource name: '%s'.\n",
    $ad_group_ad_resource_name;

  return $ad_group_ad_resource_name;
}
# [END add_shopping_product_ad]

# Creates a new default shopping listing group for the specified ad group. A listing
# group is the Google Ads API representation of a "product group" described in the
# Google Ads user interface. The listing group will be added to the ad group using an
# "ad group criterion". The criterion will contain the bid for a given listing group.
sub add_default_shopping_listing_group {
  my ($api_client, $customer_id, $ad_group_resource_name) = @_;

  # Create a new ad group criterion. This will contain the "default" listing group
  # (All products).
  my $ad_group_criterion =
    Google::Ads::GoogleAds::V23::Resources::AdGroupCriterion->new({
      # Set the ad group.
      adGroup => $ad_group_resource_name,
      # Create a new listing group. This will be the top-level "root" node.
      # Set the type of the listing group to be a biddable unit.
      listingGroup =>
        Google::Ads::GoogleAds::V23::Common::ListingGroupInfo->new({
          type => UNIT
        }
        ),
      # Set the bid for products in this listing group unit.
      cpcBidMicros => 500000,
      status       =>
        Google::Ads::GoogleAds::V23::Enums::AdGroupCriterionStatusEnum::ENABLED
    });

  # Create an ad group criterion operation.
  my $ad_group_criterion_operation =
    Google::Ads::GoogleAds::V23::Services::AdGroupCriterionService::AdGroupCriterionOperation
    ->new({create => $ad_group_criterion});

  # Add the listing group criterion.
  my $ad_group_criterion_resource_name =
    $api_client->AdGroupCriterionService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_criterion_operation]}
    )->{results}[0]{resourceName};

  printf "Added an ad group criterion containing a listing group " .
    "with resource name: '%s'.\n", $ad_group_criterion_resource_name;

  return $ad_group_criterion_resource_name;
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
  "customer_id=s"                  => \$customer_id,
  "merchant_center_account_id=i"   => \$merchant_center_account_id,
  "create_default_listing_group=s" => \$create_default_listing_group
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $merchant_center_account_id);

# Call the example.
add_shopping_product_ad($api_client, $customer_id =~ s/-//gr,
  $merchant_center_account_id, $create_default_listing_group);

=pod

=head1 NAME

add_shopping_product_ad

=head1 DESCRIPTION

This example creates a standard shopping campaign, a shopping product ad group
and a shopping product ad.

Prerequisite: You need to have access to a Merchant Center account. You can find
instructions to create a Merchant Center account here:
https://support.google.com/merchants/answer/188924
This account must be linked to your Google Ads account.

=head1 SYNOPSIS

add_shopping_product_ad.pl [options]

    -help                           Show the help message.
    -customer_id                    The Google Ads customer ID.
    -merchant_center_account_id     The Merchant Center account ID.
    -create_default_listing_group   [optional] Create default listing group.

=cut
