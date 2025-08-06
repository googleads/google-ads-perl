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
# This example shows how to add a shopping listing group tree to a shopping ad
# group. The example will optionally clear an existing listing group tree and
# rebuild it to include the following tree structure:
#
# ProductCanonicalCondition NEW $0.20
# ProductCanonicalCondition USED $0.10
# ProductCanonicalCondition null (everything else)
#   ProductBrand CoolBrand $0.90
#   ProductBrand CheapBrand $0.01
#   ProductBrand null (everything else) $0.50

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use Google::Ads::GoogleAds::V21::Resources::AdGroupCriterion;
use Google::Ads::GoogleAds::V21::Common::ListingGroupInfo;
use Google::Ads::GoogleAds::V21::Common::ListingDimensionInfo;
use Google::Ads::GoogleAds::V21::Common::ProductConditionInfo;
use Google::Ads::GoogleAds::V21::Common::ProductBrandInfo;
use Google::Ads::GoogleAds::V21::Enums::ListingGroupTypeEnum
  qw(SUBDIVISION UNIT);
use Google::Ads::GoogleAds::V21::Enums::AdGroupCriterionStatusEnum qw(ENABLED);
use Google::Ads::GoogleAds::V21::Enums::ProductConditionEnum       qw(NEW USED);
use
  Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation;
use
  Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsRequest;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id           = "INSERT_CUSTOMER_ID_HERE";
my $ad_group_id           = "INSERT_AD_GROUP_ID_HERE";
my $replace_existing_tree = undef;

# [START add_shopping_product_listing_group_tree]
sub add_shopping_product_listing_group_tree {
  my ($api_client, $customer_id, $ad_group_id, $replace_existing_tree) = @_;

  # 1) Optional: Remove the existing listing group tree, if it already exists
  # on the ad group.
  if ($replace_existing_tree) {
    remove_listing_group_tree($api_client, $customer_id, $ad_group_id);
  }

  # Create a list of ad group criteria operations to add.
  my $operations = [];

  # 2) Construct the listing group tree "root" node.

  # Subdivision node: (Root node)
  my $ad_group_criterion_root =
    create_listing_group_subdivision($customer_id, $ad_group_id);
  # Get the resource name that will be used for the root node.
  # This resource has not been created yet and will include the temporary ID as
  # part of the criterion ID.
  my $ad_group_criterion_root_resource_name =
    $ad_group_criterion_root->{resourceName};
  push @$operations,
    Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation
    ->new({
      create => $ad_group_criterion_root
    });

  # 3) Construct the listing group unit nodes for NEW, USED, and other.

  # Biddable Unit node: (Condition NEW node)
  # * Product Condition: NEW
  # * CPC bid: $0.20
  my $ad_group_criterion_condition_new = create_listing_group_unit_biddable(
    $customer_id,
    $ad_group_id,
    $ad_group_criterion_root_resource_name,
    Google::Ads::GoogleAds::V21::Common::ListingDimensionInfo->new({
        productCondition =>
          Google::Ads::GoogleAds::V21::Common::ProductConditionInfo->new({
            condition => NEW
          })}
    ),
    200000
  );
  push @$operations,
    Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation
    ->new({
      create => $ad_group_criterion_condition_new
    });

  # Biddable Unit node: (Condition USED node)
  # * Product Condition: USED
  # * CPC bid: $0.10
  my $ad_group_criterion_condition_used = create_listing_group_unit_biddable(
    $customer_id,
    $ad_group_id,
    $ad_group_criterion_root_resource_name,
    Google::Ads::GoogleAds::V21::Common::ListingDimensionInfo->new({
        productCondition =>
          Google::Ads::GoogleAds::V21::Common::ProductConditionInfo->new({
            condition => USED
          })}
    ),
    100000
  );
  push @$operations,
    Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation
    ->new({
      create => $ad_group_criterion_condition_used
    });

  # Sub-division node: (Condition "other" node)
  # * Product Condition: (not specified)
  my $ad_group_criterion_condition_other = create_listing_group_subdivision(
    $customer_id,
    $ad_group_id,
    $ad_group_criterion_root_resource_name,
    Google::Ads::GoogleAds::V21::Common::ListingDimensionInfo->new({
        # All sibling nodes must have the same dimension type, even if they
        # don't contain a bid.
        productCondition =>
          Google::Ads::GoogleAds::V21::Common::ProductConditionInfo->new()}));
  push @$operations,
    Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation
    ->new({
      create => $ad_group_criterion_condition_other
    });

  # Get the resource name that will be used for the condition other node.
  # This resource has not been created yet and will include the temporary ID as
  # part of the criterion ID.
  my $ad_group_criterion_condition_other_resource_name =
    $ad_group_criterion_condition_other->{resourceName};

  # 4) Construct the listing group unit nodes for CoolBrand, CheapBrand, and
  # other.

  # Biddable Unit node: (Brand CoolBrand node)
  # * Brand: CoolBrand
  # * CPC bid: $0.90
  my $ad_group_criterion_brand_cool_brand = create_listing_group_unit_biddable(
    $customer_id,
    $ad_group_id,
    $ad_group_criterion_condition_other_resource_name,
    Google::Ads::GoogleAds::V21::Common::ListingDimensionInfo->new({
        productBrand =>
          Google::Ads::GoogleAds::V21::Common::ProductBrandInfo->new(
          {value => "CoolBrand"})}
    ),
    900000
  );
  push @$operations,
    Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation
    ->new({
      create => $ad_group_criterion_brand_cool_brand
    });

  # Biddable Unit node: (Brand CheapBrand node)
  # * Brand: CheapBrand
  # * CPC bid: $0.01
  my $ad_group_criterion_brand_cheap_brand = create_listing_group_unit_biddable(
    $customer_id,
    $ad_group_id,
    $ad_group_criterion_condition_other_resource_name,
    Google::Ads::GoogleAds::V21::Common::ListingDimensionInfo->new({
        productBrand =>
          Google::Ads::GoogleAds::V21::Common::ProductBrandInfo->new(
          {value => "CheapBrand"})}
    ),
    10000
  );
  push @$operations,
    Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation
    ->new({
      create => $ad_group_criterion_brand_cheap_brand
    });

  # Biddable Unit node: (Brand other node)
  # * CPC bid: $0.05
  my $ad_group_criterion_brand_other_brand = create_listing_group_unit_biddable(
    $customer_id,
    $ad_group_id,
    $ad_group_criterion_condition_other_resource_name,
    Google::Ads::GoogleAds::V21::Common::ListingDimensionInfo->new({
        productBrand =>
          Google::Ads::GoogleAds::V21::Common::ProductBrandInfo->new()}
    ),
    50000
  );
  push @$operations,
    Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation
    ->new({
      create => $ad_group_criterion_brand_other_brand
    });

  # Add the ad group criterion.
  my $ad_group_criteria_response =
    $api_client->AdGroupCriterionService()->mutate({
      customerId => $customer_id,
      operations => $operations
    });

  printf "Added %d ad group criteria for listing group tree with the " .
    "following resource names:\n",
    scalar @{$ad_group_criteria_response->{results}};

  foreach my $result (@{$ad_group_criteria_response->{results}}) {
    print $result->{resourceName}, "\n";
  }

  return 1;
}
# [END add_shopping_product_listing_group_tree]

