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
# Updates the sitelink campaign extension setting to replace its extension feed
# items. Note that this doesn't completely remove your old extension feed items.
# See https://developers.google.com/google-ads/api/docs/extensions/extension-settings/overview
# for details.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V4::Resources::CampaignExtensionSetting;
use Google::Ads::GoogleAds::V4::Enums::ExtensionTypeEnum qw(SITELINK);
use
  Google::Ads::GoogleAds::V4::Services::CampaignExtensionSettingService::CampaignExtensionSettingOperation;
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
my $customer_id   = "INSERT_CUSTOMER_ID_HERE";
my $campaign_id   = "INSERT_CAMPAIGN_ID_HERE";
my $feed_item_id1 = "INSERT_FEED_ITEM_ID1_HERE";
my $feed_item_id2 = "INSERT_FEED_ITEM_ID2_HERE";
my $feed_item_ids = [];

sub update_sitelink_campaign_extension_setting {
  my ($api_client, $customer_id, $campaign_id, $feed_item_ids) = @_;

  # Transform the specified extension feed item IDs to the array of resource names.
  my $extension_feed_items = [
    map {
      Google::Ads::GoogleAds::V4::Utils::ResourceNames::extension_feed_item(
        $customer_id, $_)
    } @$feed_item_ids
  ];

  # Create a campaign extension setting using the specified campaign ID and
  # extension feed item resource names.
  my $campaign_extension_setting =
    Google::Ads::GoogleAds::V4::Resources::CampaignExtensionSetting->new({
      resourceName =>
        Google::Ads::GoogleAds::V4::Utils::ResourceNames::campaign_extension_setting(
        $customer_id, $campaign_id, SITELINK
        ),
      extensionFeedItems => $extension_feed_items
    });

  # Construct an operation that will update the campaign extension setting, using
  # the FieldMasks utility to derive the update mask. This mask tells the Google
  # Ads API which attributes of the campaign extension setting you want to change.
  my $campaign_extension_setting_operation =
    Google::Ads::GoogleAds::V4::Services::CampaignExtensionSettingService::CampaignExtensionSettingOperation
    ->new({
      update     => $campaign_extension_setting,
      updateMask => all_set_fields_of($campaign_extension_setting)});

  # Issue a mutate request to update the campaign extension setting.
  my $campaign_extension_setting_response =
    $api_client->CampaignExtensionSettingService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_extension_setting_operation]});

  # Print the resource name of the updated campaign extension setting.
  printf
    "Updated a campaign extension setting with resource name: '%s'.\n",
    $campaign_extension_setting_response->{results}[0]{resourceName};

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
  "customer_id=s"   => \$customer_id,
  "campaign_id=i"   => \$campaign_id,
  "feed_item_ids=s" => \@$feed_item_ids,
);
$feed_item_ids = [$feed_item_id1, $feed_item_id2] unless @$feed_item_ids;

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $campaign_id, $feed_item_ids);

# Call the example.
update_sitelink_campaign_extension_setting($api_client, $customer_id =~ s/-//gr,
  $campaign_id, $feed_item_ids);

=pod

=head1 NAME

update_sitelink_campaign_extension_setting

=head1 DESCRIPTION

Updates the sitelink campaign extension setting to replace its extension feed
items. Note that this doesn't completely remove your old extension feed items.
See https://developers.google.com/google-ads/api/docs/extensions/extension-settings/overview
for details.

=head1 SYNOPSIS

update_sitelink_campaign_extension_setting.pl [options]

    -help                           Show the help message.
    -customer_id                    The Google Ads customer ID.
    -campaign_id                    The campaign ID.
    -feed_item_ids                  The extension feed item IDs to replace.
 
=cut
