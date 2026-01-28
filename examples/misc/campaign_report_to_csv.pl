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
# This code example illustrates how to get metrics about a campaign and serialize
# the result as a CSV file.

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

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";
# Optional: You may pass the output file path on the command line or specify it
# here. If neither are set a null value will be passed to the campaign_report_to_csv()
# method and the default path will be used: `campaign_report_to_csv.csv` file in
# the folder where the script is located.
my $output_file_path = undef;

sub campaign_report_to_csv {
  my ($api_client, $customer_id, $output_file_path) = @_;

  # Create a query that retrieves campaigns.
  my $query =
"SELECT campaign.id, campaign.name, campaign.contains_eu_political_advertising, segments.date, "
    . "metrics.impressions, metrics.clicks, metrics.cost_micros "
    . "FROM campaign WHERE segments.date DURING LAST_7_DAYS "
    . "AND campaign.status = 'ENABLED' ORDER BY segments.date DESC";

  # Create a search Google Ads request that that retrieves campaigns.
  my $search_request =
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsRequest
    ->new({
      customerId => $customer_id,
      query      => $query
    });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $iterator = Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
    service => $google_ads_service,
    request => $search_request
  });

  # Iterate over all rows in all pages and extract the information.
  my $csv_rows = [];
  while ($iterator->has_next) {
    my $google_ads_row = $iterator->next;
    push @$csv_rows,
      [
      $google_ads_row->{campaign}{id},
      $google_ads_row->{campaign}{name},
      $google_ads_row->{campaign}{containsEuPoliticalAdvertising},
      $google_ads_row->{segments}{date},
      $google_ads_row->{metrics}{impressions},
      $google_ads_row->{metrics}{clicks},
      $google_ads_row->{metrics}{costMicros}];
  }

  if (scalar @$csv_rows == 0) {
    print "No results found.\n";
    return 0;
  }

  # Use default output file path when not set.
  if (!$output_file_path) {
    $output_file_path = __FILE__ =~ s/\.pl/.csv/r;
  }

  # Write the results to the CSV file.
  open(CSV, ">", $output_file_path)
    or die "Could not open file '$output_file_path'.";
  # Write the header row.
  print CSV join(
    ",",
    (
      "campaign.id",                                "campaign.name",
      "campaign.contains_eu_political_advertising", "segments.date",
      "metrics.impressions",                        "metrics.clicks",
      "metrics.cost_micros"
    )
    ),
    "\n";
  foreach my $csv_row (@$csv_rows) {
    print CSV join(",", @$csv_row), "\n";
  }
  close(CSV);

  printf "Successfully created %s with %d entries.", $output_file_path,
    scalar @$csv_rows;

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
  "customer_id=s"      => \$customer_id,
  "output_file_path=s" => \$output_file_path
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
campaign_report_to_csv($api_client, $customer_id =~ s/-//gr, $output_file_path);

=pod

=head1 NAME

campaign_report_to_csv

=head1 DESCRIPTION

This code example illustrates how to get metrics about a campaign and serialize
the result as a CSV file.

=head1 SYNOPSIS

campaign_report_to_csv.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -output_file_path           [optional] The output file path.

=cut
