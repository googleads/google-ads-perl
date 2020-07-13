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
# This example adds a flights feed, creates the associated feed mapping, and
# adds a feed item.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V4::Resources::FeedAttribute;
use Google::Ads::GoogleAds::V4::Resources::Feed;
use Google::Ads::GoogleAds::V4::Resources::AttributeFieldMapping;
use Google::Ads::GoogleAds::V4::Resources::FeedMapping;
use Google::Ads::GoogleAds::V4::Resources::FeedItemAttributeValue;
use Google::Ads::GoogleAds::V4::Resources::FeedItem;
use Google::Ads::GoogleAds::V4::Enums::FeedAttributeTypeEnum
  qw(STRING URL_LIST);
use Google::Ads::GoogleAds::V4::Enums::FlightPlaceholderFieldEnum
  qw(FLIGHT_DESCRIPTION DESTINATION_ID FLIGHT_PRICE FLIGHT_SALE_PRICE FINAL_URLS);
use Google::Ads::GoogleAds::V4::Enums::PlaceholderTypeEnum qw(DYNAMIC_FLIGHT);
use Google::Ads::GoogleAds::V4::Services::FeedService::FeedOperation;
use
  Google::Ads::GoogleAds::V4::Services::FeedMappingService::FeedMappingOperation;
use Google::Ads::GoogleAds::V4::Services::FeedItemService::FeedItemOperation;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
use Data::Uniqid qw(uniqid);

use constant PAGE_SIZE => 1000;

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub add_flights_feed {
  my ($api_client, $customer_id) = @_;

  # Create a new flights feed.
  my $feed_resource_name = create_feed($api_client, $customer_id);

  # Get the newly created feed's attributes and package them into a hash. This read
  # operation is required to retrieve the attribute IDs.
  my $feed_attributes =
    get_feed($api_client, $customer_id, $feed_resource_name);

  # Create a feed mapping.
  create_feed_mapping($api_client, $customer_id, $feed_attributes,
    $feed_resource_name);

  # Create a feed item.
  create_feed_item($api_client, $customer_id, $feed_attributes,
    $feed_resource_name);

  return 1;
}

# Creates a flight feed.
sub create_feed {
  my ($api_client, $customer_id) = @_;

  # Create a Flight Description attribute.
  my $flight_description_attribute =
    Google::Ads::GoogleAds::V4::Resources::FeedAttribute->new({
      type => STRING,
      name => "Flight Description"
    });
  # Create a Destination ID attribute.
  my $destination_id_attribute =
    Google::Ads::GoogleAds::V4::Resources::FeedAttribute->new({
      type => STRING,
      name => "Destination ID"
    });
  # Create a Flight Price attribute.
  my $flight_price_attribute =
    Google::Ads::GoogleAds::V4::Resources::FeedAttribute->new({
      type => STRING,
      name => "Flight Price"
    });
  # Create a Flight Sale Price attribute.
  my $flight_sales_price_attribute =
    Google::Ads::GoogleAds::V4::Resources::FeedAttribute->new({
      type => STRING,
      name => "Flight Sale Price"
    });
  # Create a Final URLs attribute.
  my $final_urls_Attribute =
    Google::Ads::GoogleAds::V4::Resources::FeedAttribute->new({
      type => URL_LIST,
      name => "Final URLs"
    });

  # Create a feed.
  my $feed = Google::Ads::GoogleAds::V4::Resources::Feed->new({
      name       => "Flights Feed #" . uniqid(),
      attributes => [
        $flight_description_attribute, $destination_id_attribute,
        $flight_price_attribute,       $flight_sales_price_attribute,
        $final_urls_Attribute
      ]});

  # Create a feed operation.
  my $feed_operation =
    Google::Ads::GoogleAds::V4::Services::FeedService::FeedOperation->new(({
      create => $feed
    }));

  # Add the feed.
  my $feed_response = $api_client->FeedService()->mutate({
      customerId => $customer_id,
      operations => [$feed_operation]});

  my $feed_resource_name = $feed_response->{results}[0]{resourceName};

  printf "Feed with resource name '%s' was created.\n", $feed_resource_name;

  return $feed_resource_name;
}

