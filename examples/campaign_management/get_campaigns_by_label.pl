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
# This example gets all campaigns with a specific label.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use
  Google::Ads::GoogleAds::V10::Services::GoogleAdsService::SearchGoogleAdsRequest;

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
my $label_id    = "INSERT_LABEL_ID_HERE";

# [START get_campaigns_by_label]
sub get_campaigns_by_label {
  my ($api_client, $customer_id, $label_id) = @_;

  # Create the search query.
  my $search_query =
    "SELECT campaign.id, campaign.name, label.id, label.name " .
    "FROM campaign_label WHERE label.id = $label_id ORDER BY campaign.id";

  # Create a search Google Ads request that will retrieve all campaign labels
  # with the specified label Id using pages of the specified page size.
  my $search_request =
    Google::Ads::GoogleAds::V10::Services::GoogleAdsService::SearchGoogleAdsRequest
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

  # Iterate over all rows in all pages and print the requested field values for the
  # campaigns and labels in each row. The results include the campaign and label
  # objects because these were included in the search criteria.
  while ($iterator->has_next) {
    my $google_ads_row = $iterator->next;

    printf "Campaign found with name '%s', ID %d, and label: '%s'.\n",
      $google_ads_row->{campaign}{name}, $google_ads_row->{campaign}{id},
      $google_ads_row->{label}{name};
  }

  return 1;
}
# [END get_campaigns_by_label]

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
  "label_id=i"    => \$label_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $label_id);

# Call the example.
get_campaigns_by_label($api_client, $customer_id =~ s/-//gr, $label_id);

=pod

=head1 NAME

get_campaigns_by_label

=head1 DESCRIPTION

This example gets all campaigns with a specific label.

=head1 SYNOPSIS

get_campaigns_by_label.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -label_id                   The label ID.

=cut
