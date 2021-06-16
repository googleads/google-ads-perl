#!/usr/bin/perl -w
#
# Copyright 2021, Google LLC
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
# This code example retrieves the full details of a Promotion Feed-based
# extension and creates a matching Promotion asset-based extension. The new
# Asset-based extension will then be associated with the same campaigns and ad
# groups as the original Feed-based extension.
#
# Once copied, you should remove the Feed-based extension; see
# remove_entire_sitelink_campaign_extension_setting.pl for an example.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use Google::Ads::GoogleAds::V8::Resources::AdGroupAsset;
use Google::Ads::GoogleAds::V8::Resources::Asset;
use Google::Ads::GoogleAds::V8::Resources::CampaignAsset;
use Google::Ads::GoogleAds::V8::Common::Money;
use Google::Ads::GoogleAds::V8::Common::PromotionAsset;
use Google::Ads::GoogleAds::V8::Enums::ExtensionTypeEnum qw(PROMOTION);
use
  Google::Ads::GoogleAds::V8::Services::AdGroupAssetService::AdGroupAssetOperation;
use Google::Ads::GoogleAds::V8::Services::AssetService::AssetOperation;
use
  Google::Ads::GoogleAds::V8::Services::CampaignAssetService::CampaignAssetOperation;
use
  Google::Ads::GoogleAds::V8::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;
use Google::Ads::GoogleAds::V8::Utils::ResourceNames;

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

sub migrate_promotion_feed_to_asset {
  my ($api_client, $customer_id, $feed_item_id) = @_;

  # Get the GoogleAdsService client.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $extension_feed_item_resource_name =
    Google::Ads::GoogleAds::V8::Utils::ResourceNames::extension_feed_item(
    $customer_id, $feed_item_id);

  # Get the target extension feed item.
  my $extension_feed_item =
    get_extension_feed_item($google_ads_service, $customer_id, $feed_item_id);

  # Get all campaign IDs associated with the extension feed item.
  my @campaign_ids =
    get_targeted_campaign_ids($google_ads_service, $customer_id,
    $extension_feed_item_resource_name);

  # Get all ad group IDs associated with the extension feed item.
  my @ad_group_ids =
    get_targeted_ad_group_ids($google_ads_service, $customer_id,
    $extension_feed_item_resource_name);

  # Create a new Promotion asset that matches the target extension feed item.
  my $promotion_asset_resource_name =
    create_promotion_asset_from_feed($api_client, $customer_id,
    $extension_feed_item);

  # Associate the new Promotion asset with the same campaigns as the original.
  associate_asset_with_campaigns($api_client, $customer_id,
    $promotion_asset_resource_name,
    @campaign_ids);

  # Associate the new Promotion asset with the same ad groups as the original.
  associate_asset_with_ad_groups($api_client, $customer_id,
    $promotion_asset_resource_name,
    @ad_group_ids);

  return 1;
}