# Retrieves details about a feed. The initial query retrieves the FeedAttributes, or columns,
# of the feed. Each FeedAttribute will also include the FeedAttributeId, which will be used in
# a subsequent step. The example then inserts a new key, value pair into a hash for each
# FeedAttribute, which is the return value of the method. The keys are the placeholder types
# that the columns will be. The values are the FeedAttributes.
sub get_feed {
  my ($api_client, $customer_id, $feed_resource_name) = @_;

  # Construct the search query.
  my $search_query =
    sprintf "SELECT feed.attributes FROM feed WHERE feed.resource_name = '%s'",
    $feed_resource_name;

  my $search_response = $api_client->GoogleAdsService()->search({
    customerId => $customer_id,
    query      => $search_query,
    pageSize   => PAGE_SIZE
  });

  # Get the first result because we only need the single feed item we created previously.
  my $google_ads_row = $search_response->{results}[0];

  # Get the attributes list from the feed and create a hash with keys of each attribute and
  # values of each corresponding ID.
  my $feed_attribute_list = $google_ads_row->{feed}{attributes};

  # Create a hash to return.
  my $feed_attributes = {};
  # Loop through the feed attributes to populate the hash.
  foreach my $feed_attribute (@$feed_attribute_list) {
    my $feed_attribute_name = $feed_attribute->{name};

    # The full list of FlightPlaceholderFields can be found here
    # https://developers.google.com/google-ads/api/reference/rpc/google.ads.googleads.[INSERT_VERSION].enums#flightplaceholderfieldenum.
    if ($feed_attribute_name eq "Flight Description") {
      $feed_attributes->{FLIGHT_DESCRIPTION} = $feed_attribute;
    } elsif ($feed_attribute_name eq "Destination ID") {
      $feed_attributes->{DESTINATION_ID} = $feed_attribute;
    } elsif ($feed_attribute_name eq "Flight Price") {
      $feed_attributes->{FLIGHT_PRICE} = $feed_attribute;
    } elsif ($feed_attribute_name eq "Flight Sale Price") {
      $feed_attributes->{FLIGHT_SALE_PRICE} = $feed_attribute;
    } elsif ($feed_attribute_name eq "Final URLs") {
      $feed_attributes->{FINAL_URLS} = $feed_attribute;
    } else {
      die("Invalid attribute name.");
    }
  }

  return $feed_attributes;
}

# Creates a feed mapping for a given feed.
sub create_feed_mapping {
  my ($api_client, $customer_id, $feed_attributes, $feed_resource_name) = @_;

  # Map the FeedAttributeIds to the fieldId constants.
  my $flight_description_mapping =
    Google::Ads::GoogleAds::V4::Resources::AttributeFieldMapping->new({
      feedAttributeId => $feed_attributes->{FLIGHT_DESCRIPTION}{id},
      flightField     => FLIGHT_DESCRIPTION
    });
  my $destination_id_mapping =
    Google::Ads::GoogleAds::V4::Resources::AttributeFieldMapping->new({
      feedAttributeId => $feed_attributes->{DESTINATION_ID}{id},
      flightField     => DESTINATION_ID
    });
  my $flight_price_mapping =
    Google::Ads::GoogleAds::V4::Resources::AttributeFieldMapping->new({
      feedAttributeId => $feed_attributes->{FLIGHT_PRICE}{id},
      flightField     => FLIGHT_PRICE
    });
  my $flight_sale_price_mapping =
    Google::Ads::GoogleAds::V4::Resources::AttributeFieldMapping->new({
      feedAttributeId => $feed_attributes->{FLIGHT_SALE_PRICE}{id},
      flightField     => FLIGHT_SALE_PRICE
    });
  my $final_urls_mapping =
    Google::Ads::GoogleAds::V4::Resources::AttributeFieldMapping->new({
      feedAttributeId => $feed_attributes->{FINAL_URLS}{id},
      flightField     => FINAL_URLS
    });

  # Create a feed mapping.
  my $feed_mapping = Google::Ads::GoogleAds::V4::Resources::FeedMapping->new({
      placeholderType        => DYNAMIC_FLIGHT,
      feed                   => $feed_resource_name,
      attributeFieldMappings => [
        $flight_description_mapping, $destination_id_mapping,
        $flight_price_mapping,       $flight_sale_price_mapping,
        $final_urls_mapping
      ]});

  # Create a feed mapping operation.
  my $feed_mapping_operation =
    Google::Ads::GoogleAds::V4::Services::FeedMappingService::FeedMappingOperation
    ->new({
      create => $feed_mapping
    });

  # Add the feed mapping.
  my $feed_mapping_response = $api_client->FeedMappingService()->mutate({
      customerId => $customer_id,
      operations => [$feed_mapping_operation]});

  printf "Created feed mapping with resource name '%s'.\n",
    $feed_mapping_response->{results}[0]{resourceName};
}

