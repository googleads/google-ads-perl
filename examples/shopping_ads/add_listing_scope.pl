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
# Adds a shopping listing scope to a shopping campaign. The example will construct
# and add a new listing scope which will act as the inventory filter for the campaign.
# The campaign will only advertise products that match the following requirements:
#
# - Brand is "google"
# - Custom label 0 is "top_selling_products"
# - Product type (level 1) is "electronics"
# - Product type (level 2) is "smartphones"
#
# Only one listing scope is allowed per campaign. Remove any existing listing
# scopes before running this example.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V20::Resources::CampaignCriterion;
use Google::Ads::GoogleAds::V20::Common::ListingDimensionInfo;
use Google::Ads::GoogleAds::V20::Common::ProductBrandInfo;
use Google::Ads::GoogleAds::V20::Common::ProductCustomAttributeInfo;
use Google::Ads::GoogleAds::V20::Common::ProductTypeInfo;
use Google::Ads::GoogleAds::V20::Common::ListingScopeInfo;
use Google::Ads::GoogleAds::V20::Enums::ProductCustomAttributeIndexEnum
  qw(INDEX0);
use Google::Ads::GoogleAds::V20::Enums::ProductTypeLevelEnum qw(LEVEL1 LEVEL2);
use
  Google::Ads::GoogleAds::V20::Services::CampaignCriterionService::CampaignCriterionOperation;
use Google::Ads::GoogleAds::V20::Utils::ResourceNames;

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
my $campaign_id = "INSERT_CAMPAIGN_ID_HERE";

sub add_listing_scope {
  my ($api_client, $customer_id, $campaign_id) = @_;

  # Create a campaign criterion to store the listing scope.
  my $campaign_criterion =
    Google::Ads::GoogleAds::V20::Resources::CampaignCriterion->new({
      campaign => Google::Ads::GoogleAds::V20::Utils::ResourceNames::campaign(
        $customer_id, $campaign_id
      )});

  # A listing scope allows you to filter the products that will be included in
  # a given campaign. You can specify multiple dimensions with conditions that
  # must be met for a product to be included in a campaign.
  # A typical listing scope might only have a few dimensions. This example
  # demonstrates a range of different dimensions you could use.
  my $dimensions = [];

  # Create a ProductBrand dimension set to "google".
  push @$dimensions,
    Google::Ads::GoogleAds::V20::Common::ListingDimensionInfo->new({
      productBrand =>
        Google::Ads::GoogleAds::V20::Common::ProductBrandInfo->new({
          value => "google"
        })});

  # Create a ProductCustomAttribute dimension for INDEX0 set to "top_selling_products".
  push @$dimensions,
    Google::Ads::GoogleAds::V20::Common::ListingDimensionInfo->new({
      productCustomAttribute =>
        Google::Ads::GoogleAds::V20::Common::ProductCustomAttributeInfo->new({
          index => INDEX0,
          value => "top_selling_products"
        })});

  # Create a ProductType dimension for LEVEL1 set to "electronics".
  push @$dimensions,
    Google::Ads::GoogleAds::V20::Common::ListingDimensionInfo->new({
      productType => Google::Ads::GoogleAds::V20::Common::ProductTypeInfo->new({
          level => LEVEL1,
          value => "electronics"
        })});

  # Create a ProductType dimension for LEVEL2 set to "smartphones".
  push @$dimensions,
    Google::Ads::GoogleAds::V20::Common::ListingDimensionInfo->new({
      productType => Google::Ads::GoogleAds::V20::Common::ProductTypeInfo->new({
          level => LEVEL2,
          value => "smartphones"
        })});

  $campaign_criterion->{listingScope} =
    Google::Ads::GoogleAds::V20::Common::ListingScopeInfo->new({
      dimensions => $dimensions
    });

  # Create a campaign criterion operation.
  my $campaign_criterion_operation =
    Google::Ads::GoogleAds::V20::Services::CampaignCriterionService::CampaignCriterionOperation
    ->new({create => $campaign_criterion});

  # Add the campaign criterion containing the listing scope on the campaign.
  my $campaign_criteria_response =
    $api_client->CampaignCriterionService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_criterion_operation]});

  printf "Added a campaign criteria with resource name: '%s'.\n",
    $campaign_criteria_response->{results}[0]{resourceName};

  return 1;
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
GetOptions("customer_id=s" => \$customer_id, "campaign_id=i" => \$campaign_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $campaign_id);

# Call the example.
add_listing_scope($api_client, $customer_id =~ s/-//gr, $campaign_id);

=pod

=head1 NAME

add_listing_scope

=head1 DESCRIPTION

Adds a shopping listing scope to a shopping campaign. The example will construct
and add a new listing scope which will act as the inventory filter for the campaign.
The campaign will only advertise products that match the following requirements:

- Brand is "google"
- Custom label 0 is "top_selling_products"
- Product type (level 1) is "electronics"
- Product type (level 2) is "smartphones"

Only one listing scope is allowed per campaign. Remove any existing listing scopes
before running this example.

=head1 SYNOPSIS

add_listing_scope.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.

=cut
