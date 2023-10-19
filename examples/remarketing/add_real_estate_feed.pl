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
# The example adds a real estate feed, creates the feed mapping, and adds items
# to the feed.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V15::Resources::FeedAttribute;
use Google::Ads::GoogleAds::V15::Resources::Feed;
use Google::Ads::GoogleAds::V15::Resources::AttributeFieldMapping;
use Google::Ads::GoogleAds::V15::Resources::FeedMapping;
use Google::Ads::GoogleAds::V15::Resources::FeedItemAttributeValue;
use Google::Ads::GoogleAds::V15::Resources::FeedItem;
use Google::Ads::GoogleAds::V15::Enums::FeedAttributeTypeEnum
  qw(STRING STRING_LIST URL URL_LIST);
use Google::Ads::GoogleAds::V15::Enums::RealEstatePlaceholderFieldEnum
  qw(LISTING_ID LISTING_NAME FINAL_URLS IMAGE_URL CONTEXTUAL_KEYWORDS);
use Google::Ads::GoogleAds::V15::Enums::PlaceholderTypeEnum
  qw(DYNAMIC_REAL_ESTATE);
use Google::Ads::GoogleAds::V15::Services::FeedService::FeedOperation;
use
  Google::Ads::GoogleAds::V15::Services::FeedMappingService::FeedMappingOperation;
use Google::Ads::GoogleAds::V15::Services::FeedItemService::FeedItemOperation;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
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

sub add_real_estate_feed {
  my ($api_client, $customer_id) = @_;

  # Create a new feed, but you can fetch and re-use an existing feed by skipping the
  # create_feed method and inserting the feed resource name of the existing feed into the
  # get_feed method.
  my $feed_resource_name = create_feed($api_client, $customer_id);

  # Get the page feed details.
  my $feed_attributes =
    get_feed($api_client, $customer_id, $feed_resource_name);

  # Create the feed mapping.
  create_feed_mapping($api_client, $customer_id, $feed_attributes,
    $feed_resource_name);

  # Create a feed item.
  create_feed_item($api_client, $customer_id, $feed_attributes,
    $feed_resource_name);

  return 1;
}

# Creates a feed.
sub create_feed {
  my ($api_client, $customer_id) = @_;

  # Create a Listing ID attribute.
  my $listing_id_attribute =
    Google::Ads::GoogleAds::V15::Resources::FeedAttribute->new({
      type => STRING,
      name => "Listing ID"
    });
  # Create a Listing Name attribute.
  my $listing_name_attribute =
    Google::Ads::GoogleAds::V15::Resources::FeedAttribute->new({
      type => STRING,
      name => "Listing Name"
    });
  # Create a Final URLs attribute.
  my $final_urls_attribute =
    Google::Ads::GoogleAds::V15::Resources::FeedAttribute->new({
      type => URL_LIST,
      name => "Final URLs"
    });
  # Create an Image URL attribute.
  my $image_url_attribute =
    Google::Ads::GoogleAds::V15::Resources::FeedAttribute->new({
      type => URL,
      name => "Image URL"
    });
  # Create a Contextual Keywords attribute.
  my $contextual_keywords_attribute =
    Google::Ads::GoogleAds::V15::Resources::FeedAttribute->new({
      type => STRING_LIST,
      name => "Contextual Keywords"
    });

  # Create a feed.
  my $feed = Google::Ads::GoogleAds::V15::Resources::Feed->new({
      name       => "Real Estate Feed #" . uniqid(),
      attributes => [
        $listing_id_attribute, $listing_name_attribute,
        $final_urls_attribute, $image_url_attribute,
        $contextual_keywords_attribute
      ]});

  # Create a feed operation.
  my $feed_operation =
    Google::Ads::GoogleAds::V15::Services::FeedService::FeedOperation->new(({
      create => $feed
    }));

  # Add the feed.
  my $feeds_response = $api_client->FeedService()->mutate({
      customerId => $customer_id,
      operations => [$feed_operation]});

  my $feed_resource_name = $feeds_response->{results}[0]{resourceName};

  printf "Feed with resource name '%s' was created.\n", $feed_resource_name;

  return $feed_resource_name;
}

# Retrieves details about a feed. The initial query retrieves the FeedAttributes, or columns,
# of the feed. Each FeedAttribute will also include the FeedAttributeId, which will be used in
# a subsequent step. The example then inserts a new key, value pair into a hash for each
# FeedAttribute, which is the return value of the method. The keys are the placeholder types
# that the columns will be. The values are the FeedAttributes.
# [START add_real_estate_feed]
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
  # Loop through each of the feed attributes and populates the hash.
  foreach my $feed_attribute (@$feed_attribute_list) {
    my $feed_attribute_name = $feed_attribute->{name};

    if ($feed_attribute_name eq "Listing ID") {
      $feed_attributes->{LISTING_ID} = $feed_attribute;
    } elsif ($feed_attribute_name eq "Listing Name") {
      $feed_attributes->{LISTING_NAME} = $feed_attribute;
    } elsif ($feed_attribute_name eq "Final URLs") {
      $feed_attributes->{FINAL_URLS} = $feed_attribute;
    } elsif ($feed_attribute_name eq "Image URL") {
      $feed_attributes->{IMAGE_URL} = $feed_attribute;
    } elsif ($feed_attribute_name eq "Contextual Keywords") {
      $feed_attributes->{CONTEXTUAL_KEYWORDS} = $feed_attribute;
    } else {
      die("Invalid attribute name.");
    }
  }

  return $feed_attributes;
}
# [END add_real_estate_feed]

