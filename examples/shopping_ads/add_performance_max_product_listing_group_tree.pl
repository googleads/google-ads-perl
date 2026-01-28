#!/usr/bin/perl -w
#
# Copyright 2022, Google LLC
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
# This example shows how to add product partitions to a Performance Max retail campaign.
#
# For Performance Max campaigns, product partitions are represented using the
# AssetGroupListingGroupFilter resource. This resource can be combined with itself
# to form a hierarchy that creates a product partition tree.
#
# For more information about Performance Max retail campaigns, see the
# add_performance_max_retail_campaign example.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::AssetGroupListingGroupFilter;
use Google::Ads::GoogleAds::V23::Resources::ListingGroupFilterDimension;
use Google::Ads::GoogleAds::V23::Resources::ProductCondition;
use Google::Ads::GoogleAds::V23::Resources::ProductBrand;
use Google::Ads::GoogleAds::V23::Enums::ListingGroupFilterTypeEnum
  qw(SUBDIVISION UNIT_INCLUDED);
use Google::Ads::GoogleAds::V23::Enums::ListingGroupFilterListingSourceEnum
  qw(SHOPPING);
use Google::Ads::GoogleAds::V23::Enums::ListingGroupFilterProductConditionEnum
  qw(NEW USED);
use Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation;
use
  Google::Ads::GoogleAds::V23::Services::AssetGroupListingGroupFilterService::AssetGroupListingGroupFilterOperation;
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
my $customer_id    = "INSERT_CUSTOMER_ID_HERE";
my $asset_group_id = "INSERT_ASSET_GROUP_ID_HERE";
# Optional: Removes the existing listing group tree from the asset group or not.
#
# If the current asset group already has a tree of listing group filters, and you
# try to add a new set of listing group filters including a root filter, you'll
# receive a 'ASSET_GROUP_LISTING_GROUP_FILTER_ERROR_MULTIPLE_ROOTS' error.
#
# Setting this option to a defined value will remove the existing tree and prevent
# this error.
my $replace_existing_tree = undef;

# We specify temporary IDs that are specific to a single mutate request.
# Temporary IDs are always negative and unique within one mutate request.
use constant LISTING_GROUP_ROOT_TEMPORARY_ID => -1;