# Removes all the ad group criteria that define the existing listing group
# tree for an ad group.
sub remove_listing_group_tree {
  my ($api_client, $customer_id, $ad_group_id) = @_;

  my $search_query =
    "SELECT ad_group_criterion.resource_name " .
    "FROM ad_group_criterion WHERE ad_group_criterion.type = LISTING_GROUP " .
    "AND ad_group_criterion.listing_group.parent_ad_group_criterion IS NULL " .
    "AND ad_group.id = $ad_group_id";

  # Create a search Google Ads request that will retrieve all listing groups
  # where the parent ad group criterion is NULL (and hence the root node in
  # the tree) for a given ad group id.
  my $search_request =
    Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query
    });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $iterator = Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
    service => $google_ads_service,
    request => $search_request
  });

  my $operations = [];
  # Iterate over all rows in all pages to find the ad group criterion to remove.
  while ($iterator->has_next) {
    my $google_ads_row     = $iterator->next;
    my $ad_group_criterion = $google_ads_row->{adGroupCriterion};
    printf "Found an ad group criterion with the resource name: '%s'.\n",
      $ad_group_criterion->{resourceName};

    # Create an ad group criterion operation.
    my $ad_group_criterion_operation =
      Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation
      ->new({
        remove => $ad_group_criterion->{resourceName}});

    push @$operations, $ad_group_criterion_operation;
  }

  if (scalar @$operations) {
    # Remove the ad group criterion that define the listing group tree.
    my $ad_group_criteria_response =
      $api_client->AdGroupCriterionService()->mutate({
        customerId => $customer_id,
        operations => $operations
      });

    printf "Removed %d ad group criteria.\n",
      scalar @{$ad_group_criteria_response->{results}};
  }
}

