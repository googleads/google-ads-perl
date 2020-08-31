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
# Adds an ad customizer feed and associates it with the customer. Then it adds an
# ad that uses the feed to populate dynamic data.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V5::Resources::FeedAttribute;
use Google::Ads::GoogleAds::V5::Resources::Feed;
use Google::Ads::GoogleAds::V5::Resources::AttributeFieldMapping;
use Google::Ads::GoogleAds::V5::Resources::FeedMapping;
use Google::Ads::GoogleAds::V5::Resources::FeedItemAttributeValue;
use Google::Ads::GoogleAds::V5::Resources::FeedItem;
use Google::Ads::GoogleAds::V5::Resources::FeedItemTarget;
use Google::Ads::GoogleAds::V5::Resources::Ad;
use Google::Ads::GoogleAds::V5::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V5::Common::ExpandedTextAdInfo;
use Google::Ads::GoogleAds::V5::Enums::FeedAttributeTypeEnum
  qw(STRING DATE_TIME);
use Google::Ads::GoogleAds::V5::Enums::FeedOriginEnum qw(USER);
use Google::Ads::GoogleAds::V5::Enums::AdCustomizerPlaceholderFieldEnum;
use Google::Ads::GoogleAds::V5::Enums::PlaceholderTypeEnum qw(AD_CUSTOMIZER);
use Google::Ads::GoogleAds::V5::Services::FeedService::FeedOperation;
use
  Google::Ads::GoogleAds::V5::Services::FeedMappingService::FeedMappingOperation;
use Google::Ads::GoogleAds::V5::Services::FeedItemService::FeedItemOperation;
use
  Google::Ads::GoogleAds::V5::Services::FeedItemTargetService::FeedItemTargetOperation;
use Google::Ads::GoogleAds::V5::Services::AdGroupAdService::AdGroupAdOperation;
use Google::Ads::GoogleAds::V5::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
use Data::Uniqid qw(uniqid);
use POSIX qw(strftime mktime);

# We're doing only searches by resource_name in this example, we can set page size = 1.
use constant PAGE_SIZE => 1;
# We're creating two different ad groups to be dynamically populated by the same feed.
use constant NUMBER_OF_AD_GROUPS => 2;

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id   = "INSERT_CUSTOMER_ID_HERE";
my $ad_group_id_1 = "INSERT_AD_GROUP_ID_1_HERE";
my $ad_group_id_2 = "INSERT_AD_GROUP_ID_2_HERE";
my $ad_group_ids  = [];

sub add_ad_customizer {
  my ($api_client, $customer_id, $ad_group_ids) = @_;

  die sprintf
    "Please pass exactly %d ad group IDs in the ad_group_ids parameter.\n",
    NUMBER_OF_AD_GROUPS
    if scalar @$ad_group_ids != NUMBER_OF_AD_GROUPS;

  my $feed_name = "Ad Customizer example feed " . uniqid();

  # Create a feed to be used for ad customization.
  my $ad_customizer_feed_resource_name =
    create_ad_customizer_feed($api_client, $customer_id, $feed_name);

  # Retrieve the attributes of the feed.
  my $ad_customizer_feed_attributes =
    get_feed_attributes($api_client, $customer_id,
    $ad_customizer_feed_resource_name);

  # Map the feed to the ad customizer placeholder fields.
  create_ad_customizer_mapping(
    $api_client, $customer_id,
    $ad_customizer_feed_resource_name,
    $ad_customizer_feed_attributes
  );

  # Create feed items to be used to customize ads.
  my $feed_item_resource_names = create_feed_items(
    $api_client, $customer_id,
    $ad_customizer_feed_resource_name,
    $ad_customizer_feed_attributes
  );

  # Set the feed to be used only with the specified ad groups.
  create_feed_item_targets($api_client, $customer_id, $ad_group_ids,
    $feed_item_resource_names);

  # Create ads that use the feed for customization.
  create_ads_with_customizations($api_client, $customer_id, $ad_group_ids,
    $feed_name);

  return 1;
}

