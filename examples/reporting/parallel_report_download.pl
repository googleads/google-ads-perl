#!/usr/bin/perl -w
#
# Copyright 2020, Google LLC
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
# Shows how to download a set of reports from a list of accounts in parallel.
#
# If you need to obtain a list of accounts, please see the get_account_hierarchy.pl
# or list_accessible_customers.pl examples.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use
  Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsRequest;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
use threads;

# Defines the Google Ads Query Language (GAQL) query strings to run for each
# customer ID.
use constant GAQL_QUERY_STRINGS => [
  "SELECT campaign.id, metrics.impressions, metrics.clicks " .
    "FROM campaign WHERE segments.date DURING LAST_30_DAYS",
  "SELECT campaign.id, ad_group.id, metrics.impressions, metrics.clicks" .
    " FROM ad_group WHERE segments.date DURING LAST_30_DAYS"
];
# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id_1     = "INSERT_CUSTOMER_ID_1_HERE";
my $customer_id_2     = "INSERT_CUSTOMER_ID_2_HERE";
my $customer_ids      = [];
my $login_customer_id = undef;

sub parallel_report_download {
  my ($api_client, $customer_ids) = @_;

  # Create a single google ads service which can be shared by all threads.
  my $google_ads_service = $api_client->GoogleAdsService();

  # IMPORTANT: You should avoid hitting the same customer ID in parallel. There
  # are rate limits at the customer ID level which are much stricter than limits
  # at the developer token level.
  foreach my $search_query (@{+GAQL_QUERY_STRINGS}) {
    # Use a list of threads to make sure that we wait for this report to complete
    # on all customer IDs before proceeding.
    my $threads = [];

    # Use the API to retrieve the report for each customer ID.
    foreach my $customer_id (@$customer_ids) {
      # Start the report download in a background thread.
      my $thread =
        threads->create(\&download_report, $google_ads_service, $customer_id,
        $search_query);

      # Store a thread to retrieve the results.
      push @$threads, $thread;
    }

    # Wait for all pending requests to the current set of customer IDs to complete.
    my $results = [map { $_->join() } @$threads];

    print "Report results for query: $search_query\n";
    foreach my $result (@$results) {
      printf "Customer ID '%d' Number of results: %d IsSuccess? %s\n",
        $result->{customerId}, $result->{numResults},
        defined $result->{errorMessage}
        ? "No :-( Why? " . $result->{errorMessage}
        : "Yes!";
    }
  }

  return 1;
}

# Downloads the report from the specified customer ID.
sub download_report {
  my ($google_ads_service, $customer_id, $search_query) = @_;

  my $numResults   = 0;
  my $errorMessage = undef;

  # Ideally we should use the search stream request here. But there's a tricky
  # issue in the JSON::SL module which is a dependency of SearchStreamHandler:
  #
  # This will most likely not work with threads, although one would wonder why
  # you would want to use this module across threads.

  # Create a search Google Ads request that will retrieve the results using pages
  # of the specified page size.
  my $search_request =
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query
    });

  eval {
    my $iterator = Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
      service => $google_ads_service,
      request => $search_request
    });

    # Iterate over all rows in all pages to count the number or results.
    while ($iterator->has_next) {
      my $google_ads_row = $iterator->next;
      $numResults++;
    }
  };
  if ($@) {
    $errorMessage = $@ =~ /"message": "([^"]+)"/ ? $1 : "";
  }

  return {
    customerId   => $customer_id,
    numResults   => $numResults,
    errorMessage => $errorMessage
  };
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
GetOptions(
  "customer_ids=s"      => \@$customer_ids,
  "login_customer_id=s" => \$login_customer_id
);
$customer_ids = [$customer_id_1, $customer_id_2] unless @$customer_ids;

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_ids);

$api_client->set_login_customer_id($login_customer_id =~ s/-//gr)
  if $login_customer_id;

# Call the example.
parallel_report_download($api_client, [map { $_ =~ s/-//gr } @$customer_ids]);

=pod

=head1 NAME

parallel_report_download

=head1 DESCRIPTION

Shows how to download a set of reports from a list of accounts in parallel.

If you need to obtain a list of accounts, please see the get_account_hierarchy.pl
or list_accessible_customers.pl examples.

=head1 SYNOPSIS

parallel_report_download.pl [options]

    -help                       Show the help message.
    -customer_ids               The Google Ads customer IDs.
    -login_customer_id          [optional] The login customer ID.

=cut