# Creates a feed mapping for a given feed.
sub create_feed_mapping {
  my ($api_client, $customer_id, $feed_attributes, $feed_resource_name) = @_;

  # Map the FeedAttributeIds to the placeholder values. The FeedAttributeId is the ID of the
  # FeedAttribute created in the create_feed method. This can be thought of as the generic ID of
  # the column of the new feed. The placeholder value specifies the type of column this is in
  # the context of a real estate feed (e.g. a LISTING_ID or LISTING_NAME). The FeedMapping
  # associates the feed column by ID to this type and controls how the feed attributes are
  # presented in dynamic content.
  # See https://developers.google.com/google-ads/api/reference/rpc/latest/RealEstatePlaceholderFieldEnum.RealEstatePlaceholderField
  # for the full list of placeholder values.
  my $listing_id_mapping =
    Google::Ads::GoogleAds::V15::Resources::AttributeFieldMapping->new({
      feedAttributeId => $feed_attributes->{LISTING_ID}{id},
      realEstateField => LISTING_ID
    });
  my $listing_name_mapping =
    Google::Ads::GoogleAds::V15::Resources::AttributeFieldMapping->new({
      feedAttributeId => $feed_attributes->{LISTING_NAME}{id},
      realEstateField => LISTING_NAME
    });
  my $final_urls_mapping =
    Google::Ads::GoogleAds::V15::Resources::AttributeFieldMapping->new({
      feedAttributeId => $feed_attributes->{FINAL_URLS}{id},
      realEstateField => FINAL_URLS
    });
  my $image_url_mapping =
    Google::Ads::GoogleAds::V15::Resources::AttributeFieldMapping->new({
      feedAttributeId => $feed_attributes->{IMAGE_URL}{id},
      realEstateField => IMAGE_URL
    });
  my $contextual_keywords_mapping =
    Google::Ads::GoogleAds::V15::Resources::AttributeFieldMapping->new({
      feedAttributeId => $feed_attributes->{CONTEXTUAL_KEYWORDS}{id},
      realEstateField => CONTEXTUAL_KEYWORDS
    });

  # Create a feed mapping.
  my $feed_mapping = Google::Ads::GoogleAds::V15::Resources::FeedMapping->new({
      placeholderType        => DYNAMIC_REAL_ESTATE,
      feed                   => $feed_resource_name,
      attributeFieldMappings => [
        $listing_id_mapping, $listing_name_mapping,
        $final_urls_mapping, $image_url_mapping,
        $contextual_keywords_mapping
      ]});

  # Create a feed mapping operation.
  my $feed_mapping_operation =
    Google::Ads::GoogleAds::V15::Services::FeedMappingService::FeedMappingOperation
    ->new({
      create => $feed_mapping
    });

  # Add the feed mapping.
  my $feed_mappings_response = $api_client->FeedMappingService()->mutate({
      customerId => $customer_id,
      operations => [$feed_mapping_operation]});

  printf "Created feed mapping with resource name '%s'.\n",
    $feed_mappings_response->{results}[0]{resourceName};
}

# Adds a new item to the feed.
# [START add_real_estate_feed_1]
sub create_feed_item {
  my ($api_client, $customer_id, $feed_attributes, $feed_resource_name) = @_;

  # Create the listing ID feed attribute value.
  my $listing_id =
    Google::Ads::GoogleAds::V15::Resources::FeedItemAttributeValue->new({
      feedAttributeId => $feed_attributes->{LISTING_ID}{id},
      stringValue     => "ABC123DEF"
    });
  # Create the listing name feed attribute value.
  my $listing_name =
    Google::Ads::GoogleAds::V15::Resources::FeedItemAttributeValue->new({
      feedAttributeId => $feed_attributes->{LISTING_NAME}{id},
      stringValue     => "Two bedroom with magnificent views"
    });
  # Create the final URLs feed attribute value.
  my $final_urls =
    Google::Ads::GoogleAds::V15::Resources::FeedItemAttributeValue->new({
      feedAttributeId => $feed_attributes->{FINAL_URLS}{id},
      stringValue     => "http://www.example.com/listings/"
    });

  # Optionally insert additional attributes here, such as address, city, description, etc.

  # Create the image URL feed attribute value.
  my $image_url =
    Google::Ads::GoogleAds::V15::Resources::FeedItemAttributeValue->new({
      feedAttributeId => $feed_attributes->{IMAGE_URL}{id},
      stringValue     =>
        "http://www.example.com/listings/images?listing_id=ABC123DEF"
    });
  # Create the contextual keywords feed attribute value.
  my $contextual_keywords =
    Google::Ads::GoogleAds::V15::Resources::FeedItemAttributeValue->new({
      feedAttributeId => $feed_attributes->{CONTEXTUAL_KEYWORDS}{id},
      stringValues    => ["beach community", "ocean view", "two bedroom"]});

  # Create a feed item, specifying the Feed ID and the attributes created above.
  my $feed_item = Google::Ads::GoogleAds::V15::Resources::FeedItem->new({
      feed            => $feed_resource_name,
      attributeValues => [
        $listing_id, $listing_name, $final_urls,
        $image_url,  $contextual_keywords
      ]});

  # Create a feed item operation.
  my $feed_item_operation =
    Google::Ads::GoogleAds::V15::Services::FeedItemService::FeedItemOperation->
    new({
      create => $feed_item
    });

  # Add the feed item.
  my $feed_items_response = $api_client->FeedItemService()->mutate({
      customerId => $customer_id,
      operations => [$feed_item_operation]});

  printf "Created feed item with resource name '%s'.\n",
    $feed_items_response->{results}[0]{resourceName};
}
# [END add_real_estate_feed_1]

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
add_real_estate_feed($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

add_real_estate_feed

=head1 DESCRIPTION

The example adds a real estate feed, creates the feed mapping, and adds items
to the feed.

=head1 SYNOPSIS

add_real_estate_feed.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
