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
# GoogleAdsService.Search results are paginated but they can only be retrieved in
# sequence starting by the first page. More details at
# https://developers.google.com/google-ads/api/docs/reporting/paging.
#
# This example searches campaigns illustrating how GoogleAdsService.Search result
# page tokens can be cached and reused to retrieve previous pages. This is useful
# when you need to request pages that were already requested in the past without
# starting over from the first page. For example, it can be used to implement an
# interactive application that displays a page of results at a time without caching
# all the results first.
#
# To add campaigns, run add_campaigns.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use
  Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsRequest;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd        qw(abs_path);
use List::Util qw(min);
use POSIX      qw(ceil);

# The maximum number of results to retrieve.
use constant RESULTS_LIMIT => 10;
# The size of the paginated search result pages.
use constant PAGE_SIZE => 3;

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub navigate_search_result_pages_caching_tokens {
  my ($api_client, $customer_id) = @_;

  # The cache of page tokens which is stored in-memory with the page numbers as
  # keys. The first page's token is always an empty string.
  my $page_tokens = {1 => ""};

  printf "\n--- 0. Fetch page #1 to get metadata:\n\n";

  # Create a query that retrieves the campaigns.
  my $query =
    sprintf "SELECT campaign.id, campaign.name FROM campaign " .
    "ORDER BY campaign.name LIMIT %d",
    RESULTS_LIMIT;

  # Issue a paginated search request.
  my $search_options = {
    # Set the number of results to return per page.
    pageSize => PAGE_SIZE,
    # Request to return the total results count. This is necessary to determine
    # how many pages of results there are.
    returnTotalResultsCount => "true"
  };
  my $response = $api_client->GoogleAdsService()->search({
    customerId => $customer_id,
    query      => $query,
    %$search_options
  });
  cache_next_page_token($page_tokens, $response, 1);

  # Determine the total number of results and print it.
  # The total results count does not take into consideration the LIMIT clause of
  # the query, so we need to find the minimal value between the limit and the total
  # results count.
  my $total_number_of_results =
    min(RESULTS_LIMIT, $response->{totalResultsCount});
  printf "Total number of campaigns found: %d.\n", $total_number_of_results;

  # Determine the total number of pages and print it.
  my $total_number_of_pages = ceil($total_number_of_results / PAGE_SIZE);
  printf "Total number of pages: %d.\n", $total_number_of_pages;
  if ($total_number_of_pages == 0) {
    print "Could not find any campaigns.\n";
    exit 1;
  }

  # Demonstrate how the logic works when iterating pages forward. We select a page
  # that is in the middle of the result set so that only a subset of the page tokens
  # will be cached.
  my $middle_page_number = ceil($total_number_of_pages / 2);
  printf "\n--- 1. Print results of the page #%d:\n\n", $middle_page_number;
  fetch_and_print_page_results($api_client, $customer_id, $query,
    $search_options, $middle_page_number, $page_tokens);

  # Demonstrate how the logic works when iterating pages backward with some page
  # tokens that are not already cached.
  print "\n--- 2. Print results from the last page to the first:\n";
  foreach my $page_number (reverse 1 .. $total_number_of_pages) {
    printf "\n-- Printing results for page #%d:\n", $page_number;
    fetch_and_print_page_results(
      $api_client,     $customer_id, $query,
      $search_options, $page_number, $page_tokens
    );
  }

  return 1;
}

# [START navigate_search_result_pages_caching_tokens]
# Fetches and prints the results of a page of a search using a cache of page tokens.
sub fetch_and_print_page_results {
  my (
    $api_client,     $customer_id, $query,
    $search_options, $page_number, $page_tokens
  ) = @_;

  my $current_page_number = undef;
  # There is no need to fetch the pages we already know the page tokens for.
  if (exists $page_tokens->{$page_number}) {
    print "The token of the requested page was cached, " .
      "we will use it to get the results.\n";
    $current_page_number = $page_number;
  } else {
    printf "The token of the requested page was never cached, " .
      "we will use the closest page we know the token for (page #%d) " .
      "and sequentially get pages from there.\n", scalar keys %$page_tokens;
    $current_page_number = scalar keys %$page_tokens;
  }

  # Fetch next pages in sequence and cache their tokens until the requested page
  # results are returned.
  my $response = undef;
  while ($current_page_number <= $page_number) {
    # Fetch the next page.
    printf "Fetching page #%d...\n", $current_page_number;
    $response = $api_client->GoogleAdsService()->search({
        customerId => $customer_id,
        query      => $query,
        %$search_options,
        # Use the page token cached for the current page number.
        pageToken => $page_tokens->{$current_page_number}});
    cache_next_page_token($page_tokens, $response, $current_page_number);
    $current_page_number++;
  }

  # Print the results of the requested page.
  printf "Printing results found for the page #%d:\n", $page_number;
  foreach my $google_ads_row (@{$response->{results}}) {
    printf
      " - Campaign with ID %d and name '%s'.\n",
      $google_ads_row->{campaign}{id},
      $google_ads_row->{campaign}{name};
  }
}
# [END navigate_search_result_pages_caching_tokens]

# Updates the cache of page tokens based on a page that was retrieved.
sub cache_next_page_token {
  my ($page_tokens, $response, $page_number) = @_;
  if (defined $response->{nextPageToken}
    && !exists $page_tokens->{$page_number + 1})
  {
    # Update the cache with the next page token if it is not set yet.
    $page_tokens->{$page_number + 1} = $response->{nextPageToken};
    printf "Cached token for page #%d.\n", $page_number + 1;
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

# Parameters passed on the command line will override any parameters set in code.
GetOptions("customer_id=s" => \$customer_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
navigate_search_result_pages_caching_tokens($api_client,
  $customer_id =~ s/-//gr);

=pod

=head1 NAME

upload_image

=head1 DESCRIPTION

GoogleAdsService.Search results are paginated but they can only be retrieved in
sequence starting by the first page. More details at
https://developers.google.com/google-ads/api/docs/reporting/paging.

This example searches campaigns illustrating how GoogleAdsService.Search result
page tokens can be cached and reused to retrieve previous pages. This is useful
when you need to request pages that were already requested in the past without
starting over from the first page. For example, it can be used to implement an
interactive application that displays a page of results at a time without caching
all the results first.

To add campaigns, run add_campaigns.pl.

=head1 SYNOPSIS

navigate_search_result_pages_caching_tokens.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
