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
# This example gets all available ad group criterion CPC bid simulations for a
# given ad group. To get ad groups, run get_ad_groups.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use
  Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;

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

# [START get_ad_group_criterion_cpc_bid_simulations]
sub get_ad_group_criterion_cpc_bid_simulations {
  my ($api_client, $customer_id, $ad_group_id) = @_;

  # Create a query that retrieves the ad group criterion CPC bid simulations.
  my $search_query =
    "SELECT ad_group_criterion_simulation.ad_group_id, " .
    "ad_group_criterion_simulation.criterion_id, " .
    "ad_group_criterion_simulation.start_date, " .
    "ad_group_criterion_simulation.end_date, " .
    "ad_group_criterion_simulation.cpc_bid_point_list.points " .
    "FROM ad_group_criterion_simulation " .
    "WHERE ad_group_criterion_simulation.type = CPC_BID " .
    "AND ad_group_criterion_simulation.ad_group_id = $ad_group_id";

  my $search_stream_request =
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query
    });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $google_ads_service,
      request => $search_stream_request
    });

  # Issue a search stream request, iterate over all rows in all messages and
  # print the requested field values for the ad group criterion CPC bid
  # simulation in each row.
  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row = shift;
      my $simulation     = $google_ads_row->{adGroupCriterionSimulation};

      printf
        "Found ad group criterion CPC bid simulation for ad group ID %d, " .
        "criterion ID %d, start date '%s', end date '%s', and points:\n",
        $simulation->{adGroupId}, $simulation->{criterionId},
        $simulation->{startDate}, $simulation->{endDate};

      foreach my $point (@{$simulation->{cpcBidPointList}{points}}) {
        printf "  bid: %d => clicks: %d, cost: %d, impressions: %d, " .
          "biddable conversions: %.2f, biddable conversions value: %.2f\n",
          $point->{cpcBidMicros},
          $point->{clicks},
          $point->{costMicros},
          $point->{impressions},
          $point->{biddableConversions},
          $point->{biddableConversionsValue};
      }
    });

  return 1;
}
# [END get_ad_group_criterion_cpc_bid_simulations]

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
  "ad_group_id=i" => \$ad_group_id,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $ad_group_id);

# Call the example.
get_ad_group_criterion_cpc_bid_simulations($api_client,
  $customer_id =~ s/-//gr, $ad_group_id);

=pod

=head1 NAME

get_ad_group_criterion_cpc_bid_simulations

=head1 DESCRIPTION

This example gets all available ad group criterion CPC bid simulations for a
given ad group. To get ad groups, run get_ad_groups.pl.

=head1 SYNOPSIS

get_ad_group_criterion_cpc_bid_simulations.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                The ad group ID to get the ad group criterion CPC
                                bid simulations for.

=cut
