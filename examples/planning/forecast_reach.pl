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
# This example demonstrates how to interact with the ReachPlanService to find
# plannable locations and product codes, build a media plan, and generate a video
# ads reach forecast.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::GoogleAdsClient;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V2::Common::GenderInfo;
use Google::Ads::GoogleAds::V2::Common::DeviceInfo;
use Google::Ads::GoogleAds::V2::Enums::ReachPlanAdLengthEnum
  qw(FIFTEEN_OR_TWENTY_SECONDS);
use Google::Ads::GoogleAds::V2::Enums::GenderTypeEnum qw(MALE FEMALE);
use Google::Ads::GoogleAds::V2::Enums::DeviceEnum qw(DESKTOP MOBILE TABLET);
use Google::Ads::GoogleAds::V2::Enums::ReachPlanAgeRangeEnum
  qw(AGE_RANGE_18_65_UP);
use Google::Ads::GoogleAds::V2::Services::ReachPlanService::PlannedProduct;
use Google::Ads::GoogleAds::V2::Services::ReachPlanService::Preferences;
use Google::Ads::GoogleAds::V2::Services::ReachPlanService::CampaignDuration;
use Google::Ads::GoogleAds::V2::Services::ReachPlanService::Targeting;
use
  Google::Ads::GoogleAds::V2::Services::ReachPlanService::GenerateReachForecastRequest;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub forecast_reach {
  my ($api_client, $customer_id) = @_;

  # Location ID to plan for. You can get a valid location ID from
  # https://developers.google.com/adwords/api/docs/appendix/geotargeting or by
  # calling list_plannable_locations on the ReachPlanService.
  # Location ID 2840 is for USA.
  my $location_id   = "2840";
  my $currency_code = "USD";
  my $budget_micros = 500_000_000_000;

  my $reach_plan_service = $api_client->ReachPlanService();

  show_plannable_locations($reach_plan_service);
  show_plannable_products($reach_plan_service, $location_id);
  forecast_manual_mix(
    $reach_plan_service, $customer_id, $location_id,
    $currency_code,      $budget_micros
  );
  forecast_suggested_mix(
    $reach_plan_service, $customer_id, $location_id,
    $currency_code,      $budget_micros
  );

  return 1;
}

# Maps friendly names of plannable locations to location IDs usable with
# ReachPlanService.
sub show_plannable_locations {
  my ($reach_plan_service) = @_;

  my $response = $reach_plan_service->list_plannable_locations();

  print "Plannable Locations:\n";
  print "Name,\tId,\tParentCountryId\n";
  foreach my $location (@{$response->{plannableLocations}}) {
    printf "'%s',\t%d,\t%d\n", $location->{name}, $location->{id},
      $location->{parentCountryId};
  }
}

# Lists plannable products for a given location.
sub show_plannable_products {
  my ($reach_plan_service, $location_id) = @_;

  my $response = $reach_plan_service->list_plannable_products({
    plannableLocationId => $location_id
  });

  printf "Plannable Products for location %d:\n", $location_id;
  foreach my $product (@{$response->{productMetadata}}) {
    printf "%s\n", $product->{plannableProductCode};
    print "Age Ranges:\n";
    foreach my $age_range (@{$product->{plannableTargeting}{ageRanges}}) {
      printf "\t- %s\n", $age_range;
    }
    print "Genders:\n";
    foreach my $gender (@{$product->{plannableTargeting}{genders}}) {
      printf "\t- %s\n", $gender->{type};
    }
    print "Devices:\n";
    foreach my $device (@{$product->{plannableTargeting}{devices}}) {
      printf "\t- %s\n", $device->{type};
    }
  }
}

# Pulls a forecast for a budget split 15% and 85% between two products.
sub forecast_manual_mix {
  my (
    $reach_plan_service, $customer_id, $location_id,
    $currency_code,      $budget_micros
  ) = @_;

  my $product_mix = [];

  # Set up a ratio to split the budget between two products.
  my $trueview_allocation = 0.15;
  my $bumper_allocation   = 1 - $trueview_allocation;

  # See list_plannable_products on ReachPlanService to retrieve a list of valid
  # plannable product codes for a given location:
  # https://developers.google.com/google-ads/api/reference/rpc/google.ads.googleads.v2.services#reachplanservice
  push @$product_mix,
    Google::Ads::GoogleAds::V2::Services::ReachPlanService::PlannedProduct->new(
    {
      plannableProductCode => "TRUEVIEW_IN_STREAM",
      budgetMicros         => int($budget_micros * $trueview_allocation)});
  push @$product_mix,
    Google::Ads::GoogleAds::V2::Services::ReachPlanService::PlannedProduct->new(
    {
      plannableProductCode => "BUMPER",
      budgetMicros         => int($budget_micros * $bumper_allocation)});

  my $reach_request =
    build_reach_request($customer_id, $product_mix, $location_id,
    $currency_code);

  pull_reach_curve($reach_plan_service, $reach_request);
}

