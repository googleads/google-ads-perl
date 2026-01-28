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
# This example generates historical metrics for keyword planning.
# Guide: https://developers.google.com/google-ads/api/docs/keyword-planning/generate-historical-metrics

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

# [START generate_historical_metrics]
sub generate_historical_metrics {
  my ($api_client, $customer_id) = @_;

  my $keyword_historical_metrics_response =
    $api_client->KeywordPlanIdeaService()->generate_keyword_historical_metrics({
      customerId => $customer_id,
      keywords   => ["mars cruise", "cheap cruise", "jupiter cruise"],
      # Geo target constant 2840 is for USA.
      geoTargetConstants => [
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::geo_target_constant(
          2840)
      ],
      keywordPlanNetwork => 'GOOGLE_SEARCH',
      # Language criteria 1000 is for English. See
      # https://developers.google.com/google-ads/api/reference/data/codes-formats#languages
      # for the list of language criteria IDs.
      language =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::language_constant(
        1000)});

  foreach my $result (@{$keyword_historical_metrics_response->{results}}) {
    my $metric = $result->{keywordMetrics};
    # These metrics include those for both the search query and any
    # variants included in the response.
    # If the metric is undefined, print (undef) as a placeholder.
    printf
"The search query, %s, (and the following variants: %s), generated the following historical metrics:\n",
      $result->{text},
      $result->{closeVariants}
      ? join(', ', $result->{closeVariants})
      : "(undef)";

    # Approximate number of monthly searches on this query averaged for
    # the past 12 months.
    printf "\tApproximate monthly searches: %s.\n",
      value_or_undef($metric->{avgMonthlySearches});

    # The competition level for this search query.
    printf "\tCompetition level: %s.\n", value_or_undef($metric->{competition});

    # The competition index for the query in the range [0, 100]. This shows how
    # competitive ad placement is for a keyword. The level of competition from
    # 0-100 is determined by the number of ad slots filled divided by the total
    # number of ad slots available. If not enough data is available, undef will
    # be returned.
    printf "\tCompetition index: %s.\n",
      value_or_undef($metric->{competitionIndex});

    # Top of page bid low range (20th percentile) in micros for the keyword.
    printf "\tTop of page bid low range: %s.\n",
      value_or_undef($metric->{lowTopOfPageBidMicros});

    # Top of page bid high range (80th percentile) in micros for the keyword.
    printf "\tTop of page bid high range: %s.\n",
      value_or_undef($metric->{highTopOfPageBidMicros});

    # Approximate number of searches on this query for the past twelve months.
    foreach my $month (@{$metric->{monthlySearchVolumes}}) {
      printf "\tApproximately %d searches in %s, %s.\n",
        $month->{monthlySearches}, $month->{month}, $month->{year};
    }
  }

  return 1;
}
# [END generate_historical_metrics]

# Returns the input value as a string if it's defined, otherwise returns "(undef)".
sub value_or_undef {
  my ($value) = @_;
  return $value ? "$value" : "(undef)";
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

my $customer_id = undef;

# Parameters passed on the command line will override any parameters set in code.
GetOptions("customer_id=s" => \$customer_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
generate_historical_metrics($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

generate_historical_metrics

=head1 DESCRIPTION

This example generates historical metrics for keyword planning.

=head1 SYNOPSIS

generate_historical_metrics.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
