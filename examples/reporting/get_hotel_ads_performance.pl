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
# This example gets Hotel-ads performance statistics for the 50 Hotel ad groups
# with the most impressions over the last 7 days.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use
  Google::Ads::GoogleAds::V14::Services::GoogleAdsService::SearchGoogleAdsRequest;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

use constant PAGE_SIZE => 1000;

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub get_hotel_ads_performance {
  my ($api_client, $customer_id) = @_;

  # Create a query that retrieves hotel-ads statistics for each campaign
  # and ad group. Returned statistics will be segmented by the check-in
  # day of week and length of stay.
  my $search_query =
    "SELECT campaign.id, campaign.advertising_channel_type, " .
    "ad_group.id, ad_group.status, " .
    "metrics.impressions, metrics.hotel_average_lead_value_micros, " .
    "segments.hotel_check_in_day_of_week, segments.hotel_length_of_stay " .
    "FROM hotel_performance_view WHERE segments.date DURING LAST_7_DAYS " .
    "AND campaign.advertising_channel_type = 'HOTEL' " .
    "AND ad_group.status = 'ENABLED' " .
    "ORDER BY metrics.impressions DESC LIMIT 50";

  # Create a search Google Ads request that will retrieve hotel-ads statistics
  # using pages of the specified page size.
  my $search_request =
    Google::Ads::GoogleAds::V14::Services::GoogleAdsService::SearchGoogleAdsRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query,
      pageSize   => PAGE_SIZE
    });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $iterator = Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
    service => $google_ads_service,
    request => $search_request
  });

  # Iterate over all rows in all pages and print the requested field values for
  # each row.
  while ($iterator->has_next) {
    my $google_ads_row = $iterator->next;

    printf "Ad group ID %d in campaign ID %d with hotel check-in on %s " .
      "and %d day(s) of stay had %d impression(s) and %d average lead value " .
      "(in micros) during the last 7 days.\n", $google_ads_row->{adGroup}{id},
      $google_ads_row->{campaign}{id},
      $google_ads_row->{segments}{hotelCheckInDayOfWeek},
      $google_ads_row->{segments}{hotelLengthOfStay},
      $google_ads_row->{metrics}{impressions},
      $google_ads_row->{metrics}{hotelAverageLeadValueMicros};
  }

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
GetOptions("customer_id=s" => \$customer_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
get_hotel_ads_performance($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

get_hotel_ads_performance

=head1 DESCRIPTION

This example gets Hotel-ads performance statistics for the 50 Hotel ad groups with
the most impressions over the last 7 days.

=head1 SYNOPSIS

get_hotel_ads_performance.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