# [START add_performance_max_product_listing_group_tree]
sub add_performance_max_product_listing_group_tree {
  my ($api_client, $customer_id, $asset_group_id, $replace_existing_tree) = @_;

  # We create all the mutate operations that manipulate a specific asset group for
  # a specific customer. The operations are used to optionally remove all asset
  # group listing group filters from the tree, and then to construct a new tree
  # of filters. These filters can have a parent-child relationship, and also include
  # a special root that includes all children.
  #
  # When creating these filters, we use temporary IDs to create the hierarchy between
  # the root listing group filter, and the subdivisions and leave nodes beneath that.
  my $mutate_operations = [];
  if (defined $replace_existing_tree) {
    my $existing_listing_group_filters =
      get_all_existing_listing_group_filter_assets_in_asset_group(
      $api_client,
      $customer_id,
      Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset_group(
        $customer_id, $asset_group_id
      ));

    if (scalar @$existing_listing_group_filters > 0) {
      push @$mutate_operations,
        # Ensure the creation of remove operations in the correct order (child
        # listing group filters must be removed before their parents).
        @{
        create_mutate_operations_for_removing_listing_group_filters_tree(
          $existing_listing_group_filters)};
    }
  }

  push @$mutate_operations,
    create_mutate_operation_for_root($customer_id, $asset_group_id,
    LISTING_GROUP_ROOT_TEMPORARY_ID);

  # The temporary ID to be used for creating subdivisions and units.
  my $temp_id = LISTING_GROUP_ROOT_TEMPORARY_ID - 1;

  push @$mutate_operations,
    create_mutate_operation_for_unit(
    $customer_id,
    $asset_group_id,
    $temp_id--,
    LISTING_GROUP_ROOT_TEMPORARY_ID,
    Google::Ads::GoogleAds::V23::Resources::ListingGroupFilterDimension->new({
        productCondition =>
          Google::Ads::GoogleAds::V23::Resources::ProductCondition->new({
            condition => NEW
          })}));

  push @$mutate_operations,
    create_mutate_operation_for_unit(
    $customer_id,
    $asset_group_id,
    $temp_id--,
    LISTING_GROUP_ROOT_TEMPORARY_ID,
    Google::Ads::GoogleAds::V23::Resources::ListingGroupFilterDimension->new({
        productCondition =>
          Google::Ads::GoogleAds::V23::Resources::ProductCondition->new({
            condition => USED
          })}));

  # We save this ID to create child nodes underneath it.
  my $condition_other_subdivision_id = $temp_id--;

  # We're calling create_mutate_operation_for_subdivision() because this listing
  # group will have children.
  push @$mutate_operations, create_mutate_operation_for_subdivision(
    $customer_id,
    $asset_group_id,
    $condition_other_subdivision_id,
    LISTING_GROUP_ROOT_TEMPORARY_ID,
    Google::Ads::GoogleAds::V23::Resources::ListingGroupFilterDimension->new({
        # All sibling nodes must have the same dimension type. We use an empty
        # ProductCondition to indicate that this is an "Other" partition.
        productCondition =>
          Google::Ads::GoogleAds::V23::Resources::ProductCondition->new({})}));

  push @$mutate_operations,
    create_mutate_operation_for_unit(
    $customer_id,
    $asset_group_id,
    $temp_id--,
    $condition_other_subdivision_id,
    Google::Ads::GoogleAds::V23::Resources::ListingGroupFilterDimension->new({
        productBrand =>
          Google::Ads::GoogleAds::V23::Resources::ProductBrand->new({
            value => "CoolBrand"
          })}));

  push @$mutate_operations,
    create_mutate_operation_for_unit(
    $customer_id,
    $asset_group_id,
    $temp_id--,
    $condition_other_subdivision_id,
    Google::Ads::GoogleAds::V23::Resources::ListingGroupFilterDimension->new({
        productBrand =>
          Google::Ads::GoogleAds::V23::Resources::ProductBrand->new({
            value => "CheapBrand"
          })}));

  push @$mutate_operations, create_mutate_operation_for_unit(
    $customer_id,
    $asset_group_id,
    $temp_id--,
    $condition_other_subdivision_id,
    # All other product brands.
    Google::Ads::GoogleAds::V23::Resources::ListingGroupFilterDimension->new({
        productBrand =>
          Google::Ads::GoogleAds::V23::Resources::ProductBrand->new({})}));

  # Issue a mutate request to create everything and print its information.
  my $response = $api_client->GoogleAdsService()->mutate({
    customerId       => $customer_id,
    mutateOperations => $mutate_operations
  });

  print_response_details($mutate_operations, $response);

  return 1;
}
# [END add_performance_max_product_listing_group_tree]

# [START add_performance_max_product_listing_group_tree_7]
# Fetches all of the asset group listing group filters in an asset group.
sub get_all_existing_listing_group_filter_assets_in_asset_group {
  my ($api_client, $customer_id, $asset_group_resource_name) = @_;

  # Create a query that retrieves asset group listing group filters.
  # The limit to the number of listing group filters permitted in a Performance
  # Max campaign can be found here:
  # https://developers.google.com/google-ads/api/docs/best-practices/system-limits.
  my $query =
    sprintf "SELECT asset_group_listing_group_filter.resource_name, " .
    "asset_group_listing_group_filter.parent_listing_group_filter " .
    "FROM asset_group_listing_group_filter " .
    "WHERE asset_group_listing_group_filter.asset_group = '%s'",
    $asset_group_resource_name;

  # Issue a search request by specifying page size.
  my $response = $api_client->GoogleAdsService()->search({
    customerId => $customer_id,
    query      => $query
  });

  my $asset_group_listing_group_filters = [];
  # Iterate over all rows in all pages to get an asset group listing group filter.
  foreach my $google_ads_row (@{$response->{results}}) {
    push @$asset_group_listing_group_filters,
      $google_ads_row->{assetGroupListingGroupFilter};
  }

  return $asset_group_listing_group_filters;
}
# [END add_performance_max_product_listing_group_tree_7]

