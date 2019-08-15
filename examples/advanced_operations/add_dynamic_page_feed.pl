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
# This example adds a page feed to specify precisely which URLs to use
# with your dynamic search ads campaign.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::GoogleAdsClient;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V2::Resources::FeedAttribute;
use Google::Ads::GoogleAds::V2::Resources::Feed;
use Google::Ads::GoogleAds::V2::Resources::AttributeFieldMapping;
use Google::Ads::GoogleAds::V2::Resources::FeedMapping;
use Google::Ads::GoogleAds::V2::Resources::FeedItemAttributeValue;
use Google::Ads::GoogleAds::V2::Resources::FeedItem;
use Google::Ads::GoogleAds::V2::Resources::Campaign;
use Google::Ads::GoogleAds::V2::Resources::AdGroupCriterion;
use Google::Ads::GoogleAds::V2::Common::WebpageConditionInfo;
use Google::Ads::GoogleAds::V2::Common::WebpageInfo;
use Google::Ads::GoogleAds::V2::Enums::FeedAttributeTypeEnum
  qw(URL_LIST STRING_LIST);
use Google::Ads::GoogleAds::V2::Enums::FeedOriginEnum qw(USER);
use Google::Ads::GoogleAds::V2::Enums::DsaPageFeedCriterionFieldEnum
  qw(PAGE_URL LABEL);
use Google::Ads::GoogleAds::V2::Enums::FeedMappingCriterionTypeEnum
  qw(DSA_PAGE_FEED);
use Google::Ads::GoogleAds::V2::Enums::WebpageConditionOperandEnum
  qw(CUSTOM_LABEL);
use Google::Ads::GoogleAds::V2::Services::FeedService::FeedOperation;
use
  Google::Ads::GoogleAds::V2::Services::FeedMappingService::FeedMappingOperation;
use Google::Ads::GoogleAds::V2::Services::FeedItemService::FeedItemOperation;
use Google::Ads::GoogleAds::V2::Services::CampaignService::CampaignOperation;
use
  Google::Ads::GoogleAds::V2::Services::AdGroupCriterionService::AdGroupCriterionOperation;
use
  Google::Ads::GoogleAds::V2::Services::GoogleAdsService::SearchGoogleAdsRequest;
use Google::Ads::GoogleAds::V2::Utils::ResourceNames;

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
my $campaign_id = "INSERT_CAMPAIGN_ID_HERE";
my $ad_group_id = "INSERT_AD_GROUP_ID_HERE";

sub add_dynamic_page_feed {
  my ($api_client, $customer_id, $campaign_id, $ad_group_id) = @_;

  my $dsa_page_url_label = "discounts";

  # Create the page feed details. This example creates a new feed, but you can
  # fetch and re-use an existing feed.
  my $feed_details = create_feed($api_client, $customer_id);
  create_feed_mapping($api_client, $customer_id, $feed_details);
  create_feed_items($api_client, $customer_id, $feed_details,
    $dsa_page_url_label);

  # Associate the page feed with the campaign.
  update_campaign_dsa_setting($api_client, $customer_id, $feed_details,
    $campaign_id);

  # Optional: Target web pages matching the feed's label in the ad group.
  add_dsa_target($api_client, $customer_id, $ad_group_id, $dsa_page_url_label);

  print "Dynamic page feed setup is complete for campaign ID $campaign_id.\n";

  return 1;
}

# Creates a feed.
sub create_feed {
  my ($api_client, $customer_id) = @_;

  # Create a URL attribute.
  my $url_attribute = Google::Ads::GoogleAds::V2::Resources::FeedAttribute->new(
    {
      type => URL_LIST,
      name => "Page URL"
    });

  # Create a label attribute.
  my $label_attribute =
    Google::Ads::GoogleAds::V2::Resources::FeedAttribute->new({
      type => STRING_LIST,
      name => "Label"
    });

  # Create the feed.
  my $feed = Google::Ads::GoogleAds::V2::Resources::Feed->new({
    name       => "DSA Feed #" . uniqid(),
    attributes => [$url_attribute, $label_attribute],
    origin     => USER
  });

  # Create a feed operation for creating a feed.
  my $feed_operation =
    Google::Ads::GoogleAds::V2::Services::FeedService::FeedOperation->new(
    {create => $feed});

  # Add the feed.
  my $feed_response = $api_client->FeedService()->mutate({
      customerId => $customer_id,
      operations => [$feed_operation]});

  my $feed_resource_name = $feed_response->{results}[0]{resourceName};

  printf "Created feed with resource name: %s.\n", $feed_resource_name;

  return get_feed($api_client, $customer_id, $feed_resource_name);
}

