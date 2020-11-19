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
# This example adds sitelinks to a campaign. To create a campaign, run add_campaigns.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V6::Resources::CampaignExtensionSetting;
use Google::Ads::GoogleAds::V6::Resources::ExtensionFeedItem;
use Google::Ads::GoogleAds::V6::Common::KeywordInfo;
use Google::Ads::GoogleAds::V6::Common::SitelinkFeedItem;
use Google::Ads::GoogleAds::V6::Common::AdScheduleInfo;
use Google::Ads::GoogleAds::V6::Enums::ExtensionTypeEnum qw(SITELINK);
use Google::Ads::GoogleAds::V6::Enums::FeedItemTargetDeviceEnum qw(MOBILE);
use Google::Ads::GoogleAds::V6::Enums::KeywordMatchTypeEnum qw(BROAD);
use Google::Ads::GoogleAds::V6::Enums::DayOfWeekEnum
  qw(MONDAY TUESDAY WEDNESDAY THURSDAY FRIDAY);
use Google::Ads::GoogleAds::V6::Enums::MinuteOfHourEnum qw(ZERO);
use
  Google::Ads::GoogleAds::V6::Services::CampaignExtensionSettingService::CampaignExtensionSettingOperation;
use
  Google::Ads::GoogleAds::V6::Services::ExtensionFeedItemService::ExtensionFeedItemOperation;
use Google::Ads::GoogleAds::V6::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
use POSIX qw(strftime mktime);

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

sub add_sitelinks {
  my ($api_client, $customer_id, $campaign_id) = @_;

  my $campaign_resource_name =
    Google::Ads::GoogleAds::V6::Utils::ResourceNames::campaign($customer_id,
    $campaign_id);

  # Create extension feed items as sitelinks.
  my $extension_feed_items =
    create_extension_feed_items($api_client, $customer_id,
    $campaign_resource_name);

  # Create a campaign extension setting.
  my $campaign_extension_setting =
    Google::Ads::GoogleAds::V6::Resources::CampaignExtensionSetting->new({
      campaign           => $campaign_resource_name,
      extensionType      => SITELINK,
      extensionFeedItems => $extension_feed_items
    });

  # Create a campaign extension setting operation.
  my $campaign_extension_setting_operation =
    Google::Ads::GoogleAds::V6::Services::CampaignExtensionSettingService::CampaignExtensionSettingOperation
    ->new({
      create => $campaign_extension_setting
    });

  # Add the campaign extension setting.
  my $campaign_extension_settings_response =
    $api_client->CampaignExtensionSettingService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_extension_setting_operation]});

  printf "Created campaign extension setting with resource name '%s'.\n",
    $campaign_extension_settings_response->{results}[0]{resourceName};

  return 1;
}

