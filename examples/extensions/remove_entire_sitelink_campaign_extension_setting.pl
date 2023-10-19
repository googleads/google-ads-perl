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
# Removes the entire sitelink campaign extension setting by removing both the
# sitelink campaign extension setting itself and its associated sitelink
# extension feed items. This requires two steps, since removing the campaign
# extension setting doesn't automatically remove its extension feed items.
#
# To make this example work with other types of extensions, find references to
# 'SITELINK' and replace it with the extension type you wish to remove.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use Google::Ads::GoogleAds::V15::Enums::ExtensionTypeEnum qw(SITELINK);
use
  Google::Ads::GoogleAds::V15::Services::CampaignExtensionSettingService::CampaignExtensionSettingOperation;
use
  Google::Ads::GoogleAds::V15::Services::ExtensionFeedItemService::ExtensionFeedItemOperation;
use Google::Ads::GoogleAds::V15::Services::GoogleAdsService::MutateOperation;
use
  Google::Ads::GoogleAds::V15::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;
use Google::Ads::GoogleAds::V15::Utils::ResourceNames;

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

# [START remove_entire_sitelink_campaign_extension_setting]
sub remove_entire_sitelink_campaign_extension_setting {
  my ($api_client, $customer_id, $campaign_id) = @_;

  my $mutate_operations = [];

  # Create a mutate operation that contains the campaign extension setting operation
  # to remove the specified sitelink campaign extension setting.
  push(
    @$mutate_operations,
    create_sitelink_campaign_extension_setting_mutate_operation(
      $customer_id, $campaign_id
    ));

  # Get all sitelink extension feed items of the specified campaign.
  my $extension_feed_item_resource_names =
    get_all_sitelink_extension_feed_items($api_client, $customer_id,
    $campaign_id);

  # Create mutate operations, each of which contains an extension feed item operation
  # to remove the specified extension feed items.
  push(
    @$mutate_operations,
    create_extension_feed_item_mutate_operations(
      $extension_feed_item_resource_names));

  # Issue a mutate request to remove the campaign extension setting and its
  # extension feed items.
  my $mutate_google_ads_response = $api_client->GoogleAdsService()->mutate({
    customerId       => $customer_id,
    mutateOperations => $mutate_operations
  });
  my $mutate_operation_responses =
    $mutate_google_ads_response->{mutateOperationResponses};

  # Print the information on the removed campaign extension setting and its
  # extension feed items.
  # Each mutate operation response is returned in the same order as we passed
  # its corresponding operation. Therefore, the first belongs to the campaign
  # setting operation, and the rest belong to the extension feed item operations.
  printf "Removed a campaign extension setting with resource name '%s'.\n",
    @$mutate_operation_responses[0]
    ->{campaignExtensionSettingResult}{resourceName};

  shift(@$mutate_operation_responses);
  foreach my $response (@$mutate_operation_responses) {
    printf "Removed an extension feed item with resource name '%s'.\n",
      $response->{extensionFeedItemResult}{resourceName};
  }

  return 1;
}
# [END remove_entire_sitelink_campaign_extension_setting]

# Creates a mutate operation for the sitelink campaign extension setting that
# will be removed.
sub create_sitelink_campaign_extension_setting_mutate_operation {
  my ($customer_id, $campaign_id) = @_;

  # Construct the resource name of the campaign extension setting to remove.
  my $campaign_extension_setting_resource_name =
    Google::Ads::GoogleAds::V15::Utils::ResourceNames::campaign_extension_setting(
    $customer_id, $campaign_id, SITELINK);

  # Create a campaign extension setting operation.
  my $campaign_extension_setting_operation =
    Google::Ads::GoogleAds::V15::Services::CampaignExtensionSettingService::CampaignExtensionSettingOperation
    ->new({
      remove => $campaign_extension_setting_resource_name
    });

  # Create and return a mutate operation for the campaign extension setting
  # operation.
  return
    Google::Ads::GoogleAds::V15::Services::GoogleAdsService::MutateOperation->
    new({
      campaignExtensionSettingOperation => $campaign_extension_setting_operation
    });
}

# Return all sitelink extension feed items associated to the specified campaign
# extension setting.
# [START remove_entire_sitelink_campaign_extension_setting_1]
sub get_all_sitelink_extension_feed_items {
  my ($api_client, $customer_id, $campaign_id) = @_;

  my $extension_feed_item_resource_names = [];

  # Issue a search stream request, then iterate over all responses.
  my $search_stream_request =
    Google::Ads::GoogleAds::V15::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
    ->new({
      customerId => $customer_id,
      query      => sprintf(
        "SELECT campaign_extension_setting.campaign, " .
          "campaign_extension_setting.extension_type, " .
          "campaign_extension_setting.extension_feed_items " .
          "FROM campaign_extension_setting " .
          "WHERE campaign_extension_setting.campaign = '%s' " .
          "AND campaign_extension_setting.extension_type = 'SITELINK'",
        Google::Ads::GoogleAds::V15::Utils::ResourceNames::campaign(
          $customer_id, $campaign_id
        ))});

  my $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $api_client->GoogleAdsService(),
      request => $search_stream_request
    });

  # Print out and store in a list each extension feed item's resource name.
  $search_stream_handler->process_contents(
    sub {
      # Display the results and add the resource names to the list.
      my $google_ads_row = shift;

      foreach my $extension_feed_item_resource_name (
        @{$google_ads_row->{campaignExtensionSetting}{extensionFeedItems}})
      {
        push(@$extension_feed_item_resource_names,
          $extension_feed_item_resource_name);
        printf "Extension feed item with resource name '%s' was found.\n",
          $extension_feed_item_resource_name;
      }
    });

  if (!@$extension_feed_item_resource_names) {
    die("The specified campaign does not contain a sitelink campaign " .
        "extension setting.\n");
  }

  return $extension_feed_item_resource_names;
}
# [END remove_entire_sitelink_campaign_extension_setting_1]

# Creates mutate operations for the sitelink extension feed items that will be
# removed.
sub create_extension_feed_item_mutate_operations {
  my ($extension_feed_item_resource_names) = @_;

  my $operations = [];

  foreach
    my $extension_feed_item_resource_name (@$extension_feed_item_resource_names)
  {
    my $operation =
      Google::Ads::GoogleAds::V15::Services::ExtensionFeedItemService::ExtensionFeedItemOperation
      ->new({
        remove => $extension_feed_item_resource_name
      });

    push(
      @$operations,
      Google::Ads::GoogleAds::V15::Services::GoogleAdsService::MutateOperation
        ->new({
          extensionFeedItemOperation => $operation
        }));
  }
  return $operations;
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
  "customer_id=s" => \$customer_id,
  "campaign_id=i" => \$campaign_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $campaign_id);

# Call the example.
remove_entire_sitelink_campaign_extension_setting($api_client,
  $customer_id =~ s/-//gr, $campaign_id);

=pod

=head1 NAME

remove_entire_sitelink_campaign_extension_setting

=head1 DESCRIPTION

Removes the entire sitelink campaign extension setting by removing both the
sitelink campaign extension setting itself and its associated sitelink extension
feed items. This requires two steps, since removing the campaign extension
setting doesn't automatically remove its extension feed items.

To make this example work with other types of extensions, find references to
'SITELINK' and replace it with the extension type you wish to remove.

=head1 SYNOPSIS

remove_entire_sitelink_campaign_extension_setting.pl [options]

    -help                           Show the help message.
    -customer_id                    The Google Ads customer ID.
    -campaign_id                    ID of the campaign from which sitelinks will
                                    be removed.

=cut
