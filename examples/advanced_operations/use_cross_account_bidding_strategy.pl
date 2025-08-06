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
# Demonstrates how to update the bidding strategy for an existing campaign.
#
# This example adds a cross-account bidding strategy to a manager account and
# attaches it to a client customer's campaign. Also lists all the bidding
# strategies that are owned by the manager and accessible by the customer.
# Please read our guide pages more information on bidding strategies:
# https://developers.google.com/google-ads/api/docs/campaigns/bidding/cross-account-strategies

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V21::Resources::BiddingStrategy;
use Google::Ads::GoogleAds::V21::Resources::Campaign;
use Google::Ads::GoogleAds::V21::Common::TargetSpend;
use
  Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;
use
  Google::Ads::GoogleAds::V21::Services::BiddingStrategyService::BiddingStrategyOperation;
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
my $customer_id         = "INSERT_CUSTOMER_ID_HERE";
my $manager_customer_id = "INSERT_MANAGER_CUSTOMER_ID_HERE";
my $campaign_id         = "INSERT_CAMPAIGN_ID_HERE";

sub use_cross_account_bidding_strategy {
  my ($api_client, $customer_id, $manager_customer_id, $campaign_id) = @_;

  my $bidding_strategy_resource_name =
    _create_bidding_strategy($api_client, $manager_customer_id);
  _list_manager_owned_bidding_strategies($api_client, $manager_customer_id);
  _list_customer_accessible_bidding_strategies($api_client, $customer_id);
  _attach_cross_account_bidding_strategy_to_campaign($api_client, $customer_id,
    $campaign_id, $bidding_strategy_resource_name);

  return 1;
}

# [START create_cross_account_strategy]
# Creates a new TargetSpend (Maximize Clicks) cross-account bidding strategy in
# the specified manager account.
sub _create_bidding_strategy {
  my ($api_client, $manager_customer_id) = @_;

  # Create a portfolio bidding strategy.
  # [START set_currency_code]
  my $portfolio_bidding_strategy =
    Google::Ads::GoogleAds::V21::Resources::BiddingStrategy->new({
      name        => "Maximize clicks #" . uniqid(),
      targetSpend => Google::Ads::GoogleAds::V21::Common::TargetSpend->new(),
      # Sets the currency of the new bidding strategy. If not provided, the
      # bidding strategy uses the manager account's default currency.
      currencyCode => "USD"
    });
  # [END set_currency_code]

  # Send a create operation that will create the portfolio bidding strategy.
  my $mutate_bidding_strategies_response =
    $api_client->BiddingStrategyService()->mutate({
      customerId => $manager_customer_id,
      operations => [
        Google::Ads::GoogleAds::V21::Services::BiddingStrategyService::BiddingStrategyOperation
          ->new({
            create => $portfolio_bidding_strategy
          })]});

  my $resource_name =
    $mutate_bidding_strategies_response->{results}[0]{resourceName};

  printf "Created cross-account bidding strategy with resource name '%s'.\n",
    $resource_name;

  return $resource_name;
}
# [END create_cross_account_strategy]

# [START list_manager_strategies]
# Lists all cross-account bidding strategies in a specified manager account.
sub _list_manager_owned_bidding_strategies {
  my ($api_client, $manager_customer_id) = @_;

  # Create a GAQL query that will retrieve all cross-account bidding
  # strategies.
  my $query = "SELECT
                 bidding_strategy.id,
                 bidding_strategy.name,
                 bidding_strategy.type,
                 bidding_strategy.currency_code
               FROM bidding_strategy";

  # Issue a streaming search request, then iterate through and print the
  # results.
  my $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $api_client->GoogleAdsService(),
      request =>
        Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
        ->new({
          customerId => $manager_customer_id,
          query      => $query
        })});

  printf
    "Cross-account bid strategies in manager account $manager_customer_id:\n";
  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row   = shift;
      my $bidding_strategy = $google_ads_row->{biddingStrategy};
      printf "\tID: $bidding_strategy->{id}\n" .
        "\tName: $bidding_strategy->{name}\n" .
        "\tStrategy type: $bidding_strategy->{type}\n" .
        "\tCurrency: $bidding_strategy->{currencyCode}\n\n";
    });
}
# [END list_manager_strategies]

