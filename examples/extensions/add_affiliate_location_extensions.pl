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
# This code example adds a feed that syncs retail addresses for a given retail
# chain ID and associates the feed with a campaign for serving affiliate location
# extensions.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use Google::Ads::GoogleAds::V6::Resources::Feed;
use Google::Ads::GoogleAds::V6::Resources::AffiliateLocationFeedData;
use Google::Ads::GoogleAds::V6::Resources::CampaignFeed;
use Google::Ads::GoogleAds::V6::Common::MatchingFunction;
use Google::Ads::GoogleAds::V6::Enums::AffiliateLocationFeedRelationshipTypeEnum
  qw(GENERAL_RETAILER);
use Google::Ads::GoogleAds::V6::Enums::FeedOriginEnum qw(GOOGLE);
use Google::Ads::GoogleAds::V6::Enums::PlaceholderTypeEnum
  qw(AFFILIATE_LOCATION);
use Google::Ads::GoogleAds::V6::Enums::AffiliateLocationPlaceholderFieldEnum
  qw(CHAIN_ID);
use
  Google::Ads::GoogleAds::V6::Services::CustomerFeedService::CustomerFeedOperation;
use Google::Ads::GoogleAds::V6::Services::FeedService::FeedOperation;
use
  Google::Ads::GoogleAds::V6::Services::CampaignFeedService::CampaignFeedOperation;
use Google::Ads::GoogleAds::V6::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
use Data::Uniqid qw(uniqid);
use Time::HiRes qw(sleep);

# The maximum number of attempts to make to retrieve the feed mapping before
# throwing an exception.
use constant MAX_FEED_MAPPING_RETRIEVAL_ATTEMPTS => 10;

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";
# The retail chain ID. For a complete list of valid retail chain IDs, see
# https://developers.google.com/adwords/api/docs/appendix/codes-formats#chain-ids.
my $chain_id = "INSERT_CHAIN_ID_HERE";
# The campaign ID for which the affiliate location extensions are added.
my $campaign_id = "INSERT_CAMPAIGN_ID_HERE";
# Optional: Delete all existing location extension feeds. This is required for
# this code example to run correctly more than once.
# 1. Google Ads only allows one location extension feed per email address.
# 2. A Google Ads account cannot have a location extension feed and an affiliate
# location extension feed at the same time.
my $delete_existing_feeds = 0;

sub add_affiliate_location_extensions {
  my ($api_client, $customer_id, $chain_id, $campaign_id,
    $delete_existing_feeds) = @_;

  if ($delete_existing_feeds) {
    delete_location_extension_feeds($api_client, $customer_id);
  }

  my $feed_resource_name =
    create_affiliate_location_extension_feed($api_client, $customer_id,
    $chain_id);

  # After the completion of the feed creation operation above the added feed
  # will not be available for usage in a campaign feed until the feed mapping
  # is created.
  # We will wait with an exponential back-off policy until the feed mapping has
  # been created.
  my $feed_mapping =
    wait_for_feed_to_be_ready($api_client, $customer_id, $feed_resource_name);

  create_campaign_feed($api_client, $customer_id, $campaign_id, $feed_mapping,
    $feed_resource_name, $chain_id);

  return 1;
}

# Deletes the existing location extension feeds.
sub delete_location_extension_feeds {
  my ($api_client, $customer_id) = @_;

  # To delete a location extension feed, you need to
  # 1. Delete the customer feed so that the location extensions from the feed stop serving.
  # 2. Delete the feed so that Google Ads will no longer sync from the GMB account.
  my $customer_feeds =
    get_location_extension_customer_feeds($api_client, $customer_id);
  if (scalar @$customer_feeds > 0) {
    # Optional: You may also want to delete the campaign and ad group feeds.
    remove_customer_feeds($api_client, $customer_id, $customer_feeds);
  }

  my $feeds = get_location_extension_feeds($api_client, $customer_id);
  if (scalar @$feeds > 0) {
    remove_feeds($api_client, $customer_id, $feeds);
  }
}

# Gets the existing location extension customer feeds.
sub get_location_extension_customer_feeds {
  my ($api_client, $customer_id) = @_;

  my $customer_feeds = [];

  my $google_ads_service = $api_client->GoogleAdsService();
  # Create the query. A location extension customer feed can be identified by
  # filtering for placeholder_types as LOCATION (location extension feeds) or
  # placeholder_types as AFFILIATE_LOCATION (affiliate location extension feeds).
  my $search_query =
    "SELECT customer_feed.resource_name FROM customer_feed " .
    "WHERE customer_feed.placeholder_types CONTAINS " .
    "ANY(LOCATION, AFFILIATE_LOCATION) AND customer_feed.status = ENABLED";

  my $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $google_ads_service,
      request => {
        customerId => $customer_id,
        query      => $search_query
      }});

  # Issue a search stream request.
  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row = shift;
      push @$customer_feeds, $google_ads_row->{customerFeed};
    });

  return $customer_feeds;
}

