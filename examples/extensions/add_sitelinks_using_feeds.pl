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
# Adds sitelinks to a campaign using feed services. To create a campaign, run
# add_campaigns.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V3::Resources::Feed;
use Google::Ads::GoogleAds::V3::Resources::FeedAttribute;
use Google::Ads::GoogleAds::V3::Resources::FeedItem;
use Google::Ads::GoogleAds::V3::Resources::FeedItemAttributeValue;
use Google::Ads::GoogleAds::V3::Resources::FeedMapping;
use Google::Ads::GoogleAds::V3::Resources::AttributeFieldMapping;
use Google::Ads::GoogleAds::V3::Resources::CampaignFeed;
use Google::Ads::GoogleAds::V3::Resources::FeedItemTarget;
use Google::Ads::GoogleAds::V3::Common::MatchingFunction;
use Google::Ads::GoogleAds::V3::Enums::FeedOriginEnum qw(USER);
use Google::Ads::GoogleAds::V3::Enums::FeedAttributeTypeEnum
  qw(STRING URL_LIST);
use Google::Ads::GoogleAds::V3::Enums::PlaceholderTypeEnum qw(SITELINK);
use Google::Ads::GoogleAds::V3::Enums::SitelinkPlaceholderFieldEnum
  qw(TEXT FINAL_URLS LINE_1 LINE_2);
use Google::Ads::GoogleAds::V3::Services::FeedService::FeedOperation;
use Google::Ads::GoogleAds::V3::Services::FeedItemService::FeedItemOperation;
use
  Google::Ads::GoogleAds::V3::Services::FeedMappingService::FeedMappingOperation;
use
  Google::Ads::GoogleAds::V3::Services::CampaignFeedService::CampaignFeedOperation;
use
  Google::Ads::GoogleAds::V3::Services::FeedItemTargetService::FeedItemTargetOperation;
use Google::Ads::GoogleAds::V3::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
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
my $campaign_id = "INSERT_CAMPAIGN_ID_HERE";
my $ad_group_id = undef;

sub add_sitelinks_using_feeds {
  my ($api_client, $customer_id, $campaign_id, $ad_group_id) = @_;

  # Create a feed, which acts as a table to store data.
  my $feed_data = create_feed($api_client, $customer_id);

  # Create feed items, which fill out the feed table with data.
  create_feed_items($api_client, $customer_id, $feed_data);

  # Create a feed mapping, which tells Google Ads how to interpret this data to
  # display additional sitelink information on ads.
  create_feed_mapping($api_client, $customer_id, $feed_data);

  # Create a campaign feed, which tells Google Ads which campaigns to use the
  # provided data with.
  create_campaign_feed($api_client, $customer_id, $campaign_id, $feed_data);

  # If an ad group is specified, limit targeting only to the given ad group.
  if ($ad_group_id) {
    create_ad_group_targeting($api_client, $customer_id, $feed_data,
      $ad_group_id);
  }

  return 1;
}

# Creates a feed.
sub create_feed {
  my ($api_client, $customer_id) = @_;

  my $feed = Google::Ads::GoogleAds::V3::Resources::Feed->new({
      name   => "Sitelinks Feed ##" . uniqid(),
      origin => USER,
      # Specify the column name and data type. This is just raw data at this point,
      # and not yet linked to any particular purpose. The names are used to help us
      # remember what they are intended for later.
      attributes => [
        Google::Ads::GoogleAds::V3::Resources::FeedAttribute->new({
            name => "Link Text",
            type => STRING
          }
        ),
        Google::Ads::GoogleAds::V3::Resources::FeedAttribute->new({
            name => "Link Final URL",
            type => URL_LIST
          }
        ),
        Google::Ads::GoogleAds::V3::Resources::FeedAttribute->new({
            name => "Line 1",
            type => STRING
          }
        ),
        Google::Ads::GoogleAds::V3::Resources::FeedAttribute->new({
            name => "Line 2",
            type => STRING
          })]});

  # Create a feed operation.
  my $feed_operation =
    Google::Ads::GoogleAds::V3::Services::FeedService::FeedOperation->new({
      create => $feed
    });

  # Issue a mutate request to add the feed.
  my $feed_response = $api_client->FeedService()->mutate({
      customerId => $customer_id,
      operations => [$feed_operation]});

  my $feed_resource_name = $feed_response->{results}[0]{resourceName};
  printf "Created feed with resource name: '%s'.\n", $feed_resource_name;

  # After we create the feed, we need to fetch it so we can determine the
  # attribute IDs, which will be required when populating feed items.
  $feed = $api_client->GoogleAdsService()->search({
      customerId => $customer_id,
      query      => "SELECT feed.attributes FROM feed " .
        "WHERE feed.resource_name = '$feed_resource_name'"
    })->{results}[0]{feed};

  my $attribute_ids = [map { $_->{id} } @{$feed->{attributes}}];

  return {
    feed => $feed_resource_name,
    # The attribute IDs come back in the same order that they were added.
    link_text_attribute_id => $attribute_ids->[0],
    final_url_attribute_id => $attribute_ids->[1],
    line_1_attribute_id    => $attribute_ids->[2],
    line_2_attribute_id    => $attribute_ids->[3]};
}