# Adds a new item to the feed.
sub create_feed_item {
  my ($api_client, $customer_id, $feed_attributes, $feed_resource_name) = @_;

  # Create the flight description feed attribute value.
  my $flight_description =
    Google::Ads::GoogleAds::V4::Resources::FeedItemAttributeValue->new({
      feedAttributeId => $feed_attributes->{FLIGHT_DESCRIPTION}{id},
      stringValue     => "Earth to Mars"
    });
  # Create the destination ID feed attribute value.
  my $destination_id =
    Google::Ads::GoogleAds::V4::Resources::FeedItemAttributeValue->new({
      feedAttributeId => $feed_attributes->{DESTINATION_ID}{id},
      stringValue     => "Mars"
    });
  # Create the flight price feed attribute value.
  my $flight_price =
    Google::Ads::GoogleAds::V4::Resources::FeedItemAttributeValue->new({
      feedAttributeId => $feed_attributes->{FLIGHT_PRICE}{id},
      stringValue     => "499.99 USD"
    });
  # Create the flight sale price feed attribute value.
  my $flight_sale_price =
    Google::Ads::GoogleAds::V4::Resources::FeedItemAttributeValue->new({
      feedAttributeId => $feed_attributes->{FLIGHT_SALE_PRICE}{id},
      stringValue     => "299.99 USD"
    });
  # Create the final URLs feed attribute value.
  my $final_urls =
    Google::Ads::GoogleAds::V4::Resources::FeedItemAttributeValue->new({
      feedAttributeId => $feed_attributes->{FINAL_URLS}{id},
      stringValues    => ["http://www.example.com/flights/"]});

  # Create a feed item, specifying the Feed ID and the attributes created above.
  my $feed_item = Google::Ads::GoogleAds::V4::Resources::FeedItem->new({
      feed            => $feed_resource_name,
      attributeValues => [
        $flight_description, $destination_id, $flight_price,
        $flight_sale_price,  $final_urls
      ]});

  # Create a feed item operation.
  my $feed_item_operation =
    Google::Ads::GoogleAds::V4::Services::FeedItemService::FeedItemOperation->
    new({
      create => $feed_item
    });

  # Add the feed item.
  my $feed_item_response = $api_client->FeedItemService()->mutate({
      customerId => $customer_id,
      operations => [$feed_item_operation]});

  printf "Created feed item with resource name '%s'.\n",
    $feed_item_response->{results}[0]{resourceName};
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
add_flights_feed($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

add_flights_feed

=head1 DESCRIPTION

This example adds a flights feed, creates the associated feed mapping, and adds
a feed item.

=head1 SYNOPSIS

add_flights_feed.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