# Creates a feed to be used for ad customization.
sub create_ad_customizer_feed {
  my ($api_client, $customer_id, $feed_name) = @_;

  # Create three feed attributes: a name, a price and a date. The attribute names
  # are arbitrary choices and will be used as placeholders in the ad text fields.
  my $name_attribute =
    Google::Ads::GoogleAds::V5::Resources::FeedAttribute->new({
      type => STRING,
      name => "Name"
    });

  my $price_attribute =
    Google::Ads::GoogleAds::V5::Resources::FeedAttribute->new({
      type => STRING,
      name => "Price"
    });

  my $date_attribute =
    Google::Ads::GoogleAds::V5::Resources::FeedAttribute->new({
      type => DATE_TIME,
      name => "Date"
    });

  # Create the feed.
  my $feed = Google::Ads::GoogleAds::V5::Resources::Feed->new({
    name       => $feed_name,
    attributes => [$name_attribute, $price_attribute, $date_attribute],
    origin     => USER
  });

  # Create a feed operation for creating a feed.
  my $feed_operation =
    Google::Ads::GoogleAds::V5::Services::FeedService::FeedOperation->new({
      create => $feed
    });

  # Issue a mutate request to add the feed.
  my $feed_response = $api_client->FeedService()->mutate({
      customerId => $customer_id,
      operations => [$feed_operation]});

  my $feed_resource_name = $feed_response->{results}[0]{resourceName};
  printf "Added feed with resource name '%s'.\n", $feed_resource_name;

  return $feed_resource_name;
}

# Retrieves attributes for a feed.
sub get_feed_attributes {
  my ($api_client, $customer_id, $feed_resource_name) = @_;

  my $search_query = "SELECT feed.attributes, feed.name FROM feed " .
    "WHERE feed.resource_name = '$feed_resource_name'";

  my $search_response = $api_client->GoogleAdsService()->search({
    customerId => $customer_id,
    query      => $search_query,
    pageSize   => PAGE_SIZE
  });

  my $feed         = $search_response->{results}[0]{feed};
  my $feed_details = {};
  printf "Found the following attributes for feed with name %s:\n",
    $feed->{name};

  foreach my $feed_attribute (@{$feed->{attributes}}) {
    $feed_details->{$feed_attribute->{name}} = $feed_attribute->{id};
    printf "\t'%s' with id %d and type '%s'\n", $feed_attribute->{name},
      $feed_attribute->{id}, $feed_attribute->{type};
  }
  return $feed_details;
}

# Creates a feed mapping for a given feed.
sub create_ad_customizer_mapping {
  my (
    $api_client, $customer_id,
    $ad_customizer_feed_resource_name,
    $ad_customizer_feed_attributes
  ) = @_;

  # Map the feed attribute IDs to the field ID constants.
  my $name_field_mapping =
    Google::Ads::GoogleAds::V5::Resources::AttributeFieldMapping->new({
      feedAttributeId => $ad_customizer_feed_attributes->{Name},
      adCustomizerField =>
        Google::Ads::GoogleAds::V5::Enums::AdCustomizerPlaceholderFieldEnum::STRING,
    });

  my $price_field_mapping =
    Google::Ads::GoogleAds::V5::Resources::AttributeFieldMapping->new({
      feedAttributeId => $ad_customizer_feed_attributes->{Price},
      adCustomizerField =>
        Google::Ads::GoogleAds::V5::Enums::AdCustomizerPlaceholderFieldEnum::PRICE,
    });

  my $date_field_mapping =
    Google::Ads::GoogleAds::V5::Resources::AttributeFieldMapping->new({
      feedAttributeId => $ad_customizer_feed_attributes->{Date},
      adCustomizerField =>
        Google::Ads::GoogleAds::V5::Enums::AdCustomizerPlaceholderFieldEnum::DATE,
    });

  # Create the feed mapping.
  my $feed_mapping = Google::Ads::GoogleAds::V5::Resources::FeedMapping->new({
      placeholderType => AD_CUSTOMIZER,
      feed            => $ad_customizer_feed_resource_name,
      attributeFieldMappings =>
        [$name_field_mapping, $price_field_mapping, $date_field_mapping]});

  # Create the operation.
  my $feed_mapping_operation =
    Google::Ads::GoogleAds::V5::Services::FeedMappingService::FeedMappingOperation
    ->new({
      create => $feed_mapping
    });

  # Issue a mutate request to add the feed mapping.
  my $feed_mapping_response = $api_client->FeedMappingService()->mutate({
      customerId => $customer_id,
      operations => [$feed_mapping_operation]});

  # Display the results.
  foreach my $result (@{$feed_mapping_response->{results}}) {
    printf "Created feed mapping with resource name '%s'.\n",
      $result->{resourceName};
  }
}

