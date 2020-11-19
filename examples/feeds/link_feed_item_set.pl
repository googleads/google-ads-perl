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
# Links the specified feed item set to the specified feed item. The specified feed
# item set must not be created as a dynamic set, i.e., both
# FeedItemSet::dynamicLocationSetFilter and FeedItemSet::dynamicAffiliateLocationSetFilter
# must not be set.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V6::Resources::FeedItemSetLink;
use
  Google::Ads::GoogleAds::V6::Services::FeedItemSetLinkService::FeedItemSetLinkOperation;
use Google::Ads::GoogleAds::V6::Utils::ResourceNames;

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
my $feed_item_id     = "INSERT_FEED_ITEM_ID_HERE";

sub link_feed_item_set {
  my ($api_client, $customer_id, $feed_id, $feed_item_set_id, $feed_item_id) =
    @_;

  # Create a new feed item set link that binds the specified feed item set and
  # feed item.
  my $feed_item_set_link =
    Google::Ads::GoogleAds::V6::Resources::FeedItemSetLink->new({
      feedItemSet =>
        Google::Ads::GoogleAds::V6::Utils::ResourceNames::feed_item_set(
        $customer_id, $feed_id, $feed_item_set_id
        ),
      feedItem => Google::Ads::GoogleAds::V6::Utils::ResourceNames::feed_item(
        $customer_id, $feed_id, $feed_item_id
      )});

  # Construct a feed item set link operation.
  my $feed_item_set_link_operation =
    Google::Ads::GoogleAds::V6::Services::FeedItemSetLinkService::FeedItemSetLinkOperation
    ->new({
      create => $feed_item_set_link
    });

  # Issue a mutate request to add the feed item set link on the server.
  my $feed_item_set_links_response =
    $api_client->FeedItemSetLinkService()->mutate({
      customerId => $customer_id,
      operations => [$feed_item_set_link_operation]});

  # Print some information about the created feed item set link.
  printf
    "Created a feed item set link with resource name '%s'.\n",
    $feed_item_set_links_response->{results}[0]{resourceName};

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
  "feed_item_set_id=i" => \$feed_item_set_id,
  "feed_item_id=i"     => \$feed_item_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $feed_id, $feed_item_set_id, $feed_item_id);

# Call the example.
link_feed_item_set($api_client, $customer_id =~ s/-//gr,
  $feed_id, $feed_item_set_id, $feed_item_id);

=pod

=head1 NAME

link_feed_item_set

=head1 DESCRIPTION

Links the specified feed item set to the specified feed item. The specified feed
item set must not be created as a dynamic set, i.e., both
FeedItemSet::dynamicLocationSetFilter and FeedItemSet::dynamicAffiliateLocationSetFilter
must not be set.

=head1 SYNOPSIS

link_feed_item_set.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -feed_id                    The feed ID that the specified feed item set is
                                associated with.
    -feed_item_set_id           The ID of specified feed item set.
    -feed_item_id               The ID of specified feed item.

=cut
