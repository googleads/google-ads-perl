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
# Adds a hotel callout extension to a specific account, campaign within the account,
# and ad group within the campaign.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::GoogleAdsClient;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V2::Resources::ExtensionFeedItem;
use Google::Ads::GoogleAds::V2::Resources::CampaignExtensionSetting;
use Google::Ads::GoogleAds::V2::Resources::AdGroupExtensionSetting;
use Google::Ads::GoogleAds::V2::Resources::CustomerExtensionSetting;
use Google::Ads::GoogleAds::V2::Common::HotelCalloutFeedItem;
use Google::Ads::GoogleAds::V2::Enums::ExtensionTypeEnum qw(HOTEL_CALLOUT);
use
  Google::Ads::GoogleAds::V2::Services::ExtensionFeedItemService::ExtensionFeedItemOperation;
use
  Google::Ads::GoogleAds::V2::Services::CampaignExtensionSettingService::CampaignExtensionSettingOperation;
use
  Google::Ads::GoogleAds::V2::Services::AdGroupExtensionSettingService::AdGroupExtensionSettingOperation;
use
  Google::Ads::GoogleAds::V2::Services::CustomerExtensionSettingService::CustomerExtensionSettingOperation;
use Google::Ads::GoogleAds::V2::Utils::ResourceNames;

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
my $campaign_id  = "INSERT_CAMPAIGN_ID_HERE";
my $ad_group_id  = "INSERT_AD_GROUP_ID_HERE";
my $callout_text = "INSERT_CALLOUT_TEXT_HERE";
# See supported languages at:
# https://developers.google.com/hotels/hotel-ads/api-reference/language-codes.
my $language_code = "INSERT_LANGUAGE_CODE_HERE";

sub add_hotel_callout_extension {
  my (
    $api_client,  $customer_id,  $campaign_id,
    $ad_group_id, $callout_text, $language_code
  ) = @_;

  # Create the extension feed item.
  my $extension_feed_item_resource_name =
    add_extension_feed_item($api_client, $customer_id, $callout_text,
    $language_code);

  # Add the extension feed item to the campaign.
  add_extension_to_campaign($api_client, $customer_id, $campaign_id,
    $extension_feed_item_resource_name);

  # Add the extension feed item to the ad group.
  add_extension_to_ad_group($api_client, $customer_id, $ad_group_id,
    $extension_feed_item_resource_name);

  # Add the extension feed item to the account.
  add_extension_to_account($api_client, $customer_id,
    $extension_feed_item_resource_name);

  return 1;
}

# Creates a new extension feed item for the callout.
sub add_extension_feed_item {
  my ($api_client, $customer_id, $callout_text, $language_code) = @_;

  # Create the callout feed item with text and language of choice.
  my $hotel_callout_feed_item =
    Google::Ads::GoogleAds::V2::Common::HotelCalloutFeedItem->new({
      text         => $callout_text,
      languageCode => $language_code
    });

  # Attache the callout feed item to an extension feed item.
  my $extension_feed_item =
    Google::Ads::GoogleAds::V2::Resources::ExtensionFeedItem->new({
      hotelCalloutFeedItem => $hotel_callout_feed_item
    });

  # Create an extension feed item operation.
  my $extension_feed_item_operation =
    Google::Ads::GoogleAds::V2::Services::ExtensionFeedItemService::ExtensionFeedItemOperation
    ->new({
      create => $extension_feed_item
    });

  # Issue a mutate request to add the extension feed item.
  my $extension_feed_item_response =
    $api_client->ExtensionFeedItemService()->mutate({
      customerId => $customer_id,
      operations => [$extension_feed_item_operation]});

  # Print out some information about the added extension feed item.
  my $extension_feed_item_resource_name =
    $extension_feed_item_response->{results}[0]{resourceName};
  printf "Added an extension feed item with resource name: '%s'.\n",
    $extension_feed_item_resource_name;

  return $extension_feed_item_resource_name;
}

