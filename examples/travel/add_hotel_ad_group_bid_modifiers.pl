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
# This example shows how to add ad group bid modifiers to a hotel ad group based
# on hotel check-in day and hotel length of stay.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Resources::AdGroupBidModifier;
use Google::Ads::GoogleAds::V21::Common::HotelCheckInDayInfo;
use Google::Ads::GoogleAds::V21::Common::HotelLengthOfStayInfo;
use Google::Ads::GoogleAds::V21::Enums::DayOfWeekEnum qw(MONDAY);
use
  Google::Ads::GoogleAds::V21::Services::AdGroupBidModifierService::AdGroupBidModifierOperation;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

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
my $ad_group_id = "INSERT_AD_GROUP_ID_HERE";

# [START add_hotel_ad_group_bid_modifiers]
sub add_hotel_ad_group_bid_modifiers {
  my ($api_client, $customer_id, $ad_group_id) = @_;

  # 1) Create an ad group bid modifier based on the hotel check-in day.
  my $check_in_day_ad_group_bid_modifier =
    Google::Ads::GoogleAds::V21::Resources::AdGroupBidModifier->new({
      # Set the ad group.
      adGroup => Google::Ads::GoogleAds::V21::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      ),
      hotelCheckInDay =>
        Google::Ads::GoogleAds::V21::Common::HotelCheckInDayInfo->new({
          dayOfWeek => MONDAY
        }
        ),
      # Set the bid modifier value to 150%.
      bidModifier => 1.5
    });

  # Create an ad group bid modifier operation.
  my $check_in_day_ad_group_bid_modifier_operation =
    Google::Ads::GoogleAds::V21::Services::AdGroupBidModifierService::AdGroupBidModifierOperation
    ->new({
      create => $check_in_day_ad_group_bid_modifier
    });

  # 2) Create an ad group bid modifier based on the hotel length of stay.
  my $length_of_stay_ad_group_bid_modifier =
    Google::Ads::GoogleAds::V21::Resources::AdGroupBidModifier->new({
      # Set the ad group.
      adGroup => Google::Ads::GoogleAds::V21::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      ),
      # Create the hotel length of stay info.
      hotelLengthOfStay =>
        Google::Ads::GoogleAds::V21::Common::HotelLengthOfStayInfo->new({
          minNights => 3,
          maxNights => 7
        }
        ),
      # Set the bid modifier value to 170%.
      bidModifier => 1.7
    });

  # Create an ad group bid modifier operation.
  my $length_of_stay_ad_group_bid_modifier_operation =
    Google::Ads::GoogleAds::V21::Services::AdGroupBidModifierService::AdGroupBidModifierOperation
    ->new({
      create => $length_of_stay_ad_group_bid_modifier
    });

  # 3) Add the ad group bid modifiers.
  my $ad_group_bid_modifiers_response =
    $api_client->AdGroupBidModifierService()->mutate({
      customerId => $customer_id,
      operations => [
        $check_in_day_ad_group_bid_modifier_operation,
        $length_of_stay_ad_group_bid_modifier_operation
      ]});

  # Print out resource names of the added ad group bid modifiers.
  my $ad_group_bid_modifier_results =
    $ad_group_bid_modifiers_response->{results};
  printf "Added %d hotel ad group bid modifiers:\n",
    scalar @$ad_group_bid_modifier_results;

  foreach my $ad_group_bid_modifier_result (@$ad_group_bid_modifier_results) {
    printf "\t%s\n", $ad_group_bid_modifier_result->{resourceName};
  }

  return 1;
}
# [END add_hotel_ad_group_bid_modifiers]

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
  "ad_group_id=i" => \$ad_group_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $ad_group_id);

# Call the example.
add_hotel_ad_group_bid_modifiers($api_client, $customer_id =~ s/-//gr,
  $ad_group_id);

=pod

=head1 NAME

add_hotel_ad_group_bid_modifiers

=head1 DESCRIPTION

This example shows how to add ad group bid modifiers to a hotel ad group based on
hotel check-in day and hotel length of stay.

=head1 SYNOPSIS

add_hotel_ad_group_bid_modifiers.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                The hotel ad group ID.

=cut
