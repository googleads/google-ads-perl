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
# This example shows how to add a hotel listing group tree, which has two
# levels. The first level is partitioned by the hotel class. The second
# level is partitioned by the country region.
#
# Each level is composed of two types of nodes: `UNIT` and `SUBDIVISION`.
# `UNIT` nodes serve as a leaf node in a tree and can have bid amount set.
# `SUBDIVISION` nodes serve as an internal node where a subtree will be
# built. The `SUBDIVISION` node can't have bid amount set.
# See https://developers.google.com/google-ads/api/docs/hotel-ads/overview
# for more information.
#
# Note: Only one listing group tree can be added. Attempting to add another
# listing group tree to an ad group that already has one will fail.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::AdGroupCriterion;
use Google::Ads::GoogleAds::V23::Common::ListingGroupInfo;
use Google::Ads::GoogleAds::V23::Common::ListingDimensionInfo;
use Google::Ads::GoogleAds::V23::Common::HotelClassInfo;
use Google::Ads::GoogleAds::V23::Common::HotelCountryRegionInfo;
use Google::Ads::GoogleAds::V23::Enums::ListingGroupTypeEnum
  qw(SUBDIVISION UNIT);
use Google::Ads::GoogleAds::V23::Enums::AdGroupCriterionStatusEnum qw(ENABLED);
use
  Google::Ads::GoogleAds::V23::Services::AdGroupCriterionService::AdGroupCriterionOperation;
use Google::Ads::GoogleAds::V23::Utils::ResourceNames;

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
my $customer_id = "INSERT_CUSTOMER_ID_HERE";
my $ad_group_id = "INSERT_AD_GROUP_ID_HERE";
# Specify the Percent CPC bid micro amount to be set on a created ad group
# criterion. For simplicity, each ad group criterion will use the below amount
# equally. In practice, you probably want to use different values for each ad
# group criterion.
my $percent_cpc_bid_micro_amount = 1000000;

sub add_hotel_listing_group_tree {
  my ($api_client, $customer_id, $ad_group_id, $percent_cpc_bid_micro_amount) =
    @_;

  # Create a list of ad group criteria operations to add.
  my $operations = [];

  # Create the root of the tree as a SUBDIVISION node.
  my $root_resource_name =
    add_root_node($customer_id, $ad_group_id, $operations,
    $percent_cpc_bid_micro_amount);

  # Create child nodes of level 1, partitioned by the hotel class info.
  my $other_hotel_resource_name =
    add_level_1_nodes($customer_id, $ad_group_id, $root_resource_name,
    $operations, $percent_cpc_bid_micro_amount);

  # Create child nodes of level 2, partitioned by the hotel country region info.
  add_level_2_nodes($customer_id, $ad_group_id, $other_hotel_resource_name,
    $operations, $percent_cpc_bid_micro_amount);

  my $ad_group_criteria_response =
    $api_client->AdGroupCriterionService()->mutate({
      customerId => $customer_id,
      operations => $operations
    });

  my $ad_group_criterion_results = $ad_group_criteria_response->{results};
  printf "Added %d listing group info entities:\n",
    scalar @$ad_group_criterion_results;

  foreach my $ad_group_criterion_result (@$ad_group_criterion_results) {
    printf "\t%s\n", $ad_group_criterion_result->{resourceName};
  }

  return 1;
}

# Creates the root node of the listing group tree and adds its create operation
# to the operations list.
sub add_root_node {
  my ($customer_id, $ad_group_id, $operations, $percent_cpc_bid_micro_amount) =
    @_;

  # Create the root of the tree as a SUBDIVISION node.
  my $root = create_listing_group_info(SUBDIVISION);
  my $root_ad_group_criterion =
    create_ad_group_criterion($customer_id, $ad_group_id, $root,
    $percent_cpc_bid_micro_amount);
  my $operation = generate_create_operation($root_ad_group_criterion);
  push @$operations, $operation;

  return $root_ad_group_criterion->{resourceName};
}

