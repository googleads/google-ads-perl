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
# This example shows how to retrieve recommendations and apply them in a batch.
#
# Recommendations should be applied shortly after they're retrieved. Depending
# on the recommendation type, a recommendation can become obsolete quickly, and
# obsolete recommendations throw an error when applied. For more details, see:
# https://developers.google.com/google-ads/api/docs/recommendations#take_action
#
# As of Google Ads API v15 users can subscribe to certain recommendation types
# to apply them automatically. For more details, see:
# https://developers.google.com/google-ads/api/docs/recommendations#auto-apply
#
# As of Google Ads API v16 users can proactively generate certain recommendation
# types during the campaign construction process. For more details see:
# https://developers.google.com/google-ads/api/docs/recommendations#recommendations-in-campaign-construction

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use
  Google::Ads::GoogleAds::V21::Services::RecommendationService::ApplyRecommendationOperation;
use
  Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd         qw(abs_path);
use Time::HiRes qw(sleep);

my $customer_id;

sub detect_and_apply_recommendations {
  my ($api_client, $customer_id) = @_;

  # [START detect_keyword_recommendations]
  # Create the search query.
  my $search_query =
    "SELECT recommendation.resource_name, " .
    "recommendation.campaign, recommendation.keyword_recommendation " .
    "FROM recommendation " .
    "WHERE recommendation.type = KEYWORD";

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

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
      my $recommendation = $google_ads_row->{recommendation};
      printf "Keyword recommendation '%s' was found for campaign '%s'.\n",
        $recommendation->{resourceName}, $recommendation->{campaign};
      my $keyword = $recommendation->{keywordRecommendation}{keyword};
      printf "\tKeyword = '%s'\n",    $keyword->{text};
      printf "\tMatch type = '%s'\n", $keyword->{matchType};
      # Creates an ApplyRecommendationOperation that will apply this recommendation, and adds
      # it to the list of operations.
      push @$apply_recommendation_operations,
        build_recommendation_operation($recommendation);
    });
  # [END detect_keyword_recommendations]

  if (!defined $apply_recommendation_operations) {
    print "No recommendations found.\n";
  } else {
    # [START apply_recommendation]
    # Issue a mutate request to apply the recommendations.
    my $apply_recommendation_response =
      $api_client->RecommendationService()->apply({
        customerId => $customer_id,
        operations => $apply_recommendation_operations
      });

    foreach my $result (@{$apply_recommendation_response->{results}}) {
      printf "Applied recommendation with resource name: '%s'.\n",
        $result->{resourceName};
    }
    # [END apply_recommendation]
  }

  return 1;
}

# [START build_apply_recommendation_operation]
sub build_recommendation_operation {
  my ($recommendation) = @_;

  # If you have a recommendation ID instead of a resource name, you can create a resource
  # name like this:
  # my $recommendation_resource_name =
  #   Google::Ads::GoogleAds::V21::Utils::ResourceNames::recommendation(
  #   $customer_id, $recommendation_id);

  # Each recommendation type has optional parameters to override the recommended values.
  # Below is an example showing how to override a recommended ad when a TextAdRecommendation
  # is applied.
  # my $overriding_ad = Google::Ads::GoogleAds::V21::Resources::Ad->new({
  #   id => "INSERT_AD_ID_AS_INTEGER_HERE"
  # });
  # my $text_ad_parameters =
  #   Google::Ads::GoogleAds::V21::Services::RecommendationService::TextAdParameters
  #   ->new({ad => $overriding_ad});
  # $apply_recommendation_operation->{textAd} = $text_ad_parameters;

  # Create an apply recommendation operation.
  my $apply_recommendation_operation =
    Google::Ads::GoogleAds::V21::Services::RecommendationService::ApplyRecommendationOperation
    ->new({
      resourceName => $recommendation->{resourceName}});

  return $apply_recommendation_operation;
}
# [END build_apply_recommendation_operation]

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
