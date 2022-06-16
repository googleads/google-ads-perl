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
# This example gets expanded text ads for a customer or for a specific ad group.
# To add expanded text ads, run add_expanded_text_ads.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use
  Google::Ads::GoogleAds::V11::Services::GoogleAdsService::SearchGoogleAdsRequest;

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
my $ad_group_id = undef;

sub get_expanded_text_ads {
  my ($api_client, $customer_id, $ad_group_id) = @_;

  # Create the search query.
  my $search_query =
    "SELECT ad_group.id, ad_group_ad.ad.id, " .
    "ad_group_ad.ad.expanded_text_ad.headline_part1, " .
    "ad_group_ad.ad.expanded_text_ad.headline_part2, " .
    "ad_group_ad.status FROM ad_group_ad " .
    "WHERE ad_group_ad.ad.type = EXPANDED_TEXT_AD";

  if ($ad_group_id) {
    $search_query .= " AND ad_group.id = $ad_group_id";
  }

  # Create a search Google Ads request that will retrieve all expanded text ads
  # using pages of the specified page size.
  my $search_request =
    Google::Ads::GoogleAds::V11::Services::GoogleAdsService::SearchGoogleAdsRequest
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
  # the expanded text ad in each row.
  while ($iterator->has_next) {
    my $google_ads_row = $iterator->next;

    my $ad                    = $google_ads_row->{adGroupAd}{ad};
    my $expanded_text_ad_info = $ad->{expandedTextAd};

    printf
      "Expanded text ad with ID %d, status '%s', and headline '%s - %s' " .
      "was found in ad group with ID %d.\n",
      $ad->{id},
      $google_ads_row->{adGroupAd}{status},
      $expanded_text_ad_info->{headlinePart1},
      $expanded_text_ad_info->{headlinePart2},
      $google_ads_row->{adGroup}{id};
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
GetOptions("customer_id=s" => \$customer_id, "ad_group_id=i" => \$ad_group_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
get_expanded_text_ads($api_client, $customer_id =~ s/-//gr, $ad_group_id);

=pod

=head1 NAME

get_expanded_text_ads

=head1 DESCRIPTION

This example gets expanded text ads for a customer or for a specific ad group.
To add expanded text ads, run add_expanded_text_ads.pl.

=head1 SYNOPSIS

get_expanded_text_ads.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                [optional] The ad group ID.

=cut
