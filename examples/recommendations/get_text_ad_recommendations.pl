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
# This example gets all TEXT_AD recommendations.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use
  Google::Ads::GoogleAds::V15::Services::GoogleAdsService::SearchGoogleAdsRequest;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

use constant PAGE_SIZE => 1000;

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

# [START get_text_ad_recommendations]
sub get_text_ad_recommendations {
  my ($api_client, $customer_id) = @_;

  # Creates the search query.
  my $search_query =
    "SELECT recommendation.type, recommendation.campaign, " .
    "recommendation.text_ad_recommendation " .
    "FROM recommendation WHERE recommendation.type = TEXT_AD";

  # Create a search Google Ads request that will retrieve all recommendations for
  # text ads using pages of the specified page size.
  my $search_request =
    Google::Ads::GoogleAds::V15::Services::GoogleAdsService::SearchGoogleAdsRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query,
      pageSize   => PAGE_SIZE
    });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $iterator = Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
    service => $google_ads_service,
    request => $search_request
  });

  # Iterate over all rows in all pages and print the requested field values for
  # the recommendation in each row.
  while ($iterator->has_next) {
    my $google_ads_row = $iterator->next;
    my $recommendation = $google_ads_row->{recommendation};
    printf
      "Recommendation '%s' was found for campaign '%s':\n",
      $recommendation->{resourceName},
      $recommendation->{campaign};

    my $recommended_ad = $recommendation->{textAdRecommendation}{ad};
    if ($recommended_ad->{expandedTextAd}) {
      my $recommended_expanded_text_ad = $recommended_ad->{expandedTextAd};

      printf "\tHeadline part 1 is '%s'.\n" .
        "\tHeadline part 2 is '%s'.\n" . "\tDescription is '%s'.\n",
        $recommended_expanded_text_ad->{headlinePart1},
        $recommended_expanded_text_ad->{headlinePart2},
        $recommended_expanded_text_ad->{description};
    }

    if ($recommended_ad->{displayUrl}) {
      printf "\tDisplay URL is '%s'.\n", $recommended_ad->{displayUrl};
    }

    foreach my $final_url (@{$recommended_ad->{finalUrls}}) {
      printf "\tFinal URL is '%s'.\n", $final_url;
    }

    foreach my $final_mobile_url (@{$recommended_ad->{finalMobileUrls}}) {
      printf "\tFinal Mobile URL is '%s'.\n", $final_mobile_url;
    }
  }

  return 1;
}
# [END get_text_ad_recommendations]

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
get_text_ad_recommendations($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

get_text_ad_recommendations

=head1 DESCRIPTION

This example gets all TEXT_AD recommendations.

=head1 SYNOPSIS

get_text_ad_recommendations.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