# Creates a new feed item operation.
sub new_feed_item_operation {
  my ($data, $text, $final_url, $line_1, $line_2) = @_;

  # Create the feed item.
  my $feed_item = Google::Ads::GoogleAds::V3::Resources::FeedItem->new({
      feed            => $data->{feed},
      attributeValues => [
        Google::Ads::GoogleAds::V3::Resources::FeedItemAttributeValue->new({
            feedAttributeId => $data->{link_text_attribute_id},
            stringValue     => $text
          }
        ),
        Google::Ads::GoogleAds::V3::Resources::FeedItemAttributeValue->new({
            feedAttributeId => $data->{final_url_attribute_id},
            stringValues    => $final_url
          }
        ),
        Google::Ads::GoogleAds::V3::Resources::FeedItemAttributeValue->new({
            feedAttributeId => $data->{line_1_attribute_id},
            stringValues    => $line_1
          }
        ),
        Google::Ads::GoogleAds::V3::Resources::FeedItemAttributeValue->new({
            feedAttributeId => $data->{line_2_attribute_id},
            stringValues    => $line_2
          })]});

  # Create a feed item operation.
  return
    Google::Ads::GoogleAds::V3::Services::FeedItemService::FeedItemOperation->
    new({
      create => $feed_item
    });
}

# Creates a list of feed items.
sub create_feed_items {
  my ($api_client, $customer_id, $feed_data) = @_;

  my $operations = [];
  push @$operations,
    new_feed_item_operation($feed_data, "Home", "http://www.example.com",
    "Home line 1", "Home line 2");
  push @$operations,
    new_feed_item_operation(
    $feed_data, "Stores",
    "http://www.example.com/stores",
    "Stores line 1",
    "Stores line 2"
    );
  push @$operations,
    new_feed_item_operation(
    $feed_data, "On Sale", "http://www.example.com/sale",
    "On Sale line 1",
    "On Sale line 2"
    );
  push @$operations,
    new_feed_item_operation(
    $feed_data, "Support",
    "http://www.example.com/support",
    "Support line 1",
    "Support line 2"
    );
  push @$operations,
    new_feed_item_operation(
    $feed_data, "Products",
    "http://www.example.com/catalogue",
    "Products line 1",
    "Products line 2"
    );
  push @$operations,
    new_feed_item_operation(
    $feed_data, "About Us",
    "http://www.example.com/about",
    "About Us line 1",
    "About Us line 2"
    );

  # Issue a mutate request to add the feed items.
  my $feed_item_response = $api_client->FeedItemService()->mutate({
      customerId => $customer_id,
      operations => [$operations]});

  my $feed_items =
    [map { $_->{resourceName} } @{$feed_item_response->{results}}];
  print "Created the following feed items:\n";
  foreach my $feed_item (@$feed_items) {
    print "\t$feed_item\n";
  }

  # We will need the resource name of the feed item to use in targeting.
  $feed_data->{feed_items} = $feed_items;

  # We may also need the feed item ID if we are going to use it in a mapping function.
  # For feed items, the ID is the last part of the resource name, after the '~'.
  $feed_data->{feed_item_ids} = [map { $1 if $_ =~ /(\d+)$/ } @$feed_items];
}