# Removes the customer feeds.
sub remove_customer_feeds {
  my ($api_client, $customer_id, $customer_feeds) = @_;

  my $operations = [];
  foreach my $customer_feed (@$customer_feeds) {
    push @$operations,
      Google::Ads::GoogleAds::V6::Services::CustomerFeedService::CustomerFeedOperation
      ->new({remove => $customer_feed->{resourceName}});
  }

  # Issue a mutate request to remove the customer feeds.
  $api_client->CustomerFeedService()->mutate({
    customerId => $customer_id,
    operations => $operations
  });
}

# Gets the existing location extension feeds.
sub get_location_extension_feeds {
  my ($api_client, $customer_id) = @_;

  my $feeds = [];

  my $google_ads_service = $api_client->GoogleAdsService();
  # Create the query.
  my $search_query = "SELECT feed.resource_name FROM feed " .
    "WHERE feed.status = ENABLED AND feed.origin = USER";

  my $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $google_ads_service,
      request => {
        customerId => $customer_id,
        query      => $search_query
      }});

  # Issue a search stream request.
  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row = shift;
      push @$feeds, $google_ads_row->{feed};
    });

  return $feeds;
}

# Removes the feeds.
sub remove_feeds {
  my ($api_client, $customer_id, $feeds) = @_;

  my $operations = [];
  foreach my $feed (@$feeds) {
    push @$operations,
      Google::Ads::GoogleAds::V6::Services::FeedService::FeedOperation->new(
      {remove => $feed->{resourceName}});
  }

  # Issue a mutate request to remove the feeds.
  $api_client->FeedService()->mutate({
    customerId => $customer_id,
    operations => $operations
  });
}

# Creates the affiliate location extension feed.
# [START add_affiliate_location_extensions]
sub create_affiliate_location_extension_feed {
  my ($api_client, $customer_id, $chain_id) = @_;

  # Create a feed that will sync to retail addresses for a given retail chain ID.
  # Do not add feed attributes, Google Ads will add them automatically because
  # this will be a system generated feed.
  my $feed = Google::Ads::GoogleAds::V6::Resources::Feed->new({
      name => "Affiliate Location Extension feed #" . uniqid(),
      affiliateLocationFeedData =>
        Google::Ads::GoogleAds::V6::Resources::AffiliateLocationFeedData->new({
          chainIds         => [$chain_id],
          relationshipType => GENERAL_RETAILER
        }
        ),
      # Since this feed's contents will be managed by Google, you must set its
      # origin to GOOGLE.
      origin => GOOGLE
    });

  # Create the feed operation.
  my $operation =
    Google::Ads::GoogleAds::V6::Services::FeedService::FeedOperation->new({
      create => $feed
    });

  # Issue a mutate request to add the feed and print some information.
  my $response = $api_client->FeedService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});
  my $feed_resource_name = $response->{results}[0]{resourceName};
  printf
    "Affiliate location extension feed created with resource name: '%s'.\n",
    $feed_resource_name;

  return $feed_resource_name;
}
# [END add_affiliate_location_extensions]

# Waits for the affiliate location extension feed to be ready.
# [START add_affiliate_location_extensions_2]
sub wait_for_feed_to_be_ready {
  my ($api_client, $customer_id, $feed_resource_name) = @_;

  my $num_attempts = 0;
  while ($num_attempts < MAX_FEED_MAPPING_RETRIEVAL_ATTEMPTS) {
    # Once you create a feed, Google's servers will setup the feed by creating
    # feed attributes and feed mapping. Once the feed mapping is created, it is
    # ready to be used for creating customer feed.
    # This process is asynchronous, so we wait until the feed mapping is created,
    # performing exponential backoff.
    my $feed_mapping =
      get_affiliate_location_extension_feed_mapping($api_client, $customer_id,
      $feed_resource_name);

    if (!$feed_mapping) {
      $num_attempts++;
      my $sleep_seconds = 5 * (2**$num_attempts);
      printf "Checked: %d time(s). Feed is not ready yet. " .
        "Waiting %d seconds before trying again.\n",
        $num_attempts,
        $sleep_seconds;
      sleep($sleep_seconds);
    } else {
      printf "Feed '%s' is now ready.\n", $feed_resource_name;
      return $feed_mapping;
    }
  }

  die(
    sprintf "The affiliate location feed mapping is still not ready " .
      "after %d attempt(s).\n",
    MAX_FEED_MAPPING_RETRIEVAL_ATTEMPTS
  );
}
# [END add_affiliate_location_extensions_2]

