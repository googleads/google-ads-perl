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
# This code example is the second in a series of code examples that show how to
# create a search campaign using the AdWords API, and then migrate it to the
# Google Ads API one functionality at a time. See other examples in this directory
# for code examples in various stages of migration.
#
# In this code example, the functionality to create a campaign budget has been
# migrated to the Google Ads API. The remaining functionalities - creating a
# campaign, creating an ad group, creating expanded text ads and creating
# keywords - are using the AdWords API.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../../lib";
use Google::Ads::GoogleAds::V10::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V10::Enums::BudgetDeliveryMethodEnum qw(STANDARD);
use
  Google::Ads::GoogleAds::V10::Services::CampaignBudgetService::CampaignBudgetOperation;
use Google::Ads::AdWords::v201809::Campaign;
use Google::Ads::AdWords::v201809::BiddingStrategyConfiguration;
use Google::Ads::AdWords::v201809::Budget;
use Google::Ads::AdWords::v201809::NetworkSetting;
use Google::Ads::AdWords::v201809::AdGroup;
use Google::Ads::AdWords::v201809::CpcBid;
use Google::Ads::AdWords::v201809::Money;
use Google::Ads::AdWords::v201809::AdGroupAdRotationMode;
use Google::Ads::AdWords::v201809::ExpandedTextAd;
use Google::Ads::AdWords::v201809::AdGroupAd;
use Google::Ads::AdWords::v201809::Keyword;
use Google::Ads::AdWords::v201809::BiddableAdGroupCriterion;
use Google::Ads::AdWords::v201809::UrlList;
use Google::Ads::AdWords::v201809::CampaignOperation;
use Google::Ads::AdWords::v201809::AdGroupOperation;
use Google::Ads::AdWords::v201809::AdGroupAdOperation;
use Google::Ads::AdWords::v201809::AdGroupCriterionOperation;

use Data::Uniqid qw(uniqid);
use URI::Escape qw(uri_escape);
use POSIX qw(strftime);

# Number of ads being added/updated in this code example.
use constant NUMBER_OF_ADS => 5;
# The list of keywords being added in this code example.
use constant KEYWORDS_TO_ADD => ["mars cruise", "space hotel"];
# The default page size for search queries.
use constant PAGE_SIZE => 1000;

sub create_complete_campaign_both_apis_phase_1 {
  my ($adwords_client, $google_ads_client, $customer_id) = @_;

  my $campaign_budget =
    create_campaign_budget($google_ads_client, $customer_id);
  my $campaign = create_campaign($adwords_client, $campaign_budget->{id});
  my $ad_group = create_ad_group($adwords_client, $campaign->get_id());
  create_text_ads($adwords_client, $ad_group->get_id());
  create_keywords($adwords_client, $ad_group->get_id());
}

# Creates a campaign budget.
sub create_campaign_budget {
  my ($google_ads_client, $customer_id) = @_;

  # Create a campaign budget.
  my $campaign_budget =
    Google::Ads::GoogleAds::V10::Resources::CampaignBudget->new({
      name           => "Interplanetary Cruise Budget #" . uniqid(),
      deliveryMethod => STANDARD,
      amountMicros   => 500000
    });

  # Create a campaign budget operation.
  my $campaign_budget_operation =
    Google::Ads::GoogleAds::V10::Services::CampaignBudgetService::CampaignBudgetOperation
    ->new({create => $campaign_budget});

  # Issue a mutate request to add the campaign budget.
  my $campaign_budgets_response =
    $google_ads_client->CampaignBudgetService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_budget_operation]});

  my $campaign_budget_resource_name =
    $campaign_budgets_response->{results}[0]{resourceName};

  my $created_campaign_budget =
    get_campaign_buget($google_ads_client, $customer_id,
    $campaign_budget_resource_name);

  printf "Added budget named '%s'.\n", $created_campaign_budget->{name};

  return $created_campaign_budget;
}

