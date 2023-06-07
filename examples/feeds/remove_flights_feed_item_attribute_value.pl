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
# Removes a feed item attribute value of a feed item in a flights feed. To create
# a flights feed, run the add_flights_feed.pl example. This example is specific
# to feeds of type DYNAMIC_FLIGHT. The attribute you are removing must be present
# on the feed.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V14::Resources::FeedItemAttributeValue;
use Google::Ads::GoogleAds::V14::Services::FeedItemService::FeedItemOperation;
use Google::Ads::GoogleAds::V14::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

require "$Bin/../remarketing/add_flights_feed.pl";

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id                   = "INSERT_CUSTOMER_ID_HERE";
my $feed_id                       = "INSERT_FEED_ID_HERE";
my $feed_item_id                  = "INSERT_FEED_ITEM_ID_HERE";
my $flight_placeholder_field_name = "INSERT_FLIGHT_PLACEHOLDER_FIELD_NAME_HERE";

sub remove_flights_feed_item_attribute_value {
  my ($api_client, $customer_id, $feed_id, $feed_item_id,
    $flight_placeholder_field_name)
    = @_;

  # [START remove_flights_feed_item_attribute_value]
  # Get the feed resource name.
  my $feed_resource_name =
    Google::Ads::GoogleAds::V14::Utils::ResourceNames::feed($customer_id,
    $feed_id);

  # Get a hash of the placeholder values and feed attributes.
  my $feed_attributes =
    get_feed($api_client, $customer_id, $feed_resource_name);

  # Get the feed item resource name.
  my $feed_item_resource_name =
    Google::Ads::GoogleAds::V14::Utils::ResourceNames::feed_item($customer_id,
    $feed_id, $feed_item_id);

  # Remove the attribute from the feed item.
  my $feed_item =
    remove_attribute_value_from_feed_item($api_client, $customer_id,
    $feed_attributes, $feed_item_resource_name,
    uc($flight_placeholder_field_name));
  # [END remove_flights_feed_item_attribute_value]

  # [START remove_flights_feed_item_attribute_value_1]
  # Create a feed item operation.
  my $feed_item_operation =
    Google::Ads::GoogleAds::V14::Services::FeedItemService::FeedItemOperation->
    new({
      update     => $feed_item,
      updateMask => all_set_fields_of($feed_item)});

  # Update the feed item.
  my $feed_items_response = $api_client->FeedItemService()->mutate({
      customerId => $customer_id,
      operations => [$feed_item_operation]});

  printf "Updated feed item with resource name: '%s'.\n",
    $feed_items_response->{results}[0]{resourceName};
  # [END remove_flights_feed_item_attribute_value_1]

  return 1;
}

# Removes a feed item attribute value.
sub remove_attribute_value_from_feed_item {
  my ($api_client, $customer_id,
    $feed_attributes, $feed_item_resource_name, $flight_placeholder_field_name)
    = @_;

  # Get the ID of the FeedAttribute for the placeholder field.
  my $attribute_id = $feed_attributes->{$flight_placeholder_field_name}{id};

  # Retrieve the feed item and its associated attributes based on its resource name.
  my $feed_item =
    get_feed_item($api_client, $customer_id, $feed_item_resource_name);

  # Get the index of the attribute value that will be removed.
  my $attribute_index = get_attribute_index($feed_item, $attribute_id);

  # Return the feed item with the removed FeedItemAttributeValue. Any FeedItemAttributeValue
  # that is not included in the updated FeedItem will be removed from the FeedItem, which is
  # why you must create the FeedItem from the existing FeedItem and set the field(s) that will
  # be removed.
  splice @{$feed_item->{attributeValues}}, $attribute_index, 1;
  return $feed_item;
}

# Retrieves a feed item and its attribute values given a resource name.
sub get_feed_item {
  my ($api_client, $customer_id, $feed_item_resource_name) = @_;

  # Construct the search query.
  my $search_query =
    sprintf "SELECT feed_item.attribute_values FROM feed_item " .
    "WHERE feed_item.resource_name = '%s'", $feed_item_resource_name;

  my $search_response = $api_client->GoogleAdsService()->search({
    customerId => $customer_id,
    query      => $search_query
  });

  return $search_response->{results}[0]{feedItem};
}

# Gets the index of the attribute value. This is needed to specify which
# FeedItemAttributeValue will be removed in the given FeedItem.
sub get_attribute_index {
  my ($feed_item, $attribute_id) = @_;

  my $attribute_index = -1;
  # Loop through attribute values to find the index of the FeedItemAttributeValue to remove.
  while (my ($index, $attribute_value) = each @{$feed_item->{attributeValues}})
  {
    if ($attribute_value->{feedAttributeId} == $attribute_id) {
      $attribute_index = $index;
      last;
    }
  }

  # Die if the attribute value is not found.
  die "No matching feed attribute for feed item attribute value: " .
    $attribute_id
    if $attribute_index == -1;

  return $attribute_index;
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
  "customer_id=s"                   => \$customer_id,
  "feed_id=i"                       => \$feed_id,
  "feed_item_id=i"                  => \$feed_item_id,
  "flight_placeholder_field_name=s" => \$flight_placeholder_field_name
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $feed_id, $feed_item_id,
  $flight_placeholder_field_name);

# Call the example.
remove_flights_feed_item_attribute_value($api_client, $customer_id =~ s/-//gr,
  $feed_id, $feed_item_id, $flight_placeholder_field_name);

=pod

=head1 NAME

remove_flights_feed_item_attribute_value

=head1 DESCRIPTION

Removes a feed item attribute value of a feed item in a flights feed. To create
a flights feed, run the add_flights_feed.pl example. This example is specific to
feeds of type DYNAMIC_FLIGHT. The attribute you are removing must be present on
the feed.

=head1 SYNOPSIS

remove_flights_feed_item_attribute_value.pl [options]

    -help                               Show the help message.
    -customer_id                        The Google Ads customer ID.
    -feed_id                            The ID of the feed containing the feed
                                        item to be updated.
    -feed_item_id                       The ID of the feed item to be updated.
    -flight_placeholder_field_name      The flight placeholder field name for the
                                        attribute to be removed.

=cut