# Gets the requested Promotion-type extension feed item.
#
# Note that extension feed items pertain to feeds that were created by Google.
# Use FeedService to instead retrieve a user-created Feed.
sub get_extension_feed_item {
  my ($google_ads_service, $customer_id, $feed_item_id) = @_;

  # Create a query that will retrieve the requested Promotion-type extension
  # feed item and ensure that all fields are populated.
  my $extension_feed_item_query = "
        SELECT
            extension_feed_item.id,
            extension_feed_item.ad_schedules,
            extension_feed_item.device,
            extension_feed_item.status,
            extension_feed_item.start_date_time,
            extension_feed_item.end_date_time,
            extension_feed_item.targeted_campaign,
            extension_feed_item.targeted_ad_group,
            extension_feed_item.promotion_feed_item.discount_modifier,
            extension_feed_item.promotion_feed_item.final_mobile_urls,
            extension_feed_item.promotion_feed_item.final_url_suffix,
            extension_feed_item.promotion_feed_item.final_urls,
            extension_feed_item.promotion_feed_item.language_code,
            extension_feed_item.promotion_feed_item.money_amount_off.amount_micros,
            extension_feed_item.promotion_feed_item.money_amount_off.currency_code,
            extension_feed_item.promotion_feed_item.occasion,
            extension_feed_item.promotion_feed_item.orders_over_amount.amount_micros,
            extension_feed_item.promotion_feed_item.orders_over_amount.currency_code,
            extension_feed_item.promotion_feed_item.percent_off,
            extension_feed_item.promotion_feed_item.promotion_code,
            extension_feed_item.promotion_feed_item.promotion_end_date,
            extension_feed_item.promotion_feed_item.promotion_start_date,
            extension_feed_item.promotion_feed_item.promotion_target,
            extension_feed_item.promotion_feed_item.tracking_url_template
        FROM extension_feed_item
        WHERE
            extension_feed_item.extension_type = 'PROMOTION'
            AND extension_feed_item.id = $feed_item_id
        LIMIT 1";

  my $fetched_extension_feed_item;

  # Issue a search request to get the extension feed item contents.
  my $search_stream_request =
    Google::Ads::GoogleAds::V8::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
    ->new({
      customerId => $customer_id,
      query      => $extension_feed_item_query
    });

  my $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $google_ads_service,
      request => $search_stream_request
    });

  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row = shift;
      $fetched_extension_feed_item = $google_ads_row->{extensionFeedItem};
    });

  # Create a query to retrieve any URL customer parameters attached to the
  # feed item.
  my $url_custom_parameters_query = "
        SELECT feed_item.url_custom_parameters
        FROM feed_item
        WHERE feed_item.id = $feed_item_id";

  # Issue a search request to get any URL custom parameters.
  $search_stream_request =
    Google::Ads::GoogleAds::V8::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
    ->new({
      customerId => $customer_id,
      query      => $url_custom_parameters_query
    });

  $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $google_ads_service,
      request => $search_stream_request
    });

  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row = shift;
      push
        @{$fetched_extension_feed_item->{promotionFeedItem}{urlCustomParameters}
        }, @{$google_ads_row->{feedItem}{urlCustomParameters}};
    });

  printf "Retrieved details for ad extension with ID %d.\n",
    $fetched_extension_feed_item->{id};

  return $fetched_extension_feed_item;
}

# Finds and returns all of the campaigns that are associated with the specified
# Promotion extension feed item.
# [START migrate_promotion_feed_to_asset_1]
sub get_targeted_campaign_ids {
  my ($google_ads_service, $customer_id, $extension_feed_item_resource_name) =
    @_;

  my @campaign_ids;

  my $query = "
        SELECT campaign.id, campaign_extension_setting.extension_feed_items
        FROM campaign_extension_setting
        WHERE campaign_extension_setting.extension_type = 'PROMOTION'
          AND campaign.status != 'REMOVED'";

  my $search_stream_request =
    Google::Ads::GoogleAds::V8::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
    ->new({
      customerId => $customer_id,
      query      => $query
    });

  my $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $google_ads_service,
      request => $search_stream_request
    });

  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row = shift;

      # Add the campaign ID to the list of IDs if the extension feed item
      # is associated with this extension setting.
      if (grep { $_ eq $extension_feed_item_resource_name }
        @{$google_ads_row->{campaignExtensionSetting}{extensionFeedItems}})
      {
        printf
          "Found matching campaign with ID $google_ads_row->{campaign}{id}.\n";
        push @campaign_ids, $google_ads_row->{campaign}{id};
      }
    });

  return @campaign_ids;
}
# [END migrate_promotion_feed_to_asset_1]