# Gets a campaign budget.
sub get_campaign_buget {
  my ($google_ads_client, $customer_id, $campaign_budget_resource_name) = @_;

  my $search_query =
    "SELECT campaign_budget.id, campaign_budget.name, " .
    "campaign_budget.resource_name FROM campaign_budget " .
    "WHERE campaign_budget.resource_name = '$campaign_budget_resource_name'";

  my $search_response = $google_ads_client->GoogleAdsService()->search({
    customerId => $customer_id,
    query      => $search_query,
    pageSize   => PAGE_SIZE
  });

  return $search_response->{results}[0]{campaignBudget};
}

# Creates a campaign.
sub create_campaign {
  my ($adwords_client, $budget_id) = @_;

  # Create a campaign.
  my $campaign = Google::Ads::AdWords::v201809::Campaign->new({
      name                   => "Interplanetary Cruise #" . uniqid(),
      advertisingChannelType => "SEARCH",
      # Recommendation: Set the campaign to PAUSED when creating it to stop
      # the ads from immediately serving. Set to ENABLED once you've added
      # targeting and the ads are ready to serve.
      status => "PAUSED",
      # Set bidding strategy.
      biddingStrategyConfiguration =>
        Google::Ads::AdWords::v201809::BiddingStrategyConfiguration->new({
          biddingStrategyType => "MANUAL_CPC"
        }
        ),
      # Set the budget.
      budget =>
        Google::Ads::AdWords::v201809::Budget->new({budgetId => $budget_id}),
      # Set the campaign network options.
      networkSetting => Google::Ads::AdWords::v201809::NetworkSetting->new({
          targetGoogleSearch  => 1,
          targetSearchNetwork => 1
        }
      ),
      # Optional: Set the start and end dates.
      startDate => strftime("%Y%m%d", localtime(time + 60 * 60 * 24)),
      endDate   => strftime("%Y%m%d", localtime(time + 60 * 60 * 24 * 365)),
    });

  # Create a campaign operation.
  my $campaign_operation =
    Google::Ads::AdWords::v201809::CampaignOperation->new({
      operator => "ADD",
      operand  => $campaign
    });

  # Create the campaign on the server and print out its information.
  my $created_campaign = $adwords_client->CampaignService()
    ->mutate({operations => [$campaign_operation]})->get_value();

  printf
    "Campaign with ID %d and name '%s' was created.\n",
    $created_campaign->get_id(),
    $created_campaign->get_name();

  return $created_campaign;
}

# Creates an ad group.
sub create_ad_group {
  my ($adwords_client, $campaign_id) = @_;

  # Create an ad group.
  my $ad_group = Google::Ads::AdWords::v201809::AdGroup->new({
      campaignId => $campaign_id,
      name       => "Earth to Mars Cruise #" . uniqid(),
      # Set ad group bids.
      biddingStrategyConfiguration =>
        Google::Ads::AdWords::v201809::BiddingStrategyConfiguration->new(
        bids => [
          Google::Ads::AdWords::v201809::CpcBid->new({
              bid => Google::Ads::AdWords::v201809::Money->new({
                  microAmount => 10000000
                }
              ),
            }
          ),
        ]
        ),
      # Optional: Set the rotation mode.
      adGroupAdRotationMode =>
        Google::Ads::AdWords::v201809::AdGroupAdRotationMode->new({
          adRotationMode => "OPTIMIZE"
        }
        ),
      status => "ENABLED"
    });

  # Create an ad group operation.
  my $ad_group_operation = Google::Ads::AdWords::v201809::AdGroupOperation->new(
    {
      operator => "ADD",
      operand  => $ad_group
    });

  # Create the ad group on the server and print out its information.
  my $created_ad_group = $adwords_client->AdGroupService()
    ->mutate({operations => [$ad_group_operation]})->get_value();

  printf
    "Ad group with ID %d and name '%s' was created.\n",
    $created_ad_group->get_id(),
    $created_ad_group->get_name();

  return $created_ad_group;
}