# Creates child nodes of level 1, partitioned by the hotel class info.
# [START add_hotel_listing_group_tree]
sub add_level_1_nodes {
  my ($customer_id, $ad_group_id, $root_resource_name, $operations,
    $percent_cpc_bid_micro_amount)
    = @_;

  # Create hotel class info and dimension info for 5-star hotels.
  my $five_starred_dimension_info =
    Google::Ads::GoogleAds::V23::Common::ListingDimensionInfo->new({
      hotelClass => Google::Ads::GoogleAds::V23::Common::HotelClassInfo->new({
          value => 5
        })});

  # Create listing group info for 5-star hotels as a UNIT node.
  my $five_starred_unit = create_listing_group_info(UNIT, $root_resource_name,
    $five_starred_dimension_info);

  # Create an ad group criterion for 5-star hotels.
  my $five_starred_ad_group_criterion =
    create_ad_group_criterion($customer_id, $ad_group_id, $five_starred_unit,
    $percent_cpc_bid_micro_amount);

  my $operation = generate_create_operation($five_starred_ad_group_criterion);
  push @$operations, $operation;

  # You can also create more UNIT nodes for other hotel classes by copying the
  # above code in this method and modifying the value passed to HotelClassInfo
  # to the value you want. For instance, passing 4 instead of 5 in the above code
  #  will create a UNIT node of 4-star hotels instead.

  # Create hotel class info and dimension info for other hotel classes by *not*
  # specifying any attributes on those object.
  my $others_hotels_dimension_info =
    Google::Ads::GoogleAds::V23::Common::ListingDimensionInfo->new({
      hotelClass => Google::Ads::GoogleAds::V23::Common::HotelClassInfo->new()}
    );

  # Create listing group info for other hotel classes as a SUBDIVISION node, which
  # will be used as a parent node for children nodes of the next level.
  my $other_hotels_subdivision =
    create_listing_group_info(SUBDIVISION, $root_resource_name,
    $others_hotels_dimension_info);

  # Create an ad group criterion for other hotel classes.
  my $other_hotels_ad_group_criterion =
    create_ad_group_criterion($customer_id, $ad_group_id,
    $other_hotels_subdivision, $percent_cpc_bid_micro_amount);

  $operation = generate_create_operation($other_hotels_ad_group_criterion);
  push @$operations, $operation;

  return $other_hotels_ad_group_criterion->{resourceName};
}
# [END add_hotel_listing_group_tree]

# Creates child nodes of level 2, partitioned by the country region.
sub add_level_2_nodes {
  my ($customer_id, $ad_group_id, $parent_resource_name, $operations,
    $percent_cpc_bid_micro_amount)
    = @_;

  # The criterion ID for Japan is 2392.
  # See https://developers.google.com/google-ads/api/reference/data/geotargets
  # for criteria ID of other countries.
  my $japan_geo_target_constant_id = 2392;
  my $japan_dimension_info =
    Google::Ads::GoogleAds::V23::Common::ListingDimensionInfo->new({
      # Create hotel country region info and dimension info for hotels in Japan.
      hotelCountryRegion =>
        Google::Ads::GoogleAds::V23::Common::HotelCountryRegionInfo->new({
          countryRegionCriterion =>
            Google::Ads::GoogleAds::V23::Utils::ResourceNames::geo_target_constant(
            $japan_geo_target_constant_id)})});

  # Create listing group info for hotels in Japan as a UNIT node.
  my $japan_hotels_unit = create_listing_group_info(UNIT, $parent_resource_name,
    $japan_dimension_info);

  # Create an ad group criterion for hotels in Japan.
  my $japan_hotels_ad_group_criterion =
    create_ad_group_criterion($customer_id, $ad_group_id, $japan_hotels_unit,
    $percent_cpc_bid_micro_amount);

  my $operation = generate_create_operation($japan_hotels_ad_group_criterion);
  push @$operations, $operation;

  # Create hotel class info and dimension info for hotels in other regions.
  my $other_hotel_regions_dimension_info =
    Google::Ads::GoogleAds::V23::Common::ListingDimensionInfo->new({
      hotelCountryRegion =>
        Google::Ads::GoogleAds::V23::Common::HotelCountryRegionInfo->new()});

  # Create listing group info for hotels in other regions as a UNIT node.
  # The "others" node is always required for every level of the tree.
  my $other_hotel_regions_unit =
    create_listing_group_info(UNIT, $parent_resource_name,
    $other_hotel_regions_dimension_info);

  # Create an ad group criterion for other hotel country regions.
  my $other_hotel_regions_ad_group_criterion =
    create_ad_group_criterion($customer_id, $ad_group_id,
    $other_hotel_regions_unit, $percent_cpc_bid_micro_amount);

  $operation =
    generate_create_operation($other_hotel_regions_ad_group_criterion);
  push @$operations, $operation;
}

