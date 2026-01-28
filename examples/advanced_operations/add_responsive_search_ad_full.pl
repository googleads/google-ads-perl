#!/usr/bin/perl -w
#
# Copyright 2024, Google LLC
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
# This example shows how to create a complete Responsive Search ad.
# Includes creation of: budget, campaign, ad group, ad group ad, keywords,
# and geo targeting. More details on Responsive Search ads can be found here:
# https://support.google.com/google-ads/answer/7684791

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::Campaign;
use Google::Ads::GoogleAds::V23::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V23::Resources::CampaignCriterion;
use Google::Ads::GoogleAds::V23::Resources::CustomizerAttribute;
use Google::Ads::GoogleAds::V23::Resources::CustomerCustomizer;
use Google::Ads::GoogleAds::V23::Resources::Ad;
use Google::Ads::GoogleAds::V23::Resources::AdGroup;
use Google::Ads::GoogleAds::V23::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V23::Resources::AdGroupCriterion;
use Google::Ads::GoogleAds::V23::Resources::NetworkSettings;
use Google::Ads::GoogleAds::V23::Common::AdTextAsset;
use Google::Ads::GoogleAds::V23::Common::CustomizerValue;
use Google::Ads::GoogleAds::V23::Common::ImageDimension;
use Google::Ads::GoogleAds::V23::Common::KeywordInfo;
use Google::Ads::GoogleAds::V23::Common::LocationInfo;
use Google::Ads::GoogleAds::V23::Common::ResponsiveSearchAdInfo;
use Google::Ads::GoogleAds::V23::Common::TargetSpend;
use Google::Ads::GoogleAds::V23::Enums::AdvertisingChannelTypeEnum qw(SEARCH);
use Google::Ads::GoogleAds::V23::Enums::BudgetDeliveryMethodEnum   qw(STANDARD);
use Google::Ads::GoogleAds::V23::Enums::CustomizerAttributeTypeEnum qw(PRICE);
use Google::Ads::GoogleAds::V23::Enums::AdGroupAdStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::AdGroupCriterionStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::AdGroupStatusEnum;
use Google::Ads::GoogleAds::V23::Enums::AdGroupTypeEnum    qw(SEARCH_STANDARD);
use Google::Ads::GoogleAds::V23::Enums::AssetTypeEnum      qw(IMAGE);
use Google::Ads::GoogleAds::V23::Enums::CampaignStatusEnum qw(PAUSED);
use Google::Ads::GoogleAds::V23::Enums::KeywordMatchTypeEnum
  qw(BROAD EXACT PHRASE);
use Google::Ads::GoogleAds::V23::Enums::MimeTypeEnum             qw(IMAGE_PNG);
use Google::Ads::GoogleAds::V23::Enums::ServedAssetFieldTypeEnum qw(HEADLINE_1);
use Google::Ads::GoogleAds::V23::Services::AdGroupService::AdGroupOperation;
use Google::Ads::GoogleAds::V23::Services::AdGroupAdService::AdGroupAdOperation;
use
  Google::Ads::GoogleAds::V23::Services::AdGroupCriterionService::AdGroupCriterionOperation;
use Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation;
use
  Google::Ads::GoogleAds::V23::Services::CampaignBudgetService::CampaignBudgetOperation;
use
  Google::Ads::GoogleAds::V23::Services::CampaignCriterionService::CampaignCriterionOperation;
use Google::Ads::GoogleAds::V23::Services::CampaignService::CampaignOperation;
use
  Google::Ads::GoogleAds::V23::Services::CustomizerAttributeService::CustomizerAttributeOperation;
use
  Google::Ads::GoogleAds::V23::Services::CustomerCustomizerService::CustomerCustomizerOperation;
use
  Google::Ads::GoogleAds::V23::Services::GeoTargetConstantService::LocationNames;
use Google::Ads::GoogleAds::V23::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);

# Keywords from the user.
use constant KEYWORD_TEXT_EXACT  => "example of exact match";
use constant KEYWORD_TEXT_PHRASE => "example of phrase match";
use constant KEYWORD_TEXT_BROAD  => "example of broad match";