# Creates a list of extension feed items.
sub create_extension_feed_items {
  my ($api_client, $customer_id, $campaign_resource_name) = @_;

  my $operations = [];

  my $sitelink_feed_item_1 = create_sitelink_feed_item("Store Hours",
    "http://www.example.com/storehours");

  # Create an extension feed item from the sitelink feed item.
  my $extension_feed_item_1 =
    Google::Ads::GoogleAds::V6::Resources::ExtensionFeedItem->new({
      extensionType    => SITELINK,
      sitelinkFeedItem => $sitelink_feed_item_1,
      targetedCampaign => $campaign_resource_name
    });

  # Create an extension feed item operation and add it to the operations list.
  push @$operations,
    Google::Ads::GoogleAds::V6::Services::ExtensionFeedItemService::ExtensionFeedItemOperation
    ->new({
      create => $extension_feed_item_1
    });

  my $sitelink_feed_item_2 = create_sitelink_feed_item("Thanksgiving Specials",
    "http://www.example.com/thanksgiving");

  # Set the start_time and end_time to show the Thanksgiving specials link only
  # from 20 - 27 Nov.
  my ($sec, $min, $hour, $mday, $mon, $year) = localtime(time);
  my $start_time = mktime(0, 0, 0, 20, 10, $year);
  if ($start_time < time) {
    # Move the start_time to next year if the current date is past November 20th.
    $year += 1;
    $start_time = mktime(0, 0, 0, 20, 10, $year);
  }
  # Convert to a string in the required format.
  my $start_time_string = strftime("%Y-%m-%d %H:%M:%S", localtime($start_time));

  # Use the same year as start_time when creating end_time.
  my $end_time        = mktime(59, 59, 23, 27, 10, $year);
  my $end_time_string = strftime("%Y-%m-%d %H:%M:%S", localtime($end_time));

  # Target this sitelink for United States only.
  # A list of country codes can be referenced here:
  # https://developers.google.com/adwords/api/docs/appendix/geotargeting
  my $united_states =
    Google::Ads::GoogleAds::V6::Utils::ResourceNames::geo_target_constant(2840);

  my $extension_feed_item_2 =
    Google::Ads::GoogleAds::V6::Resources::ExtensionFeedItem->new({
      extensionType             => SITELINK,
      sitelinkFeedItem          => $sitelink_feed_item_2,
      targetedCampaign          => $campaign_resource_name,
      startDateTime             => $start_time_string,
      endDateTime               => $end_time_string,
      targetedGeoTargetConstant => $united_states
    });

  push @$operations,
    Google::Ads::GoogleAds::V6::Services::ExtensionFeedItemService::ExtensionFeedItemOperation
    ->new({
      create => $extension_feed_item_2
    });

  my $sitelink_feed_item_3 = create_sitelink_feed_item("Wifi available",
    "http://www.example.com/mobile/wifi");

  # Set the targeted device to show the wifi details primarily for high end
  # mobile users.
  # Target this sitelink for the keyword "free wifi".
  my $extension_feed_item_3 =
    Google::Ads::GoogleAds::V6::Resources::ExtensionFeedItem->new({
      extensionType    => SITELINK,
      sitelinkFeedItem => $sitelink_feed_item_3,
      targetedCampaign => $campaign_resource_name,
      device           => MOBILE,
      targetedKeyword  => Google::Ads::GoogleAds::V6::Common::KeywordInfo->new({
          text      => "free wifi",
          matchType => BROAD
        })});

  push @$operations,
    Google::Ads::GoogleAds::V6::Services::ExtensionFeedItemService::ExtensionFeedItemOperation
    ->new({
      create => $extension_feed_item_3
    });

  my $sitelink_feed_item_4 = create_sitelink_feed_item("Happy hours",
    "http://www.example.com/happyhours");

  # Set the feed item schedules to show the happy hours link only during Mon - Fri
  # 6PM to 9PM.
  my $extension_feed_item_4 =
    Google::Ads::GoogleAds::V6::Resources::ExtensionFeedItem->new({
      extensionType    => SITELINK,
      sitelinkFeedItem => $sitelink_feed_item_4,
      targetedCampaign => $campaign_resource_name,
      adSchedules      => [
        create_ad_schedule_info(MONDAY,    18, ZERO, 21, ZERO),
        create_ad_schedule_info(TUESDAY,   18, ZERO, 21, ZERO),
        create_ad_schedule_info(WEDNESDAY, 18, ZERO, 21, ZERO),
        create_ad_schedule_info(THURSDAY,  18, ZERO, 21, ZERO),
        create_ad_schedule_info(FRIDAY,    18, ZERO, 21, ZERO)]});

  push @$operations,
    Google::Ads::GoogleAds::V6::Services::ExtensionFeedItemService::ExtensionFeedItemOperation
    ->new({
      create => $extension_feed_item_4
    });

  # Add the extension feed item.
  my $extension_feed_items_response =
    $api_client->ExtensionFeedItemService()->mutate({
      customerId => $customer_id,
      operations => $operations
    });

  my $extension_feed_item_results = $extension_feed_items_response->{results};
  printf "Added %d extension feed items:\n",
    scalar @$extension_feed_item_results;

  my $resource_names = [];
  foreach my $extension_feed_item_result (@$extension_feed_item_results) {
    printf "\tCreated extension feed item with resource name '%s'.\n",
      $extension_feed_item_result->{resourceName};
    push @$resource_names, $extension_feed_item_result->{resourceName};
  }

  return $resource_names;
}

# Creates a new sitelink feed item with the specified attributes.
sub create_sitelink_feed_item {
  my ($sitelink_text, $sitelink_url) = @_;

  return Google::Ads::GoogleAds::V6::Common::SitelinkFeedItem->new({
    linkText  => $sitelink_text,
    finalUrls => $sitelink_url
  });
}

# Creates a new ad schedule info with the specified attributes.
sub create_ad_schedule_info {
  my ($day, $start_hour, $start_minute, $end_hour, $end_minute) = @_;

  return Google::Ads::GoogleAds::V6::Common::AdScheduleInfo->new({
    dayOfWeek   => $day,
    startHour   => $start_hour,
    startMinute => $start_minute,
    endHour     => $end_hour,
    endMinute   => $end_minute
  });
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
add_sitelinks($api_client, $customer_id =~ s/-//gr, $campaign_id);

=pod

=head1 NAME

add_sitelinks

=head1 DESCRIPTION

This example adds sitelinks to a campaign. To create a campaign, run add_campaigns.pl.

=head1 SYNOPSIS

add_sitelinks.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.

=cut
