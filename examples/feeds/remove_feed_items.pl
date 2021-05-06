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
# This example removes feed items from a feed.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V7::Services::FeedItemService::FeedItemOperation;
use Google::Ads::GoogleAds::V7::Utils::ResourceNames;

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
my $customer_id   = "INSERT_CUSTOMER_ID_HERE";
my $feed_id       = "INSERT_FEED_ID_HERE";
my $feed_item_id1 = "INSERT_FEED_ITEM_ID_1_HERE";
my $feed_item_id2 = "INSERT_FEED_ITEM_ID_2_HERE";
my $feed_item_ids = [];

sub remove_feed_items {
  my ($api_client, $customer_id, $feed_id, $feed_item_ids) = @_;

  my $feed_item_operations = [];
  # Create the remove operations.
  for my $feed_item_id (@$feed_item_ids) {
    my $feed_item_resource_name =
      Google::Ads::GoogleAds::V7::Utils::ResourceNames::feed_item($customer_id,
      $feed_id, $feed_item_id);

    push @$feed_item_operations,
      Google::Ads::GoogleAds::V7::Services::FeedItemService::FeedItemOperation
      ->new({
        remove => $feed_item_resource_name
      });
  }

  # Remove the feed items.
  my $feed_items_response = $api_client->FeedItemService()->mutate({
      customerId => $customer_id,
      operations => [$feed_item_operations]});

  foreach my $feed_item_result (@{$feed_items_response->{results}}) {
    printf "Removed feed item with resource name '%s'.\n",
      $feed_item_result->{resourceName};
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
GetOptions(
  "customer_id=s"   => \$customer_id,
  "feed_id=i"       => \$feed_id,
  "feed_item_ids=s" => \@$feed_item_ids
);
$feed_item_ids = [$feed_item_id1, $feed_item_id2] unless @$feed_item_ids;

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $feed_id, $feed_item_ids);

# Call the example.
remove_feed_items($api_client, $customer_id =~ s/-//gr,
  $feed_id, $feed_item_ids);

=pod

=head1 NAME

remove_feed_items

=head1 DESCRIPTION

This example removes feed items from a feed.

=head1 SYNOPSIS

remove_feed_items.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -feed_id                    The feed ID.
    -feed_item_ids              The IDs of the feed items to remove.

=cut