# Geo targeting from the user.
use constant GEO_LOCATION_1 => "Buenos Aires";
use constant GEO_LOCATION_2 => "San Isidro";
use constant GEO_LOCATION_3 => "Mar del Plata";

# LOCALE and COUNTRY_CODE are used for geo targeting.
# LOCALE is using ISO 639-1 format. If an invalid LOCALE is given,
# 'es' is used by default.
use constant LOCALE => "es";
# A list of country codes can be referenced here:
# https://developers.google.com/google-ads/api/reference/data/geotargets
use constant COUNTRY_CODE => "AR";

use constant IMAGE_URL => "https://gaagl.page.link/bjYi";

sub add_responsive_search_ad_full {
  my ($api_client, $customer_id, $customizer_attribute_name) = @_;

  # If a customizer attribute name is provided, create the customizer
  # attribute and link it to the customer.
  # For more information on customizer attributes, visit:
  # https://developers.google.com/google-ads/api/docs/ads/customize-responsive-search-ads
  if (defined $customizer_attribute_name) {
    my $customizer_attribute_resource_name =
      create_customizer_attribute($api_client, $customer_id,
      $customizer_attribute_name);

    link_customizer_attribute_to_customer($api_client, $customer_id,
      $customizer_attribute_resource_name);
  }

  # Create a budget, which can be shared by multiple campaigns.
  my $campaign_budget = create_campaign_budget($api_client, $customer_id);

  # Create a search campaign.
  my $campaign_resource_name =
    create_campaign($api_client, $customer_id, $campaign_budget);

  # Create an empty ad group.
  my $ad_group_resource_name =
    create_ad_group($api_client, $customer_id, $campaign_resource_name);

  # Create a responsive search ad within the ad group we just created.
  create_ad_group_ad($api_client, $customer_id, $ad_group_resource_name,
    $customizer_attribute_name);

  # Create 3 keywords of match type EXACT, PHRASE, and BROAD, and add them
  # as criteria on our ad group.
  add_keywords($api_client, $customer_id, $ad_group_resource_name);

  # Create geo targets and add them as criteria on our campaign.
  add_geo_targeting($api_client, $customer_id, $campaign_resource_name);

  return 1;
}

# Creates a customizer attribute with the given customizer attribute name.
sub create_customizer_attribute {
  my ($api_client, $customer_id, $customizer_attribute_name) = @_;

  my $customizer_attribute =
    Google::Ads::GoogleAds::V23::Resources::CustomizerAttribute->new({
      name => $customizer_attribute_name,
      # Specify the type to be 'PRICE' so that we can dynamically customize the part
      # of the ad's description that is a price of a product/service we advertise.
      type => PRICE
    });

  # Create a customizer attribute operation for creating a customizer attribute.
  my $operation =
    Google::Ads::GoogleAds::V23::Services::CustomizerAttributeService::CustomizerAttributeOperation
    ->new({
      create => $customizer_attribute
    });

  my $response = $api_client->CustomizerAttributeService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});
  my $resource_name =
    $response->{results}[0]{resourceName};
  printf "Added a customizer attribute with resource name '%s'.\n",
    $resource_name;

  return $resource_name;
}

# Links the customizer attribute to the customer.
sub link_customizer_attribute_to_customer {
  my ($api_client, $customer_id, $customizer_attribute_resource_name) = @_;

  # Create a customer customizer with the value to be used in the responsive search ad.
  my $customer_customizer =
    Google::Ads::GoogleAds::V23::Resources::CustomerCustomizer->new({
      customizerAttribute => $customizer_attribute_resource_name,
      # Specify '100USD' as a text value. The ad customizer will dynamically replace
      # the placeholder with this value when the ad serves.
      value => Google::Ads::GoogleAds::V23::Common::CustomizerValue->new({
          type        => PRICE,
          stringValue => "100USD"
        })});

  # Create a customer customizer operation.
  my $operation =
    Google::Ads::GoogleAds::V23::Services::CustomerCustomizerService::CustomerCustomizerOperation
    ->new({
      create => $customer_customizer
    });

  # Issue a mutate request to add the customer customizer and print its information.
  my $response = $api_client->CustomerCustomizerService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});
  printf "Added a customer customizer with resource name '%s'.\n",
    $response->{results}[0]{resourceName};
}

