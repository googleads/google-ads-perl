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
# This example gets keyword performance statistics for the 50 keywords with the
# most impressions over the last 7 days.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use
  Google::Ads::GoogleAds::V14::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;

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

# [START get_keyword_stats]
sub get_keyword_stats {
  my ($api_client, $customer_id) = @_;

  # Limit to the 50 keywords with the most impressions in the date range.
  # If you wish to exclude entries with zero impressions, include a
  # predicate in the WHERE statement like 'metrics.impressions > 0'.
  my $search_query =
    "SELECT campaign.id, campaign.name, ad_group.id, ad_group.name, " .
    "ad_group_criterion.criterion_id, ad_group_criterion.keyword.text, " .
    "ad_group_criterion.keyword.match_type, " .
    "metrics.impressions, metrics.clicks, metrics.cost_micros " .
    "FROM keyword_view WHERE segments.date DURING LAST_7_DAYS " .
    "AND campaign.advertising_channel_type = 'SEARCH' " .
    "AND ad_group.status = 'ENABLED' " .
    "AND ad_group_criterion.status IN ('ENABLED', 'PAUSED') " .
    "ORDER BY metrics.impressions DESC LIMIT 50";

  # Create a search Google Ads stream request that will retrieve all keyword
  # statistics.
  my $search_stream_request =
    Google::Ads::GoogleAds::V14::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query,
    });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $google_ads_service,
      request => $search_stream_request
    });

  # Issue a search request and process the stream response to print the requested
  # field values for the keyword in each row.
  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row     = shift;
      my $campaign           = $google_ads_row->{campaign};
      my $ad_group           = $google_ads_row->{adGroup};
      my $ad_group_criterion = $google_ads_row->{adGroupCriterion};
      my $metrics            = $google_ads_row->{metrics};

      printf "Keyword text '%s' with match type '%s' and ID %d in ad group" .
        " '%s' with ID %d in campaign '%s' with ID %d had %d impression(s), " .
        "%d click(s), and %d cost (in micros) during the last 7 days.\n",
        $ad_group_criterion->{keyword}{text},
        $ad_group_criterion->{keyword}{matchType},
        $ad_group_criterion->{criterionId},
        $ad_group->{name},
        $ad_group->{id},
        $campaign->{name},
        $campaign->{id},
        $metrics->{impressions},
        $metrics->{clicks},
        $metrics->{costMicros};
    });

  return 1;
}
# [END get_keyword_stats]

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
get_keyword_stats($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

get_keyword_stats

=head1 DESCRIPTION

This example gets keyword performance statistics for the 50 keywords with the
most impressions over the last 7 days.

=head1 SYNOPSIS

get_keyword_stats.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