# Gets the affiliate location extension feed mapping.
# [START add_affiliate_location_extensions_1]
sub get_affiliate_location_extension_feed_mapping {
  my ($api_client, $customer_id, $feed_resource_name) = @_;

  # Create a query that retrieves the feed mapping.
  my $search_query =
    "SELECT feed_mapping.resource_name, " .
    "feed_mapping.attribute_field_mappings, " .
    "feed_mapping.status FROM feed_mapping " .
    "WHERE feed_mapping.feed = '$feed_resource_name' " .
    "AND feed_mapping.status = ENABLED " .
    "AND feed_mapping.placeholder_type = AFFILIATE_LOCATION LIMIT 1";

  # Issue a search request.
  my $response = $api_client->GoogleAdsService()->search({
    customerId              => $customer_id,
    query                   => $search_query,
    returnTotalResultsCount => "true"
  });

  return $response->{totalResultsCount} && $response->{totalResultsCount} == 1
    ? $response->{results}[0]{feedMapping}
    : undef;
}
# [END add_affiliate_location_extensions_1]

# Create the campaign feed.
# [START add_affiliate_location_extensions_3]
sub create_campaign_feed {
  my ($api_client, $customer_id, $campaign_id, $feed_mapping,
    $feed_resource_name, $chain_id)
    = @_;

  my $feed_id                   = $1 if $feed_resource_name =~ /(\d+)$/;
  my $attribute_id_for_chain_id = get_attribute_id_for_chain_id($feed_mapping);
  my $matching_function =
    "IN(FeedAttribute[$feed_id, $attribute_id_for_chain_id], $chain_id)";

  # Add a campaign feed that associates the feed with this campaign for the
  # AFFILIATE_LOCATION placeholder type.
  my $campaign_feed = Google::Ads::GoogleAds::V6::Resources::CampaignFeed->new({
      feed             => $feed_resource_name,
      placeholderTypes => AFFILIATE_LOCATION,
      matchingFunction =>
        Google::Ads::GoogleAds::V6::Common::MatchingFunction->new({
          functionString => $matching_function
        }
        ),
      campaign => Google::Ads::GoogleAds::V6::Utils::ResourceNames::campaign(
        $customer_id, $campaign_id
      )});

  # Create the campaign feed operation.
  my $operation =
    Google::Ads::GoogleAds::V6::Services::CampaignFeedService::CampaignFeedOperation
    ->new({
      create => $campaign_feed
    });

  # Issue a mutate request to add the campaign feed and print some information.
  my $response = $api_client->CampaignFeedService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});

  printf
    "Campaign feed created with resource name: '%s'.\n",
    $response->{results}[0]{resourceName};
}
# [END add_affiliate_location_extensions_3]

# Gets the feed attribute ID for the retail chain ID.
# [START add_affiliate_location_extensions_4]
sub get_attribute_id_for_chain_id {
  my ($feed_mapping) = @_;

  foreach my $field_mapping (@{$feed_mapping->{attributeFieldMappings}}) {
    if ($field_mapping->{affiliateLocationField} eq CHAIN_ID) {
      return $field_mapping->{feedAttributeId};
    }
  }

  die "Affiliate location feed mapping isn't setup correctly.";
}
# [END add_affiliate_location_extensions_4]

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
  "customer_id=s"           => \$customer_id,
  "chain_id=i"              => \$chain_id,
  "campaign_id=i"           => \$campaign_id,
  "delete_existing_feeds=i" => \$delete_existing_feeds,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $chain_id, $campaign_id);

# Call the example.
add_affiliate_location_extensions($api_client, $customer_id =~ s/-//gr,
  $chain_id, $campaign_id, $delete_existing_feeds);

=pod

=head1 NAME

add_affiliate_location_extensions

=head1 DESCRIPTION

This code example adds a feed that syncs retail addresses for a given retail
chain ID and associates the feed with a campaign for serving affiliate location
extensions.

=head1 SYNOPSIS

add_affiliate_location_extensions.pl [options]

    -help                               Show the help message.
    -customer_id                        The Google Ads customer ID.
    -chain_id                           The retail chain ID.
    -campaign_id                        The campaign ID for which the affiliate
                                        location extensions are added.
    -delete_existing_feeds              [optional] Non-zero if it should delete
                                        the existing feeds.

=cut