# Creates an AdTextAsset.
sub create_ad_text_asset {
  my ($api_client, $text, $pinned_field) = @_;

  my $ad_text_asset = Google::Ads::GoogleAds::V23::Common::AdTextAsset->new({
    text => $text
  });

  if (defined $pinned_field) {
    $ad_text_asset->{pinnedField} = $pinned_field;
  }

  return $ad_text_asset;
}

# Creates an AdTextAsset with a customizer in the text.
sub create_ad_text_asset_with_customizer {
  my ($api_client, $customizer_attribute_resource_name) = @_;

  my $ad_text_asset = create_ad_text_asset($api_client,
    "Just {CUSTOMIZER.$customizer_attribute_resource_name:10USD}");

  return $ad_text_asset;
}

# Creates a campaign budget.
sub create_campaign_budget {
  my ($api_client, $customer_id) = @_;

  # Create a campaign budget.
  my $campaign_budget =
    Google::Ads::GoogleAds::V23::Resources::CampaignBudget->new({
      name           => "Campaign budget " . uniqid(),
      amountMicros   => 50000000,
      deliveryMethod => STANDARD
    });

  # Create a campaign budget operation.
  my $campaign_budget_operation =
    Google::Ads::GoogleAds::V23::Services::CampaignBudgetService::CampaignBudgetOperation
    ->new({
      create => $campaign_budget
    });

  # Issue a mutate request to add the campaign budget.
  my $campaign_budgets_response = $api_client->CampaignBudgetService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_budget_operation]});

  my $campaign_budget_resource_name =
    $campaign_budgets_response->{results}[0]{resourceName};

  return $campaign_budget_resource_name;
}

# Creates a campaign.
sub create_campaign {
  my ($api_client, $customer_id, $campaign_budget) = @_;

  # Create a campaign.
  my $campaign = Google::Ads::GoogleAds::V23::Resources::Campaign->new({
      name           => "Testing RSA via API " . uniqid(),
      campaignBudget => $campaign_budget,
      # Recommendation: Set the campaign to PAUSED when creating it to prevent
      # the ads from immediately serving. Set to ENABLED once you've added
      # targeting and the ads are ready to serve.
      status                 => PAUSED,
      advertisingChannelType => SEARCH,
      # Set the bidding strategy and budget.
      # The bidding strategy for Maximize Clicks is TargetSpend.
      # The target_spend_micros is deprecated so don't put any value.
      # See other bidding strategies you can select in the link below.
      # https://developers.google.com/google-ads/api/reference/rpc/latest/Campaign#campaign_bidding_strategy
      targetSpend => Google::Ads::GoogleAds::V23::Common::TargetSpend->new(),
      # Set the campaign network options
      networkSettings =>
        Google::Ads::GoogleAds::V23::Resources::NetworkSettings->new({
          targetGoogleSearch  => "true",
          targetSearchNetwork => "true",
          # Enable Display Expansion on Search campaigns. See
          # https://support.google.com/google-ads/answer/7193800 to learn more.
          targetContentNetwork       => "true",
          targetPartnerSearchNetwork => "false"
        }
        ),
      # Optional: Set the start datetime. The campaign starts tomorrow.
      # startDateTime => strftime("%Y%m%d 00:00:00", localtime(time + 60 * 60 * 24)),
      # Optional: Set the end datetime. The campaign runs for 30 days.
      # endDateTime => strftime("%Y%m%d 23:59:59", localtime(time + 60 * 60 * 24 * 30)),
    });

  # Create a campaign operation.
  my $campaign_operation =
    Google::Ads::GoogleAds::V23::Services::CampaignService::CampaignOperation->
    new({
      create => $campaign
    });

  # Issue a mutate request to add the campaign.
  my $campaigns_response = $api_client->CampaignService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_operation]});

  my $resource_name =
    $campaigns_response->{results}[0]{resourceName};
  printf "Created App campaign with resource name: '%s'.\n", $resource_name;

  return $resource_name;
}