# Finds and returns all of the ad groups that are associated with the specified
# Promotion extension feed item.
sub get_targeted_ad_group_ids {
  my ($google_ads_service, $customer_id, $extension_feed_item_resource_name) =
    @_;

  my @ad_group_ids;

  my $query = "
        SELECT ad_group.id, ad_group_extension_setting.extension_feed_items
        FROM ad_group_extension_setting
        WHERE ad_group_extension_setting.extension_type = 'PROMOTION'
          AND ad_group.status != 'REMOVED'";

  my $search_stream_request =
    Google::Ads::GoogleAds::V8::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
    ->new({
      customerId => $customer_id,
      query      => $query
    });

  my $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $google_ads_service,
      request => $search_stream_request
    });

  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row = shift;

      # Add the ad group ID to the list of IDs if the extension feed item
      # is associated with this extension setting.
      if (grep { $_ eq $extension_feed_item_resource_name }
        @{$google_ads_row->{adGroupExtensionSetting}{extensionFeedItems}})
      {
        printf
          "Found matching ad group with ID $google_ads_row->{adGroup}{id}.\n";
        push @ad_group_ids, $google_ads_row->{adGroup}{id};
      }
    });

  return @ad_group_ids;
}

# Create a Promotion asset that copies values from the specified extension feed
# item.
# [START migrate_promotion_feed_to_asset]
sub create_promotion_asset_from_feed {
  my ($api_client, $customer_id, $extension_feed_item) = @_;

  my $promotion_feed_item = $extension_feed_item->{promotionFeedItem};

  # Create the Promotion asset.
  my $asset = Google::Ads::GoogleAds::V8::Resources::Asset->new({
      name => "Migrated from feed item #" . $extension_feed_item->{id},
      trackingUrlTemplate => $promotion_feed_item->{trackingUrlTemplate},
      finalUrlSuffix      => $promotion_feed_item->{finalUrlSuffix},
      promotionAsset => Google::Ads::GoogleAds::V8::Common::PromotionAsset->new(
        {
          promotionTarget     => $promotion_feed_item->{promotionTarget},
          discountModifier    => $promotion_feed_item->{discountModifier},
          redemptionStartDate => $promotion_feed_item->{promotionStartDate},
          redemptionEndDate   => $promotion_feed_item->{promotionEndDate},
          occasion            => $promotion_feed_item->{occasion},
          languageCode        => $promotion_feed_item->{languageCode}})});

  push @{$asset->{finalUrls}}, @{$promotion_feed_item->{finalUrls}};

  # Copy optional fields if present in the existing extension.
  if (defined($extension_feed_item->{adSchedules})) {
    push @{$asset->{promotionAsset}{adScheduleTargets}},
      @{$extension_feed_item->{adSchedules}};
  }

  if (defined($promotion_feed_item->{finalMobileUrls})) {
    push @{$asset->{finalMobileUrls}},
      @{$promotion_feed_item->{finalMobileUrls}};
  }

  if (defined($promotion_feed_item->{urlCustomParameters})) {
    push @{$asset->{urlCustomParameters}},
      @{$promotion_feed_item->{urlCustomParameters}};
  }

  # Either percentOff or moneyAmountOff must be set.
  if (defined($promotion_feed_item->{percentOff})) {
    # Adjust the percent off scale when copying.
    $asset->{promotionAsset}{percentOff} =
      $promotion_feed_item->{percentOff} / 100;
  } else {
    $asset->{promotionAsset}{moneyAmountOff} =
      Google::Ads::GoogleAds::V8::Common::Money->new({
        amountMicros => $promotion_feed_item->{moneyAmountOff}{amountMicros},
        currencyCode => $promotion_feed_item->{moneyAmountOff}{currencyCode}});
  }

  # Either promotionCode or ordersOverAmount must be set.
  if (defined($promotion_feed_item->{promotionCode})) {
    $asset->{promotionAsset}{promotionCode} =
      $promotion_feed_item->{promotionCode};
  } else {
    $asset->{promotionAsset}{ordersOverAmount} =
      Google::Ads::GoogleAds::V8::Common::Money->new({
        amountMicros => $promotion_feed_item->{ordersOverAmount}{amountMicros},
        currencyCode => $promotion_feed_item->{ordersOverAmount}{currencyCode}}
      );
  }

  # Set the start and end dates if set in the existing extension.
  if (defined($extension_feed_item->{startDateTime})) {
    $asset->{promotionAsset}{startDate} =
      substr($extension_feed_item->{startDateTime},
      0, index($extension_feed_item->{startDateTime}, ' '));
  }

  if (defined($extension_feed_item->{endDateTime})) {
    $asset->{promotionAsset}{endDate} =
      substr($extension_feed_item->{endDateTime},
      0, index($extension_feed_item->{endDateTime}, ' '));
  }

  # Build an operation to create the Promotion asset.
  my $operation =
    Google::Ads::GoogleAds::V8::Services::AssetService::AssetOperation->new({
      create => $asset
    });

  # Issue the request and return the resource name of the new Promotion asset.
  my $response = $api_client->AssetService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});

  printf
    "Created Promotion asset with resource name '%s'.\n",
    $response->{results}[0]{resourceName};

  return $response->{results}[0]{resourceName};
}
# [END migrate_promotion_feed_to_asset]

