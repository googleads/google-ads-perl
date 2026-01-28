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
# This example adds a new dynamic search ad (DSA) and a webpage targeting
# criterion for the DSA.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V23::Resources::Campaign;
use Google::Ads::GoogleAds::V23::Resources::DynamicSearchAdsSetting;
use Google::Ads::GoogleAds::V23::Resources::AdGroup;
use Google::Ads::GoogleAds::V23::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V23::Resources::Ad;
use Google::Ads::GoogleAds::V23::Resources::AdGroupCriterion;
use Google::Ads::GoogleAds::V23::Common::ManualCpc;
use Google::Ads::GoogleAds::V23::Common::ExpandedDynamicSearchAdInfo;
use Google::Ads::GoogleAds::V23::Common::WebpageInfo;
use Google::Ads::GoogleAds::V23::Common::WebpageConditionInfo;
use Google::Ads::GoogleAds::V23::Enums::BudgetDeliveryMethodEnum   qw(STANDARD);
use Google::Ads::GoogleAds::V23::Enums::AdvertisingChannelTypeEnum qw(SEARCH);
use Google::Ads::GoogleAds::V23::Enums::CampaignStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::AdGroupStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::AdGroupTypeEnum qw(SEARCH_DYNAMIC_ADS);
use Google::Ads::GoogleAds::V23::Enums::AdGroupAdStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::AdGroupCriterionStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::WebpageConditionOperandEnum
  qw(URL PAGE_TITLE);
use Google::Ads::GoogleAds::V23::Enums::EuPoliticalAdvertisingStatusEnum
  qw(DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING);
use
  Google::Ads::GoogleAds::V23::Services::CampaignBudgetService::CampaignBudgetOperation;
use Google::Ads::GoogleAds::V23::Services::CampaignService::CampaignOperation;
use Google::Ads::GoogleAds::V23::Services::AdGroupService::AdGroupOperation;
use Google::Ads::GoogleAds::V23::Services::AdGroupAdService::AdGroupAdOperation;
use
  Google::Ads::GoogleAds::V23::Services::AdGroupCriterionService::AdGroupCriterionOperation;
use Google::Ads::GoogleAds::V23::Utils::ResourceNames;

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

sub add_dynamic_search_ads {
  my ($api_client, $customer_id) = @_;

  my $campaign_budget_resource_name =
    create_campaign_budget($api_client, $customer_id);
  my $campaign_resource_name =
    create_campaign($api_client, $customer_id, $campaign_budget_resource_name);
  my $ad_group_resource_name =
    create_ad_group($api_client, $customer_id, $campaign_resource_name);

  create_expanded_dsa($api_client, $customer_id, $ad_group_resource_name);
  add_web_page_criterion($api_client, $customer_id, $ad_group_resource_name);

  return 1;
}

# Creates a campaign budget.
sub create_campaign_budget {
  my ($api_client, $customer_id) = @_;

  # Create a campaign budget.
  my $campaign_budget =
    Google::Ads::GoogleAds::V23::Resources::CampaignBudget->new({
      name           => "Interplanetary Cruise Budget #" . uniqid(),
      deliveryMethod => STANDARD,
      amountMicros   => 50000000
    });

  # Create a campaign budget operation.
  my $campaign_budget_operation =
    Google::Ads::GoogleAds::V23::Services::CampaignBudgetService::CampaignBudgetOperation
    ->new({create => $campaign_budget});

  # Add the campaign budget.
  my $campaign_budgets_response = $api_client->CampaignBudgetService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_budget_operation]});

  my $campaign_budget_resource_name =
    $campaign_budgets_response->{results}[0]{resourceName};
  printf "Created campaign budget '%s'.\n", $campaign_budget_resource_name;

  return $campaign_budget_resource_name;
}

# Creates a campaign.
# [START add_dynamic_search_ads]
sub create_campaign {
  my ($api_client, $customer_id, $campaign_budget_resource_name) = @_;

  # Create a campaign.
  my $campaign = Google::Ads::GoogleAds::V23::Resources::Campaign->new({
      name                   => "Interplanetary Cruise #" . uniqid(),
      advertisingChannelType => SEARCH,
      status => Google::Ads::GoogleAds::V23::Enums::CampaignStatusEnum::PAUSED,
      manualCpc      => Google::Ads::GoogleAds::V23::Common::ManualCpc->new(),
      campaignBudget => $campaign_budget_resource_name,
      # Enable the campaign for DSAs.
      dynamicSearchAdsSetting =>
        Google::Ads::GoogleAds::V23::Resources::DynamicSearchAdsSetting->new({
          domainName   => "example.com",
          languageCode => "en"
        }
        ),
      # Optional: Set the start and end datetimes for the campaign, beginning one day from
      # now and ending a month from now.
      startDateTime =>
        strftime("%Y%m%d 00:00:00", localtime(time + 60 * 60 * 24)),
      endDateTime =>
        strftime("%Y%m%d 23:59:59", localtime(time + 60 * 60 * 24 * 30)),
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
  my $campaigns_response = $api_client->CampaignService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_operation]});

  my $campaign_resource_name = $campaigns_response->{results}[0]{resourceName};

  printf "Created campaign '%s'.\n", $campaign_resource_name;

  return $campaign_resource_name;
}
# [END add_dynamic_search_ads]

