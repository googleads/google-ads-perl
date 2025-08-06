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
# This example adds a price asset and associates it with an account.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Resources::Asset;
use Google::Ads::GoogleAds::V21::Resources::CustomerAsset;
use Google::Ads::GoogleAds::V21::Common::PriceAsset;
use Google::Ads::GoogleAds::V21::Common::PriceOffering;
use Google::Ads::GoogleAds::V21::Common::Money;
use Google::Ads::GoogleAds::V21::Enums::PriceExtensionTypeEnum qw(SERVICES);
use Google::Ads::GoogleAds::V21::Enums::PriceExtensionPriceQualifierEnum
  qw(FROM);
use Google::Ads::GoogleAds::V21::Enums::PriceExtensionPriceUnitEnum
  qw(PER_HOUR PER_MONTH);
use Google::Ads::GoogleAds::V21::Enums::AssetFieldTypeEnum qw(PRICE);
use Google::Ads::GoogleAds::V21::Services::AssetService::AssetOperation;
use
  Google::Ads::GoogleAds::V21::Services::CustomerAssetService::CustomerAssetOperation;

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
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub add_prices {
  my ($api_client, $customer_id) = @_;

  # Create a new price asset.
  my $price_asset_resource_name = create_price_asset($api_client, $customer_id);

  # Add the new price asset to the account, so it will serve all campaigns
  # under the account.
  add_asset_to_account($api_client, $customer_id, $price_asset_resource_name);

  return 1;
}

# Creates a price asset.
sub create_price_asset {
  my ($api_client, $customer_id) = @_;

  # Create the price asset.
  my $price_asset = Google::Ads::GoogleAds::V21::Common::PriceAsset->new({
      type => SERVICES,
      # Price qualifier is optional.
      priceQualifier => FROM,
      languageCode   => "en",
      priceOfferings => [
        create_price_offering(
          "Scrubs",
          "Body Scrub, Salt Scrub",
          "http://www.example.com/scrubs",
          "http://m.example.com/scrubs",
          60000000,    # 60 USD
          "USD",
          PER_HOUR
        ),
        create_price_offering(
          "Hair Cuts",
          "Once a month",
          "http://www.example.com/haircuts",
          "http://m.example.com/haircuts",
          75000000,    # 75 USD
          "USD",
          PER_MONTH
        ),
        create_price_offering(
          "Skin Care Package",
          "Four times a month",
          "http://www.example.com/skincarepackage",
          undef,
          250000000,    # 250 USD
          "USD",
          PER_MONTH
        )]});

  # Create an asset.
  my $asset = Google::Ads::GoogleAds::V21::Resources::Asset->new({
    name                => "Price Asset #" . uniqid(),
    trackingUrlTemplate => "http://tracker.example.com/?u={lpurl}",
    priceAsset          => $price_asset
  });

  # Create an asset operation.
  my $operation =
    Google::Ads::GoogleAds::V21::Services::AssetService::AssetOperation->new({
      create => $asset
    });

  # Issue a mutate request to add the price asset and print some information.
  my $response = $api_client->AssetService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});

  printf
    "Created price asset with resource name '%s'.\n",
    $response->{results}[0]{resourceName};

  return $response->{results}[0]{resourceName};
}

# Adds the price asset to the customer account, allowing it to serve all campaigns
# under the account.
sub add_asset_to_account {
  my ($api_client, $customer_id, $price_asset_resource_name) = @_;

  # Create a customer asset, set its type to PRICE and attach the price asset.
  my $customer_asset =
    Google::Ads::GoogleAds::V21::Resources::CustomerAsset->new({
      asset     => $price_asset_resource_name,
      fieldType => PRICE
    });

  # Create a customer asset operation.
  my $operation =
    Google::Ads::GoogleAds::V21::Services::CustomerAssetService::CustomerAssetOperation
    ->new({
      create => $customer_asset
    });

  # Issue a mutate request to add the customer asset and print some information.
  my $response = $api_client->CustomerAssetService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});

  printf "Created customer asset with resource name '%s'.\n",
    $response->{results}[0]{resourceName};
}

# Creates a new price offering with the specified attributes.
sub create_price_offering {
  my ($header, $description, $final_url, $final_mobile_url, $price_in_micros,
    $currency_code, $unit)
    = @_;

  my $price_offering = Google::Ads::GoogleAds::V21::Common::PriceOffering->new({
      header      => $header,
      description => $description,
      finalUrl    => $final_url,
      price       => Google::Ads::GoogleAds::V21::Common::Money->new({
          amountMicros => $price_in_micros,
          currencyCode => $currency_code
        }
      ),
      unit => $unit
    });

  # Optional: set the final mobile URL.
  $price_offering->{finalMobileUrl} = $final_mobile_url if $final_mobile_url;

  return $price_offering;
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
add_prices($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

add_prices

=head1 DESCRIPTION

This example adds a price asset and associates it with an account.

=head1 SYNOPSIS

add_prices.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
