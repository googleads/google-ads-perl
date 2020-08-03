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
# This example gets all available criterion bid modifier simulations for a given
# campaign. To get campaigns, run get_campaigns.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use
  Google::Ads::GoogleAds::V4::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;

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

sub get_campaign_criterion_bid_modifier_simulations {
  my ($api_client, $customer_id, $campaign_id) = @_;

  # Create a query that retrieves the criterion bid modifier simulations.
  my $search_query =
    "SELECT campaign_criterion_simulation.criterion_id, " .
    "campaign_criterion_simulation.start_date, " .
    "campaign_criterion_simulation.end_date, " .
    "campaign_criterion_simulation.bid_modifier_point_list.points " .
    "FROM campaign_criterion_simulation " .
    "WHERE campaign_criterion_simulation.type = BID_MODIFIER " .
    "AND campaign_criterion_simulation.campaign_id = $campaign_id";

  my $search_stream_request =
    Google::Ads::GoogleAds::V4::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
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
  # print the requested field values for the campaign criterion bid modifier
  # simulation in each row.
  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row = shift;
      my $simulation     = $google_ads_row->{campaignCriterionSimulation};

      printf "Found campaign-level criterion bid modifier simulation for " .
        "criterion with ID %d, start date '%s', end date '%s', and points:\n",
        $simulation->{criterionId},
        $simulation->{startDate}, $simulation->{endDate};

      foreach my $point (@{$simulation->{bidModifierPointList}{points}}) {
        printf
          "  bid modifier: %.2f => clicks: %d, cost: %d, impressions: %d, " .
          "parent clicks: %d, parent cost: %d, parent impressions: %d, " .
          "parent required budget: %d\n",
          $point->{bidModifier},
          $point->{clicks},
          $point->{costMicros},
          $point->{impressions},
          $point->{parentClicks},
          $point->{parentCostMicros},
          $point->{parentImpressions},
          $point->{parentRequiredBudgetMicros};
      }
    });

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
  "customer_id=s" => \$customer_id,
  "campaign_id=i" => \$campaign_id,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $campaign_id);

# Call the example.
get_campaign_criterion_bid_modifier_simulations($api_client,
  $customer_id =~ s/-//gr, $campaign_id);

=pod

=head1 NAME

get_campaign_criterion_bid_modifier_simulations

=head1 DESCRIPTION

This example gets all available criterion bid modifier simulations for a given
campaign. To get campaigns, run get_campaigns.pl.

=head1 SYNOPSIS

get_campaign_criterion_bid_modifier_simulations.pl [options]

    -help                       Show the help messacge.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID to get the criterion bid modifier
                                simulations.

=cut