# Creates the listing group info with the provided parameters.
sub create_listing_group_info {
  my ($listing_group_type, $parent_criterion_resource_name, $case_value) = @_;

  my $listing_group_info =
    Google::Ads::GoogleAds::V23::Common::ListingGroupInfo->new({
      type => $listing_group_type
    });

  if ($parent_criterion_resource_name) {
    $listing_group_info->{parentAdGroupCriterion} =
      $parent_criterion_resource_name;
    $listing_group_info->{caseValue} = $case_value;
  }

  return $listing_group_info;
}

# Creates an ad group criterion from the provided listing group info.
# Bid amount will be set on the created ad group criterion when listing group info type
# is `UNIT`. Setting bid amount for `SUBDIVISION` types is not allowed.
sub create_ad_group_criterion {
  my ($customer_id, $ad_group_id, $listing_group_info,
    $percent_cpc_bid_micro_amount)
    = @_;

  my $ad_group_criterion =
    Google::Ads::GoogleAds::V23::Resources::AdGroupCriterion->new({
      status       => ENABLED,
      listingGroup => $listing_group_info,
      resourceName =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::ad_group_criterion(
        $customer_id, $ad_group_id, next_id())});

  # Bids are valid only for UNIT nodes.
  if ($listing_group_info->{type} eq UNIT) {
    $ad_group_criterion->{percentCpcBidMicros} = $percent_cpc_bid_micro_amount;
  }

  return $ad_group_criterion;
}

# Creates an operation for creating the specified ad group criterion.
sub generate_create_operation {
  my $ad_group_criterion = shift;
  return
    Google::Ads::GoogleAds::V23::Services::AdGroupCriterionService::AdGroupCriterionOperation
    ->new({
      create => $ad_group_criterion
    });
}

# Specifies a decreasing negative number for temporary ad group criteria IDs.
# The ad group criteria will get real IDs when created on the server.
# Returns -1, -2, -3, etc. on subsequent calls.
sub next_id {
  our $id ||= 0;
  $id -= 1;
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
  "customer_id=s"                  => \$customer_id,
  "ad_group_id=i"                  => \$ad_group_id,
  "percent_cpc_bid_micro_amount=i" => \$percent_cpc_bid_micro_amount
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if
  not check_params($customer_id, $ad_group_id, $percent_cpc_bid_micro_amount);

# Call the example.
add_hotel_listing_group_tree(
  $api_client,  $customer_id =~ s/-//gr,
  $ad_group_id, $percent_cpc_bid_micro_amount
);

=pod

=head1 NAME

add_hotel_listing_group_tree

=head1 DESCRIPTION

This example shows how to add a hotel listing group tree, which has two levels.
The first level is partitioned by the hotel class. The second level is partitioned
by the country region.

Each level is composed of two types of nodes: `UNIT` and `SUBDIVISION`.
`UNIT` nodes serve as a leaf node in a tree and can have bid amount set.
`SUBDIVISION` nodes serve as an internal node where a subtree will be built. The
`SUBDIVISION` node can't have bid amount set.
See https://developers.google.com/google-ads/api/docs/hotel-ads/overview for more information.

Note: Only one listing group tree can be added. Attempting to add another listing
group tree to an ad group that already has one will fail.

=head1 SYNOPSIS

add_hotel_listing_group_tree.pl [options]

    -help                           Show the help message.
    -customer_id                    The Google Ads customer ID.
    -ad_group_id                    The hotel ad group ID.
    -percent_cpc_bid_micro_amount   [optional] The percent CPC bid micro amount

=cut
