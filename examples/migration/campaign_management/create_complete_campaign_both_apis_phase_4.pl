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
# This code example is the fifth in a series of code examples that show how to
# create a search campaign using the AdWords API, and then migrate it to the
# Google Ads API one functionality at a time. See other examples in this directory
# for code examples in various stages of migration.
#
# In this code example, the functionalities to create a campaign budget, a search
# campaign, an ad group and expanded text ads have been migrated to the Google Ads
# API. The only remaining functionality using the AdWords API is creating keywords.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../../lib";
use Google::Ads::GoogleAds::V9::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V9::Resources::Campaign;
use Google::Ads::GoogleAds::V9::Resources::NetworkSettings;
use Google::Ads::GoogleAds::V9::Resources::AdGroup;
use Google::Ads::GoogleAds::V9::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V9::Resources::Ad;
use Google::Ads::GoogleAds::V9::Common::ManualCpc;
use Google::Ads::GoogleAds::V9::Common::ExpandedTextAdInfo;
use Google::Ads::GoogleAds::V9::Enums::BudgetDeliveryMethodEnum qw(STANDARD);
use Google::Ads::GoogleAds::V9::Enums::AdvertisingChannelTypeEnum qw(SEARCH);
use Google::Ads::GoogleAds::V9::Enums::CampaignStatusEnum;
use Google::Ads::GoogleAds::V9::Enums::AdGroupStatusEnum qw(ENABLED);
use Google::Ads::GoogleAds::V9::Enums::AdGroupTypeEnum qw(SEARCH_STANDARD);
use Google::Ads::GoogleAds::V9::Enums::AdGroupAdStatusEnum;
use
  Google::Ads::GoogleAds::V9::Services::CampaignBudgetService::CampaignBudgetOperation;
use Google::Ads::GoogleAds::V9::Services::CampaignService::CampaignOperation;
use Google::Ads::GoogleAds::V9::Services::AdGroupService::AdGroupOperation;
use Google::Ads::GoogleAds::V9::Services::AdGroupAdService::AdGroupAdOperation;
use Google::Ads::AdWords::v201809::Keyword;
use Google::Ads::AdWords::v201809::BiddableAdGroupCriterion;
use Google::Ads::AdWords::v201809::UrlList;
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

sub create_complete_campaign_both_apis_phase_4 {
  my ($adwords_client, $google_ads_client, $customer_id) = @_;

  my $campaign_budget =
    create_campaign_budget($google_ads_client, $customer_id);
  my $campaign =
    create_campaign($google_ads_client, $customer_id, $campaign_budget);
  my $ad_group = create_ad_group($google_ads_client, $customer_id, $campaign);
  create_text_ads($google_ads_client, $customer_id, $ad_group);
  create_keywords($adwords_client, $ad_group->{id});
}

# Creates a campaign budget.
sub create_campaign_budget {
  my ($google_ads_client, $customer_id) = @_;

  # Create a campaign budget.
  my $campaign_budget =
    Google::Ads::GoogleAds::V9::Resources::CampaignBudget->new({
      name           => "Interplanetary Cruise Budget #" . uniqid(),
      deliveryMethod => STANDARD,
      amountMicros   => 500000
    });

  # Create a campaign budget operation.
  my $campaign_budget_operation =
    Google::Ads::GoogleAds::V9::Services::CampaignBudgetService::CampaignBudgetOperation
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
  my ($google_ads_client, $customer_id, $campaign_budget) = @_;

  # Create a campaign.
  my $campaign = Google::Ads::GoogleAds::V9::Resources::Campaign->new({
      name                   => "Interplanetary Cruise #" . uniqid(),
      advertisingChannelType => SEARCH,
      # Recommendation: Set the campaign to PAUSED when creating it to stop
      # the ads from immediately serving. Set to ENABLED once you've added
      # targeting and the ads are ready to serve.
      status => Google::Ads::GoogleAds::V9::Enums::CampaignStatusEnum::PAUSED,
      # Set the bidding strategy and budget.
      manualCpc      => Google::Ads::GoogleAds::V9::Common::ManualCpc->new(),
      campaignBudget => $campaign_budget->{resourceName},
      # Set the campaign network options.
      networkSettings =>
        Google::Ads::GoogleAds::V9::Resources::NetworkSettings->new({
          targetGoogleSearch         => "true",
          targetSearchNetwork        => "true",
          targetContentNetwork       => "false",
          targetPartnerSearchNetwork => "false"
        }
        ),
      # Optional: Set the start and end dates.
      startDate => strftime("%Y%m%d", localtime(time + 60 * 60 * 24)),
      endDate   => strftime("%Y%m%d", localtime(time + 60 * 60 * 24 * 365)),
    });

  # Create a campaign operation.
  my $campaign_operation =
    Google::Ads::GoogleAds::V9::Services::CampaignService::CampaignOperation->
    new({create => $campaign});

  # Issue a mutate request to add the campaign.
  my $campaigns_response = $google_ads_client->CampaignService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_operation]});

  my $campaign_resource_name =
    $campaigns_response->{results}[0]{resourceName};

  my $created_campaign =
    get_campaign($google_ads_client, $customer_id, $campaign_resource_name);

  printf "Added campaign named '%s'.\n", $created_campaign->{name};

  return $created_campaign;
}

# Gets a campaign.
sub get_campaign {
  my ($google_ads_client, $customer_id, $campaign_resource_name) = @_;

  my $search_query =
    "SELECT campaign.id, campaign.name, campaign.resource_name " .
    "FROM campaign " .
    "WHERE campaign.resource_name = '$campaign_resource_name'";

  my $search_response = $google_ads_client->GoogleAdsService()->search({
    customerId => $customer_id,
    query      => $search_query,
    pageSize   => PAGE_SIZE
  });

  return $search_response->{results}[0]{campaign};
}

