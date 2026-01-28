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
# This example gets ad group bid modifiers.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use
  Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsRequest;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

sub get_ad_group_bid_modifiers {
  my ($api_client, $customer_id, $ad_group_id) = @_;

  # Create a query that retrieves ad group bid modifiers.
  my $search_query =
    "SELECT ad_group.id, ad_group_bid_modifier.criterion_id, campaign.id, " .
    "ad_group_bid_modifier.bid_modifier, " .
    "ad_group_bid_modifier.device.type, " .
    "ad_group_bid_modifier.hotel_date_selection_type.type, " .
    "ad_group_bid_modifier.hotel_advance_booking_window.min_days, " .
    "ad_group_bid_modifier.hotel_advance_booking_window.max_days, " .
    "ad_group_bid_modifier.hotel_length_of_stay.min_nights, " .
    "ad_group_bid_modifier.hotel_length_of_stay.max_nights, " .
    "ad_group_bid_modifier.hotel_check_in_day.day_of_week, " .
    "ad_group_bid_modifier.hotel_check_in_date_range.start_date, " .
    "ad_group_bid_modifier.hotel_check_in_date_range.end_date " .
    "FROM ad_group_bid_modifier";

  if ($ad_group_id) {
    $search_query .= " WHERE ad_group.id = $ad_group_id";
  }
  $search_query .= " LIMIT 10000";

  # Create a search Google Ads request that will retrieve all ad group bid modifiers
  # using pages of the specified page size.
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

  # Iterate over all rows in all pages and print the requested field values for the
  # ad group bid modifier in each row.
  while ($iterator->has_next) {
    my $google_ads_row        = $iterator->next;
    my $ad_group_bid_modifier = $google_ads_row->{adGroupBidModifier};
    my $ad_group              = $google_ads_row->{adGroup};
    my $campaign              = $google_ads_row->{campaign};

    printf
      "Ad group bid modifier with criterion ID %d, bid modifier value %s, " .
      "was found in an ad group with ID %d of campaign ID %d.\n",
      $ad_group_bid_modifier->{criterionId},
      $ad_group_bid_modifier->{bidModifier}
      ? sprintf "%.2f", $ad_group_bid_modifier->{bidModifier}
      : "none",
      $ad_group->{id},
      $campaign->{id};

    my $criterion_details = "  - Criterion type: '%s', ";
    if ($ad_group_bid_modifier->{device}) {
      $criterion_details = sprintf $criterion_details, "Device";
      $criterion_details .= sprintf "Type: '%s'",
        $ad_group_bid_modifier->{device}{type};
    } elsif ($ad_group_bid_modifier->{hotelAdvanceBookingWindow}) {
      $criterion_details = sprintf $criterion_details,
        "HotelAdvanceBookingWindow";
      $criterion_details .= sprintf "Min Days: %d, Max Days: %d",
        $ad_group_bid_modifier->{hotelAdvanceBookingWindow}{minDays},
        $ad_group_bid_modifier->{hotelAdvanceBookingWindow}{maxDays};
    } elsif ($ad_group_bid_modifier->{hotelCheckInDateRange}) {
      $criterion_details = sprintf $criterion_details, "HotelCheckInDateRange";
      $criterion_details .= sprintf "Start Date: %s, End Date: %s",
        $ad_group_bid_modifier->{hotelCheckInDateRange}{startDate},
        $ad_group_bid_modifier->{hotelCheckInDateRange}{endDate};
    } elsif ($ad_group_bid_modifier->{hotelCheckInDay}) {
      $criterion_details = sprintf $criterion_details, "HotelCheckInDay";
      $criterion_details .= sprintf "Day of the week: %s",
        $ad_group_bid_modifier->{hotelCheckInDay}{dayOfWeek};
    } elsif ($ad_group_bid_modifier->{HotelDateSelectionType}) {
      $criterion_details = sprintf $criterion_details, "HotelDateSelectionType";
      $criterion_details .= sprintf "Date selection type: '%s'",
        $ad_group_bid_modifier->{hotelDateSelectionType}{type};
    } elsif ($ad_group_bid_modifier->{hotelLengthOfStay}) {
      $criterion_details = sprintf $criterion_details, "HotelLengthOfStay";
      $criterion_details .= sprintf "Min Nights: %d, Max Nights: %d",
        $ad_group_bid_modifier->{hotelLengthOfStay}{minNights},
        $ad_group_bid_modifier->{hotelLengthOfStay}{maxNights};
    }

    print $criterion_details, "\n";
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

my $customer_id = undef;
my $ad_group_id = undef;

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s" => \$customer_id,
  "ad_group_id=i" => \$ad_group_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
get_ad_group_bid_modifiers($api_client, $customer_id =~ s/-//gr, $ad_group_id);

=pod

=head1 NAME

get_ad_group_bid_modifiers

=head1 DESCRIPTION

This example gets ad group bid modifiers.

=head1 SYNOPSIS

get_ad_group_bid_modifiers.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                [optional] The ad group ID.

=cut
