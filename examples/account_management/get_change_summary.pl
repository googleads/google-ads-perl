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
# This example gets a list of which resources have been changed in your account
# in the last 14 days.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use Google::Ads::GoogleAds::V23::Enums::ChangeStatusResourceTypeEnum
  qw(AD_GROUP AD_GROUP_AD AD_GROUP_CRITERION CAMPAIGN CAMPAIGN_CRITERION FEED FEED_ITEM AD_GROUP_FEED CAMPAIGN_FEED AD_GROUP_BID_MODIFIER);
use
  Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsRequest;

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

# [START get_change_summary]
sub get_change_summary {
  my ($api_client, $customer_id) = @_;

  # Construct a search query to find information about changed resources in your
  # account.
  my $search_query =
    "SELECT change_status.resource_name, change_status.last_change_date_time, "
    . "change_status.resource_status, "
    . "change_status.resource_type, "
    . "change_status.ad_group, "
    . "change_status.ad_group_ad, "
    . "change_status.ad_group_bid_modifier, "
    . "change_status.ad_group_criterion, "
    . "change_status.ad_group_feed, "
    . "change_status.campaign, "
    . "change_status.campaign_criterion, "
    . "change_status.campaign_feed, "
    . "change_status.feed, "
    . "change_status.feed_item "
    . "FROM change_status "
    . "WHERE change_status.last_change_date_time DURING LAST_14_DAYS "
    . "ORDER BY change_status.last_change_date_time "
    . "LIMIT 10000";

  # Create a search Google Ads request that will retrieve all change statuses using
  # pages of the specified page size.
  my $search_request =
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query
    });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $iterator = Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
    service => $google_ads_service,
    request => $search_request
  });

  # Iterate over all rows in all pages and print the requested field values for
  # the change status in each row.
  while ($iterator->has_next) {
    my $google_ads_row = $iterator->next;

    my $change_status = $google_ads_row->{changeStatus};

    printf "On %s, change status '%s' shows a resource type of '%s' " .
      "with resource name '%s' was '%s'.\n",
      $change_status->{lastChangeDateTime},
      $change_status->{resourceName}, $change_status->{resourceType},
      __get_resource_name_for_resource_type($change_status),
      $change_status->{resourceStatus};
  }

  return 1;
}

# This method returns the resource name of the changed field based on the
# resource type. The changed field's parent is also populated but is not used.
sub __get_resource_name_for_resource_type {
  my $change_status = shift;
  my $resource_type = $change_status->{resourceType};
  if ($resource_type eq AD_GROUP) {
    return $change_status->{adGroup};
  } elsif ($resource_type eq AD_GROUP_AD) {
    return $change_status->{adGroupAd};
  } elsif ($resource_type eq AD_GROUP_BID_MODIFIER) {
    return $change_status->{adGroupBidModifier};
  } elsif ($resource_type eq AD_GROUP_CRITERION) {
    return $change_status->{adGroupCriterion};
  } elsif ($resource_type eq AD_GROUP_FEED) {
    return $change_status->{adGroupFeed};
  } elsif ($resource_type eq CAMPAIGN) {
    return $change_status->{campaign};
  } elsif ($resource_type eq CAMPAIGN_CRITERION) {
    return $change_status->{campaignCriterion};
  } elsif ($resource_type eq CAMPAIGN_FEED) {
    return $change_status->{campaignFeed};
  } elsif ($resource_type eq FEED) {
    return $change_status->{feed};
  } elsif ($resource_type eq FEED_ITEM) {
    return $change_status->{feedItem};
  } else {
    return "";
  }
}
# [END get_change_summary]

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
get_change_summary($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

get_change_summary

=head1 DESCRIPTION

This example gets a list of which resources have been changed in your account
in the last 14 days.

=head1 SYNOPSIS

get_change_summary.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