# [START list_accessible_strategies]
# Lists all bidding strategies available to specified client customer account.
# This includes both portfolio bidding strategies owned by the client customer
# account and cross-account bidding strategies shared by any of its managers.
sub _list_customer_accessible_bidding_strategies {
  my ($api_client, $customer_id) = @_;

  # Create a GAQL query that will retrieve all accessible bidding strategies.
  my $query = "SELECT
                 accessible_bidding_strategy.resource_name,
                 accessible_bidding_strategy.id,
                 accessible_bidding_strategy.name,
                 accessible_bidding_strategy.type,
                 accessible_bidding_strategy.owner_customer_id,
                 accessible_bidding_strategy.owner_descriptive_name
               FROM accessible_bidding_strategy";

  # Uncomment the following WHERE clause addition to the query to filter results
  # to *only* cross-account bidding strategies shared with the current customer
  # by a manager (and not also include the current customer's portfolio bidding
  # strategies).
  # $query .=
  #   " WHERE accessible_bidding_strategy.owner_customer_id != $customer_id";

  # Issue a streaming search request, then iterate through and print the
  # results.
  my $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $api_client->GoogleAdsService(),
      request =>
        Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
        ->new({
          customerId => $customer_id,
          query      => $query
        })});

  printf "All bid strategies accessible by account $customer_id:\n";
  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row   = shift;
      my $bidding_strategy = $google_ads_row->{accessibleBiddingStrategy};
      printf "\tID: $bidding_strategy->{id}\n" .
        "\tName: $bidding_strategy->{name}\n" .
        "\tStrategy type: $bidding_strategy->{type}\n" .
        "\tOwner customer ID: $bidding_strategy->{ownerCustomerId}\n" .
        "\tOwner description: $bidding_strategy->{ownerDescriptiveName}\n\n";
    });
}
# [END list_accessible_strategies]

# [START attach_strategy]
# Attaches a specified cross-account bidding strategy to a campaign owned by a
# specified client customer account.
sub _attach_cross_account_bidding_strategy_to_campaign {
  my ($api_client, $customer_id, $campaign_id, $bidding_strategy_resource_name)
    = @_;

  my $campaign = Google::Ads::GoogleAds::V21::Resources::Campaign->new({
      resourceName =>
        Google::Ads::GoogleAds::V21::Utils::ResourceNames::campaign(
        $customer_id, $campaign_id
        ),
      biddingStrategy => $bidding_strategy_resource_name
    });

  my $campaign_operation =
    Google::Ads::GoogleAds::V21::Services::CampaignService::CampaignOperation->
    new({
      update     => $campaign,
      updateMask => all_set_fields_of($campaign)});

  my $campaigns_response = $api_client->CampaignService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_operation]});

  printf "Updated campaign with resource name '%s'.\n",
    $campaigns_response->{results}[0]{resourceName};
}
# [END attach_strategy]

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
  "customer_id=s"         => \$customer_id,
  "manager_customer_id=s" => \$manager_customer_id,
  "campaign_id=i"         => \$campaign_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $manager_customer_id, $campaign_id);

# Call the example.
use_cross_account_bidding_strategy(
  $api_client,
  $customer_id =~ s/-//gr,
  $manager_customer_id =~ s/-//gr, $campaign_id
);

=pod

=head1 NAME

use_cross_account_bidding_strategy

=head1 DESCRIPTION

Demonstrates how to update the bidding strategy for an existing campaign.

This example shows updating a search campaign to maximize conversions, although
the same principles apply for other campaign/bidding strategy types.

=head1 SYNOPSIS

use_cross_account_bidding_strategy.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads client customer ID.
    -manager_customer_id        The ID of the account that owns the cross-account bidding strategy.
                                This is typically the ID of the manager account.
    -campaign_id                The ID of the campaign owned by the customer ID to which the cross-account
                                bidding strategy will be attached.

=cut