# Retrieves details about a feed.
sub get_feed {
  my ($api_client, $customer_id, $feed_resource_name) = @_;

  my $search_query =
    sprintf "SELECT feed.attributes FROM feed WHERE feed.resource_name = '%s'",
    $feed_resource_name;

  my $search_response = $api_client->GoogleAdsService()->search({
    customerId => $customer_id,
    query      => $search_query,
    pageSize   => PAGE_SIZE
  });

  my $feed_attributes = $search_response->{results}[0]{feed}{attributes};
  my $feed_details    = {resourceName => $feed_resource_name};
  foreach my $feed_attribute (@$feed_attributes) {
    $feed_details->{$feed_attribute->{name}} = $feed_attribute->{id};
  }

  return $feed_details;
}

# Creates a feed mapping for a given feed.
sub create_feed_mapping {
  my ($api_client, $customer_id, $feed_details) = @_;

  # Map the feed attribute IDs to the field ID constants.
  my $url_field_mapping =
    Google::Ads::GoogleAds::V2::Resources::AttributeFieldMapping->new({
      feedAttributeId  => $feed_details->{'Page URL'},
      dsaPageFeedField => PAGE_URL
    });

  my $label_field_mapping =
    Google::Ads::GoogleAds::V2::Resources::AttributeFieldMapping->new({
      feedAttributeId  => $feed_details->{Label},
      dsaPageFeedField => LABEL
    });

  # Create the feed mapping.
  my $feed_mapping = Google::Ads::GoogleAds::V2::Resources::FeedMapping->new({
      criterionType          => DSA_PAGE_FEED,
      feed                   => $feed_details->{resourceName},
      attributeFieldMappings => [$url_field_mapping, $label_field_mapping]});

  # Create the feed mapping operation.
  my $feed_mapping_operation =
    Google::Ads::GoogleAds::V2::Services::FeedMappingService::FeedMappingOperation
    ->new({
      create => $feed_mapping
    });

  my $feed_mapping_response = $api_client->FeedMappingService()->mutate({
      customerId => $customer_id,
      operations => [$feed_mapping_operation]});

  printf "Created feed mapping with resource name: %s.\n",
    $feed_mapping_response->{results}[0]{resourceName};
}

# Creates feed items for a given feed.
sub create_feed_items {
  my ($api_client, $customer_id, $feed_details, $dsa_page_url_label) = @_;

  my $urls = [
    "http://www.example.com/discounts/rental-cars",
    "http://www.example.com/discounts/hotel-deals",
    "http://www.example.com/discounts/flight-deals"
  ];

  # Create a label attribute.
  my $label_attribute_value =
    Google::Ads::GoogleAds::V2::Resources::FeedItemAttributeValue->new({
      feedAttributeId => $feed_details->{Label},
      stringValue     => $dsa_page_url_label
    });

  # Create one operation per URL.
  my $feed_item_operations = [];
  foreach my $url (@$urls) {
    # Create a url attribute.
    my $url_attribute_value =
      Google::Ads::GoogleAds::V2::Resources::FeedItemAttributeValue->new({
        feedAttributeId => $feed_details->{'Page URL'},
        stringValue     => $url
      });

    # Create a feed item.
    my $feed_item = Google::Ads::GoogleAds::V2::Resources::FeedItem->new({
        feed            => $feed_details->{resourceName},
        attributeValues => [$url_attribute_value, $label_attribute_value]});

    push @$feed_item_operations,
      Google::Ads::GoogleAds::V2::Services::FeedItemService::FeedItemOperation
      ->new({
        create => $feed_item
      });
  }

  # Add the feed items.
  my $feed_item_response = $api_client->FeedItemService()->mutate({
    customerId => $customer_id,
    operations => $feed_item_operations
  });

  foreach my $feed_item_result (@{$feed_item_response->{results}}) {
    printf "Created feed item with resource name: %s.\n",
      $feed_item_result->{resourceName};
  }
}

