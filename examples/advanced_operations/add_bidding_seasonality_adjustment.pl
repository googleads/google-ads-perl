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
# Adds a customer-level seasonality adjustment that adjusts Smart Bidding behavior
# by the expected change in conversion rate for the given future time interval.
#
# For more information on using seasonality adjustments, see:
# https://developers.google.com/google-ads/api/docs/campaigns/bidding/seasonality-adjustments.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Resources::BiddingSeasonalityAdjustment;
use Google::Ads::GoogleAds::V21::Enums::SeasonalityEventScopeEnum  qw(CHANNEL);
use Google::Ads::GoogleAds::V21::Enums::AdvertisingChannelTypeEnum qw(SEARCH);
use
  Google::Ads::GoogleAds::V21::Services::BiddingSeasonalityAdjustmentService::BiddingSeasonalityAdjustmentOperation;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id              = "INSERT_CUSTOMER_ID_HERE";
my $start_date_time          = "INSERT_START_DATE_TIME_HERE";
my $end_date_time            = "INSERT_END_DATE_TIME_HERE";
my $conversion_rate_modifier = "INSERT_CONVERSION_RATE_MODIFIER_HERE";

# Adds a "CUSTOMER" scoped seasonality adjustment for the client customer ID,
# dates, and conversion modifier rate specified.
sub add_bidding_seasonality_adjustment {
  my ($api_client, $customer_id, $start_date_time, $end_date_time,
    $conversion_rate_modifier)
    = @_;

  # [START add_bidding_seasonality_adjustment]
  my $seasonality_adjustment =
    Google::Ads::GoogleAds::V21::Resources::BiddingSeasonalityAdjustment->new({
      # A unique name is required for every seasonality adjustment.
      name => "Seasonality adjustment #" . uniqid(),
      # The CHANNEL scope applies the conversion_rate_modifier to all campaigns
      # of specific advertising channel types. In this example, the conversion_rate_modifier
      # will only apply to Search campaigns. Use the CAMPAIGN scope to instead
      # limit the scope to specific campaigns.
      scope                   => CHANNEL,
      advertisingChannelTypes => [SEARCH],
      # If setting scope CAMPAIGN, add individual campaign resource name(s)
      # according to the commented out line below.
      # campaigns     => ["INSERT_CAMPAIGN_RESOURCE_NAME_HERE"],
      startDateTime => $start_date_time,
      endDateTime   => $end_date_time,
      # The conversion_rate_modifier is the expected future conversion rate change.
      # When this field is unset or set to 1.0, no adjustment will be applied to traffic.
      # The allowed range is 0.1 to 10.0.
      conversionRateModifier => $conversion_rate_modifier
    });

  my $operation =
    Google::Ads::GoogleAds::V21::Services::BiddingSeasonalityAdjustmentService::BiddingSeasonalityAdjustmentOperation
    ->new({
      create => $seasonality_adjustment
    });

  my $response = $api_client->BiddingSeasonalityAdjustmentService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});

  printf "Added seasonality adjustment with resource name: '%s'.\n",
    $response->{results}[0]{resourceName};
  # [END add_bidding_seasonality_adjustment]

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
  "customer_id=s"              => \$customer_id,
  "start_date_time=s"          => \$start_date_time,
  "end_date_time=s"            => \$end_date_time,
  "conversion_rate_modifier=f" => \$conversion_rate_modifier
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $start_date_time, $end_date_time,
  $conversion_rate_modifier);

# Call the example.
add_bidding_seasonality_adjustment($api_client, $customer_id =~ s/-//gr,
  $start_date_time, $end_date_time, $conversion_rate_modifier);

=pod

=head1 NAME

add_bidding_seasonality_adjustment

=head1 DESCRIPTION

Adds a customer-level seasonality adjustment that adjusts Smart Bidding behavior
by the expected change in conversion rate for the given future time interval.

For more information on using seasonality adjustments, see:
https://developers.google.com/google-ads/api/docs/campaigns/bidding/seasonality-adjustments.

=head1 SYNOPSIS

add_bidding_seasonality_adjustment.pl [options]

    -help                       Show the help message.
    -customer_id                The client customer ID of the Google Ads account
                                that the seasonality adjustment will be added to.
    -start_date_time            The start date time in yyyy-MM-dd HH:mm:ss format
                                of the conversion rate adjustment period.
    -end_date_time              The end date time in yyyy-MM-dd HH:mm:ss format
                                of the conversion rate adjustment period.
    -conversion_rate_modifier   The conversion rate modifier that will be applied
                                during the adjustment interval.

=cut
