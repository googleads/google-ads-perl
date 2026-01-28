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
# Adds a customer-level data exclusion that excludes conversions from being used
# by Smart Bidding for the time interval specified.
#
# For more information on using data exclusions, see:
# https://developers.google.com/google-ads/api/docs/campaigns/bidding/data-exclusions.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::BiddingDataExclusion;
use Google::Ads::GoogleAds::V23::Enums::SeasonalityEventScopeEnum  qw(CHANNEL);
use Google::Ads::GoogleAds::V23::Enums::AdvertisingChannelTypeEnum qw(SEARCH);
use
  Google::Ads::GoogleAds::V23::Services::BiddingDataExclusionService::BiddingDataExclusionOperation;

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
my $customer_id     = "INSERT_CUSTOMER_ID_HERE";
my $start_date_time = "INSERT_START_DATE_TIME_HERE";
my $end_date_time   = "INSERT_END_DATE_TIME_HERE";

# Adds a "CUSTOMER" scoped data exclusion for the client customer ID and dates specified.
sub add_bidding_data_exclusion {
  my ($api_client, $customer_id, $start_date_time, $end_date_time) = @_;

  # [START add_bidding_data_exclusion]
  my $data_exclusion =
    Google::Ads::GoogleAds::V23::Resources::BiddingDataExclusion->new({
      # A unique name is required for every data exclusion.
      name => "Data exclusion #" . uniqid(),
      # The CHANNEL scope applies the data exclusion to all campaigns of specific
      # advertising channel types. In this example, the exclusion will only apply
      # to Search campaigns. Use the CAMPAIGN scope to instead limit the scope to
      # specific campaigns.
      scope                   => CHANNEL,
      advertisingChannelTypes => [SEARCH],
      # If setting scope CAMPAIGN, add individual campaign resource name(s)
      # according to the commented out line below.
      # campaigns     => ["INSERT_CAMPAIGN_RESOURCE_NAME_HERE"],
      startDateTime => $start_date_time,
      endDateTime   => $end_date_time
    });

  my $operation =
    Google::Ads::GoogleAds::V23::Services::BiddingDataExclusionService::BiddingDataExclusionOperation
    ->new({
      create => $data_exclusion
    });

  my $response = $api_client->BiddingDataExclusionService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});

  printf "Added data exclusion with resource name: '%s'.\n",
    $response->{results}[0]{resourceName};
  # [END add_bidding_data_exclusion]

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
  "customer_id=s"     => \$customer_id,
  "start_date_time=s" => \$start_date_time,
  "end_date_time=s"   => \$end_date_time
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $start_date_time, $end_date_time);

# Call the example.
add_bidding_data_exclusion($api_client, $customer_id =~ s/-//gr,
  $start_date_time, $end_date_time);

=pod

=head1 NAME

add_bidding_data_exclusion

=head1 DESCRIPTION

Adds a customer-level data exclusion that excludes conversions from being used
by Smart Bidding for the time interval specified.

For more information on using data exclusions, see:
https://developers.google.com/google-ads/api/docs/campaigns/bidding/data-exclusions.

=head1 SYNOPSIS

add_bidding_data_exclusion.pl [options]

    -help                       Show the help message.
    -customer_id                The client customer ID of the Google Ads account
                                that the data exclusion will be added to.
    -start_date_time            The start date time in yyyy-MM-dd HH:mm:ss format
                                of the data exclusion period.
    -end_date_time              The end date time in yyyy-MM-dd HH:mm:ss format
                                of the data exclusion period.

=cut