# Adds the extension feed item to the campaign.
sub add_extension_to_campaign {
  my ($api_client, $customer_id, $campaign_id,
    $extension_feed_item_resource_name)
    = @_;

  # Create the campaign extension setting, set it to HOTEL_CALLOUT, and attache
  # the feed item.
  my $campaign_extension_setting =
    Google::Ads::GoogleAds::V2::Resources::CampaignExtensionSetting->new({
      extensionType => HOTEL_CALLOUT,
      campaign => Google::Ads::GoogleAds::V2::Utils::ResourceNames::campaign(
        $customer_id, $campaign_id
      ),
      extensionFeedItems => [$extension_feed_item_resource_name]});

  # Create a campaign extension setting operation.
  my $campaign_extension_setting_operation =
    Google::Ads::GoogleAds::V2::Services::CampaignExtensionSettingService::CampaignExtensionSettingOperation
    ->new({
      create => $campaign_extension_setting
    });

  # Issue a mutate request to add the campaign extension setting.
  my $campaign_extension_setting_response =
    $api_client->CampaignExtensionSettingService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_extension_setting_operation]});

  # Print out some information about the added campaign extension setting.
  my $campaign_extension_setting_resource_name =
    $campaign_extension_setting_response->{results}[0]{resourceName};
  printf "Added a campaign extension setting with resource name: '%s'.\n",
    $campaign_extension_setting_resource_name;

  return $campaign_extension_setting_resource_name;
}

# Adds the extension feed item to the ad group.
sub add_extension_to_ad_group {
  my ($api_client, $customer_id, $ad_group_id,
    $extension_feed_item_resource_name)
    = @_;

  # Create the ad group extension setting, set it to HOTEL_CALLOUT, and attache
  # the feed item.
  my $ad_group_extension_setting =
    Google::Ads::GoogleAds::V2::Resources::AdGroupExtensionSetting->new({
      extensionType => HOTEL_CALLOUT,
      adGroup => Google::Ads::GoogleAds::V2::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      ),
      extensionFeedItems => [$extension_feed_item_resource_name]});

  # Create an ad group extension setting operation.
  my $ad_group_extension_setting_operation =
    Google::Ads::GoogleAds::V2::Services::AdGroupExtensionSettingService::AdGroupExtensionSettingOperation
    ->new({
      create => $ad_group_extension_setting
    });

  # Issue a mutate request to add the ad group extension setting.
  my $ad_group_extension_setting_response =
    $api_client->AdGroupExtensionSettingService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_extension_setting_operation]});

  # Print out some information about the added ad group extension setting.
  my $ad_group_extension_setting_resource_name =
    $ad_group_extension_setting_response->{results}[0]{resourceName};
  printf "Added an ad group extension setting with resource name: '%s'.\n",
    $ad_group_extension_setting_resource_name;

  return $ad_group_extension_setting_resource_name;
}

# Adds the extension feed item to the account.
sub add_extension_to_account {
  my ($api_client, $customer_id, $extension_feed_item_resource_name) = @_;

  # Create the customer extension setting, set it to HOTEL_CALLOUT, and attache
  # the feed item.
  my $customer_extension_setting =
    Google::Ads::GoogleAds::V2::Resources::CustomerExtensionSetting->new({
      extensionType      => HOTEL_CALLOUT,
      extensionFeedItems => [$extension_feed_item_resource_name]});

  # Create a customer extension setting operation.
  my $customer_extension_setting_operation =
    Google::Ads::GoogleAds::V2::Services::CustomerExtensionSettingService::CustomerExtensionSettingOperation
    ->new({
      create => $customer_extension_setting
    });

  # Issue a mutate request to add the customer extension setting.
  my $customer_extension_setting_response =
    $api_client->CustomerExtensionSettingService()->mutate({
      customerId => $customer_id,
      operations => [$customer_extension_setting_operation]});

  # Print out some information about the added customer extension setting.
  my $customer_extension_setting_resource_name =
    $customer_extension_setting_response->{results}[0]{resourceName};
  printf "Added an account extension setting with resource name: '%s'.\n",
    $customer_extension_setting_resource_name;

  return $customer_extension_setting_resource_name;
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client =
  Google::Ads::GoogleAds::GoogleAdsClient->new({version => "V2"});

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s"   => \$customer_id,
  "campaign_id=i"   => \$campaign_id,
  "ad_group_id=i"   => \$ad_group_id,
  "callout_text=s"  => \$callout_text,
  "language_code=s" => \$language_code
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $campaign_id, $ad_group_id, $callout_text,
  $language_code);

# Call the example.
add_hotel_callout_extension($api_client, $customer_id =~ s/-//gr,
  $campaign_id, $ad_group_id, $callout_text, $language_code);

=pod

=head1 NAME

add_hotel_callout_extension

=head1 DESCRIPTION

Adds a hotel callout extension to a specific account, campaign within the account,
and ad group within the campaign.

=head1 SYNOPSIS

add_hotel_callout_extension.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.
    -ad_group_id                The ad group ID.
    -callout_text               The hotel callout text.
    -language_code              The hotel callout language code, e.g. specify 'en' for English.

=cut