# Creates an ad group.
# [START add_dynamic_search_ads_1]
sub create_ad_group {
  my ($api_client, $customer_id, $campaign_resource_name) = @_;

  # Construct an ad group and set an optional CPC value.
  my $ad_group = Google::Ads::GoogleAds::V23::Resources::AdGroup->new({
    name     => "Earth to Mars Cruises #" . uniqid(),
    campaign => $campaign_resource_name,
    status   => Google::Ads::GoogleAds::V23::Enums::AdGroupStatusEnum::PAUSED,
    type     => SEARCH_DYNAMIC_ADS,
    trackingUrlTemplate =>
      "http://tracker.examples.com/traveltracker/{escapedlpurl}",
    cpcBidMicros => 3000000
  });

  # Create an ad group operation.
  my $ad_group_operation =
    Google::Ads::GoogleAds::V23::Services::AdGroupService::AdGroupOperation->
    new({create => $ad_group});

  # Add the ad group.
  my $ad_groups_response = $api_client->AdGroupService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_operation]});

  my $ad_group_resource_name = $ad_groups_response->{results}[0]{resourceName};

  printf "Created ad group '%s'.\n", $ad_group_resource_name;

  return $ad_group_resource_name;
}
# [END add_dynamic_search_ads_1]

# Creates an expanded dynamic search ad.
# [START add_dynamic_search_ads_2]
sub create_expanded_dsa {
  my ($api_client, $customer_id, $ad_group_resource_name) = @_;

  # Create an ad group ad.
  my $ad_group_ad = Google::Ads::GoogleAds::V23::Resources::AdGroupAd->new({
      adGroup => $ad_group_resource_name,
      status => Google::Ads::GoogleAds::V23::Enums::AdGroupAdStatusEnum::PAUSED,
      ad     => Google::Ads::GoogleAds::V23::Resources::Ad->new({
          expandedDynamicSearchAd =>
            Google::Ads::GoogleAds::V23::Common::ExpandedDynamicSearchAdInfo->
            new({
              description => "Buy tickets now!"
            })})});

  # Create an ad group ad operation.
  my $ad_group_ad_operation =
    Google::Ads::GoogleAds::V23::Services::AdGroupAdService::AdGroupAdOperation
    ->new({create => $ad_group_ad});

  # Add the ad group ad.
  my $ad_group_ads_response = $api_client->AdGroupAdService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_ad_operation]});

  my $ad_group_ad_resource_name =
    $ad_group_ads_response->{results}[0]{resourceName};

  printf "Created ad group ad '%s'.\n", $ad_group_ad_resource_name;

  return $ad_group_ad_resource_name;
}
# [END add_dynamic_search_ads_2]

# Creates a webpage targeting criterion for the DSA.
sub add_web_page_criterion {
  my ($api_client, $customer_id, $ad_group_resource_name) = @_;

  # Create an ad group criterion.
  my $ad_group_criterion =
    Google::Ads::GoogleAds::V23::Resources::AdGroupCriterion->new({
      adGroup => $ad_group_resource_name,
      status  =>
        Google::Ads::GoogleAds::V23::Enums::AdGroupCriterionStatusEnum::PAUSED,
      cpcBidMicros => 10000000,
      webpage      => Google::Ads::GoogleAds::V23::Common::WebpageInfo->new({
          criterionName => "Special Offers",
          conditions    => [
            Google::Ads::GoogleAds::V23::Common::WebpageConditionInfo->new({
                operand  => URL,
                argument => "/specialoffers"

              }
            ),
            Google::Ads::GoogleAds::V23::Common::WebpageConditionInfo->new({
                operand  => PAGE_TITLE,
                argument => "Special Offers"
              })]})});

  # Create an ad group criterion operation.
  my $ad_group_criterion_operation =
    Google::Ads::GoogleAds::V23::Services::AdGroupCriterionService::AdGroupCriterionOperation
    ->new({create => $ad_group_criterion});

  # Add the ad group criterion.
  my $ad_group_criteria_response =
    $api_client->AdGroupCriterionService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_criterion_operation]});

  my $ad_group_criterion_resource_name =
    $ad_group_criteria_response->{results}[0]{resourceName};

  printf "Created ad group criterion '%s'.\n",
    $ad_group_criterion_resource_name;
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
add_dynamic_search_ads($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

add_dynamic_search_ads

=head1 DESCRIPTION

This example adds a new dynamic search ad (DSA) and a webpage targeting criterion
for the DSA.

=head1 SYNOPSIS

add_dynamic_search_ads.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
