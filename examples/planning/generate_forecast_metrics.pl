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
# This example generates forecast metrics for keyword planning.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V14::Common::DateRange;
use Google::Ads::GoogleAds::V14::Common::KeywordInfo;
use
  Google::Ads::GoogleAds::V14::Services::KeywordPlanIdeaService::BiddableKeyword;
use
  Google::Ads::GoogleAds::V14::Services::KeywordPlanIdeaService::CampaignToForecast;
use
  Google::Ads::GoogleAds::V14::Services::KeywordPlanIdeaService::CriterionBidModifier;
use
  Google::Ads::GoogleAds::V14::Services::KeywordPlanIdeaService::ForecastAdGroup;
use
  Google::Ads::GoogleAds::V14::Services::KeywordPlanIdeaService::ManualCpcBiddingStrategy;
use Google::Ads::GoogleAds::V14::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd   qw(abs_path);
use POSIX qw(strftime);

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

# [START generate_forecast_metrics]
sub generate_forecast_metrics {
  my ($api_client, $customer_id) = @_;

  my $campaign_to_forecast = create_campaign_to_forecast();

  my $keyword_forecast_metrics_response =
    $api_client->KeywordPlanIdeaService()->generate_keyword_forecast_metrics({
      customerId => $customer_id,
      campaign   => $campaign_to_forecast,

      # Set the forecast range.
      forecastPeriod => Google::Ads::GoogleAds::V14::Common::DateRange->new({
          # Set the start date. The forecast starts tomorrow.
          startDate => strftime("%Y-%m-%d", localtime(time + 60 * 60 * 24)),
          # Set the end date. The forecast ends in 30 days.
          endDate => strftime("%Y-%m-%d", localtime(time + 60 * 60 * 24 * 30))})
    });

  my $metrics = $keyword_forecast_metrics_response->{campaignForecastMetrics};

  printf "Estimated daily clicks: %s.\n",
    defined $metrics->{clicks} ? $metrics->{clicks} : "undef";
  printf "Estimated daily impressions: %s.\n",
    defined $metrics->{impressions} ? $metrics->{impressions} : "undef";
  printf "Estimated average cpc (micros): %s.\n\n",
    defined $metrics->{averageCpc} ? $metrics->{averageCpc} : "undef";

  return 1;
}

# Creates the campaign to forecast.
sub create_campaign_to_forecast {
  my ($api_client, $customer_id) = @_;

  # Create a campaign to forecast.
  my $campaign_to_forecast =
    Google::Ads::GoogleAds::V14::Services::KeywordPlanIdeaService::CampaignToForecast
    ->new({keywordPlanNetwork => 'GOOGLE_SEARCH'});

  # Set the bidding strategy.
  $campaign_to_forecast->{biddingStrategy}->{manualCpcBiddingStrategy} =
    Google::Ads::GoogleAds::V14::Services::KeywordPlanIdeaService::ManualCpcBiddingStrategy
    ->new({maxCpcBidMicros => 1000000});

  # See https://developers.google.com/google-ads/api/reference/data/geotargets
  # for the list of geo target IDs.
  $campaign_to_forecast->{geoModifiers} = [
    Google::Ads::GoogleAds::V14::Services::KeywordPlanIdeaService::CriterionBidModifier
      ->new({
        # Geo target constant 2840 is for USA.
        geoTargetConstant =>
          Google::Ads::GoogleAds::V14::Utils::ResourceNames::geo_target_constant(
          2840)})];

  # See https://developers.google.com/google-ads/api/reference/data/codes-formats#languages
  # for the list of language criteria IDs.
  $campaign_to_forecast->{languageConstants} = [

    # Language criteria 1000 is for English.
    Google::Ads::GoogleAds::V14::Utils::ResourceNames::language_constant(1000)];

  # Create a forecast ad group.
  $campaign_to_forecast->{adGroups} = [
    Google::Ads::GoogleAds::V14::Services::KeywordPlanIdeaService::ForecastAdGroup
      ->new({
        biddableKeywords => [
          Google::Ads::GoogleAds::V14::Services::KeywordPlanIdeaService::BiddableKeyword
            ->new({
              maxCpcBidMicros => 2500000,
              keyword => Google::Ads::GoogleAds::V14::Common::KeywordInfo->new({
                  text      => "mars cruise",
                  matchType => 'BROAD'
                })}
            ),
          Google::Ads::GoogleAds::V14::Services::KeywordPlanIdeaService::BiddableKeyword
            ->new({
              maxCpcBidMicros => 1500000,
              keyword => Google::Ads::GoogleAds::V14::Common::KeywordInfo->new({
                  text      => "cheap cruise",
                  matchType => 'PHRASE'
                })}
            ),
          Google::Ads::GoogleAds::V14::Services::KeywordPlanIdeaService::BiddableKeyword
            ->new({
              maxCpcBidMicros => 1990000,
              keyword => Google::Ads::GoogleAds::V14::Common::KeywordInfo->new({
                  text      => "jupiter cruise",
                  matchType => 'EXACT'
                })})
        ],
        negativeKeywords => [
          Google::Ads::GoogleAds::V14::Common::KeywordInfo->new({
              text      => "moon walk",
              matchType => 'BROAD'
            })]})];

  return $campaign_to_forecast;
}

# [END generate_forecast_metrics]

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
generate_forecast_metrics($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

generate_forecast_metrics

=head1 DESCRIPTION

This example generates forecast metrics for a campaign forecast.

=head1 SYNOPSIS

generate_forecast_metrics.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