# Creates a new criterion containing a subdivision listing group node. If
# the parent ad group criterion resource name is not specified, this method
# creates a root node.
sub create_listing_group_subdivision {
  my ($customer_id, $ad_group_id, $parent_ad_group_criterion_resource_name,
    $listing_dimension_info)
    = @_;

  my $listing_group_info =
    Google::Ads::GoogleAds::V21::Common::ListingGroupInfo->new({
      # Set the type as a SUBDIVISION, which will allow the node to be the
      # parent of another sub-tree.
      'type' => SUBDIVISION
    });

  # If $parent_ad_group_criterion_resource_name and $listing_dimension_info
  # are not null, create a non-root division by setting its parent and case value.
  if ($parent_ad_group_criterion_resource_name and $listing_dimension_info) {
    # Set the ad group criterion resource name for the parent listing group.
    # This can include a temporary ID if the parent criterion is not yet created.
    $listing_group_info->{parentAdGroupCriterion} =
      $parent_ad_group_criterion_resource_name;

    # Case values contain the listing dimension used for the node.
    $listing_group_info->{caseValue} = $listing_dimension_info;
  }

  my $ad_group_criterion =
    Google::Ads::GoogleAds::V21::Resources::AdGroupCriterion->new({
      # The resource name the criterion will be created with. This will define
      # the ID for the ad group criterion.
      resourceName =>
        Google::Ads::GoogleAds::V21::Utils::ResourceNames::ad_group_criterion(
        $customer_id, $ad_group_id, next_id()
        ),
      status       => ENABLED,
      listingGroup => $listing_group_info
    });

  return $ad_group_criterion;
}

# Creates a new criterion containing a biddable unit listing group node.
sub create_listing_group_unit_biddable {
  my ($customer_id, $ad_group_id, $parent_ad_group_criterion_resource_name,
    $listing_dimension_info, $cpc_bid_micros)
    = @_;

  # Note: There are two approaches for creating new unit nodes:
  # (1) Set the ad group resource name on the criterion (no temporary ID
  # required).
  # (2) Use a temporary ID to construct the criterion resource name and set it
  # to the 'resourceName' attribute.
  # In both cases you must set the parent ad group criterion's resource name on
  # the listing group for non-root nodes.
  # This example demonstrates method (1).
  my $ad_group_criterion =
    Google::Ads::GoogleAds::V21::Resources::AdGroupCriterion->new({
      adGroup => Google::Ads::GoogleAds::V21::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      ),
      status       => ENABLED,
      listingGroup =>
        Google::Ads::GoogleAds::V21::Common::ListingGroupInfo->new({
          # Set the type as a UNIT, which will allow the group to be biddable.
          type => UNIT,
          # Set the ad group criterion resource name for the parent listing group.
          # This can include a temporary ID if the parent criterion is not yet created.
          parentAdGroupCriterion => $parent_ad_group_criterion_resource_name,
          # Case values contain the listing dimension used for the node.
          caseValue => $listing_dimension_info
        }
        ),
      # Set the bid for this listing group unit.
      # This will be used as the CPC bid for items that are included in this
      # listing group.
      cpcBidMicros => $cpc_bid_micros
    });

  return $ad_group_criterion;
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
  "customer_id=s"           => \$customer_id,
  "ad_group_id=i"           => \$ad_group_id,
  "replace_existing_tree=s" => \$replace_existing_tree
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $ad_group_id);

# Call the example.
add_shopping_product_listing_group_tree($api_client, $customer_id =~ s/-//gr,
  $ad_group_id, $replace_existing_tree);

=pod

=head1 NAME

add_shopping_product_listing_group_tree

=head1 DESCRIPTION

This example shows how to add a shopping listing group tree to a shopping ad group.
The example will optionally clear an existing listing group tree and rebuild it to
include the following tree structure:

ProductCanonicalCondition NEW $0.20
ProductCanonicalCondition USED $0.10
ProductCanonicalCondition null (everything else)
  ProductBrand CoolBrand $0.90
  ProductBrand CheapBrand $0.01
  ProductBrand null (everything else) $0.50

=head1 SYNOPSIS

add_shopping_product_listing_group_tree.pl [options]

    -help                           Show the help message.
    -customer_id                    The Google Ads customer ID.
    -ad_group_id                    The ad group ID.
    -replace_existing_tree          [optional] Replace the existing listing group tree
                                    on the ad group, if it already exists.

=cut
