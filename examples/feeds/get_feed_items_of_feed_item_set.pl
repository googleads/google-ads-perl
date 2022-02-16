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
# This example gets all feed items of the specified feed item set by fetching all
# feed item set links. To create a new feed item set, run create_feed_item_set.pl.
# To link a feed item to a feed item set, run link_feed_item_set.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use
  Google::Ads::GoogleAds::V10::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;
use Google::Ads::GoogleAds::V10::Utils::ResourceNames;

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
my $customer_id      = "INSERT_CUSTOMER_ID_HERE";
my $feed_id          = "INSERT_FEED_ID_HERE";
my $feed_item_set_id = "INSERT_FEED_ITEM_SET_ID_HERE";

sub get_feed_items_of_feed_item_set {
  my ($api_client, $customer_id, $feed_id, $feed_item_set_id) = @_;

  # Create a query that retrieves all feed item set links associated with the
  # specified feed item set.
  my $search_query =
    sprintf "SELECT feed_item_set_link.feed_item FROM feed_item_set_link " .
    "WHERE feed_item_set_link.feed_item_set = '%s'",
    Google::Ads::GoogleAds::V10::Utils::ResourceNames::feed_item_set(
    $customer_id, $feed_id, $feed_item_set_id);

  # Create a search Google Ads stream request that will retrieve the feed item set links.
  my $search_stream_request =
    Google::Ads::GoogleAds::V10::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query
    });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $google_ads_service,
      request => $search_stream_request
    });

  printf "The feed items with the following resource names are linked with " .
    "the feed item set with ID %d:\n",
    $feed_item_set_id;

  # Iterate over all rows in all messages and print the requested field values
  # for the feed item set link in each row.
  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row = shift;
      printf "'%s'\n", $google_ads_row->{feedItemSetLink}{feedItem};
    });

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
GetOptions(
  "customer_id=s"      => \$customer_id,
  "feed_id=i"          => \$feed_id,
  "feed_item_set_id=i" => \$feed_item_set_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $feed_id, $feed_item_set_id);

# Call the example.
get_feed_items_of_feed_item_set($api_client, $customer_id =~ s/-//gr,
  $feed_id, $feed_item_set_id);

=pod

=head1 NAME

get_feed_items_of_feed_item_set

=head1 DESCRIPTION

This example gets all feed items of the specified feed item set by fetching all
feed item set links. To create a new feed item set, run create_feed_item_set.pl.
To link a feed item to a feed item set, run link_feed_item_set.pl.

=head1 SYNOPSIS

get_feed_items_of_feed_item_set.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -feed_id                    The feed ID that the specified feed item set is
                                associated with.
    -feed_item_set_id           The ID of specified feed item set.

=cut