# Creates a feed mapping.
sub create_feed_mapping {
  my ($api_client, $customer_id, $feed_data) = @_;

  my $feed_mapping = Google::Ads::GoogleAds::V3::Resources::FeedMapping->new({
      placeholderType        => SITELINK,
      feed                   => $feed_data->{feed},
      attributeFieldMappings => [
        Google::Ads::GoogleAds::V3::Resources::AttributeFieldMapping->new({
            feedAttributeId => $feed_data->{link_text_attribute_id},
            sitelinkField   => TEXT
          }
        ),
        Google::Ads::GoogleAds::V3::Resources::AttributeFieldMapping->new({
            feedAttributeId => $feed_data->{final_url_attribute_id},
            sitelinkField   => FINAL_URLS
          }
        ),
        Google::Ads::GoogleAds::V3::Resources::AttributeFieldMapping->new({
            feedAttributeId => $feed_data->{line_1_attribute_id},
            sitelinkField   => LINE_1
          }
        ),
        Google::Ads::GoogleAds::V3::Resources::AttributeFieldMapping->new({
            feedAttributeId => $feed_data->{line_2_attribute_id},
            sitelinkField   => LINE_2
          }
        ),
      ]});

  # Create a feed mapping operation.
  my $feed_mapping_operation =
    Google::Ads::GoogleAds::V3::Services::FeedMappingService::FeedMappingOperation
    ->new({
      create => $feed_mapping
    });

  # Issue a mutate request to add the feed mapping.
  my $feed_mapping_response = $api_client->FeedMappingService()->mutate({
      customerId => $customer_id,
      operations => [$feed_mapping_operation]});

  printf "Created feed mapping with resource name: '%s'.\n",
    $feed_mapping_response->{results}[0]{resourceName};
}

# Creates a campaign feed.
sub create_campaign_feed {
  my ($api_client, $customer_id, $campaign_id, $feed_data) = @_;

  my $campaign_feed = Google::Ads::GoogleAds::V3::Resources::CampaignFeed->new({
      placeholderTypes => SITELINK,
      feed             => $feed_data->{feed},
      campaign => Google::Ads::GoogleAds::V3::Utils::ResourceNames::campaign(
        $customer_id, $campaign_id
      ),
      matchingFunction =>
        Google::Ads::GoogleAds::V3::Common::MatchingFunction->new({
          functionString => sprintf
            "AND(IN(FEED_ITEM_ID,{ %s }),EQUALS(CONTEXT.DEVICE,'Mobile'))",
          join(",", @{$feed_data->{feed_item_ids}})}
        ),
    });

  # Create a campaign feed operation.
  my $campaign_feed_operation =
    Google::Ads::GoogleAds::V3::Services::CampaignFeedService::CampaignFeedOperation
    ->new({
      create => $campaign_feed
    });

  # Issue a mutate request to add the campaign feed.
  my $campaign_feed_response = $api_client->CampaignFeedService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_feed_operation]});

  printf "Created campaign feed with resource name: '%s'.\n",
    $campaign_feed_response->{results}[0]{resourceName};
}

# Creates ad group targeting.
sub create_ad_group_targeting {
  my ($api_client, $customer_id, $feed_data, $ad_group_id) = @_;

  my $feed_item = $feed_data->{feed_items}[0];

  my $feed_item_target =
    Google::Ads::GoogleAds::V3::Resources::FeedItemTarget->new({
      # You must set targeting on a per-feed-item basis. This will restrict the
      # first feed item we added to only serve for the given ad group.
      feedItem => $feed_item,
      adGroup  => Google::Ads::GoogleAds::V3::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      )});

  # Create a feed item target operation.
  my $feed_item_target_operation =
    Google::Ads::GoogleAds::V3::Services::FeedItemTargetService::FeedItemTargetOperation
    ->new({
      create => $feed_item_target
    });

  # Issue a mutate request to add the feed item target.
  my $feed_item_target_response = $api_client->FeedItemTargetService()->mutate({
      customerId => $customer_id,
      operations => [$feed_item_target_operation]});

  printf "Created feed item target '%s' for feed item '%s'.\n",
    $feed_item_target_response->{results}[0]{resourceName},
    $feed_item;
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new({version => "V3"});

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s" => \$customer_id,
  "campaign_id=i" => \$campaign_id,
  "ad_group_id=i" => \$ad_group_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $campaign_id);

# Call the example.
add_sitelinks_using_feeds($api_client, $customer_id =~ s/-//gr,
  $campaign_id, $ad_group_id);

=pod

=head1 NAME

add_sitelinks_using_feeds

=head1 DESCRIPTION

Adds sitelinks to a campaign using feed services. To create a campaign, run
add_campaigns.pl.

=head1 SYNOPSIS

add_sitelinks_using_feeds.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.
    -ad_group_id                [Optional] The ad group ID.

=cut
