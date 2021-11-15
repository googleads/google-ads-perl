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
# This example fetches the set of valid ProductBiddingCategories.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use
  Google::Ads::GoogleAds::V9::Services::GoogleAdsService::SearchGoogleAdsRequest;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

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

sub get_product_bidding_category_constant {
  my ($api_client, $customer_id) = @_;

  # Create the search query.
  my $search_query =
    "SELECT product_bidding_category_constant.localized_name, " .
    "product_bidding_category_constant." .
    "product_bidding_category_constant_parent " .
    "FROM product_bidding_category_constant " .
    "WHERE product_bidding_category_constant.country_code IN ('US') " .
    "ORDER BY product_bidding_category_constant.localized_name ASC";

  # Create a search Google Ads request that will retrieve all product bidding
  # categories using pages of the specified page size.
  my $search_request =
    Google::Ads::GoogleAds::V9::Services::GoogleAdsService::SearchGoogleAdsRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query,
      pageSize   => PAGE_SIZE
    });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $iterator = Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
    service => $google_ads_service,
    request => $search_request
  });

  # Default the values in the hash to have an array of children, so that
  # we can push children in before we've discovered all the data for the
  # parent category.
  my $all_categories  = {};
  my $root_categories = [];

  while ($iterator->has_next) {
    my $google_ads_row = $iterator->next;
    my $product_bidding_category =
      $google_ads_row->{productBiddingCategoryConstant};

    my $category = {
      name     => $product_bidding_category->{localizedName},
      id       => $product_bidding_category->{resourceName},
      children => []};

    $all_categories->{$category->{id}} = $category;

    my $parent_id =
      $product_bidding_category->{productBiddingCategoryConstantParent};
    if ($parent_id) {
      push @{$all_categories->{$parent_id}{children}}, $category;
    } else {
      push @$root_categories, $category;
    }
  }

  display_categories($root_categories, "");

  return 1;
}

# Recursively prints out each category node and its children.
sub display_categories {
  my ($categories, $prefix) = @_;
  foreach my $category (@$categories) {
    printf "%s%s [%s]\n", $prefix, $category->{name}, $category->{id};
    display_categories($category->{children},
      sprintf("%s%s > ", $prefix, $category->{name}));
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
GetOptions("customer_id=s" => \$customer_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
get_product_bidding_category_constant($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

get_product_bidding_category_constant

=head1 DESCRIPTION

This example fetches the set of valid ProductBiddingCategories.

=head1 SYNOPSIS

get_product_bidding_category_constant.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
