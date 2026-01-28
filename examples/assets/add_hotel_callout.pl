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
# This example adds hotel callout assets to a specific account.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::Asset;
use Google::Ads::GoogleAds::V23::Resources::CustomerAsset;
use Google::Ads::GoogleAds::V23::Common::HotelCalloutAsset;
use Google::Ads::GoogleAds::V23::Enums::AssetFieldTypeEnum qw(HOTEL_CALLOUT);
use Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation;
use
  Google::Ads::GoogleAds::V23::Services::CustomerAssetService::CustomerAssetOperation;

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
# See supported languages at:
# https://developers.google.com/hotels/hotel-ads/api-reference/language-codes
my $language_code = "INSERT_LANGUAGE_CODE_HERE";

sub add_hotel_callout {
  my ($api_client, $customer_id, $language_code) = @_;

  # Create assets for the hotel callout assets.
  my $hotel_callout_asset_resource_names =
    add_hotel_callout_assets($api_client, $customer_id, $language_code);

  # Add the assets at the account level, so these will serve in all eligible campaigns.
  link_assets_to_account($api_client, $customer_id,
    $hotel_callout_asset_resource_names);

  return 1;
}

# Creates new assets for the callout.
sub add_hotel_callout_assets {
  my ($api_client, $customer_id, $language_code) = @_;

  my $hotel_callout_assets = [];
  # Create the callouts with text and specified language.
  push @$hotel_callout_assets,
    Google::Ads::GoogleAds::V23::Common::HotelCalloutAsset->new({
      text         => "Activities",
      languageCode => $language_code
    });
  push @$hotel_callout_assets,
    Google::Ads::GoogleAds::V23::Common::HotelCalloutAsset->new({
      text         => "Facilities",
      languageCode => $language_code
    });

  my $operations = [];
  # Wrap the HotelCalloutAsset in an Asset and create an AssetOperation to add the Asset.
  foreach my $hotel_callout_asset (@$hotel_callout_assets) {
    push @$operations,
      Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation->new({
        create => Google::Ads::GoogleAds::V23::Resources::Asset->new({
            hotelCalloutAsset => $hotel_callout_asset
          })});
  }

  # Issue the create request to create the assets.
  my $response = $api_client->AssetService()->mutate({
    customerId => $customer_id,
    operations => $operations
  });

  # Print some information about the result.
  my $resource_names = [];
  foreach my $result (@{$response->{results}}) {
    push @$resource_names, $result->{resourceName};
    printf "Created hotel callout asset with resource name '%s'.\n",
      $result->{resourceName};
  }

  return $resource_names;
}

# Links the assets at the Customer level to serve in all eligible campaigns.
sub link_assets_to_account {
  my ($api_client, $customer_id, $hotel_callout_asset_resource_names) = @_;

  # Create a CustomerAsset link for each Asset resource name provided, then
  # convert this into a CustomerAssetOperation to create the Asset.
  my $operations = [];
  foreach
    my $hotel_callout_asset_resource_name (@$hotel_callout_asset_resource_names)
  {
    push @$operations,
      Google::Ads::GoogleAds::V23::Services::CustomerAssetService::CustomerAssetOperation
      ->new({
        create => Google::Ads::GoogleAds::V23::Resources::CustomerAsset->new({
            asset     => $hotel_callout_asset_resource_name,
            fieldType => HOTEL_CALLOUT
          })});
  }

  # Send the mutate request.
  my $response = $api_client->CustomerAssetService()->mutate({
    customerId => $customer_id,
    operations => $operations
  });

  # Print some information about the result.
  foreach my $result (@{$response->{results}}) {
    printf "Added a account asset with resource name '%s'.\n",
      $result->{resourceName};
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
  "customer_id=s"   => \$customer_id,
  "language_code=s" => \$language_code
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $language_code);

# Call the example.
add_hotel_callout($api_client, $customer_id =~ s/-//gr, $language_code);

=pod

=head1 NAME

add_hotel_callout

=head1 DESCRIPTION

This example adds hotel callout assets to a specific account.

=head1 SYNOPSIS

add_hotel_callout.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -language_code              The hotel callout language code, e.g. specify 'en' for English.

=cut
