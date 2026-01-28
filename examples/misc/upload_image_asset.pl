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
# This example uploads an image asset. To get image assets, run get_all_image_assets.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::MediaUtils;
use Google::Ads::GoogleAds::V23::Resources::Asset;
use Google::Ads::GoogleAds::V23::Common::ImageAsset;
use Google::Ads::GoogleAds::V23::Enums::AssetTypeEnum qw(IMAGE);
use Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);

use constant IMAGE_URL => "https://gaagl.page.link/Eit5";

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

# [START upload_image_asset]
sub upload_image_asset {
  my ($api_client, $customer_id) = @_;

  # Create an image content.
  my $image_content = get_base64_data_from_url(IMAGE_URL);

  # Create an asset.
  my $asset = Google::Ads::GoogleAds::V23::Resources::Asset->new({
      # Provide a unique friendly name to identify your asset.
      # When there is an existing image asset with the same content but a different
      # name, the new name will be dropped silently.
      name       => "Marketing Image",
      type       => IMAGE,
      imageAsset => Google::Ads::GoogleAds::V23::Common::ImageAsset->new({
          data => $image_content
        })});

  # Create an asset operation.
  my $asset_operation =
    Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation->new({
      create => $asset
    });

  # Issue a mutate request to add the asset.
  my $assets_response = $api_client->AssetService()->mutate({
      customerId => $customer_id,
      operations => [$asset_operation]});

  printf "The image asset with resource name '%s' was created.\n",
    $assets_response->{results}[0]{resourceName};

  return 1;
}
# [END upload_image_asset]

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
upload_image_asset($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

upload_image_asset

=head1 DESCRIPTION

This example uploads an image asset. To get image assets, run get_all_image_assets.pl.

=head1 SYNOPSIS

upload_image_asset.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
