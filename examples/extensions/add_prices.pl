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
# This example adds a price extension and associates it with an account. Campaign
# targeting is also set using the specified campaign ID. To get campaigns, run
# get_campaigns.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::GoogleAdsClient;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V2::Resources::CustomerExtensionSetting;
use Google::Ads::GoogleAds::V2::Resources::ExtensionFeedItem;
use Google::Ads::GoogleAds::V2::Common::PriceFeedItem;
use Google::Ads::GoogleAds::V2::Common::PriceOffer;
use Google::Ads::GoogleAds::V2::Common::Money;
use Google::Ads::GoogleAds::V2::Common::AdScheduleInfo;
use Google::Ads::GoogleAds::V2::Enums::ExtensionTypeEnum qw(PRICE);
use Google::Ads::GoogleAds::V2::Enums::PriceExtensionTypeEnum qw(SERVICES);
use Google::Ads::GoogleAds::V2::Enums::PriceExtensionPriceQualifierEnum
  qw(FROM);
use Google::Ads::GoogleAds::V2::Enums::PriceExtensionPriceUnitEnum
  qw(PER_HOUR PER_MONTH);
use Google::Ads::GoogleAds::V2::Enums::DayOfWeekEnum qw(SATURDAY SUNDAY);
use Google::Ads::GoogleAds::V2::Enums::MinuteOfHourEnum qw(ZERO);
use
  Google::Ads::GoogleAds::V2::Services::CustomerExtensionSettingService::CustomerExtensionSettingOperation;
use
  Google::Ads::GoogleAds::V2::Services::ExtensionFeedItemService::ExtensionFeedItemOperation;
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
my $customer_id = "INSERT_CUSTOMER_ID_HERE";
my $campaign_id = "INSERT_CAMPAIGN_ID_HERE";

sub add_prices {
  my ($api_client, $customer_id, $campaign_id) = @_;

  # Create an extension feed item as price.
  my $extension_feed_item =
    create_extension_feed_item($api_client, $customer_id, $campaign_id);

  # Create a customer extension setting using the previously created extension
  # feed item. This associates the price extension to your account.
  my $customer_extension_setting =
    Google::Ads::GoogleAds::V2::Resources::CustomerExtensionSetting->new({
      extensionType      => PRICE,
      extensionFeedItems => [$extension_feed_item]});

  # Create a customer extension setting operation.
  my $customer_extension_setting_operation =
    Google::Ads::GoogleAds::V2::Services::CustomerExtensionSettingService::CustomerExtensionSettingOperation
    ->new({
      create => $customer_extension_setting
    });

  # Add the customer extension setting.
  my $customer_extension_setting_response =
    $api_client->CustomerExtensionSettingService()->mutate({
      customerId => $customer_id,
      operations => [$customer_extension_setting_operation]});

  printf "Created customer extension setting with resource name '%s'.\n",
    $customer_extension_setting_response->{results}[0]{resourceName};

  return 1;
}

# Creates an extension feed item.
sub create_extension_feed_item {
  my ($api_client, $customer_id, $campaign_id) = @_;

  # Create the price extension feed item.
  my $price_feed_item = Google::Ads::GoogleAds::V2::Common::PriceFeedItem->new({
    type => SERVICES,
    # Price qualifier is optional.
    priceQualifier      => FROM,
    trackingUrlTemplate => "http://tracker.example.com/?u={lpurl}",
    languageCode        => "en"
  });

  # To create a price extension, at least three price offerings are needed.
  $price_feed_item->{priceOfferings} = [
    create_price_offer(
      "Scrubs",
      "Body Scrub, Salt Scrub",
      "http://www.example.com/scrubs",
      "http://m.example.com/scrubs",
      60000000,    # 60 USD
      "USD",
      PER_HOUR
    ),
    create_price_offer(
      "Hair Cuts",
      "Once a month",
      "http://www.example.com/haircuts",
      "http://m.example.com/haircuts",
      75000000,    # 75 USD
      "USD",
      PER_MONTH
    ),
    create_price_offer(
      "Skin Care Package",
      "Four times a month",
      "http://www.example.com/skincarepackage",
      undef,
      250000000,    # 250 USD
      "USD",
      PER_MONTH
    )];

  # Create an extension feed item from the price feed item.
  my $extension_feed_item =
    Google::Ads::GoogleAds::V2::Resources::ExtensionFeedItem->new({
      extensionType => PRICE,
      priceFeedItem => $price_feed_item,
      targetedCampaign =>
        Google::Ads::GoogleAds::V2::Utils::ResourceNames::campaign(
        $customer_id, $campaign_id
        ),
      adSchedules => [
        create_ad_schedule_info(SUNDAY,   10, ZERO, 18, ZERO),
        create_ad_schedule_info(SATURDAY, 10, ZERO, 22, ZERO),
      ]});

  # Create an extension feed item operation.
  my $extension_feed_item_operation =
    Google::Ads::GoogleAds::V2::Services::ExtensionFeedItemService::ExtensionFeedItemOperation
    ->new({
      create => $extension_feed_item
    });

  # Add the extension feed item.
  my $extension_feed_item_response =
    $api_client->ExtensionFeedItemService()->mutate({
      customerId => $customer_id,
      operations => [$extension_feed_item_operation]});

  my $extension_feed_item_resource_name =
    $extension_feed_item_response->{results}[0]{resourceName};
  printf "Created extension feed item with resource name '%s'.\n",
    $extension_feed_item_resource_name;

  return $extension_feed_item_resource_name;
}

# Creates a new price offer with the specified attributes.
sub create_price_offer {
  my ($header, $description, $final_url, $final_mobile_url, $price_in_micros,
    $currency_code, $unit)
    = @_;

  my $price_offer = Google::Ads::GoogleAds::V2::Common::PriceOffer->new({
      header      => $header,
      description => $description,
      finalUrls   => [$final_url],
      price       => Google::Ads::GoogleAds::V2::Common::Money->new({
          amountMicros => $price_in_micros,
          currencyCode => $currency_code
        }
      ),
      unit => $unit
    });

  # Optional: set the final mobile URLs.
  $price_offer->{finalMobileUrls} = [$final_mobile_url] if $final_mobile_url;

  return $price_offer;
}

# Creates a new ad schedule info with the specified attributes.
sub create_ad_schedule_info {
  my ($day, $start_hour, $start_minute, $end_hour, $end_minute) = @_;

  return Google::Ads::GoogleAds::V2::Common::AdScheduleInfo->new({
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
my $api_client =
  Google::Ads::GoogleAds::GoogleAdsClient->new({version => "V2"});

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions("customer_id=s" => \$customer_id, "campaign_id=i" => \$campaign_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $campaign_id);

# Call the example.
add_prices($api_client, $customer_id =~ s/-//gr, $campaign_id);

=pod

=head1 NAME

add_prices

=head1 DESCRIPTION

This example adds a price extension and associates it with an account. Campaign
targeting is also set using the specified campaign ID. To get campaigns, run
get_campaigns.pl.

=head1 SYNOPSIS

add_prices.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.

=cut
