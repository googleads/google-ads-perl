#!/usr/bin/perl -w
#
# Copyright 2022, Google LLC
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
# The auto-apply feature, which automatically applies recommendations as they become eligible,
# is currently supported by the Google Ads UI but not by the Google Ads API. See
# https://support.google.com/google-ads/answer/10279006 for more information on using auto-apply
# in the Google Ads UI.
#
# This example demonstrates how an alternative can be implemented with the features that are
# currently supported by the Google Ads API. It periodically retrieves and applies `KEYWORD`
# recommendations with default parameters.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use
  Google::Ads::GoogleAds::V12::Services::RecommendationService::ApplyRecommendationOperation;
use
  Google::Ads::GoogleAds::V12::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd         qw(abs_path);
use Time::HiRes qw(sleep);

my $customer_id;

# The maximum number of recommendations to periodically retrieve and apply.
# In a real application, such a limit would typically not be used.
use constant MAX_RESULT_SIZE => 2;

# The number of times to retrieve and apply recommendations. In a real application,
# such a limit would typically not be used.
use constant NUMBER_OF_RUNS => 3;

# The time to wait between two runs. In a real application, this would typically be set to
# minutes or hours instead of seconds.
use constant PERIOD_IN_SECONDS => 5;

sub detect_and_apply_recommendations {
  my ($api_client, $customer_id) = @_;

  # Create the search query.
  my $search_query =
    "SELECT recommendation.resource_name FROM recommendation " .
    "WHERE recommendation.type = KEYWORD LIMIT " . MAX_RESULT_SIZE;

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  for my $i (1 .. NUMBER_OF_RUNS) {
    my $search_stream_handler =
      Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
        service => $google_ads_service,
        request => {
          customerId => $customer_id,
          query      => $search_query
        }});

    # Create apply operations for all the recommendations found.
    my $apply_recommendation_operations = ();
    $search_stream_handler->process_contents(
      sub {
        my $google_ads_row = shift;
        push @$apply_recommendation_operations,
          Google::Ads::GoogleAds::V12::Services::RecommendationService::ApplyRecommendationOperation
          ->new({
            resourceName => $google_ads_row->{recommendation}{resource_name}});
      });

    if (defined $apply_recommendation_operations) {
      # Send the apply recommendation request and print information.
      my $apply_recommendation_response =
        $api_client->RecommendationService()->apply({
          customerId => $customer_id,
          operations => $apply_recommendation_operations
        });

      foreach my $result (@{$apply_recommendation_response->{results}}) {
        printf "Applied recommendation with resource name: '%s'.\n",
          $result->{resourceName};
      }
    }

    if ($i < NUMBER_OF_RUNS) {
      printf
        "Waiting %d seconds before checking for additional recommendations.\n",
        PERIOD_IN_SECONDS;
      sleep(PERIOD_IN_SECONDS);
    }

  }

  return 1;
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
detect_and_apply_recommendations($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

detect_and_apply_recommendations

=head1 DESCRIPTION

The auto-apply feature, which automatically applies recommendations as they become eligible,
is currently supported by the Google Ads UI but not by the Google Ads API. See
https://support.google.com/google-ads/answer/10279006 for more information on using auto-apply
in the Google Ads UI.

This example demonstrates how an alternative can be implemented with the features that are
currently supported by the Google Ads API. It periodically retrieves and applies `KEYWORD`
recommendations with default parameters.

=head1 SYNOPSIS

detect_and_apply_recommendations.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
