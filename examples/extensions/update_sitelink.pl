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
# Updates the sitelink extension feed item with the specified link text.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V11::Resources::ExtensionFeedItem;
use Google::Ads::GoogleAds::V11::Common::SitelinkFeedItem;
use
  Google::Ads::GoogleAds::V11::Services::ExtensionFeedItemService::ExtensionFeedItemOperation;
use Google::Ads::GoogleAds::V11::Utils::ResourceNames;

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
my $customer_id   = "INSERT_CUSTOMER_ID_HERE";
my $feed_item_id  = "INSERT_FEED_ITEM_ID_HERE";
my $sitelink_text = "INSERT_SITELINK_TEXT_HERE";

# [START update_sitelink]
sub update_sitelink {
  my ($api_client, $customer_id, $feed_item_id, $sitelink_text) = @_;

  # Create an extension feed item using the specified feed item ID and sitelink text.
  my $extension_feed_item =
    Google::Ads::GoogleAds::V11::Resources::ExtensionFeedItem->new({
      resourceName =>
        Google::Ads::GoogleAds::V11::Utils::ResourceNames::extension_feed_item(
        $customer_id, $feed_item_id
        ),
      sitelinkFeedItem =>
        Google::Ads::GoogleAds::V11::Common::SitelinkFeedItem->new({
          linkText => $sitelink_text
        })});

  # Construct an operation that will update the extension feed item, using the
  # FieldMasks utility to derive the update mask. This mask tells the Google Ads
  # API which attributes of the extension feed item you want to change.
  my $extension_feed_item_operation =
    Google::Ads::GoogleAds::V11::Services::ExtensionFeedItemService::ExtensionFeedItemOperation
    ->new({
      update     => $extension_feed_item,
      updateMask => all_set_fields_of($extension_feed_item)});

  # Issue a mutate request to update the extension feed item.
  my $extension_feed_items_response =
    $api_client->ExtensionFeedItemService()->mutate({
      customerId => $customer_id,
      operations => [$extension_feed_item_operation]});

  # Print the resource name of the updated extension feed item.
  printf
    "Updated extension feed item with resource name: '%s'.\n",
    $extension_feed_items_response->{results}[0]{resourceName};

  return 1;
}
# [END update_sitelink]

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
  "feed_item_id=i"  => \$feed_item_id,
  "sitelink_text=s" => \$sitelink_text
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $feed_item_id, $sitelink_text);

# Call the example.
update_sitelink($api_client, $customer_id =~ s/-//gr,
  $feed_item_id, $sitelink_text);

=pod

=head1 NAME

update_sitelink

=head1 DESCRIPTION

Updates the sitelink extension feed item with the specified link text.

=head1 SYNOPSIS

update_sitelink.pl [options]

    -help                           Show the help message.
    -customer_id                    The Google Ads customer ID.
    -feed_item_id                   The feed item ID.
    -sitelink_text                  The new sitelink text to update to.

=cut
