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
# This example generates keyword ideas from a list of seed keywords or a seed
# page URL.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Enums::KeywordPlanNetworkEnum
  qw(GOOGLE_SEARCH GOOGLE_SEARCH_AND_PARTNERS);
use Google::Ads::GoogleAds::V23::Services::KeywordPlanIdeaService::UrlSeed;
use Google::Ads::GoogleAds::V23::Services::KeywordPlanIdeaService::KeywordSeed;
use
  Google::Ads::GoogleAds::V23::Services::KeywordPlanIdeaService::KeywordAndUrlSeed;
use Google::Ads::GoogleAds::V23::Utils::ResourceNames;

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

# Location criteria IDs. For example, specify 21167 for New York. For more
# information on determining this value, see
# https://developers.google.com/google-ads/api/reference/data/geotargets.
my $location_id_1 = "INSERT_LOCATION_ID_1_HERE";
my $location_id_2 = "INSERT_LOCATION_ID_2_HERE";
my $location_ids  = [];

# A language criterion ID. For example, specify 1000 for English. For more
# information on determining this value, see
# https://developers.google.com/google-ads/api/reference/data/codes-formats#languages.
my $language_id = "INSERT_LANGUAGE_ID_HERE";

my $keyword_text_1 = "INSERT_KEYWORD_TEXT_1_HERE";
my $keyword_text_2 = "INSERT_KEYWORD_TEXT_2_HERE";
my $keyword_texts  = [];

# Optional: Specify a URL string related to your business to generate ideas.
my $page_url = undef;

# [START generate_keyword_ideas]
sub generate_keyword_ideas {
  my (
    $api_client,  $customer_id,   $location_ids,
    $language_id, $keyword_texts, $page_url
  ) = @_;

  # Make sure that keywords and/or page URL were specified. The request must have
  # exactly one of urlSeed, keywordSeed, or keywordAndUrlSeed set.
  if (not scalar @$keyword_texts and not $page_url) {
    die "At least one of keywords or page URL is required, " .
      "but neither was specified.";
  }

  # Specify the optional arguments of the request as a keywordSeed, urlSeed,
  # or keywordAndUrlSeed.
  my $request_option_args = {};
  if (!scalar @$keyword_texts) {
    # Only page URL was specified, so use a UrlSeed.
    $request_option_args->{urlSeed} =
      Google::Ads::GoogleAds::V23::Services::KeywordPlanIdeaService::UrlSeed->
      new({
        url => $page_url
      });
  } elsif (not $page_url) {
    # Only keywords were specified, so use a KeywordSeed.
    $request_option_args->{keywordSeed} =
      Google::Ads::GoogleAds::V23::Services::KeywordPlanIdeaService::KeywordSeed
      ->new({
        keywords => $keyword_texts
      });
  } else {
    # Both page URL and keywords were specified, so use a KeywordAndUrlSeed.
    $request_option_args->{keywordAndUrlSeed} =
      Google::Ads::GoogleAds::V23::Services::KeywordPlanIdeaService::KeywordAndUrlSeed
      ->new({
        url      => $page_url,
        keywords => $keyword_texts
      });
  }

  # Create a list of geo target constants based on the resource name of specified
  # location IDs.
  my $geo_target_constants = [
    map (
      Google::Ads::GoogleAds::V23::Utils::ResourceNames::geo_target_constant(
        $_),
      @$location_ids)];

  # Generate keyword ideas based on the specified parameters.
  my $keyword_ideas_response =
    $api_client->KeywordPlanIdeaService()->generate_keyword_ideas({
      customerId => $customer_id,
      # Set the language resource using the provided language ID.
      language =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::language_constant(
        $language_id),
      # Add the resource name of each location ID to the request.
      geoTargetConstants => $geo_target_constants,
      # Set the network. To restrict to only Google Search, change the parameter below
      # to GOOGLE_SEARCH.
      keywordPlanNetwork => GOOGLE_SEARCH_AND_PARTNERS,
      %$request_option_args
    });

  # Iterate over the results and print its detail.
  foreach my $result (@{$keyword_ideas_response->{results}}) {
    printf "Keyword idea text '%s' has %d average monthly searches " .
      "and '%s' competition.\n", $result->{text},
      $result->{keywordIdeaMetrics}{avgMonthlySearches}
      ? $result->{keywordIdeaMetrics}{avgMonthlySearches}
      : 0,
      $result->{keywordIdeaMetrics}{competition}
      ? $result->{keywordIdeaMetrics}{competition}
      : "undef";
  }

  return 1;
}
# [END generate_keyword_ideas]

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s"   => \$customer_id,
  "location_ids=i"  => \@$location_ids,
  "language_id=i"   => \$language_id,
  "keyword_texts=s" => \@$keyword_texts,
  "page_url=s"      => \$page_url,
);
$location_ids  = [$location_id_1,  $location_id_2]  unless @$location_ids;
$keyword_texts = [$keyword_text_1, $keyword_text_2] unless @$keyword_texts;

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if
  not check_params($customer_id, $location_ids, $language_id, $keyword_texts);

# Call the example.
generate_keyword_ideas($api_client, $customer_id =~ s/-//gr,
  $location_ids, $language_id, $keyword_texts, $page_url);

=pod

=head1 NAME

generate_keyword_ideas

=head1 DESCRIPTION

This example generates keyword ideas from a list of seed keywords or a seed page URL.

=head1 SYNOPSIS

generate_keyword_ideas.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -location_ids               The location criterion IDs, e.g. specify 21167 for New York.
    -language_id                The language criterion ID, e.g. specify 1000 for English.
    -keyword_texts              The keyword texts, as a seed for ideas.
    -page_url                   [optional] URL of a page related to your business.

=cut
