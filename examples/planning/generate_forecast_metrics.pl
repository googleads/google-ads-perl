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
# This example generates forecast metrics for a keyword plan. To create a
# keyword plan, run add_keyword_plan.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::GoogleAdsClient;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V2::Utils::ResourceNames;

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
my $customer_id     = "INSERT_CUSTOMER_ID_HERE";
my $keyword_plan_id = "INSERT_KEYWORD_PLAN_ID_HERE";

sub generate_forecast_metrics {
  my ($api_client, $customer_id, $keyword_plan_id) = @_;

  my $forecast_metrics_response =
    $api_client->KeywordPlanService()->generate_forecast_metrics(
    Google::Ads::GoogleAds::V2::Utils::ResourceNames::keyword_plan(
      $customer_id, $keyword_plan_id
    ));

  while (my ($index, $forecast) =
    each @{$forecast_metrics_response->{keywordForecasts}})
  {
    my $metrics = $forecast->{keywordForecast};

    printf "%d Keyword ID: %s.\n", $index + 1,
      $forecast->{keywordPlanAdGroupKeyword};
    printf "Estimated daily clicks: %s.\n",
      defined $metrics->{clicks} ? $metrics->{clicks} : "undef";
    printf "Estimated daily impressions: %s.\n",
      defined $metrics->{impressions} ? $metrics->{impressions} : "undef";
    printf "Estimated average cpc (micros): %s.\n\n",
      defined $metrics->{averageCpc} ? $metrics->{averageCpc} : "undef";
  }

  return 1;
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
GetOptions(
  "customer_id=s"     => \$customer_id,
  "keyword_plan_id=i" => \$keyword_plan_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $keyword_plan_id);

# Call the example.
generate_forecast_metrics($api_client, $customer_id =~ s/-//gr,
  $keyword_plan_id);

=pod

=head1 NAME

generate_forecast_metrics

=head1 DESCRIPTION

This example generates forecast metrics for a keyword plan. To create a keyword plan,
run add_keyword_plan.pl

=head1 SYNOPSIS

generate_forecast_metrics.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -keyword_plan_id            The keyword plan ID.

=cut
