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
# This example adds a portfolio bidding strategy and uses it to construct a
# campaign.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Resources::BiddingStrategy;
use Google::Ads::GoogleAds::V21::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V21::Resources::Campaign;
use Google::Ads::GoogleAds::V21::Resources::NetworkSettings;
use Google::Ads::GoogleAds::V21::Common::TargetSpend;
use Google::Ads::GoogleAds::V21::Enums::BudgetDeliveryMethodEnum   qw(STANDARD);
use Google::Ads::GoogleAds::V21::Enums::AdvertisingChannelTypeEnum qw(SEARCH);
use Google::Ads::GoogleAds::V21::Enums::CampaignStatusEnum         qw(PAUSED);
use Google::Ads::GoogleAds::V21::Enums::EuPoliticalAdvertisingStatusEnum
  qw(DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING);
use
  Google::Ads::GoogleAds::V21::Services::BiddingStrategyService::BiddingStrategyOperation;
use
  Google::Ads::GoogleAds::V21::Services::CampaignBudgetService::CampaignBudgetOperation;
use Google::Ads::GoogleAds::V21::Services::CampaignService::CampaignOperation;
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
# Optional: Specify a campaign budget ID below to be used to create a campaign.
# If none is specified, this example will create a new campaign budget.
my $campaign_budget_id = undef;

sub use_portfolio_bidding_strategy {
  my ($api_client, $customer_id, $campaign_budget_id) = @_;

  my $bidding_strategy_resource_name =
    create_bidding_strategy($api_client, $customer_id);

  my $campaign_budget_resource_name =
    $campaign_budget_id
    ? Google::Ads::GoogleAds::V21::Utils::ResourceNames::campaign_budget(
    $customer_id, $campaign_budget_id)
    : create_shared_campaign_buget($api_client, $customer_id);

  create_campaign_with_bidding_strategy(
    $api_client, $customer_id,
    $bidding_strategy_resource_name,
    $campaign_budget_resource_name
  );

  return 1;
}

# Creates the portfolio bidding strategy.
# [START use_portfolio_bidding_strategy_1]
sub create_bidding_strategy {
  my ($api_client, $customer_id) = @_;

  # Create a portfolio bidding strategy.
  my $portfolio_bidding_strategy =
    Google::Ads::GoogleAds::V21::Resources::BiddingStrategy->new({
      name        => "Maximize Clicks #" . uniqid(),
      targetSpend => Google::Ads::GoogleAds::V21::Common::TargetSpend->new({
          cpcBidCeilingMicros => 2000000
        }
      ),
    });

  # Create a bidding strategy operation.
  my $bidding_strategy_operation =
    Google::Ads::GoogleAds::V21::Services::BiddingStrategyService::BiddingStrategyOperation
    ->new({
      create => $portfolio_bidding_strategy
    });

  # Add the bidding strategy.
  my $bidding_strategies_response =
    $api_client->BiddingStrategyService()->mutate({
      customerId => $customer_id,
      operations => [$bidding_strategy_operation]});

  my $bidding_strategy_resource_name =
    $bidding_strategies_response->{results}[0]{resourceName};

  printf "Created portfolio bidding strategy with resource name: '%s'.\n",
    $bidding_strategy_resource_name;

  return $bidding_strategy_resource_name;
}
# [END use_portfolio_bidding_strategy_1]

# Creates an explicitly shared budget to be used to create the campaign.
# [START use_portfolio_bidding_strategy]
sub create_shared_campaign_buget {
  my ($api_client, $customer_id) = @_;

  # Create a shared budget.
  my $campaign_budget =
    Google::Ads::GoogleAds::V21::Resources::CampaignBudget->new({
      name           => "Shared Interplanetary Budget #" . uniqid(),
      deliveryMethod => STANDARD,
      # Set the amount of budget.
      amountMicros => 50000000,
      # Makes the budget explicitly shared.
      explicitlyShared => 'true'
    });

  # Create a campaign budget operation.
  my $campaign_budget_operation =
    Google::Ads::GoogleAds::V21::Services::CampaignBudgetService::CampaignBudgetOperation
    ->new({create => $campaign_budget});

  # Add the campaign budget.
  my $campaign_budgets_response = $api_client->CampaignBudgetService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_budget_operation]});

  my $campaign_budget_resource_name =
    $campaign_budgets_response->{results}[0]{resourceName};

  printf "Created a shared budget with resource name: '%s'.\n",
    $campaign_budget_resource_name;

  return $campaign_budget_resource_name;
}
# [END use_portfolio_bidding_strategy]

# Creates a campaign with the created portfolio bidding strategy.
sub create_campaign_with_bidding_strategy {
  my (
    $api_client, $customer_id,
    $bidding_strategy_resource_name,
    $campaign_budget_resource_name
  ) = @_;

  # [START use_portfolio_bidding_strategy_2]
  # Create a search campaign.
  my $campaign = Google::Ads::GoogleAds::V21::Resources::Campaign->new({
      name                   => "Interplanetary Cruise #" . uniqid(),
      advertisingChannelType => SEARCH,
      # Recommendation: Set the campaign to PAUSED when creating it to stop
      # the ads from immediately serving. Set to ENABLED once you've added
      # targeting and the ads are ready to serve.
      status => PAUSED,
      # Configures the campaign network options.
      networkSettings =>
        Google::Ads::GoogleAds::V21::Resources::NetworkSettings->new({
          targetGoogleSearch   => "true",
          targetSearchNetwork  => "true",
          targetContentNetwork => "true"
        }
        ),
      # Set the bidding strategy and budget.
      biddingStrategy => $bidding_strategy_resource_name,
      campaignBudget  => $campaign_budget_resource_name,
      # Declare whether or not this campaign serves political ads targeting the EU.
      # Valid values are CONTAINS_EU_POLITICAL_ADVERTISING and
      # DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING.
      containsEuPoliticalAdvertising =>
        DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING
    });
  # [END use_portfolio_bidding_strategy_2]

  # Create a campaign operation.
  my $campaign_operation =
    Google::Ads::GoogleAds::V21::Services::CampaignService::CampaignOperation->
    new({create => $campaign});

  # Add the campaign.
  my $campaigns_response = $api_client->CampaignService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_operation]});

  my $campaign_resource_name = $campaigns_response->{results}[0]{resourceName};

  printf "Created a campaign with resource name: '%s'.\n",
    $campaign_resource_name;
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
  "customer_id=s"        => \$customer_id,
  "campaign_budget_id=i" => \$campaign_budget_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
use_portfolio_bidding_strategy($api_client, $customer_id =~ s/-//gr,
  $campaign_budget_id);

=pod

=head1 NAME

use_portfolio_bidding_strategy

=head1 DESCRIPTION

This example adds a portfolio bidding strategy and uses it to construct a campaign.

=head1 SYNOPSIS

use_portfolio_bidding_strategy.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_budget_id         [optional] The ID of the shared campaign budget to use.

=cut
