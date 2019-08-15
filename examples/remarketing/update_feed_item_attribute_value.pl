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
# This example updates a FeedItemAttributeValue in a flights feed. To
# create a flights feed, run the add_flights_feed.pl example. This example
# is specific to feeds of type DYNAMIC_FLIGHT. The attribute you are updating
# must be present on the feed. This example is specifically for updating the
# StringValue of an attribute.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::GoogleAdsClient;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V2::Resources::FeedItemAttributeValue;
use Google::Ads::GoogleAds::V2::Services::FeedItemService::FeedItemOperation;
use Google::Ads::GoogleAds::V2::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

require "$Bin/add_flights_feed.pl";

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id              = "INSERT_CUSTOMER_ID_HERE";
my $feed_id                  = "INSERT_FEED_ID_HERE";
my $feed_item_id             = "INSERT_FEED_ITEM_ID_HERE";
my $flight_placeholder_field = "INSERT_FLIGHT_PLACEHOLDER_FIELD_HERE";
my $attribute_value          = "INSERT_ATTRIBUTE_VALUE_HERE";

sub update_feed_item_attribute_value {
  my ($api_client, $customer_id, $feed_id, $feed_item_id,
    $flight_placeholder_field, $attribute_value)
    = @_;

  # Get the feed resource name.
  my $feed_resource_name =
    Google::Ads::GoogleAds::V2::Utils::ResourceNames::feed($customer_id,
    $feed_id);

  # Get a hash of the placeholder values and feed attributes.
  my $feed_attributes =
    get_feed($api_client, $customer_id, $feed_resource_name);

  # Get the ID of the attribute to update. This is needed to specify which
  # FeedItemAttributeValue will be updated in the given FeedItem.
  my $attribute_id = $feed_attributes->{uc($flight_placeholder_field)}{id};

  # Get the feed item resource name.
  my $feed_item_resource_name =
    Google::Ads::GoogleAds::V2::Utils::ResourceNames::feed_item($customer_id,
    $feed_id, $feed_item_id);

  # Retrieve the feed item and its associated attributes based on its resource name.
  my $feed_item =
    get_feed_item($api_client, $customer_id, $feed_item_resource_name);

  # Create the updated FeedItemAttributeValue.
  my $feed_item_attribute_value =
    Google::Ads::GoogleAds::V2::Resources::FeedItemAttributeValue->new({
      feedAttributeId => $attribute_id,
      stringValue     => $attribute_value
    });

  # Get the index of the attribute value that will be updated.
  my $attribute_index = get_attribute_index($feed_item, $attribute_id);

  # Set the attribute value of the FeedItem given its index relative to other attributes
  # in the FeedItem.
  $feed_item->{attributeValues}[$attribute_index] = $feed_item_attribute_value;

  # Create a feed item operation.
  my $feed_item_operation =
    Google::Ads::GoogleAds::V2::Services::FeedItemService::FeedItemOperation->
    new({
      update     => $feed_item,
      updateMask => all_set_fields_of($feed_item)});

  # Update the feed item.
  my $feed_item_response = $api_client->FeedItemService()->mutate({
      customerId => $customer_id,
      operations => [$feed_item_operation]});

  printf "Updated feed item with resource name: %s.\n",
    $feed_item_response->{results}[0]{resourceName};

  return 1;
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
# FeedItemAttributeValue will be updated in the given FeedItem.
sub get_attribute_index {
  my ($feed_item, $attribute_id) = @_;

  my $attribute_index = -1;
  # Loop through attribute values to find the index of the FeedItemAttributeValue to update.
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
my $api_client =
  Google::Ads::GoogleAds::GoogleAdsClient->new({version => "V2"});

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s"              => \$customer_id,
  "feed_id=i"                  => \$feed_id,
  "feed_item_id=i"             => \$feed_item_id,
  "flight_placeholder_field=s" => \$flight_placeholder_field,
  "attribute_value=s"          => \$attribute_value
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $feed_id, $feed_item_id,
  $flight_placeholder_field, $attribute_value);

# Call the example.
update_feed_item_attribute_value($api_client, $customer_id =~ s/-//gr,
  $feed_id, $feed_item_id, $flight_placeholder_field, $attribute_value);

=pod

=head1 NAME

update_feed_item_attribute_value

=head1 DESCRIPTION

This example updates a FeedItemAttributeValue in a flights feed. To create a
flights feed, run the add_flights_feed.pl example. This example is specific to
feeds of type DYNAMIC_FLIGHT. The attribute you are updating must be present on
the feed. This example is specifically for updating the StringValue of an attribute.

=head1 SYNOPSIS

update_feed_item_attribute_value.pl [options]

    -help                           Show the help message.
    -customer_id                    The Google Ads customer ID.
    -feed_id                        The feed ID.
    -feed_item_id                   The feed item ID.
    -flight_placeholder_field       The placeholder type for the attribute to update.
    -attribute_value                The string value with which to update the FeedAttributeValue.

=cut
