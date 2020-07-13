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
# This example creates a keyword plan, which can be reused for retrieving
# forecast metrics and historic metrics.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V4::Resources::KeywordPlan;
use Google::Ads::GoogleAds::V4::Resources::KeywordPlanForecastPeriod;
use Google::Ads::GoogleAds::V4::Resources::KeywordPlanCampaign;
use Google::Ads::GoogleAds::V4::Resources::KeywordPlanGeoTarget;
use Google::Ads::GoogleAds::V4::Resources::KeywordPlanAdGroup;
use Google::Ads::GoogleAds::V4::Resources::KeywordPlanAdGroupKeyword;
use Google::Ads::GoogleAds::V4::Resources::KeywordPlanCampaignKeyword;
use Google::Ads::GoogleAds::V4::Enums::KeywordPlanForecastIntervalEnum
  qw(NEXT_QUARTER);
use Google::Ads::GoogleAds::V4::Enums::KeywordPlanNetworkEnum qw(GOOGLE_SEARCH);
use Google::Ads::GoogleAds::V4::Enums::KeywordMatchTypeEnum
  qw(BROAD PHRASE EXACT);
use
  Google::Ads::GoogleAds::V4::Services::KeywordPlanService::KeywordPlanOperation;
use
  Google::Ads::GoogleAds::V4::Services::KeywordPlanCampaignService::KeywordPlanCampaignOperation;
use
  Google::Ads::GoogleAds::V4::Services::KeywordPlanAdGroupService::KeywordPlanAdGroupOperation;
use
  Google::Ads::GoogleAds::V4::Services::KeywordPlanAdGroupKeywordService::KeywordPlanAdGroupKeywordOperation;
use
  Google::Ads::GoogleAds::V4::Services::KeywordPlanCampaignKeywordService::KeywordPlanCampaignKeywordOperation;
use Google::Ads::GoogleAds::V4::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
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

sub add_keyword_plan {
  my ($api_client, $customer_id) = @_;

  my $keyword_plan_resource = create_keyword_plan($api_client, $customer_id);

  my $keyword_plan_campaign_resource =
    create_keyword_plan_campaign($api_client, $customer_id,
    $keyword_plan_resource);

  my $keyword_plan_ad_group_resource =
    create_keyword_plan_ad_group($api_client, $customer_id,
    $keyword_plan_campaign_resource);

  create_keyword_plan_ad_group_keywords($api_client, $customer_id,
    $keyword_plan_ad_group_resource);

  create_keyword_plan_negative_campaign_keywords($api_client, $customer_id,
    $keyword_plan_campaign_resource);

  return 1;
}

# Creates a keyword plan.
sub create_keyword_plan {
  my ($api_client, $customer_id) = @_;

  # Create a keyword plan.
  my $keyword_plan = Google::Ads::GoogleAds::V4::Resources::KeywordPlan->new({
      name => "Keyword plan for traffic estimate #" . uniqid(),
      forecastPeriod =>
        Google::Ads::GoogleAds::V4::Resources::KeywordPlanForecastPeriod->new({
          dateInterval => NEXT_QUARTER
        })});

  # Create a keyword plan operation.
  my $keyword_plan_operation =
    Google::Ads::GoogleAds::V4::Services::KeywordPlanService::KeywordPlanOperation
    ->new({
      create => $keyword_plan
    });

  # Add the keyword plan.
  my $keyword_plan_resource = $api_client->KeywordPlanService()->mutate({
      customerId => $customer_id,
      operations => [$keyword_plan_operation]})->{results}[0]{resourceName};

  printf "Created keyword plan: '%s'.\n", $keyword_plan_resource;

  return $keyword_plan_resource;
}

# Creates the campaign for the keyword plan.
sub create_keyword_plan_campaign {
  my ($api_client, $customer_id, $keyword_plan_resource) = @_;

  # Create a keyword plan campaign.
  my $keyword_plan_campaign =
    Google::Ads::GoogleAds::V4::Resources::KeywordPlanCampaign->new({
      name               => "Keyword plan campaign #" . uniqid(),
      cpcBidMicros       => 1000000,
      keywordPlanNetwork => GOOGLE_SEARCH,
      keywordPlan        => $keyword_plan_resource
    });

  # See https://developers.google.com/adwords/api/docs/appendix/geotargeting
  # for the list of geo target IDs.
  $keyword_plan_campaign->{geoTargets} = [
    Google::Ads::GoogleAds::V4::Resources::KeywordPlanGeoTarget->new({
        # Geo target constant 2840 is for USA.
        geoTargetConstant =>
          Google::Ads::GoogleAds::V4::Utils::ResourceNames::geo_target_constant(
          2840)})];

  # See https://developers.google.com/adwords/api/docs/appendix/codes-formats#languages
  # for the list of language criteria IDs.
  $keyword_plan_campaign->{languageConstants} = [
    # Language criteria 1000 is for English.
    Google::Ads::GoogleAds::V4::Utils::ResourceNames::language_constant(1000)];

  # Create a keyword plan campaign operation
  my $keyword_plan_campaign_operation =
    Google::Ads::GoogleAds::V4::Services::KeywordPlanCampaignService::KeywordPlanCampaignOperation
    ->new({
      create => $keyword_plan_campaign
    });

  # Add the keyword plan campaign.
  my $keyword_plan_campaign_resource =
    $api_client->KeywordPlanCampaignService()->mutate({
      customerId => $customer_id,
      operations => [$keyword_plan_campaign_operation]}
  )->{results}[0]{resourceName};

  printf "Created campaign for keyword plan: '%s'.\n",
    $keyword_plan_campaign_resource;

  return $keyword_plan_campaign_resource;
}

