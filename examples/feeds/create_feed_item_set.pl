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
# Creates a new feed item set for a specified feed, which must belong to either a
# Google Ads location extension or an affiliate extension. This is equivalent to
# a "location group" in the Google Ads UI.
# See https://support.google.com/google-ads/answer/9288588 for more detail.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V14::Resources::FeedItemSet;
use Google::Ads::GoogleAds::V14::Common::DynamicLocationSetFilter;
use Google::Ads::GoogleAds::V14::Common::BusinessNameFilter;
use Google::Ads::GoogleAds::V14::Common::DynamicAffiliateLocationSetFilter;
use Google::Ads::GoogleAds::V14::Enums::FeedItemSetStringFilterTypeEnum
  qw(EXACT);
use
  Google::Ads::GoogleAds::V14::Services::FeedItemSetService::FeedItemSetOperation;
use Google::Ads::GoogleAds::V14::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";
my $feed_id     = "INSERT_FEED_ID_HERE";

sub create_feed_item_set {
  my ($api_client, $customer_id, $feed_id) = @_;

  # Create a new feed item set.
  my $feed_item_set = Google::Ads::GoogleAds::V14::Resources::FeedItemSet->new({
      feed => Google::Ads::GoogleAds::V14::Utils::ResourceNames::feed(
        $customer_id, $feed_id
      ),
      displayName => "Feed Item Set #" . uniqid()});

  # A feed item set can be created as a dynamic set by setting an optional filter
  # field below. If your feed is a location extension, uncomment the code that
  # sets 'dynamicLocationSetFilter'. If your feed is an affiliate extension, set
  # 'dynamicAffiliateLocationSetFilter' instead.
  # 1) Location extension.
  # $feed_item_set->{dynamicLocationSetFilter} =
  #   Google::Ads::GoogleAds::V14::Common::DynamicLocationSetFilter->new({
  #     # Add a filter for a business name using exact matching.
  #     businessNameFilter =>
  #       Google::Ads::GoogleAds::V14::Common::BusinessNameFilter->new({
  #         businessName => "INSERT_YOUR_BUSINESS_NAME_HERE",
  #         filterType   => EXACT
  #       })});
  # 2) Affiliate extension.
  # $feed_item_set->{dynamicAffiliateLocationSetFilter} =
  #   Google::Ads::GoogleAds::V14::Common::DynamicAffiliateLocationSetFilter->new({
  #     chainIds => [INSERT_CHAIN_IDS_HERE]});

  # Construct an operation that will create a new feed item set.
  my $feed_item_set_operation =
    Google::Ads::GoogleAds::V14::Services::FeedItemSetService::FeedItemSetOperation
    ->new({
      create => $feed_item_set
    });

  # Issue a mutate request to add the feed item set on the server.
  my $feed_item_sets_response = $api_client->FeedItemSetService()->mutate({
      customerId => $customer_id,
      operations => [$feed_item_set_operation]});

  # Print some information about the created feed item set.
  printf
    "Created a feed item set with resource name '%s'.\n",
    $feed_item_sets_response->{results}[0]{resourceName};

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
  "customer_id=s" => \$customer_id,
  "feed_id=i"     => \$feed_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $feed_id);

# Call the example.
create_feed_item_set($api_client, $customer_id =~ s/-//gr, $feed_id);

=pod

=head1 NAME

create_feed_item_set

=head1 DESCRIPTION

Creates a new feed item set for a specified feed, which must belong to either a
Google Ads location extension or an affiliate extension. This is equivalent to
a "location group" in the Google Ads UI.
See https://support.google.com/google-ads/answer/9288588 for more detail.

=head1 SYNOPSIS

create_feed_item_set.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -feed_id                    The ID of feed that a newly created feed item set
                                will be associated with.

=cut