# Creates an ad group.
sub create_ad_group {
  my ($api_client, $customer_id, $campaign_resource_name) = @_;

  # Create an ad group, setting an optional CPC value.
  my $ad_group = Google::Ads::GoogleAds::V23::Resources::AdGroup->new({
    name   => "Testing RSA via API " . uniqid(),
    status => Google::Ads::GoogleAds::V23::Enums::AdGroupStatusEnum::ENABLED,
    campaign => $campaign_resource_name,
    type     => SEARCH_STANDARD,
    # If you want to set up a max CPC bid, uncomment the line below.
    # cpcBidMicros => 10000000
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

# Creates an ad group ad.
sub create_ad_group_ad {
  my ($api_client, $customer_id, $ad_group_resource_name,
    $customizer_attribute_name)
    = @_;

  # Set a pinning to always choose this asset for HEADLINE_1. Pinning is optional; if no
  # pinning is set, then headlines and descriptions will be rotated and the ones that perform
  # best will be used more often.
  my $pinned_headline =
    create_ad_text_asset($api_client, "Headline 1 testing", HEADLINE_1);

  my $ad_group_ad = Google::Ads::GoogleAds::V23::Resources::AdGroupAd->new({
      adGroup => $ad_group_resource_name,
      status  =>
        Google::Ads::GoogleAds::V23::Enums::AdGroupAdStatusEnum::ENABLED,
      ad => Google::Ads::GoogleAds::V23::Resources::Ad->new({
          # Set responsive search ad info.
          # https://developers.google.com/google-ads/api/reference/rpc/latest/ResponsiveSearchAdInfo
          responsiveSearchAd =>
            Google::Ads::GoogleAds::V23::Common::ResponsiveSearchAdInfo->new({
              headlines => [
                $pinned_headline,
                create_ad_text_asset($api_client, "Headline 2 testing"),
                create_ad_text_asset($api_client, "Headline 3 testing"),
              ],
              descriptions => [
                create_ad_text_asset($api_client, "Desc 1 testing"),
                defined $customizer_attribute_name
                ? create_ad_text_asset_with_customizer($api_client,
                  $customizer_attribute_name)
                : create_ad_text_asset($api_client, "Desc 2 testing"),
              ],
              # First and second part of text that can be appended to the URL in the ad.
              # If you use the examples below, the ad will show
              # https://www.example.com/all-inclusive/deals
              path1 => "all-inclusive",
              path2 => "deals"
            }
            ),
          finalUrls => ["https://www.example.com"]})});

  # Create an ad group ad operation.
  my $operation =
    Google::Ads::GoogleAds::V23::Services::AdGroupAdService::AdGroupAdOperation
    ->new({
      create => $ad_group_ad
    });

  # Issue a mutate request to add the ad group ad and print its information.
  my $response = $api_client->AdGroupAdService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});
  printf "Created responsive search ad with resource name '%s'.\n",
    $response->{results}[0]{resourceName};
}

# Creates keywords of 3 keyword match types: EXACT, PHRASE, and BROAD.
# EXACT: ads may show on searches that ARE the same meaning as your keyword.
# PHRASE: ads may show on searches that INCLUDE the meaning of your keyword.
# BROAD: ads may show on searches that RELATE to your keyword.
# For smart bidding, BROAD is the recommended one.
sub add_keywords {
  my ($api_client, $customer_id, $ad_group_resource_name) = @_;

  my $operations = [];

  # Create a hash of keyword match types to keyword text to simplify ad group
  # criteria construction.
  my $keywords = {
    EXACT()  => KEYWORD_TEXT_EXACT,
    BROAD()  => KEYWORD_TEXT_BROAD,
    PHRASE() => KEYWORD_TEXT_PHRASE,
  };

  foreach my $keyword (keys %$keywords) {
    my $keyword_info = Google::Ads::GoogleAds::V23::Common::KeywordInfo->new({
      text      => $keywords->{$keyword},
      matchType => $keyword,
    });

    my $ad_group_criterion =
      Google::Ads::GoogleAds::V23::Resources::AdGroupCriterion->new({
        adGroup => $ad_group_resource_name,
        status  =>
          Google::Ads::GoogleAds::V23::Enums::AdGroupCriterionStatusEnum::ENABLED,
        keyword => $keyword_info,
        # Uncomment the below line if you want to change this keyword to a negative target.
        # negative => "true",

        # Optional repeated field.
        # finalUrls => ["https://www.example.com"],
      });

    my $ad_group_criterion_operation =
      Google::Ads::GoogleAds::V23::Services::AdGroupCriterionService::AdGroupCriterionOperation
      ->new({create => $ad_group_criterion});

    push @$operations, $ad_group_criterion_operation;
  }

  my $response = $api_client->AdGroupCriterionService()->mutate({
    customerId => $customer_id,
    operations => $operations
  });

  foreach my $result (@{$response->{results}}) {
    printf "Created keyword with resource name: '%s'.\n",
      $result->{resourceName};
  }
}

# Creates geo targets.
sub add_geo_targeting {
  my ($api_client, $customer_id, $campaign_resource_name) = @_;

  my $suggest_response = $api_client->GeoTargetConstantService()->suggest({
      locale        => LOCALE,
      countryCode   => COUNTRY_CODE,
      locationNames =>
        Google::Ads::GoogleAds::V23::Services::GeoTargetConstantService::LocationNames
        ->new({
          names => [GEO_LOCATION_1, GEO_LOCATION_2, GEO_LOCATION_3]})});

  my $operations = [];
  foreach my $geo_target_constant_suggestion (
    @{$suggest_response->{geoTargetConstantSuggestions}})
  {
    printf "geo target constant: '%s' is found in locale '%s' with reach %d" .
      " for the search term '%s'.\n",
      $geo_target_constant_suggestion->{geoTargetConstant}{resourceName},
      $geo_target_constant_suggestion->{locale},
      $geo_target_constant_suggestion->{reach},
      $geo_target_constant_suggestion->{searchTerm};

    # Create the campaign criterion for location targeting.
    my $campaign_criterion =
      Google::Ads::GoogleAds::V23::Resources::CampaignCriterion->new({
        location => Google::Ads::GoogleAds::V23::Common::LocationInfo->new({
            geoTargetConstant =>
              $geo_target_constant_suggestion->{geoTargetConstant}{resourceName}
          }
        ),
        campaign => $campaign_resource_name
      });

    push @$operations,
      Google::Ads::GoogleAds::V23::Services::CampaignCriterionService::CampaignCriterionOperation
      ->new({
        create => $campaign_criterion
      });
  }

  # Return if operations is empty.
  if (scalar @$operations == 0) {
    return;
  }
  my $campaign_criterion_response =
    $api_client->CampaignCriterionService()->mutate({
      customerId => $customer_id,
      operations => $operations
    });
  my $campaign_criterion_results = $campaign_criterion_response->{results};
  printf "Added %d campaign criteria:\n", scalar @$campaign_criterion_results;

  foreach my $campaign_criterion_result (@$campaign_criterion_results) {
    printf "\t%s\n", $campaign_criterion_result->{resourceName};
  }
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

my $customer_id;
my $customizer_attribute_name;

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s"               => \$customer_id,
  "customizer_attribute_name=s" => \$customizer_attribute_name,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id);

# Call the example.
add_responsive_search_ad_full($api_client, $customer_id =~ s/-//gr,
  $customizer_attribute_name);

=pod

=head1 NAME

add_responsive_search_ad_full

=head1 DESCRIPTION

This example shows how to create a complete Responsive Search ad.
Includes creation of: budget, campaign, ad group, ad group ad, keywords,
and geo targeting. More details on Responsive Search ads can be found here:
https://support.google.com/google-ads/answer/7684791

=head1 SYNOPSIS

add_responsive_search_ad_full.pl [options]

    -help                           Show the help message.
    -customer_id                    The Google Ads customer ID.
    -customizer_attribute_name      [optional] The name of the customizer attribute.

=cut