# Creates two different feed items to enable two different ad customizations.
sub create_feed_items {
  my (
    $api_client, $customer_id,
    $ad_customizer_feed_resource_name,
    $ad_customizer_feed_attributes
  ) = @_;

  my $feed_item_operations = [];

  my ($sec, $min, $hour, $mday, $mon, $year) = localtime(time);

  push @$feed_item_operations,
    create_feed_item_operation(
    "Mars",
    '$1234.56',
    strftime("%Y%m%d %H%M%S", localtime(mktime(0, 0, 0, 1, $mon, $year))),
    $ad_customizer_feed_resource_name,
    $ad_customizer_feed_attributes
    );

  push @$feed_item_operations, create_feed_item_operation(
    "Venus",
    '$6543.21',
    # Set the date to the 15th of the current month.
    strftime("%Y%m%d %H%M%S", localtime(mktime(0, 0, 0, 15, $mon, $year))),
    $ad_customizer_feed_resource_name,
    $ad_customizer_feed_attributes
  );

  # Add the feed items.
  my $feed_item_response = $api_client->FeedItemService()->mutate({
    customerId => $customer_id,
    operations => $feed_item_operations
  });

  my $feed_item_resource_names = [];
  # Displays the results.
  foreach my $result (@{$feed_item_response->{results}}) {
    printf "Created feed item with resource name '%s'.\n",
      $result->{resourceName};
    push @$feed_item_resource_names, $result->{resourceName};
  }

  return $feed_item_resource_names;
}

# Creates a FeedItemOperation.
sub create_feed_item_operation {
  my (
    $name, $price, $date,
    $ad_customizer_feed_resource_name,
    $ad_customizer_feed_attributes
  ) = @_;

  my $name_attribute_value =
    Google::Ads::GoogleAds::V5::Resources::FeedItemAttributeValue->new({
      feedAttributeId => $ad_customizer_feed_attributes->{Name},
      stringValue     => $name
    });

  my $price_attribute_value =
    Google::Ads::GoogleAds::V5::Resources::FeedItemAttributeValue->new({
      feedAttributeId => $ad_customizer_feed_attributes->{Price},
      stringValue     => $price
    });

  my $date_attribute_value =
    Google::Ads::GoogleAds::V5::Resources::FeedItemAttributeValue->new({
      feedAttributeId => $ad_customizer_feed_attributes->{Date},
      stringValue     => $date
    });

  my $feed_item = Google::Ads::GoogleAds::V5::Resources::FeedItem->new({
      feed => $ad_customizer_feed_resource_name,
      attributeValues =>
        [$name_attribute_value, $price_attribute_value, $date_attribute_value]}
  );

  return
    Google::Ads::GoogleAds::V5::Services::FeedItemService::FeedItemOperation->
    new({
      create => $feed_item
    });
}

