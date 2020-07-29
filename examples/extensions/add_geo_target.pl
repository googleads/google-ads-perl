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
# Adds a geo target to a extension feed item for targeting.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V4::Resources::ExtensionFeedItem;
use
  Google::Ads::GoogleAds::V4::Services::ExtensionFeedItemService::ExtensionFeedItemOperation;
use Google::Ads::GoogleAds::V4::Utils::ResourceNames;

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
my $customer_id  = "INSERT_CUSTOMER_ID_HERE";
my $feed_item_id = "INSERT_FEED_ITEM_ID_HERE";
# A list of country codes can be referenced here:
# https://developers.google.com/adwords/api/docs/appendix/geotargeting
my $geo_target_constant_id = 2840;    # US

sub add_geo_target {
  my ($api_client, $customer_id, $feed_item_id, $geo_target_constant_id) = @_;

  # Create an extension feed item using the specified feed item ID and geo target
  # constant ID for targeting.
  my $extension_feed_item =
    Google::Ads::GoogleAds::V4::Resources::ExtensionFeedItem->new({
      resourceName =>
        Google::Ads::GoogleAds::V4::Utils::ResourceNames::extension_feed_item(
        $customer_id, $feed_item_id
        ),
      targetedGeoTargetConstant =>
        Google::Ads::GoogleAds::V4::Utils::ResourceNames::geo_target_constant(
        $geo_target_constant_id)});

  # Construct an operation that will update the extension feed item, using the
  # FieldMasks utility to derive the update mask. This mask tells the Google Ads
  # API which attributes of the extension feed item you want to change.
  my $extension_feed_item_operation =
    Google::Ads::GoogleAds::V4::Services::ExtensionFeedItemService::ExtensionFeedItemOperation
    ->new({
      update     => $extension_feed_item,
      updateMask => all_set_fields_of($extension_feed_item)});

  # Issue a mutate request to update the extension feed item.
  my $extension_feed_item_response =
    $api_client->ExtensionFeedItemService()->mutate({
      customerId => $customer_id,
      operations => [$extension_feed_item_operation]});

  # Print the resource name of the updated extension feed item.
  my $updated_extension_feed_item = $extension_feed_item_response->{results}[0];
  printf("Updated extension feed item with resource name: '%s'.\n",
    $updated_extension_feed_item->{resourceName});

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
GetOptions(
  "customer_id=s"            => \$customer_id,
  "feed_item_id=i"           => \$feed_item_id,
  "geo_target_constant_id=i" => \$geo_target_constant_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $feed_item_id);

# Call the example.
add_sitelinks(
  $api_client,   $customer_id =~ s/-//gr,
  $feed_item_id, $geo_target_constant_id
);

=pod

=head1 NAME

add_geo_target

=head1 DESCRIPTION

Adds a geo target to a extension feed item for targeting.

=head1 SYNOPSIS

add_geo_target.pl [options]

    -help                           Show the help message.
    -customer_id                    The Google Ads customer ID.
    -feed_item_id                   The feed item ID.
    -geo_target_constant_id         [optional] The geo target constant ID to add
                                    to the extension feed item

=cut