# Associates the specified Promotion asset with the specified campaigns.
# [START migrate_promotion_feed_to_asset_2]
sub associate_asset_with_campaigns {
  my ($api_client, $customer_id, $promotion_asset_resource_name, @campaign_ids)
    = @_;

  if (scalar(@campaign_ids) == 0) {
    printf "Asset was not associated with any campaigns.\n";
    return ();
  }

  my $operations = [];

  foreach my $campaign_id (@campaign_ids) {
    my $campaign_asset =
      Google::Ads::GoogleAds::V8::Resources::CampaignAsset->new({
        asset     => $promotion_asset_resource_name,
        fieldType => PROMOTION,
        campaign  => Google::Ads::GoogleAds::V8::Utils::ResourceNames::campaign(
          $customer_id, $campaign_id
        )});

    my $operation =
      Google::Ads::GoogleAds::V8::Services::CampaignAssetService::CampaignAssetOperation
      ->new({
        create => $campaign_asset
      });

    push @$operations, $operation;
  }

  my $response = $api_client->CampaignAssetService()->mutate({
    customerId => $customer_id,
    operations => $operations
  });

  foreach my $result (@{$response->{results}}) {
    printf "Created campaign asset with resource name '%s'.\n",
      $result->{resourceName};
  }
}
# [END migrate_promotion_feed_to_asset_2]

# Associates the specified Promotion asset with the specified ad groups.
sub associate_asset_with_ad_groups {
  my ($api_client, $customer_id, $promotion_asset_resource_name, @ad_group_ids)
    = @_;

  if (scalar(@ad_group_ids) == 0) {
    printf "Asset was not associated with any ad groups.\n";
    return ();
  }

  my $operations = [];

  foreach my $ad_group_id (@ad_group_ids) {
    my $ad_group_asset =
      Google::Ads::GoogleAds::V8::Resources::AdGroupAsset->new({
        asset     => $promotion_asset_resource_name,
        fieldType => PROMOTION,
        adGroup   => Google::Ads::GoogleAds::V8::Utils::ResourceNames::ad_group(
          $customer_id, $ad_group_id
        )});

    my $operation =
      Google::Ads::GoogleAds::V8::Services::AdGroupAssetService::AdGroupAssetOperation
      ->new({
        create => $ad_group_asset
      });

    push @$operations, $operation;
  }

  my $response = $api_client->AdGroupAssetService()->mutate({
    customerId => $customer_id,
    operations => $operations
  });

  foreach my $result (@{$response->{results}}) {
    printf "Created ad group asset with resource name '%s'.\n",
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
  "customer_id=s"  => \$customer_id,
  "feed_item_id=i" => \$feed_item_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $feed_item_id);

# Call the example.
migrate_promotion_feed_to_asset($api_client, $customer_id =~ s/-//gr,
  $feed_item_id);

=pod

=head1 NAME

migrate_promotion_feed_to_asset

=head1 DESCRIPTION

This code example retrieves the full details of a Promotion Feed-based extension
and creates a matching Promotion asset-based extension. The new Asset-based
extension will then be associated with the same campaigns and ad groups as the
original Feed-based extension.

Once copied, you should remove the Feed-based extension; see
remove_entire_sitelink_campaign_extension_setting.pl for an example.

=head1 SYNOPSIS

migrate_promotion_feed_to_asset.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -feed_item_id               ID of the ExtensionFeedItem to migrate.

=cut