# Restricts the feed items to work only with a specific ad group; this prevents
# the feed items from being used elsewhere and makes sure they are used only for
# customizing a specific ad group.
sub create_feed_item_targets {
  my ($api_client, $customer_id, $ad_group_ids, $feed_item_resource_names) = @_;

  # Bind each feed item to a specific ad group to make sure it will only be used
  # to customize ads inside that ad group; using the feed item elsewhere will
  # result in an error.
  for (my $i = 0 ; $i < scalar @$feed_item_resource_names ; $i++) {
    my $feed_item_resource_name = $feed_item_resource_names->[$i];
    my $ad_group_id             = $ad_group_ids->[$i];

    my $feed_item_target =
      Google::Ads::GoogleAds::V5::Resources::FeedItemTarget->new({
        feedItem => $feed_item_resource_name,
        adGroup  => Google::Ads::GoogleAds::V5::Utils::ResourceNames::ad_group(
          $customer_id, $ad_group_id
        )});

    # Create the operation.
    my $feed_item_target_operation =
      Google::Ads::GoogleAds::V5::Services::FeedItemTargetService::FeedItemTargetOperation
      ->new({
        create => $feed_item_target
      });

    # Issue a mutate request to add the feed item target.
    my $feed_item_target_response =
      $api_client->FeedItemTargetService()->mutate({
        customerId => $customer_id,
        operations => [$feed_item_target_operation]});

    my $feed_item_target_resource_name =
      $feed_item_target_response->{results}[0]{resourceName};
    printf "Added feed item target with resource name '%s'.\n",
      $feed_item_target_resource_name;
  }
}

# Creates expanded text ads that use the ad customizer feed to populate the placeholders.
sub create_ads_with_customizations {
  my ($api_client, $customer_id, $ad_group_ids, $feed_name) = @_;

  my $expanded_text_ad_info =
    Google::Ads::GoogleAds::V5::Common::ExpandedTextAdInfo->new({
      headlinePart1 => "Luxury cruise to {=$feed_name.Name}",
      headlinePart2 => "Only {=$feed_name.Price}",
      description   => "Offer ends in {=countdown($feed_name.Date)}!"
    });

  my $ad = Google::Ads::GoogleAds::V5::Resources::Ad->new({
      expandedTextAd => $expanded_text_ad_info,
      finalUrls      => ["http://www.example.com"]});

  my $ad_group_ad_operations = [];
  foreach my $ad_group_id (@$ad_group_ids) {
    my $ad_group_ad = Google::Ads::GoogleAds::V5::Resources::AdGroupAd->new({
        ad      => $ad,
        adGroup => Google::Ads::GoogleAds::V5::Utils::ResourceNames::ad_group(
          $customer_id, $ad_group_id
        )});

    push @$ad_group_ad_operations,
      Google::Ads::GoogleAds::V5::Services::AdGroupAdService::AdGroupAdOperation
      ->new({
        create => $ad_group_ad
      });
  }

  # Issue a mutate request to add the ads.
  my $ad_group_ad_response = $api_client->AdGroupAdService()->mutate({
    customerId => $customer_id,
    operations => $ad_group_ad_operations
  });

  my $ad_group_ad_results = $ad_group_ad_response->{results};
  printf "Added %d ads:\n", scalar @$ad_group_ad_results;
  foreach my $ad_group_ad_result (@$ad_group_ad_results) {
    printf "Added an ad with resource name '%s'.\n",
      $ad_group_ad_result->{resourceName};
  }
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
  "customer_id=s"  => \$customer_id,
  "ad_group_ids=i" => \@$ad_group_ids
);
$ad_group_ids = [$ad_group_id_1, $ad_group_id_2] unless @$ad_group_ids;

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $ad_group_ids);

# Call the example.
add_ad_customizer($api_client, $customer_id =~ s/-//gr, $ad_group_ids);

=pod

=head1 NAME

add_ad_customizer

=head1 DESCRIPTION

Adds an ad customizer feed and associates it with the customer. Then it adds an
ad that uses the feed to populate dynamic data.

=head1 SYNOPSIS

add_ad_customizer.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_ids               The ad group IDs to bind the feed items to.

=cut