# Creates the ad group for the keyword plan.
sub create_keyword_plan_ad_group {
  my ($api_client, $customer_id, $keyword_plan_campaign_resource) = @_;

  # Create a keyword plan ad group.
  my $keyword_plan_ad_group =
    Google::Ads::GoogleAds::V4::Resources::KeywordPlanAdGroup->new({
      name                => "Keyword plan ad group #" . uniqid(),
      cpcBidMicros        => 2500000,
      keywordPlanCampaign => $keyword_plan_campaign_resource
    });

  # Create a keyword plan ad group operation.
  my $keyword_plan_ad_group_operation =
    Google::Ads::GoogleAds::V4::Services::KeywordPlanAdGroupService::KeywordPlanAdGroupOperation
    ->new({
      create => $keyword_plan_ad_group
    });

  # Add the keyword plan ad group.
  my $keyword_plan_ad_group_resource =
    $api_client->KeywordPlanAdGroupService()->mutate({
      customerId => $customer_id,
      operations => [$keyword_plan_ad_group_operation]}
  )->{results}[0]{resourceName};

  printf "Created ad group for keyword plan: '%s'.\n",
    $keyword_plan_ad_group_resource;

  return $keyword_plan_ad_group_resource;
}

# Creates ad group keywords for the keyword plan.
sub create_keyword_plan_ad_group_keywords {
  my ($api_client, $customer_id, $keyword_plan_ad_group_resource) = @_;

  # Create the ad group keywords for the keyword plan.
  my $keyword_plan_ad_group_keyword1 =
    Google::Ads::GoogleAds::V4::Resources::KeywordPlanAdGroupKeyword->new({
      text               => "mars cruise",
      cpcBidMicros       => 2000000,
      matchType          => BROAD,
      keywordPlanAdGroup => $keyword_plan_ad_group_resource
    });

  my $keyword_plan_ad_group_keyword2 =
    Google::Ads::GoogleAds::V4::Resources::KeywordPlanAdGroupKeyword->new({
      text               => "cheap cruise",
      cpcBidMicros       => 1500000,
      matchType          => PHRASE,
      keywordPlanAdGroup => $keyword_plan_ad_group_resource
    });

  my $keyword_plan_ad_group_keyword3 =
    Google::Ads::GoogleAds::V4::Resources::KeywordPlanAdGroupKeyword->new({
      text               => "jupiter cruise",
      cpcBidMicros       => 1990000,
      matchType          => EXACT,
      keywordPlanAdGroup => $keyword_plan_ad_group_resource
    });

  # Create an array of keyword plan ad group keyword operations.
  my $operations = [
    map(
      Google::Ads::GoogleAds::V4::Services::KeywordPlanAdGroupKeywordService::KeywordPlanAdGroupKeywordOperation
        ->new(
        {create => $_}
        ),
      (
        $keyword_plan_ad_group_keyword1, $keyword_plan_ad_group_keyword2,
        $keyword_plan_ad_group_keyword3
      ))];

  # Add the keyword plan ad group keywords.
  my $response = $api_client->KeywordPlanAdGroupKeywordService()->mutate({
    customerId => $customer_id,
    operations => $operations
  });

  foreach my $result (@{$response->{results}}) {
    printf "Created ad group keyword for keyword plan: '%s'.\n",
      $result->{resourceName};
  }
}

# Creates negative campaign keywords for the keyword plan.
sub create_keyword_plan_negative_campaign_keywords {
  my ($api_client, $customer_id, $keyword_plan_campaign_resource) = @_;

  # Create a negative campaign keyword for the keyword plan.
  my $keyword_plan_campaign_keyword =
    Google::Ads::GoogleAds::V4::Resources::KeywordPlanCampaignKeyword->new({
      text                => "moon walk",
      matchType           => BROAD,
      negative            => "true",
      keywordPlanCampaign => $keyword_plan_campaign_resource
    });

  # Create a keyword plan campaign keyword operation.
  my $operation =
    Google::Ads::GoogleAds::V4::Services::KeywordPlanCampaignKeywordService::KeywordPlanCampaignKeywordOperation
    ->new({
      create => $keyword_plan_campaign_keyword
    });

  # Add the keyword plan negative campaign keyword.
  my $response = $api_client->KeywordPlanCampaignKeywordService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});

  printf "Created negative campaign keyword for keyword plan: '%s'.\n",
    $response->{results}[0]{resourceName};
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
add_keyword_plan($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

add_keyword_plan

=head1 DESCRIPTION

This example creates a keyword plan, which can be reused for retrieving forecast metrics
and historic metrics.

=head1 SYNOPSIS

add_keyword_plan.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