# Updates a campaign to set the DSA feed.
sub update_campaign_dsa_setting {
  my ($api_client, $customer_id, $feed_details, $campaign_id) = @_;

  # Retrieve the existing dynamic search ads settings for the campaign.
  my $dsa_setting = get_dsa_setting($api_client, $customer_id, $campaign_id);

  my $feed_resource_name = $feed_details->{resourceName};
  $dsa_setting->{feeds} = [$feed_resource_name];

  # Create the campaign object to be updated.
  my $campaign = Google::Ads::GoogleAds::V2::Resources::Campaign->new({
      resourceName =>
        Google::Ads::GoogleAds::V2::Utils::ResourceNames::campaign(
        $customer_id, $campaign_id
        ),
      dynamicSearchAdsSetting => $dsa_setting
    });

  # Create the update operation and set the update mask.
  my $campaign_operation =
    Google::Ads::GoogleAds::V2::Services::CampaignService::CampaignOperation->
    new({
      update => $campaign,
      updateMask =>
        Google::Ads::GoogleAds::Utils::FieldMasks::all_set_fields_of($campaign)}
    );

  # Update the campaign.
  my $campaign_response = $api_client->CampaignService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_operation]});

  printf "Updated campaign with resource name: %s.\n",
    $campaign_response->{results}[0]{resourceName};
}

# Returns the DSA settings for a campaign. Dies if the campaign does not
# exist or is not a DSA campaign.
sub get_dsa_setting {
  my ($api_client, $customer_id, $campaign_id) = @_;

  # Create the query.
  # You must request all DSA fields in order to update the DSA settings in the
  # following step.
  my $search_query =
    "SELECT campaign.id, campaign.name, " .
    "campaign.dynamic_search_ads_setting.domain_name, " .
    "campaign.dynamic_search_ads_setting.language_code, " .
    "campaign.dynamic_search_ads_setting.use_supplied_urls_only " .
    "FROM campaign where campaign.id = $campaign_id";

  my $search_response = $api_client->GoogleAdsService()->search({
    customerId => $customer_id,
    query      => $search_query,
    pageSize   => PAGE_SIZE
  });

  # Die if a campaign with the provided ID does not exist.
  die "No campaign found with ID $campaign_id.\n"
    if $search_response->{totalResultsCount} == 0;

  my $dynamic_search_ads_setting =
    $search_response->{results}[0]{campaign}{dynamicSearchAdsSetting};

  # Die if the campaign is not a DSA campaign.
  die "Campaign with ID $campaign_id is not a DSA campaign.\n"
    if not $dynamic_search_ads_setting;

  return $dynamic_search_ads_setting;
}

# Creates an ad group criterion targeting the DSA label.
sub add_dsa_target {
  my ($api_client, $customer_id, $ad_group_id, $dsa_page_url_label) = @_;

  my $ad_group_resource_name =
    Google::Ads::GoogleAds::V2::Utils::ResourceNames::ad_group($customer_id,
    $ad_group_id);

  # Create the webpage condition info.
  my $web_page_condition_info =
    Google::Ads::GoogleAds::V2::Common::WebpageConditionInfo->new({
      operand  => CUSTOM_LABEL,
      argument => $dsa_page_url_label
    });

  # Create the webpage info.
  my $web_page_info = Google::Ads::GoogleAds::V2::Common::WebpageInfo->new({
      criterionName => "Test Criterion",
      conditions    => [$web_page_condition_info]});

  # Create the ad group criterion.
  my $ad_group_criterion =
    Google::Ads::GoogleAds::V2::Resources::AdGroupCriterion->new({
      adGroup      => $ad_group_resource_name,
      webpage      => $web_page_info,
      cpcBidMicros => 1500000
    });

  # Create the operation.
  my $ad_group_criterion_operation =
    Google::Ads::GoogleAds::V2::Services::AdGroupCriterionService::AdGroupCriterionOperation
    ->new({
      create => $ad_group_criterion
    });

  my $ad_group_criterion_response =
    $api_client->AdGroupCriterionService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_criterion_operation]});

  printf "Created ad group criterion with resource name: %s.\n",
    $ad_group_criterion_response->{results}[0]{resourceName};
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
  "customer_id=s" => \$customer_id,
  "campaign_id=i" => \$campaign_id,
  "ad_group_id=i" => \$ad_group_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $campaign_id, $ad_group_id);

# Call the example.
add_dynamic_page_feed($api_client, $customer_id =~ s/-//gr,
  $campaign_id, $ad_group_id);

=pod

=head1 NAME

add_dynamic_page_feed

=head1 DESCRIPTION

This example adds a page feed to specify precisely which URLs to use with your
dynamic search ads campaign.

=head1 SYNOPSIS

add_dynamic_page_feed.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.
    -ad_group_id                The ad group ID.

=cut