# Pulls a forecast for a product mix suggested based on preferences for whether
# the ad would have a guaranteed price, play with sound, would be skippable, would
# include top content, and a desired ad length.
sub forecast_suggested_mix {
  my (
    $reach_plan_service, $customer_id, $location_id,
    $currency_code,      $budget_micros
  ) = @_;

  # Note: If preferences are too restrictive, then the response will be empty.
  my $preferences =
    Google::Ads::GoogleAds::V2::Services::ReachPlanService::Preferences->new({
      hasGuaranteedPrice => "true",
      startsWithSound    => "true",
      isSkippable        => "false",
      topContentOnly     => "true",
      adLength           => FIFTEEN_OR_TWENTY_SECONDS
    });

  my $mix_response = $reach_plan_service->generate_product_mix_ideas({
    customerId          => $customer_id,
    plannableLocationId => $location_id,
    preferences         => $preferences,
    currencyCode        => $currency_code,
    budgetMicros        => $budget_micros,
  });

  my $product_mix = [];
  foreach my $product (@{$mix_response->{productAllocation}}) {
    push @$product_mix,
      Google::Ads::GoogleAds::V2::Services::ReachPlanService::PlannedProduct->
      new({
        plannableProductCode => $product->{plannableProductCode},
        budgetMicros         => $product->{budgetMicros}});
  }

  my $reach_request =
    build_reach_request($customer_id, $product_mix, $location_id,
    $currency_code);

  pull_reach_curve($reach_plan_service, $reach_request);
}

# Create a base request to generate a reach forecast.
sub build_reach_request {
  my ($customer_id, $product_mix, $location_id, $currency_code) = @_;

  # Valid durations are between 1 and 90 days.
  my $duration =
    Google::Ads::GoogleAds::V2::Services::ReachPlanService::CampaignDuration->
    new({
      durationInDays => 28
    });

  my $genders = [
    Google::Ads::GoogleAds::V2::Common::GenderInfo->new({
        type => FEMALE
      }
    ),
    Google::Ads::GoogleAds::V2::Common::GenderInfo->new({
        type => MALE
      })];

  my $devices = [
    Google::Ads::GoogleAds::V2::Common::DeviceInfo->new({
        type => DESKTOP
      }
    ),
    Google::Ads::GoogleAds::V2::Common::DeviceInfo->new({
        type => MOBILE
      }
    ),
    Google::Ads::GoogleAds::V2::Common::DeviceInfo->new({
        type => TABLET
      })];

  my $targeting =
    Google::Ads::GoogleAds::V2::Services::ReachPlanService::Targeting->new({
      plannableLocationId => $location_id,
      ageRange            => AGE_RANGE_18_65_UP,
      genders             => $genders,
      devices             => $devices
    });

  # See the docs for defaults and valid ranges:
  # https://developers.google.com/google-ads/api/reference/rpc/google.ads.googleads.v2.services#google.ads.googleads.v2.services.GenerateReachForecastRequest
  return
    Google::Ads::GoogleAds::V2::Services::ReachPlanService::GenerateReachForecastRequest
    ->new({
      customerId            => $customer_id,
      currencyCode          => $currency_code,
      campaignDuration      => $duration,
      cookieFrequencyCap    => 0,
      minEffectiveFrequency => 1,
      targeting             => $targeting,
      plannedProducts       => $product_mix
    });
}

# Pulls and prints the reach curve for the given request.
sub pull_reach_curve {
  my ($reach_plan_service, $reach_request) = @_;

  my $response = $reach_plan_service->generate_reach_forecast($reach_request);
  print "Reach curve output:\n";
  print "Currency,\tCost Micros,\tOn-Target Reach,\tOn-Target Imprs,\t" .
    "Total Reach,\tTotal Imprs,\tProducts\n";
  foreach my $point (@{$response->{reachCurve}{reachForecasts}}) {
    printf "%s,\t%d,\t%d,\t%d,\t%d,\t%d,\t'[", $reach_request->{currencyCode},
      $point->{costMicros}, $point->{forecast}{onTargetReach},
      $point->{forecast}{onTargetImpressions}, $point->{forecast}{totalReach},
      $point->{forecast}{totalImpressions};
    foreach my $product (@{$point->{forecastedProductAllocations}}) {
      printf "(Product: %s, Budget Micros: %d), ",
        $product->{plannableProductCode}, $product->{budgetMicros};
    }
    print "]'\n";
  }
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client =
  Google::Ads::GoogleAds::GoogleAdsClient->new({version => "V2"});

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions("customer_id=s" => \$customer_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
forecast_reach($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

forecast_reach

=head1 DESCRIPTION

This example demonstrates how to interact with the ReachPlanService to find plannable
locations and product codes, build a media plan, and generate a video ads reach forecast.

=head1 SYNOPSIS

forecast_reach.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