# Creates mutate operations for removing an existing tree of asset group listing
# group filters.
#
# Asset group listing group filters must be removed in a specific order: all of
# the children of a filter must be removed before the filter itself, otherwise
# the API will return an error.
sub create_mutate_operations_for_removing_listing_group_filters_tree {
  my ($asset_group_listing_group_filters) = @_;
  if (scalar @$asset_group_listing_group_filters == 0) {
    die "No listing group filters to remove.";
  }

  my $resource_names_to_listing_group_filters = {};
  my $parents_to_children                     = {};
  my $root_resource_name                      = undef;
  foreach
    my $asset_group_listing_group_filter (@$asset_group_listing_group_filters)
  {
    $resource_names_to_listing_group_filters->
      {$asset_group_listing_group_filter->{resourceName}} =
      $asset_group_listing_group_filter;
    # When the node has no parent, it means it's the root node, which is treated
    # differently.
    if (!defined $asset_group_listing_group_filter->{parentListingGroupFilter})
    {
      if (defined $root_resource_name) {
        die "More than one root node found.";
      }
      $root_resource_name = $asset_group_listing_group_filter->{resourceName};
      next;
    }

    my $parent_resource_name =
      $asset_group_listing_group_filter->{parentListingGroupFilter};
    my $siblings = [];

    # Check to see if we've already visited a sibling in this group and fetch it.
    if (exists $parents_to_children->{$parent_resource_name}) {
      $siblings = $parents_to_children->{$parent_resource_name};
    }
    push @$siblings, $asset_group_listing_group_filter->{resourceName};
    $parents_to_children->{$parent_resource_name} = $siblings;
  }

  # [START add_performance_max_product_listing_group_tree_2]
  return create_mutate_operations_for_removing_descendents($root_resource_name,
    $parents_to_children);
  # [END add_performance_max_product_listing_group_tree_2]
}

# [START add_performance_max_product_listing_group_tree_3]
# Creates a list of mutate operations that remove all the descendents of the
# specified asset group listing group filter's resource name. The order of removal
# is post-order, where all the children (and their children, recursively) are
# removed first. Then, the node itself is removed.
sub create_mutate_operations_for_removing_descendents {
  my ($asset_group_listing_group_filter_resource_name, $parents_to_children) =
    @_;

  my $operations = [];
  if (
    exists $parents_to_children->
    {$asset_group_listing_group_filter_resource_name})
  {
    foreach my $child (
      @{$parents_to_children->{$asset_group_listing_group_filter_resource_name}}
      )
    {
      push @$operations,
        @{
        create_mutate_operations_for_removing_descendents($child,
          $parents_to_children)};
    }
  }

  push @$operations,
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({
      assetGroupListingGroupFilterOperation =>
        Google::Ads::GoogleAds::V23::Services::AssetGroupListingGroupFilterService::AssetGroupListingGroupFilterOperation
        ->new({
          remove => $asset_group_listing_group_filter_resource_name
        })});

  return $operations;
}
# [END add_performance_max_product_listing_group_tree_3]

# [START add_performance_max_product_listing_group_tree_4]
# Creates a mutate operation that creates a root asset group listing group filter
# for the factory's asset group.
#
# The root node or partition is the default, which is displayed as "All Products".
sub create_mutate_operation_for_root {
  my ($customer_id, $asset_group_id, $root_listing_group_id) = @_;

  my $asset_group_listing_group_filter =
    Google::Ads::GoogleAds::V23::Resources::AssetGroupListingGroupFilter->new({
      resourceName =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset_group_listing_group_filter(
        $customer_id, $asset_group_id, $root_listing_group_id
        ),
      assetGroup =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset_group(
        $customer_id, $asset_group_id
        ),
      # Since this is the root node, do not set the 'parentListingGroupFilter' field.
      # For all other nodes, this would refer to the parent listing group filter
      # resource name.

      # Unlike add_performance_max_retail_campaign, the type for the root node
      # here must be SUBDIVISION because we add child partitions under it.
      type => SUBDIVISION,
      # Because this is a Performance Max campaign for retail, we need to specify
      # that this is in the shopping listing source.
      listingSource => SHOPPING
    });

  return
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({
      assetGroupListingGroupFilterOperation =>
        Google::Ads::GoogleAds::V23::Services::AssetGroupListingGroupFilterService::AssetGroupListingGroupFilterOperation
        ->new({
          create => $asset_group_listing_group_filter
        })});
}
# [END add_performance_max_product_listing_group_tree_4]

# [START add_performance_max_product_listing_group_tree_5]
# Creates a mutate operation that creates a intermediate asset group listing group filter.
sub create_mutate_operation_for_subdivision {
  my ($customer_id, $asset_group_id, $asset_group_listing_group_filter_id,
    $parent_id, $listing_group_filter_dimension)
    = @_;

  my $asset_group_listing_group_filter =
    Google::Ads::GoogleAds::V23::Resources::AssetGroupListingGroupFilter->new({
      resourceName =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset_group_listing_group_filter(
        $customer_id, $asset_group_id, $asset_group_listing_group_filter_id
        ),
      assetGroup =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset_group(
        $customer_id, $asset_group_id
        ),
      # Set the type as a SUBDIVISION, which will allow the node to be the parent
      # of another sub-tree.
      type => SUBDIVISION,
      # Because this is a Performance Max campaign for retail, we need to specify
      # that this is in the shopping listing source.
      listingSource            => SHOPPING,
      parentListingGroupFilter =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset_group_listing_group_filter(
        $customer_id, $asset_group_id, $parent_id
        ),
      # Case values contain the listing dimension used for the node.
      caseValue => $listing_group_filter_dimension
    });

  return
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({
      assetGroupListingGroupFilterOperation =>
        Google::Ads::GoogleAds::V23::Services::AssetGroupListingGroupFilterService::AssetGroupListingGroupFilterOperation
        ->new({
          create => $asset_group_listing_group_filter
        })});
}
# [END add_performance_max_product_listing_group_tree_5]