# Creates an ad group.
sub create_ad_group {
  my ($google_ads_client, $customer_id, $campaign) = @_;

  # Construct an ad group and set an optional CPC value.
  my $ad_group = Google::Ads::GoogleAds::V9::Resources::AdGroup->new({
    name         => "Earth to Mars Cruise #" . uniqid(),
    campaign     => $campaign->{resourceName},
    status       => ENABLED,
    type         => SEARCH_STANDARD,
    cpcBidMicros => 10000000
  });

  # Create an ad group operation.
  my $ad_group_operation =
    Google::Ads::GoogleAds::V9::Services::AdGroupService::AdGroupOperation->
    new({create => $ad_group});

  # Issue a mutate request to add the ad group.
  my $ad_groups_response = $google_ads_client->AdGroupService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_operation]});

  my $ad_group_resource_name = $ad_groups_response->{results}[0]{resourceName};

  my $created_ad_group =
    get_ad_group($google_ads_client, $customer_id, $ad_group_resource_name);

  printf "Added ad group named '%s'.\n", $created_ad_group->{name};

  return $created_ad_group;
}

# Gets an ad group.
sub get_ad_group {
  my ($google_ads_client, $customer_id, $ad_group_resource_name) = @_;

  my $search_query =
    "SELECT ad_group.id, ad_group.name, ad_group.resource_name " .
    "FROM ad_group " .
    "WHERE ad_group.resource_name = '$ad_group_resource_name'";

  my $search_response = $google_ads_client->GoogleAdsService()->search({
    customerId => $customer_id,
    query      => $search_query,
    pageSize   => PAGE_SIZE
  });

  return $search_response->{results}[0]{adGroup};
}

# Creates text ads.
sub create_text_ads {
  my ($google_ads_client, $customer_id, $ad_group) = @_;

  my $operations = [];
  for (my $i = 0 ; $i < NUMBER_OF_ADS ; $i++) {
    # Create an expanded text ad info.
    my $expanded_text_ad_info =
      Google::Ads::GoogleAds::V9::Common::ExpandedTextAdInfo->new({
        headlinePart1 => "Cruise to Mars #" . uniqid(),
        headlinePart2 => "Best Space Cruise Line",
        description   => "Buy your tickets now!"
      });

    # Create an ad group ad to hold the above ad.
    my $ad_group_ad = Google::Ads::GoogleAds::V9::Resources::AdGroupAd->new({
        adGroup => $ad_group->{resourceName},
        status  =>
          Google::Ads::GoogleAds::V9::Enums::AdGroupAdStatusEnum::PAUSED,
        ad => Google::Ads::GoogleAds::V9::Resources::Ad->new({
            expandedTextAd => $expanded_text_ad_info,
            finalUrls      => ["http://www.example.com"]})});

    # Create an ad group ad operation and add it to the operations array.
    my $ad_group_ad_operation =
      Google::Ads::GoogleAds::V9::Services::AdGroupAdService::AdGroupAdOperation
      ->new({
        create => $ad_group_ad
      });
    push @$operations, $ad_group_ad_operation;
  }

  # Issue a mutate request to add the ad group ads.
  my $ad_group_ads_response = $google_ads_client->AdGroupAdService()
    ->mutate({customerId => $customer_id, operations => $operations});

  my $new_ad_resource_names = [];
  foreach my $result (@{$ad_group_ads_response->{results}}) {
    push @$new_ad_resource_names, $result->{resourceName};
  }

  my $new_ads =
    get_ads($google_ads_client, $customer_id, $new_ad_resource_names);
  foreach my $new_ad (@$new_ads) {
    printf "Created expanded text ad with ID %d, status '%s' " .
      "and headline '%s - %s'.\n",
      $new_ad->{ad}{id}, $new_ad->{status},
      $new_ad->{ad}{expandedTextAd}{headlinePart1},
      $new_ad->{ad}{expandedTextAd}{headlinePart2};
  }
}

# Gets an array of ads by their resource names.
sub get_ads {
  my ($google_ads_client, $customer_id, $ad_resource_names) = @_;

  my $resource_names =
    join(",", map { sprintf "'%s'", $_ } @$ad_resource_names);

  my $search_query =
    "SELECT ad_group_ad.ad.id, " .
    "ad_group_ad.ad.expanded_text_ad.headline_part1, " .
    "ad_group_ad.ad.expanded_text_ad.headline_part2, " .
    "ad_group_ad.status, ad_group_ad.ad.final_urls, " .
    "ad_group_ad.resource_name " . "FROM ad_group_ad " .
    "WHERE ad_group_ad.resource_name in ($resource_names)";

  my $search_response = $google_ads_client->GoogleAdsService()->search({
    customerId => $customer_id,
    query      => $search_query,
    pageSize   => PAGE_SIZE
  });

  my $ads = [];
  foreach my $result (@{$search_response->{results}}) {
    push @$ads, $result->{adGroupAd};
  }

  return $ads;
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

create_complete_campaign_both_apis_phase_4

=head1 DESCRIPTION

This code example is the fifth in a series of code examples that show how to create
a search campaign using the AdWords API, and then migrate it to the Google Ads API
one functionality at a time. See other examples in this directory for code examples
in various stages of migration.

In this code example, the functionalities to create a campaign budget, a search campaign,
an ad group and expanded text ads have been migrated to the Google Ads API. The only
remaining functionality using the AdWords API is creating keywords.

=cut