# Creates text ads.
sub create_text_ads {
  my ($adwords_client, $ad_group_id) = @_;

  my $operations = [];
  for (my $i = 0 ; $i < NUMBER_OF_ADS ; $i++) {
    # Create an expanded text ad.
    my $expanded_text_ad = Google::Ads::AdWords::v201809::ExpandedTextAd->new({
        headlinePart1 => sprintf("Cruise #%s to Mars", uniqid()),
        headlinePart2 => "Best Space Cruise Line",
        headlinePart3 => "For Your Loved Ones",
        description   => "Buy your tickets now!",
        description2  => "Discount ends soon",
        finalUrls     => ["http://www.example.com"]});

    # Create ad group ad.
    my $ad_group_ad = Google::Ads::AdWords::v201809::AdGroupAd->new({
      adGroupId => $ad_group_id,
      ad        => $expanded_text_ad,
      # Optional: Set additional settings.
      status => "PAUSED"
    });

    # Create ad group ad operation and add it to the list.
    my $ad_group_ad_operation =
      Google::Ads::AdWords::v201809::AdGroupAdOperation->new({
        operator => "ADD",
        operand  => $ad_group_ad
      });
    push @$operations, $ad_group_ad_operation;
  }

  # Create the ad group ads on the server and print out their information.
  my $result =
    $adwords_client->AdGroupAdService()->mutate({operations => $operations});
  foreach my $ad_group_ad (@{$result->get_value()}) {
    my $ad = $ad_group_ad->get_ad();
    printf "Expanded text ad with ID %d and headline '%s - %s%s' " .
      "was created.\n",
      $ad->get_id(),
      $ad->get_headlinePart1(),
      $ad->get_headlinePart2(),
      $ad->get_headlinePart3() ? " - " : $ad->get_headlinePart3();
  }
}

# Creates keywords.
sub create_keywords {
  my ($adwords_client, $ad_group_id) = @_;

  my $operations = [];
  foreach my $keyword_text (@{+KEYWORDS_TO_ADD}) {
    # Create a keyword.
    my $keyword = Google::Ads::AdWords::v201809::Keyword->new({
      text      => $keyword_text,
      matchType => "BROAD"
    });

    # Create a biddable ad group criterion.
    my $ad_group_criterion =
      Google::Ads::AdWords::v201809::BiddableAdGroupCriterion->new({
        adGroupId => $ad_group_id,
        criterion => $keyword,
        # Optional: Set the user status.
        userStatus => "PAUSED",
        # Optional: Set the keyword destination url.
        finalUrls => [
          Google::Ads::AdWords::v201809::UrlList->new({
              urls => [
                "http://www.example.com/mars/cruise/?kw=" .
                  uri_escape($keyword_text)]})]});

    # Create an ad group criterion operation and add it to the list.
    my $ad_group_criterion_operation =
      Google::Ads::AdWords::v201809::AdGroupCriterionOperation->new({
        operator => "ADD",
        operand  => $ad_group_criterion
      });
    push @$operations, $ad_group_criterion_operation;
  }

  # Create the keywords on the server and print out their information.
  my $result =
    $adwords_client->AdGroupCriterionService()
    ->mutate({operations => $operations});
  foreach my $ad_group_criterion (@{$result->get_value()}) {
    my $keyword = $ad_group_criterion->get_criterion();
    printf "Keyword with ad group ID %d, keyword ID %d, text '%s' and " .
      "match type '%s' was created.\n",
      $ad_group_criterion->get_adGroupId(),
      $keyword->get_id(),
      $keyword->get_text(),
      $keyword->get_matchType();
  }
}

return 1;

=pod

=head1 NAME

create_complete_campaign_both_apis_phase_1

=head1 DESCRIPTION

This code example is the second in a series of code examples that show how to create
a search campaign using the AdWords API, and then migrate it to the Google Ads API
one functionality at a time. See other examples in this directory for code examples
in various stages of migration.

In this code example, the functionality to create a campaign budget has been migrated
to the Google Ads API. The remaining functionalities - creating a campaign, creating an
ad group, creating expanded text ads and creating keywords - are using the AdWords API.

=cut