# [START add_performance_max_product_listing_group_tree_6]
# Creates a mutate operation that creates a child asset group listing group filter
# (unit node).
#
# Use this method if the filter won't have child filters. Otherwise, use
# create_mutate_operation_for_subdivision().
sub create_mutate_operation_for_unit {
  my ($customer_id, $asset_group_id, $asset_group_listing_group_filter_id,
    $parent_id, $listing_group_filter_dimension)
    = @_;

  my $asset_group_listing_group_filter =
    Google::Ads::GoogleAds::V23::Resources::AssetGroupListingGroupFilter->new({
      resourceName =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset_group_listing_group_filter(
        $customer_id, $asset_group_id, $asset_group_listing_group_filter_id
        ),
      assetGroup =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset_group(
        $customer_id, $asset_group_id
        ),
      parentListingGroupFilter =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::asset_group_listing_group_filter(
        $customer_id, $asset_group_id, $parent_id
        ),
      # Set the type as a UNIT_INCLUDED to indicate that this asset group listing
      # group filter won't have children.
      type => UNIT_INCLUDED,
      # Because this is a Performance Max campaign for retail, we need to specify
      # that this is in the shopping listing source.
      listingSource => SHOPPING,
      caseValue     => $listing_group_filter_dimension
    });

  return
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::MutateOperation->
    new({
      assetGroupListingGroupFilterOperation =>
        Google::Ads::GoogleAds::V23::Services::AssetGroupListingGroupFilterService::AssetGroupListingGroupFilterOperation
        ->new({
          create => $asset_group_listing_group_filter
        })});
}
# [END add_performance_max_product_listing_group_tree_6]

# Prints the details of a mutate google ads response. Parses the "response" oneof
# field name and uses it to extract the new entity's name and resource name.
sub print_response_details {
  my ($mutate_operations, $mutate_google_ads_response) = @_;

  while (my ($i, $operation_response) =
    each @{$mutate_google_ads_response->{mutateOperationResponses}})
  {
    if (!exists $operation_response->{assetGroupListingGroupFilterResult}) {
      # Trim the substring "Result" from the end of the entity name.
      my $result_type = [keys %$operation_response]->[0];
      printf "Unsupported entity type: %s.\n", $result_type =~ s/Result$//r;
      next;
    }

    my $operation =
      $mutate_operations->[$i]{assetGroupListingGroupFilterOperation};
    if (exists $operation->{create}) {
      printf "Created an asset group listing group filter with resource name: "
        . "'%s'.\n",
        $operation_response->{assetGroupListingGroupFilterResult}{resourceName};
    } elsif (exists $operation->{remove}) {
      printf "Removed an asset group listing group filter with resource name: "
        . "'%s'.\n",
        $operation_response->{assetGroupListingGroupFilterResult}{resourceName};
    } else {
      printf
        "Unsupported operation type: '%s'.\n",
        [keys %$operation]->[0];
    }
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
  "customer_id=s"           => \$customer_id,
  "asset_group_id=i"        => \$asset_group_id,
  "replace_existing_tree=s" => \$replace_existing_tree
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $asset_group_id);

# Call the example.
add_performance_max_product_listing_group_tree(
  $api_client,     $customer_id =~ s/-//gr,
  $asset_group_id, $replace_existing_tree
);

=pod

=head1 NAME

add_performance_max_product_listing_group_tree

=head1 DESCRIPTION

This example shows how to add product partitions to a Performance Max retail campaign.

For Performance Max campaigns, product partitions are represented using the
AssetGroupListingGroupFilter resource. This resource can be combined with itself
to form a hierarchy that creates a product partition tree.

For more information about Performance Max retail campaigns, see the
add_performance_max_retail_campaign example.

=head1 SYNOPSIS

add_performance_max_product_listing_group_tree.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -asset_group_id             The asset group ID.
    -replace_existing_tree      [optional] Whether it should replace the existing
                                listing group tree on an asset group.

=cut
